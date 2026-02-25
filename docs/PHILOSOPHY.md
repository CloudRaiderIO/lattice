# Lattice Philosophy

Lattice is built on five concepts. Each addresses a specific failure mode
in agentic AI systems. Together, they form an enforcement layer that makes
LLM-driven development reliable enough for production use.

---

## 1. Deterministic Hooks: Enforcement Over Instruction

### The Problem

CLAUDE.md is a suggestion. The LLM reads it at session start. As the
context window fills with code, errors, and conversation, the instructions
fade. By token 50,000, the LLM has functionally forgotten half of what
you told it. This is not a bug in the model. It is a property of how
attention works over long contexts.

You cannot solve an enforcement problem with better instructions. You
solve it with enforcement.

### The Solution

Hooks are shell scripts that fire on runtime events. They are not part
of the conversation. They are not subject to attention degradation. They
execute deterministically, every time the event occurs.

Claude Code provides several hook events:

- **SubagentStart**: Fires when a sub-agent is spawned. Lattice uses this
  to inject temporal awareness, crystallized patterns, and project context
  into every sub-agent. The sub-agent does not need to "remember" to read
  CLAUDE.md -- the hook injects the critical parts automatically.

- **PostToolUseFailure**: Fires when a tool call fails. Lattice uses this
  to pattern-match errors against known fixes. When the LLM encounters
  the macOS `sed -i` error for the hundredth time, the hook immediately
  injects the fix instead of letting the LLM guess.

- **PreCompact**: Fires before context compression. Lattice uses this to
  preserve critical facts that must survive compaction -- database
  credentials, API conventions, project-specific anti-patterns.

### Why This Matters

Instructions degrade. Hooks do not. A hook that injects the current
date/time into every sub-agent is worth more than a CLAUDE.md line that
says "always check the date." The line will be forgotten. The hook fires
every time.

The hierarchy of enforcement:
1. Hooks (deterministic, fires on events, cannot be ignored)
2. Skills (structured workflows with gates, requires explicit override)
3. Crystals (solved patterns, injected by hooks, available but optional)
4. CLAUDE.md (instructions, followed probabilistically)

Design your critical behaviors as hooks. Save CLAUDE.md for preferences
and conventions.

---

## 2. Gated Skills: Structure Over Freedom

### The Problem

Given the instruction "implement this feature," an LLM will race to
write code. It will not brainstorm alternatives. It will not write a
plan. It will not write tests first. It will not review its own work.
And when you tell it to do all of these things, it will do them for the
first feature and skip them for the second.

The LLM is not lazy. It is optimizing for what looks like progress.
Writing code looks like progress. Planning does not. Reviewing does not.
The LLM's instinct is to produce output, not to validate it.

### The Solution

A skill is a structured workflow with explicit gates. Each gate is a
checkpoint that requires user approval before the workflow advances.
The structure prevents the LLM from taking shortcuts because the
shortcuts are not available.

Example: the `feature-dev` skill defines five gates:

1. **Brainstorm**: Understand the requirement. No code allowed.
2. **Plan**: Design the implementation. List files, changes, tests. No code.
3. **Implement**: Execute the plan. TDD: write tests first, then code.
4. **Review**: Fresh-context verification. Cannot be skipped.
5. **Merge**: Commit the verified changes.

Gate 4 (Review) is marked as mandatory. Even if the user says "skip the
review," the skill definition says it cannot be skipped. This is
intentional. The review gate exists because the implementing context
has accumulated bias. It "knows" what the code does, so it sees what
it expects rather than what is there.

### Why This Matters

Freedom is the enemy of consistency. An LLM with freedom to choose its
workflow will choose the fastest path, which is rarely the best path.
Gated skills remove that choice. They impose a workflow that has been
validated to produce good results, and they prevent deviation.

This is not about distrusting the LLM. It is about respecting the
reality that attention over long contexts is unreliable, and structured
workflows compensate for that unreliability.

---

## 3. Crystallization: Solve Once, Never Again

### The Problem

LLMs have no persistent memory between sessions. Every new session
starts from zero. If you solved a tricky platform compatibility issue
on Monday, you will solve it again on Tuesday. And Wednesday. The LLM
does not learn from experience. It re-derives from scratch.

Some teams address this by putting everything into CLAUDE.md. The file
grows to 500 lines. Then 1,000. It becomes a wall of text that the LLM
barely reads and humans cannot maintain.

### The Solution

Crystallization is the practice of encoding solved problems as small,
structured, machine-readable JSON files. A crystal contains the problem,
the solution, the error pattern for automatic matching, and enough
context for a future agent to apply the fix without re-deriving it.

