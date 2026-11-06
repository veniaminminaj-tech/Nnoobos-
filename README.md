# KolibriX

KolibriX is a planned x86 distribution based on KolibriOS, with a Windows 11-inspired desktop, persistent desktop folders, a file manager, and an integrated Python environment.

## Current status

**Milestone 1 — architecture baseline.** The requirements and technical boundaries are documented in [kolibrix/docs/architecture.md](kolibrix/docs/architecture.md).

This branch does not yet contain a verified KolibriX desktop build or a completed bootable ISO workflow. Do not treat the current repository state as a finished operating system.

## Main requirements

- Windows 11-inspired desktop shell, taskbar, Start-style launcher, and context menus.
- Real folders on the desktop, persisted in user storage across restarts.
- File manager with create, copy, move, rename, and delete operations.
- Integrated Python runtime, editor, and `.py` script launcher, after a native KolibriOS/x86 port is verified.
- Target ISO size: at most 5 GiB.

## Compatibility

KolibriOS native applications and Windows PE `.exe` files are different executable formats. Native app support does not mean Windows compatibility. Arbitrary Windows PE execution is a separate research and engineering milestone; it is not implemented or promised yet.

## Upstream and licensing

- Upstream project: [KolibriOS/kolibrios](https://github.com/KolibriOS/kolibrios)
- Preserve upstream copyright notices and GPL-2.0 license terms when modifying or redistributing upstream components.
- Keep KolibriX-specific code and documentation clearly identified.

## Development

Work is isolated on the `kolibrix-dev` branch. The next engineering task is to pin a specific KolibriOS source revision, verify its build instructions and toolchain, and build a clean baseline image before implementing the desktop shell.
