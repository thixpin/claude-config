# Contributing

Rules and workflows for extending this configuration. 
The mechanical rules are verified by `scripts/check-config.sh`; /check-config also reviews the judgment-based rules.

## Adding a skill

Names are kebab-case and name the work, not the worker; review skills are `<subject>-review`.

Create `skills/<name>/SKILL.md`:

```markdown
---
name: my-skill
description: What it does, and when Claude should reach for it. This text is how Claude decides relevance, so be specific about triggers.
---

# My Skill

One line stating the skill's stance.

## Scope

**Use for** the tasks it owns.

**Do not use for:** the neighbouring cases, naming the skill to use instead.

The method — steps, checklists, rules.
```

Then: add a `!/skills/<name>/` line to `.gitignore` (without it the skill is silently never committed), add the table row and boundaries-diagram entry to `README.md`, and check first that no existing skill owns the territory — when two skills could apply, neither reliably does. Nothing goes in `CLAUDE.md`.

`/add-skill <name>` runs all of these steps.

## Adding a command

A command must stay a thin entry point (see the README's Commands section for when one is justified). Create `commands/<name>.md`:

```markdown
---
description: What typing this does, in one line
argument-hint: [what the argument means]
allowed-tools: Skill, Read, Bash(git status:*)
---

Context gathered up front: !`git status --short`

Load the `<skill>` skill and apply it to <the scope this command binds>.
That skill owns the method — follow it rather than restating it here.
```

The whole `commands/` directory is whitelisted — no `.gitignore` edit needed. `$ARGUMENTS` (or `$1`, `$2`) takes input, `` !`cmd` `` runs at expansion time, `@path` pulls a file into context. Keep `allowed-tools` tight — omitting `Edit`/`Write` is what makes a review command read-only.

## Adding an output style

The whole `output-styles/` directory is whitelisted. Create `output-styles/<name>.md` with `name` and `description` frontmatter; the body is the style's rules.

## Adding any other top-level path

Anything not whitelisted in `.gitignore` is dropped **silently** — no error, clean `git status`. `agents/` is pre-authorized; anything else needs its own `!/…` line first. Verify with `git status --ignored`, `scripts/check-config.sh`, or `/check-config`.

## Validation

- `bash scripts/check-config.sh` — deterministic drift checks: whitelist sync, frontmatter, README table and diagram membership. CI runs it on every push.
- `/check-config` — runs the script, then audits the judgment items: skill overlap, layering, README accuracy.
