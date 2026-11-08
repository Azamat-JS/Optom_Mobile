#!/usr/bin/env python3
"""Generates the home-screen app icon for iOS and Android from the bsmart logo.

Source: assets/images/bsmart_mark.png (the BSM mark, transparent, made for dark
backgrounds). The icon is that mark centred on the brand near-black #0B0D12.

Run from the project root (needs Pillow: `pip3 install pillow`):

    python3 tool/generate_app_icons.py

Writes:
  assets/icon/app_icon*.png                      1024 px masters (for the stores)
  ios/Runner/Assets.xcassets/AppIcon.appiconset  every slot in its Contents.json
  android/app/src/main/res/mipmap-*/             legacy + adaptive layers
  android/app/src/main/res/mipmap-anydpi-v26/    adaptive icon XML

(flutter_launcher_icons was tried first, but 0.14.4 fails to compile against
the `archive` version this project resolves, so this script does the same job.)
"""

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MARK = ROOT / "assets/images/bsmart_mark.png"
MASTERS = ROOT / "assets/icon"
IOS_SET = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
RES = ROOT / "android/app/src/main/res"

INK = (0x0B, 0x0D, 0x12, 255)
S = 1024

# Width of the mark relative to the canvas.
FULL_BLEED_WIDTH = 0.80  # iOS + legacy Android: plain square, the OS rounds it
ADAPTIVE_WIDTH = 0.59  # Android adaptive: the 3:1 mark must fit the 66dp safe circle

ANDROID_DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def load_mark() -> Image.Image:
    mark = Image.open(MARK).convert("RGBA")
    alpha = mark.getchannel("A").point(lambda a: 255 if a > 8 else 0)
    return mark.crop(alpha.getbbox())


def place(mark: Image.Image, width_frac: float, bg) -> Image.Image:
    canvas = Image.new("RGBA", (S, S), bg)
    w = round(S * width_frac)
    h = round(mark.height * w / mark.width)
    resized = mark.resize((w, h), Image.LANCZOS)
    # The bag handle makes the mark top-heavy; nudge it down a little.
    canvas.alpha_composite(resized, ((S - w) // 2, (S - h) // 2 + round(h * 0.03)))
    return canvas


def scaled(img: Image.Image, px: int) -> Image.Image:
    return img.resize((px, px), Image.LANCZOS)


def main() -> None:
    mark = load_mark()
    full = place(mark, FULL_BLEED_WIDTH, INK).convert("RGB")  # no alpha: App Store rejects it
    fg = place(mark, ADAPTIVE_WIDTH, (0, 0, 0, 0))
    mono = Image.new("RGBA", (S, S), (255, 255, 255, 0))
    mono.putalpha(fg.getchannel("A"))  # Android 13+ themed icon: silhouette only

    MASTERS.mkdir(parents=True, exist_ok=True)
    full.save(MASTERS / "app_icon.png")
    fg.save(MASTERS / "app_icon_foreground.png")
    mono.save(MASTERS / "app_icon_monochrome.png")

    # iOS: every slot listed in the asset catalog.
    contents = json.loads((IOS_SET / "Contents.json").read_text())
    for entry in contents["images"]:
        points = float(entry["size"].split("x")[0])
        px = round(points * int(entry["scale"].rstrip("x")))
        scaled(full, px).save(IOS_SET / entry["filename"])

    # Android: legacy square (API < 26) + adaptive layers (108dp canvas).
    for density, factor in ANDROID_DENSITIES.items():
        folder = RES / f"mipmap-{density}"
        folder.mkdir(exist_ok=True)
        scaled(full, round(48 * factor)).save(folder / "ic_launcher.png")
        scaled(fg, round(108 * factor)).save(folder / "ic_launcher_foreground.png")
        scaled(mono, round(108 * factor)).save(folder / "ic_launcher_monochrome.png")

    anydpi = RES / "mipmap-anydpi-v26"
    anydpi.mkdir(exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
        "</adaptive-icon>\n"
    )
    print("App icons written.")


if __name__ == "__main__":
    main()
