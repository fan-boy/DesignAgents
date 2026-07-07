# Competitor Analysis — Netskope Risk Score Integration

## Feature context
Pulled from `prd-research.json` / `prd.md`: a Full Access admin connects Netskope, configures
category weights that feed Netskope-sourced signals into Dune's blended risk score, and — following
stakeholder resolution during PRD research — configures a bi-directional Share Risk Signals flow
that pushes Dune-derived signals back into Netskope's User Confidence Index (UCI). This is the
second integration in the risk-signal pattern Dune established with CrowdStrike
(`knowledge/features/crowdstrike-integration/`), and the first that includes write-back.

## Competitors reviewed
- **Living Security** (primary, direct) — confidence: high for architecture and partnership facts
  (drawn from Living Security's own product pages, support docs, and press materials), medium for
  exact UI layout (no direct product screenshots captured; descriptions are based on documented
  feature copy, not observed interaction).
- Prior CrowdStrike-side competitor findings (KnowBe4/SecurityCoach, Right-Hand Cybersecurity) are
  already covered in `crowdstrike-integration/competitor-analysis.md` and not repeated here except
  where the Netskope-specific dynamic differs materially (see Differentiation Opportunities).

Living Security is the only competitor found with a live, named, bi-directional Netskope
integration — no other platform in Dune's registry (KnowBe4, Hoxhunt, CybSafe, SoSafe, Proofpoint,
Mimecast) has a documented Netskope relationship of any kind. This makes it the single most
relevant piece of prior art for this specific feature, materially more relevant than the general
SAT competitor set.

## Workflow comparison

| Stage | Living Security (Unify) | Dune (per current PRD) |
|---|---|---|
| Data ingestion model | Generalized ingestion architecture across 9+ categories (Email, Endpoint, Web, IAM, HR/Change, SIEM, UEBA/DLP, Training/LMS) with 20+ named prebuilt integrations plus a custom push API | Purpose-built, per-vendor integration (CrowdStrike, then Netskope); no generalized framework yet, though both integrations' technical research independently raised this as an open question |
| Composite score model | Single Human Risk Index (HRI), 0-1000, explicitly composed of three named dimensions: Behavior, Threat, Identity | Single blended risk score combining training/simulation, CrowdStrike categories, and (pending) Netskope categories, without named top-level dimensions — categories are flatter and more numerous (11+ across both integrations) rather than grouped into 3 named dimensions |
| Score visibility | Dashboards at organization, segment, department, and individual level; separate Manager Scorecards (role-based, team-level) via a Human Risk Operations Center (HROC) | Individual risk score detail view only, per current PRD scope; no described manager/team rollup view or org-level dashboard for the Netskope contribution specifically |
| Netskope relationship | Named, bi-directional, productized partnership: Living Security's human signals (phishing susceptibility, credential hygiene, DLP violations) write into Netskope's UCI; Netskope's enforcement acts on the resulting score. Publicly marketed as a joint solution brief, not just a technical integration. | Also bi-directional per the resolved PRD (Share Risk Signals with Netskope flow), but scoped as one of several integrations rather than a marketed joint solution; no public-facing partnership positioning implied by the PRD |
| Weighting configurability | Not publicly documented whether admins can adjust per-source weighting within the HRI; marketing materials describe the score as computed, not admin-tunable | Explicitly admin-configurable per category via weight sliders (0-100%), a stated differentiator already named in the CrowdStrike technical research |
| Write-back scope | Specific and narrow: named human risk signal types (phishing susceptibility, credential hygiene, DLP violations) feed Netskope's UCI for access-control enforcement purposes | Per the resolved PRD: Training Overdue Status, Simulation Failure Events, and Overall Dune Risk Tier — a comparable scope and shape, independently arrived at |
| Overlap/double-counting handling | Not documented; Living Security's architecture treats HRI as the canonical score and Netskope's UCI as a downstream enforcement consumer, which avoids Dune's specific problem (Behavior Confidence reading Netskope's UCI back into the same score that fed it) because Living Security does not appear to re-ingest UCI as an HRI input at all | Dune's PRD explicitly identifies and hard-blocks this circular case (Behavior Confidence + Share Risk Signals) — a problem Living Security's simpler one-directional-per-score-purpose model may not need to solve |

## Patterns worth adopting

- **Named score dimensions.** Living Security groups its many integration sources into three named
  dimensions (Behavior, Threat, Identity) rather than a flat list of category weights. As Dune adds
  a second and eventually third risk-signal integration, a flat list of 11+ category rows across
  two settings pages is starting to lose the clarity a named-dimension grouping would provide.
  Worth raising to `design-strategist` as a structural question, not just a copy change.
- **Role-based rollup views (Manager Scorecards).** Living Security's HROC gives managers a
  team-level view distinct from the individual risk score detail view. Dune's current PRD scope for
  both CrowdStrike and Netskope is individual-only; if Dune has any pending manager-facing
  reporting features (see AEP Manager role in RBAC), this is a natural point to eventually connect
  the new signal sources to an existing or future rollup view rather than keeping Netskope/CrowdStrike
  data siloed to the single-user breakdown.
