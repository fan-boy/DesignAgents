## Last updated — 2026-07-07
Resolved during PRD research: CrowdStrike categories blend into one overall risk score (no separate human/environment split); users with no CrowdStrike coverage are scored under a new always-present "No Endpoint Visibility" weight rather than excluded or neutral; user mapping is clarified to resolve through the same IAM identity (SSO/SCIM email/UPN) Dune already uses, not a separate email field. RBAC scope remains Full Access only for v1.

Dune's Risk Scoring Engine currently derives a user's risk score from training completion, simulation performance, and overdue status. This feature adds CrowdStrike Falcon as a new risk score input source: a Full Access admin connects their organization's CrowdStrike tenant, Dune pulls endpoint, identity, vulnerability, and detection data for each mapped user, and the admin sets weights controlling how much each category of CrowdStrike signal contributes to that user's overall risk score. Because CrowdStrike licensing varies by client (core Falcon Insight versus add-on modules like Identity Protection, Spotlight, and Discover), the integration detects which data categories a given tenant can actually supply and only exposes weight controls for those categories. The feature covers connecting the integration, configuring category weights, reviewing user mapping, and viewing the CrowdStrike contribution within the existing risk score breakdown.

**Connect CrowdStrike (Full Access Admin)**
Admin connects their organization's CrowdStrike Falcon tenant from Settings > Integrations. This is a three-step setup.

| Step | Fields | Validation / Behaviour |
|---|---|---|
| Step 1 — Enter credentials | CrowdStrike Cloud Region (dropdown: US-1, US-2, EU-1, US-GOV-1), Client ID, Client Secret | All fields required. Client Secret is masked and never re-displayed after save. |
| Step 2 — Test connection & detect capabilities | Read-only capability summary generated from the credentials | Dune calls CrowdStrike's OAuth2 token endpoint and probes each service collection scope (Hosts, Detections, Incidents, Zero Trust Assessment, Spotlight Vulnerabilities, Discover, Identity Protection). Displays which categories are available versus unavailable due to missing license or missing API scope. If the connection fails outright (bad credentials, network error), the admin cannot proceed past this step. |
| Step 3 — Set sync cadence & confirm | Sync frequency (Every 6 hours / Every 12 hours / Every 24 hours, default 24 hours) | Confirms and activates the integration. Redirects to the Configure Weights screen with a success toast: "CrowdStrike connected. Set up how it affects risk scores below." |

**Configure Risk Score Weights (Full Access Admin)**
A settings page under Settings > Integrations > CrowdStrike > Risk Score Weights. Each row is a signal category with a weight slider (0–100%) and a short plain-English description of what it measures. Only categories detected as available in Step 2 of Connect CrowdStrike are shown; unavailable categories are omitted entirely rather than shown disabled, since the admin cannot act on data their license doesn't include.

| Category | Description shown to admin | Source module required |
|---|---|---|
| Identity Risk | Unusual sign-in behavior and account risk flagged by CrowdStrike for this person's identity | Falcon Identity Protection |
| Device Posture | How well-protected and up to date this person's device is | Falcon Insight (core) |
| Detected Threats | Security detections and incidents involving this person's device, weighted by severity | Falcon Insight (core) |
| Unpatched Vulnerabilities | Known, exploitable software vulnerabilities present on this person's device | Falcon Spotlight |
| Account Hygiene | Local admin usage and unsanctioned application activity on this person's device | Falcon Discover |
| No Endpoint Visibility | This person has no managed device or identity found in CrowdStrike at all | None (always shown) |

Weights are independent per category (not forced to sum to 100%) and combine with the existing training/simulation risk inputs already in the Risk Scoring Engine as one blended overall risk score — CrowdStrike categories are not split into a separate score from behavioral inputs. A live preview panel shows how many currently-scored users would see their risk score change, and by roughly how much, before the admin saves. Saving weight changes triggers a recompute of all mapped users' risk scores on the next scheduled sync, not instantly, consistent with the existing risk score recompute cadence.

A sixth, always-present row, **No Endpoint Visibility**, controls how much a user's score is affected by having no CrowdStrike coverage at all (no managed device found, no identity record found). Lack of EDR visibility is itself treated as a risk-relevant signal rather than a neutral non-event — an unmanaged or invisible device is a meaningfully different risk posture than a well-covered one scoring low across every category. This weight defaults to a moderate, non-zero value rather than 0%, and is shown even for tenants with no CrowdStrike modules detected, since it only requires knowing whether a user has any CrowdStrike presence at all. The exact scoring/escalation math for this row is an open question for Eng (see open-questions.md) — the product decision made here is that it must never be silently excluded or treated as equivalent to a clean bill of health.

