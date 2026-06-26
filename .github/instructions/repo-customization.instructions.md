---
description: "Use when editing github-copilot-helper customization assets (instructions, prompts, rules, agents, skills, hooks, templates). Enforces folder taxonomy, naming conventions, and concise markdown style."
name: "Repo Customization Conventions"
applyTo:
  - "instructions/**/*.md"
  - "rules/**/*.md"
  - "agents/**/*.md"
  - "skills/**/SKILL.md"
  - "README.md"
---
# Repository Customization Conventions

## Hard requirements

- Keep each file focused on one concern. Do not mix unrelated guidance in a single instruction, rule, agent, or skill.
- Preserve taxonomy and naming:
  - `agents/building-blocks/*.md` for specialist executors
  - `agents/orchestrators/*.md` for coordinator roles
  - `skills/<skill-name>/SKILL.md` for multi-step workflows
  - `instructions/*.md` and `rules/*.md` for their respective concerns
- Use clear trigger language in descriptions (for example: "Use when ...") so on-demand discovery works reliably.
- When adding, removing, or renaming any documented asset, update related tables and references in `README.md` in the same change.

## Preferences

- Keep markdown concise and directly actionable. Prefer short checklists over long prose.
- Avoid duplicating large sections across files. Link or reference related assets instead.
- Keep edits additive and minimal. Do not rewrite unrelated content or reformat entire files.
