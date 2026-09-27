"""GDI capture, exact marker location, and the shared latest snapshot."""

from __future__ import annotations

import ctypes
import sys
import time
from ctypes import wintypes
from dataclasses import dataclass
from math import ceil
from threading import Event, Lock

import cv2
import numpy as np
import numpy.typing as npt
from PySide6.QtCore import QObject, QTimer, Qt, Signal, Slot

type RGBImage = npt.NDArray[np.uint8]


@dataclass(frozen=True)
class Bounds:
    left: int
    top: int
    right: int
    bottom: int

    @property
    def width(self) -> int:
        return self.right - self.left

    @property
    def height(self) -> int:
        return self.bottom - self.top


class BITMAPINFOHEADER(ctypes.Structure):
    _fields_ = [
        ("biSize", wintypes.DWORD),
        ("biWidth", wintypes.LONG),
        ("biHeight", wintypes.LONG),
        ("biPlanes", wintypes.WORD),
        ("biBitCount", wintypes.WORD),
        ("biCompression", wintypes.DWORD),
        ("biSizeImage", wintypes.DWORD),
        ("biXPelsPerMeter", wintypes.LONG),
        ("biYPelsPerMeter", wintypes.LONG),
        ("biClrUsed", wintypes.DWORD),
        ("biClrImportant", wintypes.DWORD),
    ]


class BITMAPINFO(ctypes.Structure):
    _fields_ = [("bmiHeader", BITMAPINFOHEADER), ("bmiColors", wintypes.DWORD * 1)]


def windows_error(operation: str) -> OSError:
    if sys.platform == "win32":
        return OSError(f"{operation} 失败：{ctypes.WinError(ctypes.get_last_error())}")
    return OSError("GDI 截图仅支持 Windows")


def checked_handle(value: int | None, operation: str) -> int:
    if not value or (operation == "SelectObject" and value == ctypes.c_void_p(-1).value):
        raise windows_error(operation)
    return value


