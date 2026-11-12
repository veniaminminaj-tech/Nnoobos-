# KolibriX

KolibriX is an x86 operating-system distribution built on the KolibriOS kernel and native system ABI while KolibriX-specific userland components are developed.

## Release target: KolibriX 1.0.0

The 1.0 release is a first usable desktop distribution, not a claim that the kernel or every subsystem has been rewritten. It keeps the complete upstream KolibriOS LiveCD as its hardware and boot foundation and adds the KolibriX startup configuration, native desktop shell, application launcher, and Code Studio configuration.

### Included in 1.0

- Complete official KolibriOS LiveCD filesystem and original El Torito boot path, patched with KolibriX components.
- Automatic startup of the native MENUET01 KolibriX desktop shell.
- Dark navy desktop with a top menu bar, application tiles, launcher, taskbar, and dock.
- Launch shortcuts for compatible upstream file manager, terminal, CEdit Code Studio, settings, and games.
- CEdit configuration with dark theme and C, C++, C#, and FASM syntax profiles.
- Reproducible GitHub Actions build, El Torito report, ISO SHA-256 checksum, and BIOS QEMU smoke test.

### Not included / not yet complete

- Independently written kernel or original KolibriX hardware drivers.
- Full window manager, movable windows, persistent desktop layout, or KolibriX-owned file manager.
- Native Python runtime or .py execution.
- Windows PE32 loader or Win32 API compatibility.
- Bundled C/C++ compilers or C# compiler/runtime.
- VS Code-level project explorer, integrated terminal, LSP/IntelliSense, extensions, or debugger.
- Verified support for all physical PCs and devices.

These are future milestones. Do not interpret syntax highlighting as compiler support, or a file extension association as executable compatibility.

## Programming languages

C, C++, and C# are development targets. FASM is used for the current low-level shell. The current Code Studio entry launches the existing upstream KolibriOS CEdit editor; it is configured for a dark theme and language syntax profiles, but it is not a VS Code clone and does not include compilers.

- C/C++: integrate a pinned Kolibrios-compatible x86 SDK/toolchain and verify generated native binaries.
- C#: requires both a compiler and a managed runtime/IL execution layer.
- Python: requires a native interpreter port and tested .py launcher.
- Windows .exe: requires a PE32 loader and staged Win32 API implementation.

See [devtools](devtools/README.md) and [architecture](docs/architecture.md).

## Build and test

GitHub Actions workflow: [KolibriX ISO](../../actions/workflows/kolibrix-iso.yml).

The workflow downloads the full official LiveCD, compiles the KolibriX shell with FASM, injects the shell and CEdit configuration, patches the original bootable ISO, checks the El Torito catalog, calculates SHA-256, and runs a headless QEMU BIOS smoke test.

A QEMU timeout only indicates that the emulator remained running for the test window. It does not prove that the graphical desktop rendered correctly or that every click action works. Visual and interactive testing is still required before claiming those results.

## Licensing

KolibriOS-derived components retain their upstream copyright and GPL-2.0 obligations. KolibriX-specific code is maintained in this repository and must not be presented as upstream code.
