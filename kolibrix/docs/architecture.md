# KolibriX architecture

## Product definition

KolibriX is one operating-system distribution: KolibriOS x86 is the low-level kernel and hardware/API foundation; KolibriX supplies the identity, boot configuration, desktop shell, system utilities, defaults, and later its own userland applications. The result must be presented as KolibriX, not as a separate KolibriOS session with a theme layered on top.

KolibriX 1.0 desktop direction: a dark navy/blue hybrid interface. It combines a macOS-inspired top menu bar and dock, Windows 11-inspired taskbar and information cards, and iOS-inspired touch-friendly app tiles. These are visual inspirations, not copied operating-system assets. The current preview is a native shell, not yet a full window manager or persistent desktop environment. Target ISO size: at most 5 GiB.

## Boot design

- KolibriX 1.0 ships the patched complete official KolibriOS LiveCD ISO directly and preserves its original El Torito boot catalog and bootloader.
- The build does not place the full LiveCD inside a second MEMDISK-wrapped ISO; this avoids the extra nested boot layer used by the 0.5 preview.
- The upstream bootloader and low-level boot chain remain inherited components. The desktop identifies itself as KolibriX after the system startup configuration launches KXDESK.
- A KolibriX-branded boot menu is a later bootloader-integration task; 1.0 does not claim that the upstream boot menu has been replaced.

## System ownership

KolibriX must own:
- product name and boot presentation;
- startup configuration and default services;
- graphical desktop, taskbar, Start menu, shortcuts, and window behavior;
- system settings and default applications;
- filesystem layout and persistent user data conventions;
- release packaging, versioning, and documentation.

The long-term KolibriX goal is to own its hardware-driver code: KolibriX-specific drivers are to be designed, written, tested, and maintained in this repository rather than treating upstream KolibriOS drivers as our finished driver stack. Do not copy upstream driver code and relabel it as original.

During the transition, the existing KolibriOS kernel and its driver interfaces may be used as a temporary boot and hardware-enablement foundation. Any such inherited driver must be clearly identified as upstream, not described as a KolibriX-written driver. Replacing the upstream kernel and its remaining driver dependencies is a separate, later kernel-engineering milestone. Preserve upstream notices and GPL-2.0 obligations for any upstream code that is redistributed or modified.

## Native desktop

Implement the Windows 98-style desktop with native KolibriOS APIs:
- desktop background and selectable/movable shortcuts;
- taskbar and Start menu;
- movable windows and classic controls;
- context menu with New Folder, Rename, and Delete;
- persistent desktop layout and real directories on user storage;
- file manager with create, copy, move, rename, and delete;
- settings, terminal, and text editor.

The desktop must be the normal graphical environment after boot. A shell process that merely draws a static background is not enough: click zones, window lifecycle, app launching, and persistent file operations must be tested.

## Applications and compatibility

- KolibriOS native applications can be reused where compatible, while KolibriX-specific apps should be branded and maintained in this repository.
- Native KolibriOS executables and Windows PE .exe files are different formats. Do not claim arbitrary Windows application support.
- Windows PE compatibility is a separate research project.

## KolibriX driver development

Drivers are a first-class KolibriX subsystem and must be developed as original, reviewable source code in this repository.

- Start with a documented hardware support matrix and identify the exact emulator/VM devices used for development.
- Define stable interfaces between the kernel, bus discovery, device drivers, and user-space services before adding individual drivers.
- Develop and test drivers incrementally in QEMU first; do not claim physical-hardware support based only on emulator tests.
- Prioritize safe, observable devices such as the virtual display, keyboard, mouse, timer, and storage controller. Add networking and audio only after the basic driver model is stable.
- For every driver, document supported device IDs, initialization, I/O paths, error handling, and known limitations.
- Keep upstream KolibriOS drivers clearly marked as temporary dependencies until an original KolibriX replacement exists and passes tests.
- Do not remove a working upstream driver until its KolibriX replacement has boot, functional, and regression test evidence.

## Program formats, runtimes, and compatibility

Python and executable-file support are not hardware drivers. They belong to the KolibriX runtime and executable-loading subsystem.