class GDIBackend:
    """只持有当前采集线程的 Windows 资源，不负责定位或业务校验。"""

    def __init__(self) -> None:
        if sys.platform != "win32":
            raise OSError("GDI 截图仅支持 Windows")
        self._user32: ctypes.CDLL = ctypes.WinDLL("user32", use_last_error=True)
        self._gdi32: ctypes.CDLL = ctypes.WinDLL("gdi32", use_last_error=True)
        self._screen_dc: int | None = None
        self._memory_dc: int | None = None
        self._bitmap: int | None = None
        self._size: tuple[int, int] | None = None
        self._previous_dpi: int | None = None
        self._declare_signatures()
        try:
            # 仅修改截图线程，不改变 Qt 主线程的 DPI 上下文。
            self._previous_dpi = checked_handle(self._user32.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4)), "SetThreadDpiAwarenessContext")
            self._screen_dc = checked_handle(self._user32.GetDC(None), "GetDC")
            self._memory_dc = checked_handle(self._gdi32.CreateCompatibleDC(self._screen_dc), "CreateCompatibleDC")
        except Exception:
            self.close()
            raise

    def _declare_signatures(self) -> None:
        """显式声明指针与句柄宽度，避免 64 位环境默认整数返回值截断。"""
        user32, gdi32 = self._user32, self._gdi32
        user32.SetThreadDpiAwarenessContext.argtypes = [wintypes.HANDLE]
        user32.SetThreadDpiAwarenessContext.restype = wintypes.HANDLE
        user32.GetSystemMetrics.argtypes = [ctypes.c_int]
        user32.GetSystemMetrics.restype = ctypes.c_int
        user32.GetDC.argtypes = [wintypes.HWND]
        user32.GetDC.restype = wintypes.HDC
        user32.ReleaseDC.argtypes = [wintypes.HWND, wintypes.HDC]
        user32.ReleaseDC.restype = ctypes.c_int
        gdi32.CreateCompatibleDC.argtypes = [wintypes.HDC]
        gdi32.CreateCompatibleDC.restype = wintypes.HDC
        gdi32.CreateCompatibleBitmap.argtypes = [wintypes.HDC, ctypes.c_int, ctypes.c_int]
        gdi32.CreateCompatibleBitmap.restype = wintypes.HBITMAP
        gdi32.SelectObject.argtypes = [wintypes.HDC, wintypes.HGDIOBJ]
        gdi32.SelectObject.restype = wintypes.HGDIOBJ
        gdi32.BitBlt.argtypes = [wintypes.HDC, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, wintypes.HDC, ctypes.c_int, ctypes.c_int, wintypes.DWORD]
        gdi32.BitBlt.restype = wintypes.BOOL
        gdi32.GetDIBits.argtypes = [wintypes.HDC, wintypes.HBITMAP, wintypes.UINT, wintypes.UINT, ctypes.c_void_p, ctypes.POINTER(BITMAPINFO), wintypes.UINT]
        gdi32.GetDIBits.restype = ctypes.c_int
        gdi32.DeleteObject.argtypes = [wintypes.HGDIOBJ]
        gdi32.DeleteObject.restype = wintypes.BOOL
        gdi32.DeleteDC.argtypes = [wintypes.HDC]
        gdi32.DeleteDC.restype = wintypes.BOOL

    def desktop_bounds(self) -> Bounds:
        """取整个虚拟桌面的物理像素范围，左侧或上方显示器可产生负坐标。"""
        left = int(self._user32.GetSystemMetrics(76))  # SM_XVIRTUALSCREEN
        top = int(self._user32.GetSystemMetrics(77))  # SM_YVIRTUALSCREEN
        width = int(self._user32.GetSystemMetrics(78))  # SM_CXVIRTUALSCREEN
        height = int(self._user32.GetSystemMetrics(79))  # SM_CYVIRTUALSCREEN
        if width <= 0 or height <= 0:
            raise OSError("无法取得虚拟桌面尺寸")
        return Bounds(left, top, left + width, top + height)

    def capture(self, bounds: Bounds) -> RGBImage:
        """复用同尺寸位图，交付不依赖 Windows 缓冲区的连续 RGB 快照。"""
        if self._screen_dc is None or self._memory_dc is None:
            raise OSError("GDI 后端已经关闭")
        width, height = bounds.width, bounds.height
        if width <= 0 or height <= 0:
            raise ValueError("截图区域宽高必须大于 0")
        # 全屏定位切换到基板局部采集时才重建位图。
        if self._size != (width, height):
            if self._bitmap is not None:
                if not self._gdi32.DeleteObject(self._bitmap):
                    raise windows_error("DeleteObject")
                self._bitmap = None
            self._bitmap = checked_handle(self._gdi32.CreateCompatibleBitmap(self._screen_dc, width, height), "CreateCompatibleBitmap")
            self._size = (width, height)

        previous = checked_handle(self._gdi32.SelectObject(self._memory_dc, self._bitmap), "SelectObject")
        try:
            if not self._gdi32.BitBlt(self._memory_dc, 0, 0, width, height, self._screen_dc, bounds.left, bounds.top, 0x00CC0020):
                raise windows_error("BitBlt")
        finally:
            # GetDIBits 明确要求目标位图不再选入任何 DC。
            checked_handle(self._gdi32.SelectObject(self._memory_dc, previous), "SelectObject")

        bitmap_info = BITMAPINFO()
        bitmap_info.bmiHeader.biSize = ctypes.sizeof(BITMAPINFOHEADER)
        bitmap_info.bmiHeader.biWidth = width
        bitmap_info.bmiHeader.biHeight = -height  # 负高度要求自顶向下，保持与屏幕坐标同向。
        bitmap_info.bmiHeader.biPlanes = 1
        bitmap_info.bmiHeader.biBitCount = 32
        bitmap_info.bmiHeader.biCompression = 0  # BI_RGB
        buffer = (ctypes.c_ubyte * (width * height * 4))()
        lines = self._gdi32.GetDIBits(self._screen_dc, self._bitmap, 0, height, buffer, ctypes.byref(bitmap_info), 0)
        if lines != height:
            raise OSError(f"GetDIBits 只读取 {lines}/{height} 行")
        # GDI 输出 BGRA；丢弃 alpha、反转颜色通道，再独立保存 RGB。
        bgra = np.frombuffer(buffer, dtype=np.uint8).reshape(height, width, 4)
        return np.ascontiguousarray(bgra[:, :, 2::-1])

    def close(self) -> None:
        """尝试释放所有已申请资源并恢复线程 DPI；汇总释放错误。"""
        failures: list[str] = []
        if self._memory_dc is not None:
            if not self._gdi32.DeleteDC(self._memory_dc):
                failures.append("DeleteDC")
            self._memory_dc = None
        if self._bitmap is not None:
            if not self._gdi32.DeleteObject(self._bitmap):
                failures.append("DeleteObject")
            self._bitmap = None
        if self._screen_dc is not None:
            if not self._user32.ReleaseDC(None, self._screen_dc):
                failures.append("ReleaseDC")
            self._screen_dc = None
        if self._previous_dpi is not None:
            if not self._user32.SetThreadDpiAwarenessContext(self._previous_dpi):
                failures.append("SetThreadDpiAwarenessContext")
            self._previous_dpi = None
        if failures:
            raise OSError("GDI 资源释放失败：" + ", ".join(failures))


POINT_0 = (15, 25, 20)
POINT_1 = (25, 15, 20)
MARKER: RGBImage = np.repeat(np.repeat(np.array(
    [[POINT_0, POINT_1], [POINT_1, POINT_0]], dtype=np.uint8,
), 2, axis=0), 2, axis=1)
MARKER.flags.writeable = False


class LocationError(ValueError):
    def __init__(self, message: str, code: int = 1) -> None:
        super().__init__(message)
        self.code = code


