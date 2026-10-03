"""PixBlood desktop application entry point."""

import ctypes
import subprocess
import sys
from ctypes import wintypes
from pathlib import Path


MUTEX_NAME = r"Global\PixCore"
ERROR_ALREADY_EXISTS = 183


def main() -> int:
    if sys.platform != "win32":
        print("PixCore 仅支持 Windows。", file=sys.stderr)
        return 1

    shell32 = ctypes.WinDLL("shell32", use_last_error=True)
    shell32.IsUserAnAdmin.argtypes = []
    shell32.IsUserAnAdmin.restype = wintypes.BOOL
    shell32.ShellExecuteW.argtypes = [
        wintypes.HWND, wintypes.LPCWSTR, wintypes.LPCWSTR,
        wintypes.LPCWSTR, wintypes.LPCWSTR, ctypes.c_int,
    ]
    # ShellExecuteW returns an INT_PTR-compatible value, not a usable handle.
    shell32.ShellExecuteW.restype = ctypes.c_ssize_t

    if not shell32.IsUserAnAdmin():
        parameters = subprocess.list2cmdline(["-m", "pix", *sys.argv[1:]])
        result = shell32.ShellExecuteW(
            None, "runas", sys.executable, parameters,
            str(Path(__file__).resolve().parent.parent), 1,
        )
        if result <= 32:
            print(
                f"必须以管理员身份运行：提权已取消或失败（ShellExecuteW 返回 {result}）。",
                file=sys.stderr,
            )
            return 1
        return 0

    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel32.CreateMutexW.argtypes = [ctypes.c_void_p, wintypes.BOOL, wintypes.LPCWSTR]
    kernel32.CreateMutexW.restype = wintypes.HANDLE
    kernel32.CloseHandle.argtypes = [wintypes.HANDLE]
    kernel32.CloseHandle.restype = wintypes.BOOL

    # Keep the named object alive without taking ownership of the mutex.
    mutex = kernel32.CreateMutexW(None, False, MUTEX_NAME)
    error = ctypes.get_last_error()
    if not mutex:
        print(f"无法创建 PixCore 单实例锁：{ctypes.WinError(error)}", file=sys.stderr)
        return 1

    try:
        if error == ERROR_ALREADY_EXISTS:
            user32 = ctypes.WinDLL("user32", use_last_error=True)
            user32.MessageBoxW.argtypes = [
                wintypes.HWND, wintypes.LPCWSTR, wintypes.LPCWSTR, wintypes.UINT,
            ]
            user32.MessageBoxW.restype = ctypes.c_int
            user32.MessageBoxW(
                None, "已有 PixCore 程序正在运行，请先关闭后再启动。", "PixCore", 0x40,
            )
            return 0

        # Give this application its own Windows taskbar identity.
        shell32.SetCurrentProcessExplicitAppUserModelID.argtypes = [wintypes.LPCWSTR]
        shell32.SetCurrentProcessExplicitAppUserModelID.restype = ctypes.c_long
        result = shell32.SetCurrentProcessExplicitAppUserModelID("Pix.PixBlood")
        if result < 0:
            raise OSError(f"Failed to set taskbar application ID: HRESULT {result:#x}")

        from PySide6.QtGui import QIcon
        from PySide6.QtWidgets import QApplication

        from pix.ui import MainWindow

        app = QApplication(sys.argv)
        app.setWindowIcon(QIcon(str(Path(__file__).resolve().parent / "assets" / "app.ico")))
        window = MainWindow()
        window.show()
        return app.exec()
    finally:
        kernel32.CloseHandle(mutex)


if __name__ == "__main__":
    sys.exit(main())
