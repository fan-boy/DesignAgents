# Open Questions — Quiz Training Type

## Unresolved
- [ ] [Both] What validation runs against the uploaded JSON, and what does the admin see on a malformed, empty, or oversized file?
- [ ] [PM] What happens when a learner exhausts all 3 attempts without meeting the passing score?
- [ ] [PM] What is the learner's end state when Retake on fail is disabled and they fail?
- [ ] [PM] Can a published quiz be edited/re-versioned, and does that trigger a re-take requirement for users who already completed it?
- [ ] [Both] Which roles can create, publish, or assign a Quiz? `[Blocks build]`
- [ ] [PM] Should quiz assignment reject duplicates the same way module assignment does ("already assigned" failure)?
- [ ] [PM] Is there a dedicated "New Quiz Assigned" email, or does Quiz reuse the generic assignment template shown for Policies?
- [ ] [PM] What is the correct final label for wizard Step 2 — "Content," "Quiz," or "Review"? Frames show all three inconsistently.
- [ ] [PM] Does Quiz completion/score feed the Risk Scoring Engine the same way module assessments do?

## Resolved
- [x] [Both] Does Assign Quiz reuse the full Assign Module wizard (audience tabs, due date, review step), or is it a lighter single-step action? — **Answer:** Reuses the full Assign Module wizard (Assignment Type → Assessment → Assign To → Review, with Users/Departments/Custom Groups/Smart Groups tabs), for audience-targeting parity with every other content type in Training.
- [x] [PM] Is passing score/retake intentionally fixed per-quiz rather than per-assignment, unlike Module assessment config? — **Answer:** No. Passing score and retake-on-fail become configurable per assignment, set in the Assign Quiz wizard's Assessment step. The value set at Publish becomes the default that's pre-filled (and overridable) at assignment time, rather than a fixed, uneditable value.
- [x] [PM/Design] Should each quiz question give immediate per-question feedback (correct answer + why) or withhold feedback until the quiz is scored? — **Answer:** Withhold feedback until the full quiz is scored, keeping Quiz a hard pass/fail gate consistent with Dune's compliance-oriented positioning (as distinct from KnowBe4's inline teaching-oriented Knowledge Check pattern).
