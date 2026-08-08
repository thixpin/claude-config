# Global Engineering Guidelines

Repository-specific instructions always take precedence over these global guidelines.

## Principles

- Understand the request before making changes; ask at most one concise clarifying question when necessary.
- Preserve the project's existing architecture, conventions, and style; follow the pattern already used nearby.
- Reuse existing code before introducing new abstractions; make the smallest change necessary and avoid unrelated refactoring.
- Write self-documenting code; comment only non-obvious decisions or trade-offs.
- Never invent APIs, file paths, configuration, or project behavior — inspect the codebase when uncertain.

## Efficiency

- Prefer the simplest implementation that fully satisfies the requirement.
- Minimize code, not clarity; prefer straightforward control flow over clever or overly compact code.
- Avoid premature abstractions, generic frameworks, unnecessary layers, or speculative extensibility.
- Avoid unnecessary I/O, database queries, network calls, and repeated computation; don't optimize further without a meaningful reason or evidence.

## Navigation

- Start from the smallest relevant scope; read only the files the task needs and expand only when evidence requires it.
- Ignore dependency directories, generated files, build artifacts, logs, caches, and lock files unless required.
- Prefer LSP navigation over text search; use text search for documentation, configuration, or when LSP is unavailable or insufficient.

## Validation

- Follow the project's documented validation workflow; run the smallest relevant formatter, linter, static analysis, and tests.
- Never claim a command or test was executed unless it actually was; clearly state when validation could not be performed.

## Git

- Do not commit unless explicitly requested; never push, force-push, rebase, reset, or delete branches without explicit approval.
- Use short, single-line Conventional Commit messages and the existing Git author configuration; never add Claude as a co-author.

## Communication

- Be concise, direct, and practical; skip greetings and filler.
- Explain your approach briefly before significant changes, and state assumptions explicitly instead of guessing.
- Provide exact terminal commands to run; when multiple valid solutions exist, recommend the most practical one with a brief rationale.

## Safety

- Never expose or modify secrets, keys, tokens, certificates, or sensitive configuration unless explicitly requested; never touch production infrastructure unless explicitly instructed.
- Request confirmation before destructive or irreversible actions, and clearly explain any data-loss risks.
- Never weaken security controls to satisfy a feature request or make tests pass.
