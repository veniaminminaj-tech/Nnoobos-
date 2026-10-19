# x86-64 kernel and NEX64 executable groundwork

## Implemented in this milestone

- The BIOS boot sector loads the real-mode stage 2.
- Stage 2 loads nine sectors from floppy CHS sector 10 to physical address `0x10000`.
- Stage 2 builds identity-mapped page tables for the first 2 MiB, enables PAE, EFER.LME and paging, then enters 64-bit long mode.
- The experimental 64-bit kernel writes a status screen directly to VGA text memory.
- The kernel includes `nex_validate_header`, a validator for an in-memory NEX64 header.

## NEX64 header v1

The header is 24 bytes, little-endian:

| Offset | Size | Meaning |
| --- | ---: | --- |
| 0 | 5 | ASCII `NEX64` |
| 5 | 1 | Version, must be 1 |
| 6 | 1 | Architecture, must be 2 (x86-64) |
| 7 | 1 | Reserved, must be 0 |
| 8 | 4 | Image size, 1..1 MiB |
| 12 | 4 | Entry offset, must be less than image size |
| 16 | 8 | Reserved, must be 0 |

The current validator checks only a header already present in memory. It does **not** open files, load an executable image, relocate it, isolate it, or run it. The kernel has no filesystem, process model, user-mode isolation, scheduler, or system-call API yet. Do not treat this format as compatible with DOS MZ or Windows PE executables.

## Important current limits

- The kernel image is limited to 9 sectors (4608 bytes) by the current simple floppy loader.
- The initial page tables map only physical addresses 0..2 MiB using one 2 MiB page.
- VGA text output only; no GUI, mouse, disk filesystem, network or Firefox.
- The legacy desktop shell is replaced by this experimental kernel boot path in this milestone.
- Test only in an emulator using a disposable disk image.

## Next milestones

1. Add a BIOS disk-read routine with track-aware reads and a kernel size field.
2. Add GDT/IDT exception handling and a serial/debug output path.
3. Add physical/virtual memory management and a heap.
4. Implement a simple read-only filesystem and file reads.
5. Implement NEX64 image loading with full image bounds checks and controlled entry transfer.
6. Add a process model and system-call boundary before running third-party code.
7. Investigate DOS MZ compatibility separately; Windows PE requires a much larger Windows API compatibility layer.
