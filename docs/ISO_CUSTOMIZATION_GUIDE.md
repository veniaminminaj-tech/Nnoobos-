# Building a NedohackOS ISO from MenuetOS

This guide describes the safe, manual integration path for Windows. The repository does not redistribute the MenuetOS image and does not currently produce a bootable ISO in GitHub Actions.

## Files you need

- Your legally obtained `M64CD16100.ISO` MenuetOS image
- The `nedohackos-assets` ZIP from the [successful Actions run](https://github.com/veniaminminaj-tech/Nnoobos-/actions/runs/39475173160)
- An ISO editor that explicitly supports preserving bootable/El Torito images
- QEMU for testing

## 1. Keep an untouched original

Make a copy of `M64CD16100.ISO` and work only on the copy. Name the output something like `NedohackOS-test.iso`. Keep the original as a recovery copy.

## 2. Integrate the wallpaper

1. Extract the asset ZIP to a folder.
2. In the ISO editor, open the copied MenuetOS ISO as a bootable image.
3. Locate the MenuetOS system directory. In the original image this is commonly shown as `SM`.
4. Replace the existing `BGR.JPG` in that directory with the NedohackOS wallpaper supplied as `menuetos/BGR.JPG` in the asset ZIP.
5. Merge the setting below into the existing `config.mnt` in the same system directory. Do not replace the entire original config file with the overlay.

```ini
background = '\\SYSDIR\\BGR.JPG'
```

MenuetOS's official configuration documentation describes the `background` setting and image formats. See [MenuetOS configuration](https://menuetos.net/config.txt).

## 3. Do not blindly replace desktop icons

The eight NedohackOS SVG files are design concepts. The package also includes 64×64 BMP previews, but that alone does not prove they match every native MenuetOS icon's required dimensions, palette, naming, or file format. First inspect the native icon configuration and each target icon. Replace icons only when the format and dimensions are confirmed, and keep a backup of every original.

## 4. Preserve bootability

When saving the edited image, choose the ISO editor option that preserves the original boot information / El Torito boot catalog. Do not create a plain data ISO from extracted files. The resulting file should remain a bootable CD image.

## 5. Test before sharing

1. Start the output ISO in QEMU with a virtual CD/DVD drive.
2. Confirm it boots to the MenuetOS desktop.
3. Confirm the wallpaper appears and the normal desktop/apps still work.
4. If it fails, return to the untouched original and retry with a smaller change.
5. Only call it a NedohackOS ISO after these checks pass.

## Current limitations

- This guide is not a claim that the ISO has already been modified or tested.
- The current GitHub Actions workflow packages assets only; it does not patch an ISO.
- No ready-to-boot NedohackOS release is published yet.
- MenuetOS 64-bit has its own license; follow its terms when modifying or sharing an image.
