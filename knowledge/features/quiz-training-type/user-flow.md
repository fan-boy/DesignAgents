### Entry points
- **Admin**: Training → Training Library → **Quiz** tab (seventh tab alongside Security Awareness, User Activity, Functional, Compliance, Custom, Policies)
- **End User**: assigned Quiz appears as a **Quiz**-badged card on the training dashboard / "Your Trainings" page, with a **Start Quiz** call to action

### Happy path
1. Admin opens the Quiz tab and clicks **Create Quiz**.
2. **Step 1 — Basic Info**: admin enters a Quiz title and optional description, clicks Next.
3. **Step 2 — Content**: admin downloads the JSON template, fills in questions offline, uploads the completed file.
4. System parses the file, confirms "[filename].json uploaded successfully" with the question count, and shows an expandable "Review Questions" list.
5. Admin reviews each question and its answer options, confirms the set looks correct, clicks Next.
6. **Step 3 — Publish**: admin confirms the quiz summary and sets a default passing score (defaults to 80%) and default retake-on-fail toggle, clicks Publish Quiz.
7. System shows a brief "Publishing quiz..." state, then a success toast ("Quiz published successfully — [name] is now live"). The quiz appears in the Quiz tab table with status Published.
8. Admin clicks **Assign** on the new quiz's row, opening the Assign Quiz wizard.
9. **Step 1 — Assignment Type**: single-unit assignment confirmed (no split into individual trainings, since Quiz has no sub-items).
10. **Step 2 — Assessment**: admin confirms or overrides the passing score and retake-on-fail for this specific assignment (pre-filled from the quiz's published defaults).
11. **Step 3 — Assign To**: admin selects an audience via Users, Departments, Custom Groups, or Smart Groups tabs.
12. **Step 4 — Review**: admin confirms Quiz Details, Assessment settings, and Audience count, clicks Assign Quiz.
13. System shows a live assignment progress indicator, then a results screen confirming success count (and any per-user failures).
14. Assigned users see the Quiz card on their dashboard and click Start Quiz.
15. Learner answers questions one at a time ("Question N of M," "Attempt X/3"), clicking Next after each, with no per-question feedback.
16. On the final question, the system scores the attempt against the assignment's passing score.
17. If the learner passes, they see a Passed result and the quiz is marked Completed on their dashboard and the admin's Training Status table.
18. If the learner fails and retake-on-fail is enabled and attempts remain, they see a Failed result with a **Retake Quiz** action and return to step 15.
19. Admin can open any completed quiz from a user's Training Status table to see Overall Score, Date Completed, attempts used, and a full per-question breakdown of that user's answers.
20. Admin can filter Quiz performance in Advanced Reporting using the Quiz name and Quiz Status (Passed/Failed) columns.

### Decision points
- **Step 2 upload validity**: valid JSON with 1+ questions → proceed to Review Questions; invalid/malformed/empty JSON → inline error, Next stays disabled (see Edge cases).
- **Publish step confirmation**: admin can go Back to Step 2 to re-upload before publishing; no partial/draft quiz is created if the wizard is abandoned.
- **Assignment Step 2 override**: admin either accepts the quiz's published default passing score/retake, or overrides it for this specific audience — both paths lead to the same Step 3.
- **End of quiz scoring**: score ≥ passing score → Passed exit; score < passing score → branches on retake-on-fail and attempts remaining (see below).
- **Retake branch**: retake-on-fail enabled AND attempts remaining (< 3 used) → Retake Quiz path; retake-on-fail disabled OR attempts exhausted (3/3 used) → terminal Failed exit.

### System responses
- File upload: shows a progress/parsing state, then either a success confirmation with question count or an inline parse error.
- Publish action: shows a non-dismissible "Publishing quiz..." state (Cancel disabled) before resolving to success toast or error.
- Assign action: shows a live "Assigning Quiz to Users" progress indicator with an X/Y counter, then a results screen; any per-user failures (e.g. duplicate assignment) are listed with a reason.
- Quiz scoring: evaluated only after the learner answers the final question — no incremental feedback during the quiz.

### Edge cases
- **Uploaded JSON is malformed, missing fields, or has zero questions** → inline error at Step 2, Next remains disabled, admin must fix and re-upload.
- **Uploaded file exceeds 10 MB or isn't JSON** → inline size/type error, matching the Policy PDF upload pattern.
- **Admin uses "Change file" after reviewing questions** → prior upload discarded, admin uploads again before proceeding.
- **Quiz title left blank** → Next disabled at Step 1.
- **Admin abandons the wizard mid-flow** → no partial quiz is created or published.
- **Quiz assigned to a user who already has it assigned** → that user is excluded from the success count and listed in a failure table with reason "Quiz already assigned," matching the Module assignment pattern.
- **Learner leaves a quiz in progress** → not explicitly defined; flagged as an open issue in `design-strategy.md`.
- **Learner exhausts all 3 attempts without passing** → terminal "Failed — Attempts exhausted" state; no further Retake action; admin sees the exhausted status in Training Status and can manually reassign.
- **Retake-on-fail disabled and learner fails** → same terminal Failed exit, regardless of attempts remaining.
- **RBAC-restricted admin** → Create Quiz / Assign / view actions render disabled with a tooltip once permission logic is defined (not yet specified — see `open-questions.md`).

### Exit states
- **Success (admin)**: quiz published and visible in the Quiz tab; or quiz successfully assigned with a confirmed audience count.
- **Success (learner)**: Passed result, quiz marked Completed.
- **Terminal failure (learner)**: Failed — Attempts exhausted, no further learner-initiated action available.
- **Cancellation (admin)**: wizard cancelled at any step, no data persisted.
- **Error**: JSON parse/validation error at Step 2; assignment failure for specific users at Step 4 execution (partial success supported, not all-or-nothing).
