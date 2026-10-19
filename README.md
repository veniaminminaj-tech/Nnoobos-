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
- Real windows/mouse and executable loading

The project is in early development.
