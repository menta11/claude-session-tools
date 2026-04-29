#!/bin/bash
# session-start.sh — inject compact session summary into Claude's system prompt
# stdout is captured by Claude Code's SessionStart hook

SESSION_DIR="$HOME/.claude/sessions"

# --- Resolve compact file (exact CWD match, then fuzzy by basename) ---
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

cat "$COMPACT"
exit 0
