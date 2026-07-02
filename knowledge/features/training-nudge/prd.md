## Last updated
2026-07-02 — Standardised all CTA labels to use "nudge" consistently: bulk/card-level actions use "Nudge overdue users"; single-user actions use "Nudge user"; All Users bulk bar uses "Nudge ([N] overdue)". Updated BISO View two-state design: card-level bulk button and per-user expanded row button. Removed "Assign training" from Clusters dropdown (not in designs). Confirmed User Profile "Trainings Overdue" stat display.

---

The Training Nudge feature gives admins and managers a way to nudge users with overdue trainings without leaving the Dune Security platform. Prior to this feature, follow-up happened out of band via email or Slack, creating manual overhead and inconsistent coverage. The feature adds nudge actions across five surfaces: the Org Dashboard Training Status card, the BISO View (Alice Brown's team), the All Users table, individual User Profiles, and the Risky BISO Teams (Clusters) page. Admins can nudge at the card level, per-user level, or per-cluster level. Managers with BISO non-admin access can nudge their direct reports. All nudge actions are scoped to users with at least one overdue training; the action is hidden or disabled where no overdue trainings exist.

---

**CTA Labels — Quick Reference**

| Surface | CTA |
|---|---|
| Org Dashboard Training card | Nudge overdue users |
| BISO View Training Status card | Nudge overdue users |
| BISO View expanded user row | Nudge user |
| User Profile | Nudge user |
| Clusters ··· dropdown | Nudge overdue users |
| All Users Actions dropdown (per row) | Nudge user |
| All Users bulk action bar | Nudge ([N] overdue) |

---

**Org Dashboard — Training Status Card**

On the Organisation dashboard, the Training section contains a Training Status card with a donut chart and a tabbed user table showing Completed, In Progress, Not Started, and Overdue states. When viewing the Overdue tab, a **Nudge overdue users** button appears in the top-right corner of the card. The button is visible when at least one user appears in the Overdue tab; it is hidden when the Overdue count is zero.

Clicking **Nudge overdue users** opens a confirmation modal: "Nudge [N] users with overdue trainings?" with a Cancel action and a **Nudge [N] users →** primary action. On confirm, a toast notification appears: "Nudge sent to [N] users." Rows in the Overdue tab display a muted "Nudged just now" sub-line beneath the user's name after sending, transitioning to "Nudged Xd ago" on subsequent sessions.

The Overdue tab table shows each user's name, training name, risk score, and an Action column. This action is admin-only.

---

**BISO View — Training Status Card and Per-User Nudge**

The BISO View (accessible via Organisation > Clusters > [Team]) shows a manager's or admin's scoped team. The Training Data section contains a Training Status card. A **Nudge overdue users** button appears in the top-right corner of this card. Clicking it nudges all users in the team whose Training Status is Overdue, following the same confirmation and toast pattern as the Org Dashboard.

The User Data table below lists all team members with columns for Name, Department, Risk Score, Trainings Assigned, Completed, Overdue, and Risk Change. Each row has a **>** chevron that expands to reveal that user's individual training records. The expanded view shows a sub-table with Training Name, Completion Status, and Score. When the expanded row belongs to a user with at least one overdue training, a **Nudge user** button appears within the expanded section, scoped to that specific user. Clicking it nudges that user for their overdue trainings and shows a toast: "Nudge sent to [Name]."

This surface is available to both admins viewing a team page and to managers viewing their own team in the BISO non-admin view. The RBAC scope of the BISO view ensures managers can only act on users within their own team.

---

**All Users — Per-Row Nudge and Bulk Nudge**

The All Users page (Risk Insights > Users) gains an **Overdue** column showing the count of overdue trainings per user. The column displays an amber count when greater than zero and a muted dash when zero. The column is sortable; admins can sort descending to surface the highest-overdue users first. A filter pill — **Overdue trainings** — is added to the filter bar, narrowing the table to only users with Overdue > 0.

**Per-row nudge.** Each row has an Actions dropdown. When a user has Overdue > 0, a **Nudge user** item appears in the dropdown alongside existing options (Assign training, View profile). Selecting it immediately nudges that user and shows a toast: "Nudge sent to [Name]." A muted "Nudged just now" sub-line appears beneath the user's name; it transitions to "Nudged Xd ago" on return visits. When Overdue = 0, the Nudge user item does not appear in the dropdown.

**Bulk nudge.** When an admin selects multiple rows via per-row checkboxes, the contextual action bar appears at the bottom of the table. The bar includes a **Nudge ([N] overdue)** action alongside Cancel and Assign. If the selection contains users with Overdue = 0, the count reflects only the overdue subset. Clicking it opens a confirmation modal: "Nudge [N] users with overdue trainings?" with Cancel and **Nudge [N] users →**. On confirm, a toast appears: "Nudge sent to [N] users."

If the bulk selection includes users who were recently nudged, the confirmation modal surfaces a warning: "X of [N] users were already nudged recently. Proceed?" with three options: Cancel, **Nudge all [N]**, and **Skip recently nudged ([X])**.

---

**User Profile — Individual Nudge**

On an individual user's profile page, the Training section displays a **Trainings Overdue** count prominently alongside the user's other training stats. When this count is greater than zero, a **Nudge user** button appears in the Training Status section of the profile.

The Training Status section includes tabs for All, Completed, Pending, and Overdue, with a table showing Training Name, Completion Status, and Score. Clicking **Nudge user** nudges the user for all their overdue trainings and shows a toast: "Nudge sent to [Name]." After sending, the profile reflects a "Last nudged" timestamp so the admin can see when the most recent nudge was sent.

If the user has no overdue trainings, the Trainings Overdue count shows zero and the Nudge user button is not shown. If the user has no email address on file, the button is disabled with a tooltip: "No email address on file."

---

**Risky BISO Teams (Clusters) — Team-Level Nudge**

On the Risky BISO Teams page (Organisation > Clusters > Manager Teams), each row represents a cluster lead and their team. A **···** Actions column appears on each row. Opening the menu reveals two options: **Nudge overdue users** (displayed in green as the primary action) and **View team**.

Clicking **Nudge overdue users** opens a confirmation modal: "Nudge overdue users in [Cluster Lead]'s team?" with Cancel and **Nudge overdue users →**. On confirm, a toast appears: "Nudge sent to overdue users in [Cluster Lead]'s team." If the cluster has no users with overdue trainings, the Nudge overdue users option is disabled in the dropdown.

This action is available to admins across all clusters and to managers scoped to their own cluster in the BISO non-admin view.

---

**RBAC**

| Role | Surfaces available | Scope |
|---|---|---|
| Admin | Org Dashboard, BISO View (any team), All Users, User Profile, Clusters | All users in org |
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
| Audit / Last Nudged State | Send timestamps are recorded per user; surfaces display "Nudged just now" → "Nudged Xd ago" as soft rate-limiting cues |

---

**Edge Cases & System Behaviour**

| Scenario | Behaviour |
|---|---|
| User has no overdue trainings | Nudge action is hidden in Actions dropdown and User Profile; bulk count reflects only overdue subset |
| User has no email address on file | Nudge button is disabled; tooltip reads "No email address on file" |
| User has been deactivated | Row excluded from nudge targets; no CTA shown |
| User completes training before nudge sends | Backend rejects send; toast: "This user has already completed this training." Overdue count drops to 0 on next data refresh; CTA disappears |
| User was recently nudged (within cooldown window) | Bulk nudge modal warns "X users were already nudged recently" with options to nudge all, skip recently nudged, or cancel |
| Nudge API fails for one or more users | Partial failure toast: "Nudged [N] of [M] users. [X] failed." No "last nudged" update for failed recipients |
| Nudge API fails entirely | Error toast: "Failed to send nudge. Try again." No state change on any rows |
| Admin selects mixed rows (some overdue, some not) | Bulk nudge button reads "Nudge ([N] overdue)"; only overdue users are nudged |
| Cluster has no overdue users | "Nudge overdue users" option is disabled in the Clusters Actions dropdown |
| Admin and manager both nudge the same user on the same day | Rate limit applies per user — behaviour depends on rate-limit policy (see Open Questions) |
| Table is filtered or sorted when nudge is sent | Row remains in its current position after send; "Nudged just now" sub-line appears without resorting |
| BISO view loaded with stale data | "Last nudged" timestamp may not reflect sends made in another session until data refreshes; informational only |
| User Profile viewed before data refresh | Trainings Overdue count and Nudge user button state reflect the last-loaded data snapshot |

---

**Out of Scope — v1**

Custom message composition, scheduled or recurring nudges, nudge from Control Panel > Training, and mobile support are not included in this release.

---

**Open Questions**

The following questions from `open-questions.md` remain unresolved and may affect implementation decisions:

- **What does the nudge actually send?** Does it re-trigger the existing overdue email or generate a new template? Does it reference specific overdue training names or send a generic nudge?
- **Rate limiting.** Is there a cooldown window? Does "last nudged" lock the action or only inform?
- **Manager attribution.** Does the nudge email come from the manager's name or from the Dune system?
- **Bulk nudge scope.** If a user has three overdue trainings, do they receive one consolidated email or three separate emails?
- **"Last nudged" display duration.** Does the timestamp display indefinitely, or reset after a set number of days?
