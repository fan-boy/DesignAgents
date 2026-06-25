# Design Strategy: Training Nudge

**Feature:** `training-nudge`
**Date:** 2026-06-25
**Updated:** 2026-06-25 — Admin surface revised from BISO view to All Users

---

## Strategic framing

The nudge feature is a targeted action layer on top of data that already exists in two places:
- **Admin**: Risk Insights > Users (All Users) — where admins do user management work
- **Manager**: BISO non-admin view ("Team Risk & Training Overview") — their scoped team view

Admins confirmed they want nudge in All Users, not BISO view. This is the right call: BISO is an insight-reading surface, All Users is where admins act on users. The All Users page already has all the interaction infrastructure needed (checkboxes, Actions dropdown, bulk action bar).

---

## Recommended design approach

### Admin surface: All Users (Risk Insights > Users)

**The All Users page already has the right infrastructure:**
- Multi-select checkboxes per row (established in the High Risk Users sub-view)
- Per-row **Actions dropdown** (already present in High Risk Users view)
- **Bulk contextual action bar**: `[avatars] + N more selected | Cancel | Assign`

Nudge plugs directly into this without any new interaction paradigms.

#### Step 1: Add "Overdue Trainings" as a column and filter

The current All Users table shows Name, Department, Risk Score, Risk Change — no training state is visible. Admins need to see who's overdue before they can act.

- Add an **Overdue** count column — shows a count in amber/red when > 0, muted dash when 0
- Add an **"Overdue trainings"** filter pill to narrow the table to overdue users only
- Column is sortable — admins can sort descending to see worst offenders first

#### Step 2: "Nudge" in the per-row Actions dropdown

The Actions dropdown already exists. Add "Nudge" as an option when Overdue > 0. When Overdue = 0, the option is absent (not disabled — simply not applicable).

- After nudging: muted sub-line under the user's name: "Nudged just now" / "Nudged 2d ago"
- Prevents accidental double-nudging without hard-blocking re-nudge

#### Step 3: Bulk nudge via the existing contextual action bar

When admin selects users via checkboxes, the existing bulk bar appears. Extend it:

`[avatars] + N more selected | Cancel | Nudge | Assign`

- If selection contains users with Overdue = 0, Nudge only applies to overdue subset — button reads "Nudge (8 overdue)"
- Confirmation modal: "Send training reminders to 8 users with overdue trainings?" > Cancel / Nudge

### Manager surface: BISO non-admin view ("My Team")

Managers don't have access to All Users. Their surface is the BISO non-admin "Team Risk & Training Overview" — which already has an Overdue column.

- Per-row hover action: ghost "Nudge" button appears on rows with Overdue > 0
- After sending: row shows "Nudged just now" transitioning to "Nudged 2d ago" (muted)
- No bulk nudge needed in v1 — manager teams are small, individual nudges are appropriate

### "Last nudged" as a shared soft state

Both surfaces need to show when a user was last nudged so admins and managers don't pile on.

- In All Users: sub-line under the user's name in the Actions dropdown state
- In BISO manager view: muted inline label after nudge is sent
- Informational by default, not a hard lock (unless rate-limiting is confirmed by product)

---

## User flows

### Admin: nudge a single user
1. Open Risk Insights > Users
2. Filter by "Overdue trainings" or sort Overdue column descending
3. Find user with Overdue > 0
4. Open Actions dropdown > "Nudge"
5. Toast: "Reminder sent to Seymour Brooks"
6. Row shows "Nudged just now" sub-line

### Admin: bulk nudge overdue users
1. Open Risk Insights > Users, filter to overdue users
2. Select users via checkboxes
3. Bulk bar appears: `[avatars] + N more | Cancel | Nudge (N overdue) | Assign`
4. Click "Nudge (N overdue)" > confirmation modal
5. Confirm > toast: "Reminders sent to N users"

### Manager: nudge a direct report
1. Open BISO non-admin view > My Team
2. Hover row with Overdue > 0 > "Nudge" ghost button appears
3. Click > "Sent" > "Nudged just now"
4. Toast: "Reminder sent to [Name]"

---

## Stillsuit DS v2 patterns to use

- **Actions dropdown**: existing per-row pattern — Nudge is an additional menu item
- **Contextual action bar**: existing bulk pattern — Nudge is an additional action alongside Assign
- **Ghost/tertiary button**: for the manager BISO row hover action
- **Toast/snackbar**: post-nudge confirmation in both surfaces
- **Muted sub-text**: "Nudged Xd ago" — neutral, not a status badge
- **Filter pills**: for "Overdue trainings" filter on All Users
- **Confirmation modal**: for bulk nudge — standard modal with count

---

## What NOT to do

- Do not put nudge in BISO view for admins. Admins confirmed this is not their workflow surface.
- Do not add nudge to Control Panel > Training in v1. That surface is for managing training assignments, not following up with users.
- Do not show a Nudge option for users with Overdue = 0 — it will cause noise and erode trust.
- Do not skip "last nudged" state. Without it, users will receive multiple reminders in a day.
- Do not make the Overdue column mandatory — it should be addable/sortable without cluttering the default table view.

---

## Open design decisions

See `open-questions.md`. Three that materially affect this design:
1. **What does the nudge actually send?** Specific training or all overdue? Determines whether the Actions dropdown item says "Nudge (overdue trainings)" or lists them.
2. **Rate limiting** — does "last nudged" lock the action or just inform?
3. **Manager attribution** — email from manager name or from Dune system?
