# NedohackOS — KolibriOS-based edition

NedohackOS is being developed as a derivative of the real KolibriOS source tree, rather than as a separate Nnoobos kernel with a KolibriOS boot-menu entry.

## Source and licensing

- Upstream source: [KolibriOS/kolibrios](https://github.com/KolibriOS/kolibrios)
- Upstream license: GPL-2.0; preserve upstream copyright and license notices when distributing modified builds.
- This repository stores a reproducible overlay instead of duplicating the entire upstream source tree.
- `nedohackos/apply_branding.py` applies the initial branding changes.
- `nedohackos/integrate_assets.py` stages the NedohackOS artwork into the upstream source checkout for inclusion in the source patch.

## Current customizations

1. The English boot screen identifies the derivative as **NedohackOS based on KolibriOS**, retaining the warranty warning.
2. The ramdisk-save default points to `nedohackos.img`.
3. The patched source README identifies the derivative and links back to upstream.
4. The original wallpaper from the repository's `background/` folder is staged as `data/common/nedohackos/nedohackos-wallpaper.jpg`.
5. Eight original pixel-style SVG icons are staged under `data/common/nedohackos/icons8/`.

**Important:** the wallpaper and icons are now included in the generated source patch, but are not yet selected by the running desktop. KolibriOS's native desktop format/configuration must be confirmed before converting the wallpaper or wiring up desktop icons. This branch does not yet claim to produce a verified bootable ISO.

## Validate the overlay

From the repository root, with Git and Python 3 installed:

```bash
git clone --depth 1 https://github.com/KolibriOS/kolibrios.git upstream/kolibrios
python3 nedohackos/apply_branding.py upstream/kolibrios
python3 nedohackos/integrate_assets.py . upstream/kolibrios
git -C upstream/kolibrios diff --check
```

The GitHub Actions workflow checks the pinned upstream commit, applies branding, stages artwork, and uploads a source patch. It does not build an ISO yet. Full KolibriOS builds use the upstream Tup-based toolchain and configuration described in [build.txt](https://github.com/KolibriOS/kolibrios/blob/main/build.txt).

## Next milestones

- Confirm the native wallpaper format and desktop icon resource format.
- Wire the wallpaper and icons into the default desktop configuration.
- Build the modified image using the documented KolibriOS build environment.
- Boot-test the resulting image in QEMU before publishing it.

The existing `main` branch is unchanged. Work on this migration stays on `nedohackos-kolibri`.
