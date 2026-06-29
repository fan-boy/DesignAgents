# Competitor Analysis — Role-Based Access Control (RBAC)
Analyzed: 2026-06-29

---

## Feature Context

Dune Security is implementing four roles — Full Access, AEP Manager, Training & Simulations Manager, and Dashboard Viewer — that gate platform surface access and write permissions. The primary design problems are: (1) how to model functional role separation in the UI, (2) how to communicate permission boundaries to scoped users at first login and at gated surfaces, and (3) how to make role assignment friction-free for Full Access admins managing growing orgs.

---

## Competitors Reviewed

| Competitor | Reason selected | Confidence |
|---|---|---|
| KnowBe4 | Incumbent SAT benchmark; most documented RBAC model in the space | High — public docs + third-party analysis |
| Adaptive Security | Direct competitor in registry; ships a 6-role functional RBAC model closest to Dune's | High — public blog post with role details |
| Proofpoint SAT | Named in registry for admin workflow benchmarking; has documented admin role tiers | Medium — limited public detail on per-role permissions |
| Hoxhunt | Named in registry for admin workflows; SCIM/IdP provisioning documented | Low for RBAC specifics — limited public role documentation |

---

## Workflow Comparison

### KnowBe4 — KSAT Security Roles

**Role model:** Three fixed tiers (Account Owner, Full Admin, Group Admin) plus an optional Security Roles layer for higher-tier subscriptions.

- **Account Owner** — one per account, manages billing, all features, admin creation/deletion. Cannot be demoted without support intervention. Does not consume a learner seat.
- **Full Admin** — full console access across all surfaces (phishing, training, reporting, user management). No billing access. Scope cannot be restricted.
- **Group Admin** — scoped to assigned groups. Can manage training campaigns, phishing simulations, and reporting only within their groups. Cannot access users or data outside assigned groups, account settings, or billing.
- **Learner (User)** — access to learner portal only; consumes a licensed seat.

**Security Roles (Advanced/Platinum/Diamond tiers):** A custom role builder layered on top of the base tier model. Admins create a named role, attach it to one or more groups, then configure granular permission toggles (read/write/none) for: Phishing Campaigns, Training Campaigns, User Management, Reporting, Phishing Templates, Landing Pages. Permissions are **additive** — a user in multiple groups inherits all permissions across all their groups' Security Roles.

**Entry point:** Users tab → select user → Assign Admin Functions, or Security Roles tab → create role → attach group(s) → configure permissions.

**Role assignment UX:** Admin selects a user row, clicks "Make Admin" or assigns a Security Role from the user detail view. For Security Roles, the flow is role-first (create the role, then attach groups to it) rather than user-first (assign a role to a user).

**Scoped dashboards:** Group Admins and Security Role holders see reporting data filtered to their assigned groups only. The dashboard UI is identical — data is filtered at the query level, not a different UI surface.

**Feedback states:** Role changes take effect immediately. No confirmation modal documented for role changes. No audit log UI described publicly.

**Trust model:** Security Roles creation is admin-only. No self-serve access escalation path observed.

**SCIM/IdP provisioning:** Supported via ADI (Active Directory Integration), SCIM, and Google User Provisioning. Role attributes can be mapped from IdP.

**Confidence notes:** Role model is well-documented via third-party analysis. Security Roles UI specifics (modal copy, error states) are inferred, not observed directly.

---

### Adaptive Security — Functional RBAC

**Role model:** Six named functional roles, each mapped to a product surface or capability set.

1. **Account Owner** — full platform access; can assign all roles including Team Admin.
2. **Team Admin** — full platform access; can assign all roles except Account Owner.
3. **Training Manager** — scoped to training campaigns and content.
4. **Content Manager** — create and edit training and phishing content; manage SCORM imports.
5. **Phishing Manager** — manage phishing content, campaigns, and triage.
6. **Report Viewer** — dashboards and insights only; no editing rights.

**Entry point:** Admin portal → Admin Access section → "Add an Admin" (new user) or three-dot menu → "Change Role" (existing user).

**Role assignment UX:** User-first model — navigate to a user, open a context menu, select "Change Role." New admins are added explicitly via an "Add an Admin" CTA. The role names are functional and descriptive rather than permission-level labels.

