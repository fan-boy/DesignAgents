### Feature context
Admins need a way to turn a set of questions into a standalone, assignable knowledge check without building a full training module around it. The primary user is an Admin (creates, publishes, assigns, and reviews results); the secondary user is an End User / learner (completes the quiz). The trigger is an admin choosing **Create Quiz** from the Training Library. No success metric is defined in the PRD — flagged in `prd-research.json` and not invented here.

Per stakeholder decisions recorded in `open-questions.md` (2026-07-08), three structural questions are already resolved and treated as fixed inputs to this strategy, not open options:
1. **Assign Quiz reuses the full Assign Module wizard** (Assignment Type → Assessment → Assign To → Review), not a lightweight one-step action.
2. **Passing score and retake-on-fail are configurable per assignment**, pre-filled from the quiz's published defaults.
3. **Quiz-taking withholds feedback until final scoring** — no per-question "correct answer" reveal for learners, keeping Quiz a hard pass/fail gate.

### Design goal
Let an admin turn an uploaded question set into a trustworthy, assignable knowledge check in minutes using patterns learners and admins already know from Policies and Modules, and let a learner complete it with an unambiguous pass/fail outcome and a clear path forward on failure.

### Key constraints
- **JSON upload is the only authoring mechanism** — no in-UI question builder exists or is planned for v1. This makes upload validation and the "Review Questions" confirmation step the feature's main trust surface.
- **Reuse, don't invent.** Quiz must slot into the existing Training Library tab pattern, the existing Assign Module wizard, and the existing per-user Training Status table — not introduce parallel structures.
- **RBAC is unresolved.** No role gating was observed in the designs or specified in the PRD. Per Dune's RBAC-gated-flow constraint, this strategy does not guess permission logic; it flags where a `disabled` state with tooltip will be needed once roles are defined.
- **Attempt limit exists but its terminal behavior does not.** "Attempt 1/3" is shown in the designs; what happens after attempt 3 with no passing score is undefined and materially affects the end-user wireframe.
- Stillsuit DS v2 patterns only: wizard, table, modal/drawer, badge, accordion/disclosure list (already implied by the "Review Questions" expand/collapse pattern in the source designs).

### Strategy options
The remaining genuinely open design decision is **what happens when a learner exhausts all 3 attempts without passing**. This wasn't resolved with the stakeholder and directly shapes the end-user wireframe and the admin's Training Status view.

| Option | Description | Tradeoff |
|---|---|---|
| **A — Terminal failed state (Recommended)** | After the 3rd failed attempt, the quiz locks to a **Failed** status with no further retake affordance. The learner sees a clear, non-punitive message ("You've reached the maximum number of attempts for this quiz") and a pointer to contact their admin/manager. Admin sees "Failed — Attempts exhausted" in Training Status and can manually reassign if they choose. | Simple, matches how a hard compliance gate should behave, and reuses the existing manual-reassign action already available on every content type. Requires the admin to notice and act; no automatic escalation. |
| **B — Auto-reassign / cooldown reset** | After exhausting attempts, the system automatically grants a new attempt cycle after a cooldown period (e.g. 24–48 hours) without admin action. | Removes admin toil, but introduces new scheduling logic not present anywhere else in this feature or its closest precedent (Policies), and risks a learner discovering they can "wait out" a failure rather than genuinely re-engaging with the content. |

**Recommendation: Option A.** It requires no new backend scheduling concept, mirrors the manual-reassign pattern already used for every other content type in Training, and keeps the failure consequence visible to an admin rather than silently resolving itself. If product later wants automatic re-engagement, that's a additive change, not a rework.

### Recommended strategy
Build Quiz as a fourth content type sharing the same shape as Policies (standalone, own Library tab, own create wizard) but assigned through the same wizard used for Modules (since Quiz assignment now carries its own per-assignment Assessment step, unlike Policy assignment which has none). Concretely:

- **Create Quiz**: 3-step wizard (Basic Info → Content → Publish), matching the structure already in the Figma designs, with the Publish step's Passing score/Retake fields relabeled in copy as defaults ("Default passing score," "Default retake behavior") so admins understand they're editable later.
- **Assign Quiz**: 4-step wizard reusing Assign Module's structure, with Step 2 (Assessment) simplified to just Passing score + Retake on fail (no frequency/format choice, since a quiz has no separate assessment format decision — the quiz itself is the assessment).
- **Take Quiz**: one question at a time, no per-question feedback, ending in a single pass/fail result screen. On fail with retake enabled, a **Retake Quiz** CTA restarts from Question 1. On the 3rd failed attempt, the flow terminates per Strategy Option A above.
- **Review**: the existing per-user drill-down (Overall Score, Date Completed, per-question breakdown) stays as designed; extend it with an explicit "Attempts used: X/3" line so an admin doesn't have to infer exhaustion from status alone.

### Risks and tradeoffs
- Locking the terminal failure state (Option A) means a learner who fails 3 times has no self-service path back into compliance — this is intentional (matches a hard gate) but should be called out to PM as a support-load tradeoff: admins will need to notice and manually reassign.
- Reusing the full Assign Module wizard for something as small as a single quiz is heavier than Policy's simple "Assign" action. This is accepted because per-assignment passing score genuinely needs a home, but it does mean Quiz assignment has more steps than Policy assignment despite both being "single item" content types — worth a UX pass to make sure Step 1 (Assignment Type) doesn't feel like a pointless single-option screen for Quiz.
- JSON-only authoring remains the biggest unresolved trust risk in the whole feature (see `competitor-analysis.md`); this strategy does not solve validation UX beyond recommending it be treated as first-class (see Wireframe plan, Step 2).

