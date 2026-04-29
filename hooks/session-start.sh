#!/bin/bash
# session-start.sh — inject compact session summary into Claude's system prompt
# stdout is captured by Claude Code's SessionStart hook and added to the prompt

SESSION_DIR="$HOME/.claude/sessions"

# --- Step 1: Try exact CWD match ---
SAFE_NAME=$(echo "$PWD" | sed 's|/|_|g')
COMPACT_FILE="$SESSION_DIR/$SAFE_NAME.compact"

if [ -f "$COMPACT_FILE" ]; then
    cat "$COMPACT_FILE"
    exit 0
fi

# --- Step 2: Fuzzy fallback by directory basename ---
BASENAME=$(basename "$PWD")
if [ -d "$SESSION_DIR" ]; then
    MATCH=$(ls "$SESSION_DIR"/*.compact 2>/dev/null | while read f; do
        fname=$(basename "$f" .compact)
        case "$fname" in
            *"$BASENAME"*) echo "$f"; break ;;
        esac
    done)
    if [ -n "$MATCH" ] && [ -f "$MATCH" ]; then
        cat "$MATCH"
        exit 0
    fi
fi

# No session found — graceful fallback, output nothing
exit 0
