"""NedohackersOS Beta Desktop — safe, user-space prototype.

This is a desktop prototype that runs on Windows/Linux/macOS; it is not yet a
bare-metal app inside the BIOS kernel. Python code execution is a normal local
subprocess, NOT a security sandbox. Only run code you trust.
"""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import tkinter as tk
import webbrowser
from tkinter import messagebox, ttk
from urllib.parse import urlparse

APP_NAME = "NedohackersOS Beta"
BG = "#101827"
PANEL = "#182438"
PANEL_2 = "#22324a"
TEXT = "#eef4ff"
MUTED = "#9fb0c9"
ACCENT = "#61a5ff"
GREEN = "#58d6a3"


class BetaDesktop(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(APP_NAME)
        self.geometry("1100x700")
        self.minsize(820, 540)
        self.configure(bg=BG)
        self._style()
        self._build_desktop()

    def _style(self):
        style = ttk.Style(self)
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass
        style.configure("TFrame", background=BG)
        style.configure("Panel.TFrame", background=PANEL)
        style.configure("TLabel", background=BG, foreground=TEXT, font=("Segoe UI", 10))
        style.configure("Panel.TLabel", background=PANEL, foreground=TEXT, font=("Segoe UI", 10))
        style.configure("Muted.TLabel", background=BG, foreground=MUTED, font=("Segoe UI", 9))
        style.configure("TButton", font=("Segoe UI", 10), padding=(12, 8))
        style.configure("Accent.TButton", background=ACCENT, foreground="#07111f")
        style.map("Accent.TButton", background=[("active", "#8bbdff")])

    def _build_desktop(self):
        header = tk.Frame(self, bg="#0b1220", height=48)
        header.pack(fill="x")
        header.pack_propagate(False)
        tk.Label(header, text="◈  NEDOHACKERS OS", bg="#0b1220", fg=TEXT,
                 font=("Segoe UI Semibold", 12)).pack(side="left", padx=18)
        tk.Label(header, text="BETA 0.2  •  DESKTOP PROTOTYPE", bg="#0b1220", fg=GREEN,
                 font=("Segoe UI", 9)).pack(side="right", padx=18)

        body = tk.Frame(self, bg=BG)
        body.pack(fill="both", expand=True)
        tk.Label(body, text="Your workspace.", bg=BG, fg=TEXT,
                 font=("Segoe UI Semibold", 25)).pack(anchor="w", padx=32, pady=(32, 3))
        tk.Label(body, text="A safe first look at the NedohackersOS desktop.",
                 bg=BG, fg=MUTED, font=("Segoe UI", 11)).pack(anchor="w", padx=34, pady=(0, 22))

        cards = tk.Frame(body, bg=BG)
        cards.pack(anchor="w", padx=26)
        self._app_card(cards, "🐍", "Python IDE", "Write and run Python", self.open_ide, 0, 0)
        self._app_card(cards, "🌐", "Browser", "Browse the web", self.open_browser, 1, 0)
        self._app_card(cards, "📁", "Files", "Open a folder", self.open_files, 2, 0)
        self._app_card(cards, "ℹ️", "About Beta", "What works today", self.open_about, 3, 0)

        note = tk.Frame(body, bg=PANEL, highlightbackground="#2b3c56", highlightthickness=1)
        note.pack(fill="x", padx=32, pady=(30, 0))
        tk.Label(note, text="BETA NOTE", bg=PANEL, fg=ACCENT,
                 font=("Segoe UI Semibold", 9)).pack(anchor="w", padx=18, pady=(14, 4))
        tk.Label(note, text="This is a user-space desktop prototype. The current bare-metal kernel does not yet have a network stack, filesystem, or CPython runtime.",
                 bg=PANEL, fg=TEXT, wraplength=900, justify="left",
                 font=("Segoe UI", 10)).pack(anchor="w", padx=18, pady=(0, 14))

        taskbar = tk.Frame(self, bg="#0b1220", height=46)
        taskbar.pack(side="bottom", fill="x")
        taskbar.pack_propagate(False)
        tk.Button(taskbar, text="◈  Start", command=self._start_menu,
                  bg="#1b2b43", fg=TEXT, activebackground=PANEL_2,
                  activeforeground=TEXT, relief="flat", padx=16).pack(side="left", padx=8, pady=7)
        tk.Label(taskbar, text="Prototype mode • no system settings changed by the desktop app",
                 bg="#0b1220", fg=MUTED, font=("Segoe UI", 9)).pack(side="left", padx=10)
        self.clock = tk.Label(taskbar, text="", bg="#0b1220", fg=TEXT, font=("Segoe UI", 9))
        self.clock.pack(side="right", padx=18)
        self._tick_clock()

    def _tick_clock(self):
        from datetime import datetime
        self.clock.config(text=datetime.now().strftime("%H:%M  •  %d.%m.%Y"))
        self.after(1000, self._tick_clock)

    def _app_card(self, parent, emoji, title, subtitle, command, column, row):
        card = tk.Frame(parent, bg=PANEL, width=190, height=148,
                        highlightbackground="#2b3c56", highlightthickness=1)
        card.grid(row=row, column=column, padx=7, pady=7, sticky="n")
        card.pack_propagate(False)
        tk.Button(card, text=emoji, command=command, bg=PANEL, fg=TEXT,
                  activebackground=PANEL_2, activeforeground=TEXT,
                  font=("Segoe UI Emoji", 27), relief="flat", bd=0).pack(pady=(14, 0))
        tk.Button(card, text=title, command=command, bg=PANEL, fg=TEXT,
                  activebackground=PANEL_2, activeforeground=TEXT,
                  font=("Segoe UI Semibold", 11), relief="flat", bd=0).pack(pady=(3, 0))
        tk.Label(card, text=subtitle, bg=PANEL, fg=MUTED,
                 font=("Segoe UI", 8)).pack(pady=(2, 0))

    def _start_menu(self):
        win = tk.Toplevel(self)
        win.title("Start")
        win.configure(bg=PANEL)
        win.geometry(f"260x250+20+{max(70, self.winfo_rooty()+self.winfo_height()-330)}")
        tk.Label(win, text="NedohackersOS", bg=PANEL, fg=TEXT,
                 font=("Segoe UI Semibold", 14)).pack(anchor="w", padx=16, pady=14)
        for label, action in (("🐍  Python IDE", self.open_ide),
                              ("🌐  Browser", self.open_browser),
                              ("📁  Files", self.open_files),
                              ("ℹ️  About", self.open_about)):
            tk.Button(win, text=label, command=lambda a=action: (win.destroy(), a()),
                      bg=PANEL_2, fg=TEXT, activebackground="#304563",
                      activeforeground=TEXT, relief="flat", anchor="w",
                      padx=12).pack(fill="x", padx=12, pady=3)

    def open_ide(self):
        win = tk.Toplevel(self)
        win.title("Python IDE — NedohackersOS Beta")
        win.geometry("900x620")
        win.configure(bg=BG)
        top = tk.Frame(win, bg=PANEL)
        top.pack(fill="x")
        tk.Label(top, text="🐍  Python IDE", bg=PANEL, fg=TEXT,
                 font=("Segoe UI Semibold", 13)).pack(side="left", padx=14, pady=12)
        tk.Label(top, text="Runs with the Python installed on this computer",
                 bg=PANEL, fg=MUTED, font=("Segoe UI", 9)).pack(side="right", padx=14)

        warning = tk.Label(win, text="Safety: code runs locally with your user permissions. This is not a sandbox; only run code you trust.",
                           bg="#3b2b19", fg="#ffd9a1", anchor="w", padx=10, pady=7,
                           wraplength=850, justify="left")
        warning.pack(fill="x", padx=12, pady=(12, 6))

        editor = tk.Text(win, bg="#0b1220", fg="#dce8ff", insertbackground=TEXT,
                         font=("Consolas", 11), undo=True, wrap="none",
                         padx=12, pady=10, relief="flat")
        editor.pack(fill="both", expand=True, padx=12, pady=4)
        editor.insert("1.0", 'print("Hello from NedohackersOS Beta!")\nfor i in range(3):\n    print("Python works:", i + 1)\n')

        controls = tk.Frame(win, bg=BG)
        controls.pack(fill="x", padx=12, pady=6)
        output = tk.Text(win, height=8, bg="#080d16", fg="#a7f3d0",
                         insertbackground=TEXT, font=("Consolas", 10),
                         relief="flat", padx=10, pady=8)
        output.pack(fill="x", padx=12, pady=(0, 12))
        output.insert("1.0", "Output will appear here.\n")
        output.configure(state="disabled")

        def set_output(text):
            output.configure(state="normal")
            output.delete("1.0", "end")
            output.insert("1.0", text)
            output.configure(state="disabled")

        def run_code():
            source = editor.get("1.0", "end-1c")
            set_output("Running Python…")
            try:
                with tempfile.TemporaryDirectory(prefix="nedo_beta_") as workdir:
                    result = subprocess.run(
                        [sys.executable, "-I", "-c", source],
                        cwd=workdir, capture_output=True, text=True,
                        timeout=8, check=False
                    )
                combined = result.stdout
                if result.stderr:
                    combined += ("\n" if combined else "") + result.stderr
                if not combined:
                    combined = f"Finished with exit code {result.returncode} (no output)."
                set_output(combined[:20000])
            except subprocess.TimeoutExpired:
                set_output("Stopped: execution exceeded the 8-second limit.")
            except Exception as exc:
                set_output(f"Could not start Python: {exc}")

        ttk.Button(controls, text="▶ Run", style="Accent.TButton",
                   command=run_code).pack(side="left")
        ttk.Button(controls, text="Clear output",
                   command=lambda: set_output("")).pack(side="left", padx=8)
        tk.Label(controls, text=f"Interpreter: {sys.executable}",
                 bg=BG, fg=MUTED, font=("Segoe UI", 8)).pack(side="right")

    def open_browser(self):
        win = tk.Toplevel(self)
        win.title("Browser — NedohackersOS Beta")
        win.geometry("950x650")
        win.configure(bg=BG)
        toolbar = tk.Frame(win, bg=PANEL)
        toolbar.pack(fill="x")
        tk.Label(toolbar, text="🌐", bg=PANEL, fg=TEXT,
                 font=("Segoe UI Emoji", 16)).pack(side="left", padx=(12, 6), pady=8)
        address = tk.Entry(toolbar, bg="#0b1220", fg=TEXT, insertbackground=TEXT,
                           relief="flat", font=("Segoe UI", 11))
        address.pack(side="left", fill="x", expand=True, padx=4, pady=8, ipady=6)
        address.insert(0, "https://example.com")
        status = tk.Label(win, text="", bg=BG, fg=MUTED, anchor="w", padx=12)
        status.pack(fill="x", side="bottom", pady=6)
        view = tk.Frame(win, bg="#ffffff")
        view.pack(fill="both", expand=True, padx=10, pady=10)

        browser = None
        try:
            from tkinterweb import HtmlFrame
            browser = HtmlFrame(view, messages_enabled=False)
            browser.pack(fill="both", expand=True)
            status.config(text="Embedded browser powered by TkinterWeb.")
        except ImportError:
            tk.Label(view, text="Embedded view needs the optional TkinterWeb package.\nYou can still open any address in your normal browser.",
                     bg="#ffffff", fg="#1f2937", font=("Segoe UI", 13),
                     justify="center").pack(expand=True)
            status.config(text="Fallback mode: Go opens your default system browser.")

        def navigate(event=None):
            url = address.get().strip()
            if not url:
                return
            if "://" not in url:
                url = "https://" + url
            parsed = urlparse(url)
            if parsed.scheme not in ("http", "https") or not parsed.netloc:
                messagebox.showerror("Invalid address", "Enter a valid http:// or https:// web address.", parent=win)
                return
            address.delete(0, "end")
            address.insert(0, url)
            if browser is not None:
                try:
                    browser.load_website(url)
                    status.config(text=f"Loading {url}")
                except Exception as exc:
                    status.config(text=f"Could not load page: {exc}")
            else:
                try:
                    webbrowser.open(url, new=2)
                    status.config(text="Opened in the system browser.")
                except Exception as exc:
                    status.config(text=f"Could not open browser: {exc}")

        ttk.Button(toolbar, text="Go", style="Accent.TButton", command=navigate).pack(side="right", padx=10, pady=7)
        address.bind("<Return>", navigate)

    def open_files(self):
        from tkinter import filedialog
        path = filedialog.askdirectory(title="Choose a folder to open")
        if path:
            messagebox.showinfo("Selected folder", path, parent=self)

    def open_about(self):
        messagebox.showinfo(
            "About NedohackersOS Beta",
            "NedohackersOS Beta 0.2\n\n"
            "Working in this desktop prototype:\n"
            "• Python editor with Run and output\n"
            "• Browser window (embedded with optional TkinterWeb, otherwise opens system browser)\n"
            "• Start menu, desktop shortcuts, folder picker\n\n"
            "This is not yet a native bare-metal kernel feature. "
            "The current kernel does not have a full filesystem, network stack, or CPython runtime.",
            parent=self,
        )


if __name__ == "__main__":
    BetaDesktop().mainloop()
