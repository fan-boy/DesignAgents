# Design Strategy — Role-Based Access Control (RBAC)
Last updated: 2026-06-29

---

## Feature Context

**Goal:** Introduce four distinct roles that gate platform surface access and write permissions so each user only operates within their functional boundary.

**Primary actor:** Full Access admin — assigns and manages roles, onboards users, resolves access issues.

**Secondary actors:** AEP Manager, Training & Simulations Manager, and Dashboard Viewer — each experiencing the platform through the lens of their role.

**Trigger:** Admin invites a new user or changes an existing user's role.

**Success:** A scoped user logs in and sees only the surfaces relevant to their role. They can complete their work without encountering unnecessary friction. If they hit a gated surface, they understand why and have a path forward.

---

## Design Goal

Make role assignment feel like a one-second decision during onboarding, and make role enforcement feel invisible during normal work — surfacing only when a scoped user needs to understand or escalate their access.

---

## Key Constraints

- Only Full Access admins can invite users, assign roles, or access User Management.
- Role enforcement is at both UI and API layers — design must not assume client-only enforcement.
- Last Full Access admin cannot downgrade their own role — the system prevents this.
- Role changes must be recorded in the audit log.
- Four fixed roles — no custom role builder in v1.
- Bulk role operations are out of scope for v1.
- SCIM/IdP provisioning is out of scope for v1.
- Dashboard Viewer scope (cross-surface vs. role-scoped) is an **open question** that materially affects the dashboard design. The strategy below treats Dashboard Viewer as a **cross-surface read-only role** (org-wide dashboard data, no write access) — based on the PRD as written. If PM resolves this differently, the scoped dashboard section must be revisited.

---

## Strategy Options

### Option A — Inline Role Assignment on User Management Table (Recommended)

Role assignment is surfaced directly in the User Management table. Each user row shows their role as a badge. Clicking the badge opens an inline popover with the four role options. Changes are confirmed via a modal. New users are invited through an inline invite form with a per-user role selector.

Role enforcement on scoped surfaces uses a **hidden nav + first-login awareness banner** pattern: gated nav items are hidden entirely from scoped users, but the first time a scoped user logs in, a persistent banner clearly states their role and what they have access to.

**Why recommended:** Follows Adaptive Security's user-first assignment pattern, which is simpler than KnowBe4's role-first flow. Inline role badges make the current role visible without a separate view. The first-login banner addresses the biggest anti-pattern identified in competitor research — scoped users with no awareness of their boundaries.

### Option B — Dedicated Role Management Screen

A standalone "Roles & Permissions" settings screen where admins configure role definitions and assign users to roles. Users appear in a list per role.

**Rejected because:** Adds unnecessary abstraction for four fixed roles. Splits the user management and role management workflows, requiring admins to switch contexts to complete what is a single action (invite user + assign role). KnowBe4's Security Roles layer shows this adds complexity that isn't justified until the role model becomes customizable.

### Option C — Role Assignment in User Detail Drawer

Clicking a user row opens a right-anchored drawer with user details, including a role selector.

**Rejected as primary flow:** The drawer is appropriate as an edit path (clicking an existing user to see details and change their role) but is too heavyweight as the primary assignment path during bulk invites. The inline table approach is faster for the invite-time use case. The drawer can serve the edit-existing-user sub-flow.

---

## Recommended Strategy: Inline Role Assignment + First-Login Awareness

### Four surfaces, four design problems

The RBAC feature is actually four distinct design problems that must be solved together:

1. **Assignment** — how Full Access admins assign roles when inviting users and when changing existing users' roles.
2. **Enforcement** — how gated surfaces behave for scoped users (navigation visibility, URL-direct access, API calls).
3. **Awareness** — how scoped users understand their role and what it means when they first log in.
4. **Escalation** — how scoped users can request elevated access when they need it.

No competitor solves all four well. Dune's design must address all four.

---

### Problem 1: Assignment

**During invite:** The invite form is a multi-row table (one row per invitee). Each row has: email input, role selector (defaulting to Dashboard Viewer), and a remove row action. The role selector is a dropdown with all four roles and a one-line description of each. Submit sends all invites at once; per-row validation surfaces inline (email format, missing role).

