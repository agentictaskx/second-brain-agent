---
title: Daily Brief
type: playbook
audience: self
format: markdown
channel: vault
examples:
  - "catch me up"
  - "morning brief"
  - "what did I miss"
  - "start my day"
  - "run my daily brief"
---

# Daily Brief

## When to Use

Morning routine. Generates a prioritized summary of overnight activity across email, calendar, Teams chats, Slack, and channel posts. The user starts their day with this.

## Structure

Fixed section order — never rearrange:

1. **TL;DR** — 3-5 bullet executive summary (the only section some mornings)
2. **To-Do List** — consolidated action items from all sources + carry-forward
3. **Email** — inbox items tiered by sender priority
4. **Messages** — Teams chats + Slack, tiered by urgency
5. **Channel Posts** — watched channel activity
6. **Meetings** — today's calendar, tomorrow, rest of week
7. **Appendix** — data issues, source summary

## Priority Framework

All items ranked using this universal stack:

**Audience Priority:**
1. Direct to me (sent to me only, @mentioned, 1-1, assigned)
2. To a group including me (TO/CC, group chat, followed channel)

**Recency:** Most recent first within each audience tier.

**Sender Priority:**
1. VIP stakeholders (from identity context)
2. Key collaborators (from subscriptions)
3. Others

**Time Horizon:** Today first, tomorrow second, this week third.

## Template

```markdown
# Daily Brief — [Day, Month Date, Year]

> Generated at [time, timezone]. Sources: [list sources checked].

---

## TL;DR

- [Most urgent action item or deadline]
- [Second most important — VIP message, critical email, key meeting]
- [Third — notable decision, blocker, emerging issue]
- [Fourth (optional)]
- [Fifth (optional)]

---

## Today's To-Do List

### Must Do Today
1. [item — derived from red items + meeting prep + carry-forward]
2. ...

### Should Do This Week
1. [item — derived from yellow items + current priorities]
2. ...

### Open Loops (carry-forward)
- [unresolved item from previous sessions]
- ...

---

## Email

### Direct to You — VIP Senders
- **[Sender]**: [Subject] — [1-line summary]. **Action:** [respond / review / forward]

### Direct to You — Others
- **[Sender]**: [Subject] — [1-line summary]. **Action:** [respond / review]

### Group Emails Including You
- **[Sender]**: [Subject] — [1-line summary]

*[X FYI/newsletter emails skipped | X automated emails filtered]*

---

## Messages (Teams + Slack)

### Needs Your Response
- **[Person]** ([source]): [1-line summary] — *[time ago]*

### From Key Stakeholders
- **[Person]** ([source]): [1-line summary] — *[time ago]*

### Other Activity
- [X messages across Y chats in Teams]
- [X messages across Y channels in Slack]

---

## Channel Posts

### Needs Your Attention
- **[Channel]** — **[Author]**: [1-line summary]. **Action:** [reply / review]

### Announcements & Decisions
- **[Channel]** — **[Author]**: [1-line summary]

### Channel Activity Summary
| Channel | Posts (last 48h) | Notable |
|---------|-----------------|---------|
| ...     | ...             | ...     |

---

## Meetings

### Today — [Day, Date]
| Time | Meeting | With | Can't Miss? | Prep Needed |
|------|---------|------|-------------|-------------|
| ...  | ...     | ...  | ...         | ...         |

**Open blocks:** [list 30min+ gaps]
**Conflicts:** [any overlaps]

### Tomorrow — [Day, Date]
| Time | Meeting | With | Can't Miss? | Prep Needed |
|------|---------|------|-------------|-------------|

### Rest of Week
| Day | Time | Meeting | With | Notes |
|-----|------|---------|------|-------|

---

## Appendix

### Data Issues
- [sources unavailable, errors, missing config]

### Source Summary
| Source | Status | Items |
|--------|--------|-------|
| Email  | ...    | ...   |
| Calendar | ... | ...   |
| Teams Chats | ... | ... |
| Teams Channels | ... | ... |
| Slack  | ...    | ...   |
```

## Formatting Rules

- Use emoji section headers consistently: TL;DR, To-Do, Email, Messages, Channel Posts, Meetings, Appendix.
- Tier indicators: **red** = needs response/action, **yellow** = from key people/FYI important, **blue** = volume summary.
- Tables for meetings and channel activity. Bullets for everything else.
- Each TL;DR bullet must be self-contained — a reader seeing only this section knows what to do today.
- Automated/notification emails (noreply@, system alerts) are counted but not classified into tiers.

## Anti-Patterns

- **Don't list every email.** Tier 4 (FYI/newsletters) is a count only.
- **Don't show "0 messages" rows.** Omit empty sources.
- **Don't bury action items.** Every action-required item appears in both its source section AND the To-Do list.
- **Don't skip the TL;DR.** Even on quiet days, write 2-3 bullets.
- **Don't editorialize.** Report what happened; don't add opinions about priority unless asked.
