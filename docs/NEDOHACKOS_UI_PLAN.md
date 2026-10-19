# NedohackOS UI redesign plan

## Product direction

NedohackOS keeps the existing Nnoobos FASM x86-64 kernel and boot chain. The first stage of this redesign changes the project identity and documentation; it does not claim that a graphical desktop already exists.

The target is a lightweight, keyboard-friendly desktop inspired by the broad usability of KolibriOS: compact controls, a simple taskbar/menu, desktop shortcuts, small windows, and a low-resource footprint. NedohackOS should have original implementation, assets, icons, and branding.

## Current baseline verified in the repository

- `main.asm` builds a 512-byte BIOS boot sector.
- `boot/stage2.asm` loads a fixed kernel region, sets up initial page tables, enables long mode, and jumps to `kernel/kernel64.asm`.
- The kernel currently prints status text to VGA text memory and serial output, then halts.
- GitHub Actions assembles the boot files, tests the kernel and ISO boot path in QEMU, and creates an ISO with a separate official KolibriOS fallback option.
- There is no kernel GUI, filesystem, mouse driver, network stack, process isolation, or native browser at this baseline.

## Phased implementation

### Phase 1 — identity and reproducible builds
- Use NedohackOS consistently in kernel messages, boot errors, workflow labels, artifact name, and documentation.
- Keep the existing Git history; work on a dedicated `nedohackos-redesign` branch.
- Keep the official KolibriOS boot option clearly labeled as a separate OS.

### Phase 2 — kernel reliability
- Add exception/interrupt descriptor tables and readable fault reporting.
- Introduce a timer and keyboard input with safe bounds checks.
- Establish memory-map conventions and a basic allocator before loading programs.

### Phase 3 — interactive text shell
- Add a command prompt, help/about commands, reboot command, and keyboard-driven menu.
- Keep this milestone independent of graphics so it can be tested through serial logs and QEMU.

### Phase 4 — original desktop UI
- Choose a supported graphics mode and define a small drawing API.
- Add mouse input, a taskbar/menu, desktop icons, and basic window management.
- Create original SVG/source assets and document their licenses.
- Add screenshots and automated smoke tests before describing the UI as usable.

### Phase 5 — apps and networking
- Build filesystem and file APIs, process boundaries, and controlled program loading before adding apps.
- Treat a browser and Python IDE as later milestones; do not imply that a host-side prototype runs inside the bare-metal kernel.

## Acceptance criteria

- CI assembles all binaries and the ISO without errors.
- QEMU serial output contains the NedohackOS kernel banner and long-mode confirmation.
- The ISO's default menu entry starts NedohackOS; the KolibriOS entry remains a separate fallback.
- Documentation clearly distinguishes implemented kernel behavior from planned features.
