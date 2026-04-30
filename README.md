# GitHub Copilot Helper

A portable collection of GitHub Copilot customizations — instructions, prompts, and templates — that work across any project and platform (Unix/Windows).

## Why This Repo Is Useful

GitHub Copilot is only as good as the context you give it. Out of the box, it doesn't know your team's coding standards, naming conventions, or preferred patterns — so suggestions tend to be generic and inconsistent across projects.

This repo gives you a ready-made, reusable set of Copilot customizations — instructions, prompts, rules, and agents — that you can install globally (once for every project) or per-project in seconds. The result:

- **Consistent suggestions** that follow your standards instead of generic boilerplate
- **Faster onboarding** for new repos and new teammates — no re-writing the same guidelines each time
- **Better code reviews, tests, refactors, and docs** via specialized agents and prompt templates
- **Cross-platform** — same setup works on macOS, Linux, and Windows
- **No lock-in** — plain Markdown files you can fork, edit, or extend for your own team

## What's Included

| Folder | Purpose | Description |
|--------|---------|-------------|
| `instructions/` | Copilot instructions | Repository-level `.github/copilot-instructions.md` templates |
| `prompts/` | Reusable prompts | Common prompts for code review, refactoring, testing |
| `rules/` | Coding standards | Language-specific style guides and best practices |
| `agents/` | Custom agents | Specialized agents for specific tasks |
| `templates/` | Starter templates | Quick-start templates for new projects |

## Quick Start

### Global Install (User-Level)

Install once, applies to all projects:

```bash
# Unix/macOS
./install.sh -g

# Windows PowerShell
.\install.ps1 -Global
```

This installs to `~/.github-copilot/` (customizable via `GITHUB_COPILOT_HOME` env var).

### Project Install

Install to a specific project:

```bash
# Unix/macOS
./install.sh /path/to/your/project

# Windows PowerShell
.\install.ps1 -TargetPath "C:\path\to\your\project"
```

This copies files to the project's `.github/` directory.

## Install Options

### Unix/macOS

```bash
# Global install (user-level)
./install.sh -g

# Project install
./install.sh /path/to/project

# Preview without copying (dry run)
./install.sh -d -g
./install.sh -d /path/to/project

# Force overwrite existing files
./install.sh -f -g
./install.sh -f /path/to/project

# Install specific modules only
./install.sh -g -m instructions
./install.sh -m "instructions,rules,agents" /path/to/project
```

### Windows (PowerShell)

```powershell
# Global install (user-level)
.\install.ps1 -Global

# Project install
.\install.ps1 -TargetPath "C:\path\to\project"

# Preview without copying (dry run)
.\install.ps1 -Global -DryRun
.\install.ps1 -DryRun -TargetPath "C:\path\to\project"

# Force overwrite existing files
.\install.ps1 -Global -Force
.\install.ps1 -Force -TargetPath "C:\path\to\project"

# Install specific modules only
.\install.ps1 -Global -Modules "instructions,agents"
.\install.ps1 -Modules "instructions" -TargetPath "C:\path\to\project"
```

## How GitHub Copilot Uses These

GitHub Copilot reads instructions from multiple locations:

### Global Install (`~/.github-copilot/`)

After global install, configure VS Code to use them:

```json
{
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": "~/.github-copilot/instructions/base.md" }
  ]
}
```

Custom agents from `~/.github-copilot/agents/` are automatically available.

### Project Install (`.github/`)

- `.github/copilot-instructions.md` — Applied to all Copilot interactions in that repo
- `.github/copilot/agents/` — Project-specific custom agents

### Install Locations

| Mode | Location | Scope |
|------|----------|-------|
| Global | `~/.github-copilot/` | All projects |
| Project | `.github/copilot/` | Single project |

You can customize the global location with the `GITHUB_COPILOT_HOME` environment variable.

## Current Contents

### Instructions

| File | What it does |
|------|-------------|
| `instructions/base.md` | Core instructions for all projects |
| `instructions/web-frontend.md` | Frontend-specific (React, TypeScript, CSS) |
| `instructions/backend-api.md` | Backend API patterns (REST, validation) |
| `instructions/testing.md` | Test-writing guidelines |
| `instructions/async.md` | Async/concurrency patterns |
| `instructions/monorepo.md` | Monorepo workspace guidelines |
| `instructions/cicd.md` | Basic CI/CD with GitHub Actions |

### Prompts

| File | What it does |
|------|-------------|
| `prompts/review.md` | Code review checklist prompt |
| `prompts/refactor.md` | Safe refactoring prompt |
| `prompts/document.md` | Documentation generation prompt |
| `prompts/test.md` | Test generation prompt |
| `prompts/performance.md` | Performance optimization prompt |

### Rules

| File | What it does |
|------|-------------|
| `rules/general.md` | Universal coding standards |
| `rules/typescript.md` | TypeScript-specific guidelines |
| `rules/java.md` | Java-specific guidelines |
| `rules/python.md` | Python-specific guidelines |

### Agents

| File | What it does |
|------|-------------|
| `agents/code-reviewer.md` | Review code for correctness, security, performance |
| `agents/test-writer.md` | Generate comprehensive tests with edge cases |
| `agents/refactorer.md` | Safely refactor code while preserving behavior |
| `agents/documenter.md` | Generate JSDoc/Javadoc/docstrings and API docs |
| `agents/debugger.md` | Diagnose and fix bugs systematically |
| `agents/performance-optimizer.md` | Analyze performance bottlenecks and suggest optimizations |

## Customizing Instructions

To customize for your project:

1. Run the installer to copy the base template
2. Edit `.github/copilot-instructions.md` in your project
3. Add project-specific context, naming conventions, or constraints

### Combining Instructions

You can merge multiple instruction files:

```bash
# Unix
cat instructions/base.md instructions/web-frontend.md > combined.md

# PowerShell
Get-Content instructions/base.md, instructions/web-frontend.md | Set-Content combined.md
```

## VS Code Settings (Optional)

For user-level instructions that apply to all projects, add to your VS Code `settings.json`:

```json
{
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": "~/.github-copilot/instructions/base.md" }
  ]
}
```

## Adding New Customizations

Drop files into the appropriate folder:

- **Instructions** — `.md` files in `instructions/`
- **Prompts** — `.md` files in `prompts/`
- **Rules** — `.md` files in `rules/`
- **Agents** — `.md` files in `agents/` with YAML frontmatter (name, description, tools)
- **Templates** — `.md` files in `templates/`

## File Format

Instructions use Markdown. Keep them concise — Copilot has context limits.

```markdown
# Project Guidelines

## Code Style
- Use camelCase for variables
- Prefer const over let

## Architecture
- Follow clean architecture patterns
- Keep functions under 20 lines
```

## Uninstall

The installer only copies files — it never deletes. To remove, manually delete `.github/copilot-instructions.md` from your project.

## Contributing

1. Fork the repository
2. Add your customizations to the appropriate folder
3. Test with the installer
4. Submit a pull request

## License

MIT