**Default to Dashboard Viewer.** This enforces least-privilege on new invitations. The role selector must be visually prominent — not a secondary detail — so admins notice it and make a conscious choice.

**For existing users:** Each user row in the User Management table shows a role badge. Clicking the badge opens an inline role selector (popover, not a full drawer). Selecting a new role triggers a confirmation modal. The modal copy:
- If the change is a downgrade: "Change [Name]'s role from [Current Role] to [New Role]? Their access will update on their next page load. Any campaigns currently running will continue."
- If the user has an active campaign: Add an inline warning line: "This user has an active campaign."
- If the admin is the last Full Access admin and is attempting self-downgrade: Block with an error inline: "You're the only Full Access admin. Assign Full Access to another user before changing your own role."

---

### Problem 2: Enforcement

**Navigation:** Gated nav items are **hidden** (not greyed out) for scoped users. This is the correct pattern for v1 — greyed nav items invite curiosity clicks and support questions. A scoped user's nav should feel complete for their role, not like a stripped-down version of a full admin's nav.

**URL-direct access:** Gated surfaces return a **permission-denied empty state** (not 404) with: surface name, role currently held, and a "Request access" CTA. The state uses the Stillsuit DS v2 empty-state pattern.

**API layer:** 403 responses for any write action outside role boundary. This is an Eng deliverable — the design must not assume client-only enforcement.

**Dashboard for scoped roles:** AEP Manager and Training & Simulations Manager see dashboard data scoped to their surface only. Dashboard Viewer sees all dashboard data (cross-surface) in read-only mode. The dashboard UI component is the same for all roles — data is filtered at the API layer. Export is available to Dashboard Viewers (read-only action); not available to scoped managers for data outside their surface.

---

### Problem 3: Awareness

**First-login banner:** A scoped user's first session surfaces a persistent informational banner at the top of the page: "You have [Role Name] access on Dune Security. [One-line summary of what this role can do.] Questions? Contact your admin." The banner has a dismiss button and does not reappear after dismissal.

The banner should not be a blocking modal — scoped users should be able to start working immediately. It is informational and dismissible.

**Role badge in header/account menu:** The user's active role is always visible in the account menu or header as a small role badge. This passive signal reduces confusion over time.

---

### Problem 4: Escalation

**Permission-denied state:** Every gated surface's empty state includes a "Request access" button. Clicking it generates a pre-filled in-app notification to all Full Access admins: "[User Name] is requesting [Role Name] access to [Surface Name]. Their current role is [Current Role]." The notification appears in the Full Access admin's notification center.

This is a differentiated pattern — no competitor provides a structured escalation path. It closes the "contact your admin" dead end and creates an auditable request trail.

---

## Risks and Tradeoffs

**Dashboard Viewer scope is unresolved.** The strategy treats Dashboard Viewer as cross-surface read-only — broader data visibility than functional managers. If PM intends scoped dashboard access for Dashboard Viewers (same as managers), the first-login banner copy, the permission matrix, and the dashboard data filtering logic all change. Do not begin Figma work on the dashboard until this is confirmed.

**Hidden nav is invisible to new users.** Hiding nav items entirely means a new AEP Manager has no way to know that Training, Simulations, and User Management exist. The first-login banner partially mitigates this, but a scoped user who dismisses the banner immediately has no persistent reminder. This is a known tradeoff — the alternative (greyed nav items) creates more noise for users who never need those surfaces.

**"Request access" notification requires a notification center.** If Dune does not have an existing in-app notification center, the access request feature requires a net-new surface. An email fallback (clicking "Request access" opens a pre-filled mailto:) is a viable v1 shortcut that doesn't require building a notification system.

**No SCIM in v1 is an enterprise objection risk.** Enterprise buyers will ask about IdP provisioning in the first demo. Dune's v1 answer should be explicit: manual invite only, SCIM on the roadmap. This should be visible in the product as a "Coming soon: directory sync" note in User Management — not silent.

---

## Wireframe Plan

### Screen 1: User Management Table (extended)

**Role:** Primary admin surface for viewing and managing all platform users and their roles.

**Layout:** Full-width table, standard Stillsuit DS v2 table pattern. Page header with "Invite users" primary CTA, search input, and role filter dropdown.

