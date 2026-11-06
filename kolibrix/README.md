# KolibriX

KolibriX is a single x86 operating-system distribution built on the KolibriOS kernel and native system ABI while its own userland is developed.

## Current development target: bootable desktop MVP

The first MVP is intentionally being built **without writing new hardware drivers**. It temporarily uses the upstream KolibriOS kernel and hardware support so development can focus on the KolibriX system identity and graphical environment.

The MVP target is:

- one GRUB boot entry named **KolibriX**;
- automatic boot into a KolibriX-branded graphical desktop;
- classic Windows 98 visual style;
- desktop shortcuts and a taskbar with a Start menu;
- working launch actions for compatible built-in KolibriOS utilities;
- one ISO containing the complete boot path and desktop program.

## What is not included yet

- original KolibriX hardware drivers;
- an independently rewritten kernel;
- persistent desktop icon layout or a complete file manager;
- a native Python runtime;
- Windows PE / arbitrary Windows EXE compatibility;
- guaranteed support for physical hardware beyond the upstream KolibriOS baseline.

Python `.py` execution and Windows `.exe` compatibility are runtime/loader projects, not hardware drivers.

## Build

GitHub Actions workflow: [KolibriX ISO](../../actions/workflows/kolibrix-iso.yml).

The workflow compiles the native desktop with FASM, places it into the KolibriOS image, configures automatic startup, builds a BIOS-bootable ISO with one GRUB entry, and performs a QEMU boot-path smoke test.

A successful headless QEMU smoke test confirms only that the emulator did not exit early. It does not by itself prove that the graphical desktop rendered correctly or that every menu action works. Those require visual and interactive testing.

## Licensing

KolibriOS-derived components retain their upstream copyright and GPL-2.0 obligations. KolibriX-specific code is maintained in this repository and must not be presented as upstream code.
