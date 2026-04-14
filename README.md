# Second Brain Agent 🧠

> 🌅 **"Catch me up."** — Wake up, say two words, and your AI Chief of Staff sweeps your inbox, Teams, calendar, and ADO overnight signals into a single daily brief. Priorities updated. Action items filed. Wiki current.
>
> 🪶 **Zero dependencies, zero lock-in.** The entire system is plain Markdown files — no database, no Docker, no daemon. Every agent is a single `.md` file readable by any LLM. Fork it, adapt it, make it yours.
>
> *💡 Second Brain is a methodology, not a platform. What matters is the knowledge workflow — take it wherever you go.*

Built on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — a compounding personal wiki where the LLM handles all bookkeeping while you curate sources, direct analysis, and think.

## 🚀 Quick Start

```bash
# 1. Install
git clone https://github.com/nealzhang_microsoft/second-brain-agent.git
# Add to Claude Code plugin sources (or copy to ~/.claude/plugins/)

# 2. Use — that's it
claude
> catch me up           # daily brief — bootstrap interview runs automatically on first use
> ingest [paste text]   # save anything to your brain
> what do I know about  # query your knowledge base
> draft a reply to...   # compose styled output
> lint                  # vault health check
```

> 📋 **First run:** The system detects no vault exists and walks you through a **5-question bootstrap interview** — name, stakeholders, channels, priorities, communication style. After that, every command works immediately.
>
> 🔌 **Zero MCPs required.** All operations work without any MCP servers installed. MCPs add capabilities progressively — install only what you need. [Details →](#-mcp-dependencies)

## 🎯 What It Does

**7 operations, one brain:**

| Say This | What Happens |
|----------|-------------|
| `catch me up` / `daily brief` | 🌅 Sweeps email, Teams, calendar, ADO → cross-references with your priorities → styled brief → wiki updated |
| `ingest` / `save this` | 📥 Saves to `raw/`, extracts entities, routes to wiki pages (people, projects, tasks, decisions) |
| `what do I know about X` | 🔍 Searches wiki, synthesizes answer with citations, offers to file back to `wiki/overviews/` |
| `draft` / `post to` / `email` | 📤 Picks playbook by audience + channel, drafts styled output, sends via MCP on confirmation |
| `summarize` / `analyze` | ✍️ Like communicate but for you — iterates until you approve |
| `lint` / `health check` | 🔧 Full vault audit: schema, orphans, index consistency, stale entries |
| `remember` / `from now on` | 🧠 Updates the right wiki page or playbook based on what you're correcting |

> 💡 **Classification is by intent, not keywords.** "What's going on with the team?" → daily brief. "What's going on with Project X?" → query. The dispatcher figures it out.

## 🏗️ Architecture

### Engine / Vault Separation

The plugin is the **engine** (read-only, shared). Your data is the **vault** (read-write, personal). Plugin updates never touch your data.

```
Plugin (engine)                       Your Vault (data)
{plugin_root}/                        ~/second-brain/
├── agents/           6 specialists   ├── wiki/            knowledge base
├── playbooks/        default styles  ├── raw/             immutable sources
├── templates/        12 bootstrap    ├── playbooks/       your overrides
├── examples/         real config     ├── index.md         catalog
├── references/       checklists      └── log.md           event log
└── skills/SKILL.md   entry point
```

### 🤖 Agent Pipeline

```
SKILL.md → Manager → [Retriever → Analyst → Composer → Actor → Auditor]
```

| Agent | Role | Reads | Writes |
|-------|------|-------|--------|
| 🎯 **Manager** | Orchestrator — loads identity, selects playbook, spawns pipeline | wiki/identity.md, playbooks/ | Nothing (delegates) |
| 📡 **Retriever** | ALL inbound data — MCP sweeps, file reads, URL fetches | MCP tools, files, URLs | raw/ only |
| 🔬 **Analyst** | Entity extraction, synthesis, routing plans | wiki/, raw/ | Nothing (read-only) |
| 🎨 **Composer** | Drafts styled output using playbooks + identity | playbooks/, wiki/identity.md | Nothing (read-only) |
| ⚡ **Actor** | ALL mutations — vault writes, external sends, checklist | Mutation plan from Manager | wiki/, raw/, index.md, log.md |
| 🔍 **Auditor** | Health checks, lint, post-op verification | Entire vault | Nothing (read-only, reports issues) |

<details>
<summary>Example pipeline: Daily Brief</summary>

```
1. Retriever(sweep)        — pulls email, Teams, calendar, ADO, Slack signals
2. Analyst(cross-reference) — compares signals against priorities and existing wiki
3. Composer(daily-brief)   — formats using playbooks/daily-brief.md + identity
4. Actor(update wiki)      — writes to wiki/todo.md, wiki/top-of-mind.md, log.md
5. Auditor(verify)         — confirms all checklist items passed
```

</details>

<details>
<summary>Example pipeline: Ingest</summary>

```
1. Retriever(targeted)     — fetches the specific source (doc, email, URL, paste)
2. Analyst(ingest)         — extracts entities, builds routing plan (person→people.md, task→todo.md, etc.)
3. Actor(execute mutations) — writes raw/, updates wiki pages, updates index.md
4. Auditor(post-op-verify) — verifies all planned mutations were executed
```

</details>

## 🔌 MCP Dependencies

**None required.** Everything works at zero MCPs. Each MCP you add unlocks more data sources and outbound channels.

| Service | What It Unlocks | Install | Required? |
|---------|----------------|---------|:---------:|
| 📧 **Email** | Inbox sweep, compose & send email | `workiq-mcp` plugin | No |
| 📅 **Calendar** | Calendar entries in daily briefs | `workiq-mcp` plugin | No |
| 💬 **Teams** | Channel/chat monitoring, post to Teams | `workiq-mcp` plugin | No |
| 📁 **SharePoint** | Retrieve SharePoint documents | `workiq-mcp` plugin | No |
| 📂 **OneDrive** | Retrieve OneDrive files | `workiq-mcp` plugin | No |
| 📝 **Word** | Read/write Word documents | `workiq-mcp` plugin | No |
| 🔧 **Azure DevOps** | Work items, PRs, pipeline status | `azure-devops-mcp` plugin | No |
| 💬 **Slack** | Slack channel monitoring, post to Slack | `slack-mcp` plugin | No |
| 📓 **Obsidian** | Obsidian vault integration | `obsidian` MCP server | No |

> 🔄 **Auto-detection:** On first run and every session, the system probes for available MCPs via `ToolSearch` and records results in `wiki/tools.md`. Install an MCP anytime — it's picked up automatically.

<details>
<summary>Graceful degradation matrix</summary>

| Operation | 0 MCPs | Some MCPs | All MCPs |
|-----------|--------|-----------|----------|
| **Daily Brief** | Vault-only: priorities, stale todos, upcoming items | Partial sweep: available sources only | Full sweep: email + calendar + Teams + ADO + Slack |
| **Ingest** | Paste/URL/file only | + Retrieve from available sources | Full retrieval from any source |
| **Query** | Vault search with citations | Same (queries are vault-only) | + Pull fresh data if vault is stale |
| **Communicate** | Draft → save to `raw/drafts/` for manual paste | Send via available channels | Full outbound: email, Teams, Slack, ADO |
| **Compose** | Full (vault-only operation) | + Retrieve source material | Full source retrieval |
| **Lint** | Full vault audit | Same | Same |
| **Feedback** | Full (vault write only) | Same | Same |

When an MCP is unavailable, the system skips it, reports what was skipped, continues with available sources, and falls back through the [tool fallback chain](references/tool-fallback-chains.md).

</details>

## 📦 Installation

### From Git

```bash
git clone https://github.com/nealzhang_microsoft/second-brain-agent.git
```

Then add the cloned directory to Claude Code's plugin sources. The `.claude-plugin/plugin.json` manifest handles registration.

### Manual Install

```bash
cp -r second-brain-agent ~/.claude/plugins/second-brain-agent
```

### Vault Location

| Method | How |
|--------|-----|
| 🔧 Environment variable | `export SECOND_BRAIN_VAULT=/your/path` |
| 📄 Config file | `~/.second-brain/config.json` → `{"vault_path": "/your/path"}` |
| 🏠 Default | `~/second-brain/` |

Resolution order: env var → config file → default.

## 📂 Vault Structure

Created automatically on first run:

```
~/second-brain/
├── CLAUDE.md                    # Schema (loaded by Claude Code)
├── index.md                     # Wiki catalog with tagged entries
├── log.md                       # Chronological event log
├── wiki/
│   ├── identity.md              # Who you are (loaded every session)
│   ├── people.md                # People directory with context
│   ├── channels.md              # Teams channels/chats with IDs
│   ├── subscriptions.md         # Daily brief monitoring config
│   ├── top-of-mind.md           # Current priorities
│   ├── todo.md                  # Tasks and follow-ups
│   ├── decisions.md             # Decision log with rationale
│   ├── concepts.md              # Concepts and mental models
│   ├── bookmarks.md             # Saved links
│   ├── tools.md                 # MCP status (auto-generated)
│   ├── overviews/               # Filed-back synthesis
│   └── projects/                # One page per project
├── playbooks/                   # Your playbook overrides
├── raw/                         # Immutable source documents
│   ├── documents/  channels/  chats/  emails/
│   ├── meetings/   articles/  assets/
│   └── sessions/               # Session ledgers
└── ~/.second-brain/config.json  # Vault location (outside vault)
```

## 🎨 Customization

### Playbooks — Define Your Voice

Playbooks are concrete output recipes — not abstract style guides. Each defines a specific output type with structure, template, examples, and anti-patterns.

| Shipped Default | Purpose |
|----------------|---------|
| `daily-brief.md` | Morning signal sweep |
| `email-status-brief.md` | Status emails to leadership |
| `teams-channel-post.md` | Teams channel updates |
| `chat-message-polish.md` | Chat message refinement |
| `ado-rag-workstream.md` | ADO RAG/workstream updates |
| `weekly-review.md` | Weekly review summaries |

> **Override:** Create a playbook with the same name in `{vault}/playbooks/` — it takes precedence over the plugin default.
>
> **Add new:** Create any `.md` file in `{vault}/playbooks/`, register it in `_index.md`, and the Composer starts using it automatically.

### Other Customizations

| What | How |
|------|-----|
| 🧠 **Identity & preferences** | Edit `wiki/identity.md` directly, or say `"remember: I prefer bullet points"` |
| 📡 **Daily brief sources** | Edit `wiki/subscriptions.md` — add channels, chats, email filters, ADO queries |
| 📚 **New wiki pages** | Create in `wiki/`, add to entity routing table in `CLAUDE.md` |
| 🔗 **New entity types** | Add to the entity routing table — the Analyst starts routing automatically |

## 📋 First Principles

> From [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — the design philosophy behind Second Brain.

| # | Principle | Meaning |
|---|-----------|---------|
| P1 | Wiki is persistent, compounding | Knowledge compiled once, kept current |
| P2 | Raw sources immutable | Never modify originals in `raw/` |
| P3 | LLM owns the wiki | Agents maintain all wiki pages |
| P4 | Single source touches many pages | One ingest updates people, projects, todo, etc. |
| P5 | Good answers filed back | Synthesis worth keeping goes to `wiki/overviews/` |
| P6 | Schema is discipline | CLAUDE.md defines the rules |
| P7 | Maintenance cost → zero | More agents ≠ better |
| P8 | Index-first navigation | Always read `index.md` before drilling in |
| P9 | Lint keeps wiki healthy | Regular audits catch rot |
| P10 | Connections = content | Cross-links between pages are knowledge |

## 🔧 Troubleshooting

<details>
<summary>Common issues and fixes</summary>

| Problem | Cause | Fix |
|---------|-------|-----|
| "Token expired" / 401 errors | MCP auth tokens need refresh | Run `refresh-tokens` skill or re-authenticate |
| "MCP not found" during daily brief | Plugin not installed or not loaded | Check `wiki/tools.md`. Install missing plugin |
| "Vault not found" | Can't locate vault directory | Set `SECOND_BRAIN_VAULT` env var or check `~/.second-brain/config.json` |
| Bootstrap didn't run | `wiki/identity.md` already exists | Delete `{vault}/wiki/identity.md` to re-trigger |
| Playbook not applied | Not registered | Add to `{vault}/playbooks/_index.md` |
| Daily brief is empty | No subscriptions | Edit `{vault}/wiki/subscriptions.md` |
| Agent can't find files | `vault_root` resolved wrong | Run `cat ~/.second-brain/config.json` to verify |
| Stale wiki data | Pages not updated | Run `lint` → then `ingest` fresh sources |

</details>

## 📁 Examples

The `examples/` directory contains **real examples** from a mature vault deployment — not synthetic data:

- `identity-example.md` — fully populated identity with communication preferences and writing styles
- `people-example.md` — people directory with 20+ entries, roles, relationships, VIP flags
- `channels-example.md` — Teams channels and chats with real IDs
- `subscriptions-example.md` — complete daily brief subscription configuration

> 💡 Use these as calibration for the level of detail the agents work best with. The richer your wiki, the better the outputs.

## 🙏 Credits

- **Concept:** [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) by Andrej Karpathy
- **Built by:** Neal Zhang (nealzhang@microsoft.com)

## 📄 License

MIT