**Review User Mapping (Full Access Admin)**
CrowdStrike identifies devices and identities, not Dune user records, so every sync must resolve CrowdStrike data to a Dune user. Mapping resolves through the same identity key Dune already uses for user provisioning: CrowdStrike's identity record email/UPN (when Identity Protection is licensed) or a device's most recent interactive login account's UPN (when it is not) is matched against the Dune user's IAM identity (the email/UPN from SSO or SCIM provisioning), not a separately maintained email field. A table under Settings > Integrations > CrowdStrike > User Mapping shows three states: Matched, Unmatched CrowdStrike identity (data exists in CrowdStrike but no corresponding Dune user was found), and Dune users with no CrowdStrike data (no license coverage or the device/identity was never seen — these are the users the No Endpoint Visibility weight applies to). Unmatched CrowdStrike identities do not affect any risk score. Admins can manually link an unmatched CrowdStrike identity to a Dune user from this table.

**Full Access Admin view of CrowdStrike contribution to risk score**
On a user's existing risk score detail view, a new "CrowdStrike" source section appears alongside the existing Training and Simulation contribution sections, showing the per-category sub-scores and their configured weights. If a category is not licensed for this tenant, it does not appear. If the user has no CrowdStrike mapping at all, the section shows a distinct "No Endpoint Visibility" flag and its contribution to the score, rather than omitting the section or implying a clean result.

**End User view**
End users continue to see only their overall risk score and the existing framing of what drives it in general terms, consistent with the platform's principle of showing risk scores in the context of action rather than as raw underlying data. CrowdStrike-sourced detail (device posture, detections, vulnerabilities) is not surfaced to the end user directly, since it may include information the user has no visibility or control over. This treatment matches how training and simulation contributions are already summarized for end users today, and should be confirmed rather than assumed net-new.

Integration Points

| Integration | Description |
|---|---|
| Risk Scoring Engine | CrowdStrike category scores become additional weighted inputs alongside training completion and simulation performance in the existing per-user risk score calculation. |
| RBAC | Connecting the integration, editing weights, and manually resolving user mapping are Full Access admin actions only. Scoped admin roles (AEP Manager, Training & Simulations Manager, Dashboard Viewer) do not see the Integrations settings surface. |
| Audit Log | Connecting, disconnecting, and changing category weights are timestamped and recorded, consistent with other admin configuration changes. |
| Smart Groups | Once CrowdStrike contributes to risk score, any Smart Group defined by a risk score threshold is indirectly affected by CrowdStrike data without further configuration. |
| Adaptive Workflows | Existing risk-score-triggered automation (e.g. training auto-assignment on a risk threshold) is unaffected in mechanism, but may fire more often or for different users once CrowdStrike weights are active. |
| Email Notifications | No new notification type introduced by this feature; integration connection failures surface in-product only. |
| Identity Provider / SSO | The IAM identity (email/UPN) Dune already resolves through SSO or SCIM provisioning is the join key used to match CrowdStrike identity and device login records to a Dune user record. |

Edge Cases & System Behaviour

| Scenario | Behaviour |
|---|---|
| CrowdStrike credentials expire or are revoked mid-use | Next scheduled sync fails; integration status shows "Connection error" with the last successful sync timestamp; risk scores continue using the last successfully synced CrowdStrike data until reconnected. |
| Client has no CrowdStrike modules beyond core Falcon Insight | Identity Risk, Unpatched Vulnerabilities, and Account Hygiene weight rows are not shown; only Device Posture and Detected Threats are configurable. |
| Client has zero CrowdStrike license (evaluating the integration only) | Connection step fails at capability detection with a clear message identifying no accessible data categories; integration is not activated. |
| CrowdStrike identity or device has no matching Dune user | Data is retained for the User Mapping review table for admin resolution; it never contributes to any risk score while unmatched. |
| Dune user has no CrowdStrike presence at all (unmanaged or BYOD device, no identity record) | Scored under the always-present No Endpoint Visibility weight rather than excluded or treated as neutral; the user's risk score detail shows this as a distinct flag, not a blank CrowdStrike section. |
| A device or identity in CrowdStrike is shared by multiple people (e.g. shared kiosk, service account) | Login-history-based mapping only supports single-user attribution today; shared devices resolve to whichever account most recently logged in, which may be inaccurate. Flagged as a known limitation rather than solved in this version. |
| Admin disconnects the integration | Historical CrowdStrike-sourced score contributions are frozen at their last computed value rather than removed; no further recompute occurs from CrowdStrike inputs until reconnected. |
| Admin sets a category weight to 0% | The category still displays in the score breakdown for transparency but no longer contributes numerically. |
| Sync in progress when an admin changes weights | The in-progress sync completes using the previous weights; new weights apply starting with the next scheduled sync. |
| CrowdStrike API rate limiting or transient error during sync | Sync retries on the next scheduled interval; integration status shows "Sync delayed" rather than "Connection error" if the failure is transient rather than a credential/permission failure. |
