# Crystallization: The Core Innovation

Crystallization is the practice of converting solved problems into
structured, machine-readable patterns that are automatically applied
in future sessions. It is the mechanism by which a Lattice-enabled
project gets smarter over time instead of starting fresh every session.

---

## Why Crystallization Matters

LLMs have no persistent memory. Each session begins with a blank slate.
The model does not know what it solved yesterday, what patterns it
discovered, or what mistakes it made. It will re-derive solutions from
scratch, and it will often re-derive them differently -- sometimes
worse.

The traditional solution is to put everything in CLAUDE.md. This works
for a handful of conventions. It breaks down at scale. A 500-line
CLAUDE.md is a wall of text that the LLM reads with decreasing
attention. Critical instructions on line 400 receive a fraction of the
attention given to line 10.

Crystallization solves this differently. Instead of telling the LLM
about every solved problem, crystals are injected at the moment they
are relevant:

- The `PostToolUseFailure` hook matches errors against crystal patterns
  and injects the fix when the error occurs
- The `SubagentStart` hook injects the crystal index so sub-agents
  know what patterns exist
- The `PreCompact` hook preserves crystal awareness across context
  compression

The LLM does not need to remember. The infrastructure remembers for it.

---

## The Crystallization Pipeline

### 1. Encounter

You hit a problem. You solve it. This is normal work. No crystallization
yet.

### 2. Trigger

You hit the same problem again. This is the crystallization trigger.
A problem solved twice will be solved a hundred times. The second
occurrence is your signal to invest in a permanent solution.

### 3. Capture

Document the problem and solution while the context is fresh:
- What exactly went wrong?
- What error message appeared?
- What was the root cause?
- What is the correct fix?

### 4. Formalize

Write a crystal JSON file:

```json
{
  "problem": "Short description of what goes wrong",
  "error_pattern": "regex matching the error output",
  "context": "Why this happens",
  "solution": "How to fix it",
  "examples": {
    "wrong": "The incorrect approach",
    "right": "The correct approach"
  },
  "tags": ["relevant", "keywords"],
  "platform": "darwin | linux | all",
  "verified": "2026-02-25",
  "source": "Where this was discovered"
}
```

### 5. Index

Add the crystal to `.claude/crystals/index.json`:

```json
{
  "problem": "Short description",
  "file": "path/to/crystal.json",
  "tags": ["tag1", "tag2"],
  "added": "2026-02-25"
}
```

### 6. Verify

Read back the crystal. Confirm:
- The JSON is valid
- The `error_pattern` matches the actual error output
- The solution is complete enough to apply without additional context
- The examples show both wrong and right approaches

---

## Crystal Format Specification

### Required Fields

| Field | Type | Purpose |
|-------|------|---------|
| `problem` | string | One-line description of the problem |
| `solution` | string | The fix, stated as an instruction |
| `verified` | string | ISO date when the crystal was last verified |

### Recommended Fields

| Field | Type | Purpose |
|-------|------|---------|
| `error_pattern` | string | Regex for the tool-failure hook to match |
| `context` | string | Why this problem occurs (root cause) |
| `examples` | object | `wrong` and `right` usage examples |
| `tags` | array | Keywords for indexing and search |
| `platform` | string | Which OS this applies to (`darwin`, `linux`, `all`) |
| `source` | string | Where the problem was first encountered |

### Optional Fields

| Field | Type | Purpose |
|-------|------|---------|
| `related_issues` | array | Other problems often seen alongside this one |
| `common_mistakes` | array | Frequent wrong approaches to this problem |
| `severity` | string | How bad the problem is (`low`, `medium`, `high`) |

---

## When to Crystallize

**Do crystallize:**
- Platform-specific gotchas (macOS sed, BSD vs GNU tools)
- Authentication patterns (OAuth flows, token management)
- API format quirks (header formats, pagination patterns)
- Dependency-specific issues (version conflicts, import patterns)
- Environment setup steps that are easy to get wrong
- Error messages that have non-obvious solutions

**Do not crystallize:**
- One-time bugs in specific code (fix the code instead)
- Obvious errors (typos, missing imports)
- Preferences that change over time (style choices)
- Information that is better served by documentation

The litmus test: "Will a future session hit this exact problem?" If
yes, crystallize. If probably not, skip it.

---

## Organizing Crystals

For small projects, all crystals can live in `.claude/crystals/`.

For larger projects, organize by category:

```
.claude/crystals/
  index.json
  platform/
    macos-sed.json
    macos-grep.json
  auth/
    oauth-client-credentials.json
    jwt-refresh-pattern.json
  api/
    pagination-cursor.json
    rate-limit-handling.json
  private/          # gitignored
    internal-api-endpoints.json
```

The `private/` directory is gitignored by default. Use it for crystals
that contain project-specific or sensitive information (internal URLs,
API endpoints, etc.). These crystals still work with hooks -- they just
do not get committed to version control.

---

## Crystal Maintenance

Crystals should be verified periodically. Dependencies change. APIs
update. Platform behaviors evolve. A crystal with a `verified` date
from a year ago may no longer be accurate.

Recommended cadence:
- Review crystals when a version upgrade occurs (language, framework, OS)
- Delete crystals for problems that no longer exist
- Update `verified` dates when you confirm a crystal still applies

A stale crystal that injects a wrong fix is worse than no crystal at
all. If you are not sure a crystal is still valid, delete it and
re-crystallize when the problem recurs.

---

## The Philosophy

"Don't remember -- crystallize."

Memory is unreliable. For humans, it degrades over time. For LLMs, it
does not exist between sessions. In both cases, the solution is the
same: convert knowledge into a persistent, executable form.

A crystal is not a note. It is not a reminder. It is a structured
pattern that machines can read and apply automatically. When you
crystallize a solution, you are not writing documentation. You are
building infrastructure.

Every crystal makes the system more reliable. Every un-crystallized
repeated solution is a tax on future sessions.
