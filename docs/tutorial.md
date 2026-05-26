# CATIA Drawing Assistant Tutorial

This tutorial explains how to generate CATIA V5 engineering PDFs with the local assistant.

## Requirements

- Windows.
- CATIA V5 installed and running.
- Python 3.10 or newer.
- A saved `.CATProduct` file.

## Install

Open PowerShell in the repository root:

```powershell
cd catia-drawing-assistant
python -m pip install -e .
```

This installs:

- `catia-assistant`
- `catia-assistant-ui`

## Check CATIA

Open CATIA first, then run:

```powershell
catia-assistant status
```

Expected output includes `CATIA=CNEXT` and the list of open documents.

## Generate Drawings

Use either an open CATProduct name:

```powershell
catia-assistant --product MiniDrone.CATProduct --base-name MiniDrone views
```

Or a full CATProduct path:

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone views
```

Commands:

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone views
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone explode
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone detail-a1
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone detail-pages
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone all
```

## Adjust Explosion Distance

The default explosion scale is `0.65`, chosen to avoid a scattered exploded drawing.

Use a smaller value if parts are still too far apart:

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.55 explode
```

Use a larger value if parts are too close:

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.75 explode
```

Practical range:

- `0.50`: compact.
- `0.65`: default.
- `0.80`: wider.
- `1.00`: original wide spacing.

## Outputs

Files are written to `output/` by default:

- `MiniDrone_multiview.CATDrawing`
- `MiniDrone_multiview.pdf`
- `MiniDrone_exploded_multiview.CATProduct`
- `MiniDrone_exploded_multiview.CATDrawing`
- `MiniDrone_exploded_multiview.pdf`
- `MiniDrone_multiview_detail_A1.pdf`
- `MiniDrone_exploded_multiview_detail_A1.pdf`
- `MiniDrone_detail_pages.pdf`
- `MiniDrone_exploded_detail_pages.pdf`

## UI

Run:

```powershell
catia-assistant-ui
```

Fill in:

- Product file: open CATProduct name or full `.CATProduct` path.
- Output prefix: for example `MiniDrone`.
- Output directory: for example `output`.
- Explosion scale: for example `0.65`.

Then click the required generation button.

## Notes

- The source CATProduct is not overwritten.
- Exploded workflows save a separate exploded CATProduct.
- Do not call CATIA product update after exploding, because constraints can pull components back into assembled positions.
- Balloon/circled-number callouts are intentionally removed because automatic targeting was unreliable.
