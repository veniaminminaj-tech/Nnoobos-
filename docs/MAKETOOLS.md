# MakeTools for Nnoobos

MakeTools is the planned built-in source/document editor for Nnoobos. It will create and edit plain-text files with a chosen filename and extension.

## Initial file types

- `.txt` — plain text
- `.js` — JavaScript source
- `.py` — Python source
- `.cpp` and `.c++` — C++ source
- `.c` — C source
- `.html` and `.css` — web files
- `.json` — JSON data
- `.exe` — executable file association (planned; Nnoobos-native NEX64 format only until a loader exists)
- `.nex` — Nnoobos-native executable format

## Planned interface

1. Open **MakeTools** from the Nnoobos applications menu.
2. Choose **New document** or **Open document**.
3. Enter a filename, or choose a template.
4. Edit text with the keyboard.
5. Save, Save As, or discard changes.
6. Show the current filename, extension, and unsaved-change indicator.
7. Manage file associations, including `.exe` and `.nex`, in the MakeTools association settings.

Templates are starter text only. The extension does not automatically make a language executable: JavaScript and Python runtimes, and a C/C++ compiler, are separate components.

## Implementation status and required OS foundations

The current Nnoobos kernel is an experimental x86-64 boot test. It reaches long mode, writes status text to VGA/COM1, and validates a NEX64 header in memory. It does not yet have an interactive keyboard driver, filesystem, persistent file writing, application loader, or process API.

Because of that, a genuinely built-in editor cannot safely save files yet. The next implementation stages are:

1. Add keyboard input and an interactive text screen.
2. Add a writable filesystem and file operations.
3. Build the MakeTools editor UI with a bounded text buffer and filename/extension selection.
4. Connect MakeTools to filesystem open/save operations.
5. Add application loading before attempting to run user-created native programs.
6. Register `.exe` and `.nex` with the future Nnoobos executable loader and show a clear error for unsupported formats.

**Executable compatibility note:** the `.exe` association is intended for Nnoobos-native NEX64 executables once the loader exists. Ordinary Windows `.exe` files (PE/MZ) are not supported by the current kernel and must not be presented as runnable.

Until those foundations exist, this document describes the intended feature; it does not claim that MakeTools is already runnable in the OS.
