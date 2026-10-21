# Nedohack DevTools (prototype)

Native FASM starter for the MenuetOS 64-bit ABI. The current source is a **UI prototype only**.

## Source

- `devtools.asm` — initial window/event-loop skeleton and capability labels.

## Current limitations

This prototype does not yet implement a file picker, file reading/writing, syntax highlighting, process execution, or compilation. It must be assembled and tested against the exact MenuetOS 64-bit FASM examples/SDK before it is considered working.

MenuetOS is not Windows:
- `.py` can be viewed/edited once file I/O and an editor are implemented; running requires a compatible Python interpreter.
- `.cpp` / `.h` can be viewed/edited once file I/O and an editor are implemented; compiling requires a compatible C++ compiler.
- Windows `.exe` files cannot be assumed to run natively. The prototype only plans to identify/inspect them.

## Next implementation steps

1. Verify the header and syscall usage against a known-good MenuetOS 64-bit FASM example.
2. Add real GUI buttons and a visible status area.
3. Implement directory listing and file I/O using supported MenuetOS system calls.
4. Add a bounded text editor for source files.
5. Detect available interpreter/compiler binaries rather than pretending they exist.
6. Test in QEMU and VirtualBox; keep the original ISO untouched.

## Build

Use the FASM version/toolchain intended for MenuetOS 64-bit and compare the header/syscalls with the official SDK examples. No prebuilt executable or ISO is produced by this source yet.
