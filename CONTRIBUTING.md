# Contributing to GitHub Copilot Helper

## Adding New Content

### Instructions
Add `.md` files to `instructions/`. These are templates for repository-level Copilot instructions.

- `base.md` is installed as the main `.github/copilot-instructions.md`
- Other files are installed as supplementary templates

### Prompts
Add `.md` files to `prompts/`. These are reusable prompts for common tasks.

### Rules
Add `.md` files to `rules/`. These are language or framework-specific guidelines.

### Agents
Add `.md` files to `agents/` with YAML frontmatter:

```yaml
---
name: agent-name
description: What this agent does
tools:
  - codebase
  - terminalLastCommand
---
```

See [VS Code custom agents docs](https://code.visualstudio.com/docs/copilot/customization/custom-agents) for available tools.

### Templates
Add `.md` files to `templates/`. These are starter templates for users to customize.

## Testing

### Unix/macOS
```bash
# Dry run to see what would be installed
./install.sh -d /path/to/test/project

# Actual install
./install.sh /path/to/test/project
```

### Windows
```powershell
# Dry run
.\install.ps1 -DryRun -TargetPath "C:\path\to\test\project"

# Actual install
.\install.ps1 -TargetPath "C:\path\to\test\project"
```

## Guidelines

- Keep instructions concise — Copilot has context limits
- Use clear, actionable language
- Follow existing formatting patterns
- Test both Unix and Windows install scripts
- No organization-specific references

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Add your changes
4. Test the install scripts
5. Submit a pull request with a clear description
