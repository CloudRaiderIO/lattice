#!/usr/bin/env bash
#
# Lattice Installer
# Installs the enforcement layer for agentic AI into your project.
#
# Usage:
#   bash install.sh              # Install into current directory
#   bash install.sh /path/to    # Install into specified directory
#

set -euo pipefail

TARGET_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Prerequisites ---

check_prereq() {
    if ! command -v "$1" &>/dev/null; then
        echo "ERROR: $1 is required but not found in PATH."
        echo "       $2"
        exit 1
    fi
}

check_prereq "claude" "Install Claude Code: https://docs.anthropic.com/en/docs/claude-code"
check_prereq "node" "Install Node.js: https://nodejs.org/"

if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: Target directory does not exist: $TARGET_DIR"
    echo "       Create it first or use '.' for current directory."
    exit 1
fi

echo "Lattice installer"
echo "Target: $(cd "$TARGET_DIR" && pwd)"
echo ""

# --- Install .claude structure ---

CLAUDE_DIR="$TARGET_DIR/.claude"

if [ -d "$CLAUDE_DIR" ]; then
    echo "Found existing .claude/ directory."
    echo "Lattice will merge its files without overwriting your existing configuration."
    echo ""
fi

# Create directory structure
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/skills/feature-dev"
mkdir -p "$CLAUDE_DIR/skills/verify-build"
mkdir -p "$CLAUDE_DIR/skills/crystallize"
mkdir -p "$CLAUDE_DIR/skills/explore"
mkdir -p "$CLAUDE_DIR/skills/debug"
mkdir -p "$CLAUDE_DIR/crystals/examples"
mkdir -p "$CLAUDE_DIR/crystals/private"

# Copy hooks (always overwrite -- hooks should stay in sync with Lattice)
cp "$SCRIPT_DIR/.claude/hooks/subagent-start.sh" "$CLAUDE_DIR/hooks/subagent-start.sh"
cp "$SCRIPT_DIR/.claude/hooks/tool-failure.sh" "$CLAUDE_DIR/hooks/tool-failure.sh"
cp "$SCRIPT_DIR/.claude/hooks/pre-compact.sh" "$CLAUDE_DIR/hooks/pre-compact.sh"

# Make hooks executable
chmod +x "$CLAUDE_DIR/hooks/"*.sh

# Copy settings.json only if it does not exist (do not overwrite user config)
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$SCRIPT_DIR/.claude/settings.json" "$CLAUDE_DIR/settings.json"
    echo "Created .claude/settings.json with hook wiring."
else
    echo "Existing .claude/settings.json found -- not overwriting."
    echo "Verify that your hooks section includes the Lattice hooks."
    echo "See $SCRIPT_DIR/.claude/settings.json for reference."
fi

# Copy CLAUDE.md template only if it does not exist
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/.claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    echo "Created .claude/CLAUDE.md template. Edit this for your project."
else
    echo "Existing .claude/CLAUDE.md found -- not overwriting."
fi

# Copy skills (do not overwrite existing customized skills)
for skill_dir in feature-dev verify-build crystallize explore debug; do
    if [ ! -f "$CLAUDE_DIR/skills/$skill_dir/skill.md" ]; then
        cp "$SCRIPT_DIR/.claude/skills/$skill_dir/skill.md" "$CLAUDE_DIR/skills/$skill_dir/skill.md"
        echo "Installed skill: $skill_dir"
    else
        echo "Skill $skill_dir already exists -- not overwriting."
    fi
done

# Copy crystal index and examples (do not overwrite)
if [ ! -f "$CLAUDE_DIR/crystals/index.json" ]; then
    cp "$SCRIPT_DIR/.claude/crystals/index.json" "$CLAUDE_DIR/crystals/index.json"
fi

for example in "$SCRIPT_DIR/.claude/crystals/examples/"*.json; do
    basename="$(basename "$example")"
    if [ ! -f "$CLAUDE_DIR/crystals/examples/$basename" ]; then
        cp "$example" "$CLAUDE_DIR/crystals/examples/$basename"
    fi
done

# Copy crystals README
if [ ! -f "$CLAUDE_DIR/crystals/README.md" ]; then
    cp "$SCRIPT_DIR/.claude/crystals/README.md" "$CLAUDE_DIR/crystals/README.md"
fi

# Copy preserve.md template
if [ ! -f "$CLAUDE_DIR/preserve.md" ]; then
    cp "$SCRIPT_DIR/.claude/preserve.md" "$CLAUDE_DIR/preserve.md"
    echo "Created .claude/preserve.md -- add context you want preserved during compaction."
fi

# --- Validation ---

echo ""
echo "Validating installation..."

ERRORS=0

validate_file() {
    if [ ! -f "$1" ]; then
        echo "  MISSING: $1"
        ERRORS=$((ERRORS + 1))
    fi
}

validate_file "$CLAUDE_DIR/settings.json"
validate_file "$CLAUDE_DIR/CLAUDE.md"
validate_file "$CLAUDE_DIR/hooks/subagent-start.sh"
validate_file "$CLAUDE_DIR/hooks/tool-failure.sh"
validate_file "$CLAUDE_DIR/hooks/pre-compact.sh"
validate_file "$CLAUDE_DIR/skills/feature-dev/skill.md"
validate_file "$CLAUDE_DIR/skills/verify-build/skill.md"
validate_file "$CLAUDE_DIR/skills/crystallize/skill.md"
validate_file "$CLAUDE_DIR/skills/explore/skill.md"
validate_file "$CLAUDE_DIR/skills/debug/skill.md"
validate_file "$CLAUDE_DIR/crystals/index.json"

if [ "$ERRORS" -gt 0 ]; then
    echo ""
    echo "Installation completed with $ERRORS missing file(s). Check above."
    exit 1
fi

echo "All files present."
echo ""
echo "Lattice installed. Run 'claude' to start."
