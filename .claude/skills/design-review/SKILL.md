---
name: design-review
description: >
  Use when a design needs structured critique before handoff or stakeholder review.
  Applies Nielsen's 10 heuristics + Dune-specific heuristics to identify violations,
  check design system compliance, and produce a severity-rated findings list.
---

# Design Review

## When to use
- A design is ready for critique before developer handoff
- A design is being reviewed by a stakeholder and needs a structured pre-review
- A shipped feature needs a post-launch audit

## When NOT to use
- The design is in early exploration — use design-strategist instead
- You're reviewing copy only — use ux-copy skill instead

## Inputs
- Figma link or design description
- Feature context (what it does, who uses it)
- Known open questions or areas of concern

## Rubrics
All rubrics are in `.claude/skills/design-review/rubrics/`:
- `heuristics.md` — Nielsen's 10 + Dune-specific heuristics
- `severity-scale.md` — S0–S4 severity definitions
- `review-output-format.md` — output structure
- `product-principles.md` — Dune UX principles to evaluate against

## Instructions
1. Read the feature context and identify the primary user and core task.
2. Evaluate against all 10 Nielsen heuristics and all 5 Dune-specific heuristics.
3. Check design system compliance: tokens, component variants, spacing, accessibility.
4. Check RBAC and permission boundary design.
5. Rate every finding S0–S4 using `rubrics/severity-scale.md`.
6. Produce output using the structure in `rubrics/review-output-format.md`.
7. State a clear verdict: ready for handoff, needs revision, or blocked on open questions.
