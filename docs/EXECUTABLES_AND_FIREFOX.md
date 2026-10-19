# Executable files and Firefox: engineering plan

## Current state (important)

Nnoobos is a 16-bit BIOS real-mode prototype. It has no general filesystem, process model, virtual memory, user-mode isolation, network stack, graphics/window system, or POSIX/Windows API. Therefore it currently cannot launch arbitrary `.exe` files and cannot run Mozilla Firefox. This document describes the work required; it does not claim those features already work.

## Executable compatibility

The extension `.exe` does not uniquely identify one executable format:

- DOS MZ executables use the MZ header and 16-bit segmented execution model.
- Windows executables normally use the PE/COFF format, with a PE signature, architecture, sections, imports, relocations and other loader metadata.
- 32-bit and 64-bit PE programs require different CPU modes and operating-system services. Windows programs also expect Windows APIs and runtime libraries.

Reference: Microsoft's [PE/COFF format specification](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format).

### Safe implementation milestones

1. Implement a real filesystem and file reads, with bounds checks.
2. Define a small native Nnoobos executable format first, including a magic value, version, architecture, entry point and validated image size.
3. Add a loader that rejects malformed files, checks address ranges and reports unsupported architectures/formats instead of jumping into arbitrary bytes.
4. Add a process model, memory protection and a controlled system-call/API boundary before executing third-party programs.
5. Consider DOS MZ compatibility only after a DOS-compatible execution environment exists.
6. Treat Windows PE compatibility as a separate long-term project; parsing PE headers alone is not enough to run Windows applications.

Do not run untrusted executables on a real computer. Test loader changes in an emulator with disposable disk images.

## Firefox / web browser

Firefox is a large desktop browser, not a single portable executable. Mozilla documents platform-specific runtime requirements; on Linux it depends on a supported userspace and libraries, and current builds require a modern 64-bit operating-system environment. See [Mozilla's Firefox system requirements](https://www.mozilla.org/en-US/firefox/115.0/system-requirements/) and [Firefox Linux build requirements](https://github.com/mozilla-firefox/firefox/blob/main/docs/setup/linux_build.md).

The current Nnoobos text-mode stage cannot host Firefox. A real Firefox port would first need, at minimum:

- a 32/64-bit kernel and a supported CPU execution mode;
- memory management, process/thread scheduling and synchronization;
- a filesystem, dynamic loading and a runtime/library layer;
- graphics, font rendering, input and windowing;
- networking (Ethernet/Wi-Fi drivers, TCP/IP, DNS), TLS and certificate storage;
- a substantial supported userspace and a compatible toolchain.

### Practical browser roadmap

1. Build a small text-mode browser for local text/HTML documents first.
2. Add a filesystem and a reliable network stack.
3. Add a simple graphical browser with a limited HTML subset, if a graphics stack is available.
4. Only then evaluate whether a Firefox port or an existing supported browser engine is feasible.

A menu named “Firefox” or an address bar mockup would not be a real browser and must not be presented as one. No Firefox binary is bundled by this change.
