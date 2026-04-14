# Example Files

These are real examples from a mature Second Brain vault, provided as reference for new users setting up their own vault.

## What's Here

| File | Description |
|------|-------------|
| `identity-example.md` | A fully populated identity page showing communication preferences, stakeholder tables, writing styles, and working preferences |
| `people-example.md` | A people directory with 20+ entries across management chain, direct collaborators, and cross-functional partners |
| `channels-example.md` | Teams channels and group chats with IDs, channel conventions, and monitoring context |
| `subscriptions-example.md` | Complete subscription configuration: watched channels, group chats, email filters, and sender exclusions |

## How to Use These

1. **Read them to understand the structure.** Each example shows the expected frontmatter, section headers, and content format that the agents rely on.

2. **Use them as calibration.** When filling in your own templates, match the level of detail shown here. The agents work best when entries include context (e.g., "What they care about", "Recent" activity notes for people).

3. **Don't copy them verbatim.** Your vault should reflect YOUR people, channels, and preferences. The templates in `../templates/` provide the empty structure — these examples show what "done" looks like.

## Key Patterns to Notice

- **People entries have context, not just contact info.** Each person has "What they care about" and "Recent" notes that help the AI compose messages in the right tone and with the right context.

- **Channels include IDs.** The Teams channel and chat IDs enable the Retriever agent to pull messages directly via the MCP tools. Without IDs, the system can only search by name (less reliable).

- **Subscriptions control the daily brief.** The subscriptions page is the "control panel" for what gets checked each morning. Empty sections are skipped gracefully.

- **Sender exclusions reduce noise.** The automated sender exclusion table keeps notification emails out of your priority inbox scan.

## Audience

These examples are from a Microsoft internal deployment. They contain real names, email addresses, and Teams channel IDs appropriate for distribution within Microsoft. If you're adapting this system for a different organization, replace all entries with your own.
