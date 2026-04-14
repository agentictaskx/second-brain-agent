---
title: Playbook Registry
type: index
---

# Playbook Registry

> The Manager reads this to find the right playbook for each output request.
> The Composer reads `_defaults.md` first, then the matched playbook.

## Lookup Table

| Playbook | Audience | Format | Channel | Trigger Examples |
|----------|----------|--------|---------|------------------|
| [daily-brief](daily-brief.md) | self | markdown | vault | "catch me up", "morning brief", "what did I miss", "start my day" |
| [ado-rag-workstream](ado-rag-workstream.md) | team | html | ado | "weekly RAG", "mission update", "workstream rollup", "DRI summary" |
| [teams-channel-post](teams-channel-post.md) | team | markdown | teams-channel | "post to Teams", "channel update", "announce in channel" |
| [chat-message-polish](chat-message-polish.md) | peer | chat | teams-chat | "draft reply", "polish this message", "write a response" |
| [email-status-brief](email-status-brief.md) | leadership | email | email | "email brief", "send status email", "email the VP", "executive update" |
| [weekly-review](weekly-review.md) | self | markdown | vault | "weekly review", "weekly summary", "what happened this week" |

## Selection Rules

1. **Exact match:** If the user's request matches a trigger phrase, use that playbook.
2. **Audience + channel match:** If no trigger phrase matches, select by audience and channel.
3. **Audience match only:** If channel is ambiguous, select by audience and ask about channel.
4. **Defaults only:** If nothing matches, apply `_defaults.md` alone and ask the user for clarification.

## Defaults

Every output applies `_defaults.md` rules. Specific playbooks extend or override those defaults.

## Dimensions Reference

**Audience:** self | team | leadership | peer | external
**Format:** markdown | html | email | chat | slide
**Channel:** vault | ado | teams-channel | teams-chat | email | slack | doc