def locate_region(image: RGBImage, origin: tuple[int, int] = (0, 0)) -> Bounds:
    """Locate a unique 12px board; OpenCV candidates must pass exact RGB checks."""
    if image.dtype != np.uint8 or image.ndim != 3 or image.shape[2] != 3:
        raise ValueError("定位输入必须为 RGB uint8 数组")
    if image.shape[0] < 12 or image.shape[1] < 8:
        raise LocationError("未找到定位点：图像小于基板尺寸")
    scores = cv2.matchTemplate(image, MARKER, cv2.TM_SQDIFF)
    # Allow floating-point template-matching roundoff, then compare every pixel.
    ys, xs = np.where(scores <= 1.0)
    rows: dict[int, list[int]] = {}
    for y_value, x_value in zip(ys, xs):
        x, y = int(x_value), int(y_value)
        if np.array_equal(image[y:y + 4, x:x + 4], MARKER):
            rows.setdefault(y, []).append(x)
    matches: list[Bounds] = []
    for top, lefts in rows.items():
        for left in lefts:
            for right_marker in rows.get(top + 8, []):
                width = right_marker + 4 - left
                if width >= 8 and width % 4 == 0:
                    matches.append(Bounds(
                        origin[0] + left, origin[1] + top,
                        origin[0] + right_marker + 4, origin[1] + top + 12,
                    ))
                    if len(matches) > 1:
                        raise LocationError("存在多个候选区域", 2)
    if not matches:
        raise LocationError("未找到有效定位区域")
    return matches[0]


def validate_markers(image: RGBImage) -> None:
    if not (np.array_equal(image[:4, :4], MARKER) and np.array_equal(image[-4:, -4:], MARKER)):
        raise LocationError("定位标记失效，等待重新定位")


@dataclass(frozen=True)
class CaptureSnapshot:
    capture_result: RGBImage | None = None
    capture_err: str = ""
    capture_code: int = -1
    capture_ts: int = 0
    started_ns: int = 0


class SharedCapture:
    def __init__(self) -> None:
        self._lock = Lock()
        self._snapshot = CaptureSnapshot()

    def read(self) -> CaptureSnapshot:
        with self._lock:
            return self._snapshot

    def publish(self, snapshot: CaptureSnapshot) -> None:
        with self._lock:
            self._snapshot = snapshot

    def clear(self, code: int = -1) -> None:
        with self._lock:
            previous = self._snapshot
            self._snapshot = CaptureSnapshot(
                capture_code=code, capture_ts=previous.capture_ts,
            )


class CaptureWorker(QObject):
    log = Signal(str)
    started = Signal()
    stopped = Signal()

    def __init__(self, shared: SharedCapture, fps: int = 25) -> None:
        super().__init__()
        self.shared = shared
        self.stop_requested = Event()
        self._fps = fps
        self._timer: QTimer | None = None
        self._backend: GDIBackend | None = None
        self._bounds: Bounds | None = None
        self._last_error = ""
        self._stopped = False

    @Slot()
    def start(self) -> None:
        if self.stop_requested.is_set():
            self.stop()
            return
        self._timer = QTimer(self)
        self._timer.setTimerType(Qt.TimerType.PreciseTimer)
        self._timer.timeout.connect(self._capture)
        self._timer.start(ceil(1000 / self._fps))
        self.log.emit("截图已启动")
        self.started.emit()

    @Slot(int)
    def set_fps(self, fps: int) -> None:
        self._fps = fps
        if self._timer is not None and self._timer.isActive():
            self._timer.setInterval(ceil(1000 / fps))

    @Slot()
    def reset_location(self) -> None:
        self._bounds = None

    def _release_backend(self) -> None:
        backend, self._backend = self._backend, None
        if backend is not None:
            try:
                backend.close()
            except Exception as error:
                self.log.emit(f"截图资源清理失败：{error}")

    @Slot()
    def _capture(self) -> None:
        if self.stop_requested.is_set():
            self.stop()
            return
        started_ns = time.monotonic_ns()
        try:
            if self._backend is None:
                self._backend = GDIBackend()
            located = self._bounds is None
            if self._bounds is None:
                desktop = self._backend.desktop_bounds()
                image = self._backend.capture(desktop)
                self._bounds = locate_region(image, (desktop.left, desktop.top))
                left, top = self._bounds.left - desktop.left, self._bounds.top - desktop.top
                image = image[top:top + 12, left:left + self._bounds.width].copy()
            else:
                image = self._backend.capture(self._bounds)
                validate_markers(image)
            image.flags.writeable = False
            self.shared.publish(CaptureSnapshot(image, "", 0, time.time_ns(), started_ns))
            if located or self._last_error:
                self.log.emit(f"定位成功：{self._bounds.left},{self._bounds.top}，{self._bounds.width}×12")
            self._last_error = ""
        except Exception as error:
            code = error.code if isinstance(error, LocationError) else 3
            reason = str(error) or type(error).__name__
            self._bounds = None
            self.shared.publish(CaptureSnapshot(None, reason, code, time.time_ns(), started_ns))
            if reason != self._last_error:
                self.log.emit(f"截图失败：{reason}")
                self._last_error = reason
            if code == 3:
                self._release_backend()

    @Slot()
    def stop(self) -> None:
        if self._stopped:
            return
        self._stopped = True
        self.stop_requested.set()
        if self._timer is not None:
            self._timer.stop()
        self._release_backend()
        self._bounds = None
        self.shared.clear()
        self.log.emit("截图已停止")
        self.stopped.emit()
