# CATIA Drawing Assistant / CATIA 工程图助手

English | [中文](#中文说明)

Local Windows helper for CATIA V5 drawing automation.

## Features

- Detect open CATIA documents.
- Generate original multi-view CATDrawing and PDF files.
- Generate exploded CATProduct, multi-view CATDrawing, and PDF files.
- Generate A1 detail multi-view PDFs.
- Generate 7-page detail PDFs with one view per page.
- Optional DeepSeek/OpenAI-compatible JSON suggestion helper.

Balloon callouts are intentionally not included because fixed or inferred callouts were not reliable enough for this model.

## Usage

Run from this directory:

```powershell
python -m pip install -e .
python -m catia_assistant.ui
```

In the desktop UI, click **Choose CATIA File**, select a `.CATProduct`, then click the generation button you need.

Command-line usage is also available:

```powershell
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

---

## 中文说明

# CATIA Drawing Assistant / CATIA 工程图助手

这是一个用于 CATIA V5 工程图自动化的本地 Windows 工具。

## 功能

- 检测已打开的 CATIA 文档。
- 生成原版多视图 CATDrawing 和 PDF。
- 生成爆炸版 CATProduct、多视图 CATDrawing 和 PDF。
- 生成 A1 细节多视图 PDF。
- 生成 7 页细节 PDF，每页一个视图。
- 可选使用 DeepSeek/OpenAI 兼容接口提供 JSON 建议。

气泡标注功能没有包含在软件中，因为固定或推断式标注不够可靠。

## 使用方法

在本目录运行：

```powershell
python -m pip install -e .
python -m catia_assistant.ui
```

在桌面界面中点击 **选择 CATIA 文件**，选择 `.CATProduct` 文件，然后点击需要的生成按钮。

也可以使用命令行：

```powershell
python -m catia_assistant.cli status
python -m catia_assistant.cli views --product MiniDrone.CATProduct
python -m catia_assistant.cli explode --product MiniDrone.CATProduct
python -m catia_assistant.cli detail-a1 --product MiniDrone.CATProduct
python -m catia_assistant.cli detail-pages --product MiniDrone.CATProduct
python -m catia_assistant.cli all --product MiniDrone.CATProduct
python -m catia_assistant.ui
```

运行生成命令前请先打开 CATIA。`--product` 可以是已打开的 CATProduct 文件名，也可以是完整 `.CATProduct` 路径。

## 爆炸比例

默认爆炸比例是 `0.65`。数值越小，爆炸视图越紧凑；数值越大，零件分散距离越远。

```powershell
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.55 explode
catia-assistant --product "D:\path\to\MiniDrone.CATProduct" --base-name MiniDrone --explosion-scale 0.75 explode
```
