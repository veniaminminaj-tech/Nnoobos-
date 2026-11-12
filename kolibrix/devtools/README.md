# KolibriX programming languages

KolibriX will provide a programming workspace for native applications. The first target languages are C, C++, and C#. FASM remains the language used for the current low-level desktop and boot integration.

## Current status

This folder contains starter source examples, the language integration plan, and the KolibriX Code Studio configuration. The 0.5 ISO uses the existing upstream KolibriOS CEdit program as its initial code editor; this is not a newly written VS Code clone. The ISO does not yet bundle the C/C++ compilers or a C# runtime.

| Language | Planned compiler/runtime | Target status |
|---|---|---|
| C | KolibriOS-compatible GCC toolchain (kos32-gcc) or a verified native TCC build | Planned; upstream KolibriOS has existing C toolchain support |
| C++ | KolibriOS-compatible GCC toolchain (kos32-g++ / kos32-gcc with C++ mode), C++ runtime and linker | Planned; must verify ABI and library availability |
| C# | C# compiler plus a managed runtime/IL execution layer ported to x86 KolibriOS | Research stage; no runtime is included |

## C and C++ integration plan

KolibriOS has an established C/C++ development path. The KolibriOS SDK/toolchain is the starting point rather than inventing a new compiler. The eventual KolibriX build environment must:

1. Pin and build or download a reproducible x86 KolibriOS cross-toolchain.
2. Provide the matching headers, startup objects, linker scripts, libraries, and packer.
3. Compile .c and .cpp sources into native KolibriOS executables.
4. Include a small KolibriX API wrapper and documented examples.
5. Run the produced programs in QEMU and verify window creation, input, and exit behavior.

The SDK must be integrated and licensed correctly; it must not be copied into the ISO without checking its license and size.

## C# integration plan

C# is a managed language. A compiler alone cannot make a program run: KolibriX also needs a compatible runtime for .NET Intermediate Language (IL), garbage collection, exceptions, threading, and the required system APIs.

The C# work is staged:

1. Evaluate whether a small Mono-based runtime can be ported to the 32-bit KolibriOS environment.
2. Define the minimal OS services and C ABI bridge required by that runtime.
3. Start with a console-style Hello World test, then add file I/O and basic GUI bindings.
4. Publish a compatibility matrix for supported C# language/runtime features.

Until those tests pass, .cs files are source examples only. A Windows .exe produced by a normal .NET compiler is not automatically executable on KolibriX.

## Code editor integration

KolibriX launches the existing upstream KolibriOS CEdit application from the desktop under the KolibriX name **Code Studio**. Its configuration is stored at `kolibrix/config/CEDIT.INI` and is installed as `/SETTINGS/CEDIT.INI` by the ISO workflow. The configuration selects a dark editor theme and defines syntax rules for C, C++, C#, FASM, and the other upstream language profiles. CEdit supplies the actual editing, tabs, file handling, and editor features; the KolibriX integration supplies the desktop entry point and language configuration. Preserve the upstream CEdit license and attribution.

The current integration does not add a VS Code-style project explorer, integrated terminal, extensions marketplace, IntelliSense/LSP, or debugger. Those remain future KolibriX development tasks.

## Source examples

- C example: examples/c/hello.c
- C++ example: examples/cpp/hello.cpp
- C# example: examples/csharp/Hello.cs

## References

- https://wiki.kolibrios.org/wiki/Development
- https://github.com/KolibriOS/kolibrios-sdk
- https://github.com/KolibriOS/kolibrios/blob/main/build.txt

KolibriOS-derived SDK components retain their upstream licenses and notices. KolibriX-specific integration code must be clearly distinguished from upstream work.