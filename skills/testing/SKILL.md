---
name: testing
description: Strategy and rules for writing or improving automated tests. Use when adding tests, improving coverage, fixing flaky tests, setting up a test suite, or deciding what and how to test. Emphasizes deterministic tests, testing behavior over implementation, and a tight validation loop. For diagnosing why production code misbehaves use the bug-fix skill, which comes here for the regression test.
---

# Testing

Write tests that fail for exactly one reason, pass deterministically, and survive refactoring.

## Scope

**Use for** deciding what to test and writing it: new tests, coverage gaps, flaky tests, test structure, setting up a suite.

**Do not use for:**
- Diagnosing why production code misbehaves — use `bug-fix`, which comes here for the regression test.
- Judging non-test production code — use `code-quality-review`.

## What to test

- Test observable behavior and contracts, not implementation details. A refactor that preserves behavior should not break tests.
- Prioritize by risk: core business logic and boundary conditions first, then error paths, then integration seams. Do not chase coverage numbers for trivial code (getters, framework glue).
- Every bug fix gets a regression test (see the `bug-fix` skill).
- Follow the project's existing test framework, directory layout, naming, and assertion style — do not introduce a new test framework into a project that has one.

## Determinism

- No hidden dependencies on wall-clock time, timezones, locale, random seeds, network, or test execution order. Inject clocks, seed randomness, and fake external services at the boundary.
- Each test owns its setup and teardown; tests must pass in isolation and in any order.
- Treat a flaky test as a bug: find the nondeterminism, do not add retries or sleeps to mask it. Prefer explicit waits on conditions over fixed delays.

## Structure

- One behavior per test; name the test after the behavior and expected outcome, in the project's naming convention.
- Arrange–act–assert (or given–when–then), kept visually distinct.
- Prefer real objects over mocks; mock only at process or network boundaries. Heavy mocking usually signals the unit under test is doing too much.
- Keep test data minimal and meaningful — only the fields the behavior depends on.

## Validation loop

- While developing, run only the affected test file or case; run the broader suite before declaring the work done.
- Confirm a new test can fail: break the behavior mentally (or actually) and check the test would catch it. A test that cannot fail is worse than no test.
