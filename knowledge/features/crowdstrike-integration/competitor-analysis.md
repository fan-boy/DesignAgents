# Competitor Analysis — CrowdStrike Risk Score Integration

## Feature context

A Full Access admin connects CrowdStrike Falcon, and CrowdStrike signals (identity risk, device
posture, detections, vulnerabilities, account hygiene, and a new "No Endpoint Visibility" flag for
users with zero CrowdStrike coverage) become admin-weighted inputs blended into a user's overall
Dune risk score. Pulled from `prd.md` and `prd-research-summary.md`. Two workflow questions this
research targets: (1) does any registry competitor let admins weight what feeds a human risk
score, and (2) does any registry competitor ingest third-party EDR/identity signals into that
score, versus using them only as a training-delivery trigger.

## Competitors reviewed

Per `knowledge/competitor-list.md`, scoped to the "risk scoring / behavioral signals" row:
**CybSafe** and **SoSafe** (direct — human risk platforms with published risk-scoring mechanics),
**Hoxhunt** (direct — checked for EDR-triggered behavior nudges). **KnowBe4** is referenced once,
narrowly, for its published CrowdStrike integration architecture only — per the registry's explicit
"when NOT to compare" guidance, this is not a benchmark of KnowBe4's risk-scoring quality or
catalog, only a comparison of integration pattern (trigger vs. score-blend). Confidence is
medium for CybSafe (a detailed admin help article was available), low-medium for SoSafe and
Hoxhunt (marketing/product-release pages only, no admin documentation found), low for the KnowBe4
reference (press release only, no technical documentation).

## Workflow comparison

**CybSafe — Risk Quantification Impact Settings** (medium confidence, CybSafe Help Center)
- Entry point: an admin-only settings screen scoped to risk quantification, not the main dashboard.
- Core flow: three impact factors (Expected Monetary Loss, Expected Level of Effort, Expected Level
  of Disruption), each set via a slider *or* a text box, values 1–4. The three values multiply
  together (1×1×1 to 4×4×4) into a combined score mapped to a category (Minor/Moderate/Major/Extreme).
- Save behavior: a single "Apply" action immediately recalculates the risk outcome score
  retroactively.
- Notable detail: CybSafe explicitly decouples this retroactive recalculation from historical trend
  visualizations — admins can "change the impact settings as much as you want without making peaks
  and dips in the risk scores over time charts." This is a deliberate design choice to prevent
  admin tuning from corrupting the read of historical trend data.
- This is the closest published analog to Dune's proposed weight-slider UI, though CybSafe is
  weighting *consequence* factors (cost/effort/disruption of a risk outcome), not third-party
  telemetry categories. No evidence CybSafe ingests EDR/device data into this calculation.

**SoSafe — Human Risk OS™ / Human Security Index** (low-medium confidence, product marketing pages)
- Positions itself explicitly around "combining telemetry from your existing tools" with SoSafe's
  own behavioral data, and integrates with Okta, Microsoft Entra, and Google Workspace — but the
  published integration purpose is user provisioning and targeted-training automation, not EDR
  signal ingestion into the risk score itself.
- The Human Security Index score incorporates contextual modifiers — seniority, tenure, digital
  access level, functional criticality — as risk-relevant context, not just raw behavioral
  telemetry. No admin-facing weighting UI was found in public documentation.
- No evidence of a CrowdStrike or comparable EDR integration for score computation.

**Hoxhunt** (low confidence, marketing pages only)
- Describes signal flow into SOC workflows and behavior-based nudges "triggered from tools like
  Microsoft Defender" — a trigger pattern, not a score-weighting pattern. No admin risk-weighting
  UI or EDR-to-score blending found in available material.

**KnowBe4 × CrowdStrike (SecurityCoach)** — referenced narrowly, not benchmarked (low confidence,
press release only)
- Architecture pattern only: CrowdStrike detects a security event on a user's device; KnowBe4
  delivers real-time coaching content to that user in response. This is a "detect and immediately
  intervene" pattern, distinct in kind from a "detect, weight, and blend into a persistent score"
  pattern. Worth naming as a different category of response Dune could add later (a real-time
  coaching trigger off the same CrowdStrike signals), but not a substitute for the weighted-score
  approach this feature specifies.

## Patterns worth adopting

