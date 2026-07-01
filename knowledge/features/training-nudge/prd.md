## Last updated
2026-07-01 — Revised to reflect confirmed admin surfaces: Org Dashboard Training Status card, All Users table, User Profile, and Risky BISO Teams (Clusters). Removed BISO-only admin framing from original draft. Added four distinct flows with full edge case coverage.

---

The Training Nudge feature gives admins and managers a way to send training reminder emails to users with overdue trainings without leaving the Dune Security platform. Prior to this feature, follow-up happened out of band via email or Slack, creating manual overhead and inconsistent coverage. The feature adds nudge actions across four surfaces: the Org Dashboard Training Status card, the All Users table, individual User Profiles, and the Risky BISO Teams (Clusters) page. Admins can nudge individual users, bulk nudge overdue users from a selection, or trigger a team-wide nudge for an entire BISO cluster. Managers with BISO non-admin access can nudge their direct reports from the Clusters page. All nudges are scoped to users with at least one overdue training; the action is hidden or disabled for users with no overdue trainings.

---

**Org Dashboard — Training Status Card**

On the Organisation dashboard, the Training Status card displays a donut chart of training completion states alongside a tabbed user table. When an admin is viewing the dashboard, a **Nudge Overdue Training Users** button appears in the top-right corner of the card. The button is always visible when the Overdue tab is active and at least one user appears in the table; it is hidden when the Overdue count is zero.

Clicking **Nudge Overdue Training Users** sends a reminder to all users currently showing in the Overdue tab. Before sending, a confirmation modal appears: "Send training reminders to [N] users with overdue trainings?" with a Cancel action and a **Nudge [N] users →** primary action. On confirm, a toast notification appears: "Reminders sent to [N] users." This action is admin-only and does not appear for managers on their scoped BISO view.

The Overdue tab shows each user's name, assigned training name, and risk score. After a nudge is sent, rows in the table display a muted "Nudged just now" sub-line beneath the user's name, transitioning to "Nudged Xd ago" on subsequent sessions. This state persists to prevent the same user being nudged repeatedly in a short window.

---

**All Users — Per-Row Nudge and Bulk Nudge**

The All Users page (Risk Insights > Users) gains an **Overdue** column showing the count of overdue trainings per user. The column displays an amber count when greater than zero, and a muted dash when zero. The column is sortable; admins can sort descending to surface the highest-overdue users first. A filter pill — **Overdue trainings** — is added to the filter bar, narrowing the table to only users with Overdue > 0.

**Per-row nudge.** Each row in the All Users table has an Actions dropdown. When a user has Overdue > 0, a **Nudge** item appears in the dropdown alongside existing options (Assign training, View profile). Selecting Nudge immediately sends a reminder to that user and shows a toast: "Reminder sent to [Name]." A muted "Nudged just now" sub-line appears beneath the user's name in the row; it transitions to "Nudged Xd ago" on return visits. When Overdue = 0, the Nudge item does not appear in the dropdown — it is not shown as disabled, it is simply absent.

**Bulk nudge.** When an admin selects multiple rows via the per-row checkboxes, the existing contextual action bar appears at the bottom of the table. The action bar is extended to include a **Nudge** action alongside Cancel and Assign. If the selection contains users with Overdue = 0, the Nudge action applies only to the overdue subset and the button label reflects the count: **Nudge (8 overdue)**. Clicking Nudge opens a confirmation modal: "Send training reminders to [N] users with overdue trainings?" with Cancel and **Nudge [N] users →**. On confirm, a toast appears: "Reminders sent to [N] users." Rows belonging to nudged users show the "Nudged just now" sub-line.

If the bulk selection includes users who were recently nudged, the confirmation modal surfaces a warning: "X of [N] users were already nudged recently. Proceed?" with three options: Cancel, **Nudge all [N]**, and **Skip recently nudged ([X])**. This allows the admin to choose whether to re-nudge or limit sends to users who haven't received a recent reminder.

---

**User Profile — Individual Nudge**

On an individual user's profile page, a **Nudge user** action is available when the user has at least one overdue training. The action appears as a button or menu item in the profile's action area. Clicking it sends a reminder and shows a toast: "Reminder sent to [Name]." If the user has no overdue trainings, the Nudge action is not shown. If the user has no email address on file, the Nudge action is disabled with a tooltip: "No email address on file."

After a nudge is sent from the profile, the profile view reflects the "Last nudged" timestamp so the admin can see when the most recent reminder was sent.

---

**Risky BISO Teams (Clusters) — Team-Level Nudge**

On the Risky BISO Teams page (Organisation > Clusters), each row represents a BISO cluster lead and their team. A **···** Actions column is added to the table. Clicking the menu on any row opens a dropdown with three options: **Nudge overdue users**, **View team**, and **Assign training**. Nudge overdue users is shown in green as the primary action and sends reminders to all users in that cluster who have at least one overdue training.

