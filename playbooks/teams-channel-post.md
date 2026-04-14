---
title: Teams Channel Post
type: playbook
audience: team
format: markdown
channel: teams-channel
examples:
  - "post to Teams"
  - "channel update"
  - "announce in channel"
  - "post status to channel"
---

# Teams Channel Post

## When to Use

When posting an update, announcement, or status to a Teams channel. Channel posts are public to the team — they must be scannable, action-oriented, and self-contained.

## Structure

Channel posts follow a compressed format — no headers, no preamble:

1. **Lead line** — one bolded sentence stating the point
2. **Supporting detail** — 2-5 bullets with specifics
3. **Ask or next step** — what the reader should do (if anything)

For longer announcements (decisions, status rollups), add a brief structure:

1. **Subject line** (bold, in the post title or first line)
2. **Context** — 1-2 sentences of why this matters
3. **Details** — bulleted list
4. **Action / Next step** — explicit ask with owner and deadline

## Template

### Short Post (default)
```
**[One-line summary of the update]**

- [Detail 1 — what happened, with metrics if applicable]
- [Detail 2]
- [Detail 3]

[Action: @person please [do X] by [date] / No action needed — FYI only]
```

### Status Post
```
**[Workstream/Project] Status — [Date]**

Overall: [Green/Yellow/Red]

- **[Area 1]:** [1-line status]
- **[Area 2]:** [1-line status]
- **[Blocker]:** [description] — need [what] from [who] by [when]

Next update: [date]
```

### Decision Announcement
```
**Decision: [What was decided]**

Context: [1-2 sentences on why this came up]

What's changing:
- [Change 1]
- [Change 2]

Effective: [date]. Questions → [person or thread].
```

## Formatting Rules

- **No greeting.** Don't start with "Hi team" or "Hey everyone."
- **Bold the lead.** First line is always bold — it's the "subject line" of the post.
- **Bullets over paragraphs.** If you have 3+ points, use bullets.
- **@ mention sparingly.** Only @mention people who have a specific action item.
- **Keep it short.** Most channel posts should be 3-8 lines. If it's longer, consider email instead.
- **One post = one topic.** Don't combine unrelated updates.

## Tone

- Direct, casual-professional
- Match the channel's energy — some channels are formal (announcements), others casual (general)
- No unnecessary pleasantries, no sign-off
- Confident — state facts, don't hedge

## Examples

### Good
```
**V3 Dev squad moved Green → Amber this week**

- Granularity evaluation framework formalized (binary pass/fail metric)
- MMM2 coverage item updated — still tracking for C2 milestone
- Creator recommendations item flagged Amber

Signal Foundation Week 4 RAG still pending — @Kunyang please post by EOD Thursday.
```

### Bad
```
Hi team! Hope everyone's doing well. Just wanted to give a quick update on where things stand. We've been making good progress on a few fronts. The V3 Dev squad has been working hard on the granularity evaluation framework, and Deb has formalized the approach. Also, there are some updates on MMM2 coverage. Let me know if you have questions!
```

## Anti-Patterns

- **Don't write a wall of text.** If it's more than 10 lines, break it up or use email.
- **Don't start with "Hi team."** Jump to the point.
- **Don't end with "Let me know if you have questions."** If there's a real question, ask it. Otherwise, skip.
- **Don't use "just wanted to..."** — state the update directly.
- **Don't combine multiple topics.** One post per topic.
- **Don't use headers (##) in short posts.** Save structure for longer announcements.
