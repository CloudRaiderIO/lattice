# Lattice Architecture

Lattice is an enforcement layer for agentic AI. It sits between your
project instructions and the LLM runtime, providing four layers of
behavior control with decreasing enforcement strength.

---

## The Four Layers

```
                    Enforcement Strength
                    ====================

Layer 1: Hooks         |########################| Deterministic
Layer 2: Skills        |##################      | Structured
Layer 3: Crystals      |##############          | Injected
Layer 4: CLAUDE.md     |#########               | Probabilistic
```

### Layer 1: Hooks (Deterministic)

Hooks are shell scripts that fire on Claude Code runtime events. They
execute every time the event occurs, regardless of what the LLM is
doing or thinking. The LLM cannot skip, ignore, or override a hook.

**Event types used by Lattice:**

| Event | When It Fires | Lattice Hook |
|-------|---------------|--------------|
| SubagentStart | A sub-agent is spawned | `subagent-start.sh` -- injects time, crystals, project context |
| PostToolUseFailure | A tool call fails | `tool-failure.sh` -- pattern-matches errors to crystal fixes |
| PreCompact | Context window will compress | `pre-compact.sh` -- preserves critical context |

**How hooks work:**

1. An event occurs in the Claude Code runtime
2. The runtime checks `.claude/settings.json` for registered hooks
3. Matching hooks execute as shell commands
4. Hook output is injected into the LLM's context
5. The LLM sees the hook output as part of the tool result

The hook's output appears in the conversation as if it were part of the
tool's output. The LLM processes it naturally. This is how crystals
get injected -- the hook reads the crystal and echoes its content, and
the LLM sees the fix alongside the error.

**Key property:** Hooks are deterministic. They do not depend on the
LLM's attention, context size, or instruction-following reliability.
This is why critical behaviors should be hooks, not CLAUDE.md instructions.

### Layer 2: Skills (Structured)

Skills are Markdown files that define structured workflows with gates.
They are more structured than CLAUDE.md instructions but less
deterministic than hooks -- the LLM must choose to follow the skill's
structure.

Skills live in `.claude/skills/<name>/skill.md` and are discovered
automatically by Claude Code.

**How skills enforce behavior:**

1. The user triggers a skill (by keyword or explicitly)
2. Claude Code loads the skill definition into context
3. The skill defines sequential gates with approval checkpoints
4. Each gate requires user confirmation before advancing
5. Some gates are marked as mandatory (cannot be skipped)

**The gate mechanism:**

```
Gate 1 ──[user approves]──> Gate 2 ──[user approves]──> Gate 3
                                                            |
                                                     [MANDATORY]
                                                            |
                                                        Gate 4
```

Gates prevent the LLM from racing to implementation. Without gates,
the LLM's natural behavior is to start writing code immediately. With
gates, it must brainstorm, plan, and get approval before touching code.

**Key property:** Skills are structured but not deterministic. The LLM
follows them with high reliability, but under extreme context pressure,
it may skip gates. This is why the most critical gates (like review)
should also have hook-level enforcement where possible.

### Layer 3: Crystals (Injected)

Crystals are structured JSON files containing solved problems. They
are not instructions -- they are data that hooks inject at the right
moment.

**How crystals flow through the system:**

```
Crystal File (.json)
    |
    v
Hook reads crystal ──> Hook injects into LLM context
    |                         |
    |                         v
    |                   LLM sees fix alongside error
    |
    v
Index (index.json) ──> SubagentStart hook injects index summary
                              |
                              v
                        Sub-agent knows what crystals exist
```

Crystals are passive. They do nothing on their own. Their power comes
from hooks that read and inject them at the right time. This is the
synergy between Layer 1 and Layer 3.

**Key property:** Crystals are available when relevant, not when
remembered. The LLM does not need to know a crystal exists before
encountering the problem. The hook matches the error pattern and
injects the crystal automatically.

### Layer 4: CLAUDE.md (Probabilistic)

CLAUDE.md is the traditional instruction file. It contains project
conventions, anti-patterns, architectural rules, and other guidance.
Claude Code reads it at session start and includes it in the system
context.

**How CLAUDE.md works:**

1. Session starts
2. Claude Code reads `.claude/CLAUDE.md`
3. Contents are included in the system prompt
4. LLM follows instructions... with decreasing reliability as context grows

**Key property:** CLAUDE.md instructions degrade over long contexts.
They are useful for conventions and preferences but should not be relied
on for critical behaviors. Critical behaviors belong in hooks.