Clicking **Nudge overdue users** opens a confirmation modal: "Send training reminders to overdue users in [Cluster Lead]'s team?" with Cancel and **Nudge overdue users →**. On confirm, a toast appears: "Reminders sent to overdue users in [Cluster Lead]'s team." If the cluster has no users with overdue trainings, the Nudge overdue users option is disabled in the dropdown with a muted label.

This flow is available to both admins (who see all clusters) and managers with BISO non-admin access (who see only their own cluster). A manager can only nudge users within their own team; the RBAC scope enforced by their BISO view prevents them from reaching other clusters.

---

**RBAC**

| Role | Surfaces available | Can nudge |
|---|---|---|
| Admin | Org Dashboard, All Users, User Profile, Risky BISO Teams | All users in org |
| Manager (BISO non-admin) | Risky BISO Teams (own cluster only) | Direct reports only |
| Regular user | None | No |

---

**Nudge Email**

The nudge sends an email to the user's address on file using the organisation's configured Training Sender Email Domain. In v1, the email uses a standard reminder template — admins and managers cannot edit the message body. The email references the user's overdue training(s). Whether the email lists each overdue training individually or sends a single consolidated reminder is subject to the open question on nudge scope (see Open Questions).

After a nudge is sent, the platform records the send timestamp against the user. This "last nudged" state is displayed inline on all surfaces where the user appears (All Users row, Org Dashboard Training Status row, User Profile) so admins and managers can see whether a reminder was recently sent and avoid over-nudging.

---

**Integration Points**

| Integration | Description |
|---|---|
| Email Notifications | Nudge sends via the org's configured Training Sender Email Domain using a standard overdue-reminder template |
| Risk Scoring Engine | Overdue training status feeds into a user's risk score; completing a training after a nudge reduces the Overdue count and may lower risk score on next refresh |
| Overdue Training Data | Nudge CTAs are driven by live Overdue count / Training Status = Overdue; actions are hidden when count is zero |
| Audit / Last Nudged State | Send timestamps are recorded per user; surfaces display "Nudged just now" → "Nudged Xd ago" as soft rate-limiting cues |

---

**Edge Cases & System Behaviour**

| Scenario | Behaviour |
|---|---|
| User has no overdue trainings | Nudge action is hidden (not disabled) in Actions dropdown and User Profile; bulk Nudge count reflects only overdue subset |
| User has no email address on file | Nudge action is disabled; tooltip reads "No email address on file" |
| User has been deactivated | Row excluded from nudge targets; no CTA shown |
| User completes training before nudge sends | Backend rejects nudge; toast: "This user has already completed this training." Overdue count drops to 0 on next data refresh; nudge CTA disappears |
| User was recently nudged (within cooldown window) | Bulk nudge modal warns "X users were already nudged recently" with options to nudge all, skip recently nudged, or cancel |
| Nudge API fails for one or more users | Partial failure toast: "Nudged [N] of [M] users. [X] failed." No "last nudged" sub-line for failed recipients |
| Nudge API fails entirely | Error toast: "Failed to send reminders. Try again." No state change on any rows |
| Admin selects mixed rows (some overdue, some not) | Bulk nudge button reads "Nudge ([N] overdue)"; only overdue users receive the reminder |
| Admin bulk-nudges with zero overdue users selected | Nudge action is disabled in the bulk bar; not actionable |
| Cluster has no overdue users | "Nudge overdue users" option is disabled in the Clusters Actions dropdown |
| Admin and manager both nudge the same user on the same day | Rate limit applies per user per sender or globally per user — behaviour depends on rate-limit policy (see Open Questions) |
| Table is filtered/sorted when nudge is sent | Row remains in its current position after send; "Nudged just now" sub-line appears without resorting |
| BISO view loaded with stale data | "Last nudged" timestamp may not reflect sends made in another session until data refreshes; informational only |

---

**Out of Scope — v1**

Custom nudge message composition, scheduled or recurring nudges, nudge from Control Panel > Training, and mobile nudge support are not included in this release.

---

**Open Questions**

The following questions from `open-questions.md` remain unresolved and may affect implementation decisions:

- **What does the nudge actually send?** Does it re-trigger the existing overdue-reminder email or generate a new template? Does it reference specific overdue training names or send a generic reminder?
- **Rate limiting.** Is there a cooldown window? Does "last nudged" lock the action or only inform?
- **Manager attribution.** Does the nudge email come from the manager's name or from the Dune system?
- **Bulk nudge scope.** If a user has three overdue trainings, do they receive one consolidated email or three separate emails?
- **"Last nudged" display duration.** Does the timestamp display indefinitely, or reset after a set number of days?
