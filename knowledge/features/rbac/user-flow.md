# User Flow — Role-Based Access Control (RBAC)

---

## Entry Points

**Flow A — Role Assignment During Invite**
Full Access admin navigates to User Management → clicks "Invite users" CTA.

**Flow B — Role Change for Existing User**
Full Access admin views a user row in the User Management table → clicks the role badge on that row.

**Flow C — Scoped User First Login**
Any non-Full-Access user activates their invite and logs in for the first time.

**Flow D — Scoped User Hits Gated Surface**
Any scoped user navigates to a platform surface outside their role boundary (via direct URL or unexpected nav path).

---

## Flow A: Role Assignment During Invite (Happy Path)

1. Full Access admin clicks "Invite users" on the User Management table.
2. A drawer opens with one empty invite row: email input field + role selector dropdown (defaulting to "Dashboard Viewer") + row remove icon.
3. Admin enters the first invitee's email address.
4. Admin clicks the role selector and sees four options, each with a name and one-line description. Admin selects a role.
5. Admin clicks "Add another" to add additional rows and repeats steps 3–4 for each invitee.
6. Admin clicks "Send invites."
7. System validates each row: email format, role selected, no duplicates.
8. On success: drawer closes, toast notification appears ("3 invites sent"), and new user rows appear in the User Management table with "Pending" status and the assigned role badge.
9. Each invited user receives an activation email. Upon activation, their session is immediately scoped to the assigned role.

**Decision points:**
- Admin submits with a missing role on one row → inline validation error: "Select a role." Drawer stays open.
- Admin submits with invalid email format → inline validation error on affected row. Drawer stays open.
- Admin submits with a duplicate email (already a platform user) → inline warning: "This email is already in your account." Drawer stays open.
- Invite API call fails → per-row error indicators. Toast: "Some invites couldn't be sent. Review the errors below." Drawer stays open for correction.

---

## Flow B: Role Change for Existing User (Happy Path)

1. Full Access admin views the User Management table.
2. Admin locates the target user (via search or role filter).
3. Admin clicks the role badge on the user's row.
4. An inline role selector popover appears anchored to the badge. The current role has a checkmark. Three other roles are listed with one-line descriptions.
5. Admin clicks a new role.
6. A confirmation modal appears:
   - Title: "Change [Name]'s role?"
   - Body: "[Name] will be changed from [Current Role] to [New Role]. Their access will update on their next page load."
   - If user has an active campaign: an inline warning badge appears: "This user has an active campaign. It will continue after the role change."
   - Primary action: "Change role" (right)
   - Secondary action: "Cancel" (left)
7. Admin clicks "Change role."
8. Modal closes. Role badge on the user row updates immediately to the new role. Toast: "[Name]'s role has been updated."
9. The role change is recorded in the audit log with timestamp, acting admin, previous role, and new role.

**Decision points:**
- Admin clicks cancel → modal closes, no change made, badge remains unchanged.
- Admin is the last Full Access admin and selects a scoped role for themselves → popover shows Full Access as disabled with tooltip: "You're the only Full Access admin." Other options are still selectable but not applicable. (Note: if admin is not the last Full Access, they can change their own role.)
- Role change API call fails → modal stays open, inline error: "Something went wrong. Try again." Retry button in modal.

---

## Flow C: Scoped User First Login (Happy Path)

1. Scoped user activates their invite via the activation email link.
2. User completes account setup (password, profile).
3. User lands on the platform home. A persistent informational banner appears at the top of the page.
4. Banner reads: "[Role Name] access — [One-line summary of what this role can do]. Some platform features aren't available to your role."
5. User clicks dismiss (X icon). Banner disappears and does not reappear.
6. User sees primary navigation showing only the surfaces within their role boundary. Gated surfaces have no visible nav item.
7. User's role badge is visible in the account menu or header.

**System responses:**
- Banner is shown only on first login (once). After dismissal, it is never shown again for this user.
- Navigation renders only permitted surfaces. There is no greyed-out state for restricted surfaces.

---

## Flow D: Scoped User Hits Gated Surface (Permission-Denied)

1. Scoped user navigates to a gated surface via direct URL or an unexpected path.
2. Platform renders the permission-denied empty state (not a 404).
3. Empty state shows:
   - Heading: "You don't have access to [Surface Name]."
   - Body: "Your current role is [Role Name]."
   - Primary CTA: "Request access" (triggers in-app notification to Full Access admins, or pre-fills a mailto: as v1 fallback).
   - Secondary link: "Go back to [last visited surface]."
4a. If user clicks "Request access": system sends an in-app notification to all Full Access admins: "[User Name] is requesting access to [Surface Name]. Their current role is [Role Name]." Toast to user: "Your request has been sent to your admin."
4b. If user clicks "Go back": user navigates to their last accessible surface.

**System responses:**
- The URL is not a 404 — the route exists and is reachable, but renders the permission-denied state for unauthorized roles.
- API-layer enforcement: any write action attempted via the API from an unauthorized role returns 403 Forbidden, regardless of client-side state.

---

## Edge Cases

| Edge case | How it is handled in the flow |
|---|---|
| Last Full Access admin attempts self-downgrade | Inline badge tooltip prevents selection. Block with message: "You're the only Full Access admin. Assign Full Access to another user first." |
| Role downgrade for active session user | Role change takes effect on the user's next page load or API call. Modal copy informs the acting admin. No forced logout. |
| Pending invite — role changed before activation | Admin can click the "Pending" user's role badge and change the role before activation. The activation email already sent is superseded — the user activates with the new role. |
| Role change API call fails mid-confirmation | Modal remains open with inline error and retry button. No partial state. |
| Full Access admin deactivated when they're the last Full Access | System prevents deactivation: "You're the only Full Access admin. Assign Full Access to another user before deactivating your account." |
| Role change while user has an active campaign | Campaign continues unaffected. Modal shows inline warning: "This user has an active campaign." |
| Scoped user navigates to User Management via direct URL | Permission-denied empty state: "You don't have access to User Management." |
| Organization with only Dashboard Viewers | User Management shows an onboarding prompt: "No functional admins yet. Invite an AEP Manager, Training & Simulations Manager, or Full Access admin to get started." |
| User Management table with 100+ users | Role filter dropdown above the table narrows the view. Table pagination applies. |
| AEP Manager views Dashboards | Sees AEP-scoped metrics only. Dashboard component renders with AEP data filtered at the API level. |

---

## Exit States

**Flow A (Invite):**
- Success: drawer closed, toast confirmation, user rows added with Pending status.
- Partial failure: drawer stays open with per-row error indicators.
- Abandoned: admin closes drawer, no invites sent, no state change.

**Flow B (Role change):**
- Confirmed: modal closed, role badge updated, audit log entry created, toast confirmation.
- Cancelled: modal closed, no change.
- Failed: modal stays open with retry option.

**Flow C (First login):**
- Banner dismissed: banner removed, scoped session continues normally.
- Banner not dismissed: banner persists until dismissed. No timeout.

**Flow D (Permission-denied):**
- Request access sent: toast confirms, user remains on the permission-denied state.
- Go back: user navigates to last accessible surface.
- Neither: user is on the permission-denied state until they navigate away.
