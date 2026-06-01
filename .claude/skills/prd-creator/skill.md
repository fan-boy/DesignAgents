---
name: prd-creator
description: >
  Generate a Confluence-ready PRD in markdown from Figma designs and supporting documents.
  Use whenever a user provides a Figma link, a feature brief, a spec doc, or any combination
  of those and wants a PRD written. Also triggers when the user says "write a PRD", "document
  this feature", "turn this into a PRD", "draft the spec", or "Confluence doc". Reads all
  existing feature knowledge files before writing. Outputs prd.md and prd.json to
  knowledge/features/<feature-slug>/. Grounded in Dune Security's platform: simulation
  campaigns, group targeting, risk scoring, agent automation, RBAC-gated admin flows,
  learner-facing training delivery, and the Stillsuit DS v2 design system.
---

# PRD Creator

Produces a Confluence-ready PRD in markdown from a combination of Figma designs and supporting
documents. The output format matches Dune Security's internal PRD style: flowing prose with bold
section headers, actor-separated flows, wizard step breakdowns, inline tables for options and
edge cases, and no formal PM ceremony (no OKRs, no success metrics blocks unless already present
in source material).

---

## Inputs

The user may provide any combination of:
- A Figma file or frame link
- A feature brief, spec doc, copy-paste of a Confluence page, or plain notes
- A feature name or slug

At least one of Figma link or supporting doc is required. If neither is present, ask before proceeding.

---

## Standalone mode

This skill can be run directly without the feature-workflow orchestrator. When run standalone,
it handles its own context gathering before doing any work.

### Upfront context check

At the start of every standalone run, assess what the user has provided:

| Missing | What to ask |
|---|---|
| Feature name | "What should this feature be called?" |
| Figma link | "Do you have a Figma link? If not, I'll work from the doc alone." |
| Supporting doc | "Any notes, brief, or spec to go with this?" (skip if doc already provided) |
| Both Figma and doc | "I need at least a Figma link or a feature doc to proceed — which do you have?" |

Ask all missing questions in a single message — not one at a time. If the feature name is
ambiguous or could map to multiple slugs, confirm the slug before writing any files.

Once context is confirmed, proceed without further check-ins unless a blocker surfaces mid-run.

### What counts as sufficient context to start

- Feature name + at least one of: Figma link, spec doc, plain notes → proceed
- Feature name only, no Figma, no doc → ask for at least one source before proceeding
- Figma link only, no feature name → derive the name from the Figma file/frame name; confirm
  before writing files

### Mid-run blockers

If a gap surfaces during extraction or writing that would make a whole section incomplete
(e.g., no information on the end user flow at all), note it at the end under **Gaps** rather
than stopping mid-run. Complete what can be completed, flag what cannot.

---

## Required pre-check

Before writing anything:

1. Derive the feature slug (lowercase kebab-case):
   - "Custom Training Modules" → `custom-training-modules`
   - "AI Spear Phishing for Groups" → `ai-spear-phishing-groups`
2. Check `knowledge/features/<feature-slug>/` for existing files.
3. If any of the following exist, read them before writing the PRD — they inform the narrative,
   fill edge cases, and surface open questions:
   - `prd-research.json` / `prd-research-summary.md` — feature goals, constraints, open questions
   - `competitor-analysis.json` / `competitor-analysis.md` — competitive context, patterns to adopt/avoid
   - `design-strategy.json` / `design-strategy.md` — recommended approach, wireframe decisions
   - `edge-cases.md` — system behaviours and edge cases to include in the PRD
   - `open-questions.md` — unresolved questions; flag any that block writing a complete PRD
4. If the slug is ambiguous, ask before writing.

---

## Figma extraction (only when a link is provided)

When a Figma link is present:

1. Load the figma-use skill before calling any Figma tool.
2. Extract from the target file or frame:
   - Screen names and page structure
   - UI copy: labels, placeholder text, error messages, empty states, CTAs, toast copy
   - Wizard step names and sequences
   - Table column headers and row content
   - Status labels and badge text
   - Any visible annotations or notes
3. Use Figma as the source of truth for UI copy and flow structure.
4. Use supporting docs to fill in intent, business logic, edge cases, and context that
   isn't visible in the designs.
5. If there is a conflict between Figma copy and doc copy, prefer Figma (it's closer to
   what ships) and note the discrepancy.

---

## How to write the PRD

### Tone and style
- Flowing prose with bold section headers — not bullet-heavy
- Declarative, present-tense: "Admins create a module through a three-step wizard"
- Actor-first framing: separate Admin flows from End User flows clearly
- Specific over generic: name the actual fields, labels, options, and counts
- Tables for: wizard steps with options, comparison choices, edge case behaviour matrix,
  integration points — not for body content
- No em dashes. No rhetorical questions. No "intuitive" or "seamless."
- Do not pad with motivation or rationale unless it was in the source material

### What to always include

**Feature overview** — 2–4 sentences on what the feature does, who uses it, and what problem it solves. Name the flows it covers.

