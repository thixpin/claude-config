---
description: Scaffold a new skill in this config repo, wired into .gitignore and the README
argument-hint: <skill-name> [one-line purpose]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git status:*), Bash(git check-ignore:*), Bash(git ls-files:*), Bash(ls:*)
---

Add a skill named `$1` to this repository (`~/.claude`). Stated purpose, if any: $ARGUMENTS

@README.md's "Adding a skill" section is the source of truth for the `SKILL.md` shape and the naming rules — read it and follow it; do not reproduce it here.

Steps:

1. **Check the territory is free.** Read the `description` and `Scope` of each skill under `skills/`. If one already owns this work, say so and stop — when two skills could apply, neither triggers reliably. If the new skill merely *borders* an existing one, note the boundary and propose (do not silently apply) the matching `Scope` edit to the neighbour.
2. **Write `skills/$1/SKILL.md`** from the README's template. The frontmatter `description` is the only registry Claude reads: state both what the skill does and the concrete triggers for reaching for it, and name the neighbouring skills it defers to.
3. **Whitelist it.** Add `!/skills/$1/` to `.gitignore` beside the other skill lines. Without this the skill is dropped silently — no error, clean `git status`.
4. **Document it.** Add one row to the README's skill table, matching the existing column style.
5. **Verify.** `git check-ignore skills/$1/SKILL.md` must find no match, and the file must appear as untracked in `git status`. Report both results.

Do not add anything to `CLAUDE.md` — global engineering behavior lives there, reusable workflows live in `skills/`. Do not commit unless I ask.
