#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|Bash): deterministic approval gate.
#  - blocks secret-like files at all times
#  - blocks edits under src/ and tests/ until the human approved PLAN.md
#  - blocks the agent from creating the approval marker itself
# Exit 2 = block (stderr is shown to the model), exit 0 = no objection.

input=$(cat)
project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
marker="$project_dir/.claude/.plan-approved"

# JSON on stdin; extract a string field without jq and turn Windows
# backslashes (JSON-escaped as \\) into forward slashes.
field() {
  printf '%s' "$input" \
    | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" \
    | head -n1 \
    | sed 's#\\\\#/#g; s#\\#/#g'
}
tool=$(field tool_name)

if [ "$tool" = "Bash" ]; then
  command=$(field command)
  case "$command" in
    *plan-approved*|*approve-plan*)
      echo "Blocked: only the human may approve a plan (run: ! bash .claude/hooks/approve-plan.sh)." >&2
      exit 2 ;;
  esac
  exit 0
fi

path=$(field file_path)
[ -z "$path" ] && exit 0
base="${path##*/}"

case "$base" in
  .env|.env.*|*.pem|*.key|*.pfx)
    echo "Blocked: '$base' looks like a secret; never write it from the agent." >&2
    exit 2 ;;
esac
case "$path" in
  */secrets/*|secrets/*)
    echo "Blocked: files under secrets/ must not be written by the agent." >&2
    exit 2 ;;
esac

case "$path" in
  */.claude/*|.claude/*)
    # Agent configuration (including hook tests under .claude/hooks/tests/) is not application code.
    exit 0 ;;
  */src/*|src/*|*/tests/*|tests/*)
    if [ ! -f "$marker" ]; then
      echo "Blocked: no approved plan. Write PLAN.md, ask the human to review it, and wait for approval (they run: ! bash .claude/hooks/approve-plan.sh)." >&2
      exit 2
    fi ;;
esac
exit 0
