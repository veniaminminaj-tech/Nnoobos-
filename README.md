# NedohackOS

NedohackOS is a customization project intended to use MenuetOS as its operating-system base. This branch keeps the NedohackOS visual assets and removes the experimental Nnoobos kernel, its bootloader, and the KolibriOS fallback.

## Included assets

- `background/image_760c3e80.jpg` — wallpaper supplied for NedohackOS
- `nedohackos/assets/background/nedohackos-wallpaper.jpg` — copy of the wallpaper
- `nedohackos/assets/icons8/` — eight 256×256 SVG desktop icon concepts
- `apps/makertools/` — source templates and file-association defaults
- `docs/MAKETOOLS.md` and `docs/PYTHON_AND_ARCHIVES.md` — retained tooling notes

## Important status

This branch does **not** contain a bootable operating-system image yet. It does not bundle MenuetOS, because the MenuetOS 64-bit distribution has its own license and must be obtained and used according to its terms. No Nnoobos kernel, Nnoobos bootloader, or KolibriOS image is built or included here.

The included wallpaper and SVG icons are staged assets; they are not yet automatically installed into the MenuetOS desktop. The next integration step is to confirm the supported MenuetOS configuration and desktop icon formats, then test the customization using a MenuetOS image that you are authorized to use.

## Assets package

The GitHub Actions workflow creates a ZIP containing only the NedohackOS wallpaper, icon assets, and relevant tooling notes. It does not claim to build an ISO.
