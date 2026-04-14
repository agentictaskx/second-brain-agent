# Second Brain Agent

Personal AI Chief of Staff for Claude Code

## What This Is

A multi-agent knowledge base system that acts as your persistent AI chief of staff. Built on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) -- a compounding personal wiki where the LLM handles all bookkeeping while you curate sources, direct analysis, and think. The system uses a manager + 5 specialist agents to handle 7 operations: daily briefs, document ingestion, knowledge queries, styled communication, composition, vault auditing, and preference learning. Your data lives in a local vault (just a folder of markdown files); the plugin provides the engine.

## Quick Start

```
1. Install the plugin (see Installation below)
2. Say "catch me up" -- the bootstrap interview will guide you through setup
3. Done -- your vault is created and operational
```

On first run, the system detects that no vault exists and walks you through a 5-question interview to create your identity, stakeholders, channels, priorities, and communication preferences. After that, every command works immediately.

## Installation

### From Git

```bash
git clone https://github.com/agentictaskx/second-brain-agent.git
```

Then add to Claude Code's plugin sources by pointing to the cloned directory. The `.claude-plugin/plugin.json` manifest handles registration.

### Manual Install

Copy the repo to your Claude Code plugins directory:

```bash
cp -r second-brain-agent ~/.claude/plugins/second-brain-agent
```

### Vault Location

By default the vault is created at `~/second-brain/`. To customize:

| Method | How |
|--------|-----|
| Environment variable | Set `SECOND_BRAIN_VAULT` to your preferred path |
| Config file | Create `~/.second-brain/config.json` with `{"vault_path": "/your/path"}` |
| Default | `~/second-brain/` |

Resolution order: env var > config file > default.

## MCP Dependencies

**None are required.** The system works with zero MCPs installed -- all operations gracefully degrade. MCPs add capabilities progressively; install only what you need.

| Service | What It Enables | How to Install | ToolSearch Prefix |
|---------|----------------|----------------|-------------------|
| **Email** (WorkIQ) | Email sweep in daily briefs, compose & send emails | Enable `workiq-mcp` plugin | `mcp__WorkIQ-Mail__` |
| **Calendar** (WorkIQ) | Calendar entries in daily briefs | Enable `workiq-mcp` plugin | `mcp__WorkIQ-Calendar__` |
| **Teams** (WorkIQ) | Teams channel/chat monitoring, post to channels | Enable `workiq-mcp` plugin | `mcp__WorkIQ-TeamsV1__` |
| **SharePoint** (WorkIQ) | Retrieve SharePoint documents | Enable `workiq-mcp` plugin | `mcp__WorkIQ-SharePoint__` |
| **OneDrive** (WorkIQ) | Retrieve OneDrive files | Enable `workiq-mcp` plugin | `mcp__WorkIQ-OneDrive__` |
| **Word** (WorkIQ) | Read/write Word documents | Enable `workiq-mcp` plugin | `mcp__WorkIQ-Word__` |
| **Azure DevOps** | ADO work items in daily briefs, update/comment on items | Enable `azure-devops-mcp` plugin | `mcp__plugin_azure-devops-mcp` |
| **Slack** | Slack channel monitoring, post to Slack | Enable `slack-mcp` plugin | `mcp__plugin_slack-mcp_slack__` |
| **Obsidian** | Obsidian vault integration | Enable `obsidian` MCP | `mcp__plugin_user-mcp-obsidian_obsidian__` |

On first run, the system auto-detects which MCPs are available via `ToolSearch` and records results in `wiki/tools.md`. You can install MCPs at any time -- the system re-probes on each session.

## Operations Reference

