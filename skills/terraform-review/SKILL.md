---
name: terraform-review
description: Method for reviewing Terraform/OpenTofu infrastructure-as-code changes for blast radius, state safety, and drift before apply. Use when reviewing a Terraform plan or diff, writing or changing .tf files, restructuring modules, or before running terraform apply. Reviews the implementation of a design — designing the infrastructure itself belongs to infra-design; for IAM/secret depth also use security-audit; for application architecture use architecture-review.
---

# Terraform Review

Judge infrastructure changes by blast radius and reversibility, not by diff size. A one-line change can destroy a database; a hundred-line module refactor can be a no-op.

## Scope

**Reviews the implementation** — the Terraform/OpenTofu code and plan that realize an infrastructure design.

**Use for** Terraform/OpenTofu changes: resources, modules, state, providers, variables/outputs, and plan review before apply.

**Do not use for:**
- Designing the infrastructure or weighing architecture trade-offs (topology, managed versus self-hosted, capacity) — use `infra-design`. This skill takes the design as given and reviews how the code realizes it.
- Application code security review — use `security-audit`. IAM policies and secrets inside Terraform are the exception: apply both skills together.
- Multi-service system structure not expressed in Terraform — use `architecture-review`.
- CI/CD pipeline logic, unless the pipeline itself is defined as Terraform resources.

## Method

1. **Read the plan, not just the diff.** `terraform plan` output reveals the actual blast radius — a diff can look like a rename but the plan shows `destroy` + `create` because the resource's identity changed.
2. **Flag every destroy or replace on stateful resources** — databases, volumes, DNS records, anything holding data or an external dependency. Call these out explicitly and check for `lifecycle { prevent_destroy = true }` or a migration plan before data is lost.
3. **Verify state safety** — remote backend with locking; no local `.tfstate` committed to git; no hardcoded paths that only work on one machine.
4. **Check module boundaries** — reusable logic factored into modules with explicit inputs and outputs; no module reaching into another's resources or provider configuration.
5. **Audit secrets and IAM** — no plaintext secrets in tracked files or exposed in state; credential variables marked `sensitive = true`; secrets pulled via secret-manager reference, never literals; no wildcard `Action: "*"` / `Resource: "*"` IAM without explicit justification. Deeper security analysis belongs to `security-audit`.
6. **Confirm version pinning** — `required_version`, `required_providers`, and module sources pinned to a version or commit, never a floating branch (`?ref=main`), so the next apply cannot silently change behavior.
7. **Check naming and tagging consistency** — resources follow the project's existing convention (environment, owner, cost-center) so cost and ownership stay traceable.
8. **Flag drift risk** — configuration that depends on state mutated outside Terraform (manual console changes, imperative scripts) is fragile; note it even if out of scope to fix now.

## Judgment calls

- If the plan shows a destroy/replace the diff doesn't obviously explain, stop and ask before running apply — do not assume it's safe because the source change looked small.
- Changes touching production state require explicit confirmation before `apply`, per `CLAUDE.md`'s Safety section — this skill identifies the risk; it does not authorize proceeding past it.
- If the project already has an established module structure or naming scheme that differs from general best practice, follow the project's pattern instead of imposing a new one.
- If the review reveals the *design* is wrong — a component with no justifying requirement, a missing reliability or cost consideration — hand that finding to `infra-design` rather than redesigning inside the review.
