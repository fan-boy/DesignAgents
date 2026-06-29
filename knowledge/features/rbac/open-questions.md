# Open Questions — Role-Based Access Control (RBAC)

> **MVP scope note (2026-06-29):** Scope reduced to AEP Manager role only. Questions specific to Training & Simulations Manager, Dashboard Viewer, and multi-role dashboard scoping are deferred — kept below for when those roles are designed.

## Unresolved — MVP (AEP Manager)

- [x] [Eng] Is the Red Teaming dashboard a single route with an AEP tab, or does the AEP creation surface live at its own route? — **Answer:** Red Teaming is a single route with two tabs: Dashboard and AEP Library. AEP Managers land on the Red Teaming route and see the AEP Library tab only. The Dashboard tab (org-level campaign data, complicit rates, action required) is hidden for AEP Managers.
- [ ] [PM] Does the AEP Manager see the Red Teaming → Dashboard tab, or only the AEP Library tab? The Dashboard tab shows org-wide campaign metrics (complicit rates, all campaigns table, action required). Recommendation: hide the Dashboard tab from AEP Managers — it is a reporting surface they don't need and shouldn't have access to. Confirm before building.
- [ ] [PM] Does "manage" for the AEP Manager role include delete, or only create/edit? Affects whether a delete confirmation pattern is needed in MVP.
- [ ] [Eng] When a Full Access user is downgraded to AEP Manager mid-session, must their session be invalidated immediately, or is enforcement on next page load/API call acceptable from a security standpoint?
- [ ] [PM] What is the UX for a pending invite — can a Full Access admin change a user's role before they activate their account?
- [ ] [PM] Is "AEP Manager" the final role name, or is a different label preferred (e.g., "Campaign Manager", "Red Team Operator")?
- [ ] [Eng] Where is the audit log surfaced? Is it an existing surface or net-new for MVP?

## Deferred — Future Roles

- [ ] [PM] Dashboard Viewer: cross-surface read-only vs. scoped access — resolve when designing that role.
- [ ] [PM] Can Dashboard Viewers export reports?
- [ ] [PM] Is Training and Simulations intentionally one role, or should they be separable?
- [ ] [Both] SCIM/IdP provisioning scope and attribute mapping schema — resolve before enterprise GA.
- [ ] [Both] Bulk role-change flow — resolve when org size warrants it.
- [ ] [PM] In-product access request flow vs. out-of-band — resolve when second role ships.

## Resolved

- [x] [PM] How many roles for MVP? — **Answer:** Two roles only: Full Access (unchanged) and AEP Manager (new). Additional roles are deferred. Architecture must support future role additions without rework.
