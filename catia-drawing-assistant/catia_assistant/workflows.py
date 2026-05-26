from __future__ import annotations

from pathlib import Path

from .config import AppConfig
from .runner import ScriptResult, ScriptRunner
from .templates import render_template


VIEW_ORDER = [
    "Front_view",
    "Left_view",
    "Right_view",
    "Top_view",
    "Bottom_view",
    "Rear_view",
    "Isometric_view",
]


class WorkflowService:
    def __init__(self, config: AppConfig, work_dir: Path | str = ".") -> None:
        self.config = config
        self.work_dir = Path(work_dir)
        self.runner = ScriptRunner(self.work_dir)
        self.output_dir = self.work_dir / self.config.output_dir()
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def status(self) -> ScriptResult:
        result = self.runner.run_script_text(render_template("status.vbs", {}), "status")
        self.runner.write_log("status", result, self.output_dir)
        return result

    def views(self) -> ScriptResult:
        result = self.runner.run_script_text(
            render_template("views.vbs", {"PRODUCT_NAME": self.config.drawing.product_name}),
            "views",
        )
        self.runner.write_log("views", result, self.output_dir)
        return result

    def exploded(self) -> ScriptResult:
        result = self.runner.run_script_text(
            render_template(
                "exploded.vbs",
                {
                    "PRODUCT_NAME": self.config.drawing.product_name,
                    "EXPLODED_BASE_NAME": self.config.explosion.output_base_name,
                    "EXPLOSION_SCALE": self.config.explosion.explosion_multiplier,
                },
            ),
            "exploded",
        )
        self.runner.write_log("exploded", result, self.output_dir)
        return result

    def detail_pages(self) -> ScriptResult:
        result = self.runner.run_script_text(
            render_template(
                "detail_pages.vbs",
                {
                    "PRODUCT_NAME": self.config.drawing.product_name,
                    "BASE_NAME": self.config.drawing.base_name,
                    "EXPLOSION_SCALE": self.config.explosion.explosion_multiplier,
                },
            ),
            "detail_pages",
        )
        self._merge_detail_pdfs(f"{self.config.drawing.base_name}_detail_pages")
        self._merge_detail_pdfs(f"{self.config.drawing.base_name}_exploded_detail_pages")
        self.runner.write_log("detail_pages", result, self.output_dir)
        return result

    def detail_a1(self) -> ScriptResult:
        result = self.runner.run_script_text(
            render_template(
                "detail_a1.vbs",
                {
                    "PRODUCT_NAME": self.config.drawing.product_name,
                    "BASE_NAME": self.config.drawing.base_name,
                    "EXPLOSION_SCALE": self.config.explosion.explosion_multiplier,
                },
            ),
            "detail_a1",
        )
        self.runner.write_log("detail_a1", result, self.output_dir)
        return result

    def all(self) -> list[ScriptResult]:
        return [self.views(), self.exploded(), self.detail_a1(), self.detail_pages()]

    def _merge_detail_pdfs(self, prefix: str) -> Path:
        from pypdf import PdfReader, PdfWriter

        writer = PdfWriter()
        for suffix in VIEW_ORDER:
            path = self.output_dir / f"{prefix}_{suffix}.pdf"
            if not path.exists():
                continue
            reader = PdfReader(str(path))
            writer.add_page(reader.pages[0])
        output = self.output_dir / f"{prefix}.pdf"
        if len(writer.pages) > 0:
            with output.open("wb") as handle:
                writer.write(handle)
        return output
