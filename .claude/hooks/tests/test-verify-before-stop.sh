#!/usr/bin/env bash
# Scripted check of the Stop hook using a stub `dotnet` and a throwaway git repo.
# Run: bash .claude/hooks/tests/test-verify-before-stop.sh
hook="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/verify-before-stop.sh"
tmp=$(mktemp -d); stub="$tmp/bin"; repo="$tmp/repo"
mkdir -p "$stub" "$repo/src" "$repo/.claude"
printf '#!/usr/bin/env bash\necho "error: \\"boom\\" C:\\\\path"\n[ "$STUB_DOTNET_EXIT" = "0" ]\n' > "$stub/dotnet"
chmod +x "$stub/dotnet"
export PATH="$stub:$PATH" CLAUDE_PROJECT_DIR="$repo"
cd "$repo" && git init -q && git config user.email t@t && git config user.name t
git commit -q --allow-empty -m init
fail=0

check() { # name exit_code_of_condition(0=true)
  if [ "$2" -eq 0 ]; then echo "ok   - $1"; else echo "FAIL - $1"; fail=1; fi
}

echo "x" > src/a.cs   # uncommitted change under src/
out=$(STUB_DOTNET_EXIT=1 bash "$hook")
echo "$out" | grep -q '"decision":"block"'; check "red build blocks stop" $?
printf '%s' "$out" | python -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null; check "block output is valid JSON" $?
out=$(STUB_DOTNET_EXIT=0 bash "$hook"); [ -z "$out" ]; check "green build lets stop through" $?

git add -A && git commit -q -m "ticket done"
touch -d '2000-01-01' .claude/.plan-approved 2>/dev/null || touch -t 200001010000 .claude/.plan-approved
git commit -q --allow-empty -m "later commit"
STUB_DOTNET_EXIT=0 bash "$hook" >/dev/null
[ ! -f .claude/.plan-approved ]; check "approval expires after a later commit" $?

touch .claude/.plan-approved; sleep 1
STUB_DOTNET_EXIT=0 bash "$hook" >/dev/null
[ -f .claude/.plan-approved ]; check "fresh approval survives until a commit lands" $?

cd / && rm -rf "$tmp"
exit $fail
