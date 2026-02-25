# Lattice Preserve File
#
# Everything in this file is injected into the context window during
# compaction (via the PreCompact hook). Use it for facts that MUST
# survive when older conversation turns are dropped.
#
# Keep this file short. Only include what is truly critical.
# If it grows beyond ~50 lines, you are preserving too much.
#
# Examples of what belongs here:
# - Database connection details (host, port, user, database)
# - API authentication patterns (OAuth vs basic, token endpoints)
# - Critical anti-patterns that cause production incidents
# - Project-specific conventions the LLM keeps forgetting
#
# Examples of what does NOT belong here:
# - General coding style preferences (put in CLAUDE.md)
# - Full architecture descriptions (put in docs/)
# - Anything easily rediscovered by reading the codebase

# --- Add your critical context below this line ---
