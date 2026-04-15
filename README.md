# Second Brain Agent 🧠

> 🌅 **"Catch me up."** — Say two words, and your AI Chief of Staff sweeps your inbox, chat, calendar, and project tracker into a single daily brief. Priorities updated. Action items filed. Knowledge base current.
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
> catch me up           # daily brief — bootstrap interview runs on first use
> ingest [paste text]   # save anything to your brain
> what do I know about  # query your knowledge base
> draft a reply to...   # compose styled output
> lint                  # vault health check
```

> 📋 **First run:** The system detects no vault exists and walks you through a **5-question bootstrap interview** — name, stakeholders, channels, priorities, communication style. After that, every command works immediately.
>
> 🔌 **Zero external tools required.** All operations work without any MCP servers. MCP integrations (email, chat, calendar, project trackers) add capabilities progressively — install only what you need. [Details →](#-mcp-integrations)

## 🎯 What It Does

**7 operations, one brain:**

| Say This | What Happens |
|----------|-------------|
| `catch me up` / `daily brief` | 🌅 Sweeps email, chat, calendar, project tracker → cross-references with your priorities → styled brief → wiki updated |
| `ingest` / `save this` | 📥 Saves to `raw/`, extracts entities, routes to wiki pages (people, projects, tasks, decisions) |
| `what do I know about X` | 🔍 Searches wiki, synthesizes answer with citations, offers to file back to `wiki/overviews/` |
| `draft` / `post to` / `email` | 📤 Picks playbook by audience + channel, drafts styled output, sends on confirmation |
| `summarize` / `analyze` | ✍️ Like communicate but for you — iterates until you approve |
| `lint` / `health check` | 🔧 Full vault audit: schema, orphans, index consistency, stale entries |
| `remember` / `from now on` | 🧠 Updates the right wiki page or playbook based on what you're correcting |

> 💡 **Classification is by intent, not keywords.** "What's going on with the team?" → daily brief. "What's going on with Project X?" → query. The dispatcher figures it out.

---

## 🧬 How Knowledge Extraction Works

This is the core of Second Brain — how raw, unstructured data from diverse sources becomes structured, queryable, cross-linked knowledge.

### The Pipeline: Raw → Extract → Route → Link

```
                                    ┌─── wiki/people.md
                                    ├─── wiki/projects/X.md
  Email ──┐                         ├─── wiki/todo.md
  Chat  ──┤   ┌───────────┐   ┌────┤─── wiki/decisions.md
  Cal   ──┼──▶│ Retriever  │──▶│    ├─── wiki/top-of-mind.md
  ADO   ──┤   │ (raw-first)│   │    ├─── wiki/bookmarks.md
  Docs  ──┤   └───────────┘   │    └─── wiki/concepts.md
  Paste ──┘         │         │
              ┌─────▼─────┐   │    Entity Routing Table
              │  Analyst   │───┘    (defined in CLAUDE.md)
              │ (extract + │
              │  route)    │
              └────────────┘
```

### Step 1: Raw-First Rule (Data Integrity)

**Every piece of inbound data is saved verbatim to `raw/` BEFORE any processing.** This is non-negotiable — it's the foundation of the system's data integrity.

```
raw/
├── documents/2026-04-13-q2-planning-doc.md
├── emails/2026-04-13-budget-approval.md
├── channels/2026-04-13-team-standup-digest.md
├── chats/2026-04-13-alice-pipeline-delay.md
├── meetings/2026-04-13-sprint-planning.md
└── articles/2026-04-13-karpathy-llm-wiki.md
```

Each raw file includes frontmatter:

```markdown
---
type: email
source: alice@example.com
retrieved: 2026-04-13T09:15:00Z
tool_used: WorkIQ-Mail MCP
---

# Re: Q2 Budget Allocation

[Full content preserved as-is]
```

**Why raw-first?** If entity extraction fails, the source data is preserved. If you want to re-process later with better extraction logic, the originals are untouched. It's the equivalent of write-ahead logging in databases.

### Step 2: Entity Extraction (The Analyst)

The Analyst agent reads raw content and extracts structured entities using the **Entity Routing Table** — a schema that maps entity types to their wiki home pages:

| Entity | Home Page | What Gets Extracted |
|--------|-----------|-------------------|
| 👤 Person | `wiki/people.md` | name, alias, email, role, team, VIP flag, communication style, recent activity |
| 📁 Project | `wiki/projects/{name}.md` | status, IDs, milestones, blockers, architecture decisions |
| ✅ Task | `wiki/todo.md` | description, source, added date, due date, owner, priority section |
| ⚖️ Decision | `wiki/decisions.md` | what was decided, rationale, date, who decided, status |
| 🎯 Priority | `wiki/top-of-mind.md` | focus area, theme, open questions |
| 🔗 Link | `wiki/bookmarks.md` | URL, description, category |
| 💬 Channel | `wiki/channels.md` | name, IDs, purpose, key people |
| 🔧 Tool | `wiki/tools.md` | name, status, parameters, limitations |
| 💡 Concept | `wiki/concepts.md` | name, description, source reference |
| 🤝 Relationship | `wiki/people.md` | who→who, how they relate, context |

**Example: One email touches 4 wiki pages**

An email from Alice saying *"The GPU allocation for Project Atlas is approved. Bob will handle deployment by Friday. Let's skip the weekly sync this week."*

The Analyst extracts:

```yaml
entities:
  - type: person
    name: Alice
    update: "Approved GPU allocation for Project Atlas"
    target: wiki/people.md

  - type: project
    name: Project Atlas
    update: "GPU allocation approved, deployment by Friday"
    target: wiki/projects/atlas.md

  - type: task
    description: "Bob: Handle GPU deployment for Atlas"
    due: "Friday"
    owner: Bob
    target: wiki/todo.md

  - type: decision
    what: "Skip weekly sync this week"
    who: Alice
    target: wiki/decisions.md
