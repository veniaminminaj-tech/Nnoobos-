#!/usr/bin/env python3
"""Copy NedohackOS artwork into a clean KolibriOS checkout for source-patch packaging.

This stages original assets without overwriting upstream files or changing desktop code.
The native desktop still needs a format/configuration-specific integration step.
"""
from __future__ import annotations

import shutil
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("Usage: integrate_assets.py <repository root> <KolibriOS source directory>")

    repo = Path(sys.argv[1]).resolve()
    upstream = Path(sys.argv[2]).resolve()
    source_icons = repo / "nedohackos/assets/icons8"
    source_wallpaper = repo / "nedohackos/assets/background/nedohackos-wallpaper.jpg"
    destination = upstream / "data/common/nedohackos"

    if not source_wallpaper.is_file():
        raise SystemExit(f"Wallpaper asset missing: {source_wallpaper}")
    if not source_icons.is_dir():
        raise SystemExit(f"Icon assets missing: {source_icons}")
    if not (upstream / "data/common").is_dir():
        raise SystemExit(f"Not a KolibriOS source checkout: {upstream}")

    # Use a dedicated new directory; refuse to overwrite anything already upstream.
    if destination.exists():
        raise SystemExit(f"Refusing to overwrite existing asset destination: {destination}")
    destination.mkdir(parents=True)
    shutil.copy2(source_wallpaper, destination / "nedohackos-wallpaper.jpg")
    shutil.copytree(source_icons, destination / "icons8")

    (destination / "README.txt").write_text(
        "NedohackOS artwork staged by the repository overlay.\n"
        "Wallpaper: nedohackos-wallpaper.jpg\n"
        "Original pixel-style SVG icons: icons8/\n"
        "These assets are included in the source patch but are not yet wired into the "
        "KolibriOS desktop configuration. Native desktop integration requires confirming "
        "the supported wallpaper and icon formats.\n",
        encoding="utf-8",
    )
    print(f"Staged NedohackOS wallpaper and icons in {destination}")


if __name__ == "__main__":
    main()
