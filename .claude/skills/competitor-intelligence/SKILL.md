---
name: competitor-intelligence
description: >
  Research and compare how competitors solve a specific feature, workflow, or user problem.
  Use when evaluating product patterns, identifying opportunities, auditing similar experiences,
  or generating structured competitor documentation for downstream design work.
  Grounded in Dune Security's competitive landscape: SAT platforms (KnowBe4, Hoxhunt, Proofpoint,
  Cofense, Ninjio, Curricula), human risk management platforms (CybSafe, SoSafe, Mimecast), and
  adjacent products (Doppel). Always reads prd-research outputs before starting. Writes persistent
  files consumed by design-strategist, design-review, and dev-handoff skills.
---

# Competitor Intelligence

Research how competitors and adjacent products solve the same user problem as the feature being
designed or refined. Grounded in Dune Security's specific market position: a human risk management
and security awareness training platform competing on AI personalization, behavioral risk scoring,
and enterprise content production — not catalog volume.

## When to use
- Analyzing competitors before a new feature's design exploration begins
- Comparing existing product patterns to identify conventions or gaps
- Auditing workflows for differentiation opportunities
- Documenting competitive findings for design strategy, review, or handoff

## When NOT to use
- Broad market strategy or financial analysis
- Sales enablement battlecards (different output format, different audience)
- Features where Dune has no meaningful competitive overlap (e.g., internal tooling)
- Replacing direct product observation with assumption — if you can't observe it, label it

---

## Competitor registry

Use `knowledge/competitor-list.md` as the primary source. Do not research competitors outside
this list without user confirmation. Key groupings:

**Direct SAT competitors** (compare by default for training and simulation features):
- KnowBe4 — knowbe4.com — incumbent benchmark, volume-based, not adaptive
- Hoxhunt — hoxhunt.com — closest peer on "adaptive" messaging, gamification model
- Proofpoint SAT — proofpoint.com — email security-adjacent, threat-correlated training
- Cofense — cofense.com — phishing simulation specialist, reporter button focus
- Ninjio — ninjio.com — content quality benchmark, animated short-form video
- Curricula (Huntress) — huntress.com — SMB, story/humor-driven content

**Human risk management** (include when feature touches risk scoring, behavioral signals, or remediation):
- CybSafe — cybsafe.com — behavioral science framing, EMEA financial services
- SoSafe — sosafe-awareness.com — European SAT leader, GDPR-focused, growing US presence
- Mimecast — mimecast.com — email security bundle, EMEA accounts

**Adjacent / specialty** (include only when explicitly relevant):
- Doppel — doppel.com — brand protection, impersonation defense, not a training platform

### Competitor selection guidance
| Feature type | Include |
|---|---|
| Phishing / spear phishing simulation | KnowBe4, Hoxhunt, Cofense |
| Training content / module delivery | KnowBe4, Ninjio, Curricula, Hoxhunt |
| Risk scoring / behavioral signals | CybSafe, SoSafe, Hoxhunt |
| Admin workflows / scheduling / groups | KnowBe4, Hoxhunt, Proofpoint |
| Remediation / agent automation | CybSafe, SoSafe (limited) |
| Reporting / dashboards | KnowBe4, Proofpoint, CybSafe |
| White-label / client branding | Ninjio, KnowBe4 (limited) |
| EMEA / compliance-heavy context | SoSafe, CybSafe, Mimecast |

### When NOT to compare
- Against KnowBe4 on catalog size — Dune wins on quality and personalization, not volume
- Against Hoxhunt feature-for-feature — gamification vs. AI personalization are philosophically different; surface the distinction, don't flatten it
- Against Doppel on anything platform-related — different product category
- Against Proofpoint or Mimecast on UX or AI — SAT is not their primary product

---

## Inputs
- Feature name or feature slug
- Competitor scope (default to registry above; user may narrow or expand)
- PRD excerpts, URLs, or specific focus areas
- Focus dimensions (e.g., onboarding, bulk actions, trust, error handling, admin workflows, mobile, reporting)

---

## Required context lookup

Before starting research:
1. Derive or confirm the feature slug (lowercase kebab-case, same rules as `prd-research`).
2. Check for existing research at `knowledge/features/<feature-slug>/`.
3. If found, read in this order:
   - `prd-research.json` — load feature goal, user segments, constraints, risks, open questions
   - `prd-research-summary.md` — for fuller narrative context
   - `edge-cases.md` — check these against competitor flows; note which are handled and how
   - `open-questions.md` — use unresolved questions to focus the research
4. If no PRD research exists, proceed with available inputs and note the gap in confidence notes.
5. If the feature slug is ambiguous, ask before writing any files.

---

## Research goals

1. Understand how each competitor handles the specific workflow or user problem — not just whether the feature exists
2. Identify reusable patterns (conventions worth adopting or adapting)
3. Identify anti-patterns (things that look like solutions but create UX debt or trust failure)
4. Surface differentiation opportunities — especially where Dune's AI personalization, risk scoring, or remediation model creates an opening
5. Produce structured output reusable by downstream skills

---

## How to work

