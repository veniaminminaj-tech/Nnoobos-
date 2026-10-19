# NedohackOS — KolibriOS-based edition

NedohackOS is being developed as a derivative of KolibriOS, with changes kept in this repository as a reproducible overlay instead of duplicating the entire upstream source tree.

## Build the ISO

The GitHub Actions workflow [Build NedohackOS bootable ISO](https://github.com/veniaminminaj-tech/Nnoobos-/actions/workflows/build-iso.yml) runs on pushes to this branch and can also be started manually with **Actions → Build NedohackOS bootable ISO → Run workflow**.

When the workflow succeeds, open its run and download the **NedohackOS-ISO** artifact. It contains `NedohackOS.iso`, the customized KolibriOS floppy image, and the El Torito boot report.

The ISO has a BIOS/GRUB boot menu branded **NedohackOS based on KolibriOS**. It uses the official prebuilt KolibriOS floppy image as its booted system and copies the NedohackOS wallpaper and eight SVG icons into `/NEDOHACK` on that disk image. The artwork is also available separately in the ISO under `/nedohackos/assets/`.

**Current limitation:** the assets are bundled in the ISO and on the disk image, but the stock KolibriOS desktop does not yet load the wallpaper or SVGs automatically. The boot menu is branded; this does not replace the internal boot screen or kernel of the official prebuilt image with a rebuilt NedohackOS kernel. The workflow performs ISO-format validation and a QEMU BIOS smoke test, but this is not a full interactive desktop acceptance test.

## Source overlay and licensing

- Upstream: [KolibriOS/kolibrios](https://github.com/KolibriOS/kolibrios)
- The upstream source is GPL-2.0; retain its copyright and license notices when distributing modified builds.
- `nedohackos/apply_branding.py` applies the initial source branding changes.
- `nedohackos/integrate_assets.py` stages the artwork into an upstream source checkout for source-patch packaging.
- `nedohackos/assets/background/nedohackos-wallpaper.jpg` is the wallpaper asset.
- `nedohackos/assets/icons8/` contains eight original 256×256 SVG icon designs.

## Validate the source overlay locally

With Git and Python 3 installed:

```bash
git clone --depth 1 https://github.com/KolibriOS/kolibrios.git upstream/kolibrios
python3 nedohackos/apply_branding.py upstream/kolibrios
python3 nedohackos/integrate_assets.py . upstream/kolibrios
git -C upstream/kolibrios diff --check
```

The separate `build.yml` workflow validates the pinned upstream source and uploads a source patch. The `build-iso.yml` workflow creates the bootable ISO artifact described above.

The existing `main` branch is unchanged. Work on this migration stays on `nedohackos-kolibri`.
