# Python, archives, and drivers in Nnoobos

## Current reality

Nnoobos currently boots into a 16-bit x86 BIOS real-mode text interface. That is too small and old for a normal CPython installation, WinRAR, modern USB drivers, or Linux device-driver modules. The files in `drivers/` are starter BIOS-backed assembly routines; they are not yet wired into the boot image and must not be described as fully installed drivers.

## Python

A practical path is:

1. Add a small Nnoobos shell command named `python` with a deliberately limited interpreter (for example, integer arithmetic and `print`).
2. Move to a 32-bit protected-mode kernel with a memory manager and filesystem.
3. Port or embed a real Python implementation only after the OS has process, file, console, and memory services.

A command that merely launches host Python would not be Python running inside Nnoobos.

## RAR / WinRAR

WinRAR is a Windows application, not a standalone OS feature. Nnoobos needs a filesystem and archive utility. RAR support also has licensing and format-version constraints; it should be added only through a suitable legally distributable implementation. A first archive milestone should support ZIP, then evaluate a RAR-compatible library/implementation for the target architecture.

## Driver roadmap

- Keyboard: currently BIOS INT 16h; starter routines in `drivers/keyboard_bios.inc`.
- VGA text: BIOS text mode / B800 memory; starter routines in `drivers/vga_text.inc`.
- Disk: BIOS INT 13h CHS reads; starter routines in `drivers/disk_bios.inc`.
- Next: protected-mode kernel, interrupt controller, PCI enumeration, then device-specific drivers.

## Safety and testing

Test disk images in QEMU/another emulator first. Do not write experimental boot images to a real drive. Driver source snippets are not a guarantee of hardware compatibility and are not linked into the current build until explicitly included and tested.