| Operation | Trigger Phrases | What It Does | MCPs Used |
|-----------|----------------|--------------|-----------|
| **Daily Brief** | "catch me up", "daily brief", "morning brief", "start my day", "what did I miss" | Sweeps all subscribed sources, cross-references with priorities, produces a styled brief, updates todo/top-of-mind | Email, Calendar, Teams, ADO, Slack |
| **Ingest** | "ingest", "save this", "process this", "add this to my brain" | Saves content to `raw/`, extracts entities, routes updates to wiki pages (people, projects, tasks, decisions) | SharePoint, OneDrive, Word (for doc retrieval) |
| **Query** | "what do I know about", "status of", "tell me about", "find" | Searches the wiki, synthesizes answers with citations. Offers to file back synthesis to `wiki/overviews/` | None (vault-only) |
| **Communicate** | "draft", "post to", "send", "email", "message", "write RAG" | Selects playbook by intent + audience + format, drafts styled output, sends via MCP on confirmation | Email, Teams, Slack, ADO (for sending) |
| **Compose** | "write a slide", "summarize", "analyze this", "create a doc" | Like communicate but output is for the user, not for sending. Iterates until approved | None (vault-only, unless source retrieval needed) |
| **Lint** | "lint", "health check", "audit" | Runs full vault audit: schema compliance, orphan detection, index consistency, stale entries | None (vault-only) |
| **Feedback** | "remember", "from now on", "update my preference", "correct" | Updates the correct wiki page or playbook based on what's being corrected. Style fixes update playbooks; info corrections update wiki | None (vault-only) |

## Architecture

### Engine / Vault Separation

The plugin is the **engine** -- agent definitions, playbooks, templates, and references. Your data lives in the **vault** -- a separate directory of markdown files. This means:

- Plugin updates don't touch your data
- Your vault is portable (git, OneDrive, Obsidian, anywhere)
- Multiple users share the same engine with separate vaults

```
Plugin (engine)                    Vault (your data)
{plugin_root}/                     {vault_root}/
├── agents/          (6 agents)    ├── wiki/           (knowledge base)
├── playbooks/       (defaults)    ├── raw/            (immutable sources)
├── templates/       (12 files)    ├── playbooks/      (your overrides)
├── references/      (checklists)  ├── index.md        (catalog)
├── examples/        (5 files)     └── log.md          (event log)
├── skills/SKILL.md  (entry point)
└── CLAUDE.md        (schema)
```

### Agent Pipeline

```
SKILL.md (dispatcher -- resolves paths, detects first-run, classifies intent)
  └── Manager (orchestrator -- loads identity, selects playbook, spawns pipeline)
        ├── Retriever  -- fetches data from MCP tools + files + URLs
        ├── Analyst    -- extracts entities, synthesizes answers, produces routing plans
        ├── Composer   -- drafts styled output using playbooks + identity
        ├── Actor      -- all mutations: write vault, send externally, run checklist
        └── Auditor    -- health checks, lint, schema audit, post-op verification
```

Each operation follows a defined pipeline. For example, daily brief:

```
Retriever(sweep) → Analyst(cross-reference) → Composer(daily-brief playbook) → Actor(update wiki) → Auditor(verify)
```

## Vault Structure

Created automatically on first run:

```
~/second-brain/
├── CLAUDE.md                          # Schema (loaded by Claude Code automatically)
├── index.md                           # Wiki catalog with tagged entries
├── log.md                             # Chronological event log
├── wiki/
│   ├── identity.md                    # Who you are (loaded every session)
│   ├── people.md                      # People directory with context
│   ├── channels.md                    # Teams channels/chats with IDs
│   ├── subscriptions.md              # What to monitor in daily briefs
│   ├── top-of-mind.md                # Current priorities and focus areas
│   ├── todo.md                        # Tasks and follow-ups
│   ├── decisions.md                   # Decision log with rationale
│   ├── concepts.md                    # Concepts and mental models
│   ├── bookmarks.md                   # Saved links with context
│   ├── tools.md                       # MCP tool status and discovery log
│   ├── overviews/                     # Filed-back synthesis (query results worth keeping)
│   └── projects/                      # One page per project
│       └── {project-name}.md
├── playbooks/                         # Your playbook overrides (takes precedence over plugin defaults)
├── raw/                               # Immutable source documents
│   ├── documents/                     # SharePoint/OneDrive docs
│   ├── channels/                      # Teams channel digests
│   ├── chats/                         # Teams chat transcripts
│   ├── emails/                        # Email content
│   ├── meetings/                      # Meeting notes
│   ├── articles/                      # Web articles
│   ├── assets/                        # Other files
│   └── sessions/                      # Session ledgers (YYYY-MM-DD-session.md)
└── ~/.second-brain/config.json        # Vault location config (outside vault)
```

## Customization

### Add Custom Playbooks

Playbooks are concrete output recipes -- not abstract style guides. Each defines a specific output type with structure, template, examples, and anti-patterns.

