---
name: explore
description: Systematic codebase exploration and understanding
triggers:
  - "explore"
  - "understand the codebase"
  - "map the code"
  - "how does this work"
  - "find where"
allowed_tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# Explore Skill

This skill provides a systematic approach to understanding a codebase
or finding specific functionality. It prevents the common failure mode
of random grep commands that waste tokens and miss results.

## Exploration Phases

### Phase 1: Orient

Before searching for anything, understand the project structure.

Steps:
1. Read the project root: `ls` the top-level directory
2. Read configuration files: package.json, Cargo.toml, pyproject.toml,
   go.mod, or whatever defines the project
3. Read the README or CLAUDE.md if they exist
4. Identify the source directory structure

Output: A mental map of where code lives.

Time limit: 3-5 tool calls maximum.

### Phase 2: Locate

Find the specific code relevant to the question.

Search strategy (use in this order):
1. **Filename search first**: Use Glob to find files by name pattern.
   This is faster and more precise than content search.
2. **Content search second**: Use Grep with targeted patterns.
   Search for function names, class names, or unique strings --
   not generic terms.
3. **Import/reference tracing**: Once you find the target file,
   trace imports to understand dependencies.

Anti-patterns:
- Do NOT grep for single common words ("error", "handle", "data")
- Do NOT read every file in a directory sequentially
- Do NOT search the entire codebase when you can narrow to a directory
- Do NOT use regex when a literal string match will work

### Phase 3: Understand

Read the located code and build understanding.

Steps:
1. Read the primary file(s) found in Phase 2
2. Trace key dependencies (imports, called functions)
3. Check for tests -- they often explain intended behavior better
   than the code itself
4. Look for configuration that affects behavior

Read with purpose. If you are reading a file and it is not relevant,
stop and move to the next one. Do not read the entire file "just in case."

### Phase 4: Report

Summarize findings in a structured format:

```
EXPLORATION SUMMARY

Question: [what was being investigated]

Key Files:
  - path/to/main-file.ts: [what it does]
  - path/to/dependency.ts: [what it does]

How It Works:
  [2-3 paragraph explanation of the mechanism]

Related Tests:
  - path/to/test.ts: [what scenarios are tested]

Open Questions:
  - [anything unclear that would need deeper investigation]
```

## Scope Control

Exploration can expand endlessly. Enforce these limits:

- Phase 1 (Orient): Maximum 5 tool calls
- Phase 2 (Locate): Maximum 10 tool calls
- Phase 3 (Understand): Maximum 10 tool calls
- Phase 4 (Report): 1 tool call (or just text output)

Total: 26 tool calls maximum. If you hit the limit, report what you
found and what remains unknown. Partial understanding with clear gaps
is more useful than exhaustive exploration that consumes all context.
