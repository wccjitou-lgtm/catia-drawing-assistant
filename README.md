# CATIA Drawing Assistant / CATIA 工程图助手

English | [中文](#中文说明)

CATIA Drawing Assistant is a local Windows automation project for CATIA V5 engineering drawings. It includes a Python CLI, a Tkinter desktop UI, CATIA VBScript templates, a Codex skill, and tutorial documentation.

The current workflow was developed around a MiniDrone CATProduct, but the tool can work with any open or saved `.CATProduct` path.

## Features

- Detect the running CATIA session.
- Generate original multi-view CATDrawing and PDF files.
- Generate exploded CATProduct, CATDrawing, and PDF files.
- Generate A1 detail multi-view PDFs.
- Generate 7-page detail PDFs with one large view per page.
- Adjust explosion distance with `--explosion-scale`.
- Optionally use a DeepSeek/OpenAI-compatible helper for JSON suggestions.

Balloon/circled-number callouts are intentionally excluded because automatic callout targeting was not reliable enough for engineering output.

## Quick Start

```powershell
cd catia-drawing-assistant
python -m pip install -e .
catia-assistant-ui
```

In the desktop UI, click **Choose CATIA File**, select a `.CATProduct`, then click the generation button you need.

CLI usage is also available:

```powershell
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

---

## 中文说明

# CATIA Drawing Assistant / CATIA 工程图助手

CATIA 工程图助手是一个面向 CATIA V5 的本地 Windows 自动化项目。仓库包含 Python 命令行工具、Tkinter 桌面界面、CATIA VBScript 模板、Codex skill 和配套教程文档。

当前流程最初围绕 MiniDrone 装配体开发，但软件支持任意已打开或已保存的 `.CATProduct` 路径。

## 功能

- 检测正在运行的 CATIA 会话。
- 生成原版多视图 CATDrawing 和 PDF。
- 生成爆炸版 CATProduct、CATDrawing 和 PDF。
- 生成 A1 细节多视图 PDF。
- 生成 7 页细节 PDF，每页一个大视图。
- 通过 `--explosion-scale` 调整爆炸距离。
- 可选接入 DeepSeek/OpenAI 兼容接口，用于 JSON 建议和错误解释。

带圈数字/气泡标注功能已刻意移除，因为自动标注指向不够可靠，不适合直接作为工程输出。

## 快速开始

```powershell
cd catia-drawing-assistant
python -m pip install -e .
catia-assistant-ui
```

在桌面界面中点击 **选择 CATIA 文件**，选择 `.CATProduct` 文件，然后点击需要的生成按钮。

也可以使用命令行：

```powershell
catia-assistant status
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone all
```

如果爆炸视图太散，可以调小爆炸比例：

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.55 explode
```

默认输出目录是 `catia-drawing-assistant/output/`。

## 文档

- [用户教程](docs/tutorial.md)
- [Codex skill 使用指南](docs/codex-skill-guide.md)
- [GitHub 发布说明](docs/github-publishing.md)
- [项目设计说明](docs/superpowers/specs/2026-05-26-catia-drawing-assistant-design.md)

## 仓库结构

```text
catia-drawing-assistant/       Python 包、CLI、UI 和 CATIA VBS 模板
skills/catia-automation/       本流程对应的 Codex skill
docs/                          教程和设计说明
scripts/                       早期原型 VBS 脚本
```

生成的 CATIA 工程图、PDF、临时 VBS 文件和 Python 缓存不会提交到 Git。
