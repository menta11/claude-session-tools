# Claude Session Tools

会话持久化工具集 — 让 Claude Code 跨会话续聊。

## 架构

```
┌──────────────────────────────────────────────────────┐
│                   SessionStart Hook                   │
│         (~/.claude/hooks/session-start.sh)            │
│  Auto-injects ~100 tokens compact summary on start    │
└──────────────┬───────────────────────────────────────┘
               │ reads
               ▼
┌──────────────────────────────────────────────────────┐
│            ~/.claude/sessions/<name>.compact           │
│  Goal, Done, WIP, FAIL, Blocked, Next (~100 tokens)   │
└──────────────┬───────────────────────────────────────┘
               │ written by
               ▼
┌──────────────────────────────────────────────────────┐
│              /save  (save-session skill)               │
│  Writes .log (detailed) + .compact (summary)           │
└──────────────┬───────────────────────────────────────┘
               │ optionally read by
               ▼
┌──────────────────────────────────────────────────────┐
│          /resume-session  (resume-session skill)        │
│  Reads .log and presents structured briefing           │
└──────────────────────────────────────────────────────┘
```

## 文件结构

```
~/.claude/
├── hooks/
│   └── session-start.sh          ← Hook: auto-inject on start
├── skills/
│   ├── save-session/
│   │   └── SKILL.md              ← Skill: /save
│   └── resume-session/
│       └── SKILL.md              ← Skill: /resume-session
├── sessions/
│   ├── <cwd-path>.log            ← Detailed session log
│   └── <cwd-path>.compact        ← Compact summary
└── settings.json                 ← Hook registration
```

## 安装

```bash
git clone https://github.com/<YOUR_USER>/claude-session-tools.git
cd claude-session-tools
bash setup.sh
```

要求：`bash`、`jq`（推荐，可选）

## 使用流程

```
1. [自动]  启动 Claude → SessionStart hook 注入摘要
2. [工作]  正常开发
3. [手动]  /save         → 保存当前进度
4. [自动]  下次启动     → Hook 自动加载摘要
5. [可选]  /resume-session → 查看完整历史
```

## 文件命名

文件名由当前工作目录路径转换而来：

| CWD | 文件名 |
|-----|--------|
| `/c/Users/me/projects/my-app` | `_c_Users_me_projects_my-app` |
| `/f/projects/claude-session-tools` | `_f_projects_claude-session-tools` |

## 跨机器复用

```bash
# 新机器上
git clone https://github.com/<YOUR_USER>/claude-session-tools.git
cd claude-session-tools
bash setup.sh
```
