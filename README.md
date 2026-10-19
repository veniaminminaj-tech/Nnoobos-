# Nnoobos

Nnoobos is an experimental x86 hobby OS written in FASM assembly.

## BIOS boot ISO

The ISO boots **Nnoobos itself**. KolibriOS is not bundled or launched. At startup, Nnoobos offers a keyboard choice between its graphical desktop and a Linux-like command-line shell. The graphical session is an early native kernel prototype inspired by compact classic desktops: a top header, bottom taskbar, desktop icons, Start menu, and simple app windows.

- Workflow: [Build Nnoobos desktop ISO](https://github.com/veniaminminaj-tech/Nnoobos-/actions/workflows/build.yml)
- After a successful run, download the artifact **nnoobos-desktop-iso**.
- Start `nnoobos-desktop.iso` in VirtualBox with **Enable EFI turned off** (Legacy BIOS), 256–512 MB RAM, and the ISO attached as the optical drive.
- This image is BIOS/Legacy boot only; UEFI mode is not supported.
- `Shedletsky.jpg` is included as an image resource; it is not yet the desktop wallpaper.
- Native USB touchscreen/HID and mouse support are not implemented yet. The current desktop is controlled by keyboard.

## Current experimental x86-64 boot path

- BIOS boot sector loads the second stage.
- Stage 2 reads the kernel from floppy sectors 10–18, builds initial identity-mapped page tables, enables PAE/paging and enters x86-64 long mode.
- The second stage selects VGA mode 13h and copies the BIOS 8x16 font into low memory. The 64-bit kernel draws a simple experimental pixel-based desktop and placeholder app windows; it emits boot diagnostics on COM1 for automated emulator testing.
- A first NEX64 executable-header validator is included as groundwork for a future native program loader.

This is an early kernel milestone, not a general-purpose operating system. The desktop is a single-screen kernel prototype, not a complete window manager. Files, Notes and Calculator currently show placeholder windows and do not yet save files or perform calculations.

## Experimental Nnoobos keyboard controls\n\n- At startup, `1` selects the graphical desktop and `2` selects the terminal.\n- Desktop: `S` opens Start; `1` Files; `2` Notes; `3` Calculator; `0` redraws the desktop.\n- Terminal: `help`, `clear`, `uname`, `pwd`, `ls`, `whoami`, `echo TEXT`, `python`, `python --version`, and the limited `python print("Hello")`; `T` exits the terminal.\n\nThese shortcuts control the Nnoobos desktop.\n\n## Executable support status

Nnoobos does **not** yet run Windows `.exe` files, DOS MZ programs, or complete NEX64 programs from disk. The kernel currently validates a 24-byte NEX64 header only when it is already in memory. A filesystem, full image loader, memory manager, process model and system-call boundary are still required. See [NEX64 and x86-64 kernel notes](docs/X86_64_AND_NEX64.md) and [Executable and Firefox roadmap](docs/EXECUTABLES_AND_FIREFOX.md).

## Current limits

- BIOS/CHS loader with a fixed 9-sector kernel read.
- Initial page tables identity-map only the first 2 MiB.
- VGA mode 13h desktop prototype at 320x200; no mouse/touch driver, filesystem, network or Firefox.
- NEX64 validation is a first step, not full executable support.

## Roadmap

- IDT, exception handlers and serial diagnostics
- Physical and virtual memory management
- Filesystem and disk file reads
- Complete NEX64 loader and controlled execution model
- Process isolation and system calls
- Separate DOS MZ compatibility research; Windows PE compatibility is a long-term project
- Network stack and a browser after kernel services exist

Test only in an emulator with disposable disk images. Do not write the experimental image to a real disk.
