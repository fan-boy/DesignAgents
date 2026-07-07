# User Flow — CrowdStrike Risk Score Integration

## Entry points

- Settings > Integrations, from the main admin settings navigation (Full Access admin only; the
  Integrations nav item does not render for scoped roles).
- A link from the risk score breakdown view's CrowdStrike section, for an admin who wants to
  revisit weighting after seeing a specific user's score.

## Happy path

1. Full Access admin navigates to Settings > Integrations and selects the CrowdStrike tile (status:
   Not Connected).
2. **Connect wizard, Step 1:** admin selects their CrowdStrike Cloud Region and enters Client ID
   and Client Secret. Clicks Next.
3. **Connect wizard, Step 2:** Dune tests the connection and probes each CrowdStrike service
   collection scope. A capability table renders showing which categories are available. All
   categories show Available. Admin clicks Next.
4. **Connect wizard, Step 3:** admin selects a sync cadence (defaults to Every 24 hours) and clicks
   Connect & Continue.
5. System activates the integration, shows a success toast, and redirects the admin directly to
   the Configure Risk Score Weights page.
6. Admin sees a one-time callout explaining the page, category rows pre-populated with recommended
   default weights, and a divider before the always-present No Endpoint Visibility row. Admin
   adjusts a few weights using the slider or numeric input.
7. Admin clicks "Estimate impact" to see an async-generated approximate count of users whose score
   would change and by roughly how much.
8. Admin clicks Save. Because no Smart Group thresholds or Adaptive Workflow triggers would be
   crossed by this change, the save completes immediately with a confirmation toast: "Weights
   saved. Changes apply starting with the next sync."
9. On the next scheduled sync, CrowdStrike data pulls for all mapped users and risk scores recompute
   using the new weights.
10. Admin later opens a user's risk score detail view and sees a new CrowdStrike source section
    with per-category badges and a score delta since the last sync.

## Decision points

- **Capability detection outcome (Step 2):** Full capability (all categories available) → proceed
  as above. Partial capability (some categories unavailable due to license or scope) → only
  available categories show in the table and later appear as configurable weights; wizard still
  proceeds. Zero capability → wizard blocks at Step 2 with a specific failure message; admin cannot
  connect until credentials or licensing are fixed.
- **Saving weight changes:** if the new weights would move any user across a Smart Group risk
  threshold or fire an Adaptive Workflow trigger, a confirmation modal interrupts the save with a
  plain-language summary of the cascade. Admin can Cancel (return to editing) or Save Anyway
  (commits and shows the same "applies next sync" toast).
- **User mapping resolution:** CrowdStrike identity/device data with a confident match resolves
  automatically. Unmatched data appears in the Review User Mapping table for manual linking. A
  Dune user with no CrowdStrike data at all is scored under No Endpoint Visibility rather than
  appearing in the mapping table as an error.

## System responses

- Step 2 connection test and capability probe run synchronously before the admin can proceed —
  shown as an inline loading state on the capability table, not a separate screen.
- "Estimate impact" runs asynchronously; the preview panel shows a loading state and does not block
  the rest of the page.
- Scheduled sync (initial and recurring) runs in the background; the Configure Weights page and
  Integrations tile reflect status via a badge (Connected / Sync Delayed / Connection Error) and a
  last-synced timestamp, not a blocking screen.
- Saving weights while a sync is already in progress does not error — the in-progress sync
  completes on the prior weights, and the toast copy adjusts to "Applied. Will take effect starting
  after the sync currently in progress."

## Edge cases

- **CrowdStrike credentials expire or are revoked mid-use** (`edge-cases.md`, System states): next
  scheduled sync fails; Integrations tile and Configure Weights page both show a "Connection error"
  badge with the last successful sync timestamp; scores continue reflecting last-synced data.
- **Client has no modules beyond core Falcon Insight** (Content states): only Device Posture,
  Detected Threats, and No Endpoint Visibility rows render on Configure Weights; the other three
  categories are simply absent, not shown disabled.
- **Client has zero CrowdStrike license** (Content states): wizard blocks at Step 2; integration
  never activates; no Configure Weights page is reachable.
- **CrowdStrike identity/device has no matching Dune user** (Content states): retained in Review
  User Mapping for manual resolution; contributes nothing to any score while unmatched.
- **Dune user has no CrowdStrike presence at all** (Content states): scored under the always-present
  No Endpoint Visibility weight; shown as a distinct badge on their risk score breakdown, not a
  blank CrowdStrike section.
- **Shared device or service account** (System states): mapping resolves to the most recent login
  account, which may be inaccurate; Review User Mapping rows resolved this way carry a caption
  flagging the limitation.
- **Admin disconnects the integration** (Action states): confirmation modal explains that historical
  contributions freeze rather than delete; disconnect is destructive-right, cancel-left per DS modal
  pattern.
- **Admin sets all weights to 0%** (Action states): non-blocking inline banner suggests disconnecting
  instead; does not force the action.
- **Weight set above 0% before any data has synced for that category** (Content states): the
  category row and the Estimate Impact panel both show "No data yet — first sync in progress"
  instead of a misleading zero or blank number.
- **Capability set shrinks after a license downgrade** (System states): the affected category moves
  into a labeled "No longer available" section rather than disappearing silently, preserving admin
  awareness of the change.
- **Large unmatched mapping list** (Content states): handled by the table's existing search, sort,
  and pagination; bulk resolution is explicitly deferred, not designed in this flow.
- **Zero unmatched identities** (Content states): Review User Mapping table remains visible with a
  positive empty state rather than hiding the page.

## Exit states

- **Success:** integration connected, weights saved, sync completes on schedule, admin can see
  CrowdStrike's contribution on a user's risk score breakdown.
- **Cancelled setup:** admin exits the Connect wizard before Step 3 completes; nothing is created,
  no partial integration state persists.
- **Blocked setup:** wizard halts at Step 2 due to zero accessible categories; admin must resolve
  credentials/licensing outside the flow and retry.
- **Degraded but functional:** integration connected with partial capability (some categories
  unavailable); admin can still configure and save weights for whatever is available.
- **Error (post-connection):** sync failure surfaces as a status badge and does not silently fail;
  scores hold at last-known values until resolved.
