# NedohackOS — KolibriOS-based edition

This branch changes the project direction: NedohackOS is intended to be a derivative of the real KolibriOS source tree, rather than a separate Nnoobos kernel with a KolibriOS boot-menu entry.

## Source and licensing

- Upstream source: [KolibriOS/kolibrios](https://github.com/KolibriOS/kolibrios)
- Upstream license: GPL-2.0; preserve all upstream copyright and license notices when distributing modified builds.
- This repository currently stores a small, reproducible branding overlay rather than copying the entire upstream source tree (the upstream repository is large and includes submodules).
- The overlay is applied to a clean checkout of upstream source by `nedohackos/apply_branding.py`.

## Initial customizations

1. The English boot screen identifies the derivative as **NedohackOS based on KolibriOS** while retaining the warranty warning.
2. The ramdisk-save default points to `nedohackos.img`.
3. The patched source README identifies the derivative and links back to upstream.

These are initial branding/configuration changes only. They do not yet constitute a new desktop design, new kernel features, or a verified bootable ISO.

## Validate the overlay

Run from this repository's root on a machine with Git and Python 3:

```bash
git clone --depth 1 https://github.com/KolibriOS/kolibrios.git upstream/kolibrios
python3 nedohackos/apply_branding.py upstream/kolibrios
git -C upstream/kolibrios diff --check
git -C upstream/kolibrios diff -- README.md kernel/trunk/boot/bootstr-en_US.inc data/common/settings/app.ini
```

The CI workflow checks that the overlay applies to the pinned upstream commit and uploads the resulting source patch. It does not claim to build an ISO yet; full KolibriOS builds use the upstream Tup-based toolchain and configuration described in [build.txt](https://github.com/KolibriOS/kolibrios/blob/main/build.txt).

## Next milestones

- Add an original NedohackOS theme/skin without removing upstream attribution.
- Add an original wallpaper and default desktop configuration.
- Build the modified kernel/image using the documented KolibriOS build environment.
- Boot-test the resulting image in QEMU before publishing it.

The existing `main` branch is unchanged. Work on this migration stays on `nedohackos-kolibri`.
