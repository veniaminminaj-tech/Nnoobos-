# Nnoobos

Nnoobos is an experimental x86 hobby OS written in FASM assembly.

## BIOS boot ISO with a boot menu

The GitHub Actions workflow assembles Nnoobos, runs a QEMU boot smoke test, downloads the official KolibriOS floppy image, and creates a BIOS ISO with a menu for both systems.

- Workflow: [Build Nnoobos x86-64 + KolibriOS ISO](https://github.com/veniaminminaj-tech/Nnoobos-/actions/workflows/build.yml)
- After a successful run, download the artifact **nnoobos-kolibri-boot-iso**.
- Start `nnoobos-kolibri.iso` in VirtualBox with **Enable EFI turned off** (Legacy BIOS), chipset **PIIX3** or default, 256–512 MB RAM, and the ISO attached as the optical drive.
- In VMware, use a BIOS firmware VM and attach the ISO as a CD/DVD image. In QEMU, use `-cdrom nnoobos-kolibri.iso -boot d`.
- If the VM says **No bootable medium**, check that EFI is disabled and the ISO is mounted as a CD/DVD, not as a hard disk. If Nnoobos hangs, choose the KolibriOS entry to check whether the VM's BIOS boot path works.
- Choose **Nnoobos x86-64 (experimental)** to test Nnoobos, or **KolibriOS (official fallback)** to confirm the virtual machine can boot a known working system.
- The workflow checks both the raw Nnoobos floppy and the complete ISO boot path in QEMU, then uploads the serial logs. The ISO is BIOS/Legacy boot only; UEFI mode is not supported by this boot menu.

KolibriOS is included as a separate boot-menu option; its kernel is not used as the Nnoobos kernel. The two operating systems have different kernel and boot requirements.

## Current experimental x86-64 boot path

- BIOS boot sector loads the second stage.
- Stage 2 reads the kernel from floppy sectors 10–18, builds initial identity-mapped page tables, enables PAE/paging and enters x86-64 long mode.
- The 64-bit kernel writes a status screen directly to VGA text memory and emits boot diagnostics on COM1 for automated emulator testing.
- A first NEX64 executable-header validator is included as groundwork for a future native program loader.

This is an early kernel milestone, not a general-purpose operating system. The current boot path replaces the old text desktop shell. The legacy shell code is not part of this new boot path until a proper 64-bit userspace/window system exists.

## Executable support status

Nnoobos does **not** yet run Windows `.exe` files, DOS MZ programs, or complete NEX64 programs from disk. The kernel currently validates a 24-byte NEX64 header only when it is already in memory. A filesystem, full image loader, memory manager, process model and system-call boundary are still required. See [NEX64 and x86-64 kernel notes](docs/X86_64_AND_NEX64.md) and [Executable and Firefox roadmap](docs/EXECUTABLES_AND_FIREFOX.md).

## Current limits

- BIOS/CHS loader with a fixed 9-sector kernel read.
- Initial page tables identity-map only the first 2 MiB.
- VGA text mode only; no filesystem, network, GUI, mouse or Firefox.
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
