# User Flow — Netskope Risk Score Integration

## Entry points

- Settings > Integrations, from the main admin settings navigation (Full Access admin only; the
  Integrations nav item does not render for scoped roles), same entry point as CrowdStrike.
- A link from the risk score breakdown view's Netskope section, for an admin who wants to revisit
  weighting after seeing a specific user's score.
- A link from the Netskope Integrations tile's secondary status line ("5 categories active · 2
  signals shared") directly into Share Risk Signals, for an admin managing the outbound side
  specifically.

## Happy path

1. Full Access admin navigates to Settings > Integrations and selects the Netskope tile (status:
   Not Connected).
2. **Connect wizard, Step 1:** admin enters the Netskope Tenant URL and API Token. Clicks Next.
3. **Connect wizard, Step 2:** Dune tests the connection and probes each Netskope alert type plus
   whether the token carries write scope. A capability table renders showing which categories are
   available and whether Share Risk Signals is available (token scope permitting). All categories
   show Available; write scope is present. Admin clicks Next.
4. **Connect wizard, Step 3:** admin selects a sync cadence (defaults to Every 24 hours) and clicks
   Connect & Continue.
5. System activates the integration, shows a success toast, and redirects the admin directly to the
   Configure Risk Score Weights page.
6. Admin sees a one-time callout explaining the page, category rows pre-populated with recommended
   default weights grouped into three visual clusters (Behavior Confidence; the five granular
   categories; No Netskope Visibility). Admin adjusts a few weights.
7. Admin clicks "Estimate impact" to preview the effect, then clicks Save. No Smart Group or
   Adaptive Workflow thresholds are crossed, so the save completes immediately with a toast:
   "Weights saved. Changes apply starting with the next sync."
8. Admin separately navigates to Share Risk Signals with Netskope. Since the token has write scope,
   the page is unlocked. Admin turns on the master toggle. Because Behavior Confidence is not
   currently enabled, no conflict modal appears. Admin enables Training Overdue Status and Overall
   Dune Risk Tier, leaves Simulation Failure Events off, and clicks Save.
9. On the next scheduled sync, Netskope data pulls for all mapped users, risk scores recompute using
   the new weights, and the two enabled signal types push to Netskope's UCI Impact endpoint for each
   mapped user.