1. Start with the competitor registry. Select relevant competitors using the feature-type table above.
2. Focus on how the workflow actually works — entry point through completion. Not feature checklists.
3. Prefer direct observation: official product sites, documentation, help centers, product tours, changelog entries.
4. Use lower-confidence sources (G2, Capterra, screenshots, demo recordings) only when necessary. Label them.
5. Distinguish observed facts from inference. Mark inferences explicitly.
6. Do not write generic statements ("clean UI," "intuitive design") without tying them to a specific workflow step.

### For each competitor, observe and document:
- **Entry point** — how does the user get to this workflow?
- **Setup friction** — what is required before the core task can be completed?
- **Core flow steps** — what does the user actually do, step by step?
- **Navigation and IA** — where does this feature live in the product structure?
- **Feedback and states** — loading, success, error, empty, async
- **Error prevention** — what does the product do to catch mistakes before they happen?
- **Trust and risk communication** — especially relevant for simulation targeting, agent automation, and destructive actions
- **Efficiency for repeat use** — does the product get faster after the first time? Shortcuts, defaults, bulk actions?
- **RBAC and permission model** — who can do what, and how is that communicated?

### Dune-specific lenses to apply
- **AI personalization surface:** Does the competitor expose AI-driven targeting or personalization? How is it explained and controlled?
- **Risk score visibility:** Is there a behavioral risk score? How is it surfaced and acted on?
- **Admin trust model:** For simulation and agent features — how does the product communicate what will happen before it happens?
- **Remediation path:** What happens after a failure state (clicked link, failed quiz)? Is remediation automated or manual?
- **White-label / client branding:** Is it supported? How much friction does it add?

---

## Persistence

### When to write
After completing the full research pass — not incrementally. Resolve slug ambiguity before writing anything.

### Where to write
knowledge/features/<feature-slug>/

Create the folder if it doesn't exist. Never use suffixes like `-v2`, `-new`, or `-final`.

### How to update existing files
If `competitor-analysis.md` or `competitor-analysis.json` already exist:
- Read before overwriting
- Add new competitor observations; do not replace prior ones unless directly contradicted
- Note what changed in a `## Last updated` note at the top of the markdown file
- Update `analyzed_at` in the JSON

### Downstream consumers
- `competitor-analysis.json` — read by `design-strategist`, `design-review`, and `dev-handoff` to load competitive context automatically
- `competitor-analysis.md` — used as Claude context in design critique sessions and strategy reviews
- Keep JSON values clean and factual — no commentary or hedging in field values

---

## Output files

### `competitor-analysis.md`
Human-readable. Structured for use in design reviews and strategy discussions.

Sections:
- **Feature context** — pulled from PRD research or stated inputs
- **Competitors reviewed** — which ones, why selected, confidence level
- **Workflow comparison** — step-by-step, per competitor, for the target workflow
- **Patterns worth adopting** — observed conventions that work; note which competitors use them
- **Anti-patterns to avoid** — observed patterns that create friction, trust failure, or UX debt; explain why
- **Differentiation opportunities** — where Dune's AI, risk scoring, or remediation model creates an opening
- **Implications for design** — concrete, actionable, tied to the feature being designed
- **Confidence notes** — source quality, what was inferred vs. observed, gaps

### `competitor-analysis.json`
Machine-readable. Required keys:

```json
{
  "feature_name": "Human-readable feature name",
  "feature_slug": "kebab-case-slug",
  "analyzed_at": "YYYY-MM-DD",
  "direct_competitors": ["competitor names"],
  "adjacent_competitors": ["competitor names"],
  "workflow_stages": ["stage 1", "stage 2"],
  "competitors": [
    {
      "name": "Competitor name",
      "url": "url",
      "tier": "direct | adjacent",
      "entry_point": "how user reaches the workflow",
      "setup_friction": "what is required before core task",
      "core_flow": ["step 1", "step 2"],
      "feedback_states": ["observed states"],
      "error_prevention": "what the product does",
      "trust_model": "how risk/impact is communicated",
      "rbac_notes": "permission model observations",
      "repeat_use_efficiency": "shortcuts, defaults, bulk actions",
      "ai_personalization": "observed or absent",
      "risk_score_surface": "observed or absent",
      "remediation_path": "observed or absent",
      "confidence": "high | medium | low",
      "source_notes": "what was observed vs. inferred"
    }
  ],
  "observed_patterns": ["pattern 1", "pattern 2"],
  "anti_patterns": ["anti-pattern 1"],
  "differentiation_opportunities": ["opportunity 1"],
  "design_implications": ["implication 1"],
  "confidence_notes": ["note 1"]
}
```

---

## Review constraints
- Evidence-based. Fewer, stronger observations over broad shallow coverage.
- Recommendations must be relevant to the specific feature being designed.
- Do not prescribe final UI unless explicitly asked.
- Label all inferences. Do not present G2 reviews or demo screenshots as ground truth.
- Do not compare Dune against competitors on dimensions where the comparison concedes Dune's positioning (see "When NOT to compare" above).

---

## Example request
"Analyze how competitors handle bulk user targeting for phishing simulations. Focus on group selection, exclusion logic, admin trust, and error prevention before launch."

## Example output shape
Feature context pulled from `prd-research.json` → competitor selection from registry table → per-competitor workflow breakdown → patterns / anti-patterns / opportunities → `competitor-analysis.md` + `competitor-analysis.json` written to `knowledge/features/<feature-slug>/`.