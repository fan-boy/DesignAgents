---
name: design-review
description: >
  Uses structured critique before handoff, stakeholder review, or post-launch audit.
  Applies Nielsen's 10 heuristics plus Dune-specific heuristics to identify UX issues,
  check design system compliance, evaluate product craft against a Stripe-level quality bar,
  and produce a severity-rated findings list with a clear readiness verdict.
---

# Design Review

## When to use
- A design is ready for critique before developer handoff
- A design is being reviewed by a stakeholder and needs a structured pre-review
- A shipped feature needs a post-launch audit
- A Figma flow, live experience, or prototype needs a heuristic evaluation
- A feature needs a formal design quality check before implementation begins

## When NOT to use
- The design is in early exploration — use `design-strategist` instead
- You're reviewing copy only — use `ux-copy` instead
- The request is to invent a new workflow from scratch rather than critique an existing one
- The review is purely engineering code review rather than UX/design review

## Inputs
- Figma link, Figma selection, or design description
- Feature context (what it does, who uses it, why it matters)
- Known open questions or areas of concern
- Optional: live URL, screenshots, PRD excerpts, existing feature slug, or related feature folder

If no design artifact is provided, ask for one before proceeding.  
If no feature context is provided, ask for the minimum needed context:
- What feature is being reviewed?
- Who is the primary user?
- What is the user trying to accomplish?
- What areas are most important to review?

## Feature slug
Before writing output:
1. Identify or confirm the `<feature-slug>`.
2. Use lowercase kebab-case.
3. If a matching folder exists in `knowledge/features/<feature-slug>/`, load it.
4. If the slug is ambiguous or the review spans multiple features, ask for clarification before writing files.
5. Use the slug consistently across output paths and file names.

## Required context lookup
Before reviewing, read from `knowledge/features/<feature-slug>/` when available:

- `prd-research-summary.md`
- `prd-research.json`
- `open-questions.md`
- `edge-cases.md`
- `competitor-analysis.md`
- `competitor-analysis.json`
- `design-strategy.md`
- `design-strategy.json`
- `user-flow.md`
- `user-flow.mmd`
- `dev-handoff.md` if it exists and is relevant

Use these files to understand:
- intended user goal
- expected workflow and success path
- key constraints
- known risks and edge cases
- previous design reasoning
- open questions that may affect the review

If no feature folder exists, continue with the available artifact, but explicitly note that review confidence is lower without stored context.

## Rubrics
All rubrics are in `.claude/skills/design-review/rubrics/`:
- `heuristics.md` — Nielsen's 10 plus Dune-specific heuristics
- `severity-scale.md` — S0–S4 severity definitions
- `review-output-format.md` — output structure
- `product-principles.md` — Dune UX principles to evaluate against

## Quality bar
Use Stripe as the benchmark for interaction quality and product craft — not as a visual style to copy. Stripe is widely associated with meticulous craft, user-first clarity, and trust-building product quality, which makes it a useful benchmark for evaluating interaction quality and polish. [web:173][web:171][web:176]

Evaluate whether the design is at the level of quality a team like Stripe would ship in terms of:
- clarity of information hierarchy
- obvious next actions
- consistency and restraint
- quality of states and edge-case handling
- trust and risk communication
- precision of copy and feedback
- accessibility and keyboard-friendly behavior
- polish of interaction details and system feedback

This means:
- no vague or confusing actions
- no weak empty, loading, success, or error states
- no avoidable inconsistency in hierarchy, spacing, or component use
- no trust-eroding ambiguity around risky or consequential actions
- no “good enough” interaction design when a more thoughtful flow is clearly needed

Do not recommend copying Stripe’s visuals, layouts, or branding.  
Use Stripe only as a north star for product quality, coherence, and craft. [web:171][web:173]

## Instructions
1. Read the feature context and identify the primary user, core task, and consequence of failure.
2. Inspect the provided design artifact carefully: frame, flow, prototype, screenshot set, or live UI.
3. Evaluate against all 10 Nielsen heuristics and all 5 Dune-specific heuristics.
4. Check whether the design meets the quality bar defined above: clarity, hierarchy, trust, consistency, state coverage, accessibility, and interaction polish at a Stripe-level standard of craft.
5. Check design system compliance: tokens, component variants, spacing, accessibility, and system pattern reuse.
6. Check RBAC and permission boundary design.
7. Check for missing or weak states:
   - loading
   - empty
   - success
   - error
   - partial success
   - permissions / restricted access
   - destructive / irreversible actions
   - interrupted or retry scenarios
