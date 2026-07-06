# QA Test Plan: Custom Training Modules (Pre-GA)

**Feature:** `custom-training-modules`
**Date:** 2026-07-06
**Source:** Custom Training Modules PRD (Policies, Create Module, Assign Module, End User completion)
**Purpose:** Full flow + edge case coverage to sign off before GA. Organized by the four core flows in the PRD: (1) create module, (2) assign module, (3) end user completes module, (4) end user reviews/accepts a policy — plus the policy library, notifications, integrations, and cross-cutting edge cases that touch all four.

---

## How to use this doc

Each flow section has a **Happy path** checklist and a **Variations & edge cases** table. Treat happy path as blocking for GA; treat edge cases as blocking unless explicitly triaged/deferred by product. The **Open questions for eng/product** section at the end lists behaviors the PRD doesn't specify — these should be resolved (not assumed) before sign-off.

---

## 1. Policy Library (Admin)

### 1.1 Create Policy — Happy path
- [ ] Admin navigates to Training Library → Policies tab
- [ ] Policy list displays existing policies with name, status (Published), last updated date
- [ ] Admin starts Create Policy wizard
- [ ] Step 1 (Basic Info): enters Policy Title, Category, Policy Owner, optional Description → Next enabled only once required fields are filled
- [ ] Step 2 (Content): uploads a valid PDF under 10 MB via click-to-upload
- [ ] Step 2 (Content): uploads a valid PDF under 10 MB via drag-and-drop
- [ ] Step 3 (Publish): enters Version Summary, sees change-confirmation copy, clicks Publish
- [ ] New policy appears in Policies list with status Published and correct last-updated date
- [ ] Published policy is selectable when building/editing a module

### 1.2 Update Policy — Happy path
- [ ] Admin selects "Update" on an existing published policy
- [ ] Wizard opens pre-filled with existing Basic Info / Content / Publish data
- [ ] Admin uploads a new version of the document and publishes
- [ ] Re-acknowledgment confirmation copy is shown before publish is confirmed
- [ ] Last-updated date refreshes in the policy list
- [ ] Users who previously acknowledged the old version are now shown as requiring re-acknowledgment

### 1.3 Assign Policy independently — Happy path
- [ ] Admin selects "Assign" on a policy from the list (not via a module)
- [ ] Policy can be assigned directly to users/groups without being part of a module
- [ ] Assigned policy appears correctly in the recipient's assigned items

### 1.4 Variations & edge cases — Policy Library

| Scenario | Expected behavior |
|---|---|
| Upload file > 10 MB | Upload rejected with inline size-limit error, wizard does not advance |
| Upload non-PDF file (docx, image, etc.) | Upload rejected with inline file-type error |
| Upload corrupted/empty PDF | Graceful error, no silent success |
| Policy Title left blank | Next/Publish blocked, inline required-field validation |
| Duplicate Policy Title | Confirm whether duplicates are blocked or allowed (see Open Questions) |
| Admin abandons wizard mid-flow (closes tab / navigates away) | No partial/draft policy is published; no orphaned upload left behind |
| Admin clicks Update but cancels before publishing | No changes persisted, no re-ack triggered |
| Policy updated while a user is actively viewing the old version | User's in-progress acknowledgment doesn't silently complete against the old version; user is prompted to re-review the new version |
| Policy deleted/archived while included in an active module | Module and any in-progress assignments handle this gracefully — need explicit rule (see Open Questions) |
| Policy included in multiple modules, one policy update | Version bump propagates to all modules containing it; all affected assignees flagged for re-ack |
| Two admins edit/update the same policy concurrently | Last-write-wins vs. conflict warning — needs product decision |
| Policy Owner field with no CISO/GRC group configured | Field still accepts free text or shows appropriate empty state |
| Very long Policy Title / Description | Truncates gracefully in list and card views, no layout break |

---

## 2. Create Module (Admin)