**Scoped dashboards:** Report Viewer is an explicitly named read-only role scoped to dashboards and insights. Training and Phishing Managers likely see surface-scoped data, but this is inferred from the role model, not observed directly.

**Trust model:** Only Account Owners and Team Admins can modify roles. No self-serve escalation path observed.

**SCIM/IdP provisioning:** Supported. Role mapping is handled via IdP attributes.

**Confidence notes:** Role names and assignment flow are observed from the Adaptive blog post. Permission boundaries within each role are inferred from role descriptions, not observed in the product directly.

---

### Proofpoint SAT — Multi-tier Admin Roles

**Role model:** Named admin tiers include Super Admin, Training Admin, and User Admin. Proofpoint Essentials exposes a 5-role model with customizable access control toggles per module.

**Access control customization:** Admins navigate to Administration → Account Management → Access Control, then use show/hide toggles per module per role. User-level access control takes priority over global level.

**Read-only pattern:** Proofpoint Essentials documents a "Read Only Admin User" role explicitly — users with this role can see but not change anything. This is a named, first-class role, not an implied state.

**SCIM/IdP provisioning:** Supported via Microsoft Entra ID SSO and provisioning.

**Confidence notes:** Medium confidence. Role names are documented in training course materials. Actual UI flow for role assignment, confirmation states, and dashboard scoping are not publicly documented in detail.

---

### Hoxhunt — Multi-tenant Admin Model

**Role model:** Hoxhunt primarily documents a multi-tenancy model — Owner Organization with multi-tenant Admin users who have cross-org access (Admin Portal and Insights only). Single-tenant role granularity is limited in public docs.

**SCIM provisioning:** Full SCIM 2.0 support. Role attributes provisioned from IdP (Microsoft Entra ID documented). User data syncs automatically when IdP changes.

**Confidence notes:** Low confidence on RBAC specifics. Hoxhunt's primary differentiation is gamification and behavioral training, not admin tooling. Their RBAC docs are sparse or behind authentication.

---

## Patterns Worth Adopting

**Functional role names over permission-level labels.** Adaptive Security's approach — Training Manager, Phishing Manager, Report Viewer — names roles by what the person does, not what they're allowed to do. This is clearer for admins assigning roles and for users understanding their own access. "Dashboard Viewer" (Dune) is fine; "AEP Manager" and "Training & Simulations Manager" follow the same functional-name convention. This is the right pattern.

**User-first role assignment flow.** Adaptive Security's three-dot → "Change Role" pattern (per user) is simpler than KnowBe4's role-first flow (create role → attach groups → attach users). For Dune's relatively small role set (4 fixed roles), user-first is more natural and lower friction for admins.

**Scoped dashboard data, same UI surface.** KnowBe4 filters dashboard data at the query level rather than showing a different UI per role. This reduces design complexity: the same dashboard component renders different data depending on the user's role. Dune should adopt this pattern rather than building separate dashboard surfaces per role.

**Read-only as a first-class named role.** Both Adaptive Security (Report Viewer) and Proofpoint (Read Only Admin) name the read-only role explicitly. This is cleaner than describing it as "no write access" — it sets an expectation from the moment of assignment.

**SCIM as table stakes.** Every competitor reviewed supports SCIM. Enterprise buyers will ask about IdP provisioning before deployment. Treating SCIM as optional risks losing enterprise deals where the security team manages access centrally via Okta or Azure AD.

**Additive permissions create complexity.** KnowBe4's Security Roles layer allows permissions to stack across groups, which is powerful but creates hard-to-predict permission states. Dune's fixed four-role model (no stacking) is intentionally simpler and is the correct call for v1. Avoid additive permission models.

---

## Anti-Patterns to Avoid

**Role-first assignment flow for small role sets.** KnowBe4's Security Roles workflow (create role → attach groups → configure permissions) is designed for large orgs with many custom roles. For a fixed four-role model, this adds unnecessary abstraction. Users shouldn't need to "create" a role to assign an existing one.

