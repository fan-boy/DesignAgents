# QA Test Plan: Custom Training Modules (Pre-GA)

**Feature:** `custom-training-modules`
**Date:** 2026-07-06
**Source:** Custom Training Modules PRD (Policies, Create Module, Assign Module, End User completion) **cross-checked against the live Figma file** (Dune Security Master file → "Custom training Modules" page: Create module, Assign module, User views and accepts the policy, Pre assessment quiz, End User module sections, Email notification updates)
**Purpose:** Full flow + edge case coverage to sign off before GA. Organized by the four core flows in the PRD: (1) create module, (2) assign module, (3) end user completes module, (4) end user reviews/accepts a policy — plus the policy library, a Quiz content type found only in Figma, notifications, integrations, and cross-cutting edge cases.

---

## How to use this doc

Each flow section has a **Happy path** checklist and a **Variations & edge cases** table. Treat happy path as blocking for GA; treat edge cases as blocking unless explicitly triaged/deferred by product. The **Open questions for eng/product** section lists behaviors the PRD doesn't specify — these should be resolved (not assumed) before sign-off.

**Read this first:** Section 0 below lists concrete places where the current Figma designs contradict or extend the PRD text. These aren't hypothetical edge cases — they're things directly observed in the frames. Resolve which one is authoritative (PRD or design) before writing test cases against either.

---

## 0. Figma vs. PRD — discrepancies to resolve before GA

| # | PRD says | Figma design actually shows | Why it matters |
|---|---|---|---|
| 1 | Module Type (Standard/Compliance) is "selected upfront at Step 1 — Details" and "locked for the life of the module" | Step 1 (Details) of the Create Module wizard has only **Module Name** and **Description** fields. No Type selector is visible anywhere in the 3-step wizard. | If there's truly no Type selector in the build, none of the Standard/Compliance gating rules (content restrictions, assessment requirement, risk-score impact) have anywhere to be set from. This is the single biggest gap — confirm with eng whether Type selection exists elsewhere (e.g., inferred from content) or is simply not yet built. |
| 2 | Step 2 (Trainings) "only surfaces content valid for the selected type" — Compliance videos hidden from Standard modules and vice versa | The "Add Training" panel shows **all 6 tabs simultaneously enabled**: Security Awareness, User Activity, Functional, Compliance, Custom, Policies. Nothing in the frames shows a tab being hidden or disabled. | Directly contradicts the "mixing is blocked at the type level" rule. Test whether category gating exists at all in the current build, or whether an admin can freely mix a Compliance video and a SAT video in one module today. |
| 3 | Create Policy Step 1 (Basic Info) includes Policy Title, **Category**, **Policy Owner**, and Description | The actual Basic Info step only has **Policy Title** and **Description**. No Category or Policy Owner fields exist in the frame. | Test cases referencing Category/Policy Owner should be treated as not-yet-implemented until confirmed; don't file bugs against fields that were never built. |
| 4 | Assessment step for a Compliance module shows frequency/format **disabled** with an explanatory note ("Compliance modules don't include an assessment...") | The Assessment step shows **three** freely-selectable frequency options: "One assessment for the module," "Assessment per training," and **"No Assessment — No knowledge check. Just training videos."** No disabled state or explanatory note appears in any frame. | This means assessment presence may be an independent admin choice per assignment, not automatically derived from module type. If so, the PRD's "Compliance = no assessment, Standard = always required" rule needs to be reconciled with a design that lets any module skip assessment. |
| 5 | Not mentioned | A **"Quiz"** tab exists in the Training Library (7th content type) with its own Create Quiz wizard (Basic Info → Quiz/Content → Publish) and can be assigned to users as a standalone item, distinct from a module. End users see it on their dashboard with a "Quiz" badge and "Start Quiz" CTA, and it renders as a timed, multi-question MCQ knowledge check ("Question 1 of 5," "Attempt 1/3"). | This is a whole content type and assignment path with zero mention in the PRD text supplied. See Section 6 below — needs its own PRD coverage and sign-off, not just QA coverage. |
| 6 | Assign Module Step 4 (Review) shows "Assessment: Type, Frequency, Format" and "Audience: [count]" | Confirmed matching in Figma, with exact field labels: **Type** (As a module / As individual trainings), **Frequency** (Per training / One per module / No Assessment), **Format** (MCQ / Open text), **Audience → Selected: "32 Users · 1 group."** Also confirmed: an info banner "Users who previously completed training in this module won't need to retake those trainings" appears on the Review step. | Use these exact labels/copy when writing detailed test scripts so testers aren't guessing at what the UI says. |
| 7 | Not mentioned | Bulk assignment has a **confirmed, designed partial-failure state**: after assigning to a large audience, a results screen shows "Module Assigned Successfully to 1251 users" + "3 users could not be assigned. See below for details," with a table of Email + Issue (observed reason: **"Module already assigned"**). A live progress modal ("Assigning Module to Users," "10/1251") is also shown during the operation. | This converts what was an open question ("what happens on duplicate assignment?") into a concrete, testable, designed behavior — see Section 3. |
| 8 | Policy list shows "policy name, status (Published), last updated date" | The actual Policies tab table has columns: **Title, Version, Status, Last Updated, Actions** — there's a Version column not mentioned in the PRD. | Confirm whether Version is a visible number (v1, v2...) end-to-end, and add it to policy list test coverage. |
| 9 | Not addressed | The Publish step of Create Policy shows the re-acknowledgment warning ("Previously acknowledged users will need to re-acknowledge this policy") **unconditionally, including on first-ever creation of a brand-new policy**, where no one could have previously acknowledged anything. | Likely a copy bug — verify the warning is suppressed on initial creation and only shown on Update. |
| 10 | Module cards show "Type (Module)" | On the actual "Your Trainings" end-user page, cards are tagged inconsistently: one shows badge **"Module"**, another shows badge **"Compliance"** (a content category, not "Module"), and a third shows badge **"Draft"** (an admin-side publish status) while separately also showing status "Overdue" in the card body. | The "Draft" badge on an end-user-facing card looks like a data/binding bug — a user should never see admin content-status labels. Flag explicitly in Section 5. |
| 11 | Not mentioned | The end-user Trainings page has a second section below assigned modules: **"Optional trainings — Boost your knowledge and improve your risk score with these extra learning opportunities."** | Not in the PRD at all. Needs its own completion/tracking rules (do optional trainings ever go "Overdue"? do they affect risk score the same way?) — add to open questions. |

