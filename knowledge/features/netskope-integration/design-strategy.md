# Design Strategy — Netskope Risk Score Integration

## Feature context

A Full Access admin connects their organization's Netskope tenant so that Netskope signals
(Behavior Confidence, Data Loss Risk, Threat Exposure, Compromised Credentials, Shadow IT & App
Risk, Enforcement & Watchlist Activity, and a coverage signal called No Netskope Visibility) become
admin-weighted inputs blended into a user's existing Dune risk score — the same pattern established
by the CrowdStrike integration, now with a second vendor. Following stakeholder resolution during
PRD research, this feature also includes bi-directional write-back: the admin can configure Dune to
push Training Overdue Status, Simulation Failure Events, and Overall Dune Risk Tier back into
Netskope's User Confidence Index, a flow shape (outbound signal configuration) that has no existing
precedent in Dune's product. No success metric exists yet in source material, matching the same gap
in the CrowdStrike strategy. The primary user is a Full Access admin; the secondary,
indirectly-affected user is the end learner whose score may move as a result of admin configuration
they never see directly, and whose Dune-derived data may now also influence a third-party system's
access enforcement.

## Design goal

Let an admin connect Netskope, tune its influence on risk score, and optionally share Dune's own
risk signals outward — all with full visibility into what each control does and what it affects —
without making the two-vendor category list feel cluttered, without letting the write-back flow
read as a silent or opaque data export, and without ever making an employee's score feel arbitrary,
punitive, or explained by something they can't act on.

## Key constraints

- RBAC: Full Access admin only, confirmed with stakeholder — not to be redesigned as a scoped
  permission, matching the CrowdStrike precedent exactly.
- Netskope licensing varies per client tenant, but the base SSE tier already covers 5 of 7
  categories — the UI must render correctly whether 1 or 7 categories are available, and this
  integration will show a fuller panel to more clients than CrowdStrike does. Do not design for a
  worst-case-sparse panel as the default expectation.
- Netskope's connect credential model is a single API token (no OAuth2 client secret, no region
  selector) — the Connect wizard's Step 1 must not be a copy-pasted CrowdStrike form with unused
  fields removed; it should read as intentionally simpler.
- Write-back requires the same token to carry write scope, detected in Step 2 alongside read-scope
  capability detection. The UI must clearly distinguish "this category isn't licensed" from "this
  category isn't available because the token lacks write scope" — these are different admin actions
  to resolve (upgrade license vs. reissue token) and must not share one generic disabled state.
- Behavior Confidence and Share Risk Signals cannot both be active — this is a hard block per
  `prd.md`, not a soft warning like the general Behavior Confidence / granular-category overlap.
  The UI must make the causal relationship (enabling one disables the other) visible at the moment
  it happens, not just documented in a settings description.
- Sync and push both happen on the same scheduled cadence, not real-time — matching the CrowdStrike
  precedent; the UI must never imply an instant update in either direction.
- `competitor-analysis.md` flags that Dune's combined category list across CrowdStrike (6 rows) and
  Netskope (7 rows) is approaching the scalability limit of a flat, ungrouped list, and that Living
  Security's product groups signals into three named dimensions instead. This strategy addresses
  Netskope's own page internally but treats cross-integration restructuring (spanning the
  CrowdStrike page too) as a follow-up action, not part of this build — see Open Issues.
- No competitor, including Living Security, publicly documents an admin-tunable weighting UI for
  external signals (`competitor-analysis.md`) — same as the CrowdStrike case, there's no existing
  convention to defer to for the weighting UI. For the Share Risk Signals flow specifically, there
  is also no internal Dune precedent — this is the first outbound-signal-configuration surface in
  the product.

## Strategy options

**Option A — Treat Share Risk Signals as a mirrored twin of Configure Risk Score Weights.** Build
it as a visually identical settings page (same row layout, same toggle style) directly below or
beside the weights page, differing only in direction of data flow. Fast to build and visually
consistent, but risks the two pages being mistaken for one continuous configuration surface, which
would obscure the important distinction that one page controls *incoming* data shaping Dune's own
score, and the other controls *outgoing* data Dune no longer controls once it leaves.

**Option B — Combine weighting and sharing into a single page with a tab or section split.** One
Netskope settings page, two clearly labeled sections ("Pull from Netskope" and "Push to Netskope").
Keeps everything about the integration in one place, but the hard-block interaction (enabling Push
disables the Behavior Confidence pull row) becomes harder to notice if both live in one long
scrolling page rather than requiring the admin to visit a second page and confront the constraint
directly.

**Option C (recommended) — Two distinct pages with an explicit cross-reference at the point of
conflict.** Keep Configure Risk Score Weights and Share Risk Signals as two separate settings pages
under the same Netskope integration detail area (consistent with Option A's separation), but give
Share Risk Signals a distinct visual treatment from the weights page — different row style (toggle
list, not sliders, since push signals are on/off per type rather than weighted), a header that
names the direction explicitly ("Data Dune sends to Netskope," mirroring "Data Netskope sends to
Dune" framing on the weights page), and an inline, specific callout at the exact moment the
Behavior Confidence conflict is triggered, on both pages, rather than only in one direction.

## Recommended strategy

Option C. Sliders and toggles are structurally different controls for structurally different
decisions (how much vs. whether), so forcing Share Risk Signals into the weights page's slider
pattern (Option B) would misrepresent it as a weighting decision it isn't. Keeping the pages
separate but explicitly cross-referenced (Option C) makes the outbound nature of Share Risk Signals
legible on its own terms, directly addressing the competitor-analysis finding that Living Security's
public materials describe write-back in outcome language without disclosing configurability — Dune
should do the opposite, and a page that reads as its own deliberate decision (not a mirrored
sub-section of ingestion settings) supports that.

## Risks and tradeoffs

- Two separate pages means an admin who only visits one may not discover the other exists;
  mitigate with a status summary on the Integrations list tile itself (e.g. "Netskope · Pulling 5
  categories · Sharing 2 signals") so both directions are visible before drilling in, rather than
  relying on in-page navigation alone.
- The explicit cross-reference callout adds a small amount of extra copy and a conditional UI state
  to both pages; this is a deliberate trust investment given the stakes (write-back affects
  third-party enforcement), not scope creep — do not cut this to simplify the build.
- Deferring the cross-integration category-grouping restructuring (CrowdStrike + Netskope under
  named dimensions) means this feature ships a locally well-organized but globally still-flat
  two-integration category surface; acceptable for v1 but should be an explicit next design action,
  not a dropped thread.

## Wireframe plan

### 1. Integrations list (entry point, extends existing tile)
- **Role:** Settings > Integrations landing page; Netskope becomes a second tile alongside
  CrowdStrike, reusing the exact tile pattern already built.
- **Layout:** Same tile grid as the existing CrowdStrike entry — no new layout invented.
- **Key components:** Status **badge** (Not Connected / Connected / Connection Error / Sync
  Delayed, same states as CrowdStrike). For a connected Netskope tile specifically, a secondary
  line summarizing both directions at a glance: category count being pulled and signal count being
  pushed (e.g. "5 categories active · 2 signals shared"), addressing the two-page discoverability
  risk above.
- **Primary action:** Click tile → Connect wizard (not connected) or Integration Detail area
  (connected).
- **Edge cases:** Full Access only, same RBAC gating as CrowdStrike — tile grid not rendered for
  scoped roles.

### 2. Connect Netskope (wizard, 3 steps)
- **Role:** Credential entry, capability detection (read and write scope), cadence confirmation.
- **Layout:** Full-page **wizard pattern**, matching the CrowdStrike wizard's structure exactly —
  same step-bar component, same primary/secondary action placement.
- **Key components:**
  - Step 1: two required fields (Tenant URL, API Token — masked). Deliberately simpler-looking
    than the CrowdStrike step (no region dropdown, no client secret) rather than a padded
    3-field-equivalent layout — the visual simplicity itself communicates the credential model
    difference.
  - Step 2: capability **table**, one row per category plus a distinct final row for write-scope
    detection labeled "Share Risk Signals with Netskope," status badge values: Available /
    Unavailable — license / Unavailable — token scope. The write-scope row uses "Unavailable —
    token scope" specifically (not the same "Unavailable — license" wording used for
    Advanced UEBA), so the admin immediately knows whether the fix is a license upgrade or a token
    reissue.
  - Step 3: cadence selector (radio group, same options and default as CrowdStrike), confirm
    button.
- **Primary action:** Next / Connect & Continue on final step.
- **Secondary actions:** Back, Cancel (no confirmation needed, nothing created yet).
- **Edge cases:** Hard failure at Step 2 (bad token, invalid tenant URL, zero accessible
  categories) blocks progression, matching the CrowdStrike pattern exactly.

### 3. Configure Risk Score Weights (settings page)
- **Role:** Ongoing configuration for how Netskope affects risk score; first landing page after
  Connect wizard completes.
- **Layout:** Same settings-page-with-sticky-footer pattern as CrowdStrike's weights page, with one
  structural addition: rows are grouped under two unlabeled-but-visually-separated clusters —
  Behavior Confidence sits alone at the top (since it's a composite, potentially overlapping
  signal), then a divider, then the five granular categories, then a second divider before the
  always-present No Netskope Visibility row. This is a lightweight, page-local grouping (three
  visual clusters, not named headers) — it addresses the immediate overlap-communication need
  without attempting the full named-dimension restructuring flagged as a cross-integration
  follow-up in Open Issues.
- **Key components:**
  - One-time dismissible callout (first visit only), matching the CrowdStrike pattern.
  - Category rows: label, plain-language description, weight control (slider + paired numeric
    input, per the CrowdStrike-established pattern), sync-status indicator icon.
  - Behavior Confidence row carries a persistent (not one-time-dismissible) inline notice below it:
    "Enabling Share Risk Signals will turn this off to avoid a feedback loop — see Share Risk
    Signals." This is the first half of the Option C cross-reference; it must remain visible
    whenever Behavior Confidence is active, not just on first visit, since the conflict can be
    triggered later from the other page.
  - If Share Risk Signals is currently active, the Behavior Confidence row renders in a disabled
    state with the same explanatory copy, rather than simply being hidden — the admin should see
    that the row exists and why it's off, not wonder if it's missing.
  - Live "Estimate impact" preview panel, same on-demand pattern as CrowdStrike (not automatic
    recompute-on-slider-move).
- **Primary action:** Save.
- **Secondary actions:** Cancel/revert; Estimate impact (non-committing).
- **Edge case handling:** Same as CrowdStrike's equivalent page (weight set before data syncs,
  license downgrade collapsing a row into "No longer available," all-weights-at-0% informational
  banner) — reuse directly, do not redesign.

### 4. Share Risk Signals with Netskope (settings page — new pattern)
- **Role:** Configure which Dune-derived signals push into Netskope's UCI Impact endpoint.
- **Layout:** Settings page, structurally distinct from the weights page per the recommended
  strategy — a **toggle list**, not sliders, since each signal is binary (on/off) rather than
  weighted. Header explicitly states direction: "Data Dune sends to Netskope."
- **Key components:**
  - Master toggle at the top ("Share risk signals with Netskope") that gates the three per-signal
    toggles below it (Training Overdue Status, Simulation Failure Events, Overall Dune Risk Tier) —
    each with a one-line description of exactly what's sent, e.g. "Sends a High/Medium/Low tier,
    translated from the user's numeric Dune risk score."
  - If the connected token lacks write scope (per Step 2 detection), the entire page renders locked
    with instructions to update the token's scope and reconnect — matching the "Unavailable — token
    scope" language established in the Connect wizard.
  - When the master toggle is switched on and Behavior Confidence is currently active on the
    weights page, a **confirmation modal** interrupts before the toggle commits: plain-language
    explanation of the circular-dependency reason, stating that Behavior Confidence will be turned
    off. Primary action "Turn on Share Risk Signals" (proceeds, disables Behavior Confidence
    elsewhere), secondary "Cancel." This is the second half of the Option C cross-reference and is
    the only point in either page where this constraint is presented as an active decision rather
    than passive disabled-state copy.
  - Cadence note (read-only text, not a separate control): "Signals are shared on the same schedule
    as your Netskope sync," referencing Connect wizard Step 3's setting rather than duplicating a
    cadence selector.
- **Primary action:** Save (only enabled once the modal-driven master toggle decision, if
  triggered, has been resolved).
- **Secondary actions:** None beyond Cancel/revert unsaved changes.
- **Edge case handling:** A push failure surfaces as a page-level "Push delayed" status banner,
  visually distinct from the weights page's sync-status treatment, so an admin scanning both pages
  can tell ingestion and write-back health apart at a glance. Disabling the master toggle after
  active use surfaces a **confirmation modal** stating that Dune cannot retract data already sent to
  Netskope — this is an irreversibility warning, not a routine settings-change confirmation, and its
  copy should not be softened to match a generic "unsaved changes" pattern.

### 5. Review User Mapping (table page)
- **Role:** Resolve Netskope identities that didn't automatically match a Dune user.
- **Layout:** Same table pattern as CrowdStrike's User Mapping page — filter/segment control
  (Matched / Unmatched / No Netskope Data), table with row-action **drawer** to link.
- **Key components:** Identical structure to CrowdStrike's page. The per-row confidence caption
  used for CrowdStrike's device-login-inferred mappings does not apply here, since Netskope mapping
  resolves directly through SCIM/SSO identity — omit that caption row entirely rather than including
  an empty or always-positive version of it.
- **Edge cases:** Zero unmatched rows → positive empty state, matching CrowdStrike's pattern.

### 6. Admin risk score breakdown (extension of existing view)
- **Role:** Show Netskope's contribution within the risk score detail an admin already sees per
  user, now alongside Training, Simulation, and CrowdStrike sections.
- **Layout:** New "Netskope" source section, same pattern as the existing CrowdStrike section —
  not a new structure.
- **Key components:** Per-category sub-score **badges** using the existing risk scale, never a raw
  number. Because Netskope's native UCI scale (1-1000, lower = riskier) is inverted relative to
  Dune's convention (higher = riskier), the Behavior Confidence badge must be computed from an
  already-translated internal value — this is an explicit Eng handoff note, not a display-layer
  fix, since getting the translation direction wrong here would silently invert risk severity for
  any admin reading the score.
- **Edge case handling:** Same as CrowdStrike's breakdown extension — category not licensed omits
  the row; No Netskope Visibility renders as a distinct flag, not a blank section. If a user is
  simultaneously flagged No Endpoint Visibility (CrowdStrike) and No Netskope Visibility (Netskope),
  both sections render independently with their own flags — no combined or deduplicated messaging,
  since the two are genuinely independent facts about two different systems.

### 7. Disconnect confirmation
- **Role:** Confirm intent to disconnect Netskope.
- **Layout:** **Modal**, same pattern as CrowdStrike's disconnect modal.
- **Key components:** Explanatory copy covering both directions: historical Netskope-sourced score
  contributions freeze (matching CrowdStrike's disconnect behavior), and if Share Risk Signals was
  active, an additional line stating that previously pushed data remains in Netskope and cannot be
  retracted — this is the same irreversibility fact as the Share Risk Signals disable warning, and
  should reuse that copy rather than restating it differently.
- **Primary action:** Disconnect (destructive, right-aligned).
- **Secondary actions:** Cancel (left-aligned).

## Open issues

- Cross-integration category grouping (naming shared dimensions across CrowdStrike's 6 rows and
  Netskope's 7 rows, per the Living Security-informed competitor finding) is not addressed by this
  strategy and should be scoped as its own design pass once a third integration makes the need more
  concrete, rather than retrofitted now onto two already-shipped/in-progress category lists.
- No recommended default weight values are defined for Netskope's categories, same open item as
  CrowdStrike's equivalent gap — needs PM/Eng input, and should reuse whatever baseline-setting
  process gets defined for CrowdStrike rather than inventing a second one.
- Whether Dashboard Viewer sees a read-only Netskope section on the risk score breakdown is
  unresolved, mirroring the same open CrowdStrike question — should be answered once, for both
  integrations together, not twice.
- The exact translation formula from Netskope's 1-1000 UCI scale to Dune's risk badge scale is an
  Eng question this strategy explicitly defers (see wireframe #6) — the UI is designed to only ever
  display the already-translated badge, so it holds regardless of the final formula.
- Security review scope for write-back (flagged in `open-questions.md`) may surface new
  requirements — e.g. an audit trail of exactly what was pushed and when — that this strategy has
  not designed for; revisit the Share Risk Signals page once that review completes.

## Next design actions

1. Build the Connect wizard and Configure Risk Score Weights page first in Figma, reusing
   CrowdStrike's components directly rather than redrawing them.
2. Design the Share Risk Signals page as the first instance of Dune's outbound-signal-configuration
   pattern — this is the one genuinely new pattern in this feature and deserves dedicated design
   review before being treated as a template for any future write-back integration.
3. Validate the Behavior Confidence / Share Risk Signals conflict modal copy with Eng once the
   security review (open question) clarifies whether additional consent or audit language is
   required.
4. Confirm recommended default weight values and the Dashboard Viewer visibility question jointly
   with the equivalent open CrowdStrike items, not as two separate PM asks.
