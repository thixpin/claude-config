# Claude Code Configuration

My personal [Claude Code](https://claude.com/claude-code) setup — global engineering guidelines and reusable skills, versioned so it can be restored on any machine. See [Adopting this config](#adopting-this-config).

The repository lives at `~/.claude`, where Claude Code also writes runtime state (sessions, history, caches, credentials). `.gitignore` therefore uses a whitelist: everything is ignored by default and only durable configuration is tracked.

## Design philosophy

Instructions live in three layers; **the narrowest layer that can own a rule, owns it**.

| Layer                     | Holds                                                       | Loaded                         |
| ------------------------- | ----------------------------------------------------------- | ------------------------------ |
| `CLAUDE.md` (this repo)   | Global engineering behavior, for any codebase               | Always                         |
| `skills/` (this repo)     | Reusable workflows for one kind of task                     | On demand, when a task matches |
| `.claude/` (each project) | Project-specific knowledge: stack, commands, conventions    | Always, in that project        |

Project instructions override global ones. The split keeps context lean (workflow detail loads only when it matches), gives each rule exactly one home, and lets skills change without touching global behavior. `CLAUDE.md` stays short because every line costs context on every task; `skills/` is the layer meant to grow.

## Repository structure

```
~/.claude/
├── CLAUDE.md         # global engineering guidelines (always loaded)
├── skills/           # reusable workflows, loaded on demand
│   └── <name>/SKILL.md
├── README.md
└── LICENSE
```

Everything else in `~/.claude` is deliberately untracked — runtime state, and `settings.json`: it holds personal preferences (plugins, theme, model) and Claude Code rewrites it on settings changes, so versioning it would only produce noise commits of tool-authored edits.

> **Adding a top-level path?** Anything not whitelisted in `.gitignore` is dropped **silently** — no error, and `git status` stays clean. `commands/`, `agents/`, and `output-styles/` are pre-authorized; anything else needs its own `!/…` line first. Verify with `git status --ignored`.

## Skills

Claude discovers skills by reading each `SKILL.md`'s `description` and invokes one when a task matches — the frontmatter is the only registry.

| Skill                 | Reviews / produces | Use when                                                        |
| --------------------- | ------------------ | ---------------------------------------------------------------- |
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

Add a matching `!/skills/<name>/` line to `.gitignore` — skills are whitelisted by name, so without it the skill is never committed. Do **not** add it to `CLAUDE.md`, which intentionally holds no skill list. And check first that no existing skill owns the territory: when two skills could apply, neither reliably does.

## Adopting this config

**Just the skills** — each directory is self-contained:

```bash
git clone https://github.com/thixpin/claude-config.git /tmp/claude-config
cp -r /tmp/claude-config/skills/bug-fix ~/.claude/skills/
```

Skills name each other in their `Scope` sections; copy related ones together if you want the boundaries to work as written.

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