- **Treating write-back as a downstream consumer, not a re-ingested loop.** Living Security's
  apparent architecture (HRI computed once, then exported to Netskope's UCI for enforcement, without
  reading UCI back into HRI) sidesteps the circular-dependency problem Dune had to explicitly design
  around. This is worth confirming as an explicit architectural principle in Dune's own docs: Share
  Risk Signals should be framed as "export a computed result," not "sync bidirectionally," to keep
  the mental model clean even though the net effect (data flows both directions) looks similar from
  the outside.

## Anti-patterns to avoid

- **Marketing the partnership ahead of the admin-facing configurability.** Living Security's public
  materials describe the Netskope relationship in outcome language ("adapts access controls to
  human, identity, and AI-driven risk") without disclosing whether admins can tune it. If Dune ships
  write-back with the same opacity, it forfeits the differentiation already established for the
  ingestion side (transparent, admin-visible weighting) named in the CrowdStrike technical research.
  The Share Risk Signals flow's per-signal-type toggles (already in the PRD) are the right instinct —
  don't let a future marketing push describe this as a black-box "adaptive" partnership without the
  same transparency framing used elsewhere in the product.
- **Flat, ungrouped category lists at scale.** Nothing observed in Living Security's public
  materials suggests a flat per-vendor category list; grouping into 3 dimensions appears deliberate.
  Dune's current two-integration category list (6 CrowdStrike + 7 Netskope = 13 rows across two
  settings pages) is already at the edge of where a flat list stays scannable — a third integration
  would likely tip it over.

## Differentiation opportunities

- **Admin-visible weighting remains a real, defensible gap.** As in the CrowdStrike case, no
  competitor found — including Living Security — publicly documents a granular, admin-tunable
  weighting UI for how much any single external signal source moves the score. This is now
  confirmed true across both CrowdStrike-adjacent and Netskope-adjacent competitive research, not
  just a CrowdStrike-specific claim, and is worth stating more confidently in `design-strategy.md`.
- **Living Security ships write-back today; no CrowdStrike-side competitor found one.** This is a
  meaningful asymmetry between the two integrations' competitive landscapes: the CrowdStrike
  research found no competitor with a bi-directional CrowdStrike integration (KnowBe4's
  SecurityCoach and Right-Hand Cybersecurity are both consume-only patterns), while Netskope has a
  live, shipped, bi-directional competitor precedent. This changes the competitive framing for the
  two features — CrowdStrike's write-back (if ever built) would be a novel differentiator, while
  Netskope's write-back is closing a gap that already exists, not opening one. `design-strategy.md`
  should frame these two integrations' value propositions differently rather than treating write-back
  as an equivalent opportunity in both cases.
- **A generalized signal-ingestion framework is now a two-source, two-competitor-confirmed
  pattern.** Living Security's product shape (integrate broadly, weight centrally, export
  selectively) is effectively what both CrowdStrike and Netskope technical research independently
  recommended Dune consider building. With a real competitor shipping this shape at scale, the
  open question about a generalized framework (see `open-questions.md`) has more urgency and more
  market validation than when it was raised as a purely internal architecture question.

## Implications for design

- Raise the flat-category-list scalability concern to `design-strategist` now, before a third
  integration makes restructuring more disruptive — consider whether CrowdStrike's 6 categories and
  Netskope's 7 categories could be presented under named groupings (e.g., "Endpoint & Device,"
  "Data & Access," "Identity & Behavior") rather than two entirely separate, ungrouped settings
  pages.
- Frame the Share Risk Signals flow internally and in any future customer-facing copy as "Dune
  exports a computed signal" rather than "Dune and Netskope sync scores," to avoid the circular
  framing problem and to keep the transparency differentiation intact.
- When `design-strategist` scopes the score breakdown view, consider whether a future manager/team
  rollup (distinct from the individual detail view) is worth flagging as a v2 consideration, given
  Living Security treats this as a first-class, separately named feature (HROC) rather than an
  afterthought.

## Confidence notes

- High confidence on Living Security's Netskope partnership existence, direction of data flow, and
  general HRI composition (Behavior/Threat/Identity) — drawn directly from Living Security's own
  press release, product pages, and support documentation.
- Medium confidence on exact UI/dashboard layout — described from marketing and support-doc copy,
  not from an observed live product session or screenshots. Labeled as inference where noted above
  (e.g., whether HRI weighting is admin-configurable at all is explicitly unconfirmed, not
  observed-absent).
- No pricing, contractual, or technical implementation depth was available publicly for the
  Living Security x Netskope partnership beyond the solution-brief level of detail; any deeper
  comparison (e.g., exact API mechanics of their write-back) would require a demo or sales
  conversation, not further public research.
