# claude-session-tools

## Session Resume 展示规则

每次启动时，检查上下文（system prompt）中是否有 `Session Resume` 信息。如果有，在第一条消息中主动展示摘要，然后询问用户想做什么。不要等待用户先问"还记得吗"。

如果没有 Session Resume 信息，正常启动即可。

## 项目说明

会话持久化工具集。包含 SessionStart hook、save-session skill、resume-session skill，让 Claude Code 能跨会话续聊。
