"""One-shot capture diagnostic: python -m pix.test_captura (never sends keys)."""

from pix.capture import GDIBackend, locate_region


def main() -> int:
    backend: GDIBackend | None = None
    result = 0
    try:
        backend = GDIBackend()
        desktop = backend.desktop_bounds()
        bounds = locate_region(backend.capture(desktop), (desktop.left, desktop.top))
        print(f"定位成功：({bounds.left}, {bounds.top}, {bounds.right}, {bounds.bottom})")
        print(f"宽度：{bounds.width}px，高度：{bounds.height}px（物理坐标）")
    except Exception as error:
        print(f"定位失败：{error}")
        result = 1
    finally:
        if backend is not None:
            try:
                backend.close()
            except Exception as error:
                print(f"资源清理失败：{error}")
                result = 1
    return result


if __name__ == "__main__":
    raise SystemExit(main())
