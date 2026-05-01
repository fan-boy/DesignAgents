---
name: design-strategist
description: >
  Synthesize PRD research and competitor intelligence into design direction, user flows, low-fi
  wireframe plans, and feature strategy. Use when shaping a new feature, refining a concept, or
  defining the structure of a workflow before detailed UI design begins. Grounded in Dune Security's
  product context: simulation campaigns, group targeting, risk scoring, agent automation, scheduler
  exclusions, RBAC-gated admin flows, and the Stillsuit DS v2 design system. Reads all available
  feature knowledge before generating strategy. Writes persistent files consumed by design-review
  and dev-handoff skills.
---

# Design Strategist

Converts feature research into clear design strategy. Responsible for defining the recommended
approach, core workflow, decision points, edge cases, and low-fi wireframe structure — before
any screen design begins.

Grounded in Dune Security's product model: enterprise security admins configuring AI-driven
simulations, behavioral risk scoring, and automated remediation for employee learners across
financial services, healthcare, and enterprise verticals.

## When to use
- Turning PRD research into a concrete feature direction
- Synthesizing competitor analysis into actionable design choices
- Creating user flows before designing screens
- Outlining low-fi wireframe structure across a feature
- Deciding between two or more workflow approaches
- Onboarding to a feature area and need a structural read before opening Figma

## When NOT to use
- Final visual design polish or pixel-level decisions
- Design QA on shipped features
- Copy editing or microcopy refinement
- Features with no research context and no inputs — run `prd-research` first

---

## Required context lookup

Before generating strategy:
1. Derive or confirm the feature slug (lowercase kebab-case, same rules as `prd-research`).
2. Read from `knowledge/features/<feature-slug>/` in this order:
   - `prd-research.json` — feature goal, user segments, constraints, gaps, open questions
   - `prd-research-summary.md` — fuller narrative context
   - `edge-cases.md` — states the strategy must account for
   - `open-questions.md` — unresolved questions that may constrain strategy options
   - `competitor-analysis.json` — patterns worth adopting, anti-patterns, differentiation opportunities
   - `competitor-analysis.md` — richer workflow context from competitor research
3. If no research exists, proceed with available inputs and flag the gap explicitly in the strategy.
4. If feature scope is unclear or slug is ambiguous, ask before writing files.

---

## Inputs
- Feature name or feature slug
- PRD excerpts or brief
- Existing flows or Figma file links
- Specific constraints (technical, timeline, RBAC, dependencies)
- A request for a new flow, revised flow, or directional recommendation

---

## Strategy goals

1. Define the best user-centered approach for the feature
2. Produce a clear, complete user flow — happy path, branches, failure cases
3. Outline low-fi wireframe structure screen by screen
4. Make the reasoning and tradeoffs explicit and reusable by downstream skills

---

## How to work

### Core approach
1. Start from the user job and completion goal — what does the user need to accomplish and how do they know they succeeded?
2. Separate must-have flow steps from optional enhancements. V1 scope is a design constraint, not a failure.
3. Use competitor insights for inspiration, not imitation. Note where Dune's model creates a meaningful departure.
4. Prefer the simplest flow that preserves clarity and trust. Complexity must earn its place.
5. When strategy is genuinely ambiguous, propose 2–3 options and recommend one with explicit reasoning.

### Flow coverage requirements
Every strategy must address:
- **Happy path** — the ideal end-to-end flow
- **Decision points** — places where user intent or system state branches the flow
- **Edge cases** — pulled from `edge-cases.md`; address each or explicitly defer with a note
- **System states** — loading, async, empty, error, timeout — never leave a state unaccounted for
- **Permission states** — view-only, restricted action, no access, first-time user
- **Destructive and irreversible actions** — confirmation pattern required, copy explaining consequences
- **Recovery paths** — how does the user get back on track after an error or cancelled action?

### Dune-specific strategy constraints

**Simulation and campaign features**
- Wizard pattern for multi-step configuration. Back navigation must not lose form state.
- Preview of affected users before any simulation is launched — admins must see impact before committing.
- Debrief landing page is required for any flow that results in a simulated attack reaching an employee.
- Cooldown awareness: flag if a target group was recently simulated. Surface this before the final confirm step, not after.

**Agent and automation features**
- Trigger logic must be surfaced in plain language before activation — not just in a settings label.
- Bootstrap behavior (retroactive vs. prospective) must be explicit in the activation UI.
- Silent failure is a trust failure. Any async action that can fail must have a visible failure state.
- Snapshot-diff architecture for group membership detection: design around scheduled check cadence, not real-time events.

**Risk scoring and reporting features**
- Risk scores are always shown with context: what drives the score, what action it implies.
- Score changes surface as a before/after delta, not a silent update.
- Scores in tables are always a badge (color + numeric + label) — never a raw number.

**RBAC-gated flows**
- Every privileged action has a `disabled` state with tooltip explaining why.
- Permission gaps surface at the start of a flow — not at the point of action.
- RBAC questions not resolved in PRD research are flagged as open issues before handoff. Do not guess permission logic.

**Learner-facing flows**
- Plain English only. No security jargon.
- Training module delivery is completable in one focused session.
- Failure states (clicked phishing link, failed quiz) are framed as learning moments — not punishment. Copy and flow must reinforce this.

