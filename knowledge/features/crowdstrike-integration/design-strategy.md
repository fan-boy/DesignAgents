# Design Strategy — CrowdStrike Risk Score Integration

## Feature context

A Full Access admin connects their organization's CrowdStrike Falcon tenant so that CrowdStrike
signals (Identity Risk, Device Posture, Detected Threats, Unpatched Vulnerabilities, Account
Hygiene, and a coverage signal called No Endpoint Visibility) become admin-weighted inputs blended
into a user's existing Dune risk score. No success metric exists yet in source material — the
design must optimize for admin comprehension and trust rather than a stated adoption target. The
primary user is a Full Access admin, most often at an enterprise client with an existing CrowdStrike
deployment; the secondary, indirectly-affected user is the end learner whose score may move as a
result of admin configuration they never see directly.

## Design goal

Let an admin connect CrowdStrike and tune its influence on risk score with full visibility into
what each weight does and what it will affect — without ever making an employee's score feel
arbitrary, punitive, or explained by something they can't act on.

## Key constraints

- RBAC: Full Access admin only for v1 (confirmed, not to be redesigned as a scoped permission).
- CrowdStrike licensing varies per client tenant — the UI must render correctly whether 0, 2, or 5
  categories are available, and must never show a control for a category the tenant's license
  doesn't support.
- Sync is scheduled/polling-based, not real-time — weight changes and full syncs both happen on a
  cadence, not instantly. The UI must never imply an instant, real-time update.
- Score composition, missing-coverage treatment, and mapping mechanism are already decided (see
  `prd.md` Last Updated note) — this strategy designs the UI for those decisions, it does not
  revisit them.
- Open question `[Eng]` on the exact No Endpoint Visibility escalation math is unresolved; the
  design must work regardless of the final formula (i.e., don't design a UI that only works if the
  math is a simple percentage).
- No competitor in the registry publishes a comparable admin-tunable weighting UI for third-party
  telemetry (`competitor-analysis.md`) — there's no existing convention to defer to; the design
  must earn trust on its own rather than matching a known pattern.

## Strategy options

**Option A — Wizard-only setup.** Fold weight configuration into the Connect CrowdStrike wizard as
additional steps (Step 4: set weights, Step 5: confirm). Simple, guided, but couples an
ongoing-tuning task to a one-time setup metaphor — admins revisiting weights later have to
re-enter a "wizard," which reads as re-onboarding rather than settings management.

**Option B — Fully decoupled settings page.** Connect wizard ends at 3 steps (as specified in
`prd.md`); weight configuration lives entirely as an independent, always-available settings page
with no onboarding guidance beyond a toast link. Cleanest separation of concerns, matches how
CybSafe's impact settings work as a standing admin screen, but loses the opportunity to walk a
first-time admin through what each category means at the moment they're most attentive.

**Option C (recommended) — Guided handoff into a persistent settings page.** Keep the Connect
wizard at exactly the 3 steps specified in `prd.md`. On completion, land the admin directly on the
Configure Risk Score Weights page — pre-populated with conservative recommended defaults per
category rather than all-zero — with a one-time inline callout explaining what each visible
category measures. That callout dismisses permanently once acknowledged. The page itself is a
normal, always-available settings surface from that point forward, not a wizard step the admin
"completes." This gets the onboarding clarity of Option A without permanently treating ongoing
weight tuning as a wizard flow.

## Recommended strategy

Option C. It matches the flow described in `prd.md` (wizard redirects to the weights screen)
exactly, avoids inventing new structure, and directly targets the biggest identified risk in
`prd-research-summary.md`: an admin who doesn't understand what each category does and
misconfigures the weighting in a way that produces confusing downstream score movement. Starting
admins from a non-zero recommended baseline (rather than blank sliders) also reduces the chance of
an admin leaving everything at 0%, which functions like an undeclared disconnect (`prd.md` edge
case).

## Risks and tradeoffs

- Recommended default weights require a product decision on what "conservative" means per
  category — this needs PM/Eng input on reasonable starting values, tracked as a new open item.
- A permanently-dismissible callout means an admin who skims past it on day one has no easy way to
  re-surface the explanation later; mitigate with a persistent "What do these mean?" info affordance
  next to the category list, not just the one-time callout.

## Wireframe plan

