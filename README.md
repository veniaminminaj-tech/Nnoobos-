# NedohackOS

NedohackOS is an experimental x86-64 hobby operating system written in FASM assembly.

## BIOS boot ISO

The GitHub Actions workflow assembles the boot sector, stage 2 and 64-bit kernel, tests the raw image in QEMU, downloads the official KolibriOS image as a separate fallback option, and packages both choices into a BIOS bootable ISO.

- Workflow: [Build NedohackOS graphical desktop ISO](https://github.com/veniaminminaj-tech/Nnoobos-/actions/workflows/build.yml)
- After a successful run, download the artifact **nedohackos-graphical-iso**.
- The ISO is BIOS/Legacy boot only; disable EFI/UEFI in the virtual machine.
- QEMU example: `qemu-system-x86_64 -cdrom nedohackos-graphical.iso -boot d`
- Choose **NedohackOS x86-64 (experimental)** for the new desktop, or **KolibriOS (official fallback)** to boot KolibriOS separately.

## Current graphical milestone

- Stage 2 asks the BIOS for VBE 800×600×24-bit graphics mode before entering long mode.
- The kernel draws a built-in dark neon desktop, app tiles, a central panel and a bottom taskbar directly to the linear framebuffer.
- The kernel reports graphical startup over COM1 so the QEMU workflow can verify it.
- If the BIOS cannot provide the requested VBE mode, the kernel falls back to a VGA text diagnostic screen.

This is an early graphical prototype: the drawn tiles are placeholders, not yet the SVG icon files in `nedohackos/assets/icons8`. The background image in the assets folder is also not yet embedded into the boot image. Mouse input, clickable windows, a filesystem, app launching, networking and a native userspace are not implemented yet.

## Boot architecture

- BIOS boot sector loads stage 2.
- Stage 2 reads the kernel from floppy sectors 10–18, sets up identity-mapped 2 MiB pages for the first 4 GiB, and enters x86-64 long mode.
- The kernel renders the desktop using a VBE linear framebuffer when available and keeps COM1 diagnostics for emulator tests.
- KolibriOS remains a separate boot-menu fallback; it is not the NedohackOS kernel.

## Current limitations

- BIOS/CHS loader with a fixed 9-sector kernel read; kernel must remain at or below 4608 bytes.
- The framebuffer mode currently targets VBE 800×600×24-bit.
- No mouse, keyboard-driven desktop interaction, filesystem, networking, or executable loading yet.
- The NEX64 code is only an in-memory header validator, not a complete program loader.

Test only in an emulator with disposable disk images. Do not write this experimental image to a real disk.