**Per-flow sections** — one section per distinct user flow. Name flows clearly:
- Create [X] — wizard steps with field names, validation notes, empty states
- Assign [X] — options, audience selection, confirmation behaviour
- [Actor] view of [X] — what the end user sees and does

**Wizard steps** — for each step in a multi-step wizard:
- Step name and number
- Fields with types and required/optional status
- Validation or constraints (e.g., "must be unique", "max 10 MB")
- Empty states if applicable

**Options and decision points** — use a table when there are 2+ choices with distinct behaviours:
| Option | Description |
|---|---|

**Post-action behaviour** — toast copy, redirect, confirmation state

**Integration points** — table of how this feature connects to other platform systems:
| Integration | Description |
|---|---|

**Edge cases & system behaviour** — table of non-happy-path scenarios:
| Scenario | Behaviour |
|---|---|

### What to include only if present in source material
- Email notification changes — describe the new notification type and trigger
- RBAC / permission notes — who can perform which actions
- Audit log / compliance notes — what gets timestamped and recorded
- Empty library / no-data states — what the user sees before any content exists
- Edit flow — if update/edit behaviour differs from create, describe it

### What to omit
- Success metrics, OKRs, KPIs — unless they were in the input
- Technical implementation details — unless they were in the input
- Design rationale or competitor context — save that for design-strategy.md
- Open questions — move those to open-questions.md, not the PRD body

---

## Output files

Write to `knowledge/features/<feature-slug>/`.

### `prd.md`
The Confluence-ready PRD. Plain markdown. No frontmatter. Starts directly with the feature
overview prose — no title heading needed (Confluence page title handles that).

Structure:
```
[Feature overview paragraph]

[Flow 1 heading]
[Flow 1 content]

[Flow 2 heading]
...

Integration Points
[table]

Edge Cases & System Behaviour
[table]
```

### `prd.json`
Machine-readable summary for downstream skills (design-strategist, dev-handoff).

```json
{
  "feature_name": "Human-readable feature name",
  "feature_slug": "kebab-case-slug",
  "written_at": "YYYY-MM-DD",
  "flows": ["flow name 1", "flow name 2"],
  "actors": ["Admin", "End User"],
  "wizard_steps": {
    "FlowName": ["Step 1 — Name", "Step 2 — Name"]
  },
  "key_fields": ["field name 1", "field name 2"],
  "integrations": ["Risk Scoring Engine", "Email Notifications"],
  "edge_cases_count": 4,
  "open_questions_flagged": ["question 1"],
  "figma_used": true,
  "source_docs_used": true,
  "confidence": "high | medium | low",
  "confidence_notes": "why confidence is rated as it is"
}
```

---

## Updating an existing PRD

If `prd.md` already exists:
- Read it before writing anything
- Add a `## Last updated` note at the top with date and summary of what changed
- Do not replace sections wholesale — update only what the new input changes
- Update `written_at` in `prd.json` and add a `last_updated` field

---

## Dune-specific context to apply

The following platform knowledge should inform how integration points and edge cases are written.
You don't need to research these — apply them when relevant:

- **Risk Scoring Engine** — training completion and overdue status feed into risk scores; mention
  when a feature affects how users move through training
- **Adaptive Workflows** — modules and trainings can be triggered automatically by risk events or
  onboarding; mention when assignment can be automated
- **Email Notifications** — uses the configured Training Sender Email Domain; assignment and
  overdue reminders are distinct notification types
- **Policy Acknowledgement Log** — policy acceptances are timestamped and recorded for audit; always
  include when policy documents are part of the feature
- **Smart Groups** — dynamically computed groups based on rules; relevant when assignment targets groups
- **Stillsuit DS v2** — Dune's design system; do not describe components in implementation terms,
  but do use correct naming for status types (e.g., Overdue, In Progress, Completed, Not Started)
- **RBAC** — admin actions are gated; note if a flow is admin-only or if end users have a
  separate view

---

## Confidence rating

Rate `confidence` in `prd.json` as:
- **high** — Figma + supporting doc both present, all flows covered, no material gaps
- **medium** — one source only, or flows partially covered, or minor gaps
- **low** — significant gaps, no Figma, or source material is fragmentary

List specific gaps in `confidence_notes`.

---

## Example requests

**Via orchestrator (full context provided):**
"Here's the Figma link and the feature notes — write a PRD for the Custom Training Modules feature."

**Standalone, full context:**
"Write a PRD for AI Spear Phishing for Groups. Figma: [link]. Notes: [doc]."

**Standalone, partial context:**
"Can you write a PRD for the new scheduler feature?" →
Skill responds: "What should I call this feature exactly? Do you have a Figma link or any notes/spec? I need at least one source to work from."

**Standalone, Figma only:**
"Here's the Figma link — [link]. Write the PRD." →
Skill reads Figma, derives feature name from file/frame name, confirms slug, then proceeds.

## Output shape
Standalone or orchestrated:
Check for existing feature files → gather missing context if standalone → extract Figma (if link provided) → synthesize with docs → write `prd.md` in Confluence-ready markdown → write `prd.json` → report files written, confidence rating, and any gaps.