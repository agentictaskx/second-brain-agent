# Completion Checklist

Before returning results from any operation, verify:

- [ ] Raw source saved to `raw/` with proper frontmatter and naming
- [ ] Session ledger updated at `raw/sessions/YYYY-MM-DD-session.md`
- [ ] Wiki pages updated with `[[wikilink]]` citations back to raw source
- [ ] `index.md` updated with entry for each new raw file and wiki page change
- [ ] `log.md` appended with operation summary

## When to Skip
- **Query (lookup):** Skip raw save (no new content). Still update session ledger.
- **Feedback:** Skip raw save. Update target page + session ledger + log.
- **Lint:** Skip raw save. Update session ledger + log.
