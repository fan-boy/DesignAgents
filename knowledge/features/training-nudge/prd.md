# PRD: Training Nudge

**Feature slug:** `training-nudge`
**Status:** Discovery
**Date:** 2026-06-25

---

## Problem

Users with overdue trainings are not completing them without active follow-up. Currently, there is no in-product mechanism for admins or managers to send reminders to specific users. Follow-up happens out of band (email, Slack), is inconsistent, and creates manual overhead.

Two user types need this capability:
- **Admins** — can see all users across the org with overdue trainings (via BISO view or Control Panel/Training)
- **Managers** — can see their direct reports' overdue trainings (via BISO non-admin view: "Team Risk & Training Overview")

---

## Goals

1. Allow admins to nudge one or more users with overdue trainings directly from the BISO view
2. Allow managers to nudge their direct reports with overdue trainings from the BISO manager view
3. Keep the nudge action scoped to users who actually have overdue trainings (not all users)
4. Give enough transparency about what was sent (confirmation, audit trail)

---

## Non-goals

- Custom nudge message composition (v1 uses a standard template)
- Scheduling/recurring nudges
- Nudging from mobile
- Nudging users for in-progress (non-overdue) trainings in v1

---

## User stories

### Admin
- As an admin, I want to send a reminder email to a specific user with overdue trainings so that I can prompt them without leaving the platform.
- As an admin, I want to bulk nudge all users with overdue trainings so that I can efficiently follow up across my org.

### Manager
- As a manager, I want to nudge a direct report who has overdue trainings so that I can follow up on compliance within my team.
- As a manager, I want to see which of my reports I've already nudged so I don't send duplicate reminders.

---

## Scope

### In v1
- Per-row nudge action in BISO view Training Data table (rows with Overdue status)
- Per-row nudge action in BISO view User Data table (users with Overdue > 0)
- Per-row nudge action in manager BISO view ("Team Risk & Training Overview") for users with Overdue > 0
- Bulk nudge from Training Data table (select multiple overdue users → nudge)
- Confirmation state after nudge (toast or inline feedback)
- "Last nudged" indicator on user rows (so repeat nudges are visible)

### Out of v1
- Nudge from Control Panel > Training (separate surface — may be v2)
- Nudge from Specific User page
- Custom message editor
- Scheduled/automated nudges (that's the Workflows/Agent feature)

---

## RBAC

| Role | Can nudge |
|---|---|
| Admin | All users in org |
| Manager (BISO non-admin) | Direct reports only |
| Regular user | No |

---

## Open questions

See `open-questions.md`.
