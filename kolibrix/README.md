# KolibriX

KolibriX is a single x86 operating-system distribution built on the KolibriOS kernel and native system ABI while its own userland is developed.

## Current development target: KolibriX 0.5 preview

The first MVP is intentionally being built **without writing new hardware drivers**. It temporarily uses the upstream KolibriOS kernel and hardware support so development can focus on the KolibriX system identity and graphical environment.

The 0.5 preview target is:

- one GRUB boot entry named **KolibriX**;
- automatic boot into a KolibriX-branded graphical desktop;
- a hybrid dark-blue desktop concept combining a macOS-inspired top menu bar and dock, Windows 11-inspired taskbar and information cards, and iOS-inspired touch-friendly app tiles;
- clickable shortcuts for compatible upstream file manager, terminal, text editor, settings, and games;
- working launch actions for compatible built-in KolibriOS utilities;
- one ISO containing the complete boot path and desktop program.

## 0.5 preview limitations

- original KolibriX hardware drivers;
- an independently rewritten kernel;
- persistent desktop icon layout and KolibriX-owned file manager operations;
- a native Python runtime;
- a working PE32 loader and Win32 API compatibility implementation;
- C/C++ development toolchain integrated into the ISO;
- C# compiler/runtime integration;
- guaranteed support for physical hardware beyond the upstream KolibriOS baseline.

Python .py execution and Windows .exe compatibility are runtime/loader projects, not hardware drivers. The staged Win32 compatibility design is documented in [compat/winapi](compat/winapi/README.md); it is a specification, not an implemented API yet.

## Programming languages

KolibriX is preparing a native development environment for **C, C++, and C#**, while FASM remains available for low-level system development.

- C and C++ will use the established KolibriOS x86 SDK/toolchain as the starting point, with a reproducible compiler, linker, headers, and native executable output.
- C# requires a managed runtime/IL execution layer as well as a compiler. A .cs source file or a Windows .NET executable cannot run natively until that runtime exists.
- Starter source files and the implementation plan are in [kolibrix/devtools](devtools/README.md).

These are development targets, not features already shipped in the 0.5 ISO.

## Build

GitHub Actions workflow: [KolibriX ISO](../../actions/workflows/kolibrix-iso.yml).

The workflow compiles the native desktop with FASM, places it into the complete KolibriOS LiveCD image, configures automatic startup, builds a BIOS-bootable ISO with one GRUB entry, and performs a QEMU boot-path smoke test. The desktop is an early preview. The visual language is inspired by macOS, Windows 11, and iOS; it is not an exact copy. QEMU headless testing does not verify visual rendering or every click.

A successful headless QEMU smoke test confirms only that the emulator did not exit early. It does not by itself prove that the graphical desktop rendered correctly or that every menu action works. Those require visual and interactive testing.

## Licensing

KolibriOS-derived components retain their upstream copyright and GPL-2.0 obligations. KolibriX-specific code is maintained in this repository and must not be presented as upstream code.
