# GitHub Publishing Guide

This repository is intended to publish the software, Codex skill, and tutorial material only.

## Do Publish

- `catia-drawing-assistant/`
- `skills/catia-automation/`
- `docs/`
- `scripts/`
- `README.md`
- `.gitignore`

## Do Not Publish

Generated CATIA files are ignored by Git:

- `output/`
- `tmp/`
- `*.CATProduct`
- `*.CATDrawing`
- `*.CATPart`
- `*.pdf`
- Python caches and egg metadata.

## Create A GitHub Repository

Create an empty repository on GitHub, then run:

```powershell
git remote add origin https://github.com/<owner>/<repo>.git
git branch -M main
git push -u origin main
```

If the remote already exists:

```powershell
git remote set-url origin https://github.com/<owner>/<repo>.git
git push -u origin main
```

## Suggested Release Notes

```text
Initial release:
- CATIA V5 CLI and Tkinter UI.
- Original multi-view PDF generation.
- Exploded CATProduct and multi-view PDF generation.
- A1 detail drawing generation.
- 7-page detail PDF generation.
- Adjustable explosion scale, default 0.65.
- Codex catia-automation skill and tutorial docs.
- Balloon/circled-number callouts intentionally excluded.
```
