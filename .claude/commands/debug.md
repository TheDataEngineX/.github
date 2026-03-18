# Debug

Debug the reported issue autonomously.

Steps:

1. **Reproduce** — run the failing command, test, or import exactly as described
1. **Read carefully** — parse the full error message, stack trace, and logs; find the deepest frame in our code (not in a library)
1. **Root cause** — trace from symptom to actual cause; check `tasks/lessons.md` for known patterns first
1. **Search** — find related code in `src/<package>/` and tests that might expose the issue
1. **Fix** — minimal change targeting the root cause; if the fix touches more than 3 files, re-evaluate scope
1. **Validate** — run `/validate` to confirm the fix and check for regressions
1. **Capture** — if this reveals a new failure pattern, add it to `tasks/lessons.md`

Rules:

- Root cause only — don't patch symptoms or add workarounds
- No hand-holding — reproduce and fix without asking clarifying questions unless genuinely blocked
- If the fix feels like a hack, find the elegant solution
- Never use `--no-verify`, `# type: ignore`, or `# noqa` to silence an error without understanding it
