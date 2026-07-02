## Last updated
2026-07-02 — Added Nudge drawer as core interaction pattern for all bulk nudge actions. Added disabled state for Settings > Notifications toggle. Clarified that per-user nudges (Nudge user) are direct-send while bulk nudge actions open the drawer for review and selection before sending.

---

The Training Nudge feature gives admins and managers a way to nudge users with overdue trainings without leaving the Dune Security platform. Prior to this feature, follow-up happened out of band via email or Slack, creating manual overhead and inconsistent coverage. The feature adds nudge actions across six surfaces: the Org Dashboard Training Status card, the BISO View, the All Users table, individual User Profiles, the Risky BISO Teams (Clusters) page, and Settings > Notifications. Bulk nudge actions open a Nudge drawer that lets admins review, filter, and select users before sending. Per-user nudge actions send directly with a toast confirmation. All nudge actions are scoped to users with at least one overdue training; the action is hidden or disabled where no overdue trainings exist.

---

**CTA Labels — Quick Reference**

| Surface | CTA | Interaction |
|---|---|---|
| Org Dashboard Training card | Nudge overdue users | Opens Nudge drawer |
| BISO View Training Status card | Nudge overdue users | Opens Nudge drawer |
| BISO View expanded user row | Nudge user | Direct send → toast |
| User Profile | Nudge user | Direct send → toast |
| Clusters ··· dropdown | Nudge overdue users | Opens Nudge drawer |
| All Users Actions dropdown (per row) | Nudge user | Direct send → toast |
| All Users bulk action bar | Nudge ([N] overdue) | Opens Nudge drawer |
| Settings > Notifications | Nudge Users | Opens Nudge drawer |

---

**Nudge Drawer — Core Interaction Pattern**

The Nudge drawer is a side panel that opens whenever an admin triggers a bulk nudge action. It lets admins review the full list of affected users before committing to the send, and optionally narrow the selection by searching or filtering.

The drawer displays:
- **Title:** "Nudge Users with overdue trainings"
- **Subtitle:** "Users with Overdue trainings: [N]"
- **Search field:** Search user by name
- **Filters:** Department (on all surfaces); Department, Custom Group, and Smart Group (on org-wide surfaces)
- **User table:** Name, Department, Role, User Role, Risk Score — one row per overdue user
- **Bottom CTA:** **Nudge Selected users**

All users with overdue trainings are pre-loaded into the drawer. The admin can deselect individuals, filter by department or group, or search by name before clicking **Nudge Selected users** to send. Only the users checked in the table receive the nudge.

After clicking **Nudge Selected users**, the drawer closes and a toast appears: "Nudge sent to [N] users."

---

**Org Dashboard — Training Status Card**

On the Organisation dashboard, the Training section contains a Training Status card with a donut chart and a tabbed user table showing Completed, In Progress, Not Started, and Overdue states. When viewing the Overdue tab, a **Nudge overdue users** button appears in the top-right corner of the card. The button is visible when at least one user appears in the Overdue tab; it is hidden when the Overdue count is zero.

Clicking **Nudge overdue users** opens the Nudge drawer pre-loaded with all users currently in the Overdue tab. The admin reviews the list, optionally filters or deselects users, then clicks **Nudge Selected users** to send. A toast confirms delivery.

The Overdue tab table shows each user's name, training name, risk score, and an Action column. This surface is admin-only.

---

**BISO View — Training Status Card and Per-User Nudge**

The BISO View (accessible via Organisation > Clusters > [Team]) shows a manager's or admin's scoped team. The Training Data section contains a Training Status card. A **Nudge overdue users** button appears in the top-right corner of this card. Clicking it opens the Nudge drawer pre-loaded with overdue users from that team. The admin reviews and confirms, then clicks **Nudge Selected users**.

The User Data table below lists all team members with columns for Name, Department, Risk Score, Trainings Assigned, Completed, Overdue, and Risk Change. Each row has a **>** chevron that expands to reveal that user's individual training records in a sub-table showing Training Name, Completion Status, and Score. When the expanded row belongs to a user with at least one overdue training, a **Nudge user** button appears within the expanded section. Clicking it sends directly to that user and shows a toast: "Nudge sent to [Name]." No drawer is shown for this single-user action.

