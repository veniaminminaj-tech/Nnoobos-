# NedohackOS

**NedohackOS** is a KolibriOS-based remix. The goal is to keep the official KolibriOS system as the working OS and combine it with the project's own name, wallpapers, icons, and MakeTools files in one distributable ISO.

## Current build

- GitHub Actions downloads the official KolibriOS floppy image.
- The generated ISO has a single boot entry: **NedohackOS (KolibriOS base)**. It no longer offers a separate experimental x86-64 kernel as a second OS.
- Repository wallpapers from `background/` and icon sources from `data/common/nedohackos/` are packaged in the ISO under `NEDOHACKOS/`.
- Raster icon images are additionally normalized to **512 × 512 pixels** under `NEDOHACKOS/icons/512/`.
- The visual assets target **Full HD (1920 × 1080)**; see [Full HD setup](docs/FULL_HD.md) for enabling and checking that mode in the guest.
- MakeTools files are included in the same ISO.
- GitHub Actions performs a QEMU boot smoke test of the ISO.

## Important desktop integration status

This is the first single-system integration step, not yet a complete desktop reskin. The wallpaper and PNG icon files are bundled inside the ISO, but they are **not yet automatically applied to KolibriOS's live desktop**. KolibriOS uses its own desktop configuration and native icon resources (including `icons.dat` and `iconstrp.gif`); replacing those safely requires building the correct native icon strip and editing the official image's filesystem/configuration. A 512×512 PNG is a source asset, not automatically a usable desktop icon in KolibriOS.

## Build and download

1. Open [GitHub Actions](https://github.com/veniaminminaj-tech/Nnoobos-/actions/workflows/build.yml).
2. Open the latest successful **Build NedohackOS (KolibriOS base) ISO** run.
3. Download the **nedohackos-iso** artifact and extract it.
4. Run `nedohackos.iso` in QEMU or VirtualBox. Use Legacy BIOS mode if the VM asks for firmware settings.

## Project structure

- `background/` — custom wallpaper source images.
- `data/common/nedohackos/` — original icon assets.
- `NEDOHACKOS/wallpaper/` inside the ISO — bundled wallpapers.
- `NEDOHACKOS/icons/original/` — original icon files.
- `NEDOHACKOS/icons/512/` — normalized 512×512 PNG icons.
- `NEDOHACKOS/makertools/` — bundled MakeTools project files.

## License and attribution

KolibriOS is a separate open-source project. This remix should preserve the upstream license and copyright notices included with the official KolibriOS distribution. Keep original attribution for every wallpaper and icon that is not your own.

## Testing note

The QEMU smoke test confirms that the ISO can start in an emulator; it does not prove that every wallpaper or icon is active on the desktop. Test with a disposable virtual machine, not a real disk.
