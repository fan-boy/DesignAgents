---
description: >
  Route a design task through the correct sequence of Claude skills for PRD writing, feature
  research, competitor analysis, strategy, and dev handoff. Grounded in Dune Security's product
  context: simulation campaigns, group targeting, risk scoring, agent automation, RBAC-gated
  admin flows, learner-facing training delivery, and the Stillsuit DS v2 design system.
---

# Feature Workflow

Orchestrates the Dune Security design workflow across the skill chain:
`prd-creator` → `prd-research` → `competitor-intelligence` → `design-strategist` → `dev-handoff`

All outputs are written to and read from `knowledge/features/<feature-slug>/`.
All skills share the same slug, the same folder, and the same file contracts.

---

## Inputs

The user may provide:
- A mode: `new-feature`, `refinement`, `audit`, or `handoff`
- A feature name or feature slug
- A PRD, feature brief, or change request
- A Figma file, frame link, or selection
- A competitor scope (defaults to Dune's registry in `knowledge/competitor-list.md`)
- URLs for live product audits
- Focus areas: onboarding, trust, mobile, accessibility, RBAC, admin workflows, edge cases,
  risk scoring, simulation targeting, agent triggers

---

## Mode rules

| Mode | When to use |
|---|---|
| `new-feature` | Shaping a new feature or major workflow from scratch |
| `refinement` | Existing screens or flows need critique, revision, or improvement |
| `audit` | Analyzing an existing product, live site, or current experience |
| `handoff` | Main goal is implementation-ready documentation for engineering |

If the mode is not explicit, infer it from the request. Confirm only if the ambiguity would
materially change which skills run.

**Dune-specific mode inference signals:**
- "PRD," "brief," "new feature," "we're building," "write a PRD," "document this" → `new-feature`
- "these screens," "Figma link," "refine," "review," "critique" → `refinement`
- "how does KnowBe4 handle," "competitor," "what does Hoxhunt do" → `audit`
- "ready for eng," "handoff," "acceptance criteria," "build doc" → `handoff`

---

## Feature slug handling

1. Derive from the feature name using lowercase kebab-case:
   - "AI Spear Phishing for Groups v2" → `ai-spear-phishing-groups-v2`
   - "Remediation Agent — New User Trigger" → `remediation-agent-new-user-trigger`
   - "Custom Training Modules" → `custom-training-modules`
2. Check for an existing folder at `knowledge/features/<feature-slug>/`.
3. Note which files already exist before running any skill.
4. If the slug or feature scope is ambiguous, ask before writing files.
5. Never create duplicate filenames with suffixes like `-v2`, `-new`, or `-final`.

---

## Required pre-check

Before routing to any skill:
1. Inspect `knowledge/features/<feature-slug>/` if it exists.
2. List which files are present.
3. Reuse and update existing files instead of replacing them.
4. Load `knowledge/competitor-list.md` for any run that includes `competitor-intelligence`.

**File presence logic:**

| File present | Implication |
|---|---|
| None | Full run required for selected mode |
| `prd.md` / `prd.json` exists | Skip `prd-creator` or update if source material has changed |
| `prd-research.json` exists | Skip `prd-research` or update if PRD has changed |
| `competitor-analysis.json` exists | Skip `competitor-intelligence` or update if scope changed |
| `design-strategy.json` exists | Skip `design-strategist` or refine if strategy has changed |
| `dev-handoff.json` exists | Update handoff with new findings; do not replace |

**Cross-skill file reading:**
Every skill reads all files present in the feature folder before running. The reading order is:
`prd.json` → `prd-research.json` → `competitor-analysis.json` → `design-strategy.json` →
`edge-cases.md` → `open-questions.md`

This ensures each skill builds on prior work rather than starting cold.

---

## Routing logic

### Mode: `new-feature`

Run in order:
1. **`prd-creator`** — if a Figma link or feature doc is provided, write `prd.md` and `prd.json`
   first. This is the authoritative source for all downstream skills.
2. **`prd-research`** — critique the PRD, extract core frame, identify gaps, edge cases, and questions
3. **`competitor-intelligence`** — research relevant competitors from Dune's registry; focus on
   the specific workflow
4. **`design-strategist`** — synthesize research into recommended strategy, wireframe plan, and
   user flow

**Dune defaults:**
- `prd-creator` runs first whenever Figma or a feature doc is provided — do not skip it
- Competitor selection defaults to the feature-type table in `competitor-intelligence`
- Strategy output must reference Stillsuit DS v2 patterns by name
- If the feature touches simulation targeting, agent triggers, or RBAC: flag Dune-specific
  constraints before the strategy is finalized

**Expected outputs in `knowledge/features/<feature-slug>/`:**
`prd.md`, `prd.json`,
`prd-research-summary.md`, `prd-research.json`, `open-questions.md`, `edge-cases.md`,
`competitor-analysis.md`, `competitor-analysis.json`,
`design-strategy.md`, `design-strategy.json`, `user-flow.md`, `user-flow.mmd`

---

### Mode: `refinement`

Run in order:
1. **`prd-creator`** — re-run if Figma has changed materially or new source docs are provided;
   skip if `prd.md` is current
2. **`prd-research`** — re-read or update for scope changes; skip if `prd-research.json` is current
3. **`design-strategist`** — refine strategy or flow based on new inputs or Figma context
4. **`dev-handoff`** — generate or update the implementation doc

**Dune defaults:**
- If Figma context is available, use it to identify which screens exist, what states are covered,
  and what is missing
- Check `open-questions.md` — resolved questions get marked and incorporated
- If the refinement changes the user flow materially, update `user-flow.md` and `user-flow.mmd`
  before handoff

**Expected outputs:** Updated `prd.md/json` (if source changed), updated `prd-research.json`,
updated `design-strategy.md/json`, updated `user-flow.md/mmd`, `dev-handoff.md`, `dev-handoff.json`

---

### Mode: `audit`

| Audit focus | Skill to run |
|---|---|
| How competitors handle a workflow | `competitor-intelligence` |
| Critique of an existing Dune design or live UI | `design-strategist` (strategy diff) |
| Both | `competitor-intelligence` → `design-strategist` |

**Dune defaults:**
- Competitor audit defaults to Dune's registry — do not research outside `knowledge/competitor-list.md`
  without user confirmation
- Apply "when NOT to compare" rules: no KnowBe4 catalog benchmarking, no Hoxhunt feature-for-feature,
  no Doppel platform comparisons
- Live UI audits of Dune's own product reference Stillsuit DS v2 and `knowledge/heuristics.md`
- Audit outputs focus on existing experience, not feature invention

---

### Mode: `handoff`

Run: **`dev-handoff`**

**Before running:**
- Read all existing feature files in this order:
  `prd.json` → `prd-research.json` → `competitor-analysis.json` → `design-strategy.json` →
  `edge-cases.md` → `open-questions.md`
- Inspect Figma context if available
- If `prd.md` is missing, recommend running `prd-creator` first
- If the feature folder is missing critical files, pause and recommend `new-feature` mode first

**Dune defaults:**
- Every RBAC question in `open-questions.md` must be answered or labeled `[Blocks build]`
- Every state in `edge-cases.md` must appear in the handoff state matrix
- Risk score badges require: color token + numeric value + label + threshold range
- Agent features require: trigger condition in plain language, bootstrap behavior,
  snapshot-diff cadence, async failure surface

**Expected outputs:** `dev-handoff.md`, `dev-handoff.json`, updated `open-questions.md`

---

## Orchestration rules

- Run skills sequentially. Do not attempt all stages at once.
- `prd-creator` always runs before `prd-research` when source material is present — the PRD is the
  foundation the research skill critiques.
- After each skill, check whether the next stage has sufficient context to proceed.
- If a critical ambiguity appears mid-run, pause and ask a single focused question.
- Preserve all existing files. Update carefully; do not replace unless content is directly contradicted.
- If a skill cannot run because a prerequisite file is missing, say so and recommend what to run first.
- If any feature touches simulation targeting, RBAC, or agent triggers: surface relevant constraints
  at the start of the run, not mid-skill.
- If open questions from `prd-research` would change the strategy materially, pause before running
  `design-strategist`.
- Competitor scope is always confirmed against `knowledge/competitor-list.md`.

---

## Final response format

Always end every workflow run with:

### Workflow mode
Which mode was used and why (or how it was inferred).

### Skills run
Ordered list of skills executed in this run.

### Files created or updated
Full list of files written or modified in `knowledge/features/<feature-slug>/`, with one-line
notes on what changed.

### Gaps or blockers
Anything that prevented a fuller result — missing context, unresolved RBAC questions, absent
Figma frames, ambiguous scope.

### Recommended next action
The single best next step for the designer — which skill to run next, what input to provide,
or which open question to resolve first.