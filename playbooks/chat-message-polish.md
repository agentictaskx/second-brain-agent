---
title: Chat Message Polish
type: playbook
audience: peer
format: chat
channel: teams-chat
examples:
  - "draft reply"
  - "polish this message"
  - "write a response"
  - "help me reply"
  - "clean this up"
---

# Chat Message Polish

## When to Use

When drafting or polishing a Teams chat message (1-1 or group). Two sub-modes based on the message complexity.

## Sub-Modes

### Quick Reply (default)

For routine responses — acknowledgments, short answers, simple decisions.

**Structure:** 1-3 sentences. No formatting. Match the thread energy.

**Rules:**
- Conversational, efficient
- Low formality — first names, contractions OK
- Match the energy of the thread — don't over-explain
- If the thread is casual, be casual. If it's technical, be precise.
- No greeting, no sign-off

### Substantive Response

For complex answers — decisions with reasoning, multi-part responses, technical explanations.

**Structure:** Flowing prose by default. Tables only if comparing options. No bullet points unless explicitly asked.

**Rules:**
- Direct, structured when needed
- As long as necessary, but no padding
- Low-medium formality
- Lead with the decision or answer, then explain
- Use prose paragraphs — not bullets — for nuanced points

## Template

### Quick Reply
```
[Direct answer or acknowledgment — 1-3 sentences]
```

### Substantive Response
```
[Decision or answer — first sentence]

[Supporting reasoning — 2-4 sentences of prose explaining why. Use flowing paragraphs, not bullets.]

[If comparing options: brief table]

[Next step or ask, if any]
```

## Mode Selection

The Composer picks the mode based on:

| Signal | Mode |
|--------|------|
| Original message is 1-3 sentences | Quick |
| User says "quick reply" or "ack this" | Quick |
| Original message asks a yes/no question | Quick |
| Original message has multiple questions | Substantive |
| User says "explain" or "help me think through" | Substantive |
| Topic involves a decision or tradeoff | Substantive |
| Thread has 5+ back-and-forth messages | Substantive |

## Examples

### Quick Reply — Acknowledgment
```
Got it, will review by EOD.
```

### Quick Reply — Short Answer
```
Yes, we should go with option B. The latency tradeoff isn't worth it for our scale.
```

### Quick Reply — Redirect
```
Deb owns that area — loop her in and she can confirm the timeline.
```

### Substantive — Decision with Reasoning
```
I'd go with the binary pass/fail metric for granularity evaluation.

The percentage-based approach gives us more precision in theory, but in practice the grading criteria are too subjective across evaluators. Binary forces a clear standard: either the interest name is specific enough to be actionable, or it isn't. We can always layer on a more granular rubric later once we have baseline agreement on what "good" looks like.

Next step: Deb to formalize the 8-case truth table and share for review by Thursday.
```

### Substantive — Multi-Part Response
```
Three things on the DoCA convergence path:

The UMS mapping question is still open. Vikas commented on the ADO item Mar 27 but hasn't gotten a response — that's 13 days now. I'll escalate in the next RAG if we don't hear back by Wednesday.

On user activity access, the blocker is the WAPI V2 timeline. We're missing ETAs for 8 data sources. I've asked Ashly to follow up with the WAPI team directly.

For C3 planning purposes, I'm assuming DoCA won't converge before mid-May. If that changes, we can pull in the onboarding work earlier.
```

## Anti-Patterns

- **Don't over-format chat messages.** No headers, no horizontal rules, no emoji section markers.
- **Don't use bullets for 2 items.** Just write two sentences.
- **Don't start with "Great question!"** — answer the question.
- **Don't add a greeting in a group chat thread.** Jump to the response.
- **Don't hedge unnecessarily.** "I think maybe we could consider..." — just state the position.
- **Don't write an essay for a yes/no question.** Match the complexity of the ask.
