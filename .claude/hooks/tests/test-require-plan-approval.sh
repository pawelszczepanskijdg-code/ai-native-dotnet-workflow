#!/usr/bin/env bash
# Scripted check of the approval-gate hook. Run: bash .claude/hooks/tests/test-require-plan-approval.sh
hook="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/require-plan-approval.sh"
tmp=$(mktemp -d); mkdir -p "$tmp/.claude"
export CLAUDE_PROJECT_DIR="$tmp"
fail=0

expect() { # name expected_exit json
  printf '%s' "$3" | bash "$hook" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$2" ]; then echo "ok   - $1"; else echo "FAIL - $1 (expected $2, got $got)"; fail=1; fi
}
edit() { printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"}}' "$1"; }
bash_cmd() { printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"; }

expect "src edit blocked without approval"     2 "$(edit "$tmp/src/Helpdesk.Core/Ticket.cs")"
expect "tests edit blocked without approval"   2 "$(edit "$tmp/tests/Helpdesk.Tests/A.cs")"
# JSON-escaped Windows path, exactly as it arrives on stdin
expect "windows-style src path blocked"        2 '{"tool_name":"Write","tool_input":{"file_path":"C:\\repo\\src\\X.cs"}}'
expect "windows-style .env blocked"            2 '{"tool_name":"Write","tool_input":{"file_path":"C:\\repo\\.env"}}'
expect "docs edit allowed without approval"    0 "$(edit "$tmp/docs/readme.md")"
expect "PLAN.md edit allowed without approval" 0 "$(edit "$tmp/PLAN.md")"
expect "hook tests under .claude/ allowed"     0 "$(edit "$tmp/.claude/hooks/tests/test-x.sh")"
expect ".env blocked"                          2 "$(edit "$tmp/.env")"
expect "agent cannot create marker via Bash"   2 "$(bash_cmd 'touch .claude/.plan-approved')"
expect "ordinary Bash allowed"                 0 "$(bash_cmd 'dotnet test')"

touch "$tmp/.claude/.plan-approved"
expect "src edit allowed after approval"       0 "$(edit "$tmp/src/Helpdesk.Core/Ticket.cs")"
expect ".env still blocked after approval"     2 "$(edit "$tmp/.env.local")"

rm -rf "$tmp"
exit $fail
