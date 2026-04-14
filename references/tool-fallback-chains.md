# Tool Fallback Chains

When a primary tool fails, try alternatives in order. Record all attempts in `wiki/tools.md`.

## Email
1. WorkIQ-Mail MCP → 2. MS Graph MCP → 3. Ask user to paste

## Teams Channels
1. WorkIQ-Teams MCP (listChannelMessages) → 2. Slack MCP (if cross-posted) → 3. Ask user to paste

## Teams Chat
1. WorkIQ-Teams MCP (listChatMessages) → 2. Ask user to paste

## Calendar
1. WorkIQ-Calendar MCP → 2. MS Graph MCP → 3. Ask user for meeting notes

## SharePoint/OneDrive
1. WorkIQ-SharePoint MCP → 2. WorkIQ-OneDrive MCP → 3. WebFetch (if URL) → 4. Ask user to paste

## ADO Work Items
1. ADO MCP (wit_get_work_item) → 2. Ask user for work item details

## Web Content
1. Defuddle CLI → 2. WebFetch → 3. Ask user to paste

## Slack
1. Slack MCP → 2. Ask user to paste

## Sending (Outbound)
### Teams Channel Post
1. Slack MCP (if Slack-bridged) → 2. WorkIQ-Teams MCP → 3. Copy to clipboard for manual paste

### Email
1. WorkIQ-Mail MCP → 2. Copy to clipboard for manual paste

### ADO
1. ADO MCP (wit_update_work_item / wit_add_work_item_comment) → 2. Copy to clipboard for manual paste

## General Rule
- Always save to `raw/` BEFORE attempting external send (Raw-First rule)
- Record success/failure in `wiki/tools.md` with date and error message
- After 3 consecutive failures for a tool, mark as `broken` in tools.md
