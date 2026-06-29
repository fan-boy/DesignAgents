Role-Based Access Control (RBAC) governs which platform surfaces and actions are available to each user of the Dune Security platform. Rather than giving every admin unrestricted access, RBAC introduces four distinct roles — **Full Access**, **AEP Manager**, **Training & Simulations Manager**, and **Dashboard Viewer** — each scoped to the specific capabilities a user's function requires. The system is managed by Full Access admins and applies across the entire platform: campaign creation, training assignment, simulated attack management, and reporting.

---

**Role Definitions**

The platform defines four roles, each with a distinct permission boundary:

| Role | Platform Access | Write Access |
|---|---|---|
| Full Access | All surfaces: AEP, Training, Simulations, Dashboards, User Management | Full — create, edit, delete, assign across all surfaces |
| AEP Manager | AI spear phishing campaign creation and management only | Create and manage AEP campaigns; no access to training, simulations, or org-level dashboards |
| Training & Simulations Manager | Training modules and simulated attack campaigns | Create, assign, and manage training and simulated phishing campaigns; no AEP access |
| Dashboard Viewer | Reporting and dashboards across all surfaces | None — read-only access to all dashboard views; cannot create, assign, or modify any content |

**Full Access** admins are the only role that can invite users, assign or change roles, and access User Management. All other roles are scoped to their platform surface and cannot view or modify users or roles.

---

**Assigning Roles During User Invite**

When a Full Access admin invites a new user to the platform, role assignment is part of the invite flow. On the invite screen, the admin enters the user's email address, then selects a role from a dropdown. The dropdown lists all four roles with a one-line description of each. The admin can invite multiple users at once; each row in the invite table has its own role selector, defaulting to **Dashboard Viewer** to enforce least-privilege on new invitations.

Once the invite is sent, the invited user receives an email with an activation link. Upon activation, their session is immediately scoped to the assigned role — they cannot access any platform surface outside their role's boundary.

If the admin attempts to send an invite without selecting a role, the system prevents submission and surfaces an inline validation message: "Select a role to continue."

---

**Changing a User's Role**

Full Access admins can change a user's role at any time from the User Management table. Each user row includes a role badge showing their current role. Clicking the badge opens an inline role selector with the four options. Selecting a new role triggers a confirmation modal: "Change [User Name]'s role to [New Role]? Their access will update immediately." The admin confirms or cancels.

On confirmation, the role change takes effect immediately — if the user is active in a session, their access is updated on the next page load or API call. There is no delayed sync. The change is recorded in the audit log with a timestamp, the acting admin's name, the previous role, and the new role.

Downgrading a user from Full Access to a scoped role does not delete or remove any content the user previously created. Campaigns, assignments, and modules remain intact and are attributed to the user. The user simply loses the ability to create new content outside their new role's boundary.

---

**Platform Surface Gating**

Each platform surface enforces the active user's role at the navigation and API level. Role enforcement is not purely visual — attempts to reach a gated surface via direct URL return a permission-denied state, not a 404.

**AEP (AI Email Phishing) surface:** Visible and writable only to Full Access and AEP Manager roles. Dashboard Viewers and Training & Simulations Managers who attempt to navigate to AEP see a permission-denied state with the message: "You don't have access to AI Email Phishing campaigns. Contact your admin to request access."

**Training & Simulations surface:** Visible and writable only to Full Access and Training & Simulations Managers. AEP Managers and Dashboard Viewers see the same permission-denied pattern.

**Dashboards & Reporting surface:** Visible to all roles. Dashboard Viewers see a fully functional read-only view — all charts, tables, and filters work as expected, but export, edit, and configuration actions are hidden or disabled. Scoped roles (AEP Manager, Training & Simulations Manager) see dashboard data only for the surfaces within their permission boundary. An AEP Manager's dashboard shows AEP campaign performance only; a Training & Simulations Manager's dashboard shows training and simulation metrics only.

**User Management surface:** Visible and writable only to Full Access admins. All other roles do not see the User Management navigation item.

---

**Role Badge and Navigation State**

Each user's active role is visible in the platform header or account menu as a role badge (e.g., "AEP Manager"). Navigation items for surfaces outside the user's role are hidden — not greyed out — to avoid surfacing unreachable destinations. This applies to primary navigation, secondary navigation, and any quick-action menus.

---

**Integration Points**

| Integration | Description |
|---|---|
| Risk Scoring Engine | Dashboard Viewers and scoped managers can view risk score outputs but cannot configure thresholds or scoring rules — that remains Full Access only |
| Smart Groups | Group management (create, edit, delete groups) is Full Access only; scoped managers can select existing groups as assignment targets within their surface |
| Adaptive Workflows | Trigger configuration for agent-driven workflows is Full Access only; scoped managers may view workflow status on their surface |
| Email Notifications | Role assignment and role change events trigger a notification email to the affected user describing their access level |
| Audit Log | Every role assignment and role change is timestamped and recorded with acting admin, user affected, previous role, and new role |
| Stillsuit DS v2 | Role badges use the platform's status badge component; permission-denied states use the standard empty-state pattern |

---

**Edge Cases & System Behaviour**

| Scenario | Behaviour |
|---|---|
| Active session when role is downgraded | On next page load or API call, the session reflects the new role; no forced logout required |
| Last Full Access admin attempts to downgrade their own role | System prevents the action and surfaces an error: "You cannot remove your own Full Access role. Assign Full Access to another user first." |
| User attempts to access a gated URL directly | Returns a permission-denied empty state with contact-admin message; does not expose route existence |
| Admin changes a role for a user mid-campaign | Campaign proceeds uninterrupted; role change affects only future surface access, not in-progress work |
| Invite sent with no role selected | Inline validation blocks submission: "Select a role to continue." |
| Dashboard Viewer attempts a write action via API | API returns 403 Forbidden; no client-side only enforcement |
| AEP Manager views Dashboards | Sees AEP-scoped metrics only; training and simulation data are not included in their dashboard view |
| Training & Simulations Manager views Dashboards | Sees training and simulation metrics only; AEP data is not included |
| Full Access admin is deactivated | Their previously created content remains attributed to them; another Full Access admin must be present before deactivation is permitted |