**Table columns:** Name, Email, Role (badge), Status (Active / Pending / Deactivated), Last Active, Actions (three-dot menu).

**Role badge:** Uses Stillsuit DS v2 status badge. Four variants: Full Access, AEP Manager, Training & Simulations Manager, Dashboard Viewer. Clickable for Full Access admins — opens inline role selector popover.

**Inline role selector popover:** Appears anchored to the badge. Four options, each with a role name and one-line description. Selected role has a checkmark. Selecting a new role triggers the confirmation modal.

**Role filter:** Dropdown above the table. "All roles" default, then the four role names. Filters table rows.

**Empty state:** "No users yet. Invite your first user." with "Invite users" CTA.

**Loading state:** Skeleton rows.

**Edge cases:**
- 100+ users: table pagination, role filter is the primary navigation shortcut.
- Pending invite user: role badge shows "Pending" state. Clicking opens the role selector — admin can change role before activation.
- Last Full Access admin row: clicking their own role badge shows the selector with Full Access disabled and a tooltip: "You're the only Full Access admin."

---

### Screen 2: Role Change Confirmation Modal

**Role:** Confirmation gate before a role change is applied. Prevents accidental changes.

**Trigger:** Admin selects a new role from the inline popover on Screen 1.

**Layout:** Modal (max 560px). DS modal pattern. Destructive action on right, cancel on left.

**Content:**
- Title: "Change [Name]'s role?"
- Body: "[Name] will be changed from [Current Role] to [New Role]. Their access will update on their next page load."
- If downgrade to non-manager role: "Any campaigns currently running will continue."
- If user has active campaign: Inline warning badge: "This user has an active campaign."
- If self-downgrade (not last admin): "You're changing your own role. You will lose Full Access immediately."

**Primary action:** "Change role" (right, non-destructive style — this is a reversible change).
**Secondary action:** "Cancel" (left).

**Error state:** If API call fails, modal remains open with an inline error: "Something went wrong. Try again." with a retry option.

---

### Screen 3: Invite Users Flow

**Role:** Multi-user invite with role assignment per invitee.

**Trigger:** "Invite users" CTA on User Management table.

**Layout:** Modal or full-width drawer (depends on max expected invite volume — drawer recommended if >5 users is common). DS drawer pattern (480px).

**Content:**
- Drawer header: "Invite users"
- Invite table: rows with Email input, Role selector (dropdown, defaults to Dashboard Viewer), Remove row icon.
- "Add another" link below the table to add a row.
- Role selector shows four options with one-line descriptions on hover/focus.
- Submit button: "Send invites" (primary, right-anchored footer).

**Validation:**
- Email format: inline on blur.
- Missing role: inline on submit attempt: "Select a role."
- Duplicate email across rows: inline warning.

**Success state:** Drawer closes. Toast: "[N] invite(s) sent." User Management table updates with new Pending rows.

**Error state:** Per-row error for failed invites (e.g., email already in use). Drawer stays open for correction.

---

### Screen 4: Permission-Denied Empty State

**Role:** Endpoint for scoped users who attempt to reach a gated surface (via direct URL or any unexpected navigation path).

**Trigger:** Any scoped user navigates to a surface outside their role boundary.

**Layout:** Full-width empty state. DS empty-state pattern. Centered in the content area.

**Content:**
- Icon: lock or shield (DS empty-state icon slot).
- Heading: "You don't have access to [Surface Name]."
- Body: "Your current role is [Role Name]. Contact your admin to request access, or use the button below."
- Primary CTA: "Request access" — triggers in-app notification to Full Access admins (or pre-fills mailto: as v1 fallback).
- Secondary link: "Back to [last visited surface]" — prevents dead end.

**Variants:** One per gated surface (AEP, Training & Simulations, User Management). Surface name in the heading is dynamically filled.

---

### Screen 5: First-Login Role Awareness Banner

**Role:** Informs a scoped user of their access level on their first session. Prevents the "setup is broken" support pattern.

**Trigger:** First login for any non-Full-Access user.

**Layout:** Persistent informational banner at the top of the page, above the main content area. DS banner/alert component (informational variant, not warning or error).

**Content:**
- "[Role Name] access — You can [one-line summary of what this role enables]. Some platform features aren't available to your role."
- Dismiss button (X icon). Banner does not reappear after dismissal.

