#!/usr/bin/env bash
#
# Lattice Hook: SubagentStart
# Fires when a sub-agent is spawned. Injects context that the sub-agent
# would otherwise lack: temporal awareness, crystallized patterns, and
# project-specific instructions.
#
# This hook solves three problems:
# 1. Sub-agents have no sense of time (they don't know what day it is)
# 2. Sub-agents don't inherit crystallized patterns from prior sessions
# 3. Sub-agents may not read CLAUDE.md unless explicitly told to
#

set -euo pipefail

PROJECT_ROOT="$(pwd)"
CRYSTAL_DIR="$PROJECT_ROOT/.claude/crystals"
CLAUDE_MD="$PROJECT_ROOT/.claude/CLAUDE.md"

# --- Temporal Awareness ---
# LLMs have no internal clock. Inject the current date/time so
# sub-agents can evaluate data freshness and timestamp their work.

echo "=== LATTICE CONTEXT INJECTION ==="
echo ""
echo "CURRENT TIME: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo ""

# --- Crystal Index ---
# If crystals exist, inject the index so the sub-agent knows what
# solved patterns are available. It reads the full crystal only if relevant.

if [ -f "$CRYSTAL_DIR/index.json" ]; then
    CRYSTAL_COUNT=$(node -e "
        try {
            const idx = require('$CRYSTAL_DIR/index.json');
            const entries = idx.crystals || [];
            console.log(entries.length);
        } catch(e) { console.log('0'); }
    " 2>/dev/null || echo "0")

    if [ "$CRYSTAL_COUNT" != "0" ]; then
        echo "CRYSTALLIZED PATTERNS AVAILABLE: $CRYSTAL_COUNT"
        echo "Index: $CRYSTAL_DIR/index.json"
        echo "Before solving a problem, check if a crystal already covers it."
        echo ""

        # Inject crystal summaries (problem + file path only, not full solutions)
        node -e "
            try {
                const idx = require('$CRYSTAL_DIR/index.json');
                const entries = idx.crystals || [];
                entries.forEach(c => {
                    console.log('  - ' + c.problem + ' -> ' + c.file);
                });
            } catch(e) {}
        " 2>/dev/null || true
        echo ""
    fi
fi

# --- Project Context ---
# Inject the CLAUDE.md header so the sub-agent has project identity
# and core rules without reading the full file.

if [ -f "$CLAUDE_MD" ]; then
    echo "PROJECT INSTRUCTIONS: $CLAUDE_MD"
    echo "Read this file before starting work. It contains project-specific"
    echo "rules, anti-patterns, and conventions."
    echo ""

    # Inject the first 30 lines as a preview (usually the project identity section)
    echo "--- Project Context (preview) ---"
    head -n 30 "$CLAUDE_MD"
    echo "--- End Preview ---"
    echo ""
fi

echo "=== END LATTICE CONTEXT ==="
