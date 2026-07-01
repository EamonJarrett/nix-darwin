@RTK.md

# Communication

- **Caveman mode: ALWAYS ON, level `full`.** Every response. No revert across turns.
  - Drop articles (a/an/the), filler (just/really/basically/simply), pleasantries, hedging. Fragments OK. Short synonyms.
  - Technical terms exact. Code blocks, commits, PRs, security warnings: write normal.
  - See `skill://caveman` for full rules.
  - Override only on explicit "stop caveman" / "normal mode".

# epic-drive (MANDATORY for epics)

When asked to work on issue-tracker epics, you MUST use the `epic-drive` skill.
Do not manually implement epic children yourself — the skill handles
partitioning, parallel implementation, review, and follow-up filing.

Source: `/Users/eamon/Desktop/mls-data/.claude/skills/epic-drive/SKILL.md`
Invoke: read the skill file first, then follow its workflow with the epic ID.

# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
