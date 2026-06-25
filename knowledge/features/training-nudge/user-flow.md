# User Flow: Training Nudge

**Feature:** `training-nudge`
**Date:** 2026-06-25
**Updated:** 2026-06-25 — Admin surface revised to All Users

---

## Flow 1: Admin nudges a single user (All Users > Actions dropdown)

```
[Risk Insights > Users]
  └── Filter: "Overdue trainings" pill  (or sort Overdue column desc)
       └── Table narrows to users with Overdue > 0
            └── Row: Seymour Brooks | Operations | Risk 84 | Overdue 2 | ...
                 └── Click Actions dropdown (▼)
                      ├── Assign training
                      ├── View profile
                      └── Nudge   ← new item, only when Overdue > 0
                           └── [Click Nudge]
                                └── Toast: "Reminder sent to Seymour Brooks"
                                └── Row sub-line: "Nudged just now" (muted)
```

---

## Flow 2: Admin bulk nudges selected users (All Users > bulk action bar)

```
[Risk Insights > Users]
  └── Filter to overdue users
       └── Select rows via checkboxes
            └── Bulk bar appears:
                 [SB CH] + 3 more selected  |  Cancel  |  Nudge (5 overdue)  |  Assign →
                      └── [Click "Nudge (5 overdue)"]
                           └── Confirmation modal:
                                "Send training reminders to 5 users with overdue trainings?"
                                [Cancel]  [Nudge 5 users →]
                                     └── Toast: "Reminders sent to 5 users"
                                     └── Overdue rows show "Nudged just now" sub-line
```

---

## Flow 3: Manager nudges a direct report (BISO non-admin > My Team table)

```
[BISO View - Manager / "Team Risk & Training Overview"]
  └── Table: My Team
       └── Row: [Name] | Dept | Risk | Assigned | Completed | Overdue 1 | Risk Change
            └── [Hover row]
                 └── Ghost "Nudge" button appears (right side, before chevron)
                      └── [Click Nudge]
                           └── Button → "Sent" (briefly)
                           └── Button → "Nudged just now" (muted, no longer clickable briefly)
                           └── Toast: "Reminder sent to [Name]"
```

---

## Error / edge states

```
Nudge fails (API error)
  └── Toast (error): "Failed to send reminder. Try again."
  └── "Last nudged" sub-line does not appear

User has no email on file
  └── "Nudge" item in Actions dropdown is disabled
  └── Tooltip: "No email address on file"

User completes training before nudge sends
  └── Backend rejects nudge
  └── Toast: "This user has already completed the training"
  └── Overdue count drops to 0 on next refresh → Nudge option disappears

Bulk nudge: some users already recently nudged
  └── Warning in confirmation modal: "3 of 5 users were already nudged recently. Proceed?"
  └── [Cancel] [Nudge all 5] [Skip recently nudged (2)]
```
