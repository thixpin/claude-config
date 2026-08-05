---
description: Review my working changes against the code-quality-review standard
argument-hint: [paths or git ref — defaults to uncommitted changes]
allowed-tools: Skill, Read, Grep, Glob, Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git merge-base:*), Bash(git branch:*)
---

Requested scope: $ARGUMENTS

- Working tree: !`git status --short`
- Uncommitted diffstat: !`git diff --stat HEAD`

## Task

Load the `code-quality-review` skill and review the changes below against it. That skill owns the method, the checklist, and the severity levels — follow it rather than reviewing from memory, and do not restate it back to me.

Resolve the scope first:

- Argument given → review exactly that: the named paths, or a ref range such as `main..HEAD`.
- No argument, uncommitted work present → review the uncommitted changes.
- No argument, working tree clean → review this branch against its merge-base with the default branch.

State the resolved scope in one line before the findings.

Read enough surrounding code to judge each change in its real context, not just the diff hunks. Where the skill hands a finding off — system-wide structure to `architecture-review`, trust boundaries to `security-audit` — hand it off rather than answering it here.

Review only. Do not change any code unless I ask.
