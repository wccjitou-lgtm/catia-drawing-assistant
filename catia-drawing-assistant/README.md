# CATIA Drawing Assistant

Local Windows helper for CATIA V5 drawing automation.

## Features

- Detect open CATIA documents.
- Generate original multi-view CATDrawing and PDF.
- Generate exploded CATProduct, multi-view CATDrawing, and PDF.
- Generate A1 detail multi-view PDFs.
- Generate 7-page detail PDFs with one view per page.
- Optional DeepSeek/OpenAI-compatible JSON suggestion helper.

Balloon callouts are intentionally not included because fixed or inferred callouts were not reliable enough for this model.

## Usage

Run from this directory:

```powershell
python -m pip install -e .
python -m catia_assistant.cli status
python -m catia_assistant.cli views --product MiniDrone.CATProduct
python -m catia_assistant.cli explode --product MiniDrone.CATProduct
python -m catia_assistant.cli detail-a1 --product MiniDrone.CATProduct
python -m catia_assistant.cli detail-pages --product MiniDrone.CATProduct
python -m catia_assistant.cli all --product MiniDrone.CATProduct
python -m catia_assistant.ui
```

Open CATIA before running generation commands. `--product` can be either an open CATProduct name or a full `.CATProduct` path.

## Explosion Scale

The default explosion scale is `0.65`. Lower values make the exploded view tighter; higher values spread components farther apart.

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.55 explode
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.75 explode
```
