# KolibriX 0.5.0 — Full LiveCD Preview

## Included
- Full official KolibriOS LiveCD base, with its upstream applications and hardware support.
- One visible GRUB boot entry named **KolibriX**.
- Native FASM/MENUET01 dark-blue KolibriX desktop shell.
- Application cards, taskbar, Start menu, and launch actions for compatible upstream file manager, terminal, text editor, settings, and games.
- BIOS ISO packaging and a QEMU boot-path smoke test in GitHub Actions.

## Not implemented in this preview
- KolibriX-owned persistent file manager and desktop settings.
- Native Python interpreter/runtime and .py launcher.
- PE32 loader or Win32 API implementation for Windows .exe programs.
- Original KolibriX hardware drivers or a rewritten kernel.
- A complete window manager/compositor.

The upstream KolibriOS kernel, ABI, and drivers remain the temporary foundation. This release is a development preview; successful headless QEMU startup does not by itself prove graphical rendering or full interactive behavior.
