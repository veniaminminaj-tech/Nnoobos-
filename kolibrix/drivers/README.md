# KolibriX driver subsystem

This directory is the source of truth for original KolibriX driver work.

## Current state

The repository does not yet have a documented upstream-kernel hook that can safely load third-party driver modules. Therefore this milestone establishes the driver contract and test policy; it does **not** pretend that these files are already loadable kernel drivers.

Until a KolibriX kernel interface exists, hardware initialization continues through the clearly identified KolibriOS foundation. Do not relabel upstream drivers as original KolibriX work.

## Planned driver layers

1. **Bus/device discovery** — enumerate devices and expose vendor/device identifiers.
2. **Kernel driver interface** — versioned ABI, lifecycle, resource ownership, interrupt and I/O abstractions.
3. **Device drivers** — display, keyboard, mouse, timer, storage, network, and audio.
4. **User-space services** — expose safe device operations to desktop applications.

## Development order

- QEMU virtual display and text/framebuffer output.
- Keyboard input.
- Mouse input.
- Timer and clock.
- Storage controller and block-device interface.
- Network, then audio.

Every driver must declare supported device IDs, required resources, initialization and shutdown behavior, error paths, and tests. Emulator success is not evidence of physical-hardware support.

## Safety and stability requirements

- No driver may write arbitrary I/O ports or physical memory without an explicit kernel-owned resource grant.
- Validate device-reported lengths and addresses before using them.
- Keep interrupt handlers short; defer lengthy work.
- A failed driver must not take down the desktop or corrupt the filesystem.
- Do not remove an inherited driver until its KolibriX replacement passes boot and regression tests.