8. Distinguish between:
   - heuristic violations
   - design system violations
   - craft / polish gaps
   - trust / risk communication gaps
9. Rate every finding S0–S4 using `rubrics/severity-scale.md`. Severity should consider frequency, impact, and persistence, which are standard factors in heuristic severity rating. [web:172][web:174][web:177]
10. Produce output using the structure in `rubrics/review-output-format.md`.
11. State a clear verdict:
   - ready for handoff
   - needs revision
   - blocked on open questions
12. Include strengths, not just issues.
13. Recommend practical fixes a product designer can apply in the next iteration.
14. Add a short teaching note for each important finding so the review improves design judgment over time.

## Review constraints
- Focus on meaningful user-facing issues, not cosmetic nitpicks
- Prefer fewer high-confidence findings over broad shallow criticism
- Do not redesign the whole feature unless explicitly asked
- Do not hallucinate product intent that is not supported by the artifact or feature context
- If confidence is low because of missing context, say so clearly
- If a design decision appears intentional but risky, identify the tradeoff rather than assuming it is simply wrong

## Persistence

### When to write
Write output files after the full review is complete.  
If the feature slug is unclear or no design artifact is available, resolve that first before writing anything.

### Where to write
All files go in:

`knowledge/features/<feature-slug>/`

Create the folder if it does not exist.  
Never create duplicate filenames with suffixes like `-new`, `-v2`, or `-final`.

### How to update existing files
If review files already exist:
- Read the existing content before overwriting
- Preserve still-relevant findings and unresolved questions
- Update findings that are no longer accurate
- Refresh revision priorities if the design has changed
- Update `last_updated` in `design-review.json`

### Downstream consumers
These files are used by:
- `dev-handoff` to clarify implementation risk and unresolved issues
- future `design-review` runs to compare revisions
- designers during critique and iteration
- stakeholder review preparation

Keep JSON values clean and parseable.  
Keep markdown readable in human review sessions.

## Output files

### `design-review.md`
Primary human-readable review document.  
Optimized for critique sessions, stakeholder reviews, and async design iteration.

### `design-review.json`
Machine-readable summary of findings for downstream reuse. Required keys:

```json
{
  "feature_name": "Human-readable feature name",
  "feature_slug": "kebab-case-slug",
  "review_scope": "What was reviewed",
  "review_focus": ["hierarchy", "states", "accessibility"],
  "verdict": "ready for handoff | needs revision | blocked on open questions",
  "quality_bar_assessment": "Brief assessment of whether the design meets the intended craft standard",
  "strengths": ["strength 1", "strength 2"],
  "findings": [
    {
      "id": "DR-01",
      "severity": "S2",
      "category": "Error prevention",
      "location": "Invite review table",
      "issue": "Users can submit without clearly understanding which rows will fail",
      "why_it_matters": "This increases the risk of accidental bad submissions",
      "recommended_fix": "Separate valid and invalid rows visually and disable submit until the state is understood",
      "principles": ["Clarity before cleverness", "Error prevention"],
      "teaching_note": "Bulk actions need pre-submit certainty because mistakes scale quickly"
    }
  ],
  "open_questions": ["question 1"],
  "revision_priorities": ["priority 1", "priority 2"],
  "last_updated": "YYYY-MM-DD"
}
```

Keep findings concrete, specific, and directly tied to observed issues.

## Output format (for `design-review.md`)

### Review summary
2–4 bullets on the most important issues and strengths.

### Quality bar assessment
Answer:
- Does this feel ready at a Stripe-level standard of product craft?
- If not, what specifically makes it fall short?
- Is the gap mainly in clarity, trust, consistency, state design, accessibility, or polish?

### Findings
Numbered findings. For each include:
- severity
- category
- location
- issue
- why it matters
- recommended fix
- principle / heuristic violated
- teaching note

### Strengths
Short bullets for what is working well.

### Open questions
Only include questions that materially affect confidence in the review.

### Revision priorities
Top 3–5 things to fix next.

### Verdict
One of:
- ready for handoff
- needs revision
- blocked on open questions

## Read these files
- `rubrics/heuristics.md`
- `rubrics/severity-scale.md`
- `rubrics/review-output-format.md`
- `rubrics/product-principles.md`

## Example request
Review the bulk invite flow for usability, hierarchy, accessibility, and error prevention. Focus especially on partial failure handling, RBAC boundaries, and trust.

## Example response shape
See `rubrics/review-output-format.md`