---
description: Audit this config repo for drift — silently dropped skills, stale README, layer violations
allowed-tools: Read, Grep, Glob, Bash(git status:*), Bash(git ls-files:*), Bash(git check-ignore:*), Bash(ls:*), Bash(find:*)
---

- Tracked files: !`git ls-files`
- Skill directories: !`ls -1 skills/`
- Command files: !`ls -1 commands/`
- Working tree: !`git status --short`

## Task

Audit this repository (`~/.claude`) for configuration drift. Report findings; change nothing unless I ask.

1. **Silent drops.** Every skill directory that is mine — not a third-party clone, i.e. no nested `.git` — must have a matching `!/skills/<name>/` line in `.gitignore` and appear in `git ls-files`. This failure is invisible in normal `git status`, so it is the one that matters most. Also flag whitelist lines pointing at directories that no longer exist.
2. **README accuracy.** The skill table and repository-structure diagram in @README.md must match the tracked skills and tracked top-level paths exactly.
3. **Skill frontmatter.** Each tracked `SKILL.md` has `name` matching its directory, and a `description` stating both what it does and when to reach for it.
4. **Overlap.** No two skills claim the same territory without naming each other in their `Scope` sections.
5. **Layering.** Each layer keeps only what it owns: `CLAUDE.md` must not restate a skill's workflow, no skill may restate global behavior, and each file in `commands/` must stay a thin entry point — naming the skill it invokes and the scope it binds, never copying that skill's method or checklist.

Report each finding as: what drifted, the file evidence, and the one-line fix. If the repository is clean, say so plainly rather than manufacturing findings.
