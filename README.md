# NedohackOS

NedohackOS is being developed as a derivative of **KolibriOS**, using the real KolibriOS source tree as its foundation. This branch preserves the original repository history and introduces a reproducible source overlay rather than deleting the existing Nnoobos experiments.

## Start here

- [NedohackOS migration notes and build plan](nedohackos/README.md)
- [Branding overlay script](nedohackos/apply_branding.py)
- [Validate overlay workflow](.github/workflows/build.yml)

## Upstream project

The base operating system is [KolibriOS](https://github.com/KolibriOS/kolibrios), licensed under GPL-2.0. This derivative must retain upstream copyright notices and license terms. The source overlay currently changes the English boot-screen branding, the default ramdisk-save filename, and the source README title.

## Current status

The overlay is a first migration step, **not yet a complete rebrand or bootable NedohackOS ISO**. CI checks that the patch applies cleanly to a pinned KolibriOS source revision and publishes a patch artifact. Building a modified OS image is a later milestone and must be tested in an emulator before being called ready.

The `main` branch is unchanged. All current work is isolated in `nedohackos-kolibri`.