### 1. Integrations list (entry point)
- **Role:** Settings > Integrations landing page; CrowdStrike is one tile among future
  integrations.
- **Layout:** Standard settings page body, no sidebar. Grid or list of integration tiles.
- **Key components:** Tile per integration with a status **badge** (Not Connected / Connected /
  Connection Error / Sync Delayed — color + label, never color alone, per DS rules).
- **Primary action:** Click CrowdStrike tile → opens Connect wizard (not connected) or the
  Integration Detail area (already connected).
- **Edge cases:** Full Access only — tile grid is not rendered at all for scoped roles (nav item
  hidden, per RBAC permission-gap-at-start-of-flow rule); no disabled-with-tooltip needed since the
  entire surface is out of scope for those roles.

### 2. Connect CrowdStrike (wizard, 3 steps)
- **Role:** Credential entry, capability detection, cadence confirmation.
- **Layout:** Full-page **wizard pattern** with step bar — not a modal, since Step 1 alone has 3
  required fields and Step 2 renders a 7-row capability table, both past the 3-field modal limit.
- **Key components:**
  - Step 1: form fields (region dropdown, Client ID, Client Secret — masked).
  - Step 2: read-only capability **table** (category, status badge: Available / Unavailable —
    license, Unavailable — permission). Primary action disabled until connection test succeeds.
  - Step 3: cadence selector (radio group), confirm button.
- **Primary action:** Next / Connect & Continue on final step.
- **Secondary actions:** Back (preserves form state across steps), Cancel (exits without saving,
  confirmation not required since nothing has been created yet).
- **System content:** Live connection test result on Step 2; explicit per-category availability
  reason (license vs. permission) so the admin knows whether to fix API scopes or upgrade licensing.
- **Edge cases:** Hard failure at Step 2 (bad credentials, zero accessible categories) blocks
  progression with a specific error message identifying the cause; this is the only fully blocking
  state in the wizard.

### 3. Configure Risk Score Weights (settings page)
- **Role:** Ongoing configuration surface for how CrowdStrike affects risk score. First landing
  page after Connect wizard completes, and the permanent home for this configuration afterward.
- **Layout:** Settings page body with a category list (not a table — each row has a distinct
  interactive control, unlike tabular data) and a sticky footer action bar (Save / Cancel).
- **Key components:**
  - One-time dismissible callout at the top explaining the page's purpose (first visit only).
  - Category rows: label, one-line plain-language description, weight control (slider **and**
    paired numeric input per the competitor-informed pattern), and a small sync-status indicator
    icon when a category's last sync failed.
  - A visual divider before the **No Endpoint Visibility** row, with a short explanatory line
    ("Applies to any user with no managed device or identity found in CrowdStrike") — this row is
    always present regardless of license, structurally separated because it measures absence of
    data rather than a data category.
  - Previously-licensed-but-now-unavailable categories collapse into a dismissed, explicitly
    labeled "No longer available" section rather than disappearing silently, if this occurs.
  - Live preview panel: "Estimate impact" as an explicit, on-demand action (not automatic
    recompute-on-every-slider-move) given potentially large user populations — shows an
    approximate count of users whose score would change and by how much, generated async.
- **Primary action:** Save.
- **Secondary actions:** Cancel/revert unsaved changes; "Estimate impact" (non-committing).
- **System content:** Per-category weight value, sync-freshness indicator, preview results once
  generated.
- **Edge case handling:**
  - Weight set above 0% before any data has synced for that category → preview panel and category
    row both show "No data yet — first sync in progress" rather than a numeric estimate.
  - Saving weights that would move users across a Smart Group risk threshold or fire an Adaptive
    Workflow trigger surfaces a **confirmation modal** before the save commits: plain-language
    summary of the cascade ("12 users will move into the High Risk group, which may trigger
    automated training assignment") with Cancel (left) and Save Anyway (right).
  - All weights set to 0% shows a non-blocking inline banner suggesting the admin disconnect the
    integration instead if CrowdStrike shouldn't affect scoring at all — informational, not forced.
  - Recompute from a saved weight change is described as **decoupled from historical trend
    charts**: the risk score breakdown's before/after delta reflects the new weights going forward,
    but any existing trend-over-time visualization is not silently rewritten for past dates,
    consistent with the CybSafe pattern from `competitor-analysis.md`. This directly targets the
    score-volatility trust risk from `prd-research-summary.md`.

### 4. Review User Mapping (table page)
- **Role:** Resolve CrowdStrike identities/devices that didn't automatically match a Dune user.
- **Layout:** Standard **table pattern** with filter/segment control above (Matched / Unmatched /
  No CrowdStrike Data), sort and search above the table per DS rules.
- **Key components:** Table rows with mapping status **badge**; row action opens a right-anchored
  **drawer** (360px) to search and link a Dune user to an unmatched CrowdStrike identity.
- **Primary action:** Link (inside drawer).
- **Secondary actions:** Change mapping (row menu, for already-matched rows, to correct a
  mismatch).
- **System content:** Per-row confidence note where mapping was inferred from device login history
  rather than a direct identity record — a small caption ("Attributed via device login — may be
  inaccurate for shared devices") on rows resolved this way, surfacing the known shared-device
  limitation from `edge-cases.md` rather than hiding it.
- **Edge cases:** Zero unmatched rows → table remains visible with a positive **empty state**
  ("All CrowdStrike identities are mapped") rather than hiding the page, keeping the surface
  discoverable and consistent with the DS empty-state rule (message + context, never a blank
  table). Large unmatched counts rely on the table's existing search/sort/pagination — bulk
  resolution is explicitly deferred pending the open Eng question in `open-questions.md` and
  tracked as a next design action, not designed in v1.

### 5. Admin risk score breakdown (extension of existing view)
- **Role:** Show CrowdStrike's contribution within the risk score detail a Full Access admin
  already sees per user.
- **Layout:** New "CrowdStrike" source section added alongside existing Training and Simulation
  sections — same layout pattern as those sections, not a new structure.
- **Key components:** Per-category sub-score **badges** using the existing Critical/High/Medium/Low
  risk scale from `knowledge/design-system-rules.md` — never a raw number. A distinct
  "No Endpoint Visibility" badge/state for users with zero coverage, visually consistent with the
  other category badges rather than looking like an error state.
- **System content:** Score delta since last sync (before/after), consistent with the
  risk-scoring strategy rule that score changes always show as a delta, never a silent update.
- **Edge case handling:** Category not licensed for this tenant → row omitted entirely (not shown
  disabled). Scoped roles (AEP Manager, Training & Simulations Manager) don't reach this view per
  existing RBAC gating; whether Dashboard Viewer sees this section read-only is an **open
  question** — default to visible-read-only since that role already sees risk scores today, but
  flag for explicit PM confirmation before build.

### 6. Disconnect confirmation
- **Role:** Confirm a Full Access admin's intent to disconnect CrowdStrike.
- **Layout:** **Modal** (per DS modal-for-blocking-decisions rule), max 560px.
- **Key components:** Explanatory copy stating that historical CrowdStrike-sourced score
  contributions freeze at their last computed value rather than being deleted, and that no further
  CrowdStrike-driven recompute occurs until reconnected.
- **Primary action:** Disconnect (destructive, right-aligned per DS rule).
- **Secondary actions:** Cancel (left-aligned).

## Open issues

- No recommended default weight values are defined yet for Option C's pre-populated baseline —
  needs PM/Eng input.
- Whether Dashboard Viewer sees a read-only CrowdStrike section on the risk score breakdown is
  unresolved (carried from `prd-research-summary.md`).
- Bulk resolution UI for user mapping is deferred pending the Eng question on whether it's needed
  for v1 (carried from `open-questions.md`).
- The exact escalation math for No Endpoint Visibility remains open for Eng; this strategy assumes
  the UI only needs to display a resulting badge/score, not the underlying formula, so it should
  hold regardless of how that question resolves.
- Employee-facing disclosure update (whether existing risk score transparency copy needs to change)
  is unresolved and out of scope for the admin-facing screens in this strategy; flag before
  `dev-handoff` if it needs a learner-facing copy change.

## Next design actions

1. Confirm recommended default weight values with PM/Eng before wireframing Configure Risk Score
   Weights in Figma.
2. Resolve the Dashboard Viewer visibility question before finalizing the risk score breakdown
   section.
3. Build the Connect wizard and Configure Weights page first in Figma — they're the critical path;
   User Mapping and the breakdown extension can follow.
4. Validate the cascade-warning modal copy pattern ("N users will move into X group") against
   actual Smart Group/Adaptive Workflow data shapes with Eng before finalizing wording.
