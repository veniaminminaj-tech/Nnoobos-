# NedohackOS Full HD (1920×1080)

## What is Full HD in this build?

The wallpaper source is rendered to exactly **1920×1080** for the ISO. App icon source files are preserved as SVG and normalized to **512×512 PNG**. These are asset sizes; they do not, by themselves, change the live desktop resolution.

The current ISO boots the upstream KolibriOS image through GRUB/memdisk. Its desktop resolution is controlled by KolibriOS's graphics driver and the virtual/physical video adapter. This repository does not yet patch the native KolibriOS desktop resources or force a 1920×1080 mode, so it would be misleading to claim the entire live OS is already locked to Full HD.

## Try 1920×1080 in a virtual machine

1. Set the VM's display/video adapter to a standard VGA-compatible adapter and allocate enough video memory if the VM exposes that option.
2. Boot the NedohackOS ISO.
3. Open KolibriOS's display/video settings and select **1920×1080** only if that mode is offered by the active video driver.
4. Apply the mode and confirm that text and desktop elements remain visible. If the mode is not listed, use a supported mode; do not assume that changing the host window size changes the guest resolution.
5. Reboot the VM and check whether the mode persists.

For QEMU, a standard VGA device is a reasonable compatibility starting point (for example, `-vga std`), but this option does **not** force the guest to use 1920×1080. The guest driver must expose that mode.

## Build verification

GitHub Actions verifies that the packaged wallpaper PNG is exactly 1920×1080 and that normalized icon PNGs are included in the ISO. This is asset validation, not proof that the live KolibriOS desktop runs at 1920×1080.

## What remains for a true Full HD desktop release

- Verify that the KolibriOS graphics driver supports 1920×1080 on the intended VM/hardware.
- Integrate the NedohackOS wallpaper into KolibriOS's actual desktop settings/resources.
- Convert the new icons into KolibriOS-native icon resources and install them into the image.
- Add a boot test that captures or otherwise verifies the guest's actual desktop mode, not just the ISO contents.
