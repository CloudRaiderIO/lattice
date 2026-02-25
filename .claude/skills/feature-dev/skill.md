---
name: feature-dev
description: Gated development workflow with 5 mandatory phases
triggers:
  - "build a feature"
  - "implement"
  - "develop"
  - "add feature"
  - "new feature"
allowed_tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# Feature Development Workflow

This skill enforces a 5-gate development workflow. Each gate requires
explicit user approval before the next phase begins. Gate 4 (Review)
can NEVER be skipped, even if the user asks.

## Gate 1: Brainstorm

Purpose: Understand the requirement before writing any code.

Steps:
1. Read the relevant existing code to understand current state
2. Identify what needs to change and what should NOT change
3. List assumptions and unknowns
4. Present a summary to the user

Output: A clear problem statement and list of unknowns.

Ask the user: "Brainstorm complete. Proceed to planning? (yes/no)"

Do NOT write any code during this gate.

## Gate 2: Plan

Purpose: Design the implementation before touching files.

Steps:
1. Define the files that will be created or modified
2. List the specific changes per file
3. Identify test cases (what should be tested)
4. Estimate the scope (number of files, lines changed)
5. Flag any risks or breaking changes

Output: An implementation plan with file list, changes, and test cases.

Ask the user: "Plan complete. Proceed to implementation? (yes/no)"

Do NOT write any code during this gate. If the plan changes scope
significantly from what the user requested, flag it explicitly.

## Gate 3: Implement

Purpose: Execute the plan from Gate 2.

Rules:
- Follow the plan. If you discover the plan is wrong, STOP and return
  to Gate 2. Do not silently deviate.
- Write tests FIRST (TDD). Tests define the expected behavior.
  Implement until tests pass.
- Make surgical changes. Do not refactor unrelated code.
- One logical change per commit.

Steps:
1. Write test cases based on the plan
2. Run tests (they should fail -- they define desired behavior)
3. Implement the feature
4. Run tests (they should pass)
5. Run existing tests (nothing should break)

Output: Working implementation with passing tests.

Ask the user: "Implementation complete. Tests passing. Proceed to review? (yes/no)"

## Gate 4: Review (MANDATORY -- CANNOT BE SKIPPED)

Purpose: Verify the implementation with fresh eyes.

This gate exists because the implementing agent accumulates context
bias -- it "knows" what the code is supposed to do, so it overlooks
issues that a fresh reader would catch.

Steps:
1. Spawn a separate review agent (or switch to review mindset)
2. The reviewer reads ONLY the plan (from Gate 2) and the changed files
3. The reviewer does NOT read the implementation conversation
4. The reviewer checks:
   - Does the code match the plan?
   - Are there edge cases not covered by tests?
   - Are there obvious bugs or logic errors?
   - Does the code follow project conventions (from CLAUDE.md)?
   - Are there any security concerns?
5. The reviewer returns PASS, FAIL, or INCOMPLETE with specific issues

If FAIL: Return to Gate 3 with the reviewer's feedback. Do not proceed.
If INCOMPLETE: Address the specific gaps, then re-run Gate 4.
If PASS: Proceed to Gate 5.

Ask the user: "Review verdict: [PASS/FAIL/INCOMPLETE]. [Details]. Proceed to merge? (yes/no)"

## Gate 5: Merge

Purpose: Commit and integrate the verified changes.

Steps:
1. Stage only the files from the plan (no unrelated changes)
2. Write a clear commit message summarizing the change
3. Commit
4. Run the full test suite one final time
5. Report the commit hash and summary

Output: Committed change with passing tests.

## Context Management Warnings

- If the implementation spans more than 5 files, consider breaking it
  into smaller features and running this workflow for each.
- If Gate 3 takes more than 20 tool calls, the scope is too large.
  Return to Gate 2 and split the plan.
- If you are losing track of what was planned vs what was implemented,
  re-read the Gate 2 plan. Do not rely on memory.
