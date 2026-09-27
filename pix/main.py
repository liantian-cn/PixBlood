"""PixBlood desktop application entry point."""

import sys

from PySide6.QtWidgets import QApplication

from pix.ui import MainWindow


def main() -> int:
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
