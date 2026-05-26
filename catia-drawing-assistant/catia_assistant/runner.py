from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import json
import subprocess
import tempfile
from datetime import datetime


@dataclass
class ScriptResult:
    returncode: int
    stdout: str
    stderr: str
    ok_paths: list[Path]

    @property
    def succeeded(self) -> bool:
        return self.returncode == 0


class ScriptRunner:
    def __init__(self, work_dir: Path | str = ".") -> None:
        self.work_dir = Path(work_dir)

    def run_script_text(self, script_text: str, stem: str) -> ScriptResult:
        run_dir = self.work_dir / "tmp" / "catia_assistant_runs"
        run_dir.mkdir(parents=True, exist_ok=True)
        script_path = run_dir / f"{stem}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.vbs"
        script_path.write_text(script_text, encoding="utf-16")

        proc = subprocess.run(
            ["cscript", "//nologo", str(script_path)],
            cwd=str(self.work_dir),
            capture_output=True,
            text=True,
            timeout=300,
        )
        returncode = proc.returncode
        if returncode == 0 and (proc.stderr.strip() or "ERROR:" in proc.stdout):
            returncode = 1
        ok_paths = parse_ok_paths(proc.stdout)
        return ScriptResult(returncode, proc.stdout, proc.stderr, ok_paths)

    def write_log(self, name: str, result: ScriptResult, output_dir: Path) -> Path:
        log_dir = output_dir / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        path = log_dir / f"{name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        payload = {
            "returncode": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "ok_paths": [str(p) for p in result.ok_paths],
        }
        path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
        return path


def parse_ok_paths(stdout: str) -> list[Path]:
    paths: list[Path] = []
    for line in stdout.splitlines():
        line = line.strip()
        if line.startswith("OK:"):
            paths.append(Path(line[3:].strip()))
    return paths
