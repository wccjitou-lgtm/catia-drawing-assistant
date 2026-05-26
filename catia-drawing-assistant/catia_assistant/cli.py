from __future__ import annotations

import argparse
from pathlib import Path
import sys

from .config import AppConfig
from .workflows import WorkflowService


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="catia-assistant")
    parser.add_argument("--config", help="Path to JSON config")
    parser.add_argument("--product", default="MiniDrone.CATProduct")
    parser.add_argument("--base-name", default="MiniDrone")
    parser.add_argument("--output-dir", default="output")
    parser.add_argument("--explosion-scale", type=float, default=None)
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("status", "views", "explode", "detail-a1", "detail-pages", "all"):
        sub.add_parser(name)
    return parser


def load_config(args: argparse.Namespace) -> AppConfig:
    cfg = AppConfig.from_json(args.config) if args.config else AppConfig()
    cfg.drawing.product_name = args.product
    cfg.drawing.base_name = args.base_name
    cfg.drawing.output_dir = Path(args.output_dir)
    cfg.explosion.output_base_name = f"{args.base_name}_exploded_multiview"
    if args.explosion_scale is not None:
        cfg.explosion.explosion_multiplier = args.explosion_scale
    cfg.validate()
    return cfg


def print_result(result) -> None:
    if result.stdout:
        print(result.stdout, end="" if result.stdout.endswith("\n") else "\n")
    if result.stderr:
        print(result.stderr, file=sys.stderr)


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    service = WorkflowService(load_config(args), Path.cwd())
    if args.command == "status":
        result = service.status()
        print_result(result)
        return result.returncode
    if args.command == "views":
        result = service.views()
        print_result(result)
        return result.returncode
    if args.command == "explode":
        result = service.exploded()
        print_result(result)
        return result.returncode
    if args.command == "detail-pages":
        result = service.detail_pages()
        print_result(result)
        return result.returncode
    if args.command == "detail-a1":
        result = service.detail_a1()
        print_result(result)
        return result.returncode
    if args.command == "all":
        code = 0
        for result in service.all():
            print_result(result)
            code = code or result.returncode
        return code
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
