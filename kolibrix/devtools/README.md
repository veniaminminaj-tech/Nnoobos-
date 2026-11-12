# KolibriX programming languages

KolibriX will provide a programming workspace for native applications. The first target languages are C, C++, and C#. FASM remains the language used for the current low-level desktop and boot integration.

## Current status

This folder currently contains starter source examples and the integration plan. It does **not** yet contain bundled compilers, a C# runtime, or a working IDE. Do not advertise these languages as installed or executable in the 0.5 ISO.

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

## Source examples

- C example: examples/c/hello.c
- C++ example: examples/cpp/hello.cpp
- C# example: examples/csharp/Hello.cs

## References

- https://wiki.kolibrios.org/wiki/Development
- https://github.com/KolibriOS/kolibrios-sdk
- https://github.com/KolibriOS/kolibrios/blob/main/build.txt

KolibriOS-derived SDK components retain their upstream licenses and notices. KolibriX-specific integration code must be clearly distinguished from upstream work.