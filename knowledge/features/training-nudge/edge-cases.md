# Edge Cases: Training Nudge

**Feature:** `training-nudge`
**Date:** 2026-06-25

---

## User state edge cases

| State | Expected behavior |
|---|---|
| User has overdue trainings | Nudge CTA enabled |
| User has 0 overdue trainings | Nudge CTA hidden or disabled |
| User was already nudged within cooldown window | Nudge CTA disabled + "Last nudged X ago" shown |
| User has no email address | Nudge blocked; show inline error |
| User has been deactivated | Row excluded from nudge targets; no CTA shown |
| User completes training after nudge is sent | Overdue count drops to 0; nudge CTA should disappear on next data refresh |

## Bulk nudge edge cases

| State | Expected behavior |
|---|---|
| Admin selects mixed rows (some overdue, some not) | Nudge only applies to overdue rows; non-overdue rows skip silently or warn |
| Admin selects 0 rows and clicks "Nudge all overdue" | Sends to all currently overdue users — confirmation modal should show count |
| All selected users have already been nudged recently | Show warning "X users were recently nudged — proceed?" |
| Nudge fails for some users (API error) | Partial success toast: "Nudged 8 of 10 users. 2 failed." |

## RBAC edge cases

| State | Expected behavior |
|---|---|
| Manager tries to nudge user outside their team | Not possible — manager view is already scoped to direct reports |
| Admin nudges user who also has a manager | Both could nudge independently — rate limit prevents spam |
| User is in multiple departments | Nudge is per-user, not per-department — one send regardless of how many tables they appear in |

## Notification edge cases

| State | Expected behavior |
|---|---|
| User has already received an automated overdue email today | Nudge still sends (manually triggered nudges bypass automated sends) OR nudge is blocked (need product decision) |
| Manager nudge + admin nudge on same day | Rate limit applies per user per sender, or globally per user — needs product decision |

## UI state edge cases

| State | Expected behavior |
|---|---|
| Table is sorted/filtered and nudge is sent | After sending, row remains visible in its current position |
| Training is completed between row render and nudge send | Backend rejects nudge; show "This user has already completed this training" |
| BISO view loaded with stale data | "Last nudged" timestamp may not reflect most recent sends — data freshness caveat |
