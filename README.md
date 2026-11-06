# KolibriX

KolibriX is an x86 distribution based on KolibriOS. The planned native desktop uses a classic **Windows 98** look: teal desktop, grey taskbar, Start menu, classic windows, and desktop shortcuts.

## Current status

The `kolibrix-dev` branch now contains a GitHub Actions workflow for a **bootable foundation ISO**:

- Downloads the official KolibriOS x86 floppy image.
- Builds the native MENUET01 test app `KXHELLO.KEX` with FASM.
- Adds the app and KolibriX release information to the disk image.
- Creates a BIOS-bootable ISO using GRUB and MEMDISK.
- Checks ISO structure and runs a QEMU boot smoke test.
- Enforces the 5 GiB ISO size limit.

The first ISO is a bootable KolibriOS base with a KolibriX test application. It does **not yet contain the native Windows 98-style desktop shell**. The HTML prototype is only a browser mockup; its windows and folders are not native OS features.

## Build

Open the **Actions** tab and run **Build KolibriX bootable ISO**, or push a change to the `kolibrix-dev` branch. The workflow uploads the ISO as a build artifact. Pushing a tag matching `kolibrix-v*` also publishes a prerelease.

## Planned milestones

1. Bootable foundation ISO.
2. Native Windows 98-style desktop shell.
3. Persistent desktop folders and file manager.
4. Native Python runtime, editor, and `.py` launcher.
5. Separate research into Windows PE compatibility.

## Compatibility

KolibriOS native applications and Windows PE `.exe` files use different executable formats. Native app support does not imply Windows compatibility.

## Upstream and licensing

- Upstream: [KolibriOS/kolibrios](https://github.com/KolibriOS/kolibrios)
- Preserve upstream copyright notices and GPL-2.0 license terms when redistributing or modifying upstream components.
