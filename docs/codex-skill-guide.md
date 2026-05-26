# Codex Skill Guide

The repository includes a Codex skill at:

```text
skills/catia-automation/SKILL.md
```

## Install The Skill Locally

Copy the skill folder into your Codex skills directory:

```powershell
$target = "$env:USERPROFILE\.codex\skills\catia-automation"
New-Item -ItemType Directory -Force -Path $target
Copy-Item -Recurse -Force skills\catia-automation\* $target
```

Restart Codex or start a new session so the skill list is refreshed.

## Use The Skill

Example prompts:

```text
Use the catia-automation skill to generate the original and exploded engineering PDFs for MiniDrone.
```

```text
Use the catia-automation skill and generate a tighter exploded view with explosion scale 0.55.
```

```text
Use the catia-automation skill to generate detail-pages because the PDF linework is too dense.
```

## Skill Behavior

The skill tells Codex to:

1. Check CATIA connectivity.
2. Use the local `catia-assistant` software.
3. Generate original and exploded drawings.
4. Use A1 or detail-page PDFs when details are hard to read.
5. Avoid balloon/circled-number callouts.
6. Treat DeepSeek as an optional advisor only, not as direct CATIA control.

## Customize Paths

The public skill uses placeholder paths. In a local project, replace:

```text
D:\path\to\MiniDrone.CATProduct
```

with the real saved CATProduct path.
