#!/usr/bin/env bash
#
# install.sh — Install GitHub Copilot instructions to a target project or globally.
#
# Usage:
#   ./install.sh /path/to/project           # Install to project
#   ./install.sh -g                         # Install globally (~/.github-copilot)
#   ./install.sh -d /path/to/project        # Dry run
#   ./install.sh -f /path/to/project        # Force overwrite
#   ./install.sh -m instructions /path/to   # Specific modules only
#
set -euo pipefail

# Global install location
GLOBAL_DIR="${GITHUB_COPILOT_HOME:-$HOME/.github-copilot}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi

# Available modules
ALL_MODULES=(instructions prompts rules templates agents skills hooks)

usage() {
  echo -e "${BOLD}Usage:${NC} ./install.sh [options] [target-project-path]"
  echo ""
  echo -e "${BOLD}Options:${NC}"
  echo "  -g, --global      Install globally to ~/.github-copilot (user-level)"
  echo "  -f, --force       Overwrite existing files (default: skip)"
  echo "  -d, --dry-run     Show what would be installed without copying"
  echo "  -m, --modules     Comma-separated list of modules (default: all)"
  echo "  -h, --help        Show this help message"
  echo ""
  echo -e "${BOLD}Modules:${NC} instructions, prompts, rules, templates, agents, skills, hooks"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo "  ./install.sh -g                        # Global install"
  echo "  ./install.sh ~/projects/myapp          # Project install"
  echo "  ./install.sh -f ~/projects/myapp"
  echo "  ./install.sh -m instructions ~/projects/myapp"
  echo "  ./install.sh -d -m instructions,rules ~/projects/myapp"
}

# Defaults
FORCE=false
DRY_RUN=false
GLOBAL_INSTALL=false
MODULES=()
TARGET_PATH=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--global)  GLOBAL_INSTALL=true; shift ;;
    -f|--force)   FORCE=true; shift ;;
    -d|--dry-run) DRY_RUN=true; shift ;;
    -m|--modules)
      IFS=',' read -ra MODULES <<< "$2"
      shift 2
      ;;
    -h|--help)    usage; exit 0 ;;
    -*)           echo -e "${RED}Unknown option: $1${NC}"; usage; exit 1 ;;
    *)            TARGET_PATH="$1"; shift ;;
  esac
done

# Determine target path
if [[ "$GLOBAL_INSTALL" == true ]]; then
  TARGET_PATH="$GLOBAL_DIR"
  if [[ ! -d "$TARGET_PATH" ]]; then
    if [[ "$DRY_RUN" == false ]]; then
      mkdir -p "$TARGET_PATH"
    fi
  fi
elif [[ -z "$TARGET_PATH" ]]; then
  echo -e "${RED}Error: Target project path is required (or use -g for global install).${NC}"
  usage
  exit 1
elif [[ -d "$TARGET_PATH" ]]; then
  TARGET_PATH="$(cd "$TARGET_PATH" && pwd)"
else
  echo -e "${RED}Error: Target path does not exist: $TARGET_PATH${NC}"
  exit 1
fi