**Role-specific copy:**
- AEP Manager: "AEP Manager access — You can create and manage AI Email Phishing campaigns."
- Training & Simulations Manager: "Training & Simulations Manager access — You can create training modules and manage simulated phishing campaigns."
- Dashboard Viewer: "Dashboard Viewer access — You can view all reports and dashboards. You don't have access to create or edit content."

---

### Screen 6: Scoped Dashboard (Role-Filtered)

**Role:** Dashboard surface adapted for scoped managers and Dashboard Viewers. Same UI component, different data scope.

**AEP Manager view:** Shows AEP campaign performance metrics only. Charts, tables, and filters are scoped to AEP data. No training completion, simulation, or org-level risk data. Empty state if no campaigns yet: "No AEP campaigns yet. Create your first campaign to see data here."

**Training & Simulations Manager view:** Shows training completion rates, simulation results, and related metrics. No AEP data. Empty state scoped to their surface.

**Dashboard Viewer view:** Shows cross-surface data (all surfaces' metrics) in read-only mode. All interactive filters and chart controls work. Export is available (read-only action). Configuration and edit actions for dashboard widgets are hidden.

**Full Access view:** Unchanged from current dashboard — full data, full write access.

**Design note:** These are not four separate dashboard screens — they are the same dashboard component rendering role-filtered data. The role filter is applied at the API layer. The only visual difference is the presence or absence of data categories and the export/configure controls.

---

### Screen 7: Audit Log (Sub-tab in User Management)

**Role:** Record of all role assignment and change events. Trust and compliance surface for Full Access admins.

**Location:** Sub-tab within User Management (e.g., "Users" tab | "Activity log" tab).

**Trigger:** Full Access admin navigates to User Management → Activity log tab.

**Layout:** Full-width table. DS table pattern.

**Columns:** Timestamp, Actor (admin who made the change), User affected, Change (Previous Role → New Role or Invited as [Role]).

**Filters:** Date range, actor, affected user, role type.

**Empty state:** "No activity yet. Role changes will appear here."

**Access:** Full Access admin only. The Activity log tab is not visible to any scoped role.

---

## Open Issues

These questions remain unresolved and must be answered before Figma work proceeds on the affected screens:

1. **[PM — Blocks dashboard design]** Is Dashboard Viewer access to all dashboard data intentional (cross-surface read-only), or should it be scoped like functional managers?
2. **[PM — Blocks dashboard design]** Can Dashboard Viewers export reports?
3. **[PM — Informs screen copy]** Does "manage" for scoped roles include delete, or only create/edit/assign?
4. **[Both — Informs User Management scope]** Is SCIM explicitly deferred to post-v1? If yes, add "Directory sync coming soon" note to User Management.
5. **[Eng — Informs modal copy and session behavior]** Does a Full Access downgrade require immediate session invalidation, or is next-page-load acceptable?
6. **[PM — Informs notification design]** Does Dune have an in-app notification center? If not, "Request access" must fall back to a pre-filled mailto: link for v1.

---

## Next Design Actions

1. **Confirm Dashboard Viewer scope with PM** before designing any dashboard screens. This is the highest-priority open question — it determines whether the dashboard is one component or two different experiences.
2. **Audit the current User Management table** to understand what columns, actions, and patterns already exist before extending it with the role column and badge.
3. **Build the role × surface × action type permission matrix** as a Figma/doc artifact before any screen mocks. Columns: role name. Rows: AEP, Training, Simulations, Dashboards (Viewer/Manager), User Management, Audit Log, Risk Score Config, Smart Groups, Adaptive Workflows. Cells: Full access / Read only / Hidden / N/A.
4. **Confirm Stillsuit DS v2 badge variants** with the design system owner. Four new badge colors/labels may need to be added; do not create them without DS review.
5. **Design Screen 1 (User Management table) first.** It is the entry point for all role assignment flows and the surface Full Access admins will return to most. Get it right before branching to the invite flow, role change modal, and audit log.
6. **Decide v1 escalation mechanism**: in-app notification center vs. mailto: fallback. This determines whether "Request access" CTA is buildable in v1 or needs a simpler implementation.