### Design system alignment
Strategy must reference Stillsuit DS v2 patterns by name when prescribing structure:
- Multi-step configuration → **wizard pattern**
- Contextual detail without leaving the page → **drawer pattern** (right-anchored, 360px / 480px)
- Blocking decisions → **modal** (max 560px, destructive on right, cancel on left)
- Tabular data → **table pattern** with sort/filter above, empty state with CTA
- Status communication → **badge** (color + label, never color alone)

Do not invent structural patterns not in the design system without flagging it as a new pattern requiring DS review.

---

## Wireframe guidance

Low-fi structure only. No visual design decisions.

For each screen or state in the flow, specify:
- **Screen name** and its role in the flow
- **Layout region breakdown** — header, body, sidebar, footer, drawer, modal
- **Key components** — by DS component name (wizard step bar, table, drawer, modal, badge, empty state)
- **Primary action** — what the user does on this screen to advance
- **Secondary actions** — back, cancel, skip, bulk action
- **System content** — what data or state the product must surface here
- **Edge case handling** — how this screen changes for permission, empty, error, or loading states

Do not specify color, typography, spacing, or icon choices — those are resolved in Figma against the DS.

---

## Persistence

### When to write
After the full strategy is complete. Resolve slug ambiguity before writing anything.

### Where to write
knowledge/features/<feature-slug>/
Create the folder if it doesn't exist. Never use suffixes like `-v2`, `-new`, or `-final`.

### How to update existing files
If strategy files already exist:
- Read before overwriting
- Preserve prior strategy options if they are still viable — note what changed and why
- Update `last_updated` in JSON
- Append to user flow rather than replacing unless the flow has fundamentally changed

### Downstream consumers
- `design-strategy.json` — read by `design-review` and `dev-handoff` to load feature direction automatically
- `user-flow.mmd` — rendered in Figma and design docs; used as the structural reference during design critique
- `user-flow.md` — used as Claude context in design review sessions
- Keep JSON values clean and factual — no commentary in field values

---

## Output files

### `design-strategy.md`
Human-readable strategy. This is what a designer reads before opening Figma.

Sections:
- **Feature context** — goal, user, trigger, success metric (from PRD research)
- **Design goal** — what the design must accomplish, in one sentence
- **Key constraints** — technical, RBAC, DS, scope
- **Strategy options** — 2–3 approaches if ambiguous; single recommendation if clear
- **Recommended strategy** — chosen approach with rationale
- **Risks and tradeoffs** — what the recommended strategy gives up
- **Wireframe plan** — screen-by-screen low-fi structure
- **Open issues** — unresolved questions that would change the strategy if answered
- **Next design actions** — concrete first steps for the designer

### `design-strategy.json`
Machine-readable. Required keys:

```json
{
  "feature_name": "Human-readable feature name",
  "feature_slug": "kebab-case-slug",
  "design_goal": "One sentence.",
  "user_segments": ["primary", "secondary"],
  "constraints": ["constraint 1", "constraint 2"],
  "selected_strategy": "Name of the chosen approach",
  "selected_strategy_rationale": "Why this approach was chosen",
  "alternative_strategies": [
    { "name": "Option name", "summary": "Brief description", "rejected_because": "Reason" }
  ],
  "tradeoffs": ["what the selected strategy gives up"],
  "assumptions": ["assumption 1"],
  "open_issues": ["unresolved question that would change strategy"],
  "risks": ["risk 1"],
  "ds_patterns_used": ["wizard", "drawer", "modal", "table", "badge"],
  "new_patterns_required": ["pattern not in DS — requires DS review"],
  "next_actions": ["action 1", "action 2"],
  "last_updated": "YYYY-MM-DD"
}
```

### `user-flow.md`
Human-readable flow. Structured for use in design critique and PM review.

Sections:
- **Entry points** — how the user reaches this flow
- **Happy path** — numbered steps, plain language
- **Decision points** — branch conditions and outcomes
- **System responses** — what the product does at each async or conditional step
- **Edge cases** — how each case from `edge-cases.md` is handled in the flow
- **Exit states** — success, cancellation, error, timeout

### `user-flow.mmd`
Mermaid flowchart of the user flow. Must match `user-flow.md` exactly.

Format:
flowchart TD
A[Entry point] --> B{Decision?}
B -- Yes --> C[Step]
B -- No --> D[Error state]
C --> E[Success]
---

## Review constraints
- Concrete and specific. Vague flow steps ("user completes form") are not acceptable.
- Do not jump to high-fidelity UI details — that's Figma's job.
- Do not invent DS patterns without flagging them for DS review.
- Make recommendations actionable for a product designer working in Figma with Stillsuit DS v2.
- Call out every unresolved RBAC question. Do not guess permission logic.

---

## Example request
"Use the existing feature research for `ai-spear-phishing-groups-v2` to propose the best design strategy, outline the wizard flow, and create a user flow covering the happy path, group targeting edge cases, and the confirm-before-launch step."

## Example output shape
Feature context from `prd-research.json` + competitor patterns from `competitor-analysis.json` → strategy options evaluated → recommended approach selected → screen-by-screen wireframe plan → `design-strategy.md` + `design-strategy.json` + `user-flow.md` + `user-flow.mmd` written to `knowledge/features/ai-spear-phishing-groups-v2/`.