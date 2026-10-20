# NedohackOS

NedohackOS is a customization project intended to use MenuetOS as its operating-system base. This branch keeps the NedohackOS visual assets and removes the experimental Nnoobos kernel, its bootloader, and the KolibriOS fallback.

## Included assets

- `background/image_760c3e80.jpg` — wallpaper supplied for NedohackOS
- `nedohackos/assets/background/nedohackos-wallpaper.jpg` — copy of the wallpaper
- `nedohackos/assets/icons8/` — eight 256×256 SVG desktop icon concepts
- `menuetos/BGR.JPG` and `menuetos/config.mnt.overlay.txt` — wallpaper integration overlay
- `apps/makertools/` — source templates and file-association defaults
- `docs/MAKETOOLS.md` and `docs/PYTHON_AND_ARCHIVES.md` — retained tooling notes

## Current build status

- **Assets package:** built successfully by GitHub Actions.
- **Bootable ISO:** not built by this workflow.
- **Desktop icons:** SVG concepts and BMP previews are packaged, but automatic replacement in MenuetOS has not been verified.
- **Release:** no ready-to-boot NedohackOS release is published yet.

Get the latest asset package from the [GitHub Actions workflow run](https://github.com/veniaminminaj-tech/Nnoobos-/actions/runs/39475173160). Open the run's **Artifacts** section and download `nedohackos-assets`.

## Important limitations

This branch does **not** contain a bootable operating-system image yet. It does not bundle MenuetOS, because the MenuetOS 64-bit distribution has its own license and must be obtained and used according to its terms. No Nnoobos kernel, Nnoobos bootloader, or KolibriOS image is built or included here.

The included wallpaper and SVG icons are staged assets; they are not yet automatically installed into the MenuetOS desktop. See [`menuetos/README.md`](menuetos/README.md) for the manual wallpaper overlay instructions. The next integration step is to map the icons through MenuetOS's native icon configuration and test the result using a MenuetOS image that you are authorized to use.

## Assets package

The GitHub Actions workflow creates a ZIP containing the NedohackOS wallpaper, icon assets, BMP icon previews, and relevant tooling notes. It does not claim to build an ISO.