- **Decouple retroactive recompute from historical trend integrity (CybSafe).** When an admin
  changes weights, apply the new weighted score going forward without silently rewriting the
  historical trend line the admin and end users already saw. This directly addresses the "score
  volatility undermines trust" design risk flagged in `prd-research-summary.md` — admins should be
  able to tune weights without making the org's risk trend chart look erratic in hindsight.
- **Dual slider + numeric text input (CybSafe).** Every weight control should offer a precise
  numeric entry alongside the slider, not the slider alone — also closes the accessibility gap
  flagged in `edge-cases.md` about keyboard-only weight configuration.
- **Contextual risk modifiers, not just raw signal (SoSafe, CybSafe).** Both competitors adjust
  risk treatment based on who the person is (role, seniority, access level, criticality) rather
  than applying identical weighting to every user. This is a pattern to consider for a later
  iteration (e.g., a privileged-access user's Device Posture category might reasonably carry more
  weight than a standard employee's) — not required for v1, but worth flagging as a natural
  extension of the weighting model already being built.

## Anti-patterns to avoid

- **Trigger-only patterns (KnowBe4, Hoxhunt) treated as a substitute for a real score input.**
  Neither competitor's EDR-adjacent feature actually changes a persistent, weighted risk score —
  they fire a point-in-time training action. If Dune's CrowdStrike data only ever triggered
  training rather than genuinely composing the score, it would undercut this feature's stated
  purpose (letting admins weight how much CrowdStrike affects risk score) and reduce it to a
  notification feature wearing a scoring feature's PRD.
- **No competitor publishes what "combining telemetry" actually means mathematically.** SoSafe's
  marketing language ("combine telemetry from your existing tools") is the same kind of opaque
  framing flagged as a competitive gap in the technical research brief for Right-Hand
  Cybersecurity. Avoid shipping a weighting UI that implies precision (sliders, percentages)
  without a documented, admin-visible explanation of what the resulting number actually means —
  this was already surfaced as a normalization gap in `prd-research-summary.md` and this
  competitive scan reinforces that no competitor has solved it publicly either.

## Differentiation opportunities

- **No registry competitor exposes a documented, admin-tunable weighting model for third-party
  security-signal categories feeding a human risk score.** CybSafe's impact settings are the
  closest published analog, but they weight consequence factors, not external telemetry
  categories. This remains a genuine white space, consistent with the technical research brief's
  finding on Right-Hand Cybersecurity's undocumented model — Dune has room to be the first to make
  this both configurable and transparent.
- **The "No Endpoint Visibility" signal (missing coverage as its own risk-relevant category) has
  no known competitor equivalent** in the material reviewed. SoSafe and CybSafe both assume
  behavioral telemetry exists for every scored person; neither publicly addresses how they treat
  a person with no instrumented signal at all. This is a differentiated, defensible design choice
  worth naming explicitly in `design-strategy.md`, not just an internal edge case fix.

## Implications for design

- Adopt the CybSafe pattern of decoupling live weight recompute from historical trend chart
  continuity when `design-strategist` designs the risk score breakdown and any trend visualization
  affected by CrowdStrike weighting.
- Every weight control in the Configure Risk Score Weights page should pair a slider with a
  numeric input, not slider-only.
- The weighting UI copy should explain, in plain language, what a change actually does to a user's
  score (order-of-magnitude framing, not just a percentage label) — since no competitor has solved
  this transparency gap, doing it well is itself a differentiator, not just good practice.
- Consider flagging role/access-based risk modifiers (SoSafe/CybSafe pattern) as a named
  future-phase idea in `design-strategy.md`, not in scope for v1 per the PRD's current flows.

## Confidence notes

- CybSafe: medium confidence — a dedicated admin help article described concrete UI mechanics.
- SoSafe: low-medium confidence — marketing and product-release pages only; no admin-facing
  documentation of scoring mechanics or weighting controls was found.
- Hoxhunt: low confidence — marketing pages only; risk-score-to-EDR integration specifics were not
  publicly available.
- KnowBe4: low confidence, and intentionally not benchmarked on risk-scoring quality per the
  registry's "when NOT to compare" rule — referenced solely for its integration architecture
  pattern (trigger vs. score-blend).
- No live product demos, trials, or screenshots were available for direct observation; all
  findings are from public marketing and help-center pages. Treat UI mechanics described here as
  directionally reliable, not pixel-accurate.
