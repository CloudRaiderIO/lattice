#!/usr/bin/env bash
#
# Lattice Hook: PostToolUseFailure
# Fires when a tool call fails. Pattern-matches the error output against
# crystallized fixes and common platform issues.
#
# This hook solves the "spiral" problem: when a tool fails, the LLM often
# tries the same approach repeatedly, wasting tokens. By injecting the
# known fix immediately, the LLM corrects course on the first retry.
#
# Error text is passed via stdin from Claude Code.
#

set -euo pipefail

PROJECT_ROOT="$(pwd)"
FIXES_DIR="$PROJECT_ROOT/.claude/crystals"
ERROR_TEXT=$(cat)

# --- Built-in Pattern Matches ---
# These are platform-specific issues that trip up LLMs constantly.
# They don't need crystals because they are universal.

matched=false

# macOS sed -i requires empty string argument
if echo "$ERROR_TEXT" | grep -q "sed: 1:.*invalid command code"; then
    echo "=== LATTICE FIX: macOS sed -i ==="
    echo "On macOS, sed -i requires an empty string argument for in-place editing."
    echo "Wrong: sed -i 's/old/new/' file"
    echo "Right: sed -i '' 's/old/new/' file"
    echo "=== END FIX ==="
    matched=true
fi

# pip vs uv
if echo "$ERROR_TEXT" | grep -q "externally-managed-environment"; then
    echo "=== LATTICE FIX: Python package installation ==="
    echo "This Python environment is externally managed (PEP 668)."
    echo "Use 'uv pip install' instead of 'pip install'."
    echo "If uv is not available: python -m pip install --break-system-packages"
    echo "=== END FIX ==="
    matched=true
fi

# Permission denied on scripts
if echo "$ERROR_TEXT" | grep -q "Permission denied" && echo "$ERROR_TEXT" | grep -q "\.sh"; then
    echo "=== LATTICE FIX: Script permissions ==="
    echo "The script is not executable. Run: chmod +x <script_path>"
    echo "=== END FIX ==="
    matched=true
fi

# Node module not found
if echo "$ERROR_TEXT" | grep -q "Cannot find module"; then
    echo "=== LATTICE FIX: Missing Node module ==="
    echo "A required Node module is not installed."
    echo "Run 'npm install' in the project root, or install the specific package."
    echo "If this is a local file import, verify the path is correct."
    echo "=== END FIX ==="
    matched=true
fi

# Git conflict markers in file
if echo "$ERROR_TEXT" | grep -q "<<<<<<< HEAD"; then
    echo "=== LATTICE FIX: Merge conflict ==="
    echo "The file contains unresolved merge conflict markers."
    echo "Resolve the conflicts between <<<<<<< HEAD and >>>>>>> before proceeding."
    echo "=== END FIX ==="
    matched=true
fi

# EACCES on npm
if echo "$ERROR_TEXT" | grep -q "EACCES.*permission denied"; then
    echo "=== LATTICE FIX: npm permissions ==="
    echo "npm does not have write access. Do NOT use sudo."
    echo "Fix npm permissions: https://docs.npmjs.com/resolving-eacces-permissions-errors"
    echo "Or use a Node version manager (nvm, fnm) to avoid global installs."
    echo "=== END FIX ==="
    matched=true
fi

# Port already in use
if echo "$ERROR_TEXT" | grep -q "EADDRINUSE\|address already in use"; then
    echo "=== LATTICE FIX: Port in use ==="
    echo "The port is already in use by another process."
    echo "Find it: lsof -i :<port_number>"
    echo "Kill it: kill -9 <pid>"
    echo "Or use a different port."
    echo "=== END FIX ==="
    matched=true
fi

# --- Crystal-Based Pattern Matches ---
# Search the crystals/fixes directory for patterns that match this error.

if [ "$matched" = false ] && [ -d "$FIXES_DIR/examples" ]; then
    for crystal in "$FIXES_DIR/examples/"*.json; do
        [ -f "$crystal" ] || continue

        # Extract the error pattern from the crystal
        pattern=$(node -e "
            try {
                const c = require('$crystal');
                if (c.error_pattern) console.log(c.error_pattern);
            } catch(e) {}
        " 2>/dev/null || true)

        if [ -n "$pattern" ] && echo "$ERROR_TEXT" | grep -qi "$pattern"; then
            echo "=== LATTICE FIX (from crystal: $(basename "$crystal")) ==="
            node -e "
                try {
                    const c = require('$crystal');
                    console.log('Problem: ' + (c.problem || 'unknown'));
                    console.log('Solution: ' + (c.solution || 'unknown'));
                    if (c.example) console.log('Example: ' + c.example);
                } catch(e) {}
            " 2>/dev/null || true
            echo "=== END FIX ==="
            matched=true
            break
        fi
    done
fi

# If no match, output nothing. The LLM sees only the original error.
# This is intentional -- we don't want to add noise when we have no fix.
