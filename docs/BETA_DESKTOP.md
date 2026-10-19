# NedohackersOS Beta Desktop (host-side prototype)

This app is a safe user-space prototype for trying the desktop UI on Windows, Linux, or macOS. It is **not** running inside the BIOS/FASM kernel yet.

## Run on Windows

1. Install Python 3 from https://www.python.org/downloads/ and enable **Tcl/Tk** in the installer.
2. Download the repository ZIP and extract it.
3. Double-click `run_beta.bat`, or open a terminal in the project folder and run:

   ```bat
   py -3 desktop_beta.py
   ```

## Python IDE

- Write Python in the editor and press **Run**.
- **Open .py** and **Save .py** let you work with normal Python files.
- Output and errors appear below the editor.
- Each run has an 8-second timeout and runs in a temporary working directory.

**Important:** this is not a security sandbox. Python code runs locally with your Windows user permissions. Run only code you understand and trust; a timeout does not make untrusted code safe.

## Browser

For an embedded page view inside the app, install the optional dependency:

```bat
py -3 -m pip install -r requirements-beta.txt
```

Then restart the app. If TkinterWeb is unavailable or a page cannot be rendered, the Browser app can open the address in your normal system browser. Enter only normal `http://` or `https://` addresses.

## Icons and license

The desktop's icon references come from [Lucide](https://lucide.dev/icons/), an open-source SVG icon collection licensed under the [ISC License](https://github.com/lucide-icons/lucide/blob/main/LICENSE). The `assets/icons/` directory contains SVG references for code, globe, folder, info, and terminal. Emoji icons are retained as a cross-platform fallback in the current Tkinter UI.

## What this beta is — and isn't

- Included: desktop shell, Start menu, Python editor/run/output, open/save Python files, browser launcher, folder picker, and clock.
- Not included in the bare-metal kernel yet: a CPython runtime, full filesystem, network stack, or a native browser engine.
- No virus or destructive system actions are included.
