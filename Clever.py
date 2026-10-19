"""
Clever — безпечна графічна демонстрація для Windows.
Потрібен Python 3; tkinter входить до стандартної бібліотеки.
Нічого не змінює на диску й не запускається автоматично.
"""
import tkinter as tk
from tkinter import messagebox

BG = "#10131c"
PANEL = "#1b2230"
CYAN = "#53e0d0"
WHITE = "#edf3ff"
RED = "#ff5263"


class CleverApp:
    def __init__(self, root):
        self.root = root
        root.title("Clever • NedohackersOS Demo")
        root.geometry("620x440")
        root.minsize(520, 380)
        root.configure(bg=BG)

        tk.Label(root, text="CLEVER", bg=BG, fg=CYAN,
                 font=("Segoe UI", 28, "bold")).pack(pady=(24, 2))
        tk.Label(root, text="СИМУЛЯТОР СИСТЕМНОГО ІНЦИДЕНТУ",
                 bg=BG, fg=WHITE, font=("Segoe UI", 11, "bold")).pack()
        tk.Label(root, text="Демонстрація інтерфейсу — не справжній вірус",
                 bg=BG, fg="#aab6cc", font=("Segoe UI", 10)).pack(pady=(8, 18))

        panel = tk.Frame(root, bg=PANEL, padx=22, pady=18)
        panel.pack(fill="x", padx=28)
        tk.Label(panel, text="Модуль Clever готовий", bg=PANEL, fg=WHITE,
                 font=("Segoe UI", 13, "bold")).pack(anchor="w")
        tk.Label(panel, text="Запусти візуальний ефект у тестовому вікні.\n"
                             "Закрити його можна кнопкою або клавішею Esc.",
                 justify="left", bg=PANEL, fg="#aab6cc",
                 font=("Segoe UI", 10)).pack(anchor="w", pady=(8, 0))

        tk.Button(root, text="▶  Запустити демонстрацію", command=self.show_demo,
                  bg=CYAN, fg=BG, activebackground="#8af3e7",
                  relief="flat", padx=18, pady=11,
                  font=("Segoe UI", 11, "bold"), cursor="hand2").pack(pady=20)
        tk.Button(root, text="Про програму", command=self.about,
                  bg=PANEL, fg=WHITE, activebackground="#293448",
                  relief="flat", padx=14, pady=8,
                  font=("Segoe UI", 10), cursor="hand2").pack()
        tk.Label(root, text="SAFE DEMO  •  NO FILE CHANGES",
                 bg=BG, fg="#75839b", font=("Consolas", 9)).pack(side="bottom", pady=14)

    def show_demo(self):
        win = tk.Toplevel(self.root)
        win.title("Clever — тестова помилка")
        win.geometry("600x360")
        win.configure(bg="#080a0f")
        win.transient(self.root)
        win.bind("<Escape>", lambda _event: win.destroy())

        tk.Label(win, text=":( ", bg="#080a0f", fg=WHITE,
                 font=("Segoe UI", 42, "bold")).pack(pady=(22, 0))
        tk.Label(win, text="CLEVER SYSTEM ALERT", bg="#080a0f", fg=RED,
                 font=("Consolas", 20, "bold")).pack(pady=5)
        tk.Label(win, text="Це лише демонстрація. Справжньої помилки немає.",
                 bg="#080a0f", fg=WHITE, font=("Segoe UI", 11)).pack(pady=9)
        tk.Label(win, text="DEMO CODE: CLEVER_0001\nЖодні файли або налаштування не змінено.",
                 bg="#080a0f", fg="#aab6cc", font=("Consolas", 10),
                 justify="center").pack(pady=5)
        tk.Button(win, text="Закрити демонстрацію", command=win.destroy,
                  bg=RED, fg=WHITE, relief="flat", padx=18, pady=9,
                  font=("Segoe UI", 10, "bold"), cursor="hand2").pack(pady=18)

    def about(self):
        messagebox.showinfo("Про Clever",
                            "Clever — навчальна GUI-симуляція на tkinter.\n"
                            "Не сканує диск, не блокує Windows і не змінює файли.")


if __name__ == "__main__":
    root = tk.Tk()
    CleverApp(root)
    root.mainloop()
