# MCP Detection Reference

This document describes how to detect available MCP tools at runtime. The SKILL.md dispatcher uses `ToolSearch` to probe for each MCP category and builds a capabilities object.

## Detection Method

Inside SKILL.md (or any agent), use the `ToolSearch` tool to probe for MCP tool prefixes. Each MCP server registers tools with a predictable naming prefix. If `ToolSearch` returns results for a prefix, that MCP is available.

## Probe Patterns

| Service | Tool Prefix to Search | Example Tool | Capability Key |
|---------|----------------------|--------------|----------------|
| Email | `mcp__WorkIQ-Mail__` | `mcp__WorkIQ-Mail__SearchMessages` | `email` |
| Calendar | `mcp__WorkIQ-Calendar__` | `mcp__WorkIQ-Calendar__ListEvents` | `calendar` |
| Teams | `mcp__WorkIQ-TeamsV1__` | `mcp__WorkIQ-TeamsV1__ListChats` | `teams` |
| SharePoint | `mcp__WorkIQ-SharePoint__` | `mcp__WorkIQ-SharePoint__SearchSites` | `sharepoint` |
| OneDrive | `mcp__WorkIQ-OneDrive__` | `mcp__WorkIQ-OneDrive__ListFiles` | `onedrive` |
| Word | `mcp__WorkIQ-Word__` | `mcp__WorkIQ-Word__GetDocumentContent` | `word` |
| Copilot | `mcp__WorkIQ-Copilot__` | `mcp__WorkIQ-Copilot__Chat` | `copilot` |
| ADO | `mcp__plugin_azure-devops-mcp` | `mcp__plugin_azure-devops-mcp_azure-devops-mcp__wit_get_work_item` | `ado` |
| Slack | `mcp__plugin_slack-mcp_slack__` | `mcp__plugin_slack-mcp_slack__slack_send_message` | `slack` |
| Obsidian | `mcp__plugin_user-mcp-obsidian_obsidian__` | `mcp__plugin_user-mcp-obsidian_obsidian__read_note` | `obsidian` |

## Detection Logic (for SKILL.md)

```
For each service in probe_patterns:
  1. Use ToolSearch with the tool prefix as the query
  2. If ToolSearch returns 1+ matching tools → capability = true
  3. If ToolSearch returns 0 matching tools → capability = false

Build capabilities object:
  {
    "email": <bool>,
    "calendar": <bool>,
    "teams": <bool>,
    "sharepoint": <bool>,
    "onedrive": <bool>,
    "word": <bool>,
    "copilot": <bool>,
    "ado": <bool>,
    "slack": <bool>,
    "obsidian": <bool>
  }

Pass this object to the Manager agent as `mcp_capabilities`.
```

## Graceful Degradation

When an MCP is not detected:
- The Retriever skips that data source (records as `skipped_source`, not `failed_source`)
- The daily brief omits that section with a footer note
- The Actor falls back to vault-only operations (e.g., save draft to `raw/drafts/` instead of sending)

See the Graceful Degradation Matrix in the plan for full operation × capability mapping.

## MCP Installation Guide

| Service | How to Install |
|---------|---------------|
| Email, Calendar, Teams, SharePoint, OneDrive, Word, Copilot | Install the `workiq-mcp` plugin from mai-agents marketplace |
| ADO | Install the `azure-devops-mcp` plugin from mai-agents marketplace |
| Slack | Install the `slack-mcp` plugin from mai-agents marketplace (LOCAL ONLY — requires local server) |
| Obsidian | Install the `obsidian` plugin from obsidian-skills marketplace + configure the Obsidian MCP server |

## Notes

- MCP detection happens ONCE per session (on first invocation of the skill) and is cached in the Manager
- If a previously-available MCP starts failing mid-session, the Retriever records the failure in `wiki/tools.md` and switches to fallback
- Detection is near-instant — ToolSearch queries are fast and don't require actual API calls to the MCP services
