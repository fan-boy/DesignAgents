# Edge Cases — CrowdStrike Risk Score Integration

## System states
- First activation triggers a full sync of a potentially large user base with no progress indicator or size estimate shown to the admin.
- Partial per-category sync failure: one CrowdStrike scope fails (e.g. Identity Protection permission revoked) while others succeed in the same sync cycle.
- A previously available category becomes unavailable after a client's CrowdStrike license changes, while historical data and a configured weight for it still exist.
- CrowdStrike API rate limiting or transient errors during a sync — should surface as "Sync delayed," distinct from a hard "Connection error."
- Credentials expire or are revoked mid-use — risk scores continue on last successfully synced data until reconnected.

## Permission states
- No admin role narrower than Full Access exists to own this integration; a client's IT/SecOps team cannot configure CrowdStrike without full training-platform admin rights.
- Scoped roles (AEP Manager, Training & Simulations Manager, Dashboard Viewer) do not see the Integrations surface — unconfirmed whether Dashboard Viewer should see a read-only "CrowdStrike connected" indicator on risk score breakdowns they can already view.

## Content states
- Dune user with zero CrowdStrike presence (BYOD, contractor, unmanaged device) — scored under the always-present "No Endpoint Visibility" weight rather than excluded or treated as neutral; the risk score detail view shows this as a distinct flag, not an absent section.
- Zero unmatched identities (clean mapping state) — unclear whether the User Mapping table should hide itself or remain visible and empty.
- Very large unmatched identity list (hundreds/thousands of rows for a large enterprise) with no described pagination, search, or filter.
- A category weight is set above 0% before any data has synced for that category — live preview behavior in this state is undefined.
- Client has no CrowdStrike modules beyond core Falcon Insight — only Device Posture and Detected Threats are configurable; the other three category rows do not render.
- Client has zero CrowdStrike license coverage at all — connection fails at capability detection, integration never activates.

## Action states
- Disconnecting the integration has no described confirmation step despite freezing risk score inputs for the entire organization.
- Setting all five category weights to 0% is functionally equivalent to disconnecting but has no equivalent confirmation or warning.
- Re-linking an already-mapped identity to a different Dune user (correcting a mismatch) is not described — only initial linking of unmatched identities is.
- Admin changes weights while a sync is in progress — in-progress sync completes on old weights; new weights apply next cycle.
- Saving new weights that would shift Smart Group membership or fire Adaptive Workflows automation has no described warning to the admin before saving.

## Responsive / Accessibility
- Weight sliders (0-100%) need a keyboard-accessible numeric input alternative alongside drag interaction.
- Mobile/tablet behavior for the Integrations settings surface is unconfirmed; likely out of scope but not explicitly stated.
- Shared devices or service accounts (e.g. kiosk workstations) break single-user login-history attribution — flagged as a known limitation, not a solved state, in v1.
