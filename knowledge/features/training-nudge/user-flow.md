# User Flow: Training Nudge

**Feature:** `training-nudge`
**Date:** 2026-06-25

---

## Flow 1: Admin nudges a single user (BISO View → User Data table)

```
[BISO View - Admin]
  └── Scroll to "User Data" section
       └── Row: Seymour Brooks | Dept | Risk 56 | Assigned 3 | Completed 2 | Overdue 1 | +5
            └── [Hover row]
                 └── "Nudge" ghost button appears (right side, before chevron)
                      ├── [Click Nudge]
                      │    └── Button → "Sent ✓" (300ms)
                      │    └── Button → "Nudged just now" (muted, disabled)
                      │    └── Toast: "Reminder sent to Seymour Brooks"
                      └── [User already recently nudged]
                           └── No Nudge button — shows "Nudged 2d ago" (muted label)
```

---

## Flow 2: Admin bulk nudges all overdue users (BISO View → Training Data table)

```
[BISO View - Admin]
  └── Training Data section → Training Status table
       ├── Option A: Select individual overdue rows via checkbox
       │    └── Contextual action bar appears above table
       │         └── "Nudge selected (3)" button
       │              └── [Click] → Confirmation modal:
       │                   "Send reminders to 3 users about overdue trainings?"
       │                   [Cancel] [Nudge 3 users →]
       │                        └── Toast: "Reminders sent to 3 users"
       │
       └── Option B: "Nudge all overdue" shortcut at table header
            └── [Click] → Confirmation modal:
                 "Send reminders to 12 users with overdue trainings?"
                 [Cancel] [Nudge 12 users →]
                      └── Toast: "Reminders sent to 12 users"
                      └── Overdue rows show "Nudged just now" inline
```

---

## Flow 3: Manager nudges a direct report (BISO non-admin → My Team table)

```
[BISO View - Manager / "Team Risk & Training Overview"]
  └── User table: My Team
       └── Row: [Name] | Dept | Risk Score | Assigned | Completed | Overdue 1 | Risk Change
            └── [Hover row]
                 └── "Nudge" ghost button appears
                      └── [Click]
                           └── Button → "Sent ✓" → "Nudged just now"
                           └── Toast: "Reminder sent to [Name]"
```

---

## Error states

```
Nudge fails (API error)
  └── Button reverts to "Nudge"
  └── Toast (error): "Failed to send reminder. Try again."

User has no email
  └── Nudge button disabled with tooltip: "No email address on file"

User completes training before nudge sends
  └── Backend rejects → inline: "This training was already completed"
  └── Row Overdue count drops to 0 on next refresh → Nudge button disappears
```
