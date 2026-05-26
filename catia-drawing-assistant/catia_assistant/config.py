from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import json


@dataclass
class DrawingConfig:
    product_name: str = "MiniDrone.CATProduct"
    output_dir: Path = Path("output")
    base_name: str = "MiniDrone"
    paper_size: str = "A3"
    standard: str = "ISO"


@dataclass
class ExplosionConfig:
    output_base_name: str = "MiniDrone_exploded_multiview"
    explosion_multiplier: float = 0.65


@dataclass
class DetailConfig:
    create_a1: bool = True
    create_detail_pages: bool = True


@dataclass
class AIConfig:
    provider: str = "deepseek"
    api_key: str = ""
    base_url: str = "https://api.deepseek.com"
    model: str = "deepseek-chat"


@dataclass
class AppConfig:
    drawing: DrawingConfig = field(default_factory=DrawingConfig)
    explosion: ExplosionConfig = field(default_factory=ExplosionConfig)
    detail: DetailConfig = field(default_factory=DetailConfig)
    ai: AIConfig = field(default_factory=AIConfig)

    @classmethod
    def from_json(cls, path: str | Path) -> "AppConfig":
        data = json.loads(Path(path).read_text(encoding="utf-8"))
        cfg = cls()
        for section_name in ("drawing", "explosion", "detail", "ai"):
            if section_name in data:
                section = getattr(cfg, section_name)
                for key, value in data[section_name].items():
                    if hasattr(section, key):
                        if key == "output_dir":
                            value = Path(value)
                        setattr(section, key, value)
        cfg.validate()
        return cfg

    def validate(self) -> None:
        if not self.drawing.product_name.lower().endswith(".catproduct"):
            raise ValueError("product_name must end with .CATProduct")
        if self.explosion.explosion_multiplier <= 0:
            raise ValueError("explosion_multiplier must be positive")
        if not self.drawing.base_name:
            raise ValueError("base_name is required")

    def output_dir(self) -> Path:
        return self.drawing.output_dir