```

**This is Karpathy's Principle P4: "Single source touches many pages."** One email updates people, projects, tasks, and decisions simultaneously.

### Step 3: Routing Plan → Mutations

The Analyst produces a **routing plan** — a structured specification of exactly what should be written where. The Actor agent then executes these mutations in a strict order:

```
1. raw/ writes first      ← source preserved before anything else
2. wiki/ page writes      ← create, append, or update sections
3. External sends         ← only AFTER raw outbound is saved
4. index.md updates       ← entries reference pages that now exist
5. log.md append          ← records what actually happened
6. Session ledger update  ← records in raw/sessions/
```

Every wiki update includes **citations** back to the raw source:

```markdown
## Alice Chen

- **Role:** ML Platform Lead
- **Team:** Infrastructure
- Approved GPU allocation for [[raw/emails/2026-04-13-budget-approval|Project Atlas]] (2026-04-13)
```

### Step 4: Cross-Referencing (Daily Brief Intelligence)

During a daily brief, the Analyst doesn't just summarize — it **cross-references** new signals against existing knowledge:

```
New signals (from Retriever sweep)     Existing knowledge (from wiki)
─────────────────────────────────      ──────────────────────────────
Email: "Atlas deployment delayed"   ×  wiki/projects/atlas.md: "deploy by Friday"
                                       → CONFLICT detected: deadline at risk

Teams: "New hire starting Monday"   ×  wiki/people.md: no entry for new hire
                                       → NEW ENTITY: needs people.md entry

Calendar: "1:1 with VP cancelled"   ×  wiki/top-of-mind.md: "prepare VP update"
                                       → PRIORITY SHIFT: VP update no longer urgent

ADO: "Bug #4521 marked critical"    ×  wiki/todo.md: not listed
                                       → NEW TASK: add to "Do Today" section
```

This cross-referencing is what makes the daily brief intelligent — it doesn't just list what happened, it tells you **what changed, what conflicts, and what needs your attention.**

### Step 5: Filed-Back Synthesis (Compounding Knowledge)

When you query the system and get a useful synthesis, that answer gets **filed back** to `wiki/overviews/`:

```
You: "What's the status of all GPU-related work?"

→ Analyst searches wiki, synthesizes across projects/atlas.md, todo.md, people.md
→ Produces cited answer
→ Offers: "Want me to save this as wiki/overviews/gpu-workstream-status.md?"
→ If yes: synthesis becomes part of the knowledge base for future queries
```

**This is Karpathy's Principle P5: "Good answers filed back."** The wiki compounds — every query potentially adds knowledge.

### The Feedback Loop

```
         ┌──────────────────────────────────────┐
         │                                      │
    raw/ ──▶ extract ──▶ wiki/ ──▶ query ──▶ overviews/
         │                 │                    │
         │                 └── daily brief ─────┤
         │                      (cross-ref)     │
         │                                      │
         └──── "remember X" ◀── feedback ◀──────┘
