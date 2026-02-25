---
name: crystallize
description: Turn a solved problem into a reusable pattern
triggers:
  - "crystallize"
  - "save this pattern"
  - "remember this fix"
  - "crystal"
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
---

# Crystallize Skill

This skill converts a solved problem into a structured, reusable pattern
stored as a JSON crystal. Crystals are automatically injected by hooks
into future sessions, so the problem never needs to be solved again.

## When to Crystallize

Crystallize when:
- You solved the same problem twice (this is the trigger -- twice means it will happen again)
- A fix took significant debugging time and the root cause was non-obvious
- A platform-specific behavior causes consistent failures (macOS vs Linux, etc.)
- An API has authentication or formatting quirks that are not well documented

Do NOT crystallize:
- One-time problems specific to a single file or commit
- Obvious bugs that would not recur
- Problems that are better solved by fixing the underlying code

## Crystal Format

Create a JSON file with these fields:

```json
{
  "problem": "Short description of what goes wrong",
  "error_pattern": "Regex that matches the error output (for tool-failure.sh hook)",
  "context": "Why this happens -- the root cause explanation",
  "solution": "How to fix it -- the correct approach",
  "examples": {
    "wrong": "The incorrect approach that causes the problem",
    "right": "The correct approach"
  },
  "tags": ["keyword1", "keyword2"],
  "platform": "darwin | linux | windows | all",
  "verified": "YYYY-MM-DD",
  "source": "Where this was discovered (project, incident, etc)"
}
```

Required fields: `problem`, `solution`, `verified`
Recommended: `error_pattern` (enables automatic hook matching), `examples`

## Crystallization Process

### Step 1: Capture

Identify the problem and solution. If this is from a recent debugging
session, extract the relevant details while they are fresh.

Ask the user to confirm:
- "Is this the correct problem statement?"
- "Is this the correct solution?"

### Step 2: Formalize

Write the crystal JSON file. Choose an appropriate filename:
- Use lowercase with hyphens: `macos-sed-fix.json`
- Group by category if the crystals directory grows: `platform/`, `auth/`, `api/`

Place the file in `.claude/crystals/` (or a subdirectory).

### Step 3: Index

Add an entry to `.claude/crystals/index.json`:

```json
{
  "problem": "Short description",
  "file": "relative/path/to/crystal.json",
  "tags": ["tag1", "tag2"],
  "added": "YYYY-MM-DD"
}
```

### Step 4: Verify

Read back the crystal file and the index entry. Confirm:
- The JSON is valid
- The error_pattern (if present) would match the actual error output
- The solution is complete enough that a future agent can apply it
  without additional context

### Step 5: Confirm

Tell the user:
- What was crystallized
- Where it is stored
- When it will fire (which hook, what triggers it)

## Private Crystals

If the crystal contains project-specific or sensitive information
(API endpoints, internal hostnames, etc.), place it in
`.claude/crystals/private/` which is gitignored by default.

It will still be picked up by the hooks. It just will not be committed
to version control.