1. Create a new `.md` file in `{vault_root}/playbooks/`
2. Register it in `{vault_root}/playbooks/_index.md`
3. User vault playbooks override plugin defaults with the same name

The plugin ships with these default playbooks:

| Playbook | Purpose |
|----------|---------|
| `daily-brief.md` | Morning signal sweep format |
| `email-status-brief.md` | Status update emails |
| `teams-channel-post.md` | Teams channel posts |
| `chat-message-polish.md` | Chat message refinement |
| `ado-rag-workstream.md` | ADO RAG/workstream updates |
| `weekly-review.md` | Weekly review summaries |

### Add New Wiki Pages

The entity routing table in `CLAUDE.md` maps entity types to wiki pages. To add a new entity type:

1. Create the page in `{vault_root}/wiki/`
2. Add an entry to the entity routing table in `{vault_root}/CLAUDE.md`
3. The Analyst agent will start routing to it automatically

### Update Identity and Preferences

Edit `{vault_root}/wiki/identity.md` directly, or say "remember: I prefer bullet points over prose" and the feedback operation handles it.

### Add Daily Brief Subscriptions

Edit `{vault_root}/wiki/subscriptions.md` to add/remove channels, chats, email filters, or ADO queries that get checked during daily briefs. See `examples/subscriptions-example.md` for the expected format.

## Graceful Degradation

Every operation works with zero MCPs. Capabilities are additive.

| Operation | 0 MCPs | Some MCPs | All MCPs |
|-----------|--------|-----------|----------|
| **Daily Brief** | Vault-only review: surfaces priorities, stale todos, upcoming items from wiki | Partial sweep: pulls from available sources, skips unavailable ones | Full sweep: email + calendar + Teams + ADO + Slack |
| **Ingest** | User pastes content directly; entities extracted and routed to wiki | Can retrieve docs from available sources (SharePoint, ADO, etc.) | Full retrieval from any source type |
| **Query** | Searches vault wiki and returns synthesis with citations | Same (queries are vault-only by default) | Same, plus can pull fresh data if vault is stale |
| **Communicate** | Drafts output; user copies and sends manually | Sends via available channels (email, Teams, Slack) | Full send capability across all channels |
| **Compose** | Full functionality (composition is vault-only) | Can retrieve source material from available MCPs | Full source retrieval |
| **Lint** | Full functionality (auditing is vault-only) | Same | Same |
| **Feedback** | Full functionality (updates vault files only) | Same | Same |

When an MCP is unavailable, the system:
1. Skips that source (does not attempt the call)
2. Reports what was skipped in the output
3. Continues with available sources
4. Falls back through the tool fallback chain (see `references/tool-fallback-chains.md`)

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| "Token expired" or 401 errors | MCP auth tokens need refresh | Run the `refresh-tokens` skill, or re-authenticate the MCP plugin |
| "MCP not found" during daily brief | MCP plugin not installed or not loaded | Check `wiki/tools.md` for status. Install the missing plugin from the marketplace |
| "Vault not found" | System can't locate your vault directory | Set `SECOND_BRAIN_VAULT` env var, or check `~/.second-brain/config.json` has the correct `vault_path` |
| Bootstrap didn't run | `wiki/identity.md` already exists (possibly empty) | Delete `{vault_root}/wiki/identity.md` to re-trigger the bootstrap interview |
| Playbook not applied | Playbook exists but isn't registered | Add it to `{vault_root}/playbooks/_index.md` |
| Daily brief is empty | No subscriptions configured | Edit `{vault_root}/wiki/subscriptions.md` with channels/chats to monitor |
| Agent can't find vault files | `vault_root` resolved incorrectly | Check env var and config file. Run `cat ~/.second-brain/config.json` to verify |
| Stale wiki data | Wiki pages haven't been updated | Run `lint` to identify stale entries, then `ingest` fresh sources |

## Examples

The `examples/` directory contains real examples from a mature vault deployment:

- `identity-example.md` -- fully populated identity with communication preferences
- `people-example.md` -- people directory with 20+ entries and context
- `channels-example.md` -- Teams channels/chats with IDs
- `subscriptions-example.md` -- complete subscription configuration

Use these as calibration for the level of detail the agents work best with.

## Credits

- **Concept:** [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) by Andrej Karpathy
- **Built by:** Neal Zhang (nealzhang@microsoft.com)

## License

MIT
