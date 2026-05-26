---
name: catia-automation
description: Use when automating CATIA V5 engineering drawings, exploded views, multi-view PDF generation, A1 detail drawings, detail-page PDFs, or when using the local CATIA Drawing Assistant software.
---

# CATIA Automation

Use this skill for CATIA V5 drawing automation with the local CATIA Drawing Assistant.

## Tool

Primary software:

```powershell
cd "D:\path\to\catia-drawing-assistant"
catia-assistant status
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone views
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone explode
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone detail-a1
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone detail-pages
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone all
catia-assistant-ui
```

`--product` can be either an open CATProduct name or a full `.CATProduct` path.

## Explosion Scale

Default explosion scale is `0.65`. Use lower values for a tighter exploded view and higher values for a wider exploded view:

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.55 explode
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.75 explode
```

## Workflow

1. Verify CATIA is open with `status`.
2. Confirm the target `.CATProduct` is open or provide its full path.
3. Generate original multi-view drawings with `views`.
4. Generate exploded multi-view drawings with `explode`.
5. Generate A1 original and exploded detail multi-view drawings with `detail-a1`.
6. Generate detail-page PDFs with `detail-pages` when line weight hides details.
7. Verify PDFs with page counts and a rendered preview when layout matters.

## Outputs

Default outputs go under `output/`:

- `<base>_multiview.CATDrawing`
- `<base>_multiview.pdf`
- `<base>_exploded_multiview.CATProduct`
- `<base>_exploded_multiview.CATDrawing`
- `<base>_exploded_multiview.pdf`
- `<base>_multiview_detail_A1.CATDrawing`
- `<base>_multiview_detail_A1.pdf`
- `<base>_exploded_multiview_detail_A1.CATProduct`
- `<base>_exploded_multiview_detail_A1.CATDrawing`
- `<base>_exploded_multiview_detail_A1.pdf`
- `<base>_detail_pages.pdf`
- `<base>_exploded_detail_pages.pdf`

## Important Rules

- Do not overwrite the source CATProduct.
- Do not use balloon/circled-number callouts; this was intentionally removed because automatic callout targeting was unreliable.
- If PDF lines look too thick, use `detail-a1` or `detail-pages`; detail-pages generates seven pages with one large view per page.
- If a generated PDF is locked, generate a new output name or close the PDF viewer.
- Avoid calling `Product.Update` after moving exploded components because constraints can pull components back into assembled positions.

## DeepSeek

DeepSeek support is optional. It may suggest JSON configuration or explain failures, but local scripts must execute CATIA automation. Do not let AI output directly control CATIA without validation.
