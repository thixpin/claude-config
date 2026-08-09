#!/usr/bin/env bash
# Mechanical half of /check-config: deterministic drift checks, runnable
# locally or in CI. Judgment checks (skill overlap, layering) stay in
# commands/check-config.md.
set -u
cd "$(dirname "$0")/.."

fail=0
err() { printf 'FAIL: %s\n' "$*"; fail=1; }

# Local skills (no nested .git) must be whitelisted, unignored, complete,
# and documented in the README table and boundaries diagram.
for d in skills/*/; do
  name=${d#skills/}; name=${name%/}
  [ -e "${d}.git" ] && continue # third-party clone: deliberately untracked
  [ -f "${d}SKILL.md" ] || { err "skills/$name has no SKILL.md"; continue; }
  grep -qxF "!/skills/$name/" .gitignore || err "skills/$name not whitelisted in .gitignore"
  git check-ignore -q "${d}SKILL.md" && err "skills/$name/SKILL.md is ignored by git"
  head -n1 "${d}SKILL.md" | grep -qx -- '---' || err "skills/$name/SKILL.md: no frontmatter"
  grep -qx "name: $name" "${d}SKILL.md" || err "skills/$name/SKILL.md: frontmatter name != directory"
  grep -q '^description: .' "${d}SKILL.md" || err "skills/$name/SKILL.md: missing description"
  grep -q "| \`$name\`" README.md || err "README skill table: missing $name"
  awk '/^```mermaid/,/^```$/' README.md | grep -q "\[$name\]" || err "README boundaries diagram: missing $name"
done

# Whitelist lines must point at existing skill directories.
for name in $(sed -n 's|^!/skills/\(.*\)/$|\1|p' .gitignore); do
  [ -d "skills/$name" ] || err ".gitignore whitelists skills/$name which does not exist"
done

# README skill-table rows must point at existing skill directories.
for name in $(sed -n 's/^| `\([a-z][a-z-]*\)`.*/\1/p' README.md); do
  [ -d "skills/$name" ] || err "README skill table lists $name but skills/$name does not exist"
done

# Commands need a description; output styles need name and description.
for f in commands/*.md; do
  grep -q '^description: .' "$f" || err "$f: missing description"
done
for f in output-styles/*.md; do
  grep -q '^name: .' "$f" || err "$f: missing name"
  grep -q '^description: .' "$f" || err "$f: missing description"
done

[ "$fail" -eq 0 ] && echo "OK: config is consistent"
exit "$fail"
