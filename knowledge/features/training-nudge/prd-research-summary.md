# PRD Research Summary: Training Nudge

**Feature:** `training-nudge`
**Date:** 2026-06-25

---

## What the Figma file reveals

### Existing surfaces that already show overdue data

**1. BISO View — Admin (Alice Brown's team) [23970:286389]**
- **Training Data > Training Status table**: Has a "Training Status" column that already shows "Overdue" as a status badge per row. Columns: Name, Department, Training Name, Training Status, Risk Score.
- **User Data table**: Has an "Overdue" column showing a count per user. Columns: Name, Department, Risk Score, Trainings Assigned, Completed, Overdue, Risk Change.
- Neither table has any action column or nudge affordance today.

**2. BISO View — Non-admin / Manager [12066:161238]**
- "Team Risk & Training Overview" page
- Single user table with: Name, Department, Risk Score, Trainings Assigned, Completed, **Overdue**, Risk Change.
- Has a chevron > for row navigation but no action column.
- Simpler sidebar: only "My Team" and Dashboard sections visible.

**3. Control Panel / Training [9193:48430]**
- Training assignment page per module.
- Has an **Actions dropdown** per row — this is the established pattern for per-row actions.
- Bulk Assign by Email action exists at top right.
- This is an admin-only surface.

**4. Training assignment modal [9502:89222]**
- Modal for assigning a specific training to users.
- Shows Training Completion Deadline (36 days) prominently.
- User list with Name, Department, Role, Risk Score.
- Cancel / Assign Training CTA at bottom.

---

## Design pattern findings

### Row-level actions
The established pattern in Dune's platform for per-row actions is the **Actions dropdown** (seen in Control Panel/Training). For simpler single actions, the **chevron >** is used for navigation. The nudge is a single, high-clarity action — not a menu — so it should likely be a distinct inline button rather than buried in a dropdown.

### Bulk actions
Bulk actions are already used (Bulk Assign by Email in Training). The nudge bulk pattern should follow the same multi-select → action bar paradigm.

### Status visibility
The "Overdue" status badge exists in the Training Data table. The nudge action should only appear or be enabled for rows where status = Overdue (Training Data table) or Overdue count > 0 (User Data table).

### Manager vs admin surface
The manager view is intentionally simpler — no risk score factors, no over-time chart, just the team user table. The nudge in manager view must feel lightweight and not introduce admin-level complexity.

---

## Recommended placement

### Option A — In-table row action (Recommended)
Add a "Nudge" button as an inline action that appears on hover or as a persistent column for rows where Overdue > 0. This maps cleanly to the BISO view's User Data table and the manager view table. Precedent: hover actions are common in data tables in this DS.

**Pros:**
- No extra navigation
- Contextual — only shows where relevant
- Admin and manager share the same pattern
- BISO view is already the "insight → action" surface

**Cons:**
- Adds a new column or hover state to the table
- Needs "last nudged" state to avoid repeat sends

### Option B — Row contextual menu (Actions dropdown)
Add a "..." or dropdown per row, with "Nudge" as one option (alongside other possible future actions like "View profile", "Assign training").

**Pros:**
- Scales to multiple actions
- Doesn't add columns to an already-dense table

**Cons:**
- Hides the action — nudge is a primary workflow, not secondary
- Manager view doesn't currently have an actions column at all

### Option C — Bulk-first with filter
Add a "Nudge overdue users" action at the section/table header level (applies to all users with overdue). Row-level nudge is secondary.

**Pros:**
- Admin use case (scale) is served first
- Simplest UI change

**Cons:**
- Doesn't allow selective nudging
- Manager use case is per-person, not bulk

### Verdict
**Option A for the row action, with Option C as a secondary bulk affordance.** The Training Data table (admin BISO view) should also support multi-select bulk nudge.

---

## Key constraints

1. **RBAC boundary**: Manager nudge must be scoped to direct reports only. The manager view already enforces this via the "Team Risk & Training Overview" scope, so the nudge action inherits it.
2. **"Last nudged" state**: Without this, admins and managers will over-nudge. This is a required table state, not optional.
3. **Overdue-only scoping**: The nudge CTA should be disabled or hidden for users with Overdue = 0. Don't nudge people who aren't actually overdue.
4. **Confirmation**: The nudge sends an email/notification. Users need closure that it was sent. A toast is sufficient in v1.
5. **The BISO non-admin view is incomplete**: It currently only shows one row of data (Seymour Brooks). This is a placeholder — the full table needs to be designed properly before nudge is added to it.

---

## Gaps

- No existing "last nudged" or "nudge history" pattern in the DS to reference
- The non-admin BISO view appears underdeveloped (1 row in the Figma)
- No nudge notification template exists in the Email Templates page (checked: 8 email template frames, none are training nudge)
- Unclear whether nudge sends a new email or triggers an existing overdue-reminder email
- No clarity on whether nudge is rate-limited (e.g., max once per 24h per user)
