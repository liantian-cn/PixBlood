"""Immutable RGB pixel objects for the Lua addon's physical-pixel protocol."""

from functools import cached_property

import numpy as np
import numpy.typing as npt
import xxhash

type RGBImage = npt.NDArray[np.uint8]


def _snapshot(pixels: RGBImage) -> RGBImage:
    if not isinstance(pixels, np.ndarray) or pixels.dtype != np.uint8:
        raise ValueError("像素必须是 uint8 数组")
    if pixels.ndim != 3 or pixels.shape[2] != 3:
        raise ValueError("像素必须是 RGB 三通道数组")
    return np.frombuffer(pixels.tobytes(), dtype=np.uint8).reshape(pixels.shape)


class _Region:
    def __init__(self, pixels: RGBImage, pos: tuple[int, int]) -> None:
        self._pix_array = _snapshot(pixels)
        self._pos = pos

    @property
    def pix_array(self) -> RGBImage:
        return self._pix_array

    @property
    def pos(self) -> tuple[int, int]:
        return self._pos

    @property
    def region(self) -> tuple[int, int, int, int]:
        left, top = self.pos
        height, width = self.pix_array.shape[:2]
        return left, top, left + width, top + height

    @property
    def pos_string(self) -> str:
        return ",".join(map(str, self.pos))

    @property
    def region_string(self) -> str:
        return ",".join(map(str, self.region))


class Cell(_Region):
    def __init__(self, pixels: RGBImage, pos: tuple[int, int]) -> None:
        super().__init__(pixels, pos)
        if self.pix_array.shape != (4, 4, 3):
            raise ValueError("Cell 尺寸必须为 4×4")

    @property
    def inner(self) -> RGBImage:
        return self.pix_array[1:3, 1:3]

    @property
    def mean(self) -> float:
        return float(np.mean(self.inner))

    @property
    def ratio(self) -> float:
        return self.mean / 255.0

    @property
    def percent(self) -> float:
        return self.ratio * 100.0

    @property
    def is_pure(self) -> bool:
        return bool(np.all(self.inner == self.inner[0, 0]))

    @property
    def is_not_pure(self) -> bool:
        return not self.is_pure

    @property
    def color_string(self) -> str:
        return ",".join(str(int(value)) for value in self.inner[0, 0])

    @property
    def is_black(self) -> bool:
        return bool(np.all(self.inner == 0))

    @property
    def is_white(self) -> bool:
        return bool(np.all(self.inner == 255))


class ValueBar(_Region):
    def __init__(self, pixels: RGBImage, pos: tuple[int, int]) -> None:
        super().__init__(pixels, pos)
        height, width = self.pix_array.shape[:2]
        if height != 4 or width < 8 or width % 4:
            raise ValueError("ValueBar 必须高 4px，至少宽 8px，宽度为 4 的倍数")

    @property
    def inner(self) -> RGBImage:
        return self.pix_array[1:3, :]

    @property
    def ratio(self) -> float:
        white = int(np.count_nonzero(np.all(self.inner == 255, axis=2)))
        black = int(np.count_nonzero(np.all(self.inner == 0, axis=2)))
        return white / (white + black) if white + black else 0.0

    @property
    def percent(self) -> float:
        return self.ratio * 100.0


class IconTile(_Region):
    def __init__(self, pixels: RGBImage, pos: tuple[int, int]) -> None:
        super().__init__(pixels, pos)
        if self.pix_array.shape != (8, 8, 3):
            raise ValueError("IconTile 尺寸必须为 8×8")

    @property
    def inner(self) -> RGBImage:
        return self.pix_array[1:7, 1:7]

    @property
    def is_black(self) -> bool:
        return bool(np.all(self.inner == 0))

    @property
    def is_pure(self) -> bool:
        return bool(np.all(self.inner == self.inner[0, 0]))

    @property
    def is_not_pure(self) -> bool:
        return not self.is_pure

    @cached_property
    def hash(self) -> str | None:
        if self.is_black:
            return None
        return xxhash.xxh3_64_hexdigest(np.ascontiguousarray(self.inner).tobytes(), seed=0)


class Matrix:
    def __init__(self, capture_result: RGBImage) -> None:
        self._pix_array = _snapshot(capture_result)
        height, width = self.pix_array.shape[:2]
        if height != 12 or width < 8 or width % 4:
            raise ValueError("基板必须高 12px，至少宽 8px，宽度为 4 的倍数")
        for x, y, expected in (
            (0, 1, "0,255,255"),
            (0, 2, "255,0,255"),
            (-1, 1, "255,255,0"),
        ):
            cell = self.getCell(x, y)
            if not cell.is_pure or cell.color_string != expected:
                raise ValueError(f"检测格 ({x},{y}) 必须为 {expected}")
        flicker = self.getCell(-1, 0)
        if not (flicker.is_black or flicker.is_white):
            raise ValueError("末列第一行检测格必须为全黑或全白")

    @property
    def pix_array(self) -> RGBImage:
        return self._pix_array

    def _region(self, left: int, top: int, width: int, height: int) -> RGBImage:
        if left < 0 or top < 0 or left + width > self.pix_array.shape[1] or top + height > 12:
            raise ValueError(f"像素区域越界：{left},{top},{left + width},{top + height}")
        return self.pix_array[top:top + height, left:left + width]

    def getCell(self, x: int, y: int = 0) -> Cell:
        if not isinstance(x, int) or not isinstance(y, int):
            raise ValueError("Cell 坐标必须为整数")
        if x < 0:
            x += self.pix_array.shape[1] // 4
        return Cell(self._region(4 * x, 4 * y, 4, 4), (4 * x, 4 * y))

    def getValueBar(self, x: int, width: int) -> ValueBar:
        if not isinstance(x, int) or not isinstance(width, int) or width < 1:
            raise ValueError("ValueBar 坐标和内容宽度必须为整数，内容宽度至少为 1")
        if x < 1 or 4 * (x + width + 1) > self.pix_array.shape[1] - 4:
            raise ValueError("ValueBar 必须位于两侧检测列之间")
        return ValueBar(self._region(4 * x, 0, 4 * (width + 1), 4), (4 * x, 0))

    def getIconTile(self, x: int) -> IconTile:
        if not isinstance(x, int) or x < 1:
            raise ValueError("IconTile 槽位必须为从 1 开始的整数")
        left = 4 + 8 * (x - 1)
        if left + 8 > self.pix_array.shape[1] - 4:
            raise ValueError("IconTile 必须位于两侧检测列之间")
        return IconTile(self._region(left, 4, 8, 8), (left, 4))
