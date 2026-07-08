### Feature summary
Quiz introduces a standalone, assignable content type to the Training Library: admins upload a JSON file of multiple-choice questions instead of authoring a module, set a passing score and retake toggle once at publish time, and assign the finished quiz directly to users. The primary user is an Admin (creation, assignment, tracking) with a secondary End User flow (taking the quiz). The trigger is an admin choosing to create a quiz from the Training Library. **Missing from the PRD:** no success metric is defined, no RBAC gating is shown anywhere in the designs, and there is no distinct Assign Quiz wizard — only a generic per-row Assign action was observed, unlike the multi-step Assign Module flow this feature is explicitly modeled after.

### Gaps and ambiguities
1. **No dedicated Assign Quiz wizard was found.** Only a per-row "Assign" action exists in the Quiz tab table. It's unclear whether this reuses the richer Assign Module pattern (Assignment Type → Assessment → Assign To → Review, with Users/Departments/Groups/Smart Groups tabs) or is a lighter, single-step audience-and-due-date action. This materially changes assign-flow scope. `[Both]`
2. **Passing score and retake behavior are quiz-level, not assignment-level.** Both are set once at Publish, unlike the Module assessment model where frequency/format is chosen per-assignment. This means the same quiz cannot have different pass thresholds for different audiences. Confirm this is intentional. `[PM]`
3. **JSON upload is the only question-authoring path.** There's no in-UI question builder. Admins rely entirely on the "Download JSON Template" + manual editing + re-upload loop. Validation and error messaging for malformed, empty, or partially-invalid JSON is not shown. `[Both]`
4. **Attempt exhaustion is undefined.** The end-user quiz UI shows "Attempt 1/3," but nothing in the designs shows what happens when a learner exhausts all 3 attempts without meeting the passing score. `[PM]`
5. **No edit/versioning flow was observed for a published quiz.** Unclear whether admins can update questions post-publish and, if so, whether previously-completed users are required to retake it (the Policy re-acknowledgment pattern is the closest precedent). `[PM]`
6. **RBAC is entirely unaddressed.** No role-gating, disabled state, or permission boundary appears anywhere in the Quiz frames. `[Both]`
7. **Wizard step labels are inconsistent across frames** ("Basic Info / Content / Publish" vs. "Basic Info / Quiz / Publish" vs. "Basic Info / Review / Publish"). Likely mid-iteration naming; confirm the intended final labels with design before handoff. `[PM]`
8. **No Quiz-specific notification template was found.** Only "New Policy Assigned" exists as a precedent for assignment emails. Confirm whether Quiz reuses that template pattern or needs its own copy. `[PM]`

### Missing states
**System states**
- Uploaded JSON fails to parse or is missing required fields
- Parsed JSON yields zero questions
- Publish succeeds on the backend but the success toast/redirect fails to render
- Network failure mid-"Publishing quiz..." state

**Permission states**
- A non-admin role attempts to reach the Quiz tab, Create Quiz, or the per-row Assign action
- A view-only admin views the Quiz tab and detail screens without action affordances

**Content states**
- Very large question sets (50+) in the "Review Questions" list — scroll/pagination behavior
- A quiz with a single question
- Duplicate quiz titles across the library
- A quiz assigned to a user who already has it assigned

**Action states**
- Admin abandons the Create Quiz wizard mid-flow — is a draft persisted or fully discarded?
- Admin uses "Change file" after already reviewing questions — do Basic Info fields (title/description) persist across the re-upload?
- Learner leaves a quiz in progress before completing it — resumable or restarts from Question 1?
- Learner exhausts all 3 attempts (see Gap 4)

**Responsive / Accessibility**
- Keyboard-only navigation through MCQ answer options and the Next button
- Screen reader announcement of "Question N of M" and "Attempt X/3" progress indicators

### Questions for PM / Eng
1. `[Both]` Does Assign Quiz reuse the full Assign Module wizard (audience tabs, due date, review step), or is it a lighter single-step action? This is the single biggest open scope question.
2. `[PM]` Is passing score/retake intentionally fixed per-quiz rather than per-assignment, or should this be configurable per audience like Module assessments are?
3. `[Both]` What validation runs against the uploaded JSON, and what does the admin see on a malformed or empty file?
4. `[PM]` What happens when a learner exhausts all 3 attempts without meeting the passing score?
5. `[PM]` Can a published quiz be edited/re-versioned, and does that trigger a re-take requirement for users who already completed it?
6. `[Both]` Which roles can create, publish, or assign a Quiz? Is this gated the same way as Create Module / Create Policy?
7. `[PM]` Should quiz assignment reject duplicates the same way module assignment does ("Module already assigned" failure reason)?
8. `[PM]` Is there a dedicated "New Quiz Assigned" email, or does Quiz reuse the generic assignment template shown for Policies?

### Design risks
- **Locking passing score at publish time risks rework.** If stakeholders later want per-audience pass thresholds (as Modules support via per-assignment assessment config), the current one-quiz-one-threshold model will need retrofitting rather than extension.
- **JSON-only authoring is a support burden risk.** Without strong template validation and clear inline errors, non-technical admins will publish broken or malformed quizzes, and the failure will surface far downstream (learners hitting a broken assessment) rather than at creation time.
- **Undefined attempt-exhaustion end state risks stuck learners.** If a learner fails 3/3 attempts with no defined next step, they can be left permanently "Failed" with no path forward, which will quietly suppress training completion rates and any risk-score signal tied to Quiz completion.
- **Assign-flow ambiguity risk cuts both ways.** Reusing the heavy 4-step Assign Module wizard for a "quick standalone quiz" may over-engineer what should be lightweight; building a bare one-step Assign action may under-deliver the audience precision (Departments/Smart Groups) admins already expect from every other content type in this library.

### Teaching notes
- **Closest existing precedent: the Policy Library.** Quiz should follow the same shape already established for Policies — a standalone content type with its own Library tab, its own create wizard, and a generic per-row Assign action rather than a bespoke assignment flow. Model Quiz's integration points on Policy's, not Module's.
- **The per-user quiz score drill-down is a new interaction pattern**, but it closely mirrors the Simulated Attack "Click details" drill-down (browser, OS, IP) already used on the End User Risk Insights page — both are single-record audit modals launched from a table row. Reuse that interaction model rather than inventing a new one.
- **This exact feature was already flagged as a gap.** `knowledge/features/custom-training-modules/qa-test-plan.md` Section 6 ("Quiz — Standalone Knowledge Check, found in Figma, absent from PRD") documents the same Quiz tab, wizard, and end-user pattern discovered independently during QA of Custom Training Modules, with a largely overlapping open-questions list (attempt limits, risk-score impact, versioning). Resolve both documents' open questions together rather than treating this as isolated new scope — some may already have answers from that earlier discussion.
