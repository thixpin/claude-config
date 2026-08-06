# Claude Code Configuration

My personal [Claude Code](https://claude.com/claude-code) setup — global engineering guidelines, reusable skills, and the commands that invoke them, versioned so it can be restored on any machine. See [Adopting this config](#adopting-this-config).

The repository lives at `~/.claude`, where Claude Code also writes runtime state (sessions, history, caches, credentials). `.gitignore` therefore uses a whitelist: everything is ignored by default and only durable configuration is tracked.

## Design philosophy

Instructions live in layers; **the narrowest layer that can own a rule, owns it**.

| Layer                     | Holds                                                       | Loaded                         |
| ------------------------- | ----------------------------------------------------------- | ------------------------------ |
| `CLAUDE.md` (this repo)   | Global engineering behavior, for any codebase               | Always                         |
| `skills/` (this repo)     | Reusable workflows for one kind of task                     | On demand, when a task matches |
| `commands/` (this repo)   | Entry points that bind a scope and invoke a skill           | When you type `/name`          |
| `.claude/` (each project) | Project-specific knowledge: stack, commands, conventions    | Always, in that project        |

Project instructions override global ones. The split keeps context lean (workflow detail loads only when it matches), gives each rule exactly one home, and lets reusable workflows evolve without changing global behavior. `CLAUDE.md` intentionally contains only global engineering behavior; reusable workflows belong in `skills/`; a command carries no methodology of its own.

## Repository structure

```
~/.claude/
├── CLAUDE.md         # global engineering guidelines (always loaded)
├── skills/           # reusable workflows, loaded on demand
│   └── <name>/SKILL.md
├── commands/         # slash commands, invoked explicitly
│   └── <name>.md
├── README.md
└── LICENSE
```

Everything else in `~/.claude` is deliberately untracked — runtime state, and `settings.json`: it holds personal preferences (plugins, theme, model) and Claude Code rewrites it on settings changes, so versioning it would only produce noise commits of tool-authored edits.

> **Adding a top-level path?** Anything not whitelisted in `.gitignore` is dropped **silently** — no error, and `git status` stays clean. `agents/` and `output-styles/` are pre-authorized; anything else needs its own `!/…` line first. Verify with `git status --ignored`, or run `/check-config`.

## Skills

Claude discovers skills by reading each `SKILL.md`'s `description` and invokes one when a task matches — the frontmatter is the only registry.

| Skill                 | Reviews / produces | Use when                                                        |
| --------------------- | ------------------ | ---------------------------------------------------------------- |
| `debugging`           | an unknown cause   | Investigating a mystery — intermittent failures, unexplained traces, no known trigger |
| `bug-fix`             | a defect           | Fixing a bug — reproduce first, root-cause, fix minimally, add a regression test |
| `testing`             | tests              | Writing or improving tests; fixing flaky tests                    |
| `code-quality-review` | a change           | Reviewing a diff or branch for readability and maintainability     |
| `architecture-review` | the system         | Assessing structure, module boundaries, coupling; planning a refactor |
| `security-audit`      | trust boundaries   | Security review, fixing a vulnerability, hardening auth or input handling |

Names are kebab-case and name the work, not the worker; review skills are `<subject>-review`. Third-party skills can be installed by cloning into `skills/` — each stays an untracked independent clone, updated with `git pull`, keeping its upstream name and license.

### Adding a skill

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

Add a matching `!/skills/<name>/` line to `.gitignore` — skills are whitelisted by name, so without it the skill is never committed. Do **not** add anything to `CLAUDE.md`; global engineering behavior belongs there, while reusable workflows belong in `skills/`. Check first that no existing skill owns the territory: when two skills could apply, neither reliably does.

`/add-skill <name>` runs these steps, including the `.gitignore` line and the table row above.

## Commands

Slash commands are entry points, not methodology. A command exists only when it does something a skill cannot: bind a scope by running git up front, act on this repository itself, or be invoked deterministically. It names the skill it delegates to and never copies that skill's checklist — so most skills have no command, because they already trigger on their own description.

| Command          | Does                                                          | Invokes               |
| ---------------- | ------------------------------------------------------------- | --------------------- |
| `/review-changes` | Resolves the diff to review (argument, uncommitted, or branch) and reviews it read-only | `code-quality-review` |
| `/add-skill`     | Scaffolds `skills/<name>/SKILL.md`, whitelists it, adds the README row | —                     |
| `/check-config`  | Audits this repo for drift: dropped skills, stale README, layer violations | —                     |

Not commands, deliberately: `bug-fix`, `testing`, `architecture-review`, and `security-audit` trigger reliably from their own descriptions and have no scope to pre-bind; `/review`, `/code-review`, `/security-review`, `/init`, and `/run` are built in; and the skills already route to each other through their `Scope` sections, so no command composes them.

### Adding a command

Create `commands/<name>.md`:

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

Unlike `skills/`, the whole `commands/` directory is whitelisted, so a new file is tracked without editing `.gitignore`. Use `$ARGUMENTS` (or `$1`, `$2`) for input, `` !`cmd` `` to run a command at expansion time, and `@path` to pull a file into context. Keep `allowed-tools` tight — for a review command, omitting `Edit`/`Write` is what makes it read-only.

## Adopting this config

**Just the skills** — each directory is self-contained:

```bash
git clone https://github.com/thixpin/claude-config.git /tmp/claude-config
cp -r /tmp/claude-config/skills/bug-fix ~/.claude/skills/
```

Skills name each other in their `Scope` sections; copy related ones together if you want the boundaries to work as written. `commands/review-changes.md` can be copied alongside `code-quality-review`; `add-skill` and `check-config` assume this repository's layout and are not portable on their own.

**The whole config** — follow the setup below. Settings are not included; Claude Code manages your own `settings.json`. One dependency to know: `CLAUDE.md`'s preference for LSP navigation assumes an LSP plugin for your language is enabled — enable one, or drop that line.

## Setup on a new machine

```bash
git clone https://github.com/thixpin/claude-config.git ~/.claude
```

If `~/.claude` already exists (Claude Code creates it on first run), initialize in place instead of cloning over it:

```bash
cd ~/.claude
git init -b master
git remote add origin https://github.com/thixpin/claude-config.git
git fetch origin
git checkout -f master
```

## License

[MIT](LICENSE) © Soe Thura. Third-party skills installed under `skills/` are separate projects under their own licenses — see their repositories.
