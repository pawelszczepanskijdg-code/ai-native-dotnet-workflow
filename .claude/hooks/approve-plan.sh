#!/usr/bin/env bash
# Run by the human, not the agent: ! bash .claude/hooks/approve-plan.sh
# Records that PLAN.md was reviewed, which unlocks edits under src/ and tests/.
set -e
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ ! -f "$root/PLAN.md" ]; then
  echo "PLAN.md not found - nothing to approve." >&2
  exit 1
fi
touch "$root/.claude/.plan-approved"
echo "Plan approved. The agent may now edit src/ and tests/."
