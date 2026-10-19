# Nnoobos

Nnoobos is an experimental x86 hobby OS written in FASM assembly.

## Current prototype

- BIOS boot sector loads a second-stage program from a floppy-style disk image.
- Text-mode desktop prototype with a taskbar and Start menu.
- Keyboard shortcuts: **F1** Start menu, **F2** system information, **F3** simulated setup screen, **F4** reboot, **Esc** close/redraw.
- Uses BIOS services and VGA text mode. This is still a 16-bit real-mode prototype, not yet a 32-bit operating system.

> **Important:** F3 opens a setup screen inside Nnoobos. It is not the computer's motherboard BIOS/UEFI setup. A normal application cannot replace the motherboard firmware.

## Build

Install FASM on Linux and run:

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

The image is a 1.44 MB floppy image for testing in an emulator such as QEMU. Do not write this experimental image to a real disk.

## Keyboard controls

| Key | Action |
| --- | --- |
| F1 | Show Start menu; press F1 or Esc to close |
| F2 | System information screen |
| F3 | Nnoobos setup screen (simulation) |
| F4 | Reboot via BIOS bootstrap interrupt |
| Esc | Redraw desktop |

## Planned milestones

- Load a separate kernel reliably from disk
- Enter 32-bit protected mode
- Implement GDT, IDT, and interrupt handlers
- Add keyboard driver, memory management, and filesystem
- Explore PE32 executable loading

The project is in early development. The desktop and setup screen are simple text-mode prototypes.
