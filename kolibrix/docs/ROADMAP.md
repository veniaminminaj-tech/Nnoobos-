# KolibriX roadmap

## 0.1 — bootable prototype
- Boot the official KolibriOS image through a BIOS ISO.
- Add one native MENUET01 test application to the disk image.
- Publish ISO and disk-image artifacts from GitHub Actions.
- Keep KolibriX-specific code in its own directories.

## 0.2 — desktop integration
- Apply KolibriX branding to the live desktop, not only the ISO boot menu.
- Add a native settings/control-center module.
- Add a module registry and version metadata.
- Verify keyboard, mouse, display, and file-manager behavior in QEMU and VirtualBox.

## 0.3 — native application suite
- File manager integration.
- Text editor and terminal launcher.
- Installer/package format for KolibriOS-native applications.

## Later — Windows executable compatibility research
- Identify a safe, realistic subset of PE32 user-mode programs.
- Design compatibility boundaries and required APIs.
- Do not describe Windows EXE compatibility as available until real applications pass tests.
- PE32+ (64-bit Windows) is a separate, substantially larger goal.
