# MiniPygame and Pygame compatibility roadmap

## What works now

The Nnoobos kernel has a built-in command named game. From the terminal:

1. Type game and press Enter.
2. Move the red block with the left and right arrow keys.
3. Press Esc to return to the terminal.

This is a native x86-64 kernel demo using the existing VGA mode 13h drawing routines and PS/2 scan codes. It is not a Python program, a Python module, or the Pygame library.

## Target MiniPygame API

The first Python-facing graphics library should aim for a small, stable subset:

- init() and quit() — initialize and release the graphics session.
- display.set_mode((width, height)) and display.flip() — select a supported display mode and present the frame.
- draw.rect(surface, color, rect) — draw a filled rectangle.
- event.get() and key.get_pressed() — poll input without blocking the entire system.
- time.get_ticks() and time.delay(ms) — basic timing.
- A surface/pixel buffer API with bounds checking.

This is a design target only; these Python functions are not implemented yet. Because the current kernel has no general Python runtime, scripts, process model, filesystem, or stable graphics system-call API, it cannot import this library today.

## Suggested implementation order

1. Stabilize the native graphics primitives and add bounds checks to all drawing operations.
2. Introduce a frame buffer abstraction rather than letting applications write arbitrary physical addresses.
3. Add a non-blocking keyboard/event queue and timer service.
4. Implement a filesystem and loadable program/runtime boundary.
5. Port a real Python runtime (MicroPython is a possible starting point) and expose the graphics/input API as Python bindings.
6. Add surfaces, clipping, image loading, frame timing, and audio.
7. Only then investigate SDL portability and the larger compatibility work required for upstream Pygame.

## Compatibility truth

- Native game demo: implemented in kernel source; build and emulator tests must pass before a new ISO is considered verified.
- MiniPygame Python API: planned, not implemented.
- CPython/MicroPython: not integrated.
- Pygame/SDL: not supported.
- pip install pygame: not possible in the current OS.

Do not copy a host Python executable or host Pygame package into the ISO and assume it will run: Nnoobos needs compatible runtime and OS services first.

## Testing

Use the repository's GitHub Actions build. It checks kernel binary size and boots the image in QEMU. Test the interactive game command manually in QEMU after the build succeeds. The existing automated boot test verifies boot/long-mode startup, not arrow-key gameplay.
