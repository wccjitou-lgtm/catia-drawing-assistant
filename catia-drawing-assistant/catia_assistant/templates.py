from __future__ import annotations

from importlib.resources import files


def load_template(name: str) -> str:
    return (files("catia_assistant") / "templates" / name).read_text(encoding="utf-8")


def render_template(name: str, values: dict[str, object]) -> str:
    text = load_template(name)
    for key, value in values.items():
        text = text.replace(f"${key}$", str(value))
    unresolved = [part.split("$", 1)[0] for part in text.split("$")[1::2]]
    if unresolved:
        raise ValueError(f"Unresolved template placeholders: {unresolved}")
    return text
