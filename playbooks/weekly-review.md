---
title: Weekly Review
type: playbook
audience: self
format: markdown
channel: vault
examples:
  - "weekly review"
  - "weekly summary"
  - "what happened this week"
  - "week in review"
---

# Weekly Review

## When to Use

End of week (or mid-week for short weeks). Generates a personal review of the week's activity — what changed, what was accomplished, what's blocked, what actions were taken. This is a personal knowledge artifact stored in the vault, not shared externally.

## Structure

Fixed section order:

1. **Summary** — 2-4 sentences: cycle context, key status changes, top events
2. **Workstream Status** — table of tracked ADO items with current RAG, last changed date, and owner
3. **Key Changes This Week** — numbered list of material changes with dates and sources
4. **Key Accomplishments** — numbered list of completed deliverables and milestones
5. **Blockers** — bullet list of items stuck 3+ weeks, with duration and owner status
6. **Actions Taken** — bullet list of things you did (sent, checked, verified, ingested) with source links
7. **Active Decisions** — bullet list of open decisions under discussion with participants
8. **Sources** — wikilink list of all raw documents and chats referenced

## Template

```markdown
---
date: '[YYYY-MM-DD]'
last_updated: '[YYYY-MM-DD]'
source_count: [N]
tags:
  - review
  - weekly
  - c[cycle]
  - week-[N]
title: Weekly Review — [YYYY] W[week number]
type: wiki
---

# Weekly Review — [YYYY] Week [N] ([Date Range])

## Summary

[2-4 sentences. State: cycle week, top status change, key event, one forward-looking note. Be factual — this is a log, not a narrative.]

## Workstream Status

| Item | ID | Status | Last Changed | By |
|------|------|--------|-------------|-----|
| [Workstream name] | [ADO ID] | [emoji + color] | [date] | [person] |
| [Mission/Squad name] | [ADO ID] | [emoji + color] | [date] | [person] |

## Key Changes This Week ([Date Range])

1. **[Change]** — [detail] ([date])
2. **[Change]** — [detail] ([date])
3. ...

## Key Accomplishments ([source period])

1. **[Accomplishment]** — [metric or deliverable]
2. **[Accomplishment]** — [metric or deliverable]
3. ...

## Blockers (unchanged 3+ weeks)

- [Blocker description] — [owner or status] (**[N] days**)
- ...

## Actions Taken

- [Action verb] [what] [source: [[wikilink]]]
- ...

## Active Decisions

- [Decision topic] — [participants] [source: [[wikilink]]]
- ...

## Sources

- [[raw/documents/YYYY-MM-DD-slug|Display Name]]
- [[raw/chats/YYYY-MM-DD-slug|Display Name]]
- [[wiki/page|Display Name]]
```

## Formatting Rules

- **YAML frontmatter is required.** Include date, tags, source_count, type.
- **Tags:** Always include `review`, `weekly`, cycle tag (e.g., `c2`), and week tag (e.g., `week-15`).
- **Status emoji:** Use `green-circle`, `yellow-circle`, `red-circle` emoji before color word.
- **Source links:** Every claim in Key Changes and Actions Taken must have a `[[wikilink]]` source.
- **Blocker duration:** Parenthetical bold `(**N days**)` showing how long the blocker has persisted.
- **Stale RAG note:** If a squad's RAG is older than current week, note it: `(stale — Week N RAG)`.
- **ID column:** Include ADO work item IDs for quick lookup.

## Content Rules

- **Summary is a log entry, not a narrative.** State facts: "C2 Week 4. V3 Dev moved Green to Amber. Signal Foundation still missing Week 4 RAG."
- **Key Changes = what changed state.** Not what you worked on — what actually shifted (status changes, new items created, decisions made).
- **Key Accomplishments = deliverables.** Things that shipped, completed, or reached a milestone. Pull from RAG updates.
- **Blockers = items stuck.** Only list items unchanged for 3+ weeks. Include owner and duration.
- **Actions Taken = your actions.** What you sent, checked, verified, escalated. Each with source.
- **Active Decisions = open questions.** Not resolved decisions — those go in Key Changes.

## Examples

### Good Summary
> C2 Week 4. V3 Dev squad moved **Green to Amber** (Deb posted Week 4 RAG on Apr 8). Signal Foundation **still missing Week 4 RAG** (Kunyang as of Apr 9). Status email sent to core team Apr 9. Granularity evaluation framework formalized by Deb.

### Bad Summary
> This was a productive week with lots of progress. Both squads are doing well and we're on track for our goals. I had some good conversations and made progress on several fronts.

### Good Action
> - Sent ADO status summary to MAI Profile WS/Squad Leads chat [source: [[raw/chats/2026-04-08-sent-ws-squad-leads-ado-status]]]

### Bad Action
> - Worked on status updates

## Anti-Patterns

- **Don't editorialize.** This is a log. "V3 Dev moved Green to Amber" not "Unfortunately, V3 Dev had a setback."
- **Don't list tasks you worked on.** List outcomes and state changes. "Worked on X" is not a change.
- **Don't skip sources.** Every claim needs a wikilink. If there's no source, the claim shouldn't be in the review.
- **Don't include resolved blockers.** If it's no longer stuck, it goes in Key Changes ("resolved") or Accomplishments.
- **Don't forget frontmatter.** The vault relies on YAML metadata for queries and graphs.
- **Don't combine review with planning.** This reviews the past week. Next week's priorities belong in the RAG or daily brief.