10. Admin later opens a user's risk score detail view and sees a new Netskope source section with
    per-category badges (Behavior Confidence badge already translated from Netskope's 1-1000 scale
    to Dune's convention) and a score delta since the last sync.

## Decision points

- **Capability detection outcome (Step 2):** mirrors the CrowdStrike pattern for read-scope
  categories. Write-scope detection is a distinct outcome: if absent, Share Risk Signals remains
  reachable but locked, rather than blocking the whole wizard — write-back is optional, unlike core
  connectivity.
- **Enabling Share Risk Signals while Behavior Confidence is active:** triggers a confirmation modal
  explaining the circular-dependency reason before the toggle commits. Admin can Cancel (stays on
  Share Risk Signals page, nothing changes) or confirm "Turn on Share Risk Signals" (commits the
  toggle and force-disables Behavior Confidence on the Weights page in the same action).
- **Saving weight changes:** same cascade-warning modal behavior as CrowdStrike (Smart
  Group/Adaptive Workflow threshold crossings).
- **User mapping resolution:** Netskope identity data resolves automatically via the same IAM
  identity Dune already uses for SSO/SCIM — a materially higher auto-match rate is expected than
  CrowdStrike's device-login heuristic, though this is a design expectation, not a guarantee the
  flow depends on. Unmatched data appears in Review User Mapping for manual linking. A Dune user
  with no Netskope data at all is scored under No Netskope Visibility.
- **Disabling Share Risk Signals after active use:** triggers an irreversibility confirmation modal
  distinct from a routine settings-change confirmation, since Dune cannot retract data already
  consumed by Netskope's own scoring model.

## System responses

- Step 2 connection test and capability probe (including write-scope check) run synchronously
  before the admin can proceed, shown as an inline loading state on the capability table.
- "Estimate impact" runs asynchronously on the Weights page, matching the CrowdStrike pattern.
- Scheduled sync and push both run in the background on the same cadence; status badges
  (Connected / Sync Delayed / Connection Error on the Weights side, Push Delayed on the Share Risk
  Signals side) communicate health without a blocking screen.
- Saving weights or signal toggles while a sync is already in progress does not error — the
  in-progress cycle completes on prior settings; new settings apply starting with the next cycle.

## Edge cases

- **Netskope API token expires, is revoked, or is rotated mid-use** (`edge-cases.md`, System
  states): next scheduled sync and any pending push both fail; status badges reflect a connection
  error; scores and Netskope-side enforcement continue on last-known data until reconnected.
- **Client on base SSE tier only, without Advanced UEBA** (Content states): Behavior Confidence row
  is absent from Configure Risk Score Weights entirely; the five granular categories and No Netskope
  Visibility remain configurable; Share Risk Signals is unaffected since it doesn't depend on
  Advanced UEBA.
- **Client has zero Netskope license** (Content states): wizard blocks at Step 2; integration never
  activates; neither the Weights page nor Share Risk Signals is reachable.
- **Admin's token lacks write scope** (Permission states): Share Risk Signals renders locked with
  instructions to update token scope and reconnect; the rest of the integration (ingestion, weights)
  functions normally and independently.
- **Admin attempts to enable Share Risk Signals while Behavior Confidence is active** (Action
  states): force-disable confirmation modal, not a silent toggle — this is the one point in the flow
  where a setting on one page visibly changes a setting on another, and it must be presented as an
  active decision.
- **A push to Netskope's UCI Impact endpoint fails** (System states): "Push delayed" status on the
  Share Risk Signals page, distinct from ingestion sync errors; Netskope continues enforcing on the
  last successfully pushed signal.
- **Admin disables Share Risk Signals after active use** (Action states): irreversibility
  confirmation modal states that already-pushed data cannot be retracted from Netskope; this is not
  a routine "discard changes" pattern.
- **Netskope identity has no matching Dune user** (Content states): retained in Review User Mapping
  for manual resolution; contributes nothing to any score while unmatched.
- **Dune user has no Netskope presence at all** (Content states): scored under the always-present No
  Netskope Visibility weight; shown as a distinct badge, not a blank Netskope section.
- **User simultaneously flagged No Endpoint Visibility (CrowdStrike) and No Netskope Visibility
  (Netskope)** (Content states): both sections render independently on the risk score breakdown;
  no combined or deduplicated messaging, since they are independent facts about two systems.
- **Admin disconnects the integration** (Action states): confirmation modal covers both directions —
  historical contributions freeze, and if Share Risk Signals was active, previously pushed data
  remains in Netskope and cannot be retracted, reusing the same irreversibility copy as the Share
  Risk Signals disable warning.
- **Admin sets all weights to 0%** (Action states): non-blocking inline banner suggests
  disconnecting instead, matching the CrowdStrike pattern.
- **Weight set above 0% before any data has synced for that category** (Content states): category
  row and Estimate Impact panel both show "No data yet — first sync in progress."
- **Capability set shrinks after a license downgrade** (System states): affected category moves into
  a labeled "No longer available" section rather than disappearing silently.
- **Large unmatched mapping list / zero unmatched identities** (Content states): handled identically
  to the CrowdStrike pattern — existing table search/sort/pagination for large lists, positive empty
  state for zero.

## Exit states

- **Success:** integration connected, weights saved, Share Risk Signals configured (if enabled),
  sync and push complete on schedule, admin can see Netskope's contribution on a user's risk score
  breakdown.
- **Cancelled setup:** admin exits the Connect wizard before Step 3 completes; nothing is created.
- **Blocked setup:** wizard halts at Step 2 due to zero accessible categories; admin must resolve
  credentials/licensing outside the flow and retry.
- **Degraded but functional (ingestion):** integration connected with partial read capability; admin
  can still configure and save weights for whatever is available.
- **Write-back unavailable but ingestion functional:** token lacks write scope; Share Risk Signals
  stays locked while weighting and ingestion work normally — the two directions can be in different
  states simultaneously.
- **Error (post-connection):** sync or push failure surfaces as a status badge and does not silently
  fail; scores and Netskope-side enforcement hold at last-known values until resolved.
