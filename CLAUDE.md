# Helpdesk API

Small .NET 10 helpdesk (ticket) API. Demo repo for an AI-assisted workflow; code, docs and commits are in English.

## Commands
- Build: `dotnet build`
- Test all: `dotnet test`
- Test one: `dotnet test --filter "FullyQualifiedName~<TestName>"`
- Run API: `dotnet run --project src/Helpdesk.Api`

## Layout
- `src/Helpdesk.Core`: domain, commands/queries and handlers, EF Core persistence
- `src/Helpdesk.Api`: Minimal API endpoints only, no business logic
- `tests/Helpdesk.Tests`: unit tests (domain, handlers) and API integration tests

## Conventions
- CQRS: one command or query per file, each with its own handler and validator.
- Domain rules (e.g. ticket status transitions) live in the entity, not in handlers or endpoints.
- Warnings are errors; do not suppress them, fix the cause.
- Every behaviour change ships with a test written first. A change without a test is not done.
- Never use code, names or data from any employer or client; the domain stays a neutral helpdesk.

## Workflow
- Non-trivial changes go through the `ticket-workflow` skill: plan, wait for explicit approval, then implement.
- Do not edit files under `src/` or `tests/` before the plan is approved.
- Finish only with `dotnet build` and `dotnet test` green; show the output as evidence.
- One ticket per commit. Commit messages: `type(scope): summary` (feat, fix, test, docs, chore, ci), imperative mood.
- Never commit secrets, `.env` files, `PLAN.md` or anything under `.claude/settings.local.json`.
