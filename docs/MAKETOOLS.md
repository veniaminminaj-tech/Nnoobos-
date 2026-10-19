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

## Planned interface

1. Open **MakeTools** from the Nnoobos applications menu.
2. Choose **New document** or **Open document**.
3. Enter a filename, or choose a template.
4. Edit text with the keyboard.
5. Save, Save As, or discard changes.
6. Show the current filename, extension, and unsaved-change indicator.

Templates are starter text only. The extension does not automatically make a language executable: JavaScript and Python runtimes, and a C/C++ compiler, are separate components.

## Implementation status and required OS foundations

The current Nnoobos kernel is an experimental x86-64 boot test. It reaches long mode, writes status text to VGA/COM1, and validates a NEX64 header in memory. It does not yet have an interactive keyboard driver, filesystem, persistent file writing, application loader, or process API.

Because of that, a genuinely built-in editor cannot safely save files yet. The next implementation stages are:

1. Add keyboard input and an interactive text screen.
2. Add a writable filesystem and file operations.
3. Build the MakeTools editor UI with a bounded text buffer and filename/extension selection.
4. Connect MakeTools to filesystem open/save operations.
5. Add application loading before attempting to run user-created native programs.

Until those foundations exist, this document describes the intended feature; it does not claim that MakeTools is already runnable in the OS.
