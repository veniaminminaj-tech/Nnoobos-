# KolibriX Win32 compatibility layer

## Purpose

This directory defines an original compatibility implementation for running a limited set of 32-bit Windows PE applications on KolibriX. It is not Microsoft's Windows, does not contain Microsoft's proprietary DLLs, and does not promise that arbitrary Windows applications will run.

The first target is **PE32 / i386**. PE32+ / x64 is explicitly out of scope until the 32-bit ABI is stable.

## Architecture

1. **PE32 loader**
   - Validate DOS and PE signatures and all header/table bounds.
   - Accept only i386 PE32 images in the first milestone.
   - Map sections with correct alignment and permissions.
   - Apply supported base relocations.
   - Resolve imports against KolibriX compatibility DLLs.
   - Set up the initial stack and transfer control only after validation.
   - Reject unsupported or malformed images cleanly; never jump into an unchecked file.

2. **Process and memory services**
   - Provide a documented process address-space model.
   - Implement a small heap/allocation API before broader threading support.
   - Keep Windows handles separate from native KolibriOS file descriptors.
   - Return documented error values for unsupported operations.

3. **Win32 API shims**
   - `kernel32.dll`: initial candidates include `GetLastError`, `SetLastError`, `GetModuleHandleA`, `GetProcAddress`, `GetCommandLineA`, `GetCurrentProcessId`, `ExitProcess`, `HeapAlloc`, `HeapFree`, `VirtualAlloc`, `VirtualFree`, `CreateFileA`, `ReadFile`, `WriteFile`, and `CloseHandle`.
   - `user32.dll`: later add `RegisterClassA`, `CreateWindowExA`, `ShowWindow`, `UpdateWindow`, `GetMessageA`, `TranslateMessage`, `DispatchMessageA`, `DefWindowProcA`, and `PostQuitMessage`.
   - `gdi32.dll`: later add a small drawing subset such as `GetDC`, `ReleaseDC`, `CreateSolidBrush`, `SelectObject`, `DeleteObject`, `TextOutA`, and `BitBlt`.
   - Every function must have a defined prototype, calling convention, supported parameters, return behavior, and error behavior before implementation.

4. **Native backend**
   - Translate supported operations to KolibriOS system calls and KolibriX services.
   - Do not expose raw host pointers or kernel internals to untrusted PE programs.
   - Keep the native desktop and the Win32 compatibility environment separated by a documented boundary.

## Milestones

### W0 — ABI and test harness
- Document PE32 structures, i386 calling convention, import-name/ordinal rules, and supported relocation types.
- Create tiny test executables that exercise one feature at a time.
- Build a parser/validator test suite with valid and malformed fixtures.

### W1 — Console PE32
- Load a minimal i386 PE32 console program.
- Resolve a tiny `kernel32.dll` subset.
- Support process exit and basic standard input/output where the native backend permits.
- Verify with deterministic test programs; do not count merely parsing a PE file as execution support.

### W2 — Memory and files
- Add tested heap and virtual-memory calls.
- Add basic file open/read/write/close calls.
- Define handle lifetime and error mapping.

### W3 — Basic GUI
- Add a message queue and a small `user32.dll` window/message subset.
- Connect windows to the KolibriX compositor/window manager.
- Add basic `gdi32.dll` drawing only after the window/message lifecycle works.

### W4 — Compatibility expansion
- Add more APIs only in response to concrete test applications.
- Publish an application/API compatibility table.
- Consider PE32+ only after PE32 tests are stable.

## Security and correctness requirements

- Validate all PE offsets, lengths, section ranges, import tables, and relocations before use.
- Check integer overflow and out-of-bounds access.
- Reject unsupported machine types, DLL features, relocations, and subsystem types explicitly.
- Never execute untrusted input during parsing or validation.
- Keep tests for malformed files and boundary cases in CI.
- Do not report an application as supported unless it has actually launched and passed its test.

## Current status

**Specification only.** No PE loader or Win32 API function is claimed implemented by this document. The initial native KolibriX desktop and boot path remain separate work.
