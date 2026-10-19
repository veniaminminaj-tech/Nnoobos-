# NedohackOS

**NedohackOS** is an experimental x86-64 hobby operating system built from the Nnoobos kernel in FASM assembly. This branch starts the rebrand and UI redesign while preserving the existing Git history.

## Current build status

- Legacy BIOS boot path for x86-64.
- BIOS boot sector loads stage 2; stage 2 loads the kernel and enters 64-bit long mode.
- The kernel writes diagnostic status text to VGA text memory and COM1 serial output.
- A small NEX64 header validator is present as loader groundwork.
- GitHub Actions assembles the binaries and smoke-tests the boot path in QEMU.
- The ISO offers NedohackOS and the separate official KolibriOS image as boot-menu choices.

**Important:** the current kernel is still a text-mode experimental kernel. A KolibriOS-inspired graphical desktop, mouse support, windows, filesystem, networking, browser, and native Python IDE are not implemented in the kernel yet. The desktop prototype is not the bare-metal OS.

## Boot the ISO

1. Open the repository's [Actions](https://github.com/veniaminminaj-tech/Nnoobos-/actions) tab.
2. Open the latest successful **Build NedohackOS x86-64 + KolibriOS ISO** run.
3. Download the **nedohackos-kolibri-boot-iso** artifact and extract it.
4. Start `nedohackos-kolibri.iso` in VirtualBox with **Enable EFI turned off** (Legacy BIOS), 256–512 MB RAM, and the ISO mounted as a CD/DVD. QEMU example: `qemu-system-x86_64 -cdrom nedohackos-kolibri.iso -boot d`.

Choose **NedohackOS x86-64 (experimental)** to boot this kernel. Choose **KolibriOS (separate system)** only to test the official fallback image. KolibriOS is not the NedohackOS kernel.

## KolibriOS-inspired UI roadmap

The goal is a compact, fast desktop with a bottom taskbar, start/menu button, desktop shortcuts, small windows, and a classic lightweight palette inspired by the *general design language* of KolibriOS. NedohackOS will use its own code, icons, layout details, and branding rather than copying KolibriOS assets wholesale.

1. **Boot identity:** rename kernel/boot messages and artifact labels to NedohackOS.
2. **Kernel foundations:** add IDT/exception handling, keyboard input, timer, memory management, and a basic framebuffer or VGA drawing layer.
3. **Text UI milestone:** interactive shell and keyboard-driven menu before attempting a full GUI.
4. **Graphics milestone:** graphics mode, mouse input, window/taskbar manager, and original icons.
5. **Applications:** filesystem-backed file manager and terminal; later, a safe application-loading boundary.
6. **Network and browser:** only after networking and process/memory isolation exist.

See [the UI redesign plan](docs/NEDOHACKOS_UI_PLAN.md) and [NEX64/kernel notes](docs/X86_64_AND_NEX64.md).

## Executable support limits

NedohackOS does **not** yet run Windows `.exe` files, DOS MZ programs, or complete NEX64 programs from disk. The kernel currently validates a 24-byte NEX64 header only when it is already in memory. A filesystem, full image loader, memory manager, process model, and system-call boundary are still required.

## Safety and testing

Test only in an emulator with disposable virtual disks. Do not write this experimental image to a real disk. The QEMU smoke test confirms boot progression, not that the OS is a complete desktop or suitable for everyday use.

## NedohackOS ISO assets

The BIOS ISO workflow packages the repository wallpaper images from `background/` and icon source files from `data/common/nedohackos/`. It also creates normalized **512 × 512 pixel PNG** copies in `assets/icons/512/` inside the ISO; originals are preserved in `assets/icons/original/`. After pushing to `nedohackos-redesign`, open [the build workflow](https://github.com/veniaminminaj-tech/Nnoobos-/actions/workflows/build.yml) and download the `nedohackos-kolibri-boot-iso` artifact when the run succeeds.

**Important:** 512 × 512 pixels is the image resolution (not “512-bit”). The current experimental kernel is still VGA text-mode only, so these files are bundled in the ISO but are not yet displayed by a graphical desktop.
