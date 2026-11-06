# KolibriX architecture baseline

## Goal

KolibriX is a KolibriOS-based x86 distribution with a Windows 11-inspired desktop, ordinary desktop folders and an integrated Python environment. The target installer/ISO size is at most 5 GiB.

This document is the first implementation checkpoint. It is an architecture plan, not a claim that these features already work.

## Base and compatibility

- Keep the KolibriOS upstream source as the kernel and native system foundation.
- Keep KolibriX changes in this repository as a reproducible overlay.
- Native KolibriOS applications and Windows PE `.exe` files are different executable formats. Do not label native apps as Windows-compatible.
- Treat Windows PE compatibility as a later, separately scoped project. Do not promise arbitrary Windows application support.

## Desktop shell

Build a KolibriX desktop shell with:
- centered taskbar and Start-style launcher;
- movable, selectable desktop icons;
- context menu with New Folder, Rename, and Delete;
- persistent desktop layout and folder contents;
- file manager with create, copy, move, rename, and delete operations;
- settings, terminal, and basic text editor.

Desktop folders must be real directories in the KolibriX user storage, not visual shortcuts that disappear after reboot. File operations must use the filesystem APIs available in the selected KolibriOS build.

## Python environment

Python is a separate system component:
- first identify a Python version and runtime that can actually be built for KolibriOS/x86;
- port or adapt the interpreter and its required C runtime/system calls;
- provide a small editor and a launcher for `.py` scripts;
- include a basic standard-library subset and document unsupported modules;
- do not bundle a Windows Python distribution or claim CPython compatibility until a native build and smoke test pass.

## Build and size policy

- Build from a pinned KolibriOS upstream revision.
- Keep build steps reproducible in GitHub Actions.
- Produce a bootable ISO and a separate development/debug artifact where useful.
- Enforce a final ISO size below 5 GiB in CI.
- Run static checks and a QEMU boot smoke test; document that this is not proof of full hardware compatibility.

## Milestones

1. **Foundation:** pin and verify the upstream source, document its build process, and produce a clean baseline boot image.
2. **Desktop shell:** implement the KolibriX desktop, taskbar, launcher, context menus, and persistent desktop folders.
3. **File manager:** implement real filesystem operations and persistence tests.
4. **Python:** port/build the interpreter, then add editor and script runner.
5. **Compatibility research:** evaluate Windows PE support separately; publish an honest compatibility matrix.

## Acceptance criteria for milestone 1

- The exact upstream commit is recorded.
- The upstream build instructions and required tools are verified against that commit.
- A clean baseline image boots in QEMU.
- The CI artifact is not described as a completed KolibriX desktop.
- The image-size check rejects images larger than 5 GiB.
