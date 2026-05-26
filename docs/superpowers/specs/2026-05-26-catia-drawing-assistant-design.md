# CATIA Drawing Assistant Design

## Goal

Build a local Windows tool that packages the proven CATIA V5 automation workflow from this project into a reusable command-line program, a small desktop UI, and a Codex skill.

The first version must reproduce the successful MiniDrone workflow:

- Generate an A3 ISO landscape engineering drawing with front, left, right, top, bottom, rear, and isometric views.
- Generate an exploded CATProduct copy without modifying the original product.
- Generate exploded drawing and PDF outputs.
- Generate a separate exploded drawing and PDF. Balloon/circled-number callouts were removed after testing because automatic targeting was unreliable.
- Verify outputs by checking file existence, PDF page metadata, and drawing view/text/leader counts where CATIA is available.

## Product Shape

The system has three layers.

1. `catia_assistant` command-line core: deterministic local automation that creates scripts, runs CATIA through `cscript`, and validates outputs.
2. `catia_assistant.ui` desktop app: a Tkinter interface with buttons and fields for common workflows.
3. `skills/catia-automation`: a Codex skill that tells Codex how to use the software, inspect logs, run verification, and adjust configuration.

DeepSeek support is optional. The tool must work without an API key. When configured, DeepSeek may propose JSON configuration changes, but local code must validate and execute every change.

## Architecture

The Python core does not directly depend on `pywin32`. Instead, it renders VBScript templates and runs them with Windows Script Host. This mirrors the workflow already proven against CATIA V5R21 in this workspace and keeps installation simple.

Configuration is JSON. The initial preset targets `MiniDrone.CATProduct`, but the command line accepts product name, output directory, scale, and explosion multiplier. The first implementation keeps the MiniDrone explosion classification rules as a named preset and exposes the defaults so they can be adjusted later.

## Components

### CLI

The executable module is `catia_assistant.cli`.

Commands:

- `status`: connect to CATIA and list open documents.
- `views`: generate engineering views and PDF.
- `explode`: generate exploded CATProduct, drawing, and PDF.
- `all`: run views and explode.

All commands write logs to `output/logs`.

### Templates

VBScript templates live in `catia_assistant/templates`.

Templates are generated from the working scripts:

- Engineering drawing: based on `scripts/generate_drawing_views.vbs`.
- Exploded drawing: based on `scripts/generate_exploded_view.vbs`.

The generated scripts use explicit values from JSON configuration and print `OK:` lines for each output file.

### Desktop UI

The desktop app is built with Tkinter to avoid extra dependencies.

Controls:

- Product name.
- Output directory.
- Drawing scale.
- Explosion multiplier.
- Controls for product path, output path, engineering views, exploded view, PDF export, and explosion scale.
- DeepSeek API key field or environment variable hint.
- Run button and log panel.

The UI calls the CLI core in-process where practical and shows the command log.

### DeepSeek Assistance

The AI provider module supports OpenAI-compatible chat completions through `urllib.request`.

It accepts product structure JSON and returns proposed config JSON. The first version includes the provider and validation path, but the default UI workflow remains deterministic.

### Codex Skill

The skill describes:

- When to use the CATIA automation tool.
- How to check that CATIA is running.
- How to run CLI commands.
- How to inspect outputs.
- How to handle common CATIA failures such as same-name documents already open, missing product, PDF export failure, unsupported circled glyphs, or constraint updates collapsing exploded movement.

## Data Flow

1. User starts CATIA and opens a product.
2. CLI/UI writes a generated VBScript into a temporary run directory.
3. The tool runs `cscript //nologo <script>`.
4. VBScript connects to `CATIA.Application`, creates drawings/products, saves outputs, and prints paths.
5. Python parses output, records a JSON log, validates generated files, and optionally renders PDF metadata.
6. Codex can read the logs and rerun commands with adjusted configuration.

## Safety Rules

- Never overwrite the source CATProduct in place.
- Generate exploded CATProduct copies with a suffix.
- Close same-name generated documents before overwriting generated output.
- Do not call `Product.Update` after moving exploded components; CATIA constraints can pull components back into assembled positions.
- DeepSeek suggestions are advisory JSON only and must be validated locally.

## Verification

Unit tests cover configuration, command construction, VBScript rendering, output parsing, DeepSeek response validation, and PDF metadata parsing.

Manual integration verification covers:

- `python -m catia_assistant.cli status`
- `python -m catia_assistant.cli views --product MiniDrone.CATProduct`
- `python -m catia_assistant.cli explode --product MiniDrone.CATProduct --explosion-scale 0.65`
- PDF existence and page size.
- CATIA drawing view, text, and leader counts when CATIA is open.

## First-Version Limits

- Windows and CATIA V5 only.
- Tkinter UI only.
- MiniDrone preset rules are included first; generic automatic classification is a later enhancement.
- Balloon coordinates are preset-based in version one.
- DeepSeek is optional and does not directly operate CATIA.
