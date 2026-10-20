---
name: ticket-workflow
description: Implement a helpdesk feature or fix with a mandatory human approval gate before any source change. Invoke manually with /ticket-workflow <what to build>.
disable-model-invocation: true
argument-hint: <feature or fix description>
---

Work on this request: $ARGUMENTS

Follow the phases in order. Do not skip or merge phases.

## 1. Explore (read-only)
- Read the relevant code under `src/` and `tests/` and `CLAUDE.md` conventions.
- Find existing patterns to reuse (an existing command, handler, validator or test to copy the shape of).
- If the area is large, delegate the reading to a subagent so the main context stays small.
- Do not edit anything in this phase.

## 2. Plan
Write `PLAN.md` in the repository root (it is gitignored) with:
- **Goal**: one or two sentences.
- **Acceptance criteria**: observable behaviours, one per line.
- **Tests first**: the exact test cases you will write, named after the behaviour they pin down.
- **Files**: which files you will create or change, and why.
- **Out of scope**: what you are deliberately not doing.
- **Verification**: the commands that prove it works (`dotnet build`, `dotnet test`).

If the request is a one-line change you could describe in a single sentence, say so in the plan and keep it to a few lines.

## 3. Approval gate (stop here)
Show the plan summary and **stop**. Ask the human to review `PLAN.md`.
Do not continue until they approve. Approval is recorded by the human running:

```
! bash .claude/hooks/approve-plan.sh
```

A PreToolUse hook blocks edits under `src/` and `tests/` until that marker exists, and blocks you from creating it yourself.
If your edit is blocked, that is the gate working: go back to asking for approval, do not look for a way around it.

If the human asks for changes, update `PLAN.md` and stop again.

## 4. Implement, test first
- Write the failing tests from the plan, run them, and confirm they fail for the right reason.
- Implement the minimum to make them pass. Keep to the conventions in `CLAUDE.md`.
- Stay inside the plan. If you discover the plan is wrong or incomplete, stop and tell the human instead of widening scope.

## 5. Verify
- Run `dotnet build` and `dotnet test`. Both must be green with no warnings.
- Report the actual output as evidence. Do not claim success without it.
- A Stop hook re-runs these and will not let the turn end while they fail.

## 6. Review
Run the `review` skill on the diff and address findings that affect correctness or the acceptance criteria.

## 7. Commit
- Stage only files that belong to this ticket.
- Commit message: `type(scope): summary`, imperative mood, body explaining why.
- One ticket per commit. Do not push.