---

## Context Flow

This diagram shows how context flows through a typical Lattice session:

```
Session Start
    |
    v
Claude Code reads .claude/CLAUDE.md ──> System prompt
    |
    v
User makes a request
    |
    v
Main session (Architect) plans the work
    |
    v
Main session spawns sub-agent
    |
    v
[SubagentStart hook fires]
    |── Injects current date/time
    |── Reads crystals/index.json, injects summary
    |── Reads .claude/CLAUDE.md, injects preview
    v
Sub-agent has: task + time + crystals + project context
    |
    v
Sub-agent works... tool call fails
    |
    v
[PostToolUseFailure hook fires]
    |── Reads error output
    |── Pattern-matches against built-in fixes
    |── Pattern-matches against crystals/examples/*.json
    |── Injects fix if found
    v
Sub-agent sees: error + fix suggestion
    |
    v
Sub-agent completes work, returns result
    |
    v
Context grows... approaching window limit
    |
    v
[PreCompact hook fires]
    |── Reads .claude/preserve.md
    |── Echoes critical context as PRESERVE block
    |── Re-injects crystal index summary
    v
Compaction retains: preserved context + crystal awareness
```

---

## Layer Interactions

The four layers are not independent. They reinforce each other:

### Hooks deliver Crystals (Layer 1 -> Layer 3)
The `tool-failure.sh` hook reads crystal files and injects their
solutions into context. Without hooks, crystals would be static files
that the LLM would need to proactively read.

### Skills use the Verification concept (Layer 2 uses BUILD/VERIFY/COMMIT)
The `verify-build` skill implements the verified execution pattern.
The `feature-dev` skill includes a mandatory review gate. Skills encode
verification as a required workflow step.

### Crystals reduce CLAUDE.md load (Layer 3 lightens Layer 4)
Without crystals, every solved problem would need a CLAUDE.md entry.
Crystals offload this -- the solved pattern lives in a JSON file,
injected by hooks when needed, instead of a CLAUDE.md line that the
LLM may or may not read.

### CLAUDE.md defines the Architect pattern (Layer 4 enables Concept 4)
The Architect delegation pattern is defined in CLAUDE.md. It instructs
the main session to stay lean and delegate deep work. While this is
a probabilistic instruction, it is reinforced by the SubagentStart hook
(which makes sub-agents more capable by injecting context they would
otherwise lack).

---

## File Structure

```
.claude/
  settings.json              # Hook wiring (Layer 1 config)
  CLAUDE.md                  # Project instructions (Layer 4)
  preserve.md                # Context to survive compaction
  hooks/
    subagent-start.sh        # Layer 1: Sub-agent context injection
    tool-failure.sh          # Layer 1: Error pattern matching
    pre-compact.sh           # Layer 1: Context preservation
  skills/
    feature-dev/skill.md     # Layer 2: Gated development
    verify-build/skill.md    # Layer 2: Post-implementation review
    crystallize/skill.md     # Layer 2: Pattern crystallization
    explore/skill.md         # Layer 2: Codebase exploration
    debug/skill.md           # Layer 2: Systematic debugging
  crystals/
    index.json               # Layer 3: Crystal registry
    examples/                # Layer 3: Example crystals
    private/                 # Layer 3: Project-specific (gitignored)
```

---

## Design Principles

### 1. Enforcement decreases, flexibility increases

Hooks are rigid -- they fire every time. Skills are structured -- they
have gates but allow judgment within gates. Crystals are available --
they are injected but not mandatory. CLAUDE.md is suggestive -- it
provides guidance that may be followed.

This gradient is intentional. Not everything needs enforcement. Style
preferences are fine as CLAUDE.md instructions. Security-critical
checks should be hooks.

### 2. Critical behaviors belong at Layer 1

If a behavior MUST happen, it should be a hook. If a behavior SHOULD
happen, it should be a skill. If a behavior is PREFERRED, it should
be CLAUDE.md.

### 3. Crystals are infrastructure, not documentation

A crystal that only a human reads is a document. A crystal that a hook
reads and injects automatically is infrastructure. Lattice crystals are
designed for the second case.

### 4. The system should improve without manual effort

Every crystallized pattern makes future sessions more reliable. Every
hook-injected fix prevents a repeated mistake. The system gets better
over time without requiring anyone to maintain a growing CLAUDE.md file.