---

## 1. Policy Library (Admin)

### 1.1 Create Policy — Happy path
- [ ] Admin navigates to **Training** → Training Library → **Policies** tab (this is a tab within the shared Training Library component, alongside Security Awareness / User Activity / Functional / Compliance / Custom / Quiz — not a separate top-level nav item)
- [ ] Policy list displays existing policies with columns: Title, Version, Status, Last Updated, Actions
- [ ] Empty state ("No Policies Created Yet") renders correctly with a Create Policy CTA when no policies exist
- [ ] Admin starts Create Policy wizard
- [ ] Step 1 (Basic Info): enters **Policy Title** and optional **Description** → Next enabled only once Policy Title is filled (confirmed fields — Category/Policy Owner are NOT present in the current design; see [Discrepancy #3](#0-figma-vs-prd--discrepancies-to-resolve-before-ga))
- [ ] Step 2 (Content): uploads a valid PDF under 10 MB via click-to-upload; an inline preview of the uploaded PDF renders in the panel
- [ ] Step 2 (Content): uploads a valid PDF under 10 MB via drag-and-drop
- [ ] Step 3 (Publish): shows policy title, description, "Document Uploaded" confirmation, and a Create Policy button
- [ ] New policy appears in Policies list with status **Published**, a version number, and correct last-updated date
- [ ] Published policy is selectable from the Policies tab when building a module (via Add Training → Policies)

### 1.2 Update Policy — Happy path
- [ ] Admin selects "Assign" or the row's action menu on an existing published policy and finds an Update path
- [ ] Wizard opens pre-filled with existing Basic Info / Content data
- [ ] Admin uploads a new version of the document and publishes
- [ ] Re-acknowledgment warning ("Previously acknowledged users will need to re-acknowledge this policy") is shown before publish is confirmed
- [ ] Version number increments and Last Updated date refreshes in the policy list
- [ ] Users who previously acknowledged the old version are now shown as requiring re-acknowledgment

### 1.3 Assign Policy independently — Happy path
- [ ] Admin clicks the **Assign** button on a policy row in the Policies tab
- [ ] Policy can be assigned directly to users/groups without being part of a module
- [ ] Assigned policy appears correctly in the recipient's "Training Status" dashboard card, tagged with a **Policy** badge

### 1.4 Variations & edge cases — Policy Library

| Scenario | Expected behavior |
|---|---|
| Upload file > 10 MB | Upload rejected with inline size-limit error, wizard does not advance |
| Upload non-PDF file (docx, image, etc.) | Upload rejected with inline file-type error |
| Upload corrupted/empty PDF | Graceful error, no silent success |
| Policy Title left blank | Next/Publish blocked, inline required-field validation |
| Duplicate Policy Title | Confirm whether duplicates are blocked or allowed (see Open Questions) |
| **New policy, first-ever creation** | Confirm the re-acknowledgment warning does NOT appear on Step 3 — see [Discrepancy #9](#0-figma-vs-prd--discrepancies-to-resolve-before-ga); if it does appear, this is a copy bug to file |
| Admin abandons wizard mid-flow (closes tab / navigates away) | No partial/draft policy is published; no orphaned upload left behind |
| Admin clicks Update but cancels before publishing | No changes persisted, no re-ack triggered, version number does not increment |
| Policy updated while a user is actively viewing the old version | User's in-progress acknowledgment doesn't silently complete against the old version; user is prompted to re-review the new version |
| Policy deleted/archived while included in an active module | Module and any in-progress assignments handle this gracefully — need explicit rule (see Open Questions) |
| Policy included in multiple modules, one policy update | Version bump propagates to all modules containing it; all affected assignees flagged for re-ack |
| Two admins edit/update the same policy concurrently | Last-write-wins vs. conflict warning — needs product decision |
| Very long Policy Title / Description | Truncates gracefully in list, card, and PDF-preview header views, no layout break |
| Policy Version column | Confirm version numbering scheme (v1, v2... or date-based) is consistent between admin list and any end-user-facing version indicator |

---

## 2. Create Module (Admin)

**Note:** the "Module Type" concept (Standard vs. Compliance) from the PRD was not found anywhere in the actual Create Module wizard frames — see [Discrepancy #1](#0-figma-vs-prd--discrepancies-to-resolve-before-ga). The test cases below are written against the wizard as designed today (no Type step); Section 6 retains the PRD's type-gating rules as a separate checklist to re-verify once Type selection is confirmed to exist (or not) in the build under test.

### 2.1 Create Module — Happy path
- [ ] Admin navigates to Training → Modules panel (or "Create New Module" from the Training Modules list) and opens the Create Module wizard
- [ ] Step 1 (Details): enters unique **Module Name** (required) and optional **Description** → Next enabled only once Module Name is filled
- [ ] Step 2 (Trainings): starts from an empty state ("No Trainings added yet — Add trainings or policy documents to this module")
- [ ] Clicking **Add Training** opens a side panel with a search box, a live "N selected" counter, and 6 tabs: **Security Awareness, User Activity, Functional, Compliance, Custom, Policies**
- [ ] Selecting checkboxes across multiple tabs accumulates into a single running count (e.g., 4 selected spanning both a Security Awareness tab and the Policies tab)
- [ ] Clicking **Add to Module** returns to Step 2, now showing the selected items with per-item duration and remove (×) controls, plus a running **Total Duration**
- [ ] Step 3 (Review): read-only **Module Details** panel shows Name, Description, Duration, and a **Trainings** list with each item and its duration
- [ ] Clicking **Create Module** saves the module; a success state shows it in the Training Modules list as a card with thumbnail carousel, "Module" badge, "Number of Trainings: N · N Policy," Duration, and a "View and Assign" link

### 2.2 Variations & edge cases — Create Module

| Scenario | Expected behavior |
|---|---|
| Module Name left blank | Cannot proceed past Step 1 |
| Module Name duplicates an existing module name | Blocked with inline "name must be unique" validation |
| Module Name differs only by case/whitespace from existing name | Confirm whether this counts as a duplicate (see Open Questions) |
| Admin tries to proceed past Step 2 with zero items added | Blocked — "No Trainings added yet" empty state remains, Next disabled |
| Admin adds only a policy document, no training videos | Confirm this is allowed and module completion criteria still resolves correctly with only a policy item |
| Admin selects items across multiple category tabs (e.g., 2 Security Awareness + 1 Compliance video + 1 Policy) in one module | Given [Discrepancy #2](#0-figma-vs-prd--discrepancies-to-resolve-before-ga), confirm whether this is actually allowed today, contrary to the PRD's "mixing is blocked" rule — file a bug if it silently succeeds and product intends type gating to be enforced |
| Admin searches Training Library with no results | Empty state shown, no broken UI |
| Admin selects an item in the Add Training panel, then deselects it before confirming | Counter decrements correctly, item does not appear in Step 2 |
| Admin removes an item from Step 2 via the × control | Item removed, Total Duration recalculates, counter decrements |
| Admin adds a policy that is later updated/re-published while module is still unsaved | Module picks up latest published version at save/assignment time, not a stale snapshot |
| Admin navigates back from Step 3 to Step 2 | Previous selections persist correctly |
| Admin abandons wizard before Step 3 | No partial module is created |
| Very large number of items selected (stress case, e.g. 50+ videos) | Step 2/3 lists and counters render without performance/layout issues |
| Two admins create modules with the same name simultaneously | Uniqueness check handles race condition (second save fails cleanly, doesn't create a duplicate) |
| Module with a single item only (1 video, no policy) | Module Details / Review summary still renders correctly with singular vs. plural copy ("1 training" not "1 trainings") |

---

## 3. Assign Module (Admin)

### 3.1 Assign Module — Happy path
- [ ] From a module's detail page (Edit Module / **Assign** buttons), admin clicks **Assign**
- [ ] Step 1 (Assignment type): choosing **"Assign as a module"** highlights it green and shows copy "Users complete it as a unified learning path... One email notification sent for entire module assignment"
- [ ] Step 1: choosing **"Assign as individual trainings"** shows copy "...Individual notifications sent for each training in the module"
- [ ] Step 2 (Assessment): **Assessment frequency** offers three radio options — "One assessment for the module," "Assessment per training," **"No Assessment — No knowledge check. Just training videos"**
- [ ] Step 2: **Assessment format** offers "Open text response (graded by AI)" and "Multiple choice questions (MCQ) — automatically graded"
- [ ] Step 2: **Training completion deadline** stepper accepts a number of days after assignment (+/- controls and direct text entry)
- [ ] Step 3 (Assign To): 4 tabs — **Users, Departments, Custom Groups, Smart Groups**; Users tab has Department/Role/Risk Score filters, search, and a checkbox table (Name, Department, Role, Risk Score)
- [ ] Step 3: combining selections across multiple tabs (e.g., some individual Users + a Department) carries through to a combined audience count on Review
- [ ] Step 4 (Review): shows an info banner "Users who previously completed training in this module won't need to retake those trainings," plus **Module Details** (Name, Trainings count e.g. "3 trainings · 1 policy"), **Assessment** (Type: As a module/As individual trainings, Frequency, Format), and **Audience** (Selected: "N Users · N group")
- [ ] Clicking **Assign Module** shows a live progress modal: "Assigning Module to Users" with an "X/Y" counter
- [ ] On completion, a results screen confirms **"Module Assigned Successfully to N users"**; if any failed, a second line reads **"N users could not be assigned. See below for details"** with an Email + Issue table
- [ ] Closing the results screen shows an inline success toast on the module detail page: **"Training assigned successfully"**

### 3.2 Variations & edge cases — Assign Module

| Scenario | Expected behavior |
|---|---|
| Admin proceeds to Step 3 without selecting any audience | Blocked — cannot assign to zero recipients |
| **Assigning to a user who already has this exact module assigned** | **Confirmed designed behavior:** that user is excluded from the success count and listed in the failure table with reason **"Module already assigned"** — verify this exact copy and behavior, including when only some (not all) selected users are duplicates |
| Smart Group with zero currently-matching members at assignment time | Assignment allowed but resolves to 0 recipients now — confirm whether admin is warned, and whether new matches later auto-receive the module |
| Smart Group membership changes after assignment (user newly matches or drops out) | Confirm whether module assignment is dynamic (auto-adds/removes) or a point-in-time snapshot (see Open Questions) |
| Same user targeted via multiple audience paths (e.g. individually + via a group) in the same assignment action | User receives exactly one assignment, not duplicates, and is not incorrectly flagged as a failure |
| Selecting **"No Assessment"** for a module that PRD logic says should require one (e.g. a module built entirely of SAT videos) | Given [Discrepancy #4](#0-figma-vs-prd--discrepancies-to-resolve-before-ga), determine whether the UI actually allows this combination today and whether that's intended — if risk score is supposed to depend on assessment completion, an assessment-less "Standard-equivalent" module may create a risk-scoring gap |
| Deadline set to 0 or negative days | Validation blocks invalid deadline values |
| "Assign as individual trainings" selected on a module that includes a policy | Confirm how policy acknowledgment is tracked/notified in the individual-trainings mode |
| Admin switches Assignment Type (Step 1) after configuring Step 2/3 | Confirm whether downstream selections persist or reset |
| Assessment format = Open text, AI grading engine unavailable/times out | Graceful fallback/error, doesn't block user's submission indefinitely |
| Admin navigates away mid-wizard (browser back, tab close) | No partial assignment is created |
| Admin re-opens Review step and edits an earlier step | Changes reflected correctly on return to Review |
| Very large audience assignment (1000+ users) | Progress modal counter increments accurately and completes; verify performance/timeout behavior at scale (frame shows a 1251-user example) |
| Partial-failure table with many failed rows | Table is scrollable/paginated cleanly, doesn't break layout; failure reasons are accurate and distinct per cause (not all lumped as one generic error) |
| RBAC: non-admin role attempts to access Assign Module | Action is not available / blocked per role permissions |

---

## 4. End User — Policy Review & Acceptance

### 4.1 Happy path
- [ ] User sees a policy document listed as an item within an assigned module's "Get Started" list (with a distinct document icon vs. the video play icon), or as a standalone "Policy"-badged card on their Training Status dashboard
- [ ] User opens the policy — the PDF renders inline in a scrollable preview pane on the policy page
- [ ] Page shows the checkbox **"I have read and understood the full contents of this policy"** and legal copy: *"By clicking 'I Accept', you confirm that you have read, understood, and agree to comply with this policy. Your acceptance will be recorded with a timestamp and is legally binding within the scope of your employment agreement."*
- [ ] The **Accept** button's enabled/disabled state is gated correctly by the checkbox (verify: does it actually require the checkbox to be checked, or is it clickable regardless? — see Open Questions)
- [ ] After accepting, policy item status updates to Completed and the sidebar checklist marker fills in
- [ ] Acceptance is timestamped and recorded in the Policy Acknowledgement Log
- [ ] If policy was the only remaining item, parent module status updates to Completed

### 4.2 Variations & edge cases — Policy Acceptance

| Scenario | Expected behavior |
|---|---|
| User clicks "I Accept this policy" without checking the acknowledgment checkbox first | Confirm whether this is actually blocked in the build — the checkbox and button appear as separate controls in the design, not obviously wired together |
| User attempts to mark module/training complete without acknowledging the policy | Blocked — policy acknowledgment is a hard completion gate |
| Policy is updated (new version published) after user already acknowledged it | User is prompted to re-acknowledge the new version; old acknowledgment doesn't count toward current completion |
| User re-acknowledges a policy they'd already accepted (no change) | Confirm this is a no-op or handled gracefully, not a duplicate log entry issue |
| User's session expires / connection drops while viewing policy PDF | No partial/false acknowledgment is recorded |
| Policy assigned independently (not via a module) — user completes it | Reflected correctly in user's Training Status dashboard, tagged "Policy," independent of any module |
| User has the same policy assigned both standalone and inside a module | Single acknowledgment satisfies both, not tracked as two separate obligations (or confirm if it's intentionally tracked twice — see Open Questions) |
| Policy document fails to load/render for the user | Clear error state, user isn't silently stuck |
| Tenant-level isolation | Policies from Tenant A are never visible/assignable to users in Tenant B |
| PDF preview scroll on a long/multi-page policy | Scrollbar within the preview pane works correctly, user must be able to reach the end of the document (confirm whether reaching the end is itself a gate on enabling Accept) |

---

## 5. End User — Assigned Learning & Trainings Page

### 5.1 Happy path — Dashboard & assigned modules list
- [ ] "Your Trainings" page shows a **"Your Assigned Learning Modules"** section with headline "Complete these trainings to reduce your risk score and stay protected."
- [ ] Each module card shows: thumbnail carousel (dash indicators at top matching the number of items), title, a status/type badge, Due Date, Duration, and either a completion percentage + "Resume Module" CTA, or a status (e.g. "In Progress," "Overdue") + "Start Module" CTA
- [ ] Below assigned modules, an **"Optional trainings"** section appears: "Boost your knowledge and improve your risk score with these extra learning opportunities"
- [ ] No modules assigned → empty state ("No Modules Yet...") is shown
- [ ] "Training Status" widget on the Insights dashboard has Pending/Completed tabs and lists individual pending items (policies, modules, quizzes) with Duration, Due Date, Completion %, and a Start/Resume CTA

### 5.2 Happy path — Completing a module
- [ ] User opens module, right-rail "Get Started" checklist shows every item (training videos + policy documents) with distinct icons and per-item duration, plus a **Total Duration**
- [ ] User watches a training video to completion
- [ ] Any configured assessment is presented per the module's frequency/format settings
- [ ] User completes all items including any policy acknowledgment
- [ ] Module status updates to Completed; completion % reflects progress accurately at each step along the way
- [ ] Completed training/assessment feeds into the user's risk score (Risk Scoring Engine integration) where applicable

### 5.3 Variations & edge cases — End User Trainings Page

| Scenario | Expected behavior |
|---|---|
| **Module card badge correctness** | **Flag as likely bug:** cards observed in Figma show inconsistent badges — one "Module," one a content category ("Compliance"), and one an admin publish-status label ("Draft") on an end-user-facing card. Verify the actual build never surfaces "Draft" (or any admin-only status) to end users; badge should reflect assignment type/category consistently |
| Optional training completed | Confirm whether it moves out of "Optional trainings" into a completed state visible somewhere, and whether/how it affects risk score, since the PRD doesn't define this section at all (see Open Questions) |
| Optional training left incomplete indefinitely | Confirm it never becomes "Overdue" (no deadline context) and never blocks anything |
| User already completed a training video in a prior assignment, now reassigned via a new module | Not required to re-watch; existing completion honored (per the Review-step banner copy) |
| Module deadline passes before user starts/finishes | Status shows "Overdue by X days" on card and in admin tracking views |
| User completes module exactly on deadline day | Not incorrectly flagged as overdue |
| User completes an item after it's already flagged Overdue | Status updates from Overdue to Completed correctly; module-level status recalculates |
| Module contains items with mixed statuses (e.g. 2 Completed, 1 In Progress, 1 Overdue) | Completion % calculates correctly; module-level rollup status reflects the least-complete item appropriately |
| User starts an assessment, leaves before submitting | In Progress state preserved, no data loss, resumable |
| AI grading of open text response is inconclusive or fails | User isn't left in permanent limbo; fallback path exists (e.g. manual review flag) |
| MCQ assessment failed | Confirm retry behavior — can user retake immediately, is there a cooldown/attempt limit? (see Open Questions) |
| User assigned the same module twice (e.g. reassigned by two different Smart Groups) | Single module instance/progress shown, not duplicated on dashboard — consistent with the "Module already assigned" rejection confirmed in Section 3 |
| Video playback interrupted (network drop, browser refresh) mid-video | Progress checkpointing works, doesn't force restart from 0% unnecessarily |
| Module with only a policy, no videos | Module completion driven entirely by policy acknowledgment; UI doesn't show broken/empty training progress elements |
| Thumbnail carousel with a single training item | Renders correctly without carousel-empty/broken-arrow states |
| Accessibility: keyboard-only navigation through module contents and assessment | Fully operable without a mouse, focus order logical |
| Accessibility: screen reader on policy PDF viewer and acknowledgment control | Acknowledgment action is announced and operable |
| Admin-side per-user Training Status table (on a user's profile page) | Confirm Name/Status/Source/Due Date/Completion Date/Score columns populate correctly and pagination works at scale (Figma shows "Viewing 10 of 100") |

---

## 6. Quiz — Standalone Knowledge Check (found in Figma, absent from PRD)

**This entire flow was discovered in the Figma "Pre assessment quiz" section and has no corresponding PRD coverage — flag to product/PM for a written spec before GA, not just QA sign-off.** See [Discrepancy #5](#0-figma-vs-prd--discrepancies-to-resolve-before-ga).

### 6.1 Happy path (as observed)
- [ ] Admin opens Training Library → **Quiz** tab (7th tab alongside Security Awareness/User Activity/Functional/Compliance/Custom/Policies)
- [ ] Empty state: "No Quiz Created Yet" with a Create Quiz CTA
- [ ] Create Quiz wizard: Step 1 (Basic Info: Quiz title, optional Description) → Step 2 (Content/Quiz — questions) → Step 3 (Publish)
- [ ] On publish, a toast confirms "Quiz published successfully — [Quiz Name] is now live," and it appears in the Quiz list with Title/Status/Created columns
- [ ] Quiz can be assigned to a user directly, independent of any module
- [ ] Assigned quiz appears on the end user's Training Status dashboard tagged **"Quiz"** with a "Start Quiz" CTA
- [ ] Taking the quiz shows "Question N of M," an attempt counter ("Attempt 1/3"), single-select answer options, and a Next button
- [ ] Right-rail "Get Started" checklist shows a single "Knowledge Check" item with duration, and copy "Please finish the Knowledge check"

### 6.2 Open items to define before this can be tested properly

| Question | Why it matters |
|---|---|
| Is Quiz addable as an item inside a Create Module wizard (like Policies), or strictly a standalone-only assignment? | The Add Training panel in the Create Module flow did NOT show a Quiz tab — confirm this is intentional |
| What's the relationship between a standalone Quiz and a module's built-in "Assessment" (frequency/format from Section 3)? Are they the same underlying engine exposed two ways, or genuinely separate features? | Determines whether Quiz-specific bugs are actually module-assessment bugs and vice versa |
| Does a failed Quiz attempt (exhausting the "Attempt X/3" limit) block anything, or just remain incomplete/overdue? | Needed to write pass/fail edge cases |
| Does Quiz completion affect risk score? | Unclear — Quiz wasn't mentioned in the Risk Scoring Engine integration section of the PRD at all |
| Can a Quiz be updated/versioned like a Policy, requiring re-take by previously-completed users? | Needed for update/versioning test coverage parity with Policies |

---

## 7. Module Type & Content Rules (Cross-cutting — PRD-specified, unverified in current build)

**Treat this whole section as blocked pending resolution of [Discrepancies #1 and #2](#0-figma-vs-prd--discrepancies-to-resolve-before-ga).** If Module Type selection isn't actually in the build yet, none of these are testable as written — confirm with eng which of the following is true: (a) Type selection is coming in a later design iteration, (b) it's built but wasn't visible in these frames, or (c) the PRD's type-gating model has been superseded by the "assessment frequency includes No Assessment" model actually shown.

| Scenario | Expected behavior (per PRD, pending confirmation) |
|---|---|
| Attempt to add a Compliance video to a Standard module | Not selectable/visible in Step 2 — enforced by type constraint, not by save-time validation |
| Attempt to add a SAT/FST video to a Compliance module | Not selectable/visible in Step 2 |
| Module type displayed clearly and consistently in module list, card, and detail views | Type is visible wherever an admin or end user needs to distinguish Standard vs. Compliance |
| SAT + FST combination in one Standard module | Single assessment still required, correctly affects risk score |
| Module type shown as locked/non-editable when viewing an existing module's settings | No UI path allows changing type post-creation |

---

## 8. Notifications

### 8.1 Happy path
- [ ] New "training module assignment" notification type fires correctly for both "assign as module" and "assign as individual trainings" modes
- [ ] Notification is sent from the configured **Sender Training email domain** (e.g. `trainings@dunesecurity.io`, set under Training Configuration)
- [ ] "New Policy Assigned" email template renders with tenant branding (confirmed: logo swaps per tenant, e.g. "accentCare" in one sample), recipient first name, policy name, due date, duration, and a "Start Training Now" CTA
- [ ] Overdue reminder notifications fire once a module/training passes its deadline

### 8.2 Variations & edge cases

| Scenario | Expected behavior |
|---|---|
| Training Sender Email Domain not configured for a tenant | Graceful fallback or clear admin-facing error, no silent failure |
| Bulk assignment to a large audience | All recipients receive notification, no drop-off/rate-limit silent failures (cross-reference the partial-failure table in Section 3 — do failed-assignment users correctly NOT receive a notification?) |
| User's email bounces/invalid | Failure surfaced to admin, not silently swallowed |
| "Assign as individual trainings" with multiple items | Each training triggers its own notification, not batched incorrectly |
| Notification sent, then policy included in the module is updated before user acts | Confirm whether a follow-up notification/re-ack prompt is triggered |
| Tenant branding/white-labeling in email templates | Verify logo, sender name, and footer contact info correctly reflect the tenant, not a hardcoded default |

---

## 9. Integrations

| Integration | Test focus |
|---|---|
| Adaptive Workflows | Module auto-assignment triggered by a risk event or onboarding workflow follows the same assignment rules/validations as manual assignment; verify correct module, audience, and deadline are applied |
| Risk Scoring Engine | Assessed module/training completion correctly feeds risk score; completion without an assessment ("No Assessment" option, or Quiz) — confirm what does and doesn't feed risk score given [Discrepancy #4](#0-figma-vs-prd--discrepancies-to-resolve-before-ga) |
| Email Notifications | See Section 8 |
| Policy Acknowledgement Log | Every acceptance (standalone or via module) is timestamped, attributable to the correct user/tenant, and queryable for audit — verify log entry created for every acceptance path, including re-acknowledgments after a policy update |

---

## 10. Regression Checks (adjacent surfaces)

- [ ] Existing Training Library (non-module, individual training assignment) flows still function unchanged
- [ ] Existing risk score calculations for previously-assigned (pre-GA) trainings are unaffected by this release
- [ ] Training Nudge feature (see [training-nudge](../training-nudge/prd.md)) correctly recognizes overdue items within modules, standalone policies, and quizzes — not just standalone trainings
- [ ] Admin RBAC roles/permissions correctly gate access to Create Module, Assign Module, Policy, and Quiz management screens
- [ ] Existing Policy Acknowledgement Log entries (pre-feature, if any) are not disrupted by new log entries
- [ ] Existing Training Assignment Frequency org rules ("Minimum/Maximum Per Quarter," visible in Training Configuration) still apply correctly alongside module-based assignment volume

---

## Open questions for eng/product (resolve before GA sign-off)

1. **Module Type selection is missing from the build.** Where, if anywhere, does an admin choose Standard vs. Compliance? Without this, the type-gating rules in Section 7 can't be implemented or tested. **(Highest priority — blocks the most PRD content.)**
2. **Content-type gating in Add Training.** Is mixing SAT/FST and Compliance videos in one module actually prevented today, or does the current build allow any combination from any of the 6 tabs?
3. **Assessment model reconciliation.** Is "assessment frequency" (One/Per-training/No Assessment) an admin's free choice per assignment, or should it be automatically derived from — and locked by — module type as the PRD describes?
4. **Policy Basic Info fields.** Are Category and Policy Owner planned for a future iteration, or dropped from scope? Confirms whether to file missing-field bugs.
5. **Re-acknowledgment warning on first-time policy creation.** Should this warning be suppressed when there's no possible prior acknowledgment (i.e., only shown on Update, never on Create)?
6. **Duplicate module/policy names.** Is uniqueness case-sensitive / whitespace-sensitive? Exact validation rule needed.
7. **Policy version + prior acknowledgment.** When a policy is updated, is the old acknowledgment fully invalidated for risk/compliance reporting purposes, or retained as a historical record alongside the new required re-ack?
8. **Policy/content deletion while in use.** What happens to an active module or in-flight assignment if a referenced policy or video is archived/deleted?
9. **Smart Group dynamism.** Is module assignment via Smart Group a one-time snapshot at assignment, or does membership stay dynamic (auto-add/remove users) for the life of the assignment?
10. **Assessment retry rules.** For MCQ and open-text assessments (and standalone Quizzes, which show "Attempt 1/3"), are there attempt limits or cooldowns on retake after a failed attempt, and what happens after attempts are exhausted?
11. **Dual assignment (standalone + module) of the same policy.** Is this tracked as one obligation or two independent ones in reporting/logs?
12. **AI grading failure handling.** What is the defined fallback when the open-text AI grading engine cannot produce a result (timeout, error, ambiguous response)?
13. **Quiz scope.** Is Quiz in scope for this GA at all, or a separate, later-dated feature that happens to share the Training Library surface? Needs an owner and a spec — see Section 6.
14. **Optional trainings section.** What are the rules for this section (deadlines, risk-score impact, how items land here vs. in "Your Assigned Learning Modules")? Entirely undefined in the PRD.
15. **Module card badge logic.** What should a card badge show — assignment mode ("Module"), content category ("Compliance"), or something else — and confirm "Draft" (admin publish status) should never reach an end-user view.
16. **Accept-policy button gating.** Does "I Accept this policy" require the "I have read and understood..." checkbox to be checked first, or are they independent controls today?

---

## Sign-off checklist

- [ ] Section 0 discrepancies reviewed with product/eng and each one resolved (PRD updated, design updated, or explicitly deferred with rationale)
- [ ] All Section 1–6 and 8 happy paths pass against the resolved (not assumed) behavior
- [ ] All edge cases triaged: fixed, or explicitly accepted/deferred by product with rationale recorded
- [ ] All open questions above answered and reflected in either the PRD or this test plan
- [ ] Quiz (Section 6) has an explicit GA scope decision — included and fully tested, or explicitly excluded from this release
- [ ] Regression checks (Section 10) pass
- [ ] Accessibility checks (keyboard, screen reader) pass for both admin wizards and end-user completion flow
