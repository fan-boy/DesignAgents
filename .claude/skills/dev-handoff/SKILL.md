---
name: dev-handoff
description: >
  Convert feature research, strategy, review findings, and Figma context into implementation-ready
  developer handoff documentation. Use when preparing a feature for engineering, clarifying states
  and interactions, or reducing ambiguity before build. Grounded in Dune Security's product context:
  simulation campaigns, group targeting, risk scoring, agent automation, RBAC-gated admin flows,
  learner-facing training delivery, and the Stillsuit DS v2 design system. Reads all available
  feature knowledge before generating output. Writes persistent files that serve as the build
  contract between design and engineering.
---

# Dev Handoff

Translates design intent into implementation-ready documentation for engineers. Synthesizes feature
research, design strategy, user flows, review feedback, and Figma context into a clear build guide.

Grounded in Dune Security's product model: enterprise security admin workflows, AI-driven simulation
and remediation systems, behavioral risk scoring, and employee learner-facing training delivery.
The handoff document is the contract between design and engineering — it must be specific enough
that a developer can build without guessing.

## When to use
- Preparing a feature for engineering handoff
- Documenting intended behavior of a flow, screen, or component
- Clarifying states, edge cases, and interactions before build
- Generating acceptance criteria and implementation notes
- Reducing ambiguity between design and development
- Flagging open RBAC or permission questions that block implementation

## When NOT to use
- Initial ideation or design exploration — run `prd-research` and `design-strategist` first
- Visual design critique or DS token decisions — that belongs in design review
- Features with no design strategy or user flow — handoff without flow coverage produces an incomplete contract

---

## Required context lookup

Before generating handoff:
1. Derive or confirm the feature slug (lowercase kebab-case, consistent with all prior skills).
2. Read from `knowledge/features/<feature-slug>/` in this order:
   - `design-strategy.json` — design goal, selected strategy, constraints, DS patterns used, open issues
   - `design-strategy.md` — fuller strategy narrative and wireframe plan
   - `user-flow.md` — behavioral backbone; drives the flow coverage section
   - `user-flow.mmd` — structural reference for flow steps
   - `edge-cases.md` — every case must appear in the handoff; note how each is handled or explicitly deferred
   - `prd-research.json` — feature goal, user segments, constraints, assumptions
   - `open-questions.md` — unresolved questions surface as open questions in the handoff
   - `design-review.md` — if available; review findings become implementation notes or acceptance criteria
3. If Figma context is available, inspect relevant frames or selections for component specifics, interaction details, and state coverage.
4. If scope is unclear or slug is ambiguous, ask before writing files.

---

## Inputs
- Feature name or feature slug
- Figma file, frame, or selection link
- PRD excerpts or design brief
- Design review notes
- Strategy docs
- Specific implementation questions from engineering
- Scope constraints (what is and is not in v1)

---

## Handoff goals

1. Define exactly what needs to be built — no more, no less
2. Explain how the experience behaves at every meaningful state
3. Document all edge cases with explicit handling instructions
4. Provide actionable accessibility requirements (not generic checklists)
5. Surface open questions that block implementation before engineering starts
6. Produce a document useful for both engineering build and future design review

---

## How to work

### Core approach
1. Start with the core user outcome — what does the user accomplish, and how does the system confirm it?
2. Use `user-flow.md` as the behavioral backbone — every flow step becomes a documented behavior.
3. Translate design decisions into implementation guidance. Explain intent, not just appearance.
4. Separate confirmed requirements from assumptions. Label assumptions explicitly.
5. Do not invent backend behavior or technical architecture without evidence from PRD research or Eng input.
6. Prefer clarity over completeness theater — a focused handoff is more useful than an exhaustive one that engineers ignore.

### State coverage requirements
Every handoff must document all of these for each screen or component:
- **Default / loaded state** — what the user sees on arrival
- **Loading / async state** — spinner, skeleton, or progress indicator; duration expectations if known
- **Empty state** — what appears when there is no data; must include an action or explanation
- **Error state** — what the user sees when something fails; must include recovery path
- **Disabled state** — for all RBAC-gated actions; must include tooltip copy explaining why
- **Success / confirmation state** — how completion is communicated
- **Destructive / irreversible action state** — confirmation modal required; copy must explain consequences
- **Partial success state** — for bulk actions or async operations that may partially fail

### Dune-specific implementation notes

**Simulation and campaign features**
- Wizard steps: each step is a discrete route. Back navigation preserves form state — document which fields persist and which reset.
- Affected user preview is required before launch. Specify: what data is shown, how it is fetched, what the empty/loading/error states look like.
- Debrief landing page: document the URL pattern, trigger condition, and required content elements.
- Cooldown warning: specify the condition (time since last simulation on this group), where it appears in the flow (before the confirm step, not after), and whether it blocks or warns.

**Agent and automation features**
- Trigger logic: document the exact condition in plain language, not code. Engineers must implement what the UI describes.
- Bootstrap behavior: specify whether the agent evaluates existing group members on first activation, and what happens if it does.
- Snapshot-diff cadence: document the check schedule, how the UI reflects it (e.g., "Last checked: X"), and what the user sees during a pending check.
- Async failure states: every agent action that can fail silently must have a visible failure state. Document the failure surface — toast, banner, status badge — and the recovery action.

