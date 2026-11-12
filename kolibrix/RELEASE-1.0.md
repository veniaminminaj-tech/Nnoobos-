# KolibriX 1.0.0

## Release scope

KolibriX 1.0.0 is the first release target built from the complete official KolibriOS LiveCD with KolibriX-specific startup and desktop components injected into its system image.

## Included

- Full upstream KolibriOS LiveCD filesystem and original El Torito boot path.
- KolibriX native MENUET01 desktop shell, built with FASM.
- Automatic startup configuration for KXDESK.
- Desktop tiles and launcher actions for compatible upstream system applications.
- CEdit Code Studio configuration with dark theme and C, C++, C#, and FASM syntax profiles.
- CI checks for the El Torito catalog and a headless QEMU BIOS smoke test.
- SHA-256 checksum for the generated ISO.

## Known limitations

- Kernel and hardware drivers are from upstream KolibriOS, not original KolibriX implementations.
- The bootloader/menu is still upstream; the KolibriX desktop branding appears after startup.
- The desktop is an early shell, not a full window manager. Persistent icon layout, movable windows, and KolibriX-owned file operations are not included.
- Code Studio is the upstream CEdit editor with KolibriX configuration. Compilers, IntelliSense/LSP, integrated terminal, extensions, and debugger are not bundled.
- C, C++, C#, Python, and Windows PE/Win32 compatibility are not runtime-complete features in this ISO.
- A headless QEMU timeout is only a boot-path smoke test. It does not prove the desktop rendered or that input actions work.
- Physical PC compatibility has not been comprehensively tested.

## Build

The GitHub Actions workflow creates `KolibriX-1.0.0.iso` and a SHA-256 checksum. The ISO should not be called fully verified until a successful build and a visual VirtualBox/QEMU boot test have been recorded.

## Licensing

KolibriOS-derived components remain subject to their upstream licenses and notices, including GPL-2.0 where applicable.