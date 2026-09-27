"""Standalone Windows PostMessage keyboard driver, using only the standard library."""

from __future__ import annotations

import ctypes
import sys
from ctypes import wintypes
from time import sleep


MODIFIERS: dict[str, int] = {
    "LCTRL": 0x11, "RCTRL": 0x11,
    "LALT": 0x12, "RALT": 0x12,
    "LSHIFT": 0x10, "RSHIFT": 0x10,
}
VIRTUAL_KEYS: dict[str, int] = {
    **MODIFIERS,
    "UP": 0x26, "DOWN": 0x28, "LEFT": 0x25, "RIGHT": 0x27,
    "HOME": 0x24, "END": 0x23, "PAGEUP": 0x21, "PAGEDOWN": 0x22,
    "INSERT": 0x2D, "DELETE": 0x2E, "SPACE": 0x20, "TAB": 0x09,
    "ENTER": 0x0D, "ESCAPE": 0x1B, "BACKSPACE": 0x08,
    "NUMPADPLUS": 0x6B, "NUMPADMINUS": 0x6D, "NUMPADMULTIPLY": 0x6A,
    "NUMPADDIVIDE": 0x6F, "NUMPADDECIMAL": 0x6E,
    ",": 0xBC, ".": 0xBE, "/": 0xBF, ";": 0xBA, "'": 0xDE,
    "[": 0xDB, "]": 0xDD, "\\": 0xDC, "=": 0xBB, "-": 0xBD, "`": 0xC0,
}
VIRTUAL_KEYS.update({key: ord(key) for key in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"})
VIRTUAL_KEYS.update({f"F{number}": 0x6F + number for number in range(1, 25)})
VIRTUAL_KEYS.update({f"NUMPAD{number}": 0x60 + number for number in range(10)})

FIXED_SCAN_CODES: dict[str, int] = {
    "LCTRL": 0x1D, "RCTRL": 0xE01D, "LALT": 0x38, "RALT": 0xE038,
    "LSHIFT": 0x2A, "RSHIFT": 0x36,
    "UP": 0xE048, "DOWN": 0xE050, "LEFT": 0xE04B, "RIGHT": 0xE04D,
    "HOME": 0xE047, "END": 0xE04F, "PAGEUP": 0xE049, "PAGEDOWN": 0xE051,
    "INSERT": 0xE052, "DELETE": 0xE053,
    "NUMPAD0": 0x52, "NUMPAD1": 0x4F, "NUMPAD2": 0x50, "NUMPAD3": 0x51,
    "NUMPAD4": 0x4B, "NUMPAD5": 0x4C, "NUMPAD6": 0x4D, "NUMPAD7": 0x47,
    "NUMPAD8": 0x48, "NUMPAD9": 0x49, "NUMPADPLUS": 0x4E, "NUMPADMINUS": 0x4A,
    "NUMPADMULTIPLY": 0x37, "NUMPADDIVIDE": 0xE035, "NUMPADDECIMAL": 0x53,
}


def parse_keys(keys: str) -> tuple[str, ...]:
    if not isinstance(keys, str) or not keys:
        raise ValueError("组合键必须为非空字符串")
    remaining = keys.upper()
    modifiers: list[str] = []
    while True:
        prefix = next((name for name in MODIFIERS if remaining.startswith(name + "-")), None)
        if prefix is None:
            break
        if prefix in modifiers:
            raise ValueError(f"修饰键重复：{prefix}")
        modifiers.append(prefix)
        remaining = remaining[len(prefix) + 1:]
    if remaining not in VIRTUAL_KEYS or remaining in MODIFIERS:
        raise ValueError(f"非法主键：{remaining!r}")
    return (*modifiers, remaining)


class Keyboard:
    def __init__(self, pid: int | None) -> None:
        self.pid = pid
        self._user32: ctypes.CDLL | None = None

    def _api(self) -> ctypes.CDLL:
        if sys.platform != "win32":
            raise OSError("键盘驱动仅支持 Windows")
        if self._user32 is None:
            api = ctypes.WinDLL("user32", use_last_error=True)
            callback_type = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
            api.EnumWindows.argtypes = [callback_type, wintypes.LPARAM]
            api.EnumWindows.restype = wintypes.BOOL
            api.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
            api.GetWindowThreadProcessId.restype = wintypes.DWORD
            api.IsWindowVisible.argtypes = [wintypes.HWND]
            api.IsWindowVisible.restype = wintypes.BOOL
            api.GetWindow.argtypes = [wintypes.HWND, wintypes.UINT]
            api.GetWindow.restype = wintypes.HWND
            api.PostMessageW.argtypes = [wintypes.HWND, wintypes.UINT, wintypes.WPARAM, wintypes.LPARAM]
            api.PostMessageW.restype = wintypes.BOOL
            api.MapVirtualKeyW.argtypes = [wintypes.UINT, wintypes.UINT]
            api.MapVirtualKeyW.restype = wintypes.UINT
            self._user32 = api
        return self._user32

    def _target(self, api: ctypes.CDLL) -> int:
        if self.pid is None:
            raise OSError("未选定游戏进程")
        matches: list[int] = []

        def visit(hwnd: int, parameter: int) -> bool:
            pid = wintypes.DWORD()
            if api.GetWindowThreadProcessId(hwnd, ctypes.byref(pid)):
                if pid.value == self.pid and api.IsWindowVisible(hwnd) and not api.GetWindow(hwnd, 4):
                    matches.append(hwnd)
            return True

        callback_type = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
        if not api.EnumWindows(callback_type(visit), 0):
            raise ctypes.WinError(ctypes.get_last_error())
        if len(matches) != 1:
            raise OSError(f"PID {self.pid} 的可见无属主窗口必须唯一，实际找到 {len(matches)} 个")
        return matches[0]

    def send(self, keys: str) -> None:
        names = parse_keys(keys)
        api = self._api()
        target = self._target(api)
        prepared: list[tuple[int, int]] = []
        for name in names:
            virtual_key = VIRTUAL_KEYS[name]
            scan = FIXED_SCAN_CODES.get(name)
            if scan is None:
                scan = int(api.MapVirtualKeyW(virtual_key, 4))
            if not scan or scan & 0xFF00 not in (0, 0xE000):
                raise OSError(f"无法映射按键扫描码：{name}")
            lparam = 1 | ((scan & 0xFF) << 16) | (int(bool(scan & 0xE000)) << 24)
            prepared.append((virtual_key, lparam))

        pressed: list[tuple[int, int]] = []
        failure: Exception | None = None
        try:
            for virtual_key, lparam in prepared:
                if not api.PostMessageW(target, 0x0100, virtual_key, lparam):
                    raise ctypes.WinError(ctypes.get_last_error())
                pressed.append((virtual_key, lparam))
            sleep(0.01)
        except Exception as error:
            failure = error
        finally:
            for virtual_key, lparam in reversed(pressed):
                try:
                    if not api.PostMessageW(target, 0x0101, virtual_key, lparam | 0xC0000000):
                        raise ctypes.WinError(ctypes.get_last_error())
                except Exception as error:
                    if failure is None:
                        failure = error
                    else:
                        failure.add_note(f"释放键 {virtual_key} 失败：{error}")
        if failure is not None:
            raise failure
