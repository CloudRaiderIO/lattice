---
name: debug
description: Systematic 4-phase debugging workflow
triggers:
  - "debug"
  - "fix bug"
  - "not working"
  - "broken"
  - "error"
  - "failing"
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Debug Skill

This skill enforces a systematic debugging workflow that prevents the
most common LLM debugging failure: jumping to a fix before understanding
the problem. Each phase builds on the previous one. Do not skip phases.

## Phase 1: Identify

Purpose: Understand what is actually happening vs what should happen.

Steps:
1. Reproduce the error. Run the failing command or test. Read the
   actual error output. Do not work from a description alone.
2. Identify the exact error: file, line number, error message.
3. Identify the expected behavior: what should have happened instead?
4. State the gap clearly: "X happens, but Y should happen."

Questions to ask the user (if not already clear):
- When did this start happening? (Was it working before?)
- What changed recently? (New code, dependency update, config change?)
- Does it happen every time or intermittently?

Output: A clear problem statement with reproduction steps.

Do NOT propose a fix during this phase.

## Phase 2: Isolate

Purpose: Narrow down where the bug lives.

Steps:
1. Start at the error location (file and line from Phase 1)
2. Trace the call chain: what called this function? What data did it receive?
3. Check inputs: is the function receiving what it expects?
4. Check the boundary: find the point where correct data becomes incorrect

Techniques (use the simplest one that works):
- **Read the code**: Often the bug is visible in the logic
- **Check recent changes**: git diff or git log on the relevant files
- **Add logging**: Temporary console.log/print at key points
- **Simplify**: Can you reproduce with a minimal input?
- **Binary search**: If you have a working and broken state, narrow
  the difference (works for both code changes and data)

Output: "The bug is in [file]:[function] because [specific reason]."

Do NOT fix the bug during this phase.

## Phase 3: Narrow

Purpose: Confirm the root cause, not just a symptom.

Steps:
1. Verify your isolation hypothesis: if you change the identified
   cause, does the bug go away?
2. Check for related issues: is this a one-off or a pattern?
   Are there other places with the same bug?
3. Understand why: why was the code written this way? Was the bug
   introduced by a misunderstanding, a missed edge case, or a regression?

Root cause categories:
- **Logic error**: The code does not implement the intended algorithm
- **Edge case**: The code works for common inputs but fails for unusual ones
- **State issue**: The code assumes state that is not guaranteed
- **Race condition**: Timing-dependent failure
- **Environment**: Works on one platform/config but not another
- **Data**: The code is correct but the input data is unexpected

Output: "The root cause is [X] because [Y]. It was introduced by [Z]."

## Phase 4: Fix and Verify

Purpose: Apply the minimal correct fix and prove it works.

Steps:
1. Write the fix. Change as little as possible. Do not refactor.
   Do not "improve" nearby code. Fix the bug.
2. Run the failing test/command. It should now pass.
3. Run the full test suite. Nothing else should break.
4. If the bug was an edge case, add a test for that specific case
   so it cannot regress.

Output: The fix (file, change) and verification (test results).

## Rules

1. Never skip Phase 1. "I think I know what the bug is" is not a
   substitute for reproducing it.
2. Never fix in Phase 2. Isolation and fixing are separate cognitive
   tasks. Combining them leads to wrong fixes.
3. Minimal fixes only. The urge to refactor while fixing a bug is
   how new bugs are born.
4. One bug at a time. If you discover a second bug during investigation,
   note it separately. Fix the original bug first.
5. If the fix is more than 10 lines, reconsider. Most bug fixes are
   small. A large fix may mean you are addressing a symptom, not the cause.
