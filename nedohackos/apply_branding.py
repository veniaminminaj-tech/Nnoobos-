#!/usr/bin/env python3
"""Apply the initial NedohackOS branding overlay to a KolibriOS source checkout.

Usage: python3 nedohackos/apply_branding.py /path/to/kolibrios
Only targeted text files are changed. Upstream copyright and license notices are kept.
"""
from __future__ import annotations

import sys
from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    data = path.read_text(encoding="utf-8")
    count = data.count(old)
    if count != 1:
        raise SystemExit(f"Expected exactly one match in {path}, found {count}; upstream changed?")
    path.write_text(data.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: apply_branding.py <KolibriOS source directory>")
    root = Path(sys.argv[1]).resolve()
    kernel_strings = root / "kernel/trunk/boot/bootstr-en_US.inc"
    settings = root / "data/common/settings/app.ini"
    readme = root / "README.md"
    for path in (kernel_strings, settings, readme):
        if not path.is_file():
            raise SystemExit(f"Not a KolibriOS source checkout or required file missing: {path}")

    # Keep the original boot-screen line width and its surrounding assembly syntax.
    text = kernel_strings.read_text(encoding="utf-8")
    old = "KolibriOS comes with ABSOLUTELY NO WARRANTY. See file COPYING for details"
    if text.count(old) != 1:
        raise SystemExit("Could not uniquely locate the English boot-screen warranty line; upstream changed?")
    new = "NedohackOS based on KolibriOS; NO WARRANTY. See COPYING"
    if len(new) > len(old):
        raise SystemExit("Internal error: replacement would overflow the original boot-screen line")
    kernel_strings.write_text(text.replace(old, new + " " * (len(old) - len(new)), 1), encoding="utf-8")

    replace_once(
        settings,
        "path=/usbhd0/1/kolibri.img",
        "path=/usbhd0/1/nedohackos.img",
    )

    readme_text = readme.read_text(encoding="utf-8")
    if not readme_text.startswith("# KolibriOS\n"):
        raise SystemExit("Unexpected upstream README header; refusing to rewrite it blindly")
    intro = (
        "# NedohackOS (based on KolibriOS)\n\n"
        "NedohackOS is a community derivative based on the KolibriOS source tree. "
        "This branch applies an initial branding overlay while retaining the upstream "
        "license and copyright notices. Original project: https://github.com/KolibriOS/kolibrios.\n"
    )
    readme.write_text(intro + readme_text[len("# KolibriOS\n\n"):], encoding="utf-8")
    print("Applied NedohackOS branding overlay to boot text, ramdisk-save default, and README.")


if __name__ == "__main__":
    main()
