#!/usr/bin/env bash

# Behavioral trigger eval:
# Does each skill's frontmatter description route the right task to it?
#
# This probes routing only. Each prompt asks Claude to name the ONE skill
# it would load first, without doing the task.
#
# Non-deterministic and token-costed:
#   - Run before tagging a release.
#   - Run after editing any skill description.
#   - Deliberately NOT in CI.
#
# Usage:
#   bash scripts/eval-triggers.sh
#   EVAL_MODEL=haiku bash scripts/eval-triggers.sh
#   EVAL_RUNS=3 bash scripts/eval-triggers.sh
#   EVAL_RUNS=3 EVAL_MODEL=haiku bash scripts/eval-triggers.sh
#
# Exit codes:
#   0 = all behavioral evaluations passed
#   1 = one or more behavioral evaluations failed
#   2 = evaluator/environment error

set -uo pipefail

cd "$(dirname "$0")/.."

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

EVAL_MODEL="${EVAL_MODEL:-}"
EVAL_RUNS="${EVAL_RUNS:-1}"

if ! [[ "$EVAL_RUNS" =~ ^[1-9][0-9]*$ ]]; then
  printf 'ERROR: EVAL_RUNS must be a positive integer, got: %s\n' "$EVAL_RUNS" >&2
  exit 2
fi

INSTRUCTION='Which ONE of your available skills would you load first for this task? Reply with only that skill name and nothing else. Do not do the task.'

pass=0
failed=0
errors=0
total=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

normalize() {
  # Claude is instructed to return only the skill name, but normalize a little
  # defensively so harmless formatting does not create false negatives.
  tr '[:upper:]' '[:lower:]' |
    tr -d '`' |
    sed '/^[[:space:]]*$/d' |
    head -n 1 |
    xargs
}

run_claude() {
  local prompt=$1
  local -a args

  args=(-p)

  if [[ -n "$EVAL_MODEL" ]]; then
    args+=(--model "$EVAL_MODEL")
  fi

  claude "${args[@]}" "$prompt

$INSTRUCTION"
}

run() {
  local expected=$1
  local prompt=$2
  local run_number
  local answer
  local normalized
  local attempt_pass
  local attempt_error

  total=$((total + 1))

  printf '\n[%s]\n' "$expected"
  printf '  prompt: %s\n' "$prompt"

  attempt_pass=0
  attempt_error=0

  for ((run_number = 1; run_number <= EVAL_RUNS; run_number++)); do
    answer=$(run_claude "$prompt" 2>/dev/null)
    local claude_status=$?

    if ((claude_status != 0)); then
      printf '  run %d/%d: ERROR (claude exit %d)\n' \
        "$run_number" "$EVAL_RUNS" "$claude_status"
      attempt_error=1
      continue
    fi

    normalized=$(printf '%s' "$answer" | normalize)

    if [[ "$normalized" == "$expected" ]]; then
      printf '  run %d/%d: PASS (%s)\n' \
        "$run_number" "$EVAL_RUNS" "$normalized"
      attempt_pass=$((attempt_pass + 1))
    else
      printf '  run %d/%d: FAIL (got: %s)\n' \
        "$run_number" "$EVAL_RUNS" "${normalized:-<empty>}"
    fi
  done

  # Any evaluator/runtime error means this test could not be evaluated.
  if ((attempt_error > 0)); then
    errors=$((errors + 1))
    return
  fi

  # Every run must pass. This makes EVAL_RUNS=3 a strict stability check.
  if ((attempt_pass == EVAL_RUNS)); then
    pass=$((pass + 1))
  else
    failed=$((failed + 1))
  fi
}

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------

if ! command -v claude >/dev/null 2>&1; then
  printf 'ERROR: claude CLI not found in PATH\n' >&2
  exit 2
fi

if ! claude --help >/dev/null 2>&1; then
  printf 'ERROR: claude CLI is not usable\n' >&2
  exit 2
fi

printf '%s\n' '========================================'
printf '%s\n' 'Claude Skill Trigger Evaluation'
printf '%s\n' '========================================'
printf 'model: %s\n' "${EVAL_MODEL:-default}"
printf 'runs per case: %s\n' "$EVAL_RUNS"
printf '%s\n' '----------------------------------------'

# ---------------------------------------------------------------------------
# Direct hits
# ---------------------------------------------------------------------------

printf '\nDIRECT HITS\n'

run debugging \
  'Our API intermittently returns 500 errors in production, roughly 1 in 50 requests. No pattern found yet; root cause unknown.'

run bug-fix \
  'parse_row() crashes on empty input because it indexes row[0] unconditionally — the cause is confirmed. Fix it.'

run testing \
  'Add unit tests for the new pagination helper in utils/pagination.py.'

run code-quality-review \
  'Review the diff on this branch for readability and maintainability before I merge it.'

run architecture-review \
  'Assess whether our module boundaries and layering are sound across the codebase, and where the structural debt is.'

run security-audit \
  'Harden the login endpoint: check the auth flow, rate limiting, and how secrets are handled.'

run infra-design \
  'Propose the AWS infrastructure for a new low-traffic web app. Keep it as simple as possible.'

run terraform-review \
  'Here is the terraform plan output before I apply — it shows a destroy/create on the RDS instance. Review it.'

# ---------------------------------------------------------------------------
# Near misses / boundaries
# ---------------------------------------------------------------------------

printf '\nBOUNDARY / NEAR-MISS CASES\n'

run debugging \
  'One of our tests fails randomly, and we have confirmed the production code itself behaves nondeterministically.'

run testing \
  'One of our tests fails randomly; the production code is sound — the tests share fixtures and depend on execution order.'

run bug-fix \
  'We already know the root cause of the checkout total bug. Write the fix and its regression test.'

run infra-design \
  'Should this new service run on ECS or Lambda? Weigh the trade-offs and recommend a setup.'

# ---------------------------------------------------------------------------
# Negative / explicit-boundary cases
# ---------------------------------------------------------------------------

printf '\nEXPLICIT-BOUNDARY CASES\n'

run code-quality-review \
  'Review this PR for readability, naming, duplication, and maintainability. Do not redesign the system architecture.'

run architecture-review \
  'Evaluate the system-wide module boundaries and dependency direction. Do not focus on formatting or local code style.'

run security-audit \
  'Review this change specifically for authentication, authorization, secret handling, and trust-boundary problems.'

run terraform-review \
  'Review this Terraform implementation and plan for unsafe resource changes. Do not design a new infrastructure architecture.'

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

printf '\n%s\n' '========================================'
printf '%s\n' 'SUMMARY'
printf '%s\n' '========================================'

printf 'cases evaluated : %d\n' "$total"
printf 'passed           : %d\n' "$pass"
printf 'failed           : %d\n' "$failed"
printf 'errors           : %d\n' "$errors"

if ((total > 0)); then
  # Integer percentage; no external calculator required.
  evaluated=$((pass + failed))

  if ((evaluated > 0)); then
    rate=$((pass * 100 / evaluated))
    printf 'pass rate        : %d%%\n' "$rate"
  else
    printf 'pass rate        : N/A\n'
  fi
fi

printf '%s\n' '----------------------------------------'

if ((errors > 0)); then
  printf 'RESULT: ERROR — one or more evaluations could not run.\n'
  exit 2
fi

if ((failed > 0)); then
  printf 'RESULT: FAIL — one or more routing evaluations failed.\n'
  exit 1
fi

printf 'RESULT: PASS — all routing evaluations passed.\n'
exit 0
