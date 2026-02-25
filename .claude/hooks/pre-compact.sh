#!/usr/bin/env bash
#
# Lattice Hook: PreCompact
# Fires before Claude Code compresses the context window. This is your
# last chance to preserve critical information that would otherwise be
# lost when older conversation turns are summarized or dropped.
#
# How it works:
# 1. Reads .claude/preserve.md for user-defined critical context
# 2. Echoes it as a PRESERVE block that the compaction process retains
# 3. Adds session metadata (time, project) for orientation after compaction
#
# Edit .claude/preserve.md to define what YOUR project needs preserved.
# Examples: database connection details, API conventions, critical anti-patterns.
#

set -euo pipefail

PROJECT_ROOT="$(pwd)"
PRESERVE_FILE="$PROJECT_ROOT/.claude/preserve.md"

echo "=== LATTICE PRESERVE BLOCK ==="
echo ""
echo "SESSION CONTEXT (retain after compaction):"
echo "  Time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "  Project: $PROJECT_ROOT"
echo ""

# --- User-Defined Preserved Context ---

if [ -f "$PRESERVE_FILE" ]; then
    echo "--- Critical Context (from preserve.md) ---"
    cat "$PRESERVE_FILE"
    echo ""
    echo "--- End Critical Context ---"
else
    echo "No preserve.md found. Create .claude/preserve.md to define"
    echo "context that must survive compaction (DB creds, API patterns, etc)."
fi

echo ""

# --- Crystal Summary ---
# After compaction, the LLM may forget which crystals are available.
# Re-inject the crystal index summary.

CRYSTAL_INDEX="$PROJECT_ROOT/.claude/crystals/index.json"
if [ -f "$CRYSTAL_INDEX" ]; then
    CRYSTAL_COUNT=$(node -e "
        try {
            const idx = require('$CRYSTAL_INDEX');
            console.log((idx.crystals || []).length);
        } catch(e) { console.log('0'); }
    " 2>/dev/null || echo "0")

    if [ "$CRYSTAL_COUNT" != "0" ]; then
        echo "CRYSTALLIZED PATTERNS: $CRYSTAL_COUNT available"
        echo "Check $CRYSTAL_INDEX before solving known problems."
        echo ""
    fi
fi

echo "=== END LATTICE PRESERVE BLOCK ==="
