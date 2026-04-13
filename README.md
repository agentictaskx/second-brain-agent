# Second Brain Agent

Personal AI Chief of Staff — a persistent knowledge base with multi-agent architecture, built on the [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) by Andrej Karpathy.

## What This Is

A single folder that is both the **agent system** and your **data store**. Put it anywhere — git repo, OneDrive, local folder, or Obsidian vault. It works everywhere Claude Code runs.

The system uses a manager + specialist sub-agent architecture to:
- **Remember everything** — conversations, docs, emails, chats, meetings
- **Produce styled output** — using self-learning playbooks that match your voice
- **Gather daily signals** — email, calendar, Teams, Slack, ADO in one sweep
- **Track your world** — people, projects, tasks, decisions, priorities
- **Learn from corrections** — every style fix gets filed back, not lost to chat history

## Architecture

```
Manager (orchestrator — loads identity, routes operations)
  ├── Retriever   — fetches data from any source (MCP tools, files, URLs)
  ├── Analyst     — extracts entities, synthesizes answers, produces routing plans
  ├── Composer    — drafts styled output using playbooks + identity
  ├── Actor       — all mutations (write vault, send externally, run checklist)
  └── Auditor     — health checks, lint, schema audit, post-op verification
```

## Quick Start

```
# Clone
git clone https://github.com/agentictaskx/second-brain-agent.git
cd second-brain-agent

# First run — bootstrap interview creates your identity
# (via Claude Code skill invocation)
/second-brain

# Daily use
"catch me up"           → morning signal sweep
"ingest [paste/link]"   → save and process a source  
"what do I know about X" → query your knowledge base
"draft a message to Y"  → compose styled output
"lint"                  → health check
"remember: format it like X" → update preferences
```

## Design Document

The full architecture, agent contracts, workflows, and information lifecycle are documented in:

**[docs/DESIGN.md](docs/DESIGN.md)**

This is a living design doc — contributions welcome via PR.

## Folder Structure

```
second-brain-agent/
├── CLAUDE.md              # Schema (auto-loaded by Claude Code)
├── index.md               # Wiki catalog
├── log.md                 # Event log
├── agents/                # Agent definitions (6 total)
├── skills/SKILL.md        # Entry point
├── wiki/                  # Your knowledge base
│   ├── identity.md        # Who you are (loaded every session)
│   ├── people.md          # People directory
│   ├── projects/          # One page per project
│   ├── subscriptions.md   # Watched channels/chats
│   ├── tools.md           # Tool Discovery Log
│   ├── todo.md            # Tasks and follow-ups
│   └── ...
├── playbooks/             # Output style guides (extensible)
├── raw/                   # Immutable source documents
└── docs/DESIGN.md         # Architecture + design doc
```

## Key Concepts

### Playbooks
Concrete output recipes (not abstract style guides). Each playbook defines a specific output type with structure, template, examples, and anti-patterns. The system auto-selects playbooks by intent + audience + format. New playbooks can be created anytime — the system learns your preferences.

### Entity Routing
Every piece of information gets classified into entities (person, project, task, decision, etc.) and routed to the right wiki page. The routing table is self-expanding — new entity types are proposed when content doesn't fit existing categories.

### Raw-First Rule
Every external interaction saves to `raw/` before any other action. This ensures nothing is lost — you can always ask "what did I send last week?" and get an answer.

### First Principles (Karpathy)
The wiki is a persistent, compounding artifact. Knowledge is compiled once and kept current — not re-derived every query. The LLM handles all bookkeeping; you curate sources, direct analysis, and think.

## Status

**Phase: Design** — Architecture is documented in [DESIGN.md](docs/DESIGN.md). Implementation has not started. Contributions welcome.

## Contributing

1. Read [docs/DESIGN.md](docs/DESIGN.md)
2. Open issues for design feedback
3. Submit PRs for improvements
4. Agent definitions, playbook templates, and schema refinements all welcome

## License

MIT
