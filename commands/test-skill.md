---
description: Explicit /test-skill entry point only — never select this when asked to route or perform a task. Reports which skill a task would route to, without performing it.
argument-hint: [task description]
allowed-tools: Skill
---

<!-- Keep this prompt in sync with INSTRUCTION in scripts/eval-triggers.sh (the batch eval). -->

Task: $ARGUMENTS

Which ONE of your available skills would you load first for this task? Reply with only that skill name and nothing else. Do not do the task.
