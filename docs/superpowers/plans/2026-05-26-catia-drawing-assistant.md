# CATIA Drawing Assistant Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local CATIA V5 drawing assistant with a command-line core, Tkinter UI, DeepSeek-compatible optional AI helper, and Codex skill.

**Architecture:** Python renders proven VBScript automation templates and runs them through `cscript`, avoiding `pywin32` dependencies. The CLI and UI share one core service layer, and the Codex skill documents the workflow for future use.

**Tech Stack:** Python standard library, VBScript templates, Windows Script Host, Tkinter, optional DeepSeek/OpenAI-compatible HTTP API.

---

## File Structure

- Create `catia-drawing-assistant/pyproject.toml`: package metadata and console script entry point.
- Create `catia-drawing-assistant/README.md`: local user instructions for CLI/UI/API key.
- Create `catia-drawing-assistant/catia_assistant/__init__.py`: package marker and version.
- Create `catia-drawing-assistant/catia_assistant/config.py`: dataclasses and JSON config validation.
- Create `catia-drawing-assistant/catia_assistant/runner.py`: run `cscript`, capture logs, parse `OK:` paths.
- Create `catia-drawing-assistant/catia_assistant/templates.py`: render VBScript from templates.
- Create `catia-drawing-assistant/catia_assistant/workflows.py`: status, views, explode, and all workflows.
- Create `catia-drawing-assistant/catia_assistant/ai_provider.py`: optional DeepSeek/OpenAI-compatible suggestions.
- Create `catia-drawing-assistant/catia_assistant/cli.py`: argparse command surface.
- Create `catia-drawing-assistant/catia_assistant/ui.py`: Tkinter desktop app.
- Create `catia-drawing-assistant/catia_assistant/templates/status.vbs`: CATIA document probe.
- Create `catia-drawing-assistant/catia_assistant/templates/views.vbs`: engineering drawing generation.
- Create `catia-drawing-assistant/catia_assistant/templates/exploded.vbs`: exploded product and drawing generation.
- Create `catia-drawing-assistant/tests/`: unit tests for config, rendering, runner parsing, AI validation.
- Create `skills/catia-automation/SKILL.md`: Codex skill.
- Create `skills/catia-automation/agents/openai.yaml`: skill UI metadata.

## Tasks

### Task 1: Project Skeleton and Config

**Files:**
- Create: `catia-drawing-assistant/pyproject.toml`
- Create: `catia-drawing-assistant/catia_assistant/__init__.py`
- Create: `catia-drawing-assistant/catia_assistant/config.py`
- Test: `catia-drawing-assistant/tests/test_config.py`

- [ ] Write tests for default config and validation.
- [ ] Implement dataclasses for drawing, explosion, AI, and app config.
- [ ] Run `python -m unittest discover -s catia-drawing-assistant/tests`.

### Task 2: Template Rendering and Runner

**Files:**
- Create: `catia-drawing-assistant/catia_assistant/templates.py`
- Create: `catia-drawing-assistant/catia_assistant/runner.py`
- Create: `catia-drawing-assistant/catia_assistant/templates/status.vbs`
- Test: `catia-drawing-assistant/tests/test_templates_runner.py`

- [ ] Test placeholder substitution and `OK:` output parsing.
- [ ] Implement template loading with `$PLACEHOLDER$` replacement.
- [ ] Implement `ScriptRunner.run_script_text`.

### Task 3: CATIA VBScript Templates

**Files:**
- Create: `catia-drawing-assistant/catia_assistant/templates/views.vbs`
- Create: `catia-drawing-assistant/catia_assistant/templates/exploded.vbs`
- Test: `catia-drawing-assistant/tests/test_templates_content.py`

- [ ] Port the proven engineering drawing VBScript to a parameterized template.
- [ ] Port the proven exploded VBScript to a parameterized template.
- [ ] Test that rendered scripts include expected product names, output names, and explosion scales.

### Task 4: Workflows and CLI

**Files:**
- Create: `catia-drawing-assistant/catia_assistant/workflows.py`
- Create: `catia-drawing-assistant/catia_assistant/cli.py`
- Test: `catia-drawing-assistant/tests/test_cli.py`

- [ ] Test CLI argument parsing for `status`, `views`, `explode`, and `all`.
- [ ] Implement workflow functions.
- [ ] Implement JSON log writing under `output/logs`.

### Task 5: DeepSeek-Compatible Provider

**Files:**
- Create: `catia-drawing-assistant/catia_assistant/ai_provider.py`
- Test: `catia-drawing-assistant/tests/test_ai_provider.py`

- [ ] Test provider request payload construction.
- [ ] Test safe JSON extraction and validation.
- [ ] Implement OpenAI-compatible chat request using `urllib.request`.

### Task 6: Tkinter UI

**Files:**
- Create: `catia-drawing-assistant/catia_assistant/ui.py`
- Test: `catia-drawing-assistant/tests/test_ui_import.py`

- [ ] Test the UI module imports without constructing a window.
- [ ] Implement fields and buttons for product, output directory, explosion multiplier, views, explode, detail outputs, and all.
- [ ] Show workflow logs in a text area.

### Task 7: Codex Skill

**Files:**
- Create: `skills/catia-automation/SKILL.md`
- Create: `skills/catia-automation/agents/openai.yaml`

- [ ] Write a concise skill that points to the CLI and verification workflow.
- [ ] Include common CATIA failure handling.
- [ ] Include DeepSeek optional-assist guidance.

### Task 8: Verification

**Files:**
- Modify as needed based on test failures.

- [ ] Run unit tests.
- [ ] Run `python -m catia_assistant.cli --help`.
- [ ] Run `python -m catia_assistant.cli status` if CATIA is open.
- [ ] If CATIA is available, run `views` and `explode` against `MiniDrone.CATProduct`.
- [ ] Verify generated PDFs exist and have one A3 landscape page.
