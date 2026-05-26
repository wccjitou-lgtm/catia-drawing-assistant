from __future__ import annotations

import json
import urllib.request

from .config import AIConfig


def build_suggestion_prompt(product_summary: str) -> str:
    return (
        "You are assisting CATIA drawing automation. Return only JSON with keys "
        "explosion_notes, view_notes, and risks. Do not control CATIA directly.\n\n"
        f"Product summary:\n{product_summary}"
    )


def request_deepseek_suggestion(config: AIConfig, product_summary: str) -> dict:
    if not config.api_key:
        raise ValueError("DeepSeek API key is required")
    payload = {
        "model": config.model,
        "messages": [
            {"role": "system", "content": "Return valid JSON only."},
            {"role": "user", "content": build_suggestion_prompt(product_summary)},
        ],
        "temperature": 0.2,
    }
    request = urllib.request.Request(
        config.base_url.rstrip("/") + "/chat/completions",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {config.api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        data = json.loads(response.read().decode("utf-8"))
    content = data["choices"][0]["message"]["content"]
    return parse_json_object(content)


def parse_json_object(text: str) -> dict:
    text = text.strip()
    if text.startswith("```"):
        text = text.strip("`")
        if text.lower().startswith("json"):
            text = text[4:].strip()
    start = text.find("{")
    end = text.rfind("}")
    if start == -1 or end == -1 or end < start:
        raise ValueError("AI response did not contain a JSON object")
    data = json.loads(text[start : end + 1])
    if not isinstance(data, dict):
        raise ValueError("AI response JSON must be an object")
    return data