```

Over time, the wiki becomes a **high-signal, low-noise knowledge base** that reflects exactly what matters to you — not a firehose of raw data, but curated, cross-linked, cited knowledge.

---

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
| 📡 **Retriever** | ALL inbound data — sweeps, file reads, URL fetches | MCP tools, files, URLs | raw/ only |
| 🔬 **Analyst** | Entity extraction, synthesis, routing plans | wiki/, raw/ | Nothing (read-only) |
| 🎨 **Composer** | Drafts styled output using playbooks + identity | playbooks/, wiki/identity.md | Nothing (read-only) |
| ⚡ **Actor** | ALL mutations — vault writes, external sends, checklist | Mutation plan from Manager | wiki/, raw/, index.md, log.md |
| 🔍 **Auditor** | Health checks, lint, post-op verification | Entire vault | Nothing (read-only, reports issues) |

<details>
<summary>Example pipeline: Daily Brief</summary>

```
1. Retriever(sweep)         — pulls email, chat, calendar, project tracker signals
2. Analyst(cross-reference) — compares signals against priorities and existing wiki
3. Composer(daily-brief)    — formats using playbooks/daily-brief.md + identity
4. Actor(update wiki)       — writes to wiki/todo.md, wiki/top-of-mind.md, log.md
5. Auditor(verify)          — confirms all checklist items passed
```

</details>

<details>
<summary>Example pipeline: Ingest</summary>

```
1. Retriever(targeted)      — fetches the specific source (doc, email, URL, paste)
2. Analyst(ingest)           — extracts entities, builds routing plan
3. Actor(execute mutations)  — writes raw/, updates wiki pages, updates index.md
4. Auditor(post-op-verify)   — verifies all planned mutations were executed
```

</details>

## 🔌 MCP Integrations

**None required.** Everything works at zero MCPs. Each integration you add unlocks more data sources and outbound channels.

The system is designed to work with any MCP server that provides data access. Out of the box, it includes fallback chains for these categories:

| Category | What It Unlocks | Required? |
|----------|----------------|:---------:|
| 📧 **Email** | Inbox sweep, compose & send email | No |
| 📅 **Calendar** | Calendar entries in daily briefs | No |
| 💬 **Chat** | Channel/thread monitoring, post messages | No |
| 📁 **Documents** | Retrieve docs from cloud storage | No |
| 🔧 **Project Tracker** | Work items, PRs, pipeline status | No |
| 📓 **Notes** | Note-taking app integration | No |
| 💬 **Messaging** | Additional messaging platforms | No |

> **Bring your own MCPs.** The system uses a [tool fallback chain](references/tool-fallback-chains.md) — if the primary tool fails, it tries alternatives, and ultimately falls back to "ask user to paste." You can plug in any MCP that provides email, chat, calendar, or document access.
>
> 🔄 **Auto-detection:** On each session, the system probes for available tools and records results in `wiki/tools.md`. Install an MCP anytime — it's picked up automatically.

<details>
<summary>Graceful degradation matrix</summary>

| Operation | 0 MCPs | Some MCPs | All MCPs |
|-----------|--------|-----------|----------|
| **Daily Brief** | Vault-only: priorities, stale todos, upcoming items | Partial sweep: available sources only | Full sweep across all channels |
| **Ingest** | Paste/URL/file only | + Retrieve from available sources | Full retrieval from any source |
| **Query** | Vault search with citations | Same (queries are vault-only) | + Pull fresh data if vault is stale |
| **Communicate** | Draft → save for manual send | Send via available channels | Full outbound across all channels |
| **Compose** | Full (vault-only operation) | + Retrieve source material | Full source retrieval |
| **Lint** | Full vault audit | Same | Same |
| **Feedback** | Full (vault write only) | Same | Same |

</details>

## 📦 Installation

### From Git

```bash
git clone https://github.com/nealzhang_microsoft/second-brain-agent.git
```

Add the cloned directory to Claude Code's plugin sources. The `.claude-plugin/plugin.json` manifest handles registration.

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
│   ├── channels.md              # Chat channels with IDs
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
| `teams-channel-post.md` | Chat channel updates |
| `chat-message-polish.md` | Chat message refinement |
| `ado-rag-workstream.md` | Project tracker updates |
| `weekly-review.md` | Weekly review summaries |

> **Override:** Create a playbook with the same name in `{vault}/playbooks/` — it takes precedence over the plugin default.
>
> **Add new:** Create any `.md` file in `{vault}/playbooks/`, register it in `_index.md`, and the Composer starts using it automatically.

### Other Customizations

| What | How |
|------|-----|
| 🧠 **Identity & preferences** | Edit `wiki/identity.md` directly, or say `"remember: I prefer bullet points"` |
| 📡 **Daily brief sources** | Edit `wiki/subscriptions.md` — add channels, chats, email filters |
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
| Bootstrap didn't run | `wiki/identity.md` already exists | Delete `{vault}/wiki/identity.md` to re-trigger |
| Playbook not applied | Not registered | Add to `{vault}/playbooks/_index.md` |
| Daily brief is empty | No subscriptions | Edit `{vault}/wiki/subscriptions.md` |
| MCP tool not detected | Plugin not loaded | Check `wiki/tools.md`. Install/enable the MCP plugin |
| Auth errors (401) | Token expired | Refresh auth for the specific MCP provider |
| Agent can't find files | `vault_root` resolved wrong | Check `~/.second-brain/config.json` |
| Stale wiki data | Pages not updated | Run `lint` → then `ingest` fresh sources |

</details>

## 📁 Examples

The `examples/` directory contains **real examples** from a mature vault deployment:

- `identity-example.md` — fully populated identity with communication preferences and writing styles
- `people-example.md` — people directory with 20+ entries, roles, relationships
- `channels-example.md` — chat channels with IDs
- `subscriptions-example.md` — complete daily brief subscription configuration

> 💡 Use these as calibration for the level of detail the agents work best with. The richer your wiki, the better the outputs.

## 🙏 Credits

- **Concept:** [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) by Andrej Karpathy
- **Built by:** Neal Zhang

## 📄 License

MIT
