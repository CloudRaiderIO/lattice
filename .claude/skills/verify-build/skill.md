---
name: verify-build
description: Post-implementation verification with fresh context
triggers:
  - "verify"
  - "review build"
  - "check implementation"
  - "verify build"
allowed_tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# Verify Build Skill

This skill performs a fresh-context review of an implementation.
It is the enforcement mechanism behind the BUILD -> VERIFY -> COMMIT pattern.

## Purpose

The agent that built something has context bias. It knows what the code
is supposed to do, so it reads what it expects to see, not what is
actually there. A verification agent starts fresh, reads the spec,
reads the code, and makes an independent judgment.

## Inputs Required

Before starting, you need:
1. **The spec**: What was the code supposed to do? (A plan, a ticket, a description)
2. **The file list**: Which files were created or modified?
3. **The test file(s)**: Where are the tests for this change?

If any of these are missing, ask the user before proceeding.

## Verification Process

### Phase 1: Read the Spec

Read the specification or plan document. Understand what the code
should accomplish. Note the acceptance criteria.

Do NOT read the implementation yet. Form expectations first.

### Phase 2: Read the Tests

Read the test files. Do the tests cover the acceptance criteria?
Note any gaps between what the spec requires and what the tests verify.

Tests are READ-ONLY during verification. If you find test issues,
report them. Do not fix them. That is the implementor's job.

### Phase 3: Read the Implementation

Now read the implementation files. Check against your expectations
from Phase 1 and the test coverage from Phase 2.

Check for:
- Logic errors (code does not match spec intent)
- Edge cases not handled (spec implies them, code ignores them)
- Convention violations (check CLAUDE.md for project rules)
- Security issues (injection, auth bypass, data exposure)
- Performance concerns (N+1 queries, unbounded loops, missing pagination)
- Error handling (what happens when things fail?)

### Phase 4: Run the Tests

Execute the test suite. Observe:
- Do all tests pass?
- Are there any flaky tests?
- Is test coverage adequate for the changed code?

### Phase 5: Deliver Verdict

Return one of three verdicts:

**PASS**: The implementation matches the spec, tests are adequate,
no significant issues found. Safe to commit.

**FAIL**: There are specific issues that must be fixed before committing.
List each issue with:
- File and line number
- What is wrong
- Why it matters

**INCOMPLETE**: The implementation partially meets the spec but is
missing functionality. List what is done and what remains.

## Rules

1. Tests are READ-ONLY. Report issues, do not fix them.
2. Do not refactor. You are reviewing, not rewriting.
3. Be specific. "Code looks wrong" is not useful. "Line 47 in auth.ts
   checks token expiry with > instead of >=, which means tokens are
   accepted one second past expiry" is useful.
4. If you are unsure about something, flag it as a question rather
   than a pass or fail. Uncertainty is honest. False confidence is not.
5. Do not let the implementation agent's comments or commit messages
   influence your judgment. Read the code, not the narrative.
