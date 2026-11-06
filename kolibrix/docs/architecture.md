# KolibriX architecture

## Product goal

KolibriX is an x86 distribution based on KolibriOS. Its target desktop appearance is classic Windows 98: teal desktop, grey taskbar, Start menu, classic title bars, desktop shortcuts, and a simple file manager. Target ISO size: at most 5 GiB.

## Current bootable foundation

The first ISO workflow downloads the official KolibriOS x86 floppy image, builds the native MENUET01 test program KXHELLO.KEX with FASM, copies the program and release information into the image, then wraps it in a BIOS-bootable GRUB/MEMDISK ISO.

This is only the bootable foundation. It does not yet replace the stock KolibriOS desktop with the Windows 98-style KolibriX shell. The browser prototype is a UI mockup, not native OS code.

## Base and compatibility

- Keep the official KolibriOS kernel and native system as the base.
- Keep KolibriX changes in this repository as a reproducible overlay.
- Native KolibriOS applications and Windows PE .exe files are different executable formats. Do not claim arbitrary Windows application support.
- Treat Windows PE compatibility as a separate future research project.

## Native desktop shell

Implement the Windows 98-style shell using KolibriOS native APIs:
- desktop background, selectable and movable shortcuts;
- taskbar and Start menu;
- movable windows and classic controls;
- context menu with New Folder, Rename, and Delete;
- persistent desktop layout and actual folders on user storage;
- file manager with create, copy, move, rename, and delete operations;
- settings, terminal, and text editor.

Desktop folders must be real filesystem directories and persist across restarts. The current HTML prototype's in-memory folders do not meet this requirement.

## Python environment

Python is a separate engineering milestone:
- identify a Python interpreter version that can be built for KolibriOS/x86;
- port/adapt the runtime and required system calls;
- provide an editor and .py launcher;
- document unsupported standard-library modules;
- do not bundle Windows Python or claim Python support until native execution is tested.

## Build and release policy

- Build the base image from the official KolibriOS distribution image and record its SHA-256 in each CI artifact.
- Produce a BIOS-bootable ISO and keep the ISO below 5 GiB.
- Run an ISO structure check and a QEMU boot smoke test.
- A successful boot smoke test verifies the boot path only; it does not prove that the planned KolibriX desktop or all hardware support is complete.
- Keep the Windows 98 desktop, persistent file manager, and Python runtime as explicit milestones rather than release claims.

## Milestones

1. Bootable foundation ISO with a native FASM test application.
2. Native Windows 98-style KolibriX desktop shell.
3. Persistent desktop folders and file manager.
4. Native Python runtime, editor, and .py launcher.
5. Separate research into Windows PE compatibility.

## Licensing

Preserve upstream KolibriOS copyright notices and GPL-2.0 terms for redistributed or modified upstream components. Keep KolibriX-specific code and documentation clearly identified.
