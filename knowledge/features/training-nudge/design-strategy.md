# Design Strategy: Training Nudge

**Feature:** `training-nudge`
**Date:** 2026-06-25

---

## Strategic framing

The nudge feature is not a new page — it's a targeted action layer on top of data that already exists. The BISO view already exposes overdue training data in two places: the Training Data table (per training row) and the User Data table (per user with an Overdue count). The design job is to make "act on this data" as low-friction as possible without changing the meaning of the surface.

The BISO view is Dune's "insight → action" hub for both admins and managers. Adding nudge here is the right call because the user is already in the mental mode of reviewing risk signals. The nudge happens at the moment of recognition, not after a context switch.

---

## Recommended design approach

### 1. Row-level nudge as a ghost button in the User Data table

In the **User Data table** (both admin BISO and manager BISO), add a "Nudge" ghost/tertiary button in the actions area of each row — but only render it when `Overdue > 0`.

- On hover, the row reveals: [Nudge] button on the right side (before the chevron ›)
- If user was recently nudged: replace [Nudge] with a muted "Nudged 2d ago" label — no button
- After clicking Nudge: button changes to "Sent ✓" briefly, then reverts to "Nudged Xm ago"

This is the primary nudge path for managers (who care about specific people, not bulk actions).

### 2. Bulk nudge in the Training Data table (admin BISO only)

The Training Data table already has a donut chart summary + user rows. For admin scale, add:
- Multi-select checkboxes on rows with Training Status = "Overdue"
- When ≥1 overdue row is selected: a contextual action bar appears above the table with "Nudge selected (N)" button
- A "Nudge all overdue" shortcut at the table header level for one-click org-wide nudge
- Confirmation modal: "You're about to nudge N users about overdue trainings. Proceed?" with Cancel / Nudge

### 3. "Last nudged" as a persistent soft state

Add a "Last Nudged" column to the User Data table (hidden by default, togglable via column picker). For users who were recently nudged, show a muted timestamp inline.

This is critical for preventing over-nudging. It also gives managers visibility into whether an admin already followed up.

### 4. Manager vs. admin: same pattern, different scope

The manager's BISO view ("Team Risk & Training Overview") needs to reach parity first — the current Figma shows only 1 row, which suggests it's underdeveloped. Before designing nudge for the manager surface, the full table design needs to be confirmed.

Once parity is established, the nudge pattern is identical: hover → Nudge button on rows with Overdue > 0.

---

## User flows

### Admin flow: nudge a single user
1. Admin opens BISO View (their org or a specific team view)
2. Scrolls to User Data table
3. Sees user "Seymour Brooks" with Overdue = 2
4. Hovers row → "Nudge" button appears
5. Clicks Nudge → brief "Sent ✓" state → button becomes "Nudged just now"
6. Toast at top: "Reminder sent to Seymour Brooks"

### Admin flow: bulk nudge all overdue users
1. Admin opens BISO View
2. In Training Data section, clicks "Nudge all overdue" (or selects individual rows)
3. Confirmation modal: "Nudge 12 users with overdue trainings?"
4. Confirms → toast: "Reminders sent to 12 users"
5. Overdue rows update "last nudged" timestamp inline

### Manager flow: nudge a direct report
1. Manager opens BISO non-admin view ("My Team" → Team Risk & Training Overview)
2. Sees direct report with Overdue = 1
3. Hovers row → "Nudge" appears
4. Clicks → "Sent ✓" then "Nudged just now"
5. Toast: "Reminder sent to [Name]"

---

## Stillsuit DS v2 patterns to use

- **Ghost/tertiary button**: for the Nudge row action — low visual weight, contextual
- **Contextual action bar**: for the bulk nudge selection state — consistent with multi-select flows in data tables
- **Toast/snackbar**: for post-nudge confirmation
- **Status badge**: "Nudged Xd ago" should use a muted/neutral badge variant, not a status color
- **Column picker / table settings**: for toggling "Last Nudged" column visibility
- **Confirmation modal**: for bulk nudge — standard modal with count in body copy

---

## What NOT to do

- Do not add nudge to the Control Panel > Training page in v1. That surface is for training management (assign, edit deadlines), not for following up with users. Mixing concerns will confuse the information architecture.
- Do not show a Nudge button for users with Overdue = 0. It will be clicked accidentally and erode trust in the feature.
- Do not put nudge in a nested dropdown. This is a primary action for a compliance-critical workflow — it must be one click.
- Do not skip the "last nudged" state. Without it, admins will send 5 reminders to the same person in a week.

---

## Open design decisions

See `open-questions.md` for unresolved questions that may change the above. The three that would materially affect the design:
1. **What does the nudge send?** (specific training vs. all overdue) — determines how the Training Data table nudge works vs. User Data table nudge
2. **Rate limit behavior** — determines whether the "last nudged" state is informational or a hard lock
3. **Manager nudge attribution** — affects toast copy and email template design
