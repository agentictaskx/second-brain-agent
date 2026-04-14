---
title: ADO RAG Workstream Update
type: playbook
audience: team
format: html
channel: ado
examples:
  - "weekly RAG"
  - "mission update"
  - "workstream rollup"
  - "DRI summary"
  - "combine squad updates"
  - "write my weekly update"
---

# ADO RAG Workstream Update

## When to Use

Weekly. Synthesizes multiple squad-level RAG updates into a single workstream-level rollup. Written from the DRI's perspective for LT review. Pushed to ADO Sprint fields as HTML.

This is the most structured playbook — follow the template exactly.

## Structure

Fixed section order:

1. **Header** — workstream name, cycle, week number
2. **Overall Status** — single RAG color
3. **Squad Status Table** — squad name + RAG per squad
4. **TL;DR** — 2 sentences max
5. **Summary** — 2-4 sentence synthesis paragraph
6. **Highlights** — bulleted list with squad attribution
7. **Lowlights** — bulleted list with POC, ETA, LT tags
8. **Next Week Focus** — table with owner and ETA per priority
9. **Week-over-Week Changes** — table comparing last week to this week
10. **Callouts** — optional thanks/recognition

## The 10 Writing Rules

1. **Lead with the TL;DR.** Execs may read only that line. It must stand alone.
2. **Outcomes over activities.** "Completed Scope-to-Spark tool with 100% data parity" not "Worked on Scope-to-Spark migration."
3. **Quantify everything.** "100 users" not "more users"; "12h to 2h" not "faster"; "60 A100 GPUs at >80% utilization" not "deployed GPUs."
4. **Make asks explicit.** State **who** you need **what** from by **when**. "Need security review from @alice by Wed or release slips 1 week."
5. **Connect to mission.** At least 1-2 highlights should ladder to the cycle OKR/mission.
6. **Honest risk reporting.** Don't minimize. If blocked, say blocked. Tag **[LT needed]** when escalation required.
7. **Workstream perspective.** Synthesize across squads — don't concatenate squad updates. Find cross-cutting themes.
8. **No fluff.** Every sentence informs a decision or signals a status change. Cut "continued to make progress on X" unless there's a measurable delta.
9. **Attribution.** Parenthetical squad names on squad-specific bullets: `(V3 Dev)`, `(Signal Foundation)`.
10. **Acknowledge silence.** If a previously reported item has no update, say so: "No change from last week." Don't silently omit it.

## Template

```markdown
[Workstream Name] – C[cycle] Week [N] RAG

Overall Status: [Green/Yellow/Red]

| Squad | Status |
|-------|--------|
| [Squad 1] | [Green/Yellow/Red] |
| [Squad 2] | [Green/Yellow/Red] |

TL;DR
[Sentence 1: what shipped or moved the needle. Sentence 2: top risk or ask.]

Summary
[2-4 sentences. Frame around outcomes and momentum. Connect milestones to cycle OKR. State aggregate risk posture.]

Week [N] Highlights
- **[Bold label]** — description with metrics (Squad)
- **[Bold label]** — description (Squad)
- ...

Week [N] Lowlights
- **[Bold label]** — description. POC: [Name], ETA: [date/TBD] (Squad)
  - Sub-bullet for grouped external deps
- **[Bold label]** — description. **[LT needed]** (Squad)
- ...

Next Week Focus
| # | Priority | Owner | ETA |
|---|----------|-------|-----|
| 1 | [priority] | [name] | [date] |
| 2 | ... | ... | ... |

Week-over-Week Changes
| Area | Last Week | This Week | Squad |
|------|-----------|-----------|-------|
| [area] | [previous] | [current] | [squad] |

Callouts
- Thanks to [person/team] for [specific contribution]
```

## Squad vs. Workstream Differences

| Element | Squad Level | Workstream Level |
|---------|-------------|------------------|
| TL;DR | Not present | Required — 2 sentences |
| Lists | Numbered | Bulleted |
| Tables | None | 3 tables (squad status, next week, WoW) |
| Attribution | Not needed (single squad) | Every bullet has `(Squad name)` |
| Cross-squad items | N/A | Yes — e.g., "Both squads absorbing scope change" |
| Synthesis | Report what happened | Explain *why it matters* for the workstream |
| LT asks | Implicit | Explicit `[LT needed]` tags |
| Owner/ETA tracking | Inline mentions | Structured in tables |
| Week-over-week | Not present | Comparison table |
| Credits | Not present | Callouts section |

## HTML Output Rules

When pushing to ADO, convert the markdown to ADO-compatible HTML:

- **Tables:** `border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse;"`
- **RAG colors inline:** Green = `color:rgb(12, 136, 42)`, Yellow = `color:rgb(204, 163, 0)`, Red = `color:rgb(204, 41, 0)`
- **Special chars:** Use HTML entities (`&mdash;`, `&amp;`, `&gt;`, `&ldquo;`, `&rdquo;`)
- **Next Week Focus:** Render as a table with columns: #, Priority, Owner, ETA
- **Bold:** `<b>` or `<strong>`
- **Lists:** `<ul><li>` for bullets, `<ol><li>` for numbered
- **Headers:** `<h2>` for section titles, `<h3>` for sub-sections

## ADO Field Usage

- **Sprint 1 field:** Weeks 1-2 updates (newest on top, prepended)
- **Sprint 2 field:** Weeks 3-4+ updates
- Each week's update is prepended above previous content in the same field
- Format: HTML (rich text with `<h2>`, `<ul>`, `<li>`, `<b>` tags)

## Synthesis Approach

The workstream rollup is NOT a copy-paste of squad updates. It must:

1. **Reframe** squad achievements in terms of workstream goals
2. **Connect** milestones across squads (e.g., "Signal Foundation completed denoising -> V3 Dev can now scale to 100 users")
3. **Elevate** blockers that require LT attention with explicit tags
4. **Track progression** via the week-over-week table — show movement, not snapshots
5. **Assign owners and ETAs** to every open item in Next Week Focus

## Examples

### Good TL;DR
> Denoising runtime hit 5M users in <2h (down from 12h/day) and MT/Spark capacity validated for 1M users (42TB, 100 MT tokens). Top risk: DoCA convergence path unresolved — need Vikas response on UMS mapping by Apr 15 or C3 onboarding planning slips.

### Bad TL;DR
> Good progress across both squads this week. Some risks to monitor.

### Good Highlight
> - **Denoising runtime milestone** — 5M users / 170M activities processed in <2h, down from 12h/day continuous pipeline (Signal Foundation)

### Bad Highlight
> - Continued work on denoising improvements (Signal Foundation)

### Good Lowlight
> - **DoCA convergence path** — UMS mapping + user activity access still unresolved. POC: Vikas Sabharwal, ETA: TBD. Vikas's ADO comment (Mar 27) unanswered for 13 days. **[LT needed]** (Cross-squad)

### Bad Lowlight
> - DoCA integration still in progress

## Anti-Patterns

- **Don't concatenate squad updates.** Synthesize across squads to find themes.
- **Don't minimize risks.** If it's blocked, say "blocked" — not "slightly delayed."
- **Don't skip week-over-week.** Even if nothing changed, say "No change from last week" for tracked items.
- **Don't use vague metrics.** "More users" and "faster" are never acceptable.
- **Don't omit squad attribution.** Every bullet must end with `(Squad name)` or `(Cross-squad)`.
- **Don't forget the TL;DR.** An exec who reads only 2 sentences must know the state of the workstream.
- **Don't use numbered lists.** Workstream level uses bullets. Squads use numbers.
