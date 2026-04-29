# Save Session

Save current session state so work can be resumed in a future session.

## When to Use

- End of a work session before closing Claude Code
- Before hitting context limits (save first, then start fresh session)
- After solving a complex problem worth remembering

Trigger phrases: `/save`, `保存会话`, `记录当前进度`, `save session`

## Process

### Step 1: Gather context

Collect from the conversation:
- What was built or modified (list files touched)
- What worked (with evidence: tests passing, manual verification, etc.)
- What failed (with exact error/reason — the most important section)
- What hasn't been tried yet
- Decisions made and why
- Open questions / blockers
- What the exact next step should be

### Step 2: Compute safe filename

Run this shell command to get the safe filename for the current project:

```bash
echo "$PWD" | sed 's|/|_|g'
```

Use the output as the filename prefix.

### Step 3: Create directories if needed

```bash
mkdir -p "$HOME/.claude/sessions"
```

### Step 4: Write detailed log

Write to `$HOME/.claude/sessions/<SAFE_NAME>.log`

Use this format:

```
# Session: YYYY-MM-DD HH:MM

## Project
<project path or name>

## What We Are Building
<1-3 paragraphs — enough context for someone with zero memory>

## What WORKED (with evidence)
- <thing> — confirmed by: <specific evidence>

## What Did NOT Work (and why)
- <approach tried> — failed because: <exact reason>

## What Has NOT Been Tried Yet
- <approach worth exploring>

## Files Changed
| File | Status | Notes |
|------|--------|-------|
| path/to/file | PASS: Complete | what it does |
| path/to/file | In Progress | what's left |

## Decisions Made
- <decision> — reason: <why chosen>

## Blockers & Open Questions
- <blocker>

## Exact Next Step
<single most important thing to do next>
```

Be honest — write "Nothing yet" or "N/A" for empty sections rather than skipping them.

### Step 5: Extract and compress summary

Write a compact version to `$HOME/.claude/sessions/<SAFE_NAME>.compact`

Keep it under 150 tokens. Use this caveman-style format:

```
<project-name> | <date> | <n> sessions
Goal: <one-line goal>
Done: <key accomplishments>
WIP: <in-progress items>
FAIL: <failed approaches — what NOT to retry>
Blocked: <blockers>
Next: <exact next step>
```

### Step 6: Confirm with user

Show the user both files were written:
```
Session saved.
Log: ~/.claude/sessions/<name>.log
Summary: ~/.claude/sessions/<name>.compact

Does this look accurate?
```

Wait for confirmation and make edits if requested.

## Notes

- Never include hardcoded secrets, API keys, or passwords
- The "What Did NOT Work" section is critical — future sessions will blindly retry failed approaches without it
- The .compact file is read by SessionStart hook — keep it terse
- Both files stay local in ~/.claude/sessions/, never committed to git
