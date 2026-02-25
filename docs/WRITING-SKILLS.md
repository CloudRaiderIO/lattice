# Writing Custom Skills

Skills are structured workflows defined as Markdown files. They tell
Claude Code how to approach a specific type of task, what gates to
enforce, and what tools are allowed. This guide covers the skill format
and how to create your own.

---

## Skill File Location

Skills live in `.claude/skills/<skill-name>/skill.md`. Each skill gets
its own directory, which can also contain supporting files (templates,
scripts, examples).

```
.claude/skills/
  feature-dev/
    skill.md          # The skill definition
  my-custom-skill/
    skill.md          # Your new skill
    template.json     # Supporting file (optional)
```

---

## Skill Format

A skill file has two parts: YAML frontmatter and a Markdown body.

### Frontmatter

```yaml
---
name: my-skill
description: One-line description of what this skill does
triggers:
  - "keyword that activates this skill"
  - "another trigger phrase"
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---
```

**Fields:**

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | Unique identifier for the skill |
| `description` | Yes | One-line summary shown in skill listings |
| `triggers` | Recommended | Phrases that activate the skill |
| `allowed_tools` | Optional | Restrict which tools the skill can use |

### Body

The body is Markdown that describes the workflow. It is injected into
the LLM's context when the skill is activated. Write it as direct
instructions.

---

## The Gate Pattern

Gates are checkpoints that require user approval before proceeding.
They are the core mechanism for preventing the LLM from taking shortcuts.

### Defining a Gate

Use a consistent format so gates are recognizable:

```markdown
## Gate 1: Name

Purpose: Why this gate exists.

Steps:
1. What to do
2. What to do next
3. What to check

Output: What this gate produces.

Ask the user: "Gate 1 complete. [Summary]. Proceed to Gate 2? (yes/no)"
```

### Gate Rules

1. **Each gate must produce output.** A gate that does not produce
   something verifiable is not a real gate.

2. **Each gate must ask for approval.** Use "Ask the user:" as a
   clear signal that the workflow pauses here.

3. **Some gates can be mandatory.** If a gate should never be skipped
   (like a review gate), state it explicitly:
   "This gate is MANDATORY and cannot be skipped, even if the user asks."

4. **Gates should be sequential.** Gate N depends on the output of
   Gate N-1. Do not allow out-of-order execution.

### Example: 3-Gate Deployment Skill

```markdown
## Gate 1: Pre-flight Check

Steps:
1. Run the test suite
2. Check for uncommitted changes
3. Verify the target environment is reachable

Output: Pre-flight report (tests passed, no uncommitted changes, env reachable).

Ask the user: "Pre-flight passed. Deploy to [environment]? (yes/no)"

## Gate 2: Deploy (MANDATORY)

Steps:
1. Run the deployment command
2. Wait for health check to pass
3. Verify the deployment version matches expected

Output: Deployment confirmation with version and health status.

Ask the user: "Deployed version X. Verify in browser and confirm? (yes/no)"

## Gate 3: Post-Deploy Verification

Steps:
1. Run smoke tests against the deployed environment
2. Check error rates in monitoring (if available)
3. Compare response times to pre-deploy baseline

Output: Verification report.
```

---

## Tool Restrictions

The `allowed_tools` field limits what tools the skill can use. This is
useful for skills that should not modify files (like exploration or review)
or skills that should not run arbitrary commands.

Common patterns:

| Skill Type | Allowed Tools |
|------------|---------------|
| Read-only exploration | Read, Glob, Grep |
| Review/verification | Read, Glob, Grep, Bash |
| Full development | Read, Write, Edit, Bash, Glob, Grep |
| Dangerous operations | Explicit list with Bash |

If `allowed_tools` is omitted, the skill can use any tool available
in the session.

---

## Context Management in Skills

Skills execute within the main context window. Long skills can consume
significant context. Add explicit warnings:

```markdown
## Context Management

- If this skill takes more than 20 tool calls, the scope is too large.
  Break the task into smaller pieces.
- Re-read the plan from Gate 2 before Gate 4. Do not rely on memory
  of what was planned.
- If the implementation spans more than 5 files, run separate skills
  for each logical group.
```

---

## Skill Discovery

Claude Code discovers skills by reading the `.claude/skills/` directory.
Users can also invoke skills explicitly by name or by using trigger phrases.

For a skill to be discoverable:
1. It must be in `.claude/skills/<name>/skill.md`
2. It must have valid YAML frontmatter
3. The `name` field must be unique across all skills

---

## Testing a Skill

Before relying on a new skill:

1. Run it on a small, low-stakes task
2. Verify each gate pauses and asks for approval
3. Check that tool restrictions are enforced
4. Confirm the output format is useful
5. Iterate on the wording based on how the LLM interprets it

Skills are instructions. They work probabilistically. The more specific
and structured your instructions, the more consistently the LLM follows
them. Vague skills produce vague results.

---

## Skill Examples

Lattice ships with five core skills:

| Skill | Purpose | Gates |
|-------|---------|-------|
| `feature-dev` | Gated development workflow | 5 (brainstorm, plan, implement, review, merge) |
| `verify-build` | Post-implementation verification | 5 phases (read spec, read tests, read code, run tests, verdict) |
| `crystallize` | Turn solved problems into patterns | 5 steps (capture, formalize, index, verify, confirm) |
| `explore` | Systematic codebase exploration | 4 phases (orient, locate, understand, report) |
| `debug` | 4-phase debugging workflow | 4 phases (identify, isolate, narrow, fix) |

Read these as examples of the format. Adapt them for your needs.
