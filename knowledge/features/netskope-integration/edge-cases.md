# Edge Cases — Netskope Risk Score Integration

## System states
- Netskope sync and CrowdStrike sync both fail in the same window — no combined "integrations degraded" view described; each surfaces its own status independently.
- First activation triggers a full sync of a potentially large user base with no progress indicator or size estimate shown to the admin (same unresolved gap as CrowdStrike, recurring for a second integration).
- Partial per-category sync failure: one Netskope alert type fails to return data (e.g. Advanced UEBA permission revoked) while others succeed in the same sync cycle.
- A previously available category (most likely Behavior Confidence) becomes unavailable after a client's Netskope license changes, while historical data and a configured weight for it still exist.
- Netskope API rate limiting or transient errors during a sync — surfaces as "Sync delayed," distinct from a hard "Connection error," matching the CrowdStrike pattern.
- Netskope API token expires, is revoked, or is rotated mid-use — risk scores continue on last successfully synced data until reconnected.

## Permission states
- No admin role narrower than Full Access exists to own this integration; unlike CrowdStrike (SecOps-owned), Netskope credentials commonly sit with networking/SSE teams, making this gap more likely to surface in practice for this integration specifically.
- Scoped roles (AEP Manager, Training & Simulations Manager, Dashboard Viewer) do not see the Integrations surface — same unconfirmed question as CrowdStrike about whether Dashboard Viewer should see a read-only "Netskope connected" indicator on risk score breakdowns they can already view.

## Content states
- Dune user with zero Netskope presence (unmanaged personal device, traffic never routed through Netskope) — scored under the always-present "No Netskope Visibility" weight rather than excluded or treated as neutral.
- A user simultaneously flagged "No Endpoint Visibility" (CrowdStrike) and "No Netskope Visibility" (Netskope) — both sections would appear on one risk score detail view; combined framing/copy for this double-gap state is undefined.
- Behavior Confidence enabled but the underlying UBA data hasn't populated yet for a new tenant — live preview and score breakdown behavior in this state is undefined, same class of gap flagged for CrowdStrike's category-weight-before-data-exists case.
- Admin enables both Behavior Confidence and the five granular categories at meaningful weights — not blocked, only soft-warned; the resulting score movement compounds the same underlying behavior twice.
- Zero unmatched identities (clean mapping state) vs. very large unmatched identity list — same unresolved pagination/filter/empty-state question as CrowdStrike.
- Client on base SSE tier only, without Advanced UEBA — Behavior Confidence row does not render; the five granular categories and No Netskope Visibility remain configurable.
- Client has zero Netskope license coverage at all — connection fails at capability detection, integration never activates.

## Action states
- Disconnecting the integration has no described confirmation step despite freezing risk score inputs for the entire organization, same gap as CrowdStrike.
- Setting all category weights (including Behavior Confidence) to 0% is functionally equivalent to disconnecting but has no equivalent confirmation or warning.
- Admin disables Behavior Confidence after a period of active use — whether historical UCI-driven score contribution freezes (matching disconnect behavior) or immediately zeroes out is undefined.
- Re-linking an already-mapped Netskope identity to a different Dune user (correcting a mismatch) is not restated in this PRD even though the equivalent CrowdStrike behavior exists — confirm rather than assume identical treatment.
- Admin changes weights while a sync is in progress — in-progress sync completes on old weights; new weights apply next cycle, matching the CrowdStrike pattern.
- Saving new weights that would shift Smart Group membership or fire Adaptive Workflows automation has no described warning to the admin before saving, same unresolved gap as CrowdStrike.

## Responsive / Accessibility
- Weight sliders (0-100%) need a keyboard-accessible numeric input alternative alongside drag interaction, same requirement as CrowdStrike's equivalent UI.
- Mobile/tablet behavior for the Integrations settings surface remains unconfirmed across both integrations; likely resolved once, generically, rather than per-vendor.
