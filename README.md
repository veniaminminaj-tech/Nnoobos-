# Nnoobos

Nnoobos is an experimental x86 hobby OS written in FASM assembly.

## First ISO build

GitHub Actions now assembles the boot sector, 16-bit stage 2 and experimental 64-bit kernel, creates a 1.44 MB floppy image, then wraps that image in a BIOS El Torito ISO.

- Workflow: [Build Nnoobos x86-64 ISO](https://github.com/veniaminminaj-tech/Nnoobos-/actions/workflows/build.yml)
- After a successful run, open the run's **Artifacts** section and download `nnoobos-first-iso`.
- The ISO uses BIOS floppy-emulation boot media; it is not a UEFI boot ISO.
- Build success and bootability are not claimed until the GitHub Actions run and an emulator test pass.

## Current experimental x86-64 boot path

- BIOS boot sector loads the second stage.
- Stage 2 reads the kernel from floppy sectors 10–18, builds initial identity-mapped page tables, enables PAE/paging and enters x86-64 long mode.
- The 64-bit kernel writes a status screen directly to VGA text memory.
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
