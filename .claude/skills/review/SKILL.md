---
name: review
description: Review the current uncommitted change in a fresh context before committing. Use after implementing a ticket, or when asked to review the diff.
---

Review the current working tree changes with the `reviewer` subagent.

1. Make sure there is something to review: run `git status`. If the tree is clean, say so and stop.
2. Delegate to the `reviewer` subagent. Tell it to read `PLAN.md` (if present) and the diff, and to report only correctness, plan-conformance, test-quality, security and convention findings.
3. Relay its findings to the user unchanged, ordered by severity, with its verdict.
4. For each finding, decide whether it affects correctness or the acceptance criteria. Fix those and re-run the review. Mention the rest as optional instead of acting on them, to avoid over-engineering.

For a broader bug hunt on a branch or pull request, the built-in `/code-review` command is an alternative; this skill is the quick pre-commit check that is aware of `PLAN.md`.
