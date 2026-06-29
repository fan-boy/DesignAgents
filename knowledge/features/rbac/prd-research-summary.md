# PRD Research — Role-Based Access Control (RBAC)
Last updated: 2026-06-29

---

## Feature Summary

RBAC introduces four roles — **Full Access**, **AEP Manager**, **Training & Simulations Manager**, and **Dashboard Viewer** — that gate which platform surfaces and actions each user can access. The primary actor is a Full Access admin who assigns and manages roles during user invites and from the User Management table. Secondary actors are all scoped users who experience the platform through their role's restricted lens. Success means scoped users cannot access surfaces outside their boundary (neither visually nor via API), and Full Access admins can reliably assign and change roles without workflow friction.

**Missing from the PRD:** No success metrics are specified. No mention of SSO/SCIM provisioning, bulk role operations, or multi-tenant handling. The relationship between Dashboard Viewer's "all dashboard views" and scoped managers' filtered dashboards creates a material contradiction that needs resolution.

---

## Gaps and Ambiguities

1. **Dashboard Viewer scope contradicts scoped manager scope.** The PRD states Dashboard Viewers see "all dashboard views" (read-only), while AEP Managers and Training & Simulations Managers see only their surface's data. This creates an inversion: a Dashboard Viewer has broader data visibility than a functional manager. Is this intentional? If yes, the Dashboard Viewer role is effectively a reporting/audit role with cross-surface read access. If no, the scope for each role needs to be reconciled. This is the single most consequential ambiguity in the PRD — it changes the role model fundamentally.

2. **Export is undefined for Dashboard Viewer.** The PRD says export/edit/configuration actions are "hidden or disabled" for Dashboard Viewers. Export is not a write action — it's a read action that produces a file. Many reporting workflows depend on export. Whether Dashboard Viewers can export charts, tables, or raw data must be specified before the dashboard design can be finalized.

3. **Granular write permissions within a surface are unspecified.** The PRD says Training & Simulations Managers can "create, assign, and manage" content — but "manage" is undefined. Can they delete campaigns? Remove training assignments from users? Archive modules? Each of these has a distinct permission boundary and a distinct UX implication. AEP Managers have the same gap.

4. **SSO and SCIM provisioning are absent.** Enterprise customers routinely provision users via an identity provider (Okta, Azure AD, etc.) with role attributes mapped to application roles. If SCIM is planned, the role model needs a defined attribute mapping schema. If SCIM is out of scope for v1, that must be explicit, because it will be the first question from any enterprise buyer.

5. **Bulk role operations are not addressed.** The PRD describes single-user role changes via an inline selector. For organizations with 50–500 users, admins will need to reassign roles in bulk (e.g., onboarding a new team). No bulk flow is specified.

6. **The "Training & Simulations Manager" bundles two functionally distinct capabilities.** Training module management and simulated phishing campaign management are typically operated by different team members (L&D vs. security ops). Bundling them into one role means you cannot grant simulation access without also granting training access. Confirm whether this is an intentional simplification or a gap in role granularity.

7. **Role change "on next page load" is a soft enforcement boundary.** A user whose role is downgraded mid-session retains their current access until they reload or make an API call. For high-privilege downgrades (Full Access → scoped), this window may be unacceptable from a security posture standpoint. Whether a forced logout or session invalidation is required must be an explicit Eng/security decision, not a default.

8. **The audit log surface is not described.** The PRD specifies what the audit log records but not where it lives in the UI. Is it a dedicated surface? A sub-section of User Management? Is it accessible to Dashboard Viewers? Scoped managers? This gap will block handoff.

---

## Missing States

### System states
- Role change API call fails mid-confirmation (network error, server error) — what does the admin see? Does the modal stay open or dismiss?
- User invite email fails to deliver — what feedback does the admin receive? Is the user shown in User Management in a "pending" state?
- Session token refresh during a role downgrade — if the token caches the old role, how long before the new role takes effect?

### Permission states
- AEP Manager navigates to a URL for a Training surface they once had access to (before a role change) — permission-denied state must handle the context of "you used to have access here"
- Dashboard Viewer attempts to configure a dashboard widget (if widgets are configurable) — is configuration hidden or shown as disabled with tooltip?
- Scoped manager tries to access User Management — not shown in nav, but direct URL should return permission-denied, not 404
- Full Access admin views their own role badge — can they change their own role? The PRD prevents downgrading only if they're the last Full Access admin, implying self-role-change is otherwise permitted

### Content states
- Organization has only one user (the Full Access admin) — invite screen is the empty state entry point
- All users in the org are Dashboard Viewers — no functional work can happen; should the platform surface a warning or onboarding prompt?
- User Management table with many users (100+) — filtering, sorting by role must be available; PRD does not specify
- User has a pending invite (not yet activated) — can their role be changed before they accept? What is the pending state UX?

### Action states
- Admin bulk-invites 20 users with mixed roles — what is the success confirmation state? Individual row-level results or a summary?
- Admin changes role for a user who is currently running an active campaign — PRD says the campaign continues, but does the admin receive any warning before confirming the role change?
- Admin attempts to deactivate themselves — PRD covers role downgrade protection but not self-deactivation; are these separate guards?