# Default to all modules if none specified
if [[ ${#MODULES[@]} -eq 0 ]]; then
  for mod in "${ALL_MODULES[@]}"; do
    [[ -d "$SCRIPT_DIR/$mod" ]] && MODULES+=("$mod")
  done
fi

# Validate modules
for mod in "${MODULES[@]}"; do
  if [[ ! -d "$SCRIPT_DIR/$mod" ]]; then
    echo -e "${YELLOW}Warning: Module '$mod' not found. Skipping.${NC}"
  fi
done

# Stats
copied=0
skipped=0
overwritten=0

install_file() {
  local src="$1"
  local dest="$2"

  # Skip hidden/system files
  local basename
  basename="$(basename "$src")"
  [[ "$basename" == .* ]] && return

  local dest_dir
  dest_dir="$(dirname "$dest")"

  if [[ -f "$dest" ]]; then
    if [[ "$FORCE" == true ]]; then
      if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${YELLOW}[overwrite]${NC} $dest"
      else
        mkdir -p "$dest_dir"
        cp "$src" "$dest"
        echo -e "  ${YELLOW}[overwrite]${NC} $dest"
      fi
      overwritten=$((overwritten + 1))
    else
      echo -e "  ${CYAN}[skip]${NC} $dest (exists)"
      skipped=$((skipped + 1))
    fi
  else
    if [[ "$DRY_RUN" == true ]]; then
      echo -e "  ${GREEN}[copy]${NC} $dest"
    else
      mkdir -p "$dest_dir"
      cp "$src" "$dest"
      echo -e "  ${GREEN}[copy]${NC} $dest"
    fi
    copied=$((copied + 1))
  fi
}

echo ""
echo -e "${BOLD}GitHub Copilot Helper Installer${NC}"
if [[ "$GLOBAL_INSTALL" == true ]]; then
  echo -e "Mode: ${GREEN}Global${NC} (user-level)"
else
  echo -e "Mode: ${CYAN}Project${NC}"
fi
echo -e "Target: ${CYAN}$TARGET_PATH${NC}"
if [[ "$DRY_RUN" == true ]]; then
  echo -e "${YELLOW}(dry run — no files will be modified)${NC}"
fi
echo ""

for mod in "${MODULES[@]}"; do
  [[ ! -d "$SCRIPT_DIR/$mod" ]] && continue

  echo -e "${BOLD}[$mod]${NC}"

  # Determine destination prefix based on install mode
  if [[ "$GLOBAL_INSTALL" == true ]]; then
    DEST_PREFIX="$TARGET_PATH"
  else
    DEST_PREFIX="$TARGET_PATH/.github/copilot"
  fi

  case "$mod" in
    instructions)
      if [[ "$GLOBAL_INSTALL" == true ]]; then
        # Global: copy all instructions to instructions/
        while IFS= read -r -d '' file; do
          basename="$(basename "$file")"
          install_file "$file" "$DEST_PREFIX/instructions/$basename"
        done < <(find "$SCRIPT_DIR/instructions" -maxdepth 1 -name "*.md" -type f -print0)
      else
        # Project: Install base instructions to .github/copilot-instructions.md
        if [[ -f "$SCRIPT_DIR/instructions/base.md" ]]; then
          install_file "$SCRIPT_DIR/instructions/base.md" "$TARGET_PATH/.github/copilot-instructions.md"
        fi
        # Copy other instruction templates to .github/copilot/
        while IFS= read -r -d '' file; do
          basename="$(basename "$file")"
          [[ "$basename" == "base.md" ]] && continue
          rel_name="${basename%.md}"
          install_file "$file" "$DEST_PREFIX/instructions-$rel_name.md"
        done < <(find "$SCRIPT_DIR/instructions" -maxdepth 1 -name "*.md" -type f -print0)
      fi
      ;;
    prompts)
      while IFS= read -r -d '' file; do
        basename="$(basename "$file")"
        install_file "$file" "$DEST_PREFIX/prompts/$basename"
      done < <(find "$SCRIPT_DIR/prompts" -maxdepth 1 -name "*.md" -type f -print0)
      ;;
    rules)
      while IFS= read -r -d '' file; do
        basename="$(basename "$file")"
        install_file "$file" "$DEST_PREFIX/rules/$basename"
      done < <(find "$SCRIPT_DIR/rules" -maxdepth 1 -name "*.md" -type f -print0)
      ;;
    templates)
      while IFS= read -r -d '' file; do
        basename="$(basename "$file")"
        install_file "$file" "$DEST_PREFIX/templates/$basename"
      done < <(find "$SCRIPT_DIR/templates" -maxdepth 1 -name "*.md" -type f -print0)
      ;;
    agents|skills|hooks)
      while IFS= read -r -d '' file; do
        rel_path="${file#$SCRIPT_DIR/}"
        install_file "$file" "$DEST_PREFIX/${rel_path#*/}"
      done < <(find "$SCRIPT_DIR/$mod" -type f ! -path "*/.*" -print0)

      if [[ "$mod" == "hooks" && "$GLOBAL_INSTALL" == false && "$DRY_RUN" == false ]]; then
        mkdir -p "$TARGET_PATH/.vscode"
        settings_file="$TARGET_PATH/.vscode/settings.json"
        echo -e "  ${YELLOW}[config]${NC} Wiring Copilot hooks into .vscode/settings.json"
        
        if [[ ! -f "$settings_file" ]]; then
          echo "{}" > "$settings_file"
        fi
        
        if command -v jq &>/dev/null; then
          jq '."github.copilot.advanced" += {"hooks": {"PreToolUse": [{"command": "bash .github/copilot/hooks/lint-before-commit.sh", "matcher": "Bash(git commit*)"}, {"command": "bash .github/copilot/hooks/test-before-push.sh", "matcher": "Bash(git push*)"}], "PostToolUse": [{"command": "bash .github/copilot/hooks/format-on-save.sh", "matcher": "Edit|Write"}]}}' "$settings_file" > "${settings_file}.tmp" && mv "${settings_file}.tmp" "$settings_file"
        else
          echo -e "  ${RED}[warning]${NC} 'jq' not found. Cannot auto-configure .vscode/settings.json. Please configure hooks manually."
        fi
      fi
      ;;
  esac

  echo ""
done

echo -e "${BOLD}Done.${NC} ${GREEN}$copied copied${NC}, ${CYAN}$skipped skipped${NC}, ${YELLOW}$overwritten overwritten${NC}"
