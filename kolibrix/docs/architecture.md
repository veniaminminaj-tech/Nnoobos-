# KolibriX architecture

## Product definition

KolibriX is one operating-system distribution: KolibriOS x86 is the low-level kernel and hardware/API foundation; KolibriX supplies the identity, boot configuration, desktop shell, system utilities, defaults, and later its own userland applications. The result must be presented as KolibriX, not as a separate KolibriOS session with a theme layered on top.

Target desktop: classic Windows 98 visual language (teal desktop, grey taskbar, Start menu, classic windows and shortcuts). Target ISO size: at most 5 GiB.

## Boot design

- The ISO has exactly one visible GRUB menu entry, named **KolibriX**.
- Selecting it boots the KolibriOS x86 core and starts the KolibriX system startup configuration.
- No second GRUB entry for upstream KolibriOS or a release-information screen.
- Release information belongs in documentation inside the ISO, not as another boot choice.
- The early BIOS image currently packages the upstream KolibriOS floppy image using GRUB/MEMDISK. This is a bootstrapping mechanism, not the final integrated disk layout.
- The next boot milestone is to make the KolibriX startup path and filesystem layout reproducible, then reduce reliance on a wrapped upstream floppy image where technically feasible.

## System ownership

KolibriX must own:
- product name and boot presentation;
- startup configuration and default services;
- graphical desktop, taskbar, Start menu, shortcuts, and window behavior;
- system settings and default applications;
- filesystem layout and persistent user data conventions;
- release packaging, versioning, and documentation.

KolibriOS supplies the current x86 kernel, drivers, system-call ABI, and compatible native application environment. Upstream notices and GPL-2.0 obligations must be preserved. This is an integrated distribution built on KolibriOS technology; do not claim that the kernel was independently rewritten.

## Native desktop

Implement the Windows 98-style desktop with native KolibriOS APIs:
- desktop background and selectable/movable shortcuts;
- taskbar and Start menu;
- movable windows and classic controls;
- context menu with New Folder, Rename, and Delete;
- persistent desktop layout and real directories on user storage;
- file manager with create, copy, move, rename, and delete;
- settings, terminal, and text editor.

The desktop must be the normal graphical environment after boot. A shell process that merely draws a static background is not enough: click zones, window lifecycle, app launching, and persistent file operations must be tested.

## Applications and compatibility

- KolibriOS native applications can be reused where compatible, while KolibriX-specific apps should be branded and maintained in this repository.
- Native KolibriOS executables and Windows PE `.exe` files are different formats. Do not claim arbitrary Windows application support.
- Windows PE compatibility is a separate research project.

## Python environment

Python is a separate engineering milestone:
- identify a Python interpreter version that can be built for KolibriOS/x86;
- port/adapt the runtime and required system calls;
- provide an editor and `.py` launcher;
- document unsupported standard-library modules;
- do not bundle Windows Python or claim Python support until native execution is tested.

## Build and verification policy

- Build from a pinned, recorded official KolibriOS source/image revision; record SHA-256 values in CI artifacts.
- Produce a BIOS-bootable ISO with exactly one KolibriX GRUB entry.
- Check the ISO structure and run a QEMU boot smoke test.
- A headless QEMU timeout only proves that the emulator did not exit early; it does not prove that the desktop appeared or that mouse clicks work.
- Require visual boot evidence and interaction tests before calling the graphical desktop verified.
- Keep persistent file operations, Python, and Windows PE compatibility as explicit milestones rather than release claims.

## Milestones

1. Reproducible KolibriOS-core boot foundation with one KolibriX GRUB entry.
2. Native KolibriX desktop that starts automatically and handles real input.
3. Persistent desktop folders, file manager, and user settings.
4. KolibriX-branded system utilities and applications.
5. Native Python runtime, editor, and `.py` launcher.
6. Separate research into Windows PE compatibility.

## Licensing

Preserve upstream KolibriOS copyright notices and GPL-2.0 terms for redistributed or modified upstream components. Clearly identify KolibriX-specific code and documentation.