### Wireframe plan

**Admin — Quiz Library**
- **Screen: Quiz tab (empty)** — Table pattern, empty state. Body: "No Quiz Created Yet" message + **Create Quiz** primary action. Edge case: RBAC-restricted admin sees the tab read-only with Create Quiz disabled + tooltip (pending RBAC definition).
- **Screen: Quiz tab (populated)** — Table pattern. Header: search ("Search quizzes"), status filter (All/Active/Inactive/All time). Columns: Title, Questions, Status (badge), Created, Actions (Assign). Empty search result state required but not yet designed.

**Admin — Create Quiz (wizard)**
- **Step 1 — Basic Info**: Wizard pattern, step bar shows 3 steps. Fields: Quiz title (required), Description (optional). Primary action: Next (disabled until title present). Secondary: Cancel.
- **Step 2 — Content**: Wizard body splits into "Download JSON Template" action + upload dropzone. States: empty (drag/click prompt), uploading, **parse error** (new state — inline error banner naming the problem: wrong file type, over 10MB, malformed JSON, zero questions), success (filename + question count + expandable "Review Questions" accordion showing each question's options with the correct answer marked, "Change file" secondary action). Primary action: Next, disabled until a valid upload exists.
- **Step 3 — Publish**: Read-only summary (name, source file, question count, question type, created date) plus two editable fields relabeled as defaults: **Default passing score** (%, pre-filled 80), **Default retake on fail** (toggle). Primary action: Publish Quiz. Secondary: Cancel, Back.
- **Transient state: Publishing** — non-dismissible progress row (quiz name + question count), Cancel disabled.
- **Confirmation**: success toast ("Quiz published successfully — [name] is now live"), returns to populated Quiz tab with the new row visible.

**Admin — Assign Quiz (wizard, reused Assign Module structure)**
- **Step 1 — Assignment Type**: Single-option screen (quiz is one unit); consider collapsing this step visually to a static line rather than a full step if there's truly only one choice — flag to design for a lighter treatment than Module's two-option screen.
- **Step 2 — Assessment**: Passing score and Retake on fail, pre-filled from the quiz's published defaults, editable for this assignment only.
- **Step 3 — Assign To**: Reuse Module's four audience tabs (Users, Departments, Custom Groups, Smart Groups) with existing filters/search/combined-count behavior.
- **Step 4 — Review**: Quiz Details (name, question count), Assessment (passing score, retake), Audience (selected count). Primary action: Assign Quiz.
- **Transient state**: live progress modal ("Assigning Quiz to Users," X/Y counter).
- **Result state**: success count, plus a failure table for any per-user rejections (e.g. "Quiz already assigned"), matching the Module assignment pattern exactly.

**End User — Take Quiz**
- **Entry**: dashboard card, **Quiz** badge, Duration, Due Date, **Start Quiz** CTA — visually distinct from Module cards (no thumbnail carousel, no progress-percent, since a quiz isn't multi-item).
- **Question screen**: "Question N of M" + "Attempt X/3" header, question text, single-select MCQ options, **Next**. No per-question feedback (per resolved decision).
- **Result screen (pass)**: score, "Passed" badge, return-to-dashboard action.
- **Result screen (fail, attempts remaining)**: score, "Failed" badge, plain-language framing ("You didn't reach the passing score this time"), **Retake Quiz** primary action if Retake on fail is enabled for this assignment.
- **Result screen (fail, attempts exhausted)** — new screen per Strategy Option A: "Failed — Attempts exhausted" badge, message pointing the learner to their admin/manager, no Retake action.

**Admin — Quiz Tracking & Review**
- **Per-user Training Status row**: Name (Quiz title), Completion Status (badge), Score (e.g. "7/10"), Actions.
- **Drill-down (modal or drawer)**: Overall Score, Date Completed, **Attempts used: X/3** (new field per this strategy), and a per-question breakdown (question text, options, the learner's selected answer, correct answer). Use the drawer pattern (480px) rather than a full-page navigation, consistent with other "inspect one record" admin views.

**Reporting**
- **Advanced Reporting — Create Report**: Quiz name (dropdown filter) and Quiz Status (Passed/Failed) as available columns/filters, as already designed. No new pattern required.

### Open issues
- Which roles can create, publish, or assign a Quiz — RBAC is undefined; do not design a `disabled` state's exact gating logic until this is answered, but reserve the visual space for it in Step 1 of Create Quiz and on the Quiz tab's Create Quiz button.
- What validation messaging appears for malformed/empty/oversized JSON — this strategy assumes an inline error banner exists but the exact copy and error taxonomy (wrong type vs. too large vs. unparseable vs. zero questions) needs content design input.
- Whether a quiz can be edited/re-versioned post-publish, and whether that forces already-completed users to retake it (mirrors the Policy re-acknowledgment precedent) — unresolved, and this strategy does not design an edit flow until it's answered.
- Whether Quiz completion feeds the Risk Scoring Engine the same way module assessments do — affects whether the Training Status row needs a risk-score-delta indicator.
- Whether there's a dedicated "New Quiz Assigned" email or it reuses the generic template — affects notification copywriting, not wireframe structure.

### Next design actions
1. Confirm the attempt-exhaustion strategy (Option A recommended above) with PM before wireframing the end-user fail states in Figma.
2. Design the JSON upload error-state taxonomy (content design input needed) as its own mini-flow before the Content step is considered final.
3. Build the Create Quiz and Assign Quiz wireframes in Figma directly on top of the existing Assign Module and Policy Library components rather than from scratch, per the reuse-first constraint above.
4. Flag the RBAC and email-template open issues to PM now, not at handoff, since they block a complete Step 1 / notification design.