This surface is available to both admins viewing a team page and to managers viewing their own team in the BISO non-admin view. The RBAC scope of the BISO view ensures managers can only act on users within their own team.

---

**All Users — Per-Row Nudge and Bulk Nudge**

The All Users page (Risk Insights > Users) gains an **Overdue** column showing the count of overdue trainings per user. The column displays an amber count when greater than zero and a muted dash when zero. The column is sortable; admins can sort descending to surface the highest-overdue users first. A filter pill — **Overdue trainings** — is added to the filter bar, narrowing the table to only users with Overdue > 0.

**Per-row nudge.** Each row has an Actions dropdown. When a user has Overdue > 0, a **Nudge user** item appears in the dropdown alongside existing options (Assign training, View profile). Selecting it sends directly to that user and shows a toast: "Nudge sent to [Name]." A muted "Nudged just now" sub-line appears beneath the user's name, transitioning to "Nudged Xd ago" on return visits. When Overdue = 0, the Nudge user item does not appear in the dropdown.

**Bulk nudge.** When an admin selects multiple rows via per-row checkboxes, the contextual action bar appears at the bottom of the table. The bar includes a **Nudge ([N] overdue)** action, where the count reflects only users in the selection with Overdue > 0. Clicking it opens the Nudge drawer pre-loaded with those users. The admin can review and deselect before clicking **Nudge Selected users**.

---

**User Profile — Individual Nudge**

On an individual user's profile page, the Training section displays a **Trainings Overdue** count prominently alongside the user's other training stats. When this count is greater than zero, a **Nudge user** button appears in the Training Status section of the profile.

The Training Status section includes tabs for All, Completed, Pending, and Overdue, with a table showing Training Name, Completion Status, and Score. Clicking **Nudge user** sends directly to that user and shows a toast: "Nudge sent to [Name]." After sending, the profile reflects a "Last nudged" timestamp.

If the user has no overdue trainings, the Trainings Overdue count shows zero and the Nudge user button is not shown. If the user has no email address on file, the button is disabled with a tooltip: "No email address on file."

---

**Risky BISO Teams (Clusters) — Team-Level Nudge**

On the Risky BISO Teams page (Organisation > Clusters > Manager Teams), each row represents a cluster lead and their team. A **···** Actions column appears on each row. Opening the menu reveals two options: **Nudge overdue users** (displayed in green as the primary action) and **View team**.

Clicking **Nudge overdue users** opens the Nudge drawer pre-loaded with all overdue users in that cluster. The admin reviews the list and clicks **Nudge Selected users** to send. A toast confirms: "Nudge sent to [N] users." If the cluster has no overdue users, the Nudge overdue users option is disabled in the dropdown.

This action is available to admins across all clusters and to managers scoped to their own cluster in the BISO non-admin view.

---

**Settings > Notifications — Immediate Org-Wide Nudge**

Under Settings > Notifications, the Training Reminder Notifications section contains an **Overdue Trainings Overview** row. This row controls the automated scheduled nudge sent to all users with overdue trainings ("Overdue reminders are sent out on every week on Tuesday at 2pm"). The row has a toggle, a **View/Edit Template** link, a **Change Schedule** button, and a **Nudge Users** button.

The **Nudge Users** button lets an admin trigger an immediate org-wide nudge independent of the scheduled send, opening the Nudge drawer pre-loaded with all currently overdue users across the org. The admin can filter by Department, Custom Group, or Smart Group before clicking **Nudge Selected users**.

The **Change Schedule** button opens the Custom Email Schedule modal, which lets the admin configure the automated nudge cadence. The modal offers three frequency options — Daily, Weekly, and Monthly — a day-of-week selector (for Weekly), a send time picker, and a note that all sends are in UTC time. Changes are saved with a **Save** action; **Cancel** dismisses without saving.

**Disabled state.** When the Overdue Trainings Overview toggle is turned off, both the **Change Schedule** and **Nudge Users** buttons are hidden from the row. Only the toggle and **View/Edit Template** link remain visible. Turning the toggle back on restores both buttons.

**View Overdue rules** is a link that navigates to the organisation's configured overdue thresholds. This is existing functionality; the nudge feature does not change it.

This surface is admin-only. Managers do not have access to Settings > Notifications.

---

**RBAC**