### Responsive / Accessibility
- Role selector dropdown in the invite table — keyboard navigation through role options must be tested; multi-row invite with per-row selectors is complex for keyboard users
- Role badge in the header — must meet WCAG contrast requirements across all four role variants and color themes
- Permission-denied state — must be announced to screen readers as a meaningful error, not a silent page change
- Mobile: User Management table with role badges and inline selectors may not be feasible at small viewports — confirm mobile is out of scope or specify breakpoint behavior

---

## Questions for PM / Eng

1. `[PM]` Is the Dashboard Viewer's access to "all dashboard views" intentional — meaning they can see cross-surface data that a functional manager cannot? Or should Dashboard Viewer also be scoped to the surfaces they're associated with?
2. `[PM]` Can Dashboard Viewers export reports and data? If not, what read-only actions are they permitted beyond viewing charts?
3. `[PM]` Does "manage" within the AEP Manager and Training & Simulations Manager roles include delete, or only create/edit/assign?
4. `[Both]` Is SCIM/IdP provisioning in scope for v1? If yes, what is the role attribute mapping schema? If no, what is the plan to communicate this limitation to enterprise buyers?
5. `[PM]` Is the bundling of Training and Simulations into one role intentional, or should there be an option for simulation-only access without training access?
6. `[Eng]` When a Full Access user is downgraded, must their session be invalidated immediately (forced re-auth), or is "on next page load" acceptable from a security standpoint?
7. `[PM]` Where does the audit log surface in the UI? Is it a dedicated Admin surface, a sub-tab in User Management, or accessible to all roles?
8. `[Both]` Is there a planned bulk role-change flow for large org onboarding, or is single-user change the only supported pattern in v1?

---

## Design Risks

**The Dashboard Viewer / scoped manager dashboard inversion.** If Dashboard Viewers see more data than functional managers, the role model will be unintuitive and may lead admins to assign the wrong role to achieve the result they want. A Training & Simulations Manager may ask why they can't see org-wide risk data that a "viewer" account can see. Resolve the scope before designing the dashboard views.

**Hidden navigation is a trust hazard for new users.** Hiding nav items entirely (rather than disabling them with a tooltip) means a new scoped user has no way to know what they're missing. If their onboarding email says "log in and go to Simulations," but Simulations doesn't appear in their nav, they'll assume a setup error. A short "Your access is scoped to X" message on first login mitigates this, but the PRD doesn't specify it.

**The role selector default (Dashboard Viewer) may create a support burden.** Defaulting all new invites to Dashboard Viewer is a sound least-privilege choice, but if admins forget to change it, functional users will be locked out of their intended surfaces and file support tickets. The invite flow must make the role selection visually prominent — not a secondary dropdown below the email field.

**"Contact your admin" dead-ends for scoped users.** The permission-denied state tells users to contact their admin, but there's no defined path for how a scoped user requests elevated access from within the platform. This will result in out-of-band requests (Slack, email) that are harder to track and audit. A lightweight access request flow (or at minimum a mailto link to the admin) would close this gap.

**Role change without active session awareness.** If a user is downgraded from Full Access while they have a write-capable surface open, they could complete an action (e.g., delete a campaign) in the window between the role change and their next API call. For destructive actions, the downgrade should either force a session check or log the action with the role state at time of execution.

---

## Teaching Notes

**RBAC is infrastructure, but it ships as UX.** The four roles are a data model that will be instantiated as UI surfaces, empty states, badge components, permission-denied pages, and nav visibility rules. Every surface in the product needs a "what does this look like for each of the four roles?" answer before Figma mocks can be considered complete. Build a state matrix across roles × surfaces × action types as the first design artifact.

**Closest existing pattern — User Management.** The User Management table already exists in the platform for Full Access admins. The RBAC work extends this surface with a role column, role badge, and inline role selector. Start by auditing the current User Management table to understand what changes are additive vs. structural.

**Stillsuit DS v2 badge component.** Role badges should use the existing status badge component. Confirm with the design system whether four new variants (one per role) need to be added, or whether existing status colors can be mapped. Avoid creating net-new badge variants without design system review — color proliferation is a common design debt source.

**Permission-denied state pattern.** Dune already has a standard empty-state pattern (Stillsuit DS v2). The permission-denied state should use this component with a consistent message structure: what the user cannot access + who to contact. The message in the PRD ("Contact your admin to request access") is a good starting point but needs a way to actually contact the admin — either a button that opens a pre-filled email or an in-product access request mechanism.

**Audit log design precedent.** If no audit log surface currently exists in the platform, this may be a net-new surface that requires its own design scope. Check whether any existing feature (e.g., campaign history) has established an audit/activity log pattern that RBAC can extend.

**Role enforcement is a two-layer problem.** The PRD correctly notes that enforcement must happen at both the UI and API layer. The design work only controls the UI layer — confirm with Eng that API-level enforcement (403 responses) is owned on the backend before designing a UI that assumes it.