### 2.1 Create Standard Module — Happy path
- [ ] Admin opens Create Module wizard, selects module type = Standard at Step 1
- [ ] Step 1: enters unique Module Name (required) and optional Description
- [ ] Step 2 (Trainings): browses Training Library, filtered to SAT/FST videos only + policies
- [ ] Selecting items updates the "N selected" counter live
- [ ] Step 2: adds at least one training video and one policy document
- [ ] Step 3 (Review): read-only Module Details panel correctly summarizes trainings count and included policies
- [ ] Save creates the module; it appears in the module list

### 2.2 Create Compliance Module — Happy path
- [ ] Admin selects module type = Compliance at Step 1
- [ ] Step 2 only surfaces Compliance videos + policy documents (no SAT/FST videos selectable/visible)
- [ ] Step 3 Review panel reflects Compliance-only content, no assessment info implied
- [ ] Module saves successfully

### 2.3 Variations & edge cases — Create Module

| Scenario | Expected behavior |
|---|---|
| Module Name left blank | Cannot proceed past Step 1 |
| Module Name duplicates an existing module name | Blocked with inline "name must be unique" validation |
| Module Name differs only by case/whitespace from existing name | Confirm whether this counts as a duplicate (see Open Questions) |
| Admin tries to proceed past Step 2 with zero items added | Blocked — "Empty module" rule: "No Trainings added yet" empty state remains, Next disabled |
| Admin adds only a policy document, no training videos | Allowed per PRD (policy alone can satisfy "at least one item") — confirm module completion criteria still resolves correctly |
| Admin switches module type after adding content in Step 2 | Not possible per PRD (type locked from Step 1) — verify UI actually prevents going back to change type once Step 2 has selections, or clears selections if type is changed before Step 2 is touched |
| Admin searches Training Library with no results | Empty state shown, no broken UI |
| Admin selects an item, then deselects it | Counter decrements correctly, item removed from Step 3 summary |
| Admin adds a policy that is later updated/re-published while module is still in draft (not yet assigned) | Module picks up latest published version at assignment time, not a stale snapshot |
| Admin navigates back from Step 3 to Step 2 | Previous selections persist correctly |
| Admin abandons wizard before Step 3 | No partial module is created |
| Very large number of items selected (stress case, e.g. 50+ videos) | Step 3 summary and counters render without performance/layout issues |
| Two admins create modules with the same name simultaneously | Uniqueness check handles race condition (second save fails cleanly, doesn't create duplicate) |

---

## 3. Assign Module (Admin)

### 3.1 Assign Standard Module — Happy path
- [ ] Admin opens Assign wizard for a saved Standard module
- [ ] Step 1: selects "Assign as a module" — confirms single notification framing
- [ ] Step 1: selects "Assign as individual trainings" — confirms per-training notification framing
- [ ] Step 2 (Assessment): selects frequency (one per module / per training)
- [ ] Step 2: selects format (Open text / MCQ)
- [ ] Step 2: sets Training Completion Deadline (days)
- [ ] Step 3 (Assign To): selects audience via Users tab
- [ ] Step 3: selects audience via Departments tab
- [ ] Step 3: selects audience via Custom Groups tab
- [ ] Step 3: selects audience via Smart Groups tab
- [ ] Step 3: combines audiences across multiple tabs in one assignment
- [ ] Step 4 (Review): summary correctly shows module name, trainings/policy count, assessment type/frequency/format, audience counts
- [ ] Clicking "Assign Module" confirms assignment
- [ ] Success toast "Training assigned successfully" appears with working "View in Simulated Attack tracker" link

### 3.2 Assign Compliance Module — Happy path
- [ ] Admin opens Assign wizard for a saved Compliance module
- [ ] Step 2 (Assessment) is shown but frequency/format controls are disabled
- [ ] Explanatory note is displayed: "Compliance modules don't include an assessment..."
- [ ] Training Completion Deadline is still settable (confirm — see Open Questions)
- [ ] Step 4 Review reflects no assessment for this module
- [ ] Assignment completes successfully, no assessment step is presented to end users later

### 3.3 Variations & edge cases — Assign Module

| Scenario | Expected behavior |
|---|---|
| Admin proceeds to Step 3 without selecting any audience | Blocked — cannot assign to zero recipients |
| Smart Group with zero currently-matching members at assignment time | Assignment allowed but resolves to 0 recipients now — confirm whether admin is warned, and whether new matches later auto-receive the module |
| Smart Group membership changes after assignment (user newly matches or drops out) | Confirm whether module assignment is dynamic (auto-adds/removes) or a point-in-time snapshot (see Open Questions) |
| Same user targeted via multiple audience paths (e.g. individually + via a group) | User receives exactly one assignment, not duplicates |
| User already has this module assigned (re-assign) | Confirm behavior: reset progress vs. no-op vs. error |
| Deadline set to 0 or negative days | Validation blocks invalid deadline values |
| "Assign as individual trainings" selected with a module that includes a policy | Confirm how policy acknowledgment is tracked/notified in the individual-trainings mode |
| Admin switches Assignment Type (Step 1) after configuring Step 2/3 | Confirm whether downstream selections persist or reset |
| Assessment format = Open text, AI grading engine unavailable/times out | Graceful fallback/error, doesn't block user's submission indefinitely |
| Assessment per training vs. one per module — module has only 1 training | Both options behave sensibly / equivalently, no broken UI |
| Admin navigates away mid-wizard (browser back, tab close) | No partial assignment is created |
| Admin re-opens Review step and edits an earlier step | Changes reflected correctly on return to Review |
| Assigning a module whose content includes a policy that's since been unpublished/archived | Confirm module assignment behavior — block, warn, or silently skip the policy (see Open Questions) |
| Large audience (e.g. all users org-wide via Smart Group) | Assignment completes and notifications send without timeout/failure at scale |
| RBAC: non-admin role attempts to access Assign Module | Action is not available / blocked per role permissions |

---

## 4. End User — Policy Review & Acceptance

### 4.1 Happy path
- [ ] User sees a policy document listed as an item within an assigned module, or as a standalone assigned policy
- [ ] User opens the policy — document renders/downloads correctly (PDF)
- [ ] User formally acknowledges/accepts the policy (explicit action, not passive view)
- [ ] Policy item status updates to Completed
- [ ] Acceptance is timestamped and recorded in the Policy Acknowledgement Log
- [ ] If policy was the only remaining item, parent module status updates to Completed

### 4.2 Variations & edge cases — Policy Acceptance

| Scenario | Expected behavior |
|---|---|
| User attempts to mark module/training complete without acknowledging the policy | Blocked — policy acknowledgment is a hard completion gate |
| Policy is updated (new version published) after user already acknowledged it | User is prompted to re-acknowledge the new version; old acknowledgment doesn't count toward current completion |
| User re-acknowledges a policy they'd already accepted (no change) | Confirm this is a no-op or handled gracefully, not a duplicate log entry issue |
| User's session expires / connection drops while viewing policy PDF | No partial/false acknowledgment is recorded |
| Policy assigned independently (not via a module) — user completes it | Reflected correctly in user's assigned items list and completion state, independent of any module |
| User has the same policy assigned both standalone and inside a module | Single acknowledgment satisfies both, not tracked as two separate obligations (or confirm if it's intentionally tracked twice — see Open Questions) |
| Policy document fails to load/render for the user | Clear error state, user isn't silently stuck |
| Tenant-level isolation | Policies from Tenant A are never visible/assignable to users in Tenant B |

---

## 5. End User — Assigned Module Completion

### 5.1 Happy path — Dashboard & module list
- [ ] "Your Assigned Learning Modules" section appears on user dashboard with headline copy
- [ ] Each module card shows: name, type (Module), status, duration, completion %, thumbnail carousel of included trainings
- [ ] CTA reads "Start Module" for not-yet-started modules
- [ ] CTA reads "Resume Module" for in-progress modules
- [ ] No modules assigned → empty state "No Modules Yet..." is shown

### 5.2 Happy path — Completing a Standard module
- [ ] User opens module, sees all items (videos + policies) with individual status badges
- [ ] User watches a SAT/FST video to completion
- [ ] Assessment is presented per the module's configured frequency (per-module or per-training) and format (open text / MCQ)
- [ ] User submits assessment; video/training item is marked Completed only after assessment is passed
- [ ] User completes all items including any policy acknowledgment
- [ ] Module status updates to Completed; completion % reflects progress accurately at each step along the way
- [ ] Completed training/assessment feeds into the user's risk score (Risk Scoring Engine integration)

### 5.3 Happy path — Completing a Compliance module
- [ ] User opens Compliance module, sees compliance videos + any policies, no assessment prompts
- [ ] Video is marked Completed on playback finish alone (no knowledge check)
- [ ] Any included policy still requires acknowledgment before module reaches Completed
- [ ] Module completion does not affect risk score

### 5.4 Variations & edge cases — End User Completion

| Scenario | Expected behavior |
|---|---|
| Compliance module fully watched | Module marked Completed, no assessment, no risk-score change |
| Compliance module with a policy, video watched but policy not yet acknowledged | Module remains incomplete until policy is acknowledged |
| User already completed a training video in a prior assignment, now reassigned via a new module | Not required to re-watch; existing completion honored |
| User already completed a training video, but its assessment requirement changed in the new module (e.g. now requires an assessment where the old assignment didn't) | Confirm correct behavior — does prior completion still count without the assessment? (see Open Questions) |
| Module deadline passes before user starts/finishes | Status shows "Overdue by X days" on card and in admin tracking views |
| User completes module exactly on deadline day | Not incorrectly flagged as overdue |
| User completes an item after it's already flagged Overdue | Status updates from Overdue to Completed correctly; module-level status recalculates |
| Module contains items with mixed statuses (e.g. 2 Completed, 1 In Progress, 1 Overdue) | Completion % calculates correctly; module-level rollup status reflects the least-complete item appropriately |
| User starts assessment (open text), leaves before submitting | In Progress state preserved, no data loss, resumable |
| AI grading of open text response is inconclusive or fails | User isn't left in permanent limbo; fallback path exists (e.g. manual review flag) |
| MCQ assessment failed | Confirm retry behavior — can user retake immediately, is there a cooldown/attempt limit? (see Open Questions) |
| User assigned the same module twice (e.g. reassigned by two different Smart Groups) | Single module instance/progress shown, not duplicated on dashboard |
| Module reassigned after user already completed it fully | Confirm whether it shows as already Completed or resets (see Open Questions) |
| Video playback interrupted (network drop, browser refresh) mid-video | Progress checkpointing works, doesn't force restart from 0% unnecessarily |
| Module with only a policy, no videos | Module completion driven entirely by policy acknowledgment; UI doesn't show broken/empty training progress elements |
| Thumbnail carousel with a single training item | Renders correctly without carousel-empty/broken-arrow states |
| User has zero risk-score-impacting modules but multiple compliance-only modules | Dashboard headline copy ("reduce your risk score") still makes sense / doesn't mislead for compliance-only users |
| Accessibility: keyboard-only navigation through module contents and assessment | Fully operable without a mouse, focus order logical |
| Accessibility: screen reader on policy PDF viewer and acknowledgment control | Acknowledgment action is announced and operable |

---

## 6. Module Type & Content Rules (Cross-cutting)

| Scenario | Expected behavior |
|---|---|
| Attempt to add a Compliance video to a Standard module | Not selectable/visible in Step 2 — enforced by type constraint, not by save-time validation |
| Attempt to add a SAT/FST video to a Compliance module | Not selectable/visible in Step 2 |
| Module type displayed clearly and consistently in module list, card, and detail views | Type is visible wherever an admin or end user needs to distinguish Standard vs. Compliance |
| SAT + FST combination in one Standard module | Single assessment still required, correctly affects risk score |
| Module type shown as locked/non-editable when viewing an existing module's settings | No UI path allows changing type post-creation |

---

## 7. Notifications

### 7.1 Happy path
- [ ] New "training module assignment" notification type fires correctly for both "assign as module" and "assign as individual trainings" modes
- [ ] Notification is sent from the configured Training Sender Email Domain
- [ ] Notification content correctly reflects module name, deadline, and (if applicable) policy inclusion
- [ ] Overdue reminder notifications fire once a module/training passes its deadline

### 7.2 Variations & edge cases

| Scenario | Expected behavior |
|---|---|
| Training Sender Email Domain not configured for a tenant | Graceful fallback or clear admin-facing error, no silent failure |
| Bulk assignment to a large audience | All recipients receive notification, no drop-off/rate-limit silent failures |
| User's email bounces/invalid | Failure surfaced to admin, not silently swallowed |
| "Assign as individual trainings" with multiple items | Each training triggers its own notification, not batched incorrectly |
| Notification sent, then policy included in the module is updated before user acts | Confirm whether a follow-up notification/re-ack prompt is triggered |

---

## 8. Integrations

| Integration | Test focus |
|---|---|
| Adaptive Workflows | Module auto-assignment triggered by a risk event or onboarding workflow follows the same assignment rules/validations as manual assignment; verify correct module, audience, and deadline are applied |
| Risk Scoring Engine | Standard module assessment completion correctly feeds risk score; Compliance module completion correctly does NOT feed risk score; verify timing (immediate vs. batch recalculation) |
| Email Notifications | See Section 7 |
| Policy Acknowledgement Log | Every acceptance (standalone or via module) is timestamped, attributable to the correct user/tenant, and queryable for audit — verify log entry created for every acceptance path, including re-acknowledgments after a policy update |

---

## 9. Regression Checks (adjacent surfaces)

- [ ] Existing Training Library (non-module, individual training assignment) flows still function unchanged
- [ ] Existing risk score calculations for previously-assigned (pre-GA) trainings are unaffected by this release
- [ ] Training Nudge feature (see [training-nudge](../training-nudge/prd.md)) correctly recognizes overdue items within modules, not just standalone trainings
- [ ] Admin RBAC roles/permissions correctly gate access to Create Module, Assign Module, and Policy management screens
- [ ] Existing Policy Acknowledgement Log entries (pre-feature, if any) are not disrupted by new log entries

---

## Open questions for eng/product (resolve before GA sign-off)

1. **Duplicate module/policy names:** Is uniqueness case-sensitive / whitespace-sensitive? Exact validation rule needed.
2. **Policy version + prior acknowledgment:** When a policy is updated, is the old acknowledgment fully invalidated for risk/compliance reporting purposes, or retained as historical record alongside the new required re-ack?
3. **Policy/content deletion while in use:** What happens to an active module or in-flight assignment if a referenced policy or video is archived/deleted?
4. **Smart Group dynamism:** Is module assignment via Smart Group a one-time snapshot at assignment, or does membership stay dynamic (auto-add/remove users) for the life of the assignment?
5. **Reassignment behavior:** If a module is reassigned to a user who already completed it (fully or partially), does progress reset, stay as-is, or is reassignment blocked?
6. **Assessment retry rules:** For MCQ and open-text assessments, are there attempt limits or cooldowns on retake after a failed assessment?
7. **Compliance module deadlines:** Does the Training Completion Deadline still apply/display for Compliance modules given there's no assessment, only a completion requirement?
8. **Dual assignment (standalone + module) of the same policy:** Is this tracked as one obligation or two independent ones in reporting/logs?
9. **AI grading failure handling:** What is the defined fallback when the open-text AI grading engine cannot produce a result (timeout, error, ambiguous response)?
10. **Training completion carried across assessment-requirement changes:** If a user completed a video previously without an assessment, and a new module assignment requires one for the "same" video, is prior completion still honored?

---

## Sign-off checklist

- [ ] All Section 1–7 happy paths pass
- [ ] All edge cases triaged: fixed, or explicitly accepted/deferred by product with rationale recorded
- [ ] All open questions above answered and reflected in either the PRD or this test plan
- [ ] Regression checks (Section 9) pass
- [ ] Accessibility checks (keyboard, screen reader) pass for both admin wizards and end-user completion flow