**Risk scoring features**
- Badge spec: color token (`color/risk/critical`, `color/risk/high`, `color/risk/medium`, `color/risk/low`) + numeric value + label. All three required. Document the threshold ranges.
- Score context: what drives the score must be surfaced on the same screen as the score. Document the data source and refresh cadence.
- Delta display: before/after values when a score changes. Document the trigger condition and visual treatment.

**RBAC and permission-gated features**
- For every privileged action: document the permission required, the disabled state appearance, and the exact tooltip copy.
- List all roles that can and cannot perform each action. Do not leave permission logic implicit.
- If RBAC questions are unresolved in `open-questions.md`, surface them as blocking open questions in the handoff — do not guess.

**Learner-facing features**
- All copy must be in plain English — no security jargon. Document copy strings directly in the handoff.
- Module completion must be achievable in one focused session. Document session persistence behavior: what happens if the user closes mid-module?
- Failure states (clicked phishing link, failed quiz): document the debrief content, tone requirements (learning moment, not punishment), and next-step action.

### Design system references
Reference Stillsuit DS v2 components by name in implementation notes. For each component used:
- Name the component and variant (e.g., `Button / Primary / md`)
- Note any instance property overrides
- Flag any component used outside its intended scope — this requires DS review before build

Do not describe visual properties (color, font size, spacing) that are already encoded in the DS token system. Reference the token name instead.

---

## Persistence

### When to write
After the full handoff is complete. Resolve slug ambiguity before writing anything.

### Where to write
knowledge/features/<feature-slug>/
Create the folder if it doesn't exist. Never use suffixes like `-v2`, `-new`, or `-final`.

### How to update existing files
If handoff files already exist:
- Read before overwriting
- Preserve prior acceptance criteria if still valid — mark updated criteria clearly
- Move resolved open questions to a `## Resolved` section with the answer and date
- Update `last_updated` in JSON

### Downstream consumers
- `dev-handoff.md` — the primary document engineers read during build; also used in design review retrospectives
- `dev-handoff.json` — read by future skills to load implementation context; keep values factual and terse
- Open questions in `dev-handoff.md` feed back into `open-questions.md` — keep both in sync

---

## Output files

### `dev-handoff.md`
Human-readable handoff. The build contract.

Sections:
- **Feature summary** — one paragraph: goal, primary user, trigger, success metric
- **Scope** — explicit in-scope and out-of-scope list for v1
- **Flow coverage** — each step from `user-flow.md`, with system behavior documented per step
- **Screen and component notes** — per screen: DS components used (with variant), instance overrides, layout notes
- **Interaction details** — hover, focus, click, drag, keyboard, async trigger behaviors
- **States and edge cases** — full state matrix per screen; every case from `edge-cases.md` addressed
- **RBAC and permissions** — role matrix: who can do what, disabled state specs, tooltip copy
- **Accessibility requirements** — specific, actionable, tied to components and interactions (not a generic checklist)
- **Analytics events** — event name, trigger condition, properties; only when instrumentation is in scope
- **Acceptance criteria** — numbered, testable, written in "Given / When / Then" format where useful
- **Open questions** — blocking questions labeled `[Blocks build]`; non-blocking labeled `[Nice to resolve]`

### `dev-handoff.json`
Machine-readable. Required keys:

```json
{
  "feature_name": "Human-readable feature name",
  "feature_slug": "kebab-case-slug",
  "summary": "One paragraph.",
  "in_scope": ["item 1", "item 2"],
  "out_of_scope": ["item 1", "item 2"],
  "flow_steps": [
    {
      "step": "Step name",
      "actor": "user | system",
      "behavior": "What happens",
      "states": ["default", "loading", "error", "empty", "disabled", "success"]
    }
  ],
  "components": [
    {
      "screen": "Screen name",
      "component": "DS component name and variant",
      "overrides": "Any instance property changes",
      "notes": "Implementation note"
    }
  ],
  "interactions": ["interaction description"],
  "rbac": [
    {
      "action": "Action name",
      "required_permission": "Permission name",
      "disabled_tooltip": "Exact tooltip copy"
    }
  ],
  "accessibility_requirements": ["requirement 1", "requirement 2"],
  "analytics_events": [
    { "event": "event_name", "trigger": "condition", "properties": ["prop1"] }
  ],
  "acceptance_criteria": ["criterion 1", "criterion 2"],
  "open_questions": [
    { "question": "Question text", "owner": "PM | Eng | Design", "blocking": true }
  ],
  "dependencies": ["dependency 1"],
  "last_updated": "YYYY-MM-DD"
}
```

---

## Review constraints
- Implementation-oriented. Do not just paraphrase the design — explain behavior and intent.
- Every state must have an explicit handling instruction. "TBD" is not acceptable in a handoff.
- Every RBAC question must be answered or labeled as blocking. Do not guess permission logic.
- Accessibility requirements must be tied to specific components and interactions — not generic statements like "ensure accessibility."
- Open questions are visible and labeled. Do not bury them in body copy.

---

## Example request
"Generate a dev handoff for `ai-spear-phishing-groups-v2` using the feature folder and current Figma frames. Focus on group targeting behavior, the affected-user preview step, cooldown warning logic, and confirm-before-launch states."

## Example output shape
Strategy + user flow from `knowledge/features/ai-spear-phishing-groups-v2/` + Figma frame inspection → per-step behavior documentation → full state matrix → RBAC role matrix → acceptance criteria → `dev-handoff.md` + `dev-handoff.json` written to `knowledge/features/ai-spear-phishing-groups-v2/`.