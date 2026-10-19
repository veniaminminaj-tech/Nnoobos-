# Nnoobos

Nnoobos is an experimental x86 hobby OS written in FASM assembly.

## Current prototype

- BIOS boot sector loads a second-stage program from a floppy-style disk image.
- Text-mode desktop with title bar, desktop icons, welcome window, and taskbar.
- Start menu (F1), system information (F2), simulated setup screen (F3), reboot (F4), terminal (F5).
- Interactive Linux-like command shell: `help`, `clear`, `uname`, `ls`, `echo TEXT`, `desktop`, `exit`, `reboot`.
- BIOS video and keyboard services; VGA 80x25 text mode.

This is a 16-bit real-mode prototype, not a Linux distribution and not yet a 32-bit protected-mode OS. The terminal is a small built-in shell; it does not execute Linux binaries or access a real filesystem yet.

> The F3 setup screen is an OS menu simulation, not the motherboard's BIOS/UEFI firmware settings.

## Driver starter files

- `drivers/keyboard_bios.inc` — BIOS keyboard input routines.
- `drivers/vga_text.inc` — BIOS VGA text-mode routines.
- `drivers/disk_bios.inc` — BIOS CHS disk read/reset routines.

These are starter routines and are **not yet linked into the boot image**. The current desktop already calls BIOS services directly.

## EXE files and browser support

Nnoobos does not yet launch Windows `.exe` files or run Firefox. The current 16-bit BIOS prototype lacks the filesystem, process/memory protection, APIs, graphics and networking required for these features. See [Executable and Firefox roadmap](docs/EXECUTABLES_AND_FIREFOX.md) for the technical milestones and references. The roadmap is documentation, not implemented support.

## Python and archive support

Nnoobos does not yet run CPython or WinRAR/RAR tools. See [Python and archive roadmap](docs/PYTHON_AND_ARCHIVES.md) for a realistic implementation plan. Python needs a runtime and OS services; archive support needs a filesystem and an archive implementation. A limited built-in Python-like interpreter could be an intermediate step.

## Build

Install FASM on Linux:

```sh
mkdir -p build
fasm main.asm build/boot.bin
fasm boot/stage2.asm build/stage2.bin
test "$(wc -c < build/boot.bin)" -eq 512
test "$(wc -c < build/stage2.bin)" -le 4096
truncate -s 1474560 build/nnoobos.img
dd if=build/boot.bin of=build/nnoobos.img conv=notrunc
dd if=build/stage2.bin of=build/nnoobos.img bs=512 seek=1 conv=notrunc
```

Run `build/nnoobos.img` in an emulator such as QEMU as a floppy image. Do not write this experimental image to a real disk.

## Keyboard

| Key | Action |
| --- | --- |
| F1 | Start menu |
| F2 | System information |
| F3 | Setup screen simulation |
| F4 | Reboot |
| F5 | Open terminal |
| Esc | Return/redraw desktop |

## Shell commands

- `help` — list commands
- `clear` — clear terminal
- `uname` — show OS/architecture
- `ls` — show placeholder directory list
- `echo TEXT` — print text
- `desktop` or `exit` — return to desktop
- `reboot` — reboot via BIOS

## Roadmap

- Reliable disk loading and a separate 32-bit kernel
- GDT, IDT, protected mode, interrupt handling
- Keyboard driver, memory manager, filesystem
- Real windows/mouse and a validated native executable loader
- Text-mode browser, network stack, then investigate a full browser engine
- Limited scripting interpreter, then investigate real Python runtime
- Filesystem and archive tools; evaluate legally distributable RAR support

The project is in early development.
