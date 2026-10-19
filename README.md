# Nnoobos

Nnoobos is a small hobby operating system project for x86 (IA-32), written in FASM assembly. The project is being built incrementally, starting with a BIOS boot sector before adding protected mode, kernel services, drivers, memory management, and executable loading.

> **Status:** early development. The current milestone is a minimal BIOS boot sector that prints a startup message. This is not yet a complete operating system.

## Goals

- [x] Assemble a 512-byte BIOS boot sector
- [ ] Load a separate kernel from disk
- [ ] Enable the A20 line and enter 32-bit protected mode
- [ ] Add GDT, IDT, and interrupt handlers
- [ ] Add text output and keyboard input
- [ ] Add physical memory management and paging
- [ ] Explore a simple filesystem
- [ ] Parse and load PE32 executables

## Repository layout

```text
Nnoobos-/
├── boot/
│   └── boot.asm
├── include/
│   ├── constants.inc
│   ├── macros.inc
│   └── memory_map.inc
├── kernel/
│   └── kernel.asm
├── .github/workflows/build.yml
├── .gitignore
├── main.asm
└── README.md
```

## Build

Install [FASM](https://flatassembler.net/) and run from the repository root:

```sh
mkdir -p build
fasm main.asm build/boot.bin
```

The resulting `build/boot.bin` should be exactly 512 bytes. It can be used as a boot-sector image for testing in an emulator such as QEMU. Do not write it to a real disk; this is an experimental project.

On GitHub, the workflow assembles the boot sector and uploads it as a build artifact.

## Design notes

- FASM syntax is used throughout.
- The boot sector starts in 16-bit BIOS real mode.
- The boot sector currently prints a message using BIOS interrupt `int 10h` and then halts.
- The kernel is a separate future milestone; it is not loaded by the current boot sector yet.
- Build output is generated in `build/` and is not committed.

## Contributing

Keep each milestone small and testable. Add new modules only when they are needed by the next milestone, and document the memory layout and boot assumptions as they evolve.
