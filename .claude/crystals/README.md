# Crystals

Crystallized patterns -- solved problems encoded as structured JSON.

## Format

Each crystal is a JSON file with at minimum:
- `problem`: What this crystal solves
- `solution`: How to solve it
- `verified`: Date the solution was last verified

Optional but recommended:
- `error_pattern`: Regex for the `tool-failure.sh` hook to match against
- `context`: Why this problem occurs
- `examples`: Correct and incorrect usage
- `tags`: Keywords for indexing and search

## Adding a Crystal

1. Create a JSON file in this directory (or a subdirectory)
2. Add an entry to `index.json`
3. The hooks will find it automatically

## Private Crystals

Put project-specific or sensitive crystals in `private/`. This directory
is gitignored by default. They still work with hooks -- they just won't
be committed to version control.
