#!/bin/bash
# session-start.sh — inject compact session summary via JSON additionalContext
# stdout is captured by Claude Code's SessionStart hook

SESSION_DIR="$HOME/.claude/sessions"

# --- Resolve compact file ---
resolve_compact() {
    local safe_name=$(echo "$PWD" | sed 's|/|_|g')
    local exact="$SESSION_DIR/$safe_name.compact"
    [ -f "$exact" ] && echo "$exact" && return

    local basename=$(basename "$PWD")
    if [ -d "$SESSION_DIR" ]; then
        for f in "$SESSION_DIR"/*.compact; do
            [ -f "$f" ] || continue
            case "$(basename "$f" .compact)" in
                *"$basename"*) echo "$f"; return ;;
            esac
        done
    fi
}

COMPACT=$(resolve_compact)
[ -z "$COMPACT" ] && exit 0

SUMMARY=$(cat "$COMPACT")

# Output JSON additionalContext
if command -v jq &>/dev/null; then
    jq -n --arg text "$SUMMARY" '{
        additionalContext: "Session Resume\n\n\($text)\n\n---\nDisplay the session resume above as your first message. Keep it terse — just the key points. Then ask what to work on."
    }'
else
    # Fallback: construct JSON manually (limited escaping)
    escaped=$(echo "$SUMMARY" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))" 2>/dev/null || echo "")
    [ -n "$escaped" ] && printf '{"additionalContext": "Session Resume\\n\\n%s\\n\\n---\\nDisplay the session resume above as your first message. Keep it terse \\u2014 just the key points. Then ask what to work on."}\n' "$escaped"
fi
exit 0
