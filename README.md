# Lattice

**The enforcement layer for agentic AI.**

LLMs are powerful but inconsistent. As context grows, instructions drift, patterns degrade, and agents make the same mistakes they solved yesterday. CLAUDE.md files help, but they are suggestions -- the model can and will ignore them under pressure.

Lattice makes agentic AI reliable. It sits between your instructions and the LLM runtime, enforcing behavior through deterministic hooks, structured workflows, and executable patterns. It works with Claude Code today and is designed to extend to any agentic framework.

---

## The Problem

You write careful instructions in CLAUDE.md. The LLM follows them for the first 10,000 tokens. Then context grows. The model starts cutting corners. It forgets your database conventions. It skips the review step. It solves a problem you already solved last week, but worse this time.

This is not a prompting problem. It is an enforcement problem.

Instructions are suggestions. Hooks are guarantees.

## The Five Concepts

### 1. Deterministic Hooks

Hooks fire on runtime events -- not when the LLM decides to, but when the event occurs. A `SubagentStart` hook injects context into every sub-agent automatically. A `PostToolUseFailure` hook catches errors and suggests fixes before the LLM spirals. A `PreCompact` hook preserves critical context when the window compresses. These are shell scripts. They run every time. The LLM cannot skip them.

### 2. Gated Skills

A skill is a structured workflow with explicit checkpoints. Instead of "implement this feature," a gated skill enforces: brainstorm, plan, implement, review, merge -- each requiring user approval before proceeding. The review gate cannot be skipped. This prevents the LLM from racing to implementation without thinking, and from merging without verification.

### 3. Crystallized Patterns

When you solve a problem, you crystallize it: a small JSON file containing the problem, solution, platform context, and verification date. The next time anyone encounters that problem -- in any session, on any machine -- the hook system finds the crystal and injects the fix. You solve a problem once. It stays solved.

### 4. Architect Delegation

The main session stays lean. It understands the request, breaks it into tasks, delegates to sub-agents, and synthesizes results. Deep work happens in sub-agents with focused context. This prevents the main session from accumulating context debt, which is the primary cause of instruction drift in long-running sessions.

### 5. Verified Execution

Every build has a verification step. A separate agent, with fresh context, reviews the implementation against the spec. It returns PASS, FAIL, or INCOMPLETE. Code only commits on PASS. This is not optional. The pattern is: BUILD then VERIFY then COMMIT.

---

## Quick Start

```bash
git clone https://github.com/cloudraider-io/lattice.git
cd lattice
bash install.sh
```

That's it. No database, no Docker, no heavy dependencies. Lattice installs a `.claude/` directory structure into your project and wires up the hooks.

To use it in an existing project:

```bash
cd your-project
bash /path/to/lattice/install.sh
```

Then run `claude` as usual. The hooks fire automatically.

---

## Before and After

### Without Lattice

```
You: "Always use uv pip install, never pip directly"
Session 1: LLM uses uv pip install. Good.
Session 2: LLM uses pip install. Breaks venv.
Session 3: LLM uses uv again but forgets --system flag. Partial fix.
Session 4: LLM uses pip. You fix it manually. Again.
```

### With Lattice

```
You: crystallize the uv pip pattern once.
Session 1-N: PostToolUseFailure hook catches "pip install" failures.
             Injects crystal: "Use uv pip install, not pip directly."
             LLM corrects itself. Every time. Automatically.
```

### Without Lattice

```
You: "Review before committing"
LLM: implements feature, commits, pushes. No review.
You: "I said review first"
LLM: "You're right, I should have reviewed. Let me..."
     (implements next feature, commits, pushes. No review. Again.)
```

### With Lattice

```
feature-dev skill enforces: brainstorm -> plan -> implement -> REVIEW -> merge
Gate 4 (review) requires explicit user approval.
The LLM cannot skip it. The workflow structure prevents it.
```

---

## Who Is This For

- **AI developers** building with Claude Code who are tired of inconsistent behavior across sessions.
- **Engineering teams** using agentic AI in production who need reliability guarantees, not probabilistic suggestions.
- **Anyone** who has written the same instruction in CLAUDE.md three times and watched the LLM ignore it on the fourth.

If you have ever said "I already told you not to do that," Lattice is for you.

---

## Project Structure

```
lattice/
  .claude/
    settings.json          # Hook wiring
    CLAUDE.md              # Project instruction template
    hooks/
      subagent-start.sh    # Context injection on sub-agent spawn
      tool-failure.sh      # Error pattern matching to crystals
      pre-compact.sh       # Context preservation during compression
    skills/
      feature-dev/         # Gated development workflow
      verify-build/        # Post-implementation verification
      crystallize/         # Pattern crystallization workflow
      explore/             # Systematic codebase exploration
      debug/               # 4-phase debugging workflow
    crystals/
      index.json           # Crystal registry
      examples/            # Example crystals
  docs/
    PHILOSOPHY.md          # The 5 concepts in depth
    ARCHITECTURE.md        # How the layers interact
    WRITING-SKILLS.md      # Guide to creating custom skills
    CRYSTALLIZATION.md     # Deep dive on crystallization
  install.sh               # One-command installer
```

---

## Documentation

| Document | Purpose |
|----------|---------|
| [Philosophy](docs/PHILOSOPHY.md) | The five concepts explained in depth |
| [Architecture](docs/ARCHITECTURE.md) | How hooks, skills, crystals, and CLAUDE.md interact |
| [Writing Skills](docs/WRITING-SKILLS.md) | How to create your own gated skills |
| [Crystallization](docs/CRYSTALLIZATION.md) | The crystallization pipeline and format |

---

## Credits

Built by [CloudRaider](https://cloudraider.io) -- battle-tested in production security operations. The patterns in Lattice emerged from running autonomous AI agents against real incidents, real infrastructure, and real consequences for getting it wrong.

## License

Apache 2.0. See [LICENSE](LICENSE).
