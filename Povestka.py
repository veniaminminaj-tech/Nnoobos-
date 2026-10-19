"""
Повестка — безпечний жартівливий GUI-симулятор для Windows.
Потрібен Python 3; tkinter входить до стандартної бібліотеки.
"""
import tkinter as tk
from tkinter import messagebox

BG = "#171018"
CARD = "#271923"
GOLD = "#ffc857"
WHITE = "#fff4e6"


class PovestkaApp:
    def __init__(self, root):
        self.root = root
        root.title("ПОВЕСТКА • Prank Demo")
        root.geometry("600x470")
        root.minsize(500, 400)
        root.configure(bg=BG)

        tk.Label(root, text="⚠  ПОВЕСТКА", bg=BG, fg=GOLD,
                 font=("Segoe UI", 28, "bold")).pack(pady=(24, 4))
        tk.Label(root, text="ЖАРТІВЛИВЕ ПОПЕРЕДЖЕННЯ • DEMO MODE",
                 bg=BG, fg=WHITE, font=("Segoe UI", 10, "bold")).pack()

        card = tk.Frame(root, bg=CARD, padx=22, pady=18,
                        highlightthickness=1, highlightbackground="#704455")
        card.pack(fill="both", expand=True, padx=28, pady=20)
        tk.Label(card, text="УВАГА! ВИЯВЛЕНО ПОВІДОМЛЕННЯ",
                 bg=CARD, fg=GOLD, font=("Segoe UI", 13, "bold")).pack(anchor="w")
        tk.Label(card, text="Це постановочне вікно для розваги.\n"
                            "Жодних реальних повісток не створено.\n"
                            "Програма не надсилає повідомлень і не збирає дані.",
                 bg=CARD, fg=WHITE, justify="left",
                 font=("Segoe UI", 10), wraplength=470).pack(anchor="w", pady=14)

        self.status = tk.Label(card, text="СТАТУС: ДЕМО ГОТОВЕ",
                               bg=CARD, fg="#7ee0a1",
                               font=("Consolas", 10, "bold"))
        self.status.pack(anchor="w", pady=(2, 12))

        buttons = tk.Frame(card, bg=CARD)
        buttons.pack(fill="x")
        tk.Button(buttons, text="Перевірити статус", command=self.check_status,
                  bg=GOLD, fg=BG, relief="flat", padx=12, pady=9,
                  font=("Segoe UI", 10, "bold"), cursor="hand2").pack(side="left")
        tk.Button(buttons, text="Закрити", command=root.destroy,
                  bg="#49303c", fg=WHITE, relief="flat", padx=18, pady=9,
                  font=("Segoe UI", 10), cursor="hand2").pack(side="right")

        tk.Label(root, text="Povestka.py  |  Безпечна локальна демонстрація",
                 bg=BG, fg="#b9a7b1", font=("Segoe UI", 9)).pack(pady=(0, 14))

    def check_status(self):
        self.status.config(text="СТАТУС: ЦЕ ЛИШЕ ЖАРТ", fg=GOLD)
        messagebox.showinfo("Перевірка",
                            "Демо завершено успішно.\n"
                            "Ця програма не має доступу до системних функцій.")


if __name__ == "__main__":
    root = tk.Tk()
    PovestkaApp(root)
    root.mainloop()
