#!/usr/bin/env python3

from pathlib import Path

from PIL import Image


ROOT_DIR = Path(__file__).resolve().parent.parent
APP_ICON_PATH = ROOT_DIR / "Assets" / "AppIcon.png"
APP_ICON_PREVIEW_PATH = ROOT_DIR / "Resources" / "AppIcon-preview.png"
APP_ICON_ICNS_PATH = ROOT_DIR / "Resources" / "AppIcon.icns"


def main() -> None:
    app_icon = Image.open(APP_ICON_PATH).convert("RGBA")
    app_icon.save(APP_ICON_PREVIEW_PATH)
    app_icon.save(
        APP_ICON_ICNS_PATH,
        format="ICNS",
        sizes=[(16, 16), (32, 32), (64, 64), (128, 128), (256, 256), (512, 512), (1024, 1024)],
    )


if __name__ == "__main__":
    main()
