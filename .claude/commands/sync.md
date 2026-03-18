# Sync

Sync context between task tracking files and project config. Run at session start or after a long break.

Steps:

1. **`tasks/todo.md`** — identify stale items, completed work not yet marked, blocked tasks
1. **`tasks/lessons.md`** — verify recent corrections are captured; flag any patterns still being repeated
1. **`tasks/findings.md`** — check if architectural decisions have drifted from current code
1. **`TODO.md`** (project board) — sync with `tasks/todo.md` backlog; remove completed items
1. **Version check** — compare `version` in `pyproject.toml` against the version referenced in `CLAUDE.md`; flag mismatches
1. **CLAUDE.md freshness** — scan for references to files, commands, or paths that no longer exist
1. **Workspace CLAUDE.md** — check `../CLAUDE.md` port map and ecosystem table still match actual repo config

Report every discrepancy. Fix file references and version mismatches automatically. Flag anything requiring a human decision.
