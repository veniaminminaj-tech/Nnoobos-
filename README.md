# KolibriX

KolibriX is a custom x86 distribution based on KolibriOS, developed as independently maintained system modules and a reproducible bootable ISO.

## Project status

**Stage 1 — bootable prototype.** The first image uses the official prebuilt KolibriOS floppy image as its booted system, adds the KolibriX native test application, and wraps it in a BIOS-bootable ISO. It is a prototype, not a full desktop replacement yet.

## Build

Open **Actions → Build KolibriX ISO → Run workflow** or push a change to this branch. When the workflow succeeds, download the **KolibriX-ISO** artifact. It contains:
- `KolibriX.iso` — bootable BIOS ISO
- `kolibrix.img` — KolibriOS disk image with the KolibriX test app
- `KXHELLO.KEX` — native Kolibrios application
- `iso-boot-report.txt` — El Torito boot report

## Architecture
- `kolibrix/modules/` — independent system modules and native applications.
- `kolibrix/config/` — distribution metadata and module manifest.
- `kolibrix/docs/` — design and compatibility notes.
- `.github/workflows/kolibrix-build.yml` — reproducible ISO build.

## Executable compatibility

KolibriOS native applications use the MENUET01/KolibriOS executable format and system calls. A Windows `.exe` is a different format. This prototype does **not** claim to run arbitrary Windows PE executables. Windows EXE support is a separate compatibility-layer project and will be developed only after the native system is stable.

## Upstream and licensing

KolibriX is a derivative distribution built on the official [KolibriOS source project](https://github.com/KolibriOS/kolibrios). Preserve upstream copyright notices and GPL-2.0 license terms when modifying or redistributing upstream components. KolibriX-specific files are identified separately in their headers or documentation.

## Testing

Use a disposable VirtualBox/QEMU virtual machine. The workflow validates the ISO structure and performs a BIOS boot smoke test; it does not prove that every device or application works on physical hardware.
