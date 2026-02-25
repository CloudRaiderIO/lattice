# Project: [YOUR PROJECT NAME]

# ============================================================
# Lattice CLAUDE.md Template
# ============================================================
# This file defines project-specific instructions for Claude Code.
# It is the lowest enforcement layer -- hooks and skills override it.
# Edit each section for your project. Delete comments when done.
#
# Enforcement hierarchy (strongest to weakest):
#   1. Hooks (deterministic, always fire)
#   2. Skills (structured workflows with gates)
#   3. Crystals (solved patterns, injected by hooks)
#   4. This file (instructions, followed probabilistically)
# ============================================================


## Project Identity

# What is this project? One paragraph. The LLM reads this to understand
# what codebase it is working in and what matters.

[Describe your project here. What does it do? What tech stack?
What are the critical things an AI agent must know before touching code?]


## Architecture Rules

# List the 3-5 most important architectural constraints.
# These should be things the LLM tends to violate.

# Example:
# - All API routes go through src/routes/. Never create route handlers elsewhere.
# - Database access only through src/db/. No raw SQL in route handlers.
# - Tests mirror source structure: src/foo.ts -> tests/foo.test.ts


## Architect Pattern

# The main Claude session should stay lean. It should:
# 1. Understand the request
# 2. Break it into focused tasks
# 3. Delegate to sub-agents for deep work
# 4. Synthesize results
#
# Sub-agents carry deep context for their specific task.
# The main session avoids accumulating context debt.
#
# When to delegate:
# - Any task requiring more than 3 tool calls
# - Any research or exploration task
# - Any multi-file change
#
# When NOT to delegate:
# - Simple questions
# - Single-file edits
# - Quick status checks


## Crystallization Rules

# When the same problem is solved twice, it should be crystallized:
# 1. Create a JSON crystal in .claude/crystals/
# 2. Update .claude/crystals/index.json
# 3. The crystal is now available to all future sessions via hooks
#
# Do not "remember" patterns. Crystallize them.
# Scripts do not forget. Memory does.


## Anti-Patterns

# List specific things the LLM should NOT do in this project.
# Be concrete. "Don't use bad practices" is useless.
# "Never use console.log for error handling; use the logger at src/lib/logger.ts" is useful.

# Example:
# - Never use `pip install` directly. Use `uv pip install`.
# - Never commit to main. Always create a branch.
# - Never skip the review gate in the feature-dev skill.
# - Never hardcode credentials. Use environment variables.


## Context to Preserve

# List facts that must survive context compaction.
# These should also be added to .claude/preserve.md for the PreCompact hook.
# But listing them here provides a secondary layer of persistence.

# Example:
# - Database is PostgreSQL on port 5433 (not default 5432).
# - Auth uses OAuth2 with PKCE, not basic auth.
# - The CI pipeline runs on push to main and on PR creation.
