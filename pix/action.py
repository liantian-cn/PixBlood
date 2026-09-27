"""Action values and the single sequential Matrix → Context → Rotation worker."""

from __future__ import annotations

from dataclasses import dataclass
from math import ceil
import random
from threading import Event
import time
from typing import TYPE_CHECKING

from PySide6.QtCore import QObject, QTimer, Qt, Signal, Slot

from pix.capture import CaptureSnapshot, SharedCapture
from pix.context import Context
from pix.keyboard import Keyboard
from pix.matrix import Matrix

if TYPE_CHECKING:
    from pix.rotation import Rotation


@dataclass(frozen=True)
class Cast:
    name: str
    note: str | None = None


@dataclass(frozen=True)
class Use:
    name: str
    note: str | None = None


@dataclass(frozen=True)
class Idle:
    reason: str


@dataclass(frozen=True)
class Sleep:
    reason: str
    seconds: float = 1


class ActionWorker(QObject):
    log = Signal(str)
    started = Signal()
    stopped = Signal()

    def __init__(self, shared: SharedCapture, pid: int | None, fps: int = 10) -> None:
        super().__init__()
        self.shared = shared
        self.stop_requested = Event()
        self.rotation: Rotation | None = None
        self.keyboard = Keyboard(pid)
        self._fps = fps
        self._timer: QTimer | None = None
        self._last_error = ""
        self._stopped = False

    @Slot()
    def start(self) -> None:
        if self.stop_requested.is_set():
            self.stop()
            return
        try:
            # Action values are defined before Rotation imports them.
            from pix.rotation import Rotation

            self.rotation = Rotation()
            self._timer = QTimer(self)
            self._timer.setSingleShot(True)
            self._timer.setTimerType(Qt.TimerType.PreciseTimer)
            self._timer.timeout.connect(self._run)
            self._timer.start(0)
        except Exception as error:
            self.log.emit(f"循环启动失败：{error}")
            self.stop()
            return
        self.log.emit("循环已启动")
        self.started.emit()

    @Slot(int)
    def set_fps(self, fps: int) -> None:
        # Applies to the next ordinary schedule; never reschedules an active Sleep.
        self._fps = fps

    @Slot(object)
    def set_pid(self, pid: int | None) -> None:
        self.keyboard = Keyboard(pid)

    @staticmethod
    def _check_age(snapshot: CaptureSnapshot) -> None:
        if time.monotonic_ns() - snapshot.started_ns > 500_000_000:
            raise ValueError("截图帧已过期（超过 0.5 秒）")

    @Slot()
    def _run(self) -> None:
        if self.stop_requested.is_set():
            self.stop()
            return
        round_started = time.monotonic()
        sleep_deadline: float | None = None
        stage = "帧检查"
        try:
            snapshot = self.shared.read()
            if snapshot.capture_code != 0 or snapshot.capture_result is None:
                return
            self._check_age(snapshot)
            stage = "像素解码"
            ctx = Context(Matrix(snapshot.capture_result))
            stage = "循环计算"
            if self.rotation is None:
                raise RuntimeError("Rotation 尚未初始化")
            action = self.rotation.main_rotation(ctx)
            returned_at = time.monotonic()
            # No history tracking: a new successful frame does not cancel this decision.
            if self.stop_requested.is_set():
                return
            current = self.shared.read()
            if current.capture_code != 0 or current.capture_result is None:
                return
            stage = "帧检查"
            self._check_age(snapshot)
            stage = "动作执行"
            if isinstance(action, (Cast, Use)):
                keys = self.rotation.keymap[action.name]
                note = f"（{action.note}）" if action.note else ""
                self.log.emit(f"{type(action).__name__}：{action.name}{note}")
                stage = "键盘发送"
                self.keyboard.send(keys)
            elif isinstance(action, Idle):
                self.log.emit(f"Idle：{action.reason}")
            elif isinstance(action, Sleep):
                seconds = min(15, max(1, action.seconds))
                self.log.emit(f"Sleep：{action.reason}（{seconds:g} 秒）")
                sleep_deadline = returned_at + seconds
            else:
                raise TypeError(f"不支持的动作类型：{type(action).__name__}")
            self._last_error = ""
        except Exception as error:
            message = f"{stage}失败：{type(error).__name__}: {error}"
            if message != self._last_error:
                self.log.emit(message)
                self._last_error = message
        finally:
            if self.stop_requested.is_set():
                self.stop()
            elif self._timer is not None:
                if sleep_deadline is not None:
                    wait = max(0.0, sleep_deadline - time.monotonic())
                else:
                    interval = random.uniform(0.5 / self._fps, 1.5 / self._fps)
                    wait = max(0.0, interval - (time.monotonic() - round_started))
                self._timer.start(ceil(wait * 1000))

    @Slot()
    def stop(self) -> None:
        if self._stopped:
            return
        self._stopped = True
        self.stop_requested.set()
        if self._timer is not None:
            self._timer.stop()
        self.log.emit("循环已停止")
        self.stopped.emit()
