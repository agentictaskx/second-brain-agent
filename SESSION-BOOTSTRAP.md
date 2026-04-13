# SESSION-BOOTSTRAP: second-brain-agent

## Current State
**Phase:** Design complete, ready for implementation
**Repo:** https://github.com/agentictaskx/second-brain-agent
**Local:** C:/Users/nealzhang/project/second-brain-agent
**Plan:** docs/DESIGN.md (1100+ lines, fully reviewed)

## What Was Done (Apr 13, 2026)
1. Analyzed existing `/second-brain` skill (vault at Obsidian) and `/mai-cos` skill (chief of staff)
2. Analyzed 7 days of real vault usage data (log.md, usage-log.md, session ledgers)
3. Designed unified architecture: 1 Manager + 5 Specialists (Retriever, Analyst, Composer, Actor, Auditor)
4. Ran 2 adversarial reviews (16 findings total, all addressed)
5. Designed: playbook system (self-learning, trigger-based), information lifecycle (inbound/outbound maps, entity routing), bootstrap flow, error handling, schema audit
6. Pushed design doc + README to GitHub

## Architecture Summary
```
Manager → Retriever (fetch data) → Analyst (extract entities, synthesize) → Composer (draft styled output) → Actor (write/send) → Auditor (verify)
```
- 7 operation types: daily brief, ingest, query, communicate, compose, lint, feedback
- Playbooks: extensible output recipes selected by intent + audience + format
- Single folder = agent code + data store (git/cloud/local/Obsidian)
- Identity in wiki/identity.md (not CLAUDE.md) — loaded every session

## Next Steps (Implementation)
1. **Phase 1: Scaffold** — Create folder structure, CLAUDE.md schema, state-manager.sh
2. **Phase 2: Agents** — Write 6 agent definition files using the prompt contracts in DESIGN.md
3. **Phase 3: Data Seeding** — Merge existing vault + mai-cos data into new structure
4. **Phase 4: CLAUDE.md Thinning** — Remove personal data from global CLAUDE.md
5. **Phase 5: Install + Test** — Plugin install, test all 7 operations

## Key Files
- `docs/DESIGN.md` — Full architecture (READ THIS FIRST)
- `README.md` — Project overview
- `~/.claude/plans/lively-leaping-clarke.md` — Same content as DESIGN.md (plan file)

## Key Decisions Made
- 6 agents (not 9, not 4) — split by cognitive mode + context needs
- Analyst + Composer separate (investigative vs creative, different context loads)
- Actor handles ALL mutations (writes + sends + checklist — no write conflicts)
- Playbooks selected by intent + audience + format (not keyword triggers)
- Manager asks when ambiguous (prevents pipeline misfire)
- Auditor does post-op verification ("someone else checks homework")
- All agents return structured error responses with partial completion
- Schema, entity routing, and playbooks are all self-expanding
- CLAUDE.md kept as filename (auto-loaded by Claude Code)

## Existing Systems to Migrate From
- `/second-brain` skill: `~/.claude/skills/second-brain/`
- `/mai-cos` skill: `~/.claude/skills/mai-cos/`
- Existing vault: `C:\Users\nealzhang\OneDrive - Microsoft\My Obsidian\My Valut\second-brain-vault`
- Vault config: `~/.claude/second-brain.json`
