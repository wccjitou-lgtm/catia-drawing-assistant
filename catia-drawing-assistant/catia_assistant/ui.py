from __future__ import annotations

from pathlib import Path
import threading
import tkinter as tk
from tkinter import filedialog, messagebox, scrolledtext

from .config import AppConfig
from .workflows import WorkflowService


class App(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("CATIA Drawing Assistant / CATIA 工程图助手")
        self.geometry("920x580")

        self.product_var = tk.StringVar(value="")
        self.base_var = tk.StringVar(value="MiniDrone")
        self.output_var = tk.StringVar(value="output")
        self.explosion_scale_var = tk.StringVar(value="0.65")

        self._build()

    def _build(self) -> None:
        form = tk.Frame(self, padx=12, pady=12)
        form.pack(fill=tk.X)

        self._row(form, 0, "CATIA 文件", self.product_var, state="readonly")
        tk.Button(form, text="选择 CATIA 文件", command=self._choose_product).grid(row=0, column=2, padx=6)

        self._row(form, 1, "输出前缀", self.base_var)
        self._row(form, 2, "输出目录", self.output_var)
        tk.Button(form, text="选择目录", command=self._choose_dir).grid(row=2, column=2, padx=6)

        self._row(form, 3, "爆炸比例", self.explosion_scale_var)

        buttons = tk.Frame(self, padx=12)
        buttons.pack(fill=tk.X)
        for label, command in [
            ("检测 CATIA", "status"),
            ("原版多视图", "views"),
            ("爆炸多视图", "explode"),
            ("A1 细节图", "detail-a1"),
            ("分页细节 PDF", "detail-pages"),
            ("全部生成", "all"),
        ]:
            tk.Button(buttons, text=label, command=lambda c=command: self._run(c)).pack(side=tk.LEFT, padx=4)

        self.log = scrolledtext.ScrolledText(self, height=24)
        self.log.pack(fill=tk.BOTH, expand=True, padx=12, pady=12)
        self._append("请选择 .CATProduct 文件，然后点击生成按钮。\n")

    def _row(self, parent: tk.Frame, row: int, label: str, variable: tk.StringVar, state: str = "normal") -> None:
        tk.Label(parent, text=label, width=12, anchor="e").grid(row=row, column=0, pady=4)
        tk.Entry(parent, textvariable=variable, width=72, state=state).grid(row=row, column=1, sticky="we", pady=4)
        parent.columnconfigure(1, weight=1)

    def _choose_product(self) -> None:
        selected = filedialog.askopenfilename(
            title="选择 CATIA 产品文件",
            filetypes=[
                ("CATIA Product", "*.CATProduct"),
                ("All files", "*.*"),
            ],
        )
        if selected:
            path = Path(selected)
            self.product_var.set(str(path))
            if not self.base_var.get().strip() or self.base_var.get().strip() == "MiniDrone":
                self.base_var.set(path.stem)

    def _choose_dir(self) -> None:
        selected = filedialog.askdirectory(title="选择输出目录")
        if selected:
            self.output_var.set(selected)

    def _config(self, require_product: bool = True) -> AppConfig:
        cfg = AppConfig()
        product_name = self.product_var.get().strip()
        if require_product and not product_name:
            raise ValueError("请先点击“选择 CATIA 文件”，选择一个 .CATProduct 文件。")
        cfg.drawing.product_name = product_name or "MiniDrone.CATProduct"
        cfg.drawing.base_name = self.base_var.get().strip()
        cfg.drawing.output_dir = Path(self.output_var.get().strip())
        cfg.explosion.output_base_name = f"{cfg.drawing.base_name}_exploded_multiview"
        cfg.explosion.explosion_multiplier = float(self.explosion_scale_var.get().strip())
        cfg.validate()
        return cfg

    def _run(self, command: str) -> None:
        def work() -> None:
            try:
                service = WorkflowService(self._config(require_product=command != "status"), Path.cwd())
                if command == "status":
                    results = [service.status()]
                elif command == "views":
                    results = [service.views()]
                elif command == "explode":
                    results = [service.exploded()]
                elif command == "detail-a1":
                    results = [service.detail_a1()]
                elif command == "detail-pages":
                    results = [service.detail_pages()]
                else:
                    results = service.all()
                for result in results:
                    self._append(result.stdout)
                    if result.stderr:
                        self._append(result.stderr)
            except Exception as exc:
                messagebox.showerror("运行失败", str(exc))

        self._append(f"\n>>> {command}\n")
        threading.Thread(target=work, daemon=True).start()

    def _append(self, text: str) -> None:
        self.log.insert(tk.END, text)
        self.log.see(tk.END)


def main() -> None:
    App().mainloop()


if __name__ == "__main__":
    main()
