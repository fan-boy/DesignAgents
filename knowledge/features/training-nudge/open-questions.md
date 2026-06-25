# Open Questions: Training Nudge

**Feature:** `training-nudge`
**Date:** 2026-06-25

---

## Blocks build

- [ ] **What does the nudge actually send?** Is it a new email template, or does it re-trigger the existing overdue notification? Does it include the specific training name(s) that are overdue, or is it a generic reminder?
- [ ] **Rate limiting**: Can a user be nudged multiple times in a day? Is there a cooldown? This determines whether "last nudged" is just informational or acts as a lock.
- [ ] **Manager nudge authority**: When a manager nudges a direct report, does the email come from the manager's name ("Your manager Alice Brown wants you to complete...") or from the system ("Dune Security reminder...")?

## Design decisions

- [ ] **Nudge scope in BISO admin view**: Does nudging a user from the Training Data table nudge them for that specific training only? Or does it nudge for all their overdue trainings?
- [ ] **Bulk nudge behavior**: If a user has 3 overdue trainings and is bulk-nudged, do they receive 3 emails or 1 consolidated email?
- [ ] **Non-admin BISO view completeness**: The current Figma frame shows only 1 row. Is this view fully designed elsewhere? What is the intended scope — direct reports only, or any user visible in a manager's department?
- [ ] **"Last nudged" display**: How long should the "last nudged" timestamp be shown? After 7 days does it reset? Or is it always shown?

## UX/edge cases

- [ ] What happens when you try to nudge a user who has no email on file?
- [ ] Can a manager see if an admin already nudged their direct report (to avoid double-nudging)?
- [ ] If the user completes the training between the nudge send and when the admin views the table, does the nudge CTA disappear?
