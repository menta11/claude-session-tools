# Resume Session

Load a detailed session log and orient fully before doing any work.

## When to Use

- Want to see full history from a previous session (beyond the compact summary)
- Need to understand exactly what failed and why
- Handed a session file from another machine or teammate

Trigger phrases: `/resume-session`, `恢复会话`, `查看历史记录`

## Usage

```
/resume-session                              → loads .log for current project
/resume-session ~/.claude/sessions/<name>.log → loads a specific log file
```

## Process

### Step 1: Find the session file

If no argument provided:
1. Compute safe filename from CWD: `echo "$PWD" | sed 's|/|_|g'`
2. Read `$HOME/.claude/sessions/<SAFE_NAME>.log`
3. If not found, try fuzzy match by directory basename (check `$HOME/.claude/sessions/*.log`)

If file path provided:
1. Read that file directly

If nothing is found:
```
No session log found for this project.
Run /save at the end of a session to create one.
```
Then stop.

### Step 2: Read the entire log file

Read the complete file. Do not summarize yet.

### Step 3: Present structured briefing

Respond in this exact format:

```
SESSION LOADED: <path>

PROJECT: <project name>

WHAT WE'RE BUILDING:
<2-3 sentence summary>

CURRENT STATE:
  PASS: <completed items>
  WIP: <in progress>
  Not Started: <not started>

WHAT NOT TO RETRY:
<failed approaches — this is critical>

BLOCKERS:
<open questions / blockers>

NEXT STEP:
<exact next step if defined>
────────────────────────────────────────
Ready to continue. What would you like to do?
```

### Step 4: Wait for user

Do NOT start working automatically. Do NOT touch any files.
Wait for the user to say what to do next.

## Notes

- Never modify the session file when loading — read-only
- The briefing format is fixed — do not skip sections even if empty
- If files referenced in the log no longer exist on disk, note: "WARNING: <path> referenced but not found"
- If the session is from more than 7 days ago, note: "WARNING: Session from N days ago — things may have changed"
