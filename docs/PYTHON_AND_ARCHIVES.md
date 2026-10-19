# Python, archives, and drivers in Nnoobos

## Current reality

Nnoobos currently boots into a 16-bit x86 BIOS real-mode text interface. That is too small and old for a normal CPython installation, WinRAR, modern USB drivers, or Linux device-driver modules. The files in `drivers/` are starter BIOS-backed assembly routines; they are not yet wired into the boot image and must not be described as fully installed drivers.

## Python

### Current status

The x86-64 kernel now includes **MiniPython 0.1**, a tiny built-in Python-like command handler. In the terminal:

- `python --version` shows the MiniPython version.
- `python print("Hello")` displays the quoted string.
- `python` explains the supported subset.

This is deliberately very limited: it handles a single quoted string passed to `print`; it does not execute general Python programs, variables, arithmetic, imports, scripts, or third-party modules. It is not CPython or MicroPython, and `pip install` still cannot install packages.

### Path to full Python

1. Add filesystem and disk-file reads so scripts can be stored and opened.
2. Add reliable memory allocation, console I/O, and a program/runtime boundary.
3. Port a real Python implementation such as MicroPython to Nnoobos; only then can a genuine Python interpreter and package strategy be considered.

A command that launches host Python would not be Python running inside Nnoobos.

## RAR / WinRAR

WinRAR is a Windows application, not a standalone OS feature. Nnoobos needs a filesystem and archive utility. RAR support also has licensing and format-version constraints; it should be added only through a suitable legally distributable implementation. A first archive milestone should support ZIP, then evaluate a RAR-compatible library/implementation for the target architecture.

## Driver roadmap

- Keyboard: currently BIOS INT 16h; starter routines in `drivers/keyboard_bios.inc`.
- VGA text: BIOS text mode / B800 memory; starter routines in `drivers/vga_text.inc`.
- Disk: BIOS INT 13h CHS reads; starter routines in `drivers/disk_bios.inc`.
- Next: protected-mode kernel, interrupt controller, PCI enumeration, then device-specific drivers.

## Safety and testing

Test disk images in QEMU/another emulator first. Do not write experimental boot images to a real drive. Driver source snippets are not a guarantee of hardware compatibility and are not linked into the current build until explicitly included and tested.
