---
description: Scaffold a new skill in this config repo, wired into .gitignore and the README
argument-hint: <skill-name> [one-line purpose]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git status:*), Bash(git check-ignore:*), Bash(git ls-files:*), Bash(ls:*)
---

Arguments: $ARGUMENTS

The first whitespace-separated token of the arguments is the skill name — `<name>` below; anything after it is the stated purpose. If the first token is not a plausible kebab-case skill name, say so and stop rather than scaffolding a misnamed directory. Add the skill `<name>` to this repository (`~/.claude`).

@CONTRIBUTING.md's "Adding a skill" section is the source of truth for the `SKILL.md` shape and the naming rules — read it and follow it; do not reproduce it here.

Steps:

1. **Check the territory is free.** Read the `description` and `Scope` of each skill under `skills/`. If one already owns this work, say so and stop — when two skills could apply, neither triggers reliably. If the new skill merely *borders* an existing one, note the boundary and propose (do not silently apply) the matching `Scope` edit to the neighbour.
2. **Write `skills/<name>/SKILL.md`** from the README's template. The frontmatter `description` is the only registry Claude reads: state both what the skill does and the concrete triggers for reaching for it, and name the neighbouring skills it defers to.
3. **Whitelist it.** Add `!/skills/<name>/` to `.gitignore` beside the other skill lines. Without this the skill is dropped silently — no error, clean `git status`.
4. **Document it.** Add one row to the README's skill table, matching the existing column style, and add the skill to the README's boundaries diagram: a branch from the decision node, plus a dotted edge for each Scope handoff.
5. **Verify.** Run `scripts/check-config.sh` — it must pass, covering the whitelist, frontmatter, table row, and diagram entry. Report its output.

Do not add anything to `CLAUDE.md` — global engineering behavior lives there, reusable workflows live in `skills/`. Do not commit unless I ask.