| Role | Surfaces available | Scope |
|---|---|---|
| Admin | Org Dashboard, BISO View (any team), All Users, User Profile, Clusters, Settings > Notifications | All users in org |
| Manager (BISO non-admin) | BISO View (own team only), Clusters (own cluster only) | Direct reports only |
| Regular user | None | No access |

---

**Nudge Email**

The nudge sends an email to the user's address on file using the organisation's configured Training Sender Email Domain. In v1, the email uses a standard overdue-nudge template — admins and managers cannot edit the message body. Whether the email references specific overdue training names or sends a generic nudge is subject to the open question on nudge scope (see Open Questions).

After a nudge is sent, the platform records the send timestamp against the user. This "last nudged" state is displayed inline on all surfaces where the user appears so admins and managers can see whether a nudge was recently sent and avoid over-nudging.

---

**Integration Points**

| Integration | Description |
|---|---|
| Email Notifications | Nudge sends via the org's configured Training Sender Email Domain using a standard overdue-nudge template |
| Risk Scoring Engine | Overdue training status feeds into a user's risk score; completing a training after a nudge reduces the Overdue count and may lower risk score on next refresh |
| Overdue Training Data | Nudge CTAs are driven by live Overdue count / Training Status = Overdue; actions are hidden when count is zero |
| Smart Groups / Custom Groups | Nudge drawer supports filtering by Custom Group and Smart Group on org-wide surfaces |
| Audit / Last Nudged State | Send timestamps are recorded per user; surfaces display "Nudged just now" → "Nudged Xd ago" as soft rate-limiting cues |

---

**Edge Cases & System Behaviour**

| Scenario | Behaviour |
|---|---|
| User has no overdue trainings | Nudge action hidden in Actions dropdown and User Profile; not shown in Nudge drawer |
| User has no email address on file | Nudge user button is disabled; tooltip reads "No email address on file" |
| User has been deactivated | Excluded from Nudge drawer and all nudge targets; no CTA shown |
| Nudge drawer opened with zero overdue users | Drawer shows empty state; Nudge Selected users button is disabled |
| Admin deselects all users in Nudge drawer | Nudge Selected users button is disabled until at least one user is selected |
| User completes training before nudge sends | Backend rejects send; toast: "This user has already completed this training." Overdue count drops to 0 on next refresh; CTA disappears |
| User was recently nudged (within cooldown window) | User shown in drawer with "Recently nudged" indicator; admin can still include or deselect them |
| Nudge API fails for one or more users | Partial failure toast: "Nudged [N] of [M] users. [X] failed." No "last nudged" update for failed recipients |
| Nudge API fails entirely | Error toast: "Failed to send nudge. Try again." No state change on any rows |
| Overdue Trainings Overview toggle is off | "Nudge Users" and "Change Schedule" buttons hidden from Settings > Notifications row |
| Cluster has no overdue users | "Nudge overdue users" option is disabled in the Clusters Actions dropdown |
| Admin and manager both nudge the same user on the same day | Rate limit applies per user — behaviour depends on rate-limit policy (see Open Questions) |
| Table is filtered or sorted when nudge is sent | Rows remain in position; "Nudged just now" sub-line appears without resorting |
| BISO view loaded with stale data | "Last nudged" timestamp may not reflect recent sends from another session; informational only |
| User Profile viewed before data refresh | Trainings Overdue count and Nudge user button state reflect the last-loaded snapshot |

---

**Out of Scope — v1**

Custom message composition, scheduled or recurring nudges, nudge from Control Panel > Training, and mobile support are not included in this release.

---

**Open Questions**

The following questions from `open-questions.md` remain unresolved and may affect implementation decisions:

- **What does the nudge actually send?** Does it re-trigger the existing overdue email or generate a new template? Does it reference specific overdue training names or send a generic nudge?
- **Rate limiting.** Is there a cooldown window? Does "last nudged" lock the action or only inform? Does a "Recently nudged" indicator in the drawer prevent or just warn?
- **Manager attribution.** Does the nudge email come from the manager's name or from the Dune system?
- **Bulk nudge scope.** If a user has three overdue trainings, do they receive one consolidated email or three separate emails?
- **"Last nudged" display duration.** Does the timestamp display indefinitely, or reset after a set number of days?
- **Nudge drawer default selection.** Are all overdue users pre-selected in the drawer, or does the admin select manually?
