# NedohackersOS on FASM

NedohackersOS on FASM is an experimental x86 hobby OS written in FASM assembly.

## BIOS boot ISO

The ISO boots **NedohackersOS on FASM itself**. KolibriOS is not bundled or launched. It starts directly on the graphical desktop; press `T` to open the Linux-like command-line shell. The graphical session is an early native kernel prototype with a top header, bottom taskbar, desktop icons, Start menu, and simple app windows.

- Workflow: [Build NedohackersOS on FASM desktop ISO](https://github.com/veniaminminaj-tech/Nnoobos-/actions/workflows/build.yml)
- After a successful run, download the artifact **nedohackersos-on-fasm-iso**.
- Start `nedohackersos-on-fasm.iso` in VirtualBox with **Enable EFI turned off** (Legacy BIOS), 256–512 MB RAM, and the ISO attached as the optical drive.
- This image is BIOS/Legacy boot only; UEFI mode is not supported.
- `Shedletsky.jpg` is included as an image resource; it is not yet the desktop wallpaper.
- A polled PS/2 mouse cursor and basic left-click actions are implemented for the desktop icons, Start button/menu, and a window close target. USB HID and VirtualBox absolute-pointer support are not implemented.

## Current experimental x86-64 boot path

- BIOS boot sector loads the second stage.
- Stage 2 reads the kernel from floppy sector 10 through sector 18, then continues at head 1, sector 1 (up to 16 sectors total), builds initial identity-mapped page tables, enables PAE/paging and enters x86-64 long mode.
- The second stage selects VGA mode 13h and copies the BIOS 8x16 font into low memory. The 64-bit kernel draws a simple experimental pixel-based desktop and placeholder app windows; it emits boot diagnostics on COM1 for automated emulator testing.
- A first NEX64 executable-header validator is included as groundwork for a future native program loader.

This is an early kernel milestone, not a general-purpose operating system. The desktop is a single-screen kernel prototype, not a complete window manager. Files, Notes and Calculator still show placeholder windows and do not yet save files or perform calculations. A filesystem, disk driver, persistent file storage, and VirtualBox host-to-guest drag-and-drop protocol are not implemented.

## Experimental NedohackersOS on FASM keyboard controls

- At startup, press 1 for the graphical desktop or 2 for the terminal.
- Desktop: `S` opens Start; `1` Files; `2` Notes; `3` Calculator; `0` redraws the desktop. With the PS/2 mouse, click Files/Notes/Calculator icons or the Start button; click the menu item row to select an app.
- Terminal: help, clear, uname, pwd, ls, whoami, echo TEXT, python, python --version, and the limited python print("Hello").
- Terminal game demo: type game, move the red block with the left/right arrow keys, and press Esc to return.

MiniPython only handles a single quoted string passed to print; it is not CPython/MicroPython and cannot run arbitrary .py files. The game command is a native kernel demo, not the Pygame Python package. See [MiniPygame roadmap](docs/MINIPYGAME.md).

## Executable support status

NedohackersOS on FASM does **not** yet run Windows `.exe` files, DOS MZ programs, or complete NEX64 programs from disk. The kernel currently validates a 24-byte NEX64 header only when it is already in memory. A filesystem, full image loader, memory manager, process model and system-call boundary are still required. See [NEX64 and x86-64 kernel notes](docs/X86_64_AND_NEX64.md) and [Executable and Firefox roadmap](docs/EXECUTABLES_AND_FIREFOX.md).

## Current limits

- BIOS/CHS loader with a fixed 16-sector maximum kernel read.
- Initial page tables identity-map only the first 2 MiB.
- VGA mode 13h desktop prototype at 320x200; basic PS/2 mouse only, no USB HID, filesystem, persistent storage, network, or Firefox.
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


## NedohackersOS Beta desktop prototype (Python IDE + browser)

A separate desktop preview is available while native kernel services are still being developed. It runs as a regular Python desktop app on Windows and does not replace or modify Windows.

- Start on Windows: double-click `run_beta.bat`, or run `py -3 desktop_beta.py`.
- Python IDE: edit Python code, press **Run**, and view stdout/errors. Runs in a subprocess with an 8-second timeout.
- Browser: with the optional `tkinterweb` package installed, the app attempts to show web pages in its own window. Without it, **Go** opens the URL in your system browser.
- Optional embedded browser dependency: `py -3 -m pip install -r requirements-beta.txt`.
- Icons: see [assets/icons/README.md](assets/icons/README.md) for the open-source Lucide icon references and license.

**Important:** this is a desktop prototype, not yet a browser or CPython implementation inside the bare-metal kernel. The IDE runs code with your normal user permissions; it is not a security sandbox, so only run code you trust. The desktop app itself does not change system settings or install anything.
