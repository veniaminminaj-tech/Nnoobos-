# NedohackOS — MenuetOS customization overlay

This branch keeps MenuetOS as the intended OS base. The original MenuetOS kernel and applications are not rewritten or bundled here. The experimental Nnoobos kernel, its bootloader, and the KolibriOS fallback have been removed from this branch.

## Wallpaper

MenuetOS 64 supports selecting a boot wallpaper with the `background` setting in `config.mnt`. The official configuration documents BMP, PNG, JPG, and GIF images and supports a path relative to the system directory.

The overlay includes:
- `BGR.JPG` — NedohackOS wallpaper, named for the system-directory wallpaper path
- `config.mnt.overlay.txt` — the exact setting to merge into your existing MenuetOS `config.mnt`

Copy `BGR.JPG` into the MenuetOS system directory and merge the line from `config.mnt.overlay.txt` into the existing configuration. Do not replace the complete original configuration with this two-line overlay.

## Icons

The original eight NedohackOS SVG icons are preserved under `nedohackos/assets/icons8/`. The package also creates BMP previews for compatibility testing. MenuetOS uses its own icon manager/configuration, so the SVG files are not falsely claimed to replace desktop icons automatically yet. The next step is to map these images through the native MenuetOS icon configuration and verify the result in QEMU.

## Build and license

GitHub Actions packages the customization files as `nedohackos-assets.zip`; it does not produce a bootable ISO. Obtain MenuetOS from its official website and follow its license. This repository does not download, modify, or redistribute the proprietary MenuetOS 64-bit kernel image.

Official documentation:
- https://menuetos.net/download.htm
- https://menuetos.net/config.txt
