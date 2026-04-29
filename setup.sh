#!/bin/bash
# setup.sh — Install claude-session-tools into ~/.claude/
# Run: bash setup.sh

set -e

echo "=== Claude Session Tools Installer ==="

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

# --- 1. Copy hook ---
echo "[1/4] Installing SessionStart hook..."
mkdir -p "$CLAUDE_DIR/hooks"
cp "$SCRIPT_DIR/hooks/session-start.sh" "$CLAUDE_DIR/hooks/session-start.sh"
chmod +x "$CLAUDE_DIR/hooks/session-start.sh"

# --- 2. Copy skills ---
echo "[2/4] Installing skills..."
cp -r "$SCRIPT_DIR/skills/save-session" "$CLAUDE_DIR/skills/save-session"
cp -r "$SCRIPT_DIR/skills/resume-session" "$CLAUDE_DIR/skills/resume-session"

# --- 3. Create sessions directory ---
echo "[3/4] Creating sessions directory..."
mkdir -p "$CLAUDE_DIR/sessions"

# --- 4. Register SessionStart hook in settings.json ---
echo "[4/4] Registering hook in settings.json..."

# Build the hook entry (correct format: matcher is string, hooks is array)
HOOK_ENTRY='{
  "matcher": "",
  "hooks": [
    {
      "type": "command",
      "command": "bash '$CLAUDE_DIR'/hooks/session-start.sh"
    }
  ]
}'

if [ ! -f "$SETTINGS_FILE" ]; then
    # No settings file exists — create one
    echo "{ \"hooks\": { \"SessionStart\": [$HOOK_ENTRY] } }" > "$SETTINGS_FILE"
    echo "  Created $SETTINGS_FILE with SessionStart hook."
else
    # Check if jq is available
    if command -v jq &>/dev/null; then
        # Use jq to merge hooks section
        # If hooks.SessionStart already exists, append to it; otherwise create it
        HAS_HOOKS=$(jq 'has("hooks")' "$SETTINGS_FILE" 2>/dev/null || echo "false")
        if [ "$HAS_HOOKS" = "true" ]; then
            # Merge into existing hooks
            TMP_FILE=$(mktemp)
            jq --argjson entry "$HOOK_ENTRY" \
               '.hooks.SessionStart = (.hooks.SessionStart // []) + [$entry]' \
               "$SETTINGS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$SETTINGS_FILE"
        else
            # Add hooks section
            TMP_FILE=$(mktemp)
            jq --argjson entry "$HOOK_ENTRY" \
               '. + {"hooks": {"SessionStart": [$entry]}}' \
               "$SETTINGS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$SETTINGS_FILE"
        fi
        echo "  Updated $SETTINGS_FILE via jq."
    else
        # Fallback: jq not available, insert hooks before the last closing brace
        echo "  Warning: jq not found — trying sed-based merge."
        echo "  Install jq (winget install jqlang.jq) for safer merging."
        # Simple sed approach — insert before last }
        sed -i.bak '$ s/}$/,\n  "hooks": {\n    "SessionStart": [\n      '"$HOOK_ENTRY"'\n    ]\n  }\n}/' "$SETTINGS_FILE"
        echo "  Backup saved as $SETTINGS_FILE.bak"
    fi
fi

echo ""
echo "=== Installation complete! ==="
echo ""
echo "What was installed:"
echo "  Hook:  $CLAUDE_DIR/hooks/session-start.sh"
echo "  Skill: $CLAUDE_DIR/skills/save-session/SKILL.md"
echo "  Skill: $CLAUDE_DIR/skills/resume-session/SKILL.md"
echo "  Data:  $CLAUDE_DIR/sessions/ (created)"
echo ""
echo "Usage:"
echo "  /save             — Save session before closing"
echo "  /resume-session   - View full session history"
echo ""
echo "Next session start will auto-load the compact summary."