**Hiding vs. disabling gated nav items without context.** No competitor publicly documents their hidden-vs-disabled choice, which suggests this is often left to implementation. The risk of purely hiding items is that new scoped users have no awareness of what they're missing — they may assume setup is broken. Adaptive Security uses "Add an Admin" as a distinct CTA rather than showing the admin interface to non-admin users at all. The correct pattern: hide the nav item but provide a first-login modal or persistent banner that states the user's role and what they can access.

**No access request path at the permission-denied state.** None of the competitors reviewed document an in-product access request mechanism. All use "contact your admin" copy. This is a gap across the industry — users who hit a gated surface have no structured path to request access. The workaround (Slack the admin) is out-of-band and unauditable. Dune has an opportunity to build a lightweight access request flow or at minimum a "Request access" button that generates a pre-filled email or in-app notification to the Full Access admin.

**Session behavior on role change undocumented.** No competitor publicly addresses what happens to an active session when a user's role is changed. This is a security-significant gap that Dune must address explicitly — the PRD's "on next page load or API call" approach needs validation against Dune's security posture.

---

## Differentiation Opportunities

**AEP as a first-class, named surface.** KnowBe4 and Adaptive Security treat phishing simulation as one surface among several. Dune's AEP (AI-driven spear phishing) is a distinct, premium capability — naming the role "AEP Manager" signals that this is a differentiated capability, not just "phishing campaigns." This reinforces Dune's AI personalization positioning at the role model level.

**Role-change awareness for active campaigns.** No competitor documents a warning when an admin changes a role for a user with an active campaign. Dune's PRD notes that campaigns continue uninterrupted — surfacing this clearly in the role change confirmation ("This user has an active campaign. Their access will change but the campaign continues.") is a trust signal that no competitor currently provides.

**In-product access request flow.** The "contact your admin" dead-end is universal among competitors. A lightweight "Request access to [surface]" button on the permission-denied state — which sends a structured in-app notification to Full Access admins — would be a first in the SAT/HRM category. It turns a trust-eroding dead end into a managed workflow.

**First-login role awareness.** Scoped users receive no onboarding about their permissions in any competitor reviewed. A first-login modal or persistent header banner ("You have Training & Simulations Manager access. Some platform features aren't available to your role.") prevents support tickets from users who assume setup is broken.

---

## Implications for Design

1. **Build a role × surface × action type state matrix before opening Figma.** Every surface (AEP, Training, Simulations, Dashboards, User Management) needs a defined state for each of the four roles before any screen can be mocked. KnowBe4's group-scoped model shows how quickly this becomes complex without a matrix as the source of truth.

2. **Use user-first role assignment (not role-first).** The inline role selector on the user row (as described in the PRD) is the correct pattern. Confirm that the invite flow and role-change flow both start from the user, not from a "Manage Roles" configuration screen.

3. **Design the Dashboard as a single component with role-scoped data.** Do not build separate dashboard surfaces per role. Filter data at the query/API level; the UI component is identical. The visual design challenge is: what does an AEP Manager's dashboard look like when it only shows AEP metrics? The empty state for missing surfaces (training data not visible) must be role-aware, not a generic empty state.

4. **Name the read-only role clearly.** "Dashboard Viewer" is functional and follows the Adaptive Security pattern. Confirm the name is final before building any badge components.

5. **Design the permission-denied state as a workflow endpoint, not a dead end.** Add an action to the permission-denied empty state — at minimum a "Request access" button with a pre-filled admin notification. This is an unmet need across the category.

6. **Plan for SCIM in v1 scope or explicitly defer it.** Every enterprise competitor supports SCIM. If it's not in v1, define how role assignment will work during bulk onboarding from an IdP and communicate the limitation clearly in the product.

7. **Address first-login role onboarding.** A role-aware onboarding banner or modal on first login removes the support burden of scoped users thinking their setup is broken.

---

## Confidence Notes

- KnowBe4 role model: high confidence — documented via Stitchflow user management guide and public blog post on delegated permissions.
- Adaptive Security role model: high confidence — observed directly from product blog post.
- Proofpoint SAT: medium confidence — role names from training course materials; UI flow is inferred.
- Hoxhunt: low confidence for RBAC specifics — most documentation is behind authentication.
- No competitor's permission-denied UX, session invalidation behavior, or dashboard scoping specifics were directly observed — all are inferred from role model documentation.
