## Last updated — 2026-07-08
Resolved with stakeholder input: Assign Quiz reuses the full Assign Module wizard rather than a lightweight action, passing score/retake become configurable per assignment (not fixed at publish), and quiz-taking withholds feedback until final scoring rather than teaching per question. The "Create Quiz" and "Assign Quiz" sections below are updated accordingly.

Admins can create **Quiz** as a new, standalone training content type inside the Training Library, alongside Security Awareness, User Activity, Functional, Compliance, Custom, and Policies. A Quiz is a set of multiple-choice questions the admin uploads as a JSON file rather than authoring one at a time in the UI. Once published, a Quiz can be assigned directly to users, independent of any training module, through the same multi-step assignment wizard used for Modules, with a passing score and retake rule set per assignment that determines whether a learner passes or must retake it. End users complete assigned Quizzes from their training dashboard, and admins can track completion, review individual scores, drill into a specific user's exact answers, and filter Quiz performance in Advanced Reporting.

**Create Quiz (Admin)**

Admins open the Training Library and select the **Quiz** tab, a seventh tab alongside Security Awareness, User Activity, Functional, Compliance, Custom, and Policies. Before any quiz exists, the tab shows an empty state ("No Quiz Created Yet") with a **Create Quiz** call to action. Once quizzes exist, the tab shows a table (Title, Questions, Status, Created, Actions) with a "Search quizzes" box and status filters (All / Active / Inactive / All time).

Create Quiz is a 3-step wizard:

| Step | Fields | Validation / Notes |
|---|---|---|
| 1. Basic Info | Quiz title (text, placeholder "e.g. Acceptable Use Policy"), Description (textarea, optional) | Title is required; Next is disabled until filled |
| 2. Content | "Download JSON Template" action, Quiz Document upload (click-to-upload or drag-and-drop) | Accepts `.json` only, max 10 MB. On successful upload, shows "[filename].json uploaded successfully" and the parsed question count, plus a "Review Questions" list where each question can be expanded to show its answer options with the correct answer marked (e.g. "Correct answer: B"). A "Change file" action lets the admin re-upload before continuing. |
| 3. Publish | Read-only summary (Quiz name, "[quiz type] · [filename].json"), Questions count, Question type ("Multiple choice"), Created date, **Passing score** (percentage, default 80%, hint: "Learners must score at or above this threshold to pass"), **Retake on fail** (toggle, hint: "Learners who fail will be prompted to retake the quiz") | Cancel / Publish Quiz. These two values are saved as the quiz's default and are pre-filled (and overridable) in the Assess step of the Assign Quiz wizard — they are not locked once published. |

Publishing shows a brief "Publishing quiz..." progress state (quiz name and question count, Cancel disabled) followed by a success toast: "Quiz published successfully — [Quiz Name] is now live." The new quiz then appears in the Quiz tab table with status Published.

Each uploaded question is multiple choice with a fixed set of answer options (observed as four: A–D) and exactly one correct answer, defined in the uploaded JSON rather than configured through the wizard UI.

**Assign Quiz (Admin)**

A published quiz is assigned through the same multi-step Assign wizard used for Modules, launched from the **Assign** action on its row in the Quiz tab table:

| Step | Content |
|---|---|
| 1. Assignment Type | Quiz is a single unit of assignment (no "as individual trainings" split, since a quiz has no separable sub-items) |
| 2. Assessment | **Passing score** and **Retake on fail**, pre-filled from the quiz's published defaults and editable per assignment, so the same quiz can carry a stricter or lighter bar for different audiences |
| 3. Assign To | Same four audience tabs used for Module assignment: Users, Departments, Custom Groups, Smart Groups, with the same filters, search, and combined-audience counting |
| 4. Review | Quiz Details (name, question count), Assessment (passing score, retake setting), Audience (selected count) before confirming |

Assignment otherwise follows the same completion pattern as Module assignment: a live progress indicator while assigning, a results screen confirming success count and any per-user failures (e.g. duplicate assignment), and a success toast on return to the Quiz tab.

**End User — Taking a Quiz**

An assigned Quiz appears as its own item on the end user's training dashboard, tagged with a **Quiz** badge, alongside its Duration and Due Date, with a **Start Quiz** call to action, distinct from module-based "Start Module" / "Resume Module" cards.

Taking the quiz presents one question at a time: a "Question N of M" progress indicator, an "Attempt X/3" counter, the question text, single-select multiple-choice answer options, and a **Next** button to advance. The correct answer is not revealed as the learner progresses; scoring happens once all questions are answered. On completion, the learner's score is evaluated against the passing score set for that assignment. If **Retake on fail** is enabled for that assignment and the learner does not meet the passing score, they are prompted to retake the quiz.

**Admin — Quiz Tracking & Review**

A user's Training Status table includes their assigned Quizzes alongside modules and policies, with columns for Name, Completion Status, and Score (e.g. "7/10"). Selecting a completed Quiz opens a detail view showing the "Overall Score" (e.g. "8/10"), the "Date Completed," and a full per-question breakdown: each question the user was asked, the answer options presented, and (implicitly) which option the user selected, letting an admin audit exactly how a user answered.

Integration Points

| Integration | Description |
|---|---|
| Risk Scoring Engine | Quiz completion and score are visible alongside other training completion data on a user's Training Status; treat Quiz pass/fail as a completion signal consistent with other assessed content |
| Advanced Reporting | The Create Report builder exposes **Quiz name** (dropdown, e.g. "Pre Assessment") and **Quiz Status** (Passed / Failed) as filterable columns, letting admins build custom exports segmented by quiz performance |
| Email Notifications | Quiz assignment is expected to follow the same "New [Content] Assigned" email pattern used for policies and modules (recipient name, due date, duration, "Start Training Now" CTA, sent from the configured Training Sender Email Domain); no Quiz-specific template was found in the designs |
| Training Library | Quiz is a seventh content-type tab alongside Security Awareness, User Activity, Functional, Compliance, Custom, and Policies |

Edge Cases & System Behaviour

| Scenario | Behaviour |
|---|---|
| Uploaded JSON is malformed, missing required fields, or has zero questions | Upload should be rejected with an inline error rather than silently accepted (exact validation messaging not shown in designs) |
| Uploaded JSON exceeds 10 MB or is a non-JSON file type | Rejected with inline size/type error, matching the pattern used for policy PDF uploads |
| Admin clicks "Change file" after reviewing questions | Prior upload is discarded and the admin can upload a new JSON file before proceeding to Publish |
| Learner exhausts all 3 attempts without meeting the passing score | Not specified in the designs; needs a defined end state (e.g. remains failed/incomplete vs. escalation) |
| Retake on fail is disabled and the learner fails | Learner's result presumably remains "Failed" with no further attempt path; not explicitly shown |
| Quiz title left blank | Next is disabled at Step 1 until a title is entered |
| Quiz assigned to a user who already has it assigned | Not shown in these frames; other content types in this library reject duplicate assignment with a per-user "already assigned" failure reason |