- Python (.py): provide a native Python interpreter/runtime for the target x86 environment, a launcher, and a basic editor. The interpreter must actually execute scripts on KolibriX; file association or syntax highlighting alone does not count as Python support.
- KolibriOS native executables (.kex / MENUET01): support the native executable format through the existing KolibriOS-compatible loader while that kernel foundation remains in use. Clearly document which native ABI is supported.
- Windows executables (.exe / PE): build a KolibriX Win32 compatibility subsystem: PE32 loader, import resolver, process/thread model, and DLL/API shims. This is not a hardware driver and does not mean embedding Microsoft's Windows. Begin with a deliberately small documented API subset, then run real test binaries and publish results. A file extension association or a wrapper that merely launches another program is not Windows compatibility.
- Win32 API layers: implement compatible subsets of kernel32.dll, user32.dll, and gdi32.dll in stages. Define calling conventions, structures, constants, error behavior, and supported functions in the compatibility documentation before claiming support.
- Keep runtime support separate from hardware drivers: the Python interpreter, PE loader, system libraries, and compatibility services are software subsystems, not device drivers.
- Never claim that every Python package or every Windows .exe works. Publish a tested compatibility list and explicit limitations.

## Programming languages

The programming environment is a separate userland/toolchain subsystem, not part of the kernel or hardware drivers.

### C

- Start from the established KolibriOS x86 SDK/toolchain (including its GCC-based compiler path) rather than assuming a generic host GCC can emit a working KolibriOS executable.
- Package or build a pinned cross-compiler, matching headers, startup objects, linker scripts, libraries, and executable packer.
- Compile a minimal C program, then test native system calls, file access, and GUI events in QEMU.
- Verify the actual generated binary format and ABI before making it available as a system compiler.

### C++

- Use the matching KolibriOS C++ cross-toolchain and verify the C++ runtime and standard-library subset.
- Begin with a minimal program that does not depend on unsupported runtime features.
- Add exceptions, RTTI, threads, and standard-library components only after the matching runtime support is demonstrated.
- Keep C and C++ ABI/startup configuration consistent so C libraries can be linked safely.

### C#

- C# needs both a compiler and a managed runtime. A compiler that emits .NET IL is not enough to execute programs on KolibriX.
- Research a small Mono-based x86 runtime port and identify the required memory management, exception, threading, file, and system-call services.
- Start with a console Hello World test, then add file I/O and basic UI bindings.
- Do not claim that ordinary Windows .NET executables or all modern .NET APIs are supported. Publish the tested language/runtime profile.

Starter source examples and status are maintained in kolibrix/devtools. They are examples and documentation only until compiler/runtime integration and execution tests are complete.

## Python environment

Python is a separate engineering milestone:
- identify a Python interpreter version that can be built for KolibriOS/x86;
- port/adapt the runtime and required system calls;
- provide an editor and .py launcher;
- document unsupported standard-library modules;
- do not bundle Windows Python or claim Python support until native execution is tested.

## Build and verification policy

- Build from a pinned, recorded official KolibriOS source/image revision; record SHA-256 values in CI artifacts.
- Produce a BIOS-bootable ISO with exactly one KolibriX GRUB entry.
- Check the ISO structure and run a QEMU boot smoke test.
- A headless QEMU timeout only proves that the emulator did not exit early; it does not prove that the desktop appeared or that mouse clicks work.
- Require visual boot evidence and interaction tests before calling the graphical desktop verified.
- Keep persistent file operations, language toolchains/runtimes, Python, and Win32/PE compatibility as explicit milestones rather than release claims.

## Milestones

1. **1.0 baseline:** reproducible patched full LiveCD ISO, native KolibriX shell, startup configuration, and Code Studio configuration.
2. Complete and visually validate the desktop event loop, window lifecycle, and app-launch behavior.
3. Persistent desktop folders, file manager, and user settings.
4. KolibriX-branded system utilities and applications.
5. C and C++ cross-toolchain, SDK headers, native examples, and QEMU execution tests.
6. C# compiler/runtime research and a minimal managed Hello World execution test.
7. Native Python runtime, editor, and .py launcher.
8. Specify and implement the PE32 loader and Win32 API compatibility layer, starting with a small tested API subset.

## Licensing

Preserve upstream KolibriOS copyright notices and GPL-2.0 terms for redistributed or modified upstream components. Clearly identify KolibriX-specific code and documentation.
