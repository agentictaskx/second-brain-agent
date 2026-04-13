# Plan: Unify second-brain + mai-cos into a Personal AI Chief of Staff Agent

## Context

Neal currently has **two separate systems that should be one:**

1. **`/second-brain`** skill — LLM Wiki for persistent knowledge (vault at Obsidian). Has: raw sources, wiki pages, index, log, schema. Good at: storing/retrieving knowledge, entity routing, cross-linking. Bad at: remembering styles, tool handling, parallelism, completing checklists.

2. **`/mai-cos`** skill — Chief of Staff for daily productivity. Has: identity (`context/me.md`), styles (`context/styles.md`), people directory, subscriptions, memory (working/episodic/long-term), capabilities (daily brief, RAG update, todo), output persistence. Bad at: it's a monolithic skill too, most context files are still templates (unfilled), and it duplicates data that second-brain already has.

**The problem:** These are two halves of the same system. The second-brain has the data but can't produce styled output or gather daily signals. Mai-cos has the output capabilities and style awareness but no persistent knowledge graph. Neal's CLAUDE.md has identity/preferences that should live in the vault, not the orchestrator config.

**Goal:** Merge both into a unified **Personal AI Chief of Staff Agent** at `C:/Users/nealzhang/project/second-brain-agent` that:
- Stores all knowledge in the Obsidian vault (second-brain's wiki)
- Produces all output using playbooks/styles (mai-cos's style system)
- Gathers signals from all sources (mai-cos's subscriptions)
- Tracks identity, relationships, preferences in the vault (not CLAUDE.md)
- Uses a manager + specialist sub-agent architecture for reliability
- Moves CLAUDE.md to thin orchestrator only

## What Real Usage Data Reveals

Analysis of 7 days of vault logs + mai-cos structure shows both systems have complementary strengths:

### What Second-Brain Has (Keep)
- Persistent wiki with raw sources, cross-references, first principles
- Entity routing table (people → wiki/people.md, projects → wiki/projects/)
- Enforcement rules (Raw-First, session ledger, completion checklist)
- 26KB schema (CLAUDE.md in vault) as single source of truth
- Tool Discovery Log (wiki/tools.md) with verified/broken/untested status

### What Mai-Cos Has (Absorb Into Vault)
- **Identity:** `context/me.md` — name, role, team, focus areas, stakeholders
- **Styles:** `context/styles.md` — writing voice per audience × content type
- **People:** `context/people.md` — key people directory with communication preferences
- **Subscriptions:** `context/subscriptions.md` — watched channels, key chats, email filters
- **Priorities:** `context/now.md` — weekly priorities, open loops, blockers
- **Memory:** working.md, episodic.md, long-term.md, todo.md
- **Capabilities:** daily-brief, ado-rag-update, workstream-rag-summary, todo, send-output
- **Output persistence:** auto-save to outputs/ in .md and .html

### What Neither Has (Must Build)
- **Parallel sub-agent execution** — everything runs in one context window today
- **Playbook-driven composition** — styles exist but aren't read by a dedicated agent
- **Automatic style learning** — corrections evaporate into chat history
- **Cross-session task tracking** — mai-cos has todo.md but it's not connected to second-brain's todo
- **Unified daily signal gathering** — mai-cos has subscriptions but can't store results in the wiki
- **CLAUDE.md thinning** — identity/preferences currently duplicated across CLAUDE.md, mai-cos/me.md, and vault CLAUDE.md

### Data Migration Map

| Data | Current Location | New Location in Vault |
|------|-----------------|----------------------|
| Identity | CLAUDE.md "About Neal" + mai-cos/context/me.md | `wiki/identity.md` |
| Communication preferences | CLAUDE.md + mai-cos/context/me.md | `wiki/identity.md` |
| Writing styles | mai-cos/context/styles.md | `wiki/playbooks/` (one per output type) |
| People directory | mai-cos/context/people.md + wiki/people.md | `wiki/people.md` (merge — vault version is richer) |
| Key stakeholders | CLAUDE.md + mai-cos/context/me.md | `wiki/people.md` (VIP section) |
| Subscriptions | mai-cos/context/subscriptions.md | `wiki/subscriptions.md` (new) |
| Weekly priorities | mai-cos/context/now.md + wiki/top-of-mind.md | `wiki/top-of-mind.md` (merge) |
| Episodic memory | mai-cos/memory/episodic.md | `raw/sessions/` (already exists in vault) |
| Long-term memory | mai-cos/memory/long-term.md | Distributed: missions → `wiki/projects/`, preferences → `wiki/identity.md`, lessons → `wiki/decisions.md` |
| Todo | mai-cos/memory/todo.md + wiki/todo.md | `wiki/todo.md` (merge — vault version has richer metadata) |
| Tool config | mai-cos/config/mcp-tool-reference.md + wiki/tools.md | `wiki/tools.md` (merge) |
| Capabilities | mai-cos/capabilities/*.md | Agent definitions in `agents/` |
| Output templates | mai-cos inlined in capabilities | `wiki/playbooks/` |
| Outputs | mai-cos/outputs/ | `raw/` (outbound content per Raw-First rule) |

### What Moves OUT of CLAUDE.md

| Section | Currently In | Moves To | CLAUDE.md Keeps |
|---------|-------------|----------|----------------|
| "About Neal" (identity, role, team) | Global CLAUDE.md | `wiki/identity.md` | Nothing — agents read vault |
| Communication preferences | Global CLAUDE.md | `wiki/identity.md` | Nothing |
| Output format rules | Global CLAUDE.md | `wiki/playbooks/_defaults.md` | Nothing |
| Key stakeholders | Global CLAUDE.md | `wiki/people.md` | Nothing |
| Expertise, frameworks | Vault CLAUDE.md | `wiki/identity.md` | Nothing |
| Tool priority (Rule 5) | Vault CLAUDE.md | `wiki/tools.md` (already there) | Pointer only |

**CLAUDE.md becomes:** Agent routing rules only. "When user says X, spawn Y agent with Z context." No personal data, no preferences, no styles.

## Unified Architecture

### Design Principle: Minimal Agents, Maximum Capability

Karpathy's P7: "Maintenance cost approaches zero." More agents = more agent definitions to maintain, more handoff points to break, more context loading overhead. The system should have the **fewest agents that cover all operations**.

**Rule: If two agents differ only by a parameter, they're one agent. If they need different context loads, they're different agents.**

```
Manager (orchestrator — loads identity, reads schema, classifies intent, routes operations)
  │
  ├── Retriever   — ALL inbound data (broad sweep OR targeted — parameter-driven)
  ├── Analyst     — reads vault + extracts entities + synthesizes answers (investigative)
  ├── Composer    — drafts styled output using playbooks + identity (creative)
  ├── Actor       — ALL mutations (write vault, send externally, update index/log, run checklist)
  └── Auditor     — read-only health checks, lint, schema audit, post-op verification
```

### Why 5 Specialists (Not 4, Not 9)

The Round 2 adversarial review (Finding 1) correctly identified that the Thinker was doing 4 different cognitive jobs with different context needs. Split into Analyst + Composer:

| Agent | Cognitive Mode | Context Load | Why Separate |
|-------|---------------|--------------|--------------|
| **Analyst** | Investigative — find facts, extract entities, connect patterns | index.md + relevant wiki pages + entity routing table | Needs vault breadth — reads many pages lightly |
| **Composer** | Creative — match tone, structure, audience | playbook + identity.md + people.md (recipient) + data from Analyst | Needs style depth — reads few files deeply |

These can't merge because they need **different context**. The Analyst reads 10+ wiki pages to extract entities. The Composer reads 1 playbook + identity + people to draft styled output. Loading both contexts into one agent wastes half the context window on irrelevant material.

| Old (4 specialists) | New (5 specialists) | Change |
|---------------------|---------------------|--------|
| Thinker (4 jobs) | **Analyst** (entity extraction + query synthesis) + **Composer** (styled drafting) | Split by cognitive mode + context needs |
| Retriever | **Retriever** (unchanged) | — |
| Actor | **Actor** (unchanged) | — |
| Auditor | **Auditor** (expanded — now also does post-op verification + schema audit) | Expanded scope |

**Total: 1 Manager + 5 Specialists = 6 agent definitions.**

### Agent Roster

#### Manager (`agents/manager.md`)
- **Role:** Orchestrator — loads identity, reads schema, classifies user intent, selects playbook, spawns the right pipeline
- **Tools:** Read, Grep, Glob, Agent
- **Key behaviors:**
  - ALWAYS reads `CLAUDE.md` + `wiki/identity.md` at session start (first invocation). Caches identity in session ledger for subsequent invocations.
  - Classifies user intent → selects operation type → selects playbook (by intent + audience + format, NOT keyword matching)
  - **When intent is ambiguous:** Asks the user. e.g., "Check on Kunyang" → "Do you want me to: (a) look up what I know about Kunyang, (b) check ADO for his latest updates, or (c) draft a message to him?"
  - Spawns specialists with tailored context (identity excerpt, relevant schema sections, playbook path, tool discovery sections)
  - Only agent that talks to user
  - **Does NOT do entity extraction or analysis** — that's the Analyst's job
- **Truly thin:** Parse intent → select playbook → spawn pipeline → present results → confirm with user
- **Error handling:** When a specialist returns `status: partial` or `status: failed`, Manager presents what succeeded, notes what failed, and offers to retry. Never silently drops failures.

#### Retriever (`agents/retriever.md`)
- **Role:** ALL inbound data retrieval — broad sweep (daily brief) or targeted (one doc/work item)
- **Tools:** Read, Write, Grep, Glob, Bash, + all inbound MCP tools
- **Key behaviors:**
  - Reads `wiki/tools.md` for what works on this device. Tries preferred tool, falls back gracefully.
  - Reads `wiki/subscriptions.md` when doing broad sweeps (daily brief)
  - Saves everything to `raw/` (Raw-First rule) — creates raw source files AND adds index entry for each
  - Returns structured content + metadata + list of raw files created
- **Mode parameter:** Manager tells it `mode: sweep` or `mode: targeted`
- **Error response format:**
  ```
  { status: "success" | "partial" | "failed",
    raw_files_created: ["raw/documents/..."],
    content: { ... },
    failed_sources: [{ source: "...", error: "...", recoverable: true/false }] }
  ```

#### Analyst (`agents/analyst.md`)
- **Role:** The investigator — reads vault, extracts entities, synthesizes answers, produces routing plans
- **Tools:** Read, Grep, Glob, Bash
- **Key behaviors:**
  - Reads `index.md` first (P8 index-first navigation), then drills into relevant pages
  - Reads `wiki/identity.md` for user context (role, focus)
  - Does entity extraction + routing recommendations (what wiki pages to update, with what content)
  - Synthesizes answers with `[[wikilink]]` citations for queries
  - Classifies queries as **lookup** (simple fact retrieval, no file-back) or **synthesis** (new insight produced, recommend file-back per P5)
  - Returns: entity routing plan + action items + answer (if query) + file-back recommendation
  - **Read-only** — never writes to vault

#### Composer (`agents/composer.md`)
- **Role:** The stylist — drafts output content using playbooks + identity + recipient context
- **Tools:** Read, Grep, Glob, Bash
- **Key behaviors:**
  - ALWAYS reads the selected playbook from `playbooks/`
  - Reads `wiki/identity.md` for communication preferences and voice
  - Reads `wiki/people.md` for recipient context when relevant
  - Receives data/facts from the Analyst's output — doesn't re-read vault pages
  - Drafts styled output (messages, emails, RAGs, slides, summaries, analyses, daily briefs)
  - **Read-only** — returns draft content, never writes
- **Style learning:** When user corrects output, Manager spawns Actor to update playbook.

#### Actor (`agents/actor.md`)
- **Role:** ALL mutations — writes vault pages, sends externally, updates index/log/session-ledger, runs completion checklist
- **Tools:** Read, Write, Edit, Grep, Glob, Bash, + outbound MCP tools
- **Key behaviors:**
  - Receives a structured mutation plan from Manager (list of pages to write/edit, content for each, external sends)
  - Executes mutations in order: raw/ first (Rule 1), then wiki/ pages, then external sends
  - **Serializes writes to the same page** — different pages can be parallelized via multiple Actor instances
  - Updates `index.md` after all wiki writes
  - Updates `playbooks/_index.md` whenever it creates/modifies a playbook
  - Appends to `log.md` and session ledger
  - Runs the **completion checklist** as hard gate before returning
  - For external sends: saves outbound to `raw/` BEFORE sending (Raw-First), reports message IDs
  - **Error response format:**
    ```
    { status: "success" | "partial" | "failed",
      pages_written: ["wiki/people.md", ...],
      pages_failed: [{ page: "...", error: "..." }],
      sends_completed: [{ channel: "...", message_id: "..." }],
      sends_failed: [{ channel: "...", error: "...", recoverable: true/false }],
      checklist: { raw_saved: true, session_ledger: true, ... } }
    ```

#### Auditor (`agents/auditor.md`)
- **Role:** Read-only health checks + post-operation verification + schema audit
- **Tools:** Read, Grep, Glob, Bash
- **Key behaviors:**
  - **Wiki lint:** stale pages, orphans, broken links, bidirectional link check
  - **Todo accountability:** flag 7+ day items, mark done items
  - **First-principles audit** (P4/P5/P8/P10)
  - **Post-operation verification** (new): After every Actor completes, Manager can optionally spawn Auditor to verify:
    - Every raw/ file has a corresponding index.md entry
    - log.md's last entry matches the operation just completed
    - All wiki pages referenced in the Actor's mutation plan were actually written
    - This is "someone else checks my homework" — not self-verification
  - **Schema audit** (new): During lint, also checks:
    - Entity routing table for overlapping types (e.g., "vendor" and "partner" with 80% overlap → suggest merge)
    - Playbook registry for duplicates or gaps
    - Inbound/outbound maps for stale entries (tools that haven't been used in 30+ days)
    - Entity type count — if approaching 20, flag for review ("merge or justify")
  - **Subscription health:** stale channels, untested tools
  - **Identity completeness:** unfilled fields, missing people entries
  - Returns structured lint report. Does NOT fix issues — Manager spawns Actor for fixes.

### Parallelism Model

**When to parallelize:** The Actor can be spawned multiple times in parallel, but each Actor instance writes to **distinct pages**. The Manager ensures no two Actors target the same file.

```
Parallel OK:                    Sequential REQUIRED:
Actor 1 → wiki/people.md       Actor 1 → wiki/people.md (person A)
Actor 2 → wiki/projects/x.md   Actor 1 → wiki/people.md (person B)  ← same file, serialize
Actor 3 → wiki/todo.md         Actor 1 → wiki/people.md (person C)
```

**The Manager groups mutations by target page** before spawning Actors. If an ingest routes 3 people to wiki/people.md and 2 items to wiki/todo.md, the Manager creates:
- Actor 1: all 3 people updates to wiki/people.md (sequential within)
- Actor 2: both todo items to wiki/todo.md (sequential within)
- Actor 3: raw source to raw/documents/... 
- These 3 Actors run in parallel.

## Playbook System

### What Playbooks Are

Playbooks are **concrete output recipes** — each one defines a specific output type with trigger phrases, exact structure, examples, and what to include/exclude. They're NOT a fixed list. Users create new playbooks anytime ("save this as a playbook for next time"), and the system auto-matches the right playbook based on trigger phrases.

### Playbook File Format

Every playbook has metadata that the Manager uses to select — NOT trigger-string matching, but **intent + audience + format matching**:

```yaml
---
title: Weekly RAG Update
type: playbook
audience: team           # team | leadership | peer | self | external
format: html             # markdown | html | slide | email | chat
channel: ado             # ado | teams-channel | teams-chat | email | slack | doc | vault
examples:
  - "write my weekly RAG for ADO"
  - "workstream update"
  - "mission update"
---

# Weekly RAG Update

## When to Use
[description of when this playbook applies]

## Structure
[exact section order, formatting rules]

## Template
[concrete template with placeholders]

## Examples
[real examples from past outputs]

## Anti-Patterns
[what NOT to do — learned from corrections]
```

### How Playbook Selection Works

The Manager selects playbooks by **understanding intent**, not keyword matching:

1. User says something ("Help me write a message to Tao about the pipeline delay")
2. Manager classifies: **audience** = peer (Tao), **format** = chat, **channel** = teams-chat
3. Manager reads `playbooks/_index.md` — filters by audience + format + channel
4. If one match → passes playbook path to Thinker
5. If multiple matches → Manager picks best fit based on context, or asks user
6. If no match → Thinker drafts best-effort, Manager offers: "Save this format as a new playbook?"
7. If user corrects output → Actor updates the playbook with the correction

**Why intent-based, not trigger-based:** "Summarize this for Rukmini" could be an email, a slide, or a doc. Trigger matching can't distinguish — but the Manager knows Rukmini is VP (from wiki/people.md), so it selects `leadership-slide` or `email-status-brief` based on whether the user said "email" or "slide." Context matters more than keywords.

### Creating New Playbooks

Users can create playbooks two ways:
- **Explicit:** "Save this as a playbook called [name]" → Manager spawns Writer to create `playbooks/{name}.md`
- **Implicit:** User corrects an output that had no playbook → Manager offers to save the corrected format as a new playbook

### Starter Playbooks (seeded from vault history)

| Playbook | Source | Trigger Examples |
|----------|--------|-----------------|
| `daily-brief.md` | mai-cos/capabilities/daily-brief.md | "daily brief", "morning brief", "catch me up" |
| `ado-rag-workstream.md` | wiki/overviews/ado-rag-writing-patterns.md | "weekly RAG", "ADO RAG", "mission update" |
| `teams-channel-post.md` | raw/chats/sent-* patterns | "post to Teams", "channel update" |
| `chat-message-polish.md` | usage-log feedback | "polish this message", "draft reply" |
| `email-status-brief.md` | raw/chats/sent-uu-core-team | "send status email", "email brief" |
| `weekly-review.md` | wiki/reviews/weekly-2026-W15.md | "weekly review", "weekly summary" |

More playbooks can be added at any time. The system is designed to grow.

## Information Lifecycle: How Data Flows Through the System

### The Core Question

Every piece of information that enters the system must answer 5 questions:
1. **Where did it come from?** → saved to `raw/` (immutable source)
2. **What kind of thing is it?** → classified by source type + content intent
3. **What entities does it contain?** → routed to the right wiki pages
4. **How do I find it later?** → indexed in `index.md` + cross-linked + tagged
5. **What should I do about it?** → action items extracted to `wiki/todo.md`

### Inbound Information Map

Every input type, how the Retriever fetches it, where the Actor stores it, and what wiki pages the Thinker routes entities to.

**This table is a starter set. New rows get added automatically** when the Retriever encounters a new source type or the user connects a new MCP tool. The Thinker updates `wiki/tools.md` with the new source type, and the Actor adds a row to the inbound registry in `CLAUDE.md`.

| Input Source | Retriever Method | Raw Storage | Wiki Pages Touched | Index Entry |
|-------------|-----------------|-------------|-------------------|-------------|
| **SharePoint/Word doc** | WorkIQ-Word MCP | `raw/documents/YYYY-MM-DD-{title}.md` | projects/, people, decisions, todo, bookmarks | `[doc] Title — one-line summary` |
| **PowerPoint deck** | WorkIQ-OneDrive MCP or file read | `raw/documents/YYYY-MM-DD-{title}.md` | projects/, concepts, decisions | `[ppt] Title — one-line summary` |
| **Teams channel posts** | WorkIQ-Teams listChannelMessages | `raw/channels/YYYY-MM-DD-{channel}.md` | projects/, people, todo, top-of-mind | `[channel] Channel — date range digest` |
| **Teams chat messages** | WorkIQ-Teams listChatMessages | `raw/chats/YYYY-MM-DD-{person-or-topic}.md` | people, projects/, decisions | `[chat] Person/Topic — key points` |
| **Slack messages** | Slack MCP | `raw/chats/YYYY-MM-DD-slack-{channel}.md` | projects/, people, todo | `[slack] Channel — digest` |
| **Email (inbox)** | WorkIQ-Mail search/get | `raw/emails/YYYY-MM-DD-{subject}.md` | people, projects/, todo, decisions | `[email] Subject — from whom, action needed` |
| **ADO work items** | ADO MCP wit_get_work_item | `raw/documents/YYYY-MM-DD-ado-{desc}.md` | projects/, people, todo | `[ado] Item# — title, status` |
| **Calendar/meetings** | WorkIQ-Calendar | `raw/meetings/YYYY-MM-DD-{meeting}.md` | people, projects/, todo, decisions | `[meeting] Name — attendees, outcomes` |
| **Website/article** | WebFetch or Defuddle CLI | `raw/articles/YYYY-MM-DD-{title}.md` | concepts, bookmarks, projects/ | `[article] Title — key takeaway` |
| **Slack canvas** | Slack MCP canvas_read | `raw/documents/YYYY-MM-DD-{canvas}.md` | projects/, concepts | `[canvas] Title — summary` |
| **User paste (text)** | Direct (no Retriever needed) | `raw/documents/YYYY-MM-DD-{desc}.md` | Depends on content — Thinker classifies | `[paste] Desc — summary` |
| **User conversation** | Session context | `raw/sessions/YYYY-MM-DD-session.md` | identity, decisions, todo, top-of-mind | Session ledger (not indexed separately) |
| *(new source discovered)* | *(Thinker proposes method)* | `raw/{type}/YYYY-MM-DD-{desc}.md` | *(Thinker classifies entities)* | *(Actor adds to index)* |

**Growth mechanism:** When the user says "ingest this Zotero paper" or "read my WeChat messages" and the system hasn't done it before:
1. Retriever checks `wiki/tools.md` — is there an MCP for this? What parameters work?
2. If tool exists but untested → Retriever tries it, records success/failure in `wiki/tools.md`
3. If tool doesn't exist → Retriever falls back to user paste or manual URL fetch
4. Actor adds the new source type to the inbound registry
5. Next time the same source type is requested, the system knows how

### Outbound Information Map

Every output type, where the Actor saves it, and how it's indexed for later retrieval.

**This table grows with playbooks.** Every new playbook implicitly creates a new outbound type. When the user says "save this as a playbook" after creating a new kind of output, the corresponding outbound row is added automatically.

| Output Type | Playbook Used | Raw Storage | Wiki Pages Touched | Index Entry |
|-------------|--------------|-------------|-------------------|-------------|
| **Workstream RAG** | `ado-rag-workstream.md` | `raw/documents/YYYY-MM-DD-rag-{workstream}.md` | projects/, reviews/ | `[rag] Workstream — Week N status` |
| **Squad RAG** | `ado-rag-workstream.md` (squad section) | `raw/documents/YYYY-MM-DD-rag-{squad}.md` | projects/ | `[rag] Squad — Week N status` |
| **Teams channel post** | `teams-channel-post.md` | `raw/chats/YYYY-MM-DD-sent-{channel}.md` | projects/, channels | `[sent] Channel — topic` |
| **Teams chat message** | `chat-message-polish.md` | `raw/chats/YYYY-MM-DD-sent-{person}.md` | people | `[sent] Person — topic` |
| **Email sent** | `email-status-brief.md` | `raw/emails/YYYY-MM-DD-sent-{subject}.md` | people, projects/ | `[sent] Subject — to whom` |
| **Leadership slide** | `leadership-slide.md` | `raw/documents/YYYY-MM-DD-slide-{topic}.md` | projects/, decisions | `[slide] Topic — for whom` |
| **Doc summary** | `doc-summary.md` | `raw/documents/YYYY-MM-DD-summary-{doc}.md` | projects/, bookmarks | `[summary] Doc — key findings` |
| **Strategic analysis** | `strategic-analysis.md` | Filed to `wiki/overviews/{topic}.md` | projects/, decisions, todo | `[analysis] Topic — conclusions` |
| **Weekly review** | `weekly-review.md` | Filed to `wiki/reviews/weekly-YYYY-Www.md` | todo, top-of-mind | `[review] Week N — highlights` |
| **Daily brief** | `daily-brief.md` | `raw/documents/YYYY-MM-DD-daily-brief.md` | todo, top-of-mind | `[brief] Date — key items` |
| *(new playbook created)* | *(user-defined)* | `raw/{type}/YYYY-MM-DD-{desc}.md` | *(defined in playbook)* | *(Actor adds to index)* |

**Growth mechanism:** When the user creates a new output type the system hasn't seen before:
1. Thinker drafts best-effort (no playbook)
2. User corrects → Manager offers: "Save this as a playbook?"
3. If yes → Actor creates `playbooks/{name}.md` with structure, template, examples from this session
4. The new playbook defines its own raw storage pattern and wiki routing
5. Next time → Thinker reads the playbook, output matches user's style

### Entity Routing: How the Thinker Classifies Content

**This is a living routing table.** New entity types can be added when the Thinker encounters something that doesn't fit existing categories. The Thinker proposes a new entity type → Manager confirms with user → Actor creates the wiki page and adds the route.

| Entity | Home Page | What to Capture | Growth Signal |
|--------|-----------|----------------|---------------|
| **Person** | `wiki/people.md` | Name, alias, email, role, team, squad, VIP flag, comm style, what they care about, recent activity | New person mentioned in any source |
| **Project** | `wiki/projects/{name}.md` | Status, tracking IDs, milestones, blockers, architecture, dependencies, squad structure | New project/initiative referenced |
| **Task/Action** | `wiki/todo.md` | Description, source link, added date, due date, owner, section (today/week/waiting/backlog) | Any "should do" / "need to" / "follow up" |
| **Decision** | `wiki/decisions.md` | What, rationale, date, who, status (open/closed) | "We decided" / "the decision is" / tradeoff resolved |
| **Priority/Theme** | `wiki/top-of-mind.md` | Focus area, recurring theme, open question | Topic appears 3+ times across sources |
| **Link/URL** | `wiki/bookmarks.md` | URL, description, category, why it matters | Any URL worth saving |
| **Channel** | `wiki/channels.md` | Name, IDs, purpose, key people | New channel/chat discovered |
| **Tool** | `wiki/tools.md` | Name, works/broken, parameters, limitations | New MCP tool used or discovered |
| **Concept** | `wiki/concepts.md` | Name, description, source, relevance | Framework, pattern, mental model worth remembering |
| **Relationship** | `wiki/people.md` (cross-ref) | Who relates to whom, how, context | "X reports to Y" / "X depends on Y's team" |
| *(new entity type)* | *(Thinker proposes)* | *(defined when created)* | Content doesn't fit any existing category |

**Growth mechanism for entity routing:**
1. Thinker encounters content that doesn't fit any existing entity type (e.g., a "vendor" or "competitor" or "metric")
2. Thinker includes in its response: "Found entity type not in routing table: [description]. Recommend creating `wiki/{name}.md`"
3. Manager asks user: "Should I create a page for tracking [entity type]?"
4. If yes → Actor creates the wiki page + adds the route to the schema
5. Future ingests automatically route this entity type to the new page

**Growth mechanism for entity metadata:**
- The "What to Capture" column also grows. When the Thinker notices a field it should have captured but didn't (e.g., someone's timezone, a project's budget), it recommends adding the field to the entity's metadata spec.
- User confirms → Actor updates the entity definition in the schema
- This is how wiki/people.md went from "name, role" to "name, alias, email, role, team, squad, VIP flag, comm style, what they care about, recent activity" over 7 days of actual use.

### How Indexing Works

**`index.md`** is the master catalog. The Actor updates it after every write. Format:

```markdown
## Raw Sources (29 entries)
### Documents
- [[raw/documents/2026-04-10-1m-scaling-plan|1M Scaling Plan]] — 20 milestones, DLIS GPU dependency, 4/24 integration target
- [[raw/documents/2026-04-08-pdi-wapi-vnext|PDI WAPI vNext]] — architecture spec for Profile Data Infrastructure

### Chats & Channels
- [[raw/channels/2026-04-07-ws-uu-weekly-digest|WS-UU Weekly Digest Apr 2-8]] — 40 msgs, 15 threads: GPU scaling, eval, interest merge
- [[raw/chats/2026-04-09-sent-ws-uu-week4-rag|Sent: Week 4 RAG to WS-UU]] — Amber status, both squads

### Emails
- [[raw/emails/2026-04-09-sent-uu-core-team-ado-status|Sent: ADO Status to Core Team]] — action banner, 6 recipients

## Wiki Pages (18 entries)
### Projects
- [[wiki/projects/mai-profile|MAI User Profile]] — P0 project: unified profile layer, C2 Week 4, Amber status

### Overviews & Analyses
- [[wiki/overviews/c2-exit-risk-analysis|C2 Exit Risk Analysis]] — 4 P0 blockers, 6 P1 risks, 14 must-do tasks

### Reviews
- [[wiki/reviews/weekly-2026-W15|Weekly Review W15]] — V3 Dev Amber, Signal Foundation stale, granularity framework

## Playbooks (6 entries)
- [[playbooks/ado-rag-workstream|ADO RAG Workstream]] — squad vs workstream templates, Week 1-3 patterns
```

**How the Thinker uses the index:** When answering a query, the Thinker reads index.md FIRST (P8). The one-line summaries let it identify which pages are relevant without reading every file. It then drills into 3-5 relevant pages to synthesize an answer.

### How Retrieval Works

When you ask "what did I discuss with Tao last week?" or "what's the status of the 1M scaling plan?":

```
Manager classifies: this is a Query
  → Spawns Thinker with: question + index.md content + identity context

Thinker:
  1. Reads index.md → identifies relevant entries by scanning summaries
     "Tao" → wiki/people.md, wiki/projects/mai-profile.md
     "1M scaling" → raw/documents/2026-04-10-1m-scaling-plan, wiki/projects/mai-profile.md
  
  2. Reads identified pages → gathers facts with citations
  
  3. Reads wiki/todo.md → any pending action items related to query?
  
  4. Synthesizes answer with [[wikilinks]] citing every fact:
     "The 1M Scaling Plan [source: [[raw/documents/2026-04-10-1m-scaling-plan|1M Scaling Plan]]]
      was added mid-Sprint 2. Tao raised GPU concerns [source: [[raw/channels/2026-04-07-ws-uu-weekly-digest|WS-UU Digest]]]..."
  
  5. Returns: answer + routing plan (if wiki pages need updating) + action items + file-back recommendation

Manager presents answer to user.
If Thinker recommends file-back → Manager asks user → Actor writes synthesis to wiki/overviews/
```

### The Daily Accumulation Loop

This is how the system compounds knowledge day over day:

```
Day 1 (Monday):
  Morning: "catch me up" → Retriever sweeps email/Teams/ADO
    → Thinker cross-references against wiki (who are these people? which project?)
    → Actor saves signals to raw/, updates todo, top-of-mind
  
  During day: "ingest this doc" → saves to raw/, updates 8 wiki pages
  During day: "post RAG to Teams" → Thinker drafts using playbook, Actor sends + saves to raw/
  
  End of day: wiki has 3 new raw sources, 12 wiki page updates, 5 new todos

Day 2 (Tuesday):
  Morning: "catch me up" → Retriever sweeps
    → Thinker NOW KNOWS about yesterday's ingest (it's in the wiki)
    → Cross-references today's signals against yesterday's context
    → "Vikas replied to the ADO comment you flagged yesterday"
    → Actor marks todo as done, updates people.md with Vikas's response
  
  This is P1 in action: knowledge compiled once, kept current, not re-derived.

Day 5 (Friday):
  "Write my weekly review" → Thinker reads this week's raw/sessions/* + wiki/todo.md
    → Drafts review using weekly-review playbook
    → Actor saves to wiki/reviews/weekly-YYYY-Www.md
  
  The review CITES all raw sources from the week. Nothing is fabricated.

Week 4:
  "What patterns do I see in the last month?" → Thinker reads 4 weekly reviews + project pages
    → Synthesizes monthly analysis
    → Filed back to wiki/overviews/ (P5)
  
  This is how the wiki COMPOUNDS — each layer builds on the previous.
```

### What Makes This Different from RAG

Traditional RAG: Upload files → chunk → embed → retrieve chunks → answer.
This system: Ingest → extract entities → route to wiki pages → cross-link → index → answer from compiled knowledge.

The key difference (Karpathy P1): **knowledge is compiled once and kept current**. When you ask about Vikas, you don't get chunks from 5 raw documents — you get wiki/people.md which already synthesizes everything known about Vikas, with citations back to every raw source. The compilation happened at ingest time, not at query time.

## Workflows (5-Specialist Model)

### Daily Brief ("catch me up", "morning brief", "start my day")
```
SKILL → Manager
  1. Load identity (session start) + read wiki/top-of-mind.md + wiki/todo.md
  2. Spawn Retriever (mode: sweep) → pull all signals per wiki/subscriptions.md, save to raw/, add to index
  3. Spawn Analyst → cross-reference signals against vault knowledge (who are these people? what projects?)
  4. Spawn Composer → draft brief using daily-brief playbook + Analyst's findings
  5. Present brief to user
  6. Spawn Actor(s) → update wiki/todo.md, wiki/top-of-mind.md, log, session ledger
  7. (Optional) Spawn Auditor → post-op verify: raw files indexed, log updated
```

### Ingest ("ingest this", "save this", "process this")
```
SKILL → Manager
  1. If source is external: Spawn Retriever (mode: targeted) → fetch + save to raw/ + index entry
     If source is pasted text: Manager passes directly to Analyst
  2. Spawn Analyst → analyze content, extract entities, produce routing plan + action items
  3. Present takeaways to user, await confirmation
  4. Spawn Actor(s) in parallel → wiki page updates (grouped by target page)
     Actor runs completion checklist as hard gate
  5. (Optional) Spawn Auditor → post-op verify: all routed pages written, index complete
```

### Query ("what do I know about X", "status of Y")
```
SKILL → Manager
  1. If external data needed: Spawn Retriever first
  2. Spawn Analyst → read index + pages + synthesize cited answer
     Analyst classifies: LOOKUP (simple fact) or SYNTHESIS (new insight)
  3. Present answer to user
  4. If SYNTHESIS + file-back recommended (P5): Ask user → Spawn Actor to write overview page
  5. If LOOKUP: No file-back prompt (don't ask for simple fact retrieval)
```

### Communication ("post to Teams", "send email", "write RAG", "draft message")
```
SKILL → Manager
  1. Classify intent. If ambiguous, ask user: "Do you want me to (a) draft a message, (b) post to a channel, (c) send an email?"
  2. Select playbook by intent + audience + format (using wiki/people.md for recipient context)
  3. If data needed: Spawn Retriever → fetch source data
  4. Spawn Analyst → extract key facts from source data
  5. Spawn Composer → draft using playbook + Analyst's facts + identity + recipient context
  6. Present draft to user, await confirmation/corrections
  7. If user corrects: Spawn Actor to update playbook, then re-run Composer
  8. Spawn Actor → save raw (outbound) + send externally + update log/session ledger
```

### Compose ("write a slide", "summarize this doc", "analyze this")
```
SKILL → Manager
  1. If source is external: Spawn Retriever
  2. Spawn Analyst → gather vault context + extract key facts
  3. Select playbook by intent + audience + format
  4. Spawn Composer → draft using playbook + Analyst's output
  5. Present to user, iterate (re-run Composer with corrections)
  6. If user wants to send: → Actor sends + saves raw
  7. If user wants to save to wiki: → Actor writes to wiki
```

### Lint ("health check", "lint")
```
SKILL → Manager
  1. Spawn Auditor → full scan:
     - Wiki health (stale, orphans, broken links, bidirectional)
     - Todo accountability (7+ day items)
     - First-principles audit (P4/P5/P8/P10)
     - Schema audit (entity type overlap, playbook gaps, stale inbound/outbound entries)
     - Subscription health, identity completeness
  2. Present lint report to user
  3. For auto-fixable items: Spawn Actor(s) to fix
```

### Feedback ("remember this", "from now on format it like X")
```
SKILL → Manager
  1. Classify what's being corrected:
     - Output style → playbook
     - Personal preference → wiki/identity.md
     - Person info → wiki/people.md
     - Tool behavior → wiki/tools.md
     - Subscription change → wiki/subscriptions.md
     - New entity type → wiki/{name}.md + schema update
  2. Spawn Actor to update the correct page (+ playbooks/_index.md if playbook changed)
  3. Confirm to user what was saved and where
```

### Key Workflow Properties

- **Analyst and Composer are always sequential** — Composer needs Analyst's output as input
- **Analyst does entity extraction (investigative), Composer does styled drafting (creative)** — different cognitive modes, different context loads
- **Manager asks when ambiguous** — one round-trip prevents pipeline misfire
- **Lookup vs Synthesis classification** — simple lookups skip the file-back prompt
- **Post-op verification is optional** — Manager can spawn Auditor after Actor for critical operations (ingest, daily brief) but skips for simple queries
- **All agents return structured error responses** — Manager handles partial results gracefully
- **Actor updates playbooks/_index.md** whenever it creates/modifies a playbook — no stale registry

## Storage: Single Folder

The entire system — agent code AND all data — lives in **one folder**. That folder can be:
- A **git repo** (version history, branching, clone to another machine)
- An **OneDrive / Google Drive folder** (cross-device sync)
- A **local folder** (simplest)
- An **Obsidian vault** (open in Obsidian for graph view, link navigation)

There is no separation between "agent system" and "data store." They are the same folder. When you clone, copy, or sync this folder, you get everything — the brain AND the operating system that runs it.

**No Obsidian dependency.** Obsidian MCP is an optional optimization (auto-detected at runtime). Default is filesystem tools (Read/Write/Edit/Grep/Glob).

### Folder Structure

**The schema file is named `CLAUDE.md`** (not SCHEMA.md) — Claude Code auto-reads files named CLAUDE.md in the current directory. This means the schema loads for free when Claude Code runs from this folder, without the skill needing to explicitly read it.

```
second-brain-agent/                # ← This IS your data store. Put it anywhere.
│
├── CLAUDE.md                      # Schema: wiki rules + conventions + agent routing
│                                  # (auto-loaded by Claude Code when run from this folder)
├── index.md                       # Wiki catalog (agents read first for queries)
├── log.md                         # Event log, append-only
│
├── agents/                        # Agent definitions (6 total)
│   ├── manager.md
│   ├── retriever.md
│   ├── analyst.md
│   ├── composer.md
│   ├── actor.md
│   └── auditor.md
│
├── skills/
│   └── SKILL.md                   # Entry point → spawns manager
│
├── .claude-plugin/
│   └── plugin.json
│
├── references/                    # Agent reference docs
│   ├── completion-checklist.md
│   └── tool-fallback-chains.md
│
├── scripts/
│   └── state-manager.sh
│
├── wiki/                          # LLM-maintained knowledge
│   ├── identity.md                # WHO I AM — loaded at session start, cached after
│   ├── people.md                  # People directory (VIP flags, comm styles)
│   ├── projects/                  # One .md per project
│   ├── subscriptions.md           # Watched channels, key chats, email filters
│   ├── tools.md                   # Tool Discovery Log + MCP reference
│   ├── todo.md                    # Living tasks, action items, follow-ups
│   ├── top-of-mind.md             # Current priorities, themes, open loops
│   ├── decisions.md               # Decision log
│   ├── concepts.md                # Ideas, frameworks, mental models
│   ├── channels.md                # Channel directory
│   ├── bookmarks.md               # Curated links
│   ├── reviews/                   # Weekly/monthly reviews
│   └── overviews/                 # Synthesized analyses
│
├── playbooks/                     # Output style guides (extensible — add anytime)
│   ├── _defaults.md               # General output format rules
│   ├── _index.md                  # Playbook registry (audience × format × channel)
│   ├── daily-brief.md
│   ├── ado-rag-workstream.md
│   ├── teams-channel-post.md
│   ├── chat-message-polish.md
│   ├── email-status-brief.md
│   ├── weekly-review.md
│   └── (more added by user at any time)
│
├── raw/                           # Immutable sources
│   ├── articles/  documents/  meetings/  chats/  channels/  emails/
│   ├── assets/
│   └── sessions/                  # Session ledgers + state.json
│
├── .gitignore
└── README.md
```

## Bootstrap: Day-1 Experience

A new user clones/creates the folder and gets an empty wiki. The system must handle this gracefully.

### First-Run Detection

The Manager checks if `wiki/identity.md` exists. If not → **bootstrap mode**.

### Bootstrap Flow

```
User: /second-brain (first time)
  Manager detects: wiki/identity.md missing → bootstrap mode
  
  1. "Welcome! I'm your AI chief of staff. Let me set up your brain."
  2. Interview: "What's your name, role, team, and org?"
     → Actor creates wiki/identity.md
  3. "Who are your key stakeholders? (name, role, email)"
     → Actor creates wiki/people.md with VIP section
  4. "What Teams channels and chats should I monitor daily?"
     → Actor creates wiki/subscriptions.md
  5. "What are your top 3 priorities this week?"
     → Actor creates wiki/top-of-mind.md + wiki/todo.md
  6. "Setup complete. Try: 'catch me up' for your daily brief, 
     or 'ingest [paste content]' to save something."
```

### Progressive Capability

The system works with ANY level of setup:

| What's populated | What works |
|-----------------|-----------|
| Nothing (fresh clone) | Bootstrap interview triggers |
| identity.md only | Query, ingest, compose (no daily brief — no subscriptions) |
| + subscriptions.md | Daily brief, channel digests |
| + people.md | Recipient-aware message drafting |
| + playbooks/ | Styled output matching user's preferences |
| + raw/ + wiki/ (mature) | Full chief of staff with persistent knowledge |

**Nothing breaks on empty state.** Each agent checks what data exists and degrades gracefully. The Retriever skips sources without subscriptions. The Thinker drafts without a playbook if none match. The Actor creates pages that don't exist yet.

## Agent Prompt Contracts

Each specialist agent receives a structured prompt from the Manager. These contracts define the **exact interface** — what the Manager sends and what the agent returns. This is the most critical implementation detail: if the contracts are wrong, the agents can't interoperate.

### Contract Format

Every agent prompt from the Manager follows this structure:

```
## Identity Context
[Excerpt from wiki/identity.md — name, role, team, focus areas]

## Task
[What to do — operation-specific]

## Inputs
[Data the agent needs — file paths, content, parameters]

## Schema Context
[Relevant sections from CLAUDE.md — only what this agent needs]

## Constraints
[Rules this agent must follow — read-only, raw-first, etc.]

## Expected Output Format
[Exact JSON/markdown structure the agent must return]
```

### Manager → Retriever Contract

```yaml
# Prompt structure
identity: "[name, role — 2 lines from wiki/identity.md]"
task: "Retrieve [mode: sweep|targeted]"
inputs:
  mode: "sweep"  # or "targeted"
  # If sweep:
  subscriptions_path: "wiki/subscriptions.md"
  time_range: "last 24 hours"  # or "last 7 days", etc.
  # If targeted:
  source_type: "sharepoint-doc"  # or "ado-work-item", "teams-channel", etc.
  source_ref: "https://..." # or work item ID, channel ID, etc.
schema_context:
  - "Tool Discovery Log sections relevant to requested tools"
  - "Raw-First rule (save to raw/ before anything)"
  - "Raw file naming conventions"
constraints:
  - "Save every retrieved item to raw/ with proper frontmatter"
  - "Add index.md entry for each raw file created"
  - "Return structured response, not prose"
  - "If a tool fails, record failure in response AND in wiki/tools.md"

# Expected response
response_format:
  status: "success | partial | failed"
  raw_files_created:
    - path: "raw/documents/2026-04-13-example.md"
      title: "Example Doc"
      summary: "One-line summary for index"
  content:
    # Structured representation of retrieved data
    entities_detected: ["person: Vikas", "project: MAI Profile", ...]
    key_facts: ["...", "..."]
    action_items: ["...", "..."]
  failed_sources:
    - source: "WorkIQ-Mail"
      error: "401 Unauthorized"
      recoverable: true
```

### Manager → Analyst Contract

```yaml
# Prompt structure
identity: "[name, role, focus areas — 5 lines from wiki/identity.md]"
task: "Analyze [content_type: ingest|query|cross-reference]"
inputs:
  # If ingest analysis:
  content: "[raw content OR path to raw file just created by Retriever]"
  # If query:
  question: "[user's question]"
  index_content: "[full content of index.md]"
  # If cross-reference (daily brief):
  signals: "[structured output from Retriever]"
  index_content: "[full content of index.md]"
schema_context:
  - "Entity routing table (full)"
  - "First principles P4 (touch many pages), P5 (file-back), P8 (index-first)"
  - "Cross-linking and citation format"
constraints:
  - "Read-only — never write to any file"
  - "Use [[wikilinks]] for all citations"
  - "Classify queries as LOOKUP or SYNTHESIS"
  - "Return structured routing plan, not prose instructions"

# Expected response
response_format:
  # For ingest:
  routing_plan:
    - target: "wiki/people.md"
      action: "append"
      content: "## Vikas Sabharwal\n- Role: ..."
      citations: ["[[raw/documents/2026-04-13-example|Example Doc]]"]
    - target: "wiki/todo.md"
      action: "append"
      section: "Do This Week"
      content: "- [ ] Follow up with Vikas..."
  action_items:
    - description: "Follow up with Vikas on ADO comment"
      source: "raw/documents/2026-04-13-example.md"
      priority: "today"
  key_takeaways:
    - "Vikas confirmed GPU allocation is on track"
    - "New blocker: Copilot dataset incident"
  file_back_recommendation: null  # or { topic: "...", rationale: "..." }
  
  # For query:
  answer: "[cited markdown answer]"
  query_type: "lookup | synthesis"
  pages_read: ["wiki/people.md", "wiki/projects/mai-profile.md"]
  file_back_recommendation:
    topic: "GPU Scaling Status Analysis"
    rationale: "This synthesis connects 3 sources — worth preserving"
    suggested_path: "wiki/overviews/gpu-scaling-status.md"
  action_items: [...]
```

### Manager → Composer Contract

```yaml
# Prompt structure
identity: "[full communication preferences section from wiki/identity.md]"
task: "Draft [output_type] for [audience]"
inputs:
  playbook_path: "playbooks/ado-rag-workstream.md"  # Composer reads this file
  data: "[structured facts from Analyst — key_takeaways, routing_plan, etc.]"
  recipient:  # from wiki/people.md if applicable
    name: "Tao Di"
    role: "Tech Lead"
    comm_style: "Direct, technical"
  additional_context: "[any user instructions, e.g., 'emphasize the GPU risk']"
schema_context:
  - "Output format rules from playbooks/_defaults.md (if no specific playbook)"
constraints:
  - "Read-only — return draft content only, never write"
  - "MUST read playbook file before drafting"
  - "Match the playbook's structure, tone, and format exactly"
  - "If playbook has Anti-Patterns section, actively avoid those patterns"

# Expected response
response_format:
  draft: "[the actual output content — markdown, HTML, or whatever format the playbook specifies]"
  format: "html | markdown | slide"
  playbook_used: "playbooks/ado-rag-workstream.md"
  playbook_missing: false  # true if no matching playbook was found
  suggested_playbook_name: null  # if playbook_missing, suggest a name for the new playbook
```

### Manager → Actor Contract

```yaml
# Prompt structure
identity: "[name — 1 line]"
task: "Execute mutation plan"
inputs:
  mutations:
    - type: "write"
      target: "wiki/people.md"
      action: "append"
      content: "[exact content to write, from Analyst's routing_plan]"
      citations: ["[[raw/documents/...]]"]
    - type: "write"
      target: "wiki/todo.md"
      action: "append"
      section: "Do This Week"
      content: "[task content]"
    - type: "send"
      channel: "teams-channel"
      target_id: "19:4ae170cb..."
      content: "[draft content from Composer]"
      save_raw_as: "raw/chats/2026-04-13-sent-ws-uu-example.md"
    - type: "update-index"
      entries:
        - path: "wiki/people.md"
          summary: "People directory — 42 people, VIP flags"
    - type: "update-playbook-registry"
      playbook: "playbooks/new-playbook.md"
  session_ledger_entry:
    operation: "ingest"
    tools_used: ["WorkIQ-Word MCP"]
    raw_sources: ["raw/documents/2026-04-13-example.md"]
    wiki_pages: ["wiki/people.md", "wiki/todo.md"]
    outcome: "Ingested example doc, 2 wiki pages updated"
schema_context:
  - "Raw-First rule (save outbound to raw/ BEFORE sending)"
  - "Completion checklist"
  - "Tool Discovery Log sections for outbound tools"
constraints:
  - "Execute mutations in order: raw/ first, then wiki/, then external sends"
  - "Serialize writes to the same target page"
  - "Run completion checklist before returning"
  - "If any mutation fails, continue with remaining and report partial status"

# Expected response
response_format:
  status: "success | partial | failed"
  pages_written: ["wiki/people.md", "wiki/todo.md"]
  pages_failed: []
  sends_completed:
    - channel: "teams-channel"
      message_id: "1775789700377"
  sends_failed: []
  index_updated: true
  playbook_registry_updated: false
  checklist:
    raw_saved: true
    session_ledger: true
    wiki_updated: true
    index_updated: true
    log_appended: true
```

### Manager → Auditor Contract

```yaml
# Prompt structure
identity: "[name — 1 line]"
task: "Audit [mode: full-lint | post-op-verify | schema-audit]"
inputs:
  # If post-op-verify:
  actor_response: "[the Actor's structured response to verify against]"
  expected_mutations: "[the mutation plan that was sent to Actor]"
  # If full-lint:
  vault_root: "[path to project folder]"
  # If schema-audit:
  schema_path: "CLAUDE.md"
schema_context:
  - "First principles (all 10, for full-lint)"
  - "Completion checklist (for post-op-verify)"
  - "Entity routing table (for schema-audit)"
constraints:
  - "Read-only — never write to any file"
  - "Return structured report, not prose"

# Expected response (full-lint)
response_format:
  wiki_health:
    stale_pages: [{ page: "...", last_updated: "...", days_stale: 45 }]
    orphan_pages: ["wiki/concepts.md"]
    broken_links: [{ from: "...", to: "...", link: "[[missing]]" }]
    bidirectional_gaps: [{ a: "...", b: "...", direction: "a→b only" }]
  todo_accountability:
    overdue: [{ task: "...", added: "...", days_open: 14 }]
    completed: [{ task: "...", evidence: "..." }]
  first_principles:
    violations: [{ principle: "P4", page: "...", description: "..." }]
  schema_audit:
    overlapping_entities: [{ a: "vendor", b: "partner", overlap: "80%" }]
    entity_count: 12
    playbook_gaps: ["no playbook for 'meeting-notes' output type"]
    stale_tools: [{ tool: "WeChat MCP", last_tested: "never" }]
  auto_fixable: ["broken_links", "bidirectional_gaps", "index_entries"]
  manual_review: ["overlapping_entities", "stale_pages"]

# Expected response (post-op-verify)
response_format:
  verified: true | false
  checks:
    - check: "raw file exists"
      path: "raw/documents/2026-04-13-example.md"
      result: "pass"
    - check: "index entry exists"
      path: "index.md"
      search: "2026-04-13-example"
      result: "fail — not found in index"
    - check: "log entry exists"
      path: "log.md"
      result: "pass"
  failures: ["index entry missing for raw/documents/2026-04-13-example.md"]
```

## CLAUDE.md Schema Design

The project's `CLAUDE.md` serves dual purposes:
1. **Auto-loaded by Claude Code** when running from this folder — acts as the project's instruction file
2. **The wiki schema** — defines all conventions, routing, and enforcement rules

### What Goes In CLAUDE.md

```markdown
# [User's Name]'s Second Brain

## What This Is
Personal AI Chief of Staff — a persistent knowledge base with multi-agent architecture.
Built on the LLM Wiki pattern by Andrej Karpathy.

## Quick Start
- `catch me up` / `daily brief` → morning signal sweep
- `ingest [paste/link]` → save and process a source
- `query [question]` → search your knowledge base
- `draft [message/email/RAG]` → compose styled output
- `lint` → health check
- `remember [preference/correction]` → update your brain

## How It Works
This folder is both the agent system and your data store.
- `wiki/identity.md` — who you are (loaded every session)
- `wiki/` — your knowledge base (LLM-maintained)
- `playbooks/` — your output styles (self-learning)
- `raw/` — immutable source documents
- `agents/` — the specialist agents that run the system

## Agent Architecture
Manager (this file routes to the right pipeline)
  ├── Retriever — fetches data from external tools + files
  ├── Analyst — extracts entities, synthesizes answers
  ├── Composer — drafts styled output using playbooks
  ├── Actor — writes vault, sends externally, runs checklist
  └── Auditor — health checks, verification, schema audit

## Operation Routing
[How the Manager classifies intent and selects the pipeline]

| User Says | Operation | Pipeline |
|-----------|-----------|----------|
| "catch me up", "daily brief" | Daily Brief | Retriever(sweep) → Analyst → Composer → Actor |
| "ingest", "save", "process" | Ingest | Retriever(targeted) → Analyst → Actor(s) |
| "what do I know about", "status of" | Query | Analyst → (Actor if file-back) |
| "post to", "send", "draft", "write RAG" | Communication | Retriever → Analyst → Composer → Actor |
| "write a slide", "summarize", "analyze" | Compose | Retriever → Analyst → Composer → iterate |
| "lint", "health check" | Lint | Auditor → Actor(fixes) |
| "remember", "from now on" | Feedback | Actor(update page) |

## Entity Routing Table
[Living table — grows as new entity types are discovered]

| Entity | Home Page | What to Capture |
|--------|-----------|----------------|
| Person | wiki/people.md | name, alias, email, role, team, VIP, comm style, recent activity |
| Project | wiki/projects/{name}.md | status, IDs, milestones, blockers, architecture |
| Task | wiki/todo.md | description, source, added, due, owner, section |
| Decision | wiki/decisions.md | what, rationale, date, who, status |
| Priority | wiki/top-of-mind.md | focus area, theme, open question |
| Link | wiki/bookmarks.md | URL, description, category |
| Channel | wiki/channels.md | name, IDs, purpose, people |
| Tool | wiki/tools.md | name, status, parameters, limitations |
| Concept | wiki/concepts.md | name, description, source |
| Relationship | wiki/people.md | who→who, how, context |

## Enforcement Rules

### Rule 1: Raw-First
Every external interaction saves to raw/ BEFORE any other action.
- Inbound: retrieve → save raw → update wiki
- Outbound: compose → save raw → send

### Rule 2: Session Ledger
Every session maintains raw/sessions/YYYY-MM-DD-session.md

### Rule 3: Completion Checklist
Before returning results:
- [ ] Raw source saved
- [ ] Session ledger updated  
- [ ] Wiki pages updated with citations
- [ ] index.md updated
- [ ] log.md appended

### Rule 4: Tool Discovery
Record tool successes/failures in wiki/tools.md

## First Principles (Karpathy)
P1: Wiki is persistent, compounding | P2: Raw sources immutable
P3: LLM owns the wiki | P4: Single source touches many pages
P5: Good answers filed back | P6: Schema is discipline
P7: Maintenance cost → zero | P8: Index-first navigation
P9: Lint keeps wiki healthy | P10: Connections = content
```

### What Does NOT Go In CLAUDE.md

| Content | Where It Lives Instead |
|---------|----------------------|
| User identity (name, role, team) | `wiki/identity.md` |
| Communication preferences | `wiki/identity.md` |
| Key stakeholders | `wiki/people.md` |
| Output format rules | `playbooks/_defaults.md` |
| Tool configuration | `wiki/tools.md` |
| Subscriptions | `wiki/subscriptions.md` |

**CLAUDE.md is the schema. The data is in wiki/.**

## Collaboration: GitHub Repository

This plan is a living design document. Move to GitHub so multiple contributors can refine it via PRs.

### Repository Setup
- **Repo:** `agentictaskx/second-brain-agent` (or preferred org)
- **Branch strategy:** `main` for stable design, feature branches for proposals
- **Contributing:** Design changes via PR with rationale

### What Goes in the Repo
- This plan → `docs/DESIGN.md`
- Agent definitions → `agents/*.md`
- Schema → `CLAUDE.md`
- Starter playbooks → `playbooks/*.md` (generic templates)
- Wiki structure → `wiki/` (empty folders + README per folder explaining purpose)

### What Does NOT Go in the Repo (User-Specific, gitignored)
- `wiki/identity.md`, `wiki/people.md`, `wiki/subscriptions.md` (personal data)
- `raw/` (personal source documents)
- `raw/sessions/` (session ledgers)

The repo ships with template examples (e.g., `wiki/identity.example.md`) that users copy and fill in.

### Phase 1: Scaffold
- [ ] Create folder structure (agents/, skills/, wiki/, playbooks/, raw/, references/, scripts/)
- [ ] Create `.claude-plugin/plugin.json`
- [ ] Create `CLAUDE.md` (schema — storage-agnostic, agent routing table, entity routing table, enforcement rules)
- [ ] Create `index.md`, `log.md` (seed from existing vault or empty)
- [ ] Create `scripts/state-manager.sh`
- [ ] Create `references/completion-checklist.md`, `references/tool-fallback-chains.md`
- [ ] Create `.gitignore`

### Phase 2: Agents + Skill
- [ ] Create `skills/SKILL.md` (thin dispatcher — 7 operation types)
- [ ] Create `agents/manager.md` (orchestrator — intent classification, ambiguity handling, playbook selection, identity loading)
- [ ] Create `agents/retriever.md` (all inbound data — sweep or targeted, with fallback chains, structured error responses)
- [ ] Create `agents/analyst.md` (entity extraction, query synthesis, routing plans, lookup vs synthesis classification)
- [ ] Create `agents/composer.md` (styled drafting via playbooks + identity + recipient context)
- [ ] Create `agents/actor.md` (all mutations — vault writes, external sends, index/log, playbook registry, completion checklist, structured error responses)
- [ ] Create `agents/auditor.md` (lint, post-op verification, schema audit, first-principles audit)

### Phase 3: Data Seeding
- [ ] Create `wiki/identity.md` (merge from CLAUDE.md + mai-cos/context/me.md)
- [ ] Create `wiki/people.md` (merge from vault + mai-cos/context/people.md, add VIP flags + comm styles)
- [ ] Create `wiki/subscriptions.md` (from mai-cos/context/subscriptions.md)
- [ ] Create `wiki/tools.md` (from vault + mai-cos/config/mcp-tool-reference.md)
- [ ] Create `wiki/todo.md`, `wiki/top-of-mind.md`, `wiki/decisions.md`, etc.
- [ ] Create `playbooks/_defaults.md`, `playbooks/_index.md`
- [ ] Create starter playbooks (daily-brief, ado-rag-workstream, teams-channel-post, chat-message-polish, email-status-brief, weekly-review)

### Phase 4: CLAUDE.md Thinning
- [ ] Remove personal data from global ~/.claude CLAUDE.md (identity, preferences, stakeholders)
- [ ] Ensure project CLAUDE.md is storage-agnostic (no Obsidian-specific rules)
- [ ] Add agent routing table + bootstrap detection + schema growth rules to project CLAUDE.md

### Phase 5: Install + Test
- [ ] Install plugin (symlink or settings.json)
- [ ] Initialize git repo
- [ ] Test bootstrap flow (empty wiki → interview → identity created)
- [ ] Test all 7 operations: daily brief, ingest, query, communicate, compose, lint, feedback
- [ ] Test playbook learning: correct output → verify playbook updated → verify next draft uses updated style
- [ ] Test error handling: simulate MCP failure → verify Manager presents partial results + retry offer
- [ ] Test post-op verification: ingest → Auditor verifies raw indexed, pages written, log updated
- [ ] Test schema audit: add overlapping entity type → lint catches overlap → suggest merge

## Verification

- [ ] 6 agent .md files have valid frontmatter (manager + retriever + analyst + composer + actor + auditor)
- [ ] SKILL.md handles all 7 operation types
- [ ] Bootstrap: empty wiki/ → first invocation interviews user → creates identity.md
- [ ] Degradation: missing subscriptions.md → daily brief skips signal gathering with note
- [ ] Ambiguity: "check on Kunyang" → Manager asks user to clarify intent
- [ ] Daily brief: manager → retriever (sweep) → analyst (cross-ref) → composer (draft) → actor (write) → auditor (verify)
- [ ] Ingest: manager → retriever (targeted) → analyst (entities) → actor(s) in parallel (grouped by page)
- [ ] Query lookup: manager → analyst → answer (no file-back prompt)
- [ ] Query synthesis: manager → analyst → answer + file-back prompt → actor (if accepted)
- [ ] Communicate: manager → retriever → analyst → composer (with playbook) → actor (save raw + send)
- [ ] Lint: manager → auditor (wiki + schema + post-op) → actor (fixes)
- [ ] Feedback: user corrects → actor updates playbook + _index.md → next composer draft matches
- [ ] Write conflict: 3 people to wiki/people.md → all go to same Actor instance (serialized)
- [ ] Identity caching: first invocation reads, subsequent use cached version
- [ ] Error recovery: MCP fails → Retriever returns status: partial → Manager shows what worked + offers retry
- [ ] Schema drift: 15 entity types → Auditor flags for review during lint
- [ ] Post-op verify: Actor writes but misses index → Auditor catches orphaned raw file
