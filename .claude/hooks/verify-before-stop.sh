#!/usr/bin/env bash
# Stop hook: the agent may not finish a turn while src/ or tests/ have
# uncommitted changes and the build or tests are red.
# Also expires the plan approval once a commit landed after it, so each
# approved plan unlocks exactly one ticket.
# Output: JSON {"decision":"block",...} to keep the agent working, otherwise nothing.

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" || exit 0
marker=".claude/.plan-approved"

expire_approval() {
  [ -f "$marker" ] || return 0
  last_commit=$(git log -1 --format=%ct 2>/dev/null) || return 0
  approved_at=$(stat -c %Y "$marker" 2>/dev/null || stat -f %m "$marker" 2>/dev/null) || return 0
  [ -n "$last_commit" ] && [ "$last_commit" -gt "$approved_at" ] && rm -f "$marker"
  return 0
}

if [ -z "$(git status --porcelain -- src tests 2>/dev/null)" ]; then
  expire_approval
  exit 0
fi

if ! output=$({ dotnet build --nologo -v q && dotnet test --nologo -v q; } 2>&1); then
  # Make the output safe to embed in a JSON string: drop CRs, escape \ and ", join lines with \n.
  tail_text=$(printf '%s' "$output" | tr -d '\r' | tail -n 15 \
    | sed 's/\\/\\\\/g; s/"/\\"/g' \
    | awk '{printf "%s\\n", $0}')
  printf '{"decision":"block","reason":"dotnet build/test is failing. Fix the cause (do not suppress or skip tests), then finish. Last output:\\n%s"}\n' "$tail_text"
  exit 0
fi

expire_approval
exit 0