The key insight: crystals are not documentation. They are executable
patterns. The `PostToolUseFailure` hook reads crystals and
pattern-matches errors automatically. The `SubagentStart` hook injects
the crystal index so sub-agents know what patterns exist. The crystal
does the work. The LLM does not need to remember.

### The Pipeline

1. You encounter a problem. You solve it.
2. You encounter the same problem again. This is the trigger.
3. You crystallize: write a JSON file with the problem, solution, and
   error pattern.
4. You add the crystal to the index.
5. The hooks pick it up. The problem is now solved for all future sessions.

### Why This Matters

"Don't remember -- crystallize." Memory is unreliable. Code is not. A
crystallized pattern is a solved problem converted into executable
infrastructure. It does not degrade with context. It does not get
forgotten across sessions. It does not depend on the LLM paying
attention. It fires deterministically through hooks.

The goal is a system that gets smarter over time, not one that starts
fresh every morning.

---

## 4. Architect Delegation: Context Management Through Sub-Agents

### The Problem

A single Claude session accumulates context as it works. It reads files,
runs commands, writes code, encounters errors. Each tool call adds to
the context window. After enough context, the session enters what we
call "context debt" -- it has seen so much that it starts losing track
of what matters.

This is when mistakes happen. The LLM forgets the plan. It modifies
a file it already checked. It re-reads code it already analyzed. It
drifts from the user's intent.

### The Solution

The Architect pattern separates orchestration from execution. The main
session (the Architect) stays lean. It:

1. Understands the request
2. Breaks it into focused tasks
3. Delegates to sub-agents for deep work
4. Synthesizes the results

Sub-agents carry deep context for their specific task. They read the
relevant files, do the analysis, write the code, and return a focused
result. When they are done, their context is released. The Architect
never accumulates the deep context of the work -- it only sees the
summary.

### Why This Matters

Context is finite. Every token of context spent on deep investigation
is a token not available for instruction-following. By delegating deep
work to sub-agents, the Architect preserves its ability to follow
instructions, maintain project context, and make good decisions.

This is not just about performance. It is about reliability. A lean
main session follows CLAUDE.md better. It makes fewer mistakes. It
remembers the user's intent. It does not drift.

### Rules for Delegation

Delegate when:
- The task requires more than 3 tool calls
- The task involves reading multiple files
- The task requires research or exploration
- The task involves database queries or API calls

Do not delegate when:
- The user asked a simple question
- The task is a single-file edit
- The task is a quick status check

---

## 5. Verified Execution: Trust Through Redundancy

### The Problem

An LLM that writes code and commits it without verification is dangerous.
Not because the code is always wrong -- often it is correct. But when
it is wrong, there is no safety net. The bug ships. The test was not
written. The edge case was missed.

The implementing agent cannot reliably verify its own work. It has
accumulated context that biases its review. It "knows" what the code
does, so it reads what it expects to see. This is not a flaw in the
model. It is a cognitive bias that affects humans and machines alike.

### The Solution

Every implementation gets a separate verification step. A fresh agent
-- with no knowledge of the implementation conversation -- reads the
spec and reads the code. It makes an independent judgment: PASS, FAIL,
or INCOMPLETE.

The pattern:
1. **BUILD**: Implement the feature, following the plan and writing tests.
2. **VERIFY**: A fresh-context agent reviews the implementation against
   the spec. It checks for correctness, edge cases, convention compliance,
   and security issues.
3. **COMMIT**: Only if verification passes. A FAIL sends the work back
   to BUILD with specific feedback.

### Why This Matters

Trust in agentic systems comes from redundancy, not from confidence.
A single agent that says "looks good to me" provides no assurance. Two
independent agents that agree on correctness provide real assurance.

Verification is not overhead. It is the mechanism that makes autonomous
commits safe. Without it, every commit is a gamble. With it, every
commit has been independently checked by an agent with fresh context
and no implementation bias.

The cost of verification is one extra read pass. The cost of skipping
verification is a shipped bug. The math is straightforward.

---

## The Layers Together

These five concepts form an enforcement stack:

```
Layer 4: CLAUDE.md          Probabilistic instructions
Layer 3: Crystals           Solved patterns, injected by hooks
Layer 2: Skills             Structured workflows with gates
Layer 1: Hooks              Deterministic event handlers
```

Each layer reinforces the others:
- Hooks inject crystals into sub-agents (Layer 1 delivers Layer 3)
- Skills enforce verification gates (Layer 2 uses concept 5)
- Crystals prevent re-solving known problems (Layer 3 reduces Layer 4 load)
- CLAUDE.md defines the Architect pattern (Layer 4 enables concept 4)

The result is a system where the LLM's probabilistic nature is
contained by deterministic enforcement. It can still be creative,
flexible, and useful. But the guardrails prevent the most common
failure modes.

Lattice does not make the LLM smarter. It makes the system reliable.
