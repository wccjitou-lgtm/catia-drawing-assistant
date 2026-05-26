# CATIA Drawing Assistant

CATIA Drawing Assistant is a local Windows automation project for CATIA V5. It contains:

- A Python command-line tool and Tkinter UI.
- VBScript templates that drive CATIA through COM.
- A Codex skill for repeating the drawing workflow.
- Tutorials for installation, generation, and skill use.

The current preset was built around a MiniDrone CATProduct workflow, but the tool accepts any open or saved `.CATProduct` path.

## Main Capabilities

- Detect the running CATIA session.
- Generate original multi-view CATDrawing and PDF.
- Generate exploded CATProduct, CATDrawing, and PDF.
- Generate A1 detail multi-view PDFs.
- Generate 7-page detail PDFs with one view per page.
- Adjust explosion distance with `--explosion-scale`.
- Optionally use a DeepSeek/OpenAI-compatible helper for JSON suggestions.

Balloon/circled-number callouts are intentionally not included. They were removed because automatic callout targeting was not reliable enough for engineering output.

## Quick Start

```powershell
cd catia-drawing-assistant
python -m pip install -e .
catia-assistant status
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone all
```

Use a smaller explosion scale when the exploded drawing looks too scattered:

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.55 explode
```

Default output goes to `catia-drawing-assistant/output/`.

## Documentation

- [User tutorial](docs/tutorial.md)
- [Codex skill guide](docs/codex-skill-guide.md)
- [Publishing guide](docs/github-publishing.md)
- [Project design note](docs/superpowers/specs/2026-05-26-catia-drawing-assistant-design.md)

## Repository Layout

```text
catia-drawing-assistant/       Python package, CLI, UI, and CATIA VBS templates
skills/catia-automation/       Codex skill for this workflow
docs/                          Tutorials and design notes
scripts/                       Original prototype VBS scripts
```

Generated CATIA drawings, PDFs, temporary VBS runs, and Python build caches are ignored by Git.
