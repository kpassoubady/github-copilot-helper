# GitHub Copilot Helper — Project Guide

A portable collection of GitHub Copilot customizations (instructions, prompts, rules, agents, skills, hooks, templates) installable globally or per-project via `install.sh` / `install.ps1`.

## Repository Layout

| Path | Purpose |
|------|---------|
| `instructions/` | `.github/copilot-instructions.md` templates (base + overlays) |
| `prompts/` | Reusable slash-command prompts (review, refactor, test, …) |
| `rules/` | Language-specific coding standards (TypeScript, Java, Python, …) |
| `agents/building-blocks/` | Single-purpose agent personas (reviewer, debugger, …) |
| `agents/orchestrators/` | High-level decision-making agents (architect, …) |
| `skills/` | Multi-step SKILL.md workflow files for autonomous execution |
| `hooks/` | Deterministic shell scripts wired to Copilot hook triggers |
| `templates/` | Starter templates users copy and customize |
| `install.sh` | Unix/macOS installer |
| `install.ps1` | Windows PowerShell installer |

## Verification / Testing

There are no automated tests. Verify changes with a dry run before committing:

```bash
# Preview what would be installed (no files written)
./install.sh -d -g
./install.sh -d /tmp/test-project

# Actual install to a throw-away dir
./install.sh /tmp/test-project

# Windows
.\install.ps1 -DryRun -Global
.\install.ps1 -DryRun -TargetPath "C:\Temp\test-project"
```

After editing any Markdown file, run the linter:

```bash
npx markdownlint-cli2 "**/*.md"
```

(Ignored paths are listed in `.markdownlintignore`.)

## Adding New Content

### Instructions (`instructions/`)
- `base.md` is installed as `.github/copilot-instructions.md` — keep it short and universal.
- Overlay files (e.g. `web-frontend.md`) are supplementary templates users combine manually.

### Prompts (`prompts/`)
Plain Markdown files. Each file should focus on a single task and include example usage in a code block.

### Rules (`rules/`)
Language or framework-specific guidelines. One file per language.

### Agents (`agents/`)
Require YAML front matter:

```yaml
---
name: agent-name
description: One-line summary
tools:
  - codebase
  - terminalLastCommand
---
```

See the [VS Code custom agents docs](https://code.visualstudio.com/docs/copilot/customization/custom-agents) for the full list of available tools.

- Place single-purpose personas under `agents/building-blocks/`.
- Place orchestrating agents under `agents/orchestrators/`.

### Skills (`skills/<name>/SKILL.md`)
Multi-step workflow files. Follow the format used by existing skills (`dev-workflow`, `increase-coverage`, `perf-audit`, `security-audit`).

### Hooks (`hooks/`)
Bash scripts. Each hook comment must document:
- The Copilot hook trigger (`PreToolUse` / `PostToolUse`)
- The tool it intercepts (e.g. `git commit`, `Edit`)

## Content Guidelines

- Keep instructions concise — Copilot has context limits.
- Use clear, actionable language (imperative mood).
- No organization-specific references — everything must work for any team.
- Follow existing Markdown formatting and heading conventions.
- Test both Unix and Windows install paths when touching `install.sh` / `install.ps1`.

## Commit Standards

Follow the project's existing commit style (Conventional Commits):

```
<type>: <short summary>
```

Common types: `feat`, `fix`, `docs`, `refactor`, `chore`.

Keep the subject line under 72 characters.
