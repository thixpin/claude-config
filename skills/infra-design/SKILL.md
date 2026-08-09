---
name: infra-design
description: Simplest-first workflow for designing and proposing infrastructure — pin the requirements, draft the minimal design, then add complexity only where performance, reliability, security, or cost demands justify it. Use when designing new infrastructure, proposing a deployment or hosting architecture, choosing between managed services, planning capacity and scaling, or comparing infrastructure options. Reviewing an existing system's structure belongs to architecture-review; reviewing the Terraform change that implements a design belongs to terraform-review.
---

# Infrastructure Design

Start with the simplest design that satisfies the requirements. Add complexity only when performance, reliability, security, or operational requirements justify it.

## Scope

**Designs and proposes infrastructure** — how a system should be deployed, hosted, scaled, and operated.

**Use for** designing or proposing infrastructure: deployment and hosting architecture, service topology, managed versus self-hosted choices, capacity and scaling strategy, network layout, environments.

**Do not use for:**

- Assessing an existing system's structure, module boundaries, or coupling — use `architecture-review`. This skill proposes what to build; that one judges what already exists.
- Reviewing the Terraform/OpenTofu change that implements a design — use `terraform-review`.
- Reviewing application code for security — use `security-audit`; the Security step below applies its standards to the design instead.

## Workflow

Work through the steps in order. Each step may add to the design only what the previous step's design fails to satisfy, and every addition carries the requirement that forced it.

1. **Requirements.** Pin the workload facts before designing anything: traffic and data volume (current and a realistic horizon), latency and availability targets, compliance constraints, budget, and the team's operational capacity. Separate stated requirements from assumptions, and write the assumptions down.
2. **Simple.** Draft the minimal design that meets the functional requirements — fewest moving parts, managed services over self-hosted, a single region, technology the team already operates. This baseline is what every later addition must justify itself against.
3. **Performance.** Test the baseline against the load and latency numbers from step 1. Add capacity, caching, async processing, or read replicas only where a number says the baseline falls short — never because a pattern is popular.
4. **Reliability.** Take the availability target and the failure modes that matter, then add redundancy, health checks, backups with tested restore, or failover only as far as the target requires. Every standby and replica must map to a stated availability, RPO, or RTO requirement.
5. **Security.** Draw the trust boundaries and secure them: network segmentation, least-privilege IAM, secret management, encryption in transit and at rest. Apply the `security-audit` skill's standards to the design; a security addition needs a threat, not a checkbox.
6. **Cost & operational complexity.** Price the full design — compute, storage, egress, observability — and count what the team must operate, patch, and wake up for. If either is out of proportion to the requirement it serves, return to the step that added the offending component and simplify.
7. **Final design.** Present the design with each component annotated with the requirement that justifies it, the simpler alternative that was rejected and why, and the known limits — the point at which the design must evolve, and roughly into what.

## Rules

- - Every non-trivial component must have a clear requirement-based justification; remove components justified only by "best practice" or speculation.
- Prefer boring: managed over self-hosted, fewer technologies over the optimal tool per slot, one region until a requirement says otherwise.
- Design for the stated horizon, not speculative scale — note the evolution path instead of building it now.
- When a requirement genuinely cannot be met simply (hard multi-region, strict compliance, extreme scale), the complexity is justified — record which requirement forced it.
- When a trade-off is genuinely open, present the options with their costs and recommend one; do not present a menu without a recommendation.
