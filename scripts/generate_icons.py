#!/usr/bin/env python3

from pathlib import Path

from PIL import Image


ROOT_DIR = Path(__file__).resolve().parent.parent
APP_ICON_PATH = ROOT_DIR / "Assets" / "AppIcon.png"
APP_ICON_PREVIEW_PATH = ROOT_DIR / "Resources" / "AppIcon-preview.png"
APP_ICON_ICNS_PATH = ROOT_DIR / "Resources" / "AppIcon.icns"
MENU_BAR_ICON_PATH = ROOT_DIR / "Resources" / "MenuBarIconTemplate.png"


def main() -> None:
    app_icon = Image.open(APP_ICON_PATH).convert("RGBA")
    app_icon.save(APP_ICON_PREVIEW_PATH)
    app_icon.save(
        APP_ICON_ICNS_PATH,
        format="ICNS",
        sizes=[(16, 16), (32, 32), (64, 64), (128, 128), (256, 256), (512, 512), (1024, 1024)],
    )
    derive_menu_bar_icon(app_icon).save(MENU_BAR_ICON_PATH)


def derive_menu_bar_icon(app_icon: Image.Image) -> Image.Image:
    size = app_icon.width
    hand_region = app_icon.crop(
        (
            int(size * 0.24),
            int(size * 0.18),
            int(size * 0.76),
            int(size * 0.86),
        )
    )

    pixels = hand_region.load()
    for y in range(hand_region.height):
        for x in range(hand_region.width):
            r, g, b, a = pixels[x, y]
            if a == 0:
                pixels[x, y] = (0, 0, 0, 0)
                continue

            blue_strength = b - max(r, g)
            if b > 135 and blue_strength > 25:
                alpha = max(0, min(255, int(blue_strength * 3.2)))
                pixels[x, y] = (0, 0, 0, alpha)
            else:
                pixels[x, y] = (0, 0, 0, 0)

    content_box = hand_region.getbbox()
    if content_box is None:
        raise RuntimeError("Failed to derive menu bar icon from Assets/AppIcon.png")

    hand_region = hand_region.crop(content_box)

    canvas = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    scale = min(40 / hand_region.width, 40 / hand_region.height)
    scaled_size = (
        max(1, round(hand_region.width * scale)),
        max(1, round(hand_region.height * scale)),
    )
    hand_region = hand_region.resize(scaled_size, Image.Resampling.LANCZOS)
    offset = ((64 - hand_region.width) // 2, (64 - hand_region.height) // 2)
    canvas.alpha_composite(hand_region, offset)
    return canvas


if __name__ == "__main__":
    main()
