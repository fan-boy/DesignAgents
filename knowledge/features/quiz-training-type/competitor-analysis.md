### Feature context
Quiz Training Type lets a Dune admin upload a JSON set of multiple-choice questions as a standalone, assignable Training Library content type, set a passing score and retake toggle once at publish, and track individual learner scores and per-question responses. Per `prd-research.json`, the open questions most relevant to competitive framing are: whether passing score should be fixed per-quiz or configurable per-assignment, what happens when a learner exhausts retry attempts, and whether the assign flow should be a full audience wizard or a lightweight action.

### Competitors reviewed
Selected per the "Training content / module delivery" row of the competitor registry, since Quiz is an assessment/knowledge-check pattern, not a simulation or risk-scoring feature:
- **KnowBe4** — direct, incumbent benchmark. Confidence: medium (official support-article summaries retrieved via search; direct KB article fetch was blocked, so exact UI mechanics are described from indexed excerpts, not a full walkthrough).
- **Hoxhunt** — direct, closest "adaptive" peer. Confidence: low (marketing and support pages only; no documentation on exact pass-score mechanics was found).
- **Curricula (now Huntress Managed SAT)** — direct, SMB/story-driven. Confidence: low-medium (marketing and G2 summary only).

### Workflow comparison

| Step | KnowBe4 | Hoxhunt | Curricula / Huntress |
|---|---|---|---|
| Where the assessment lives | Two distinct constructs: **Knowledge Checks** appear inline within a module to reinforce concepts with explanations; **Quizzes** appear at the end of a module to test retention. A separate **Security Awareness Proficiency Assessment (SAPA)** exists as a standalone, module-independent proficiency test. | Micro-lesson quizzes are embedded in short training moments triggered after a simulated phishing interaction, not managed as a standalone library item. | Quizzes are bundled into narrative "episodes" alongside video and phishing simulation, not exposed as an independent content type. |
| Question authoring | Managed through KnowBe4's Content Manager; passing score is configurable per content item (default reported at 80%). | Not admin-authored in the way Dune's JSON upload works; content is Hoxhunt-curated as part of the training path. | Curated by Huntress; not customer-authored. |
| Passing score model | Configurable per content item, default 80%; some Compliance Plus content has regulator-driven fixed thresholds. | Not framed as pass/fail — gamified stars/badges reward completion rather than gating on a score. | Not documented as a configurable threshold; quiz score is one of several tracked metrics (completion rate, phishing report rate, quiz score). |
| Retake behavior | Users who fail can review questions and retake; some content additionally offers a **test-out** toggle letting users attempt the quiz before starting the training, skipping the module entirely if they pass. | Framed as continuous reinforcement rather than a gated retry; no fixed attempt-limit language found. | Not documented. |
| Reporting / drill-down | KSAT Quiz Interaction Reports give admins per-question interaction data across users. | Aggregate behavior-change metrics (stars, badges, training path completion), not documented at the individual-question level. | Quiz scores tracked as one of several rollup metrics alongside completion and phishing report rates. |

### Patterns worth adopting
- **KnowBe4's Knowledge Check vs. Quiz distinction** is a useful conceptual split Dune doesn't currently make: inline reinforcement (explain the right answer immediately) vs. end-of-content gating (score against a threshold). Dune's current PRD only has the latter; explicitly deciding whether Quiz is meant to teach-while-testing or purely gate is worth resolving, since it changes whether "Correct answer: B" should be shown to the *learner* after each question (not just the admin during Review Questions).
- **KnowBe4's per-content configurable passing score, default 80%** validates Dune's existing default of 80% — this is a safe, expected default, not one requiring justification to stakeholders or customers evaluating against KnowBe4.
- **KnowBe4's test-out toggle** is a differentiation-relevant idea: letting a confident learner attempt the quiz first and skip training if they pass rewards competence instead of forcing everyone through the same content. Worth flagging as a future extension, not required for v1.
- **KnowBe4's per-question interaction reporting (KSAT)** validates Dune's existing per-user, per-question drill-down (Q1-Q5 review) as directionally correct and already ahead of Hoxhunt/Curricula on reporting granularity.

### Anti-patterns to avoid
- **Hoxhunt's lack of a hard pass/fail gate** works for their gamified, behavior-nudge positioning but would undercut Dune's compliance-oriented use case (the PRD explicitly ties Quiz completion to a passing score and retake requirement). Do not soften Quiz into a pure engagement mechanic — Dune customers evaluating against KnowBe4 for compliance-adjacent training will expect a real gate.
- **Curricula/Huntress bundling quizzes only inside narrative episodes** removes the option to assign a lightweight, standalone knowledge check independent of a full training experience. Dune's standalone Quiz tab is already a differentiator here; don't accidentally couple Quiz creation to a training module in future iterations.

### Differentiation opportunities
- **JSON-based bulk question authoring is unusual in this space.** None of the three competitors reviewed expose an admin-facing bulk upload for question authoring; KnowBe4 and Curricula quizzes are vendor-authored, and Hoxhunt's are algorithmically triggered. Dune's "Download JSON Template → fill in → upload → Review Questions" flow gives admins authoring control none of these three offer at all. This is worth stating plainly in positioning, but the flow's usability (validation, error handling on malformed JSON) has to be solid or the differentiator becomes a support burden instead of an advantage.
- **Per-user, per-question answer drill-down** (already in Dune's designs) matches KnowBe4's most advanced reporting (KSAT) and exceeds what Hoxhunt or Curricula appear to expose publicly. This is a legitimate parity-or-better claim against the incumbent, not a stretch.
- **Standalone assignability independent of any module** is stronger than Curricula's model and cleaner than Hoxhunt's embedded-in-training-path approach; lean into this in strategy framing rather than treating Quiz as a lesser version of a module assessment.

### Implications for design
- Resolve whether Quiz is teaching (show correct answer + explanation after each question, à la KnowBe4 Knowledge Checks) or purely testing (no feedback until the end, à la a formal Quiz) before design-strategist proposes the end-user question flow — this is a real fork, not a cosmetic detail.
- Keep the 80% default passing score; it's an industry-expected default that needs no special justification.
- Treat the JSON upload validation and error states (flagged in `open-questions.md`) as a first-class design surface, not an edge case — it's the feature's main differentiator and its main risk simultaneously.
- Do not gate Quiz completion softly (badges/stars only); the PRD's passing-score + retake model should stay a hard requirement, consistent with Dune's positioning against KnowBe4's compliance-adjacent audience rather than Hoxhunt's gamification audience.

### Confidence notes
- KnowBe4 findings are medium confidence: sourced from indexed support-article summaries returned by web search (ModStore/Library Guide, SAPA Overview, "Is There a Quiz at the End of Training Modules," KSAT Quiz Interactions Reports). Direct fetches of two KnowBe4 support articles returned HTTP 403 (bot-blocked), so exact screen-level UI mechanics are inferred from summary text, not a full walkthrough. Treat specific UI claims (e.g., exact Content Manager toggle labels) as approximate.
- Hoxhunt findings are low confidence: only marketing and general support pages were available; no article specifically documented pass-score or retry mechanics for their micro-lesson quizzes. The "no hard gating" characterization is an inference from the gamification framing, not a confirmed product behavior.
- Curricula/Huntress findings are low-to-medium confidence: post-acquisition rebrand to "Huntress Managed SAT" means some legacy Curricula-specific documentation may be stale; quiz mechanics are described only at a marketing level, not a UI walkthrough.
