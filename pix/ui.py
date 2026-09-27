"""The complete UI, in-memory settings, process discovery and worker lifecycle."""

from __future__ import annotations

from datetime import datetime
from pathlib import Path
import shutil

import psutil
from PySide6.QtCore import QThread, QTimer, Qt, Signal, Slot
from PySide6.QtGui import QCloseEvent
from PySide6.QtWidgets import (
    QFormLayout, QGridLayout, QGroupBox, QLabel,
    QMainWindow, QMessageBox, QPlainTextEdit, QPushButton, QSpinBox, QVBoxLayout, QWidget,
)

from pix.action import ActionWorker
from pix.capture import CaptureWorker, RGBImage, SharedCapture


class MainWindow(QMainWindow):
    capture_stop = Signal()
    action_stop = Signal()
    location_reset = Signal()
    pid_changed = Signal(object)
    capture_fps_changed = Signal(int)
    action_fps_changed = Signal(int)

    def __init__(self) -> None:
        super().__init__()
        self.setWindowTitle("PixBlood")
        self.setFixedSize(1600, 1200)
        self.setWindowFlags(
            Qt.WindowType.Window
            | Qt.WindowType.CustomizeWindowHint
            | Qt.WindowType.WindowTitleHint
            | Qt.WindowType.WindowSystemMenuHint
            | Qt.WindowType.WindowCloseButtonHint
        )
        self.shared = SharedCapture()
        self.capture_result: RGBImage | None = None
        self.capture_err = ""
        self.capture_code = -1
        self.capture_ts = 0
        self.pid: int | None = None
        self.capture_fps = 25
        self.action_fps = 10
        self._capture_worker: CaptureWorker | None = None
        self._capture_thread: QThread | None = None
        self._action_worker: ActionWorker | None = None
        self._action_thread: QThread | None = None
        self._capture_state = "已停止"
        self._action_state = "已停止"
        self._stop_capture_pending = False
        self._closing = False
        self._last_log: str | None = None
        self._build_ui()
        self._process_timer = QTimer(self)
        self._process_timer.timeout.connect(self._discover_game)
        self._process_timer.start(1000)
        self._snapshot_timer = QTimer(self)
        self._snapshot_timer.timeout.connect(self._refresh_snapshot)
        self._snapshot_timer.start(50)
        self._discover_game()
        self._refresh_controls()

    def _build_ui(self) -> None:
        central = QWidget(self)
        self.setCentralWidget(central)
        grid = QGridLayout(central)
        grid.setColumnStretch(0, 1)
        grid.setColumnStretch(1, 3)
        grid.setRowStretch(0, 1)
        grid.setRowStretch(1, 9)

        buttons = QGroupBox("操作")
        button_layout = QVBoxLayout(buttons)
        self.capture_button = QPushButton("启动截图")
        self.action_button = QPushButton("启动循环")
        self.copy_button = QPushButton("拷贝插件")
        for button in (self.capture_button, self.action_button, self.copy_button):
            button_layout.addWidget(button)
        self.capture_button.clicked.connect(self._toggle_capture)
        self.action_button.clicked.connect(self._toggle_action)
        self.copy_button.clicked.connect(self._copy_addon)
        grid.addWidget(buttons, 0, 0)

        status = QGroupBox("状态")
        status_layout = QFormLayout(status)
        self.capture_label = QLabel()
        self.capture_label.setWordWrap(True)
        self.action_label = QLabel()
        self.directory_label = QLabel("未运行")
        self.directory_label.setWordWrap(True)
        self.directory_label.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        status_layout.addRow("截图：", self.capture_label)
        status_layout.addRow("循环：", self.action_label)
        status_layout.addRow("游戏目录：", self.directory_label)
        grid.addWidget(status, 1, 0)

        config = QGroupBox("配置")
        config_layout = QFormLayout(config)
        self.capture_spin = QSpinBox()
        self.capture_spin.setRange(15, 35)
        self.capture_spin.setValue(self.capture_fps)
        self.capture_spin.valueChanged.connect(self._set_capture_fps)
        self.action_spin = QSpinBox()
        self.action_spin.setRange(8, 16)
        self.action_spin.setValue(self.action_fps)
        self.action_spin.valueChanged.connect(self._set_action_fps)
        config_layout.addRow("截图 FPS", self.capture_spin)
        config_layout.addRow("Action 基础 FPS", self.action_spin)
        grid.addWidget(config, 0, 1)

        logs = QGroupBox("日志")
        log_layout = QVBoxLayout(logs)
        self.log_text = QPlainTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setLineWrapMode(QPlainTextEdit.LineWrapMode.WidgetWidth)
        self.log_text.setMaximumBlockCount(2000)
        log_layout.addWidget(self.log_text)
        grid.addWidget(logs, 1, 1)

    @Slot(str)
    def log(self, message: str) -> None:
        if message == self._last_log:
            return
        self._last_log = message
        self.log_text.appendPlainText(f"{datetime.now():%H:%M:%S.%f}  {message}")
        scrollbar = self.log_text.verticalScrollBar()
        scrollbar.setValue(scrollbar.maximum())

    @Slot(int)
    def _set_capture_fps(self, fps: int) -> None:
        self.capture_fps = fps
        self.capture_fps_changed.emit(fps)

    @Slot(int)
    def _set_action_fps(self, fps: int) -> None:
        self.action_fps = fps
        self.action_fps_changed.emit(fps)

    @Slot()
    def _copy_addon(self) -> None:
        try:
            if self.pid is None:
                raise OSError("未选定游戏进程，请先启动游戏")
            executable = psutil.Process(self.pid).exe()
            if not executable:
                raise OSError("可执行文件路径为空")
            source = Path(__file__).resolve().parent / "lua"
            if not source.is_dir() or not (source / "PixBlood.toc").is_file():
                raise OSError(f"插件源目录或 PixBlood.toc 缺失：{source}")
            destination = Path(executable).parent / "Interface" / "AddOns" / "PixBlood"
            shutil.copytree(source, destination, dirs_exist_ok=True)
        except (psutil.Error, OSError) as error:
            QMessageBox.warning(
                self, "拷贝插件失败",
                f"{type(error).__name__}: {error}\n\n"
                "若复制已开始，可能已有部分文件更新。请解决问题后重试。",
            )
            return
        QMessageBox.information(
            self, "拷贝插件",
            f"插件已完整复制到：\n{destination}\n\n请在游戏内执行 /reload。",
        )

    @Slot()
    def _discover_game(self) -> None:
        pid = self.pid
        if pid is None or not psutil.pid_exists(pid):
            pid = None
            for process in psutil.process_iter(["pid", "name"]):
                try:
                    if (process.info["name"] or "").casefold() == "wow.exe":
                        pid = process.pid
                        break
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    continue
        if pid != self.pid:
            self.pid = pid
            self.shared.clear(1 if self._capture_thread is not None else -1)
            self.location_reset.emit()
            self.pid_changed.emit(pid)
        if pid is None:
            self.directory_label.setText("未运行")
        else:
            try:
                executable = psutil.Process(pid).exe()
                if not executable:
                    raise OSError("可执行文件路径为空")
                self.directory_label.setText(str(Path(executable).parent))
            except (psutil.Error, OSError) as error:
                self.directory_label.setText(f"路径读取失败：{type(error).__name__}: {error}")
        self.copy_button.setEnabled(pid is not None and not self._closing)

    @Slot()
    def _refresh_snapshot(self) -> None:
        snapshot = self.shared.read()
        self.capture_result = snapshot.capture_result
        self.capture_err = snapshot.capture_err
        self.capture_code = snapshot.capture_code
        self.capture_ts = snapshot.capture_ts
        self._refresh_controls()

    def _refresh_controls(self) -> None:
        self.capture_button.setText("启动截图" if self._capture_thread is None else "停止截图")
        self.capture_button.setEnabled(not self._closing and self._capture_state not in ("启动中", "停止中"))
        self.action_button.setText("启动循环" if self._action_thread is None else "停止循环")
        self.action_button.setEnabled(
            not self._closing and not self._stop_capture_pending
            and self._capture_state == "运行中" and self._action_state not in ("启动中", "停止中")
        )
        detail = self.capture_err
        if self._capture_state == "运行中" and not detail:
            detail = "采集正常" if self.capture_code == 0 else "等待定位"
        self.capture_label.setText(self._capture_state + (f" · {detail}" if detail else ""))
        self.action_label.setText(self._action_state)

    @Slot()
    def _toggle_capture(self) -> None:
        if self._capture_thread is None:
            self.start_capture()
        else:
            self.stop_capture()

    @Slot()
    def _toggle_action(self) -> None:
        if self._action_thread is None:
            self.start_action()
        else:
            self.stop_action()

    def start_capture(self) -> None:
        if self._capture_thread is not None or self._closing:
            return
        self.shared.clear(1)
        thread = QThread(self)
        worker = CaptureWorker(self.shared, self.capture_fps)
        worker.moveToThread(thread)
        thread.started.connect(worker.start)
        worker.log.connect(self.log)
        worker.started.connect(self._capture_started)
        worker.stopped.connect(thread.quit)
        thread.finished.connect(worker.deleteLater)
        thread.finished.connect(self._capture_finished)
        self.capture_stop.connect(worker.stop)
        self.location_reset.connect(worker.reset_location)
        self.capture_fps_changed.connect(worker.set_fps)
        self._capture_worker, self._capture_thread = worker, thread
        self._capture_state = "启动中"
        self._refresh_controls()
        thread.start()

    @Slot()
    def _capture_started(self) -> None:
        if self._capture_state == "启动中":
            self._capture_state = "运行中"
        self._refresh_controls()

    def start_action(self) -> None:
        if self._action_thread is not None or self._capture_state != "运行中" or self._closing:
            return
        thread = QThread(self)
        worker = ActionWorker(self.shared, self.pid, self.action_fps)
        worker.moveToThread(thread)
        thread.started.connect(worker.start)
        worker.log.connect(self.log)
        worker.started.connect(self._action_started)
        worker.stopped.connect(thread.quit)
        thread.finished.connect(worker.deleteLater)
        thread.finished.connect(self._action_finished)
        self.action_stop.connect(worker.stop)
        self.pid_changed.connect(worker.set_pid)
        self.action_fps_changed.connect(worker.set_fps)
        self._action_worker, self._action_thread = worker, thread
        self._action_state = "启动中"
        self._refresh_controls()
        thread.start()

    @Slot()
    def _action_started(self) -> None:
        if self._action_state == "启动中":
            self._action_state = "运行中"
        self._refresh_controls()

    def stop_action(self) -> None:
        if self._action_worker is None or self._action_state == "停止中":
            return
        self._action_state = "停止中"
        self._action_worker.stop_requested.set()
        self.action_stop.emit()
        self._refresh_controls()

    def stop_capture(self) -> None:
        if self._capture_thread is None:
            self.stop_action()
            return
        self._stop_capture_pending = True
        self._capture_state = "停止中"
        if self._action_thread is not None:
            self.stop_action()
        else:
            self._request_capture_stop()
        self._refresh_controls()

    def _request_capture_stop(self) -> None:
        if self._capture_worker is not None:
            self._capture_worker.stop_requested.set()
            self.capture_stop.emit()

    @Slot()
    def _action_finished(self) -> None:
        thread = self._action_thread
        self._action_worker = None
        self._action_thread = None
        self._action_state = "已停止"
        if thread is not None:
            thread.deleteLater()
        if self._stop_capture_pending:
            self._request_capture_stop()
        self._refresh_controls()
        self._finish_close()

    @Slot()
    def _capture_finished(self) -> None:
        thread = self._capture_thread
        self._capture_worker = None
        self._capture_thread = None
        self._capture_state = "已停止"
        self._stop_capture_pending = False
        if thread is not None:
            thread.deleteLater()
        self._refresh_snapshot()
        self._finish_close()

    def _finish_close(self) -> None:
        if self._closing and self._capture_thread is None and self._action_thread is None:
            self.close()

    def closeEvent(self, event: QCloseEvent) -> None:
        if self._capture_thread is None and self._action_thread is None:
            event.accept()
            return
        event.ignore()
        self._closing = True
        self.copy_button.setEnabled(False)
        self.stop_capture()
