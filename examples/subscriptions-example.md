---
title: Subscriptions
date: 2026-04-07
type: wiki-living
tags:
  - subscriptions
  - channels
  - monitoring
last_updated: 2026-04-13
---

# Subscriptions

Monitored Teams channels, group chats, email filters, and key 1:1 chats. Controls what gets checked during daily briefs and channel scans.

---

## Key People for Chat Monitoring

These people's 1-1 chats (Teams and Slack) are always checked during the daily brief. Supplements the VIP stakeholder list in identity.md.

| Name | UPN / Email | Chat ID | Platform | Priority | Notes |
|------|-------------|---------|----------|----------|-------|
| *(resolve next session)* | *(resolve)* | 19:398852c6-d1c3-4369-94fd-6457f4be8a69_a21d5c05-a666-436d-82b6-a073daf8343b@unq.gbl.spaces | Teams | High | 1-1 — last active Aug 7 2025 |
| *(resolve next session)* | *(resolve)* | 19:a21d5c05-a666-436d-82b6-a073daf8343b_fb82ee64-8f6b-415a-b168-fe31cdb476a5@unq.gbl.spaces | Teams | High | 1-1 — last active Aug 19 2025 |

> **Tip:** VIP stakeholders from identity.md (Julia Beizer, Sridhar Iyer, Rukmini Iyer, Umesh Shankar, Jacob Rossi, Tao Di) are automatically treated as high-priority senders. You don't need to duplicate them here unless you want to add notes.

---

## Watched Teams Channels

These channels are checked for unread posts, @mentions, and announcements during the daily brief.

| Team Name | Team ID | Channel Name | Channel ID | Why I Watch | Check Frequency |
|-----------|---------|-------------|------------|-------------|-----------------|
| MAI Content | c0734c00-20b9-4103-af0e-5da27d2a12b1 | Ruby Feedback | 19:5f714e3a85a848b1a81ec228c22ed8a8@thread.tacv2 | Ruby product feedback and issues | Daily |
| MAI Content | c0734c00-20b9-4103-af0e-5da27d2a12b1 | WS-User_Understanding | 19:4ae170cb637a4339a081bb2f2d2a8b0d@thread.tacv2 | My workstream — user understanding updates | Daily |
| MAI Content | c0734c00-20b9-4103-af0e-5da27d2a12b1 | Team-FAI Experiment Review and Ship Request | 19:c134f5e3a1954e34850e708433ea03f4@thread.tacv2 | Experiment reviews and ship approvals | Daily |
| MAI Content | c0734c00-20b9-4103-af0e-5da27d2a12b1 | Content Product Team | 19:xqBZ3bkCYVYPGHvVE0Al7Rhpwji5RAMzWHtaekFhosM1@thread.tacv2 | Org-wide product team announcements | Daily |

> **How to add a channel:** Add a row with team name and channel name. If you have the Teams URL, paste it and Claude will extract the IDs. If IDs are missing, Claude will resolve them at runtime.

---

## Watched Slack Channels

These Slack channels are checked during the daily brief (when Slack MCP tools are available).

| Workspace | Channel Name | Why I Watch | Check Frequency |
|-----------|-------------|-------------|-----------------|
| *(add as needed)* | | | |

> **Note:** If no Slack MCP tools are configured, Slack sections will be skipped with a note in the brief footer.

---

## Group Chats to Monitor

Specific group chats (Teams or Slack) that should always be checked, beyond 1-1s.

| Chat Name / Topic | Chat ID | Platform | Last Active | Why I Monitor |
|-------------------|---------|----------|-------------|---------------|
| 2x2 Feed Ranker | 19:a5e4d4e91d2d4fe282068253f1f88f7e@thread.v2 | Teams | 2026-01-07 | Feed ranking discussions |
| 2x2 Feed UU | 19:f4f48d440d91430b830e33de7480cb1c@thread.v2 | Teams | 2025-12-03 | Feed user understanding |
| F&A LT | 19:c07ff7bea04d4d7a8065161af36d6651@thread.v2 | Teams | 2026-01-30 | F&A leadership team |
| WQR Prep | 19:bb5ae80109c74afaa67a55f656a4520c@thread.v2 | Teams | 2026-03-23 | Weekly quality review prep — very active |
| MAI Profile WS/Squad Leads Chat | 19:fa979c8d713b4e12b71eb24a412ae032@thread.v2 | Teams | 2026-03-19 | MAI Profile workstream leads — directly relevant to P0 project |

---

## Automated Sender Exclusions

Emails from these senders are filtered out of the daily brief's Tier 1/2/3 classification. They appear as a summary count at the bottom of the email section.

| Pattern | Description |
|---------|-------------|
| `noreply@*` | Any noreply sender |
| `no-reply@*` | Any no-reply sender |
| `notifications@*` | Notification systems |
| `engage.mail@microsoft.com` | Viva Engage / Yammer digests |
| `akanotif@microsoft.com` | AKA link notifications |
| `becim@microsoft.com` | IcM incident management alerts |
| `ossmart2@microsoft.com` | ObjectStore automated alerts |
| `msteamsrecording@microsoft.com` | Teams recording notifications |
| `MicrosoftExchange329e71ec88ae4615bbc36ab6ce41109e@microsoft.com` | Exchange system messages |
| `promptoftheweek@microsoft.com` | Newsletter |

> **To customize:** Add rows for any automated sender that clutters your inbox. Remove rows if you want those senders back in the priority tiers.

---

## Configuration Notes

- **Empty sections = skipped in brief.** If a section above has no entries, the daily brief will skip that source and note it in the footer.
- **To add entries quickly:** Tell Claude "add [channel/person] to my watched list" and it will update this file.
- **Review cadence:** Check this file monthly to prune channels you no longer need and add new ones.
