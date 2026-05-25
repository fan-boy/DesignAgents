# Design Review — AEP Builder: Step 2 Chat Test
Dune Security · Feature: AEP Library · Last reviewed: 2026-05-22

---

## Review Summary

- **The two-panel split (refine left, chat right) is the right structural call** — it keeps the test conversation in focus while making behavior refinement always accessible.
- **The inline 👍/👎 per-message feedback is correctly placed** — this matches industry-standard AI output rating patterns (Gemini, ChatGPT) and is the strongest UX decision in the screen.
- **Three issues need to be resolved before this is handoff-ready:** (1) the AEP sender is labeled "Attacker" which breaks simulation realism; (2) the left panel mock content is a placeholder for a different product entirely; (3) key workflow elements from the design strategy — session history, archetype chips, New Chat — are absent from this design.
- **Overall verdict: needs revision.** The structural concept is sound, but the detail layer has gaps that would undermine usability and the core value proposition of a realistic simulation.

---

## Quality Bar Assessment

This design is **not yet at a Stripe-level standard of product craft**. The gap is primarily in:

1. **Content accuracy** — The left panel's AI response reads like it was generated for a different tool entirely ("Generate Design Element", "comprehensive admin UI"). This is clearly a placeholder, but even as a placeholder it creates confusion about what this feature does and makes design review harder.
2. **Simulation immersion** — Labeling the AEP persona "Attacker" in the chat is the equivalent of a stage play with a character named "Bad Guy." The whole premise of the feature is that the AEP is a realistic persona the security manager experiences as if they were the employee. "Attacker" destroys that.
3. **State coverage gaps** — No session history, no completion signal, no publish eligibility guard, no New Chat. These are not polish issues — they are core workflow elements documented in the design strategy.
4. **Interaction consistency** — The dual timestamp ("3:23 pm · 10:23 am") in the last attacker message is a visible data rendering bug. Small, but tells a story about how carefully the detail layer has been reviewed.

---

## Findings

---

### DR-01 · S3 · Simulation integrity
**Location:** Chat panel — message sender labels

**Issue:** AEP messages are labeled "Attacker" throughout the conversation (e.g., "Attacker · IT Support Scam AEP", "Attacker · Whatsapp · 10:23 am"). The employee receiving these messages in a live campaign would not see "Attacker" — they would see a realistic persona name. The security manager testing this AEP should be experiencing it as the employee would: from the persona's identity, not a system-level role label.

**Why it matters:** The entire value of Step 2 is that the security manager validates whether this AEP would be believable to a real employee. "Attacker" as a sender label tells the manager nothing about whether the AEP's persona is convincing. It also breaks the discipline of reviewing the conversation from the employee's perspective, which is the correct mental model for this test. A manager who reviews a realistic-feeling conversation is far more likely to catch authenticity issues than one reviewing a transcript labeled "Attacker."

**Recommended fix:** Use the AEP's persona name as the sender — the same name the employee would see in a live campaign (e.g., "Jake (IT Support)" or whatever name the AEP has been configured with). The AEP name/type can be shown in the chat header as context without repeating it on every message. The employee responder should show the manager's name or a consistent target persona label, not the generic "Employee."

**Heuristic violated:** Match between system and the real world; Visibility of system status (the status being shown — "you're testing from the employee's POV" — is obscured)

**Teaching note:** Simulation tools need to make the test feel like the thing being simulated, not like a log viewer. The label on the sender is the first thing that signals whether this is a real conversation or a database output. Getting this right is the difference between a manager who trusts the AEP's realism and one who dismisses it as "just a bot."

---

### DR-02 · S3 · Content accuracy / Recognition rather than recall
**Location:** Left panel — AI refinement response ("Generate Design Element Version 1")

**Issue:** After the manager submits a refinement ("This is too direct. Change it make it informal!"), the AI responds with reasoning text that describes building "a comprehensive admin UI for the Dune Security training platform" with "a full assignment activity tracking system, a left sidebar navigation, top header with global search, and a detailed table view." The action card reads "Generate Design Element Version 1." None of this has anything to do with AEP behavior refinement. This is clearly placeholder content from a different product or workflow.

**Why it matters:** Even in a design prototype or review artifact, wrong placeholder content is actively misleading. It obscures what the AI response pattern is supposed to communicate, makes it impossible to evaluate whether the refinement flow is well-designed, and sets incorrect expectations for PM and engineering reviewers. If this pattern ships with similarly generic LLM responses that don't confirm what behavioral change was actually applied, security managers will lose trust in the refinement flow quickly.

**Recommended fix:**
1. Replace with AEP-appropriate content immediately. The AI response should confirm what changed in the AEP's behavior. Example: "Done. I've softened the opening approach — the AEP will now use more casual phrasing and build rapport before making asks. Starting a new test session."
2. The action card should read something like "AEP Updated — v2" not "Generate Design Element."
3. "Additional feedback" is vague. If this is a follow-up prompt option, label it "Refine further" or "Add another instruction."

**Heuristic violated:** Match between system and the real world; Help users recognize, diagnose, and recover from errors

**Teaching note:** Placeholder copy in design reviews reveals design assumptions. The "Generate Design Element" card shows that this pattern was likely borrowed from an AI design-generation tool (like a Figma plugin or similar). The AEP refinement flow needs its own vocabulary: behavioral change confirmation, session restart signal, and a clear "what changed" summary — not design artifact generation language.

---

### DR-03 · S3 · State completeness
**Location:** Left panel — missing session history section

**Issue:** The design strategy and user flow both document that the left sidebar must contain a session history list (past sessions with timestamp + archetype + outcome). This view shows no session history at all — only the refinement input/chat. There is also no "New Chat" button visible anywhere.

**Why it matters:** Without session history, the manager has no way to: (a) understand how many sessions they have run, (b) compare behavior across sessions, (c) navigate back to review an earlier conversation, or (d) know whether they have tested enough to publish confidently. The session list is also the primary signal that informs publish eligibility — "you've done 2 sessions with different archetypes" is the quality bar the manager needs to see before pressing Publish.

**Recommended fix:** Restore the session history section below the refinement panel in the left sidebar. Each session entry should show: session number, archetype used, number of turns, outcome (complete / abandoned). The active session should be highlighted. "New Chat" should appear here or in the chat header — either location is fine as long as it is always visible and clearly labeled.

**Heuristic violated:** Visibility of system status; State completeness (Dune-specific); User control and freedom

**Teaching note:** In a multi-session workflow, the session list is not just navigation — it is progress evidence. It tells the manager where they are in the validation process and builds confidence that they are testing thoroughly enough. Removing it removes the "you've done the work" signal that makes the Publish action feel earned rather than premature.

---

### DR-04 · S3 · Error prevention
**Location:** Top right — "Publish AEP" button

**Issue:** "Publish AEP" is visible and appears enabled with no signal of whether the manager has done enough testing to publish. The design strategy is explicit: the button must be disabled with a tooltip ("Complete at least one test session before publishing") when 0 sessions have been completed, and must show a warning acknowledgment when exactly 1 session has been completed. This guard is absent from the current design.

**Why it matters:** Publishing an AEP is irreversible — the strategy states "Published AEPs are immutable; editing requires cloning to new version." Allowing a manager to publish after zero or one session of testing means they could run a live campaign with an unvalidated persona. Given that real employees receive these messages, premature publishing is a meaningful risk — both to the employee experience and to the organization's trust in the platform.

**Recommended fix:**
- 0 sessions: Disable the button, tooltip on hover: "Complete at least one test session to publish."
- 1 session: Enable the button but show a warning modal with an acknowledgment checkbox before proceeding.
- 2+ sessions: Standard publish confirmation modal.
- Consider adding a lightweight "readiness indicator" in the step header — e.g., "2 sessions completed" — so the manager can see their testing progress without hunting for it.

**Heuristic violated:** Error prevention; Trust and risk communication (Dune-specific)

**Teaching note:** Consequential actions that are irreversible need both a structural guard (the disabled state or warning gate) and a contextual signal (how close am I to the threshold). The guard prevents the mistake; the signal prevents the user from being surprised by the guard. Both are required.

---

### DR-05 · S2 · Visibility of system status
**Location:** Chat panel — message timestamps

**Issue:** The last attacker message shows two timestamps: "3:23 pm · 10:23 am." One is presumably the real time and one is a mock time in the conversation; the combination is rendered as if they are both valid and both relevant.

**Why it matters:** Timestamp inconsistency signals either a data rendering bug or an unclear information architecture decision. In a security product where audit trails matter, ambiguous timestamps erode trust in the system's precision. Even in a prototype, it signals that the data model for "when did this message happen" has not been fully resolved.

**Recommended fix:** Decide on one timestamp format for the chat. Options: (a) relative time since session start ("+2 min"), (b) absolute time of the simulated conversation (removed for simulations — timestamps are artificial anyway), or (c) real wall-clock time of the test session. Whichever you choose, apply it consistently across all messages. Do not surface two timestamps for the same message.

**Heuristic violated:** Consistency and standards; Aesthetic and minimalist design

**Teaching note:** Timestamp format is a system design decision, not just a UI decision. For a simulated conversation, "time within the scenario" and "real session time" are two different concepts. Decide which one is meaningful to the security manager (likely real session time) and surface only that.

---

### DR-06 · S2 · Recognition rather than recall
**Location:** Chat panel — missing archetype quick-start chips

**Issue:** The design strategy documents archetype quick-start chips above the message input (Curious / Skeptical / Hostile / Compliant) that inject a preset first reply to speed up testing. These are absent from this design.

**Why it matters:** The archetype chips reduce the cognitive load of starting a test — the manager does not need to invent a realistic employee reply from scratch. They also make it easier to test the AEP consistently across sessions ("I tested this with a Skeptical reply in session 1 and a Curious reply in session 2"). Without them, the manager defaults to improvising, which produces inconsistent test inputs.

**Recommended fix:** Add archetype chips above the "Reply as Employee" input bar. They should be clearly labeled and disappear or become inactive after the first message is sent (since they are starter aids, not ongoing controls).

**Heuristic violated:** Flexibility and efficiency of use; Recognition rather than recall

**Teaching note:** Archetype chips are a scaffolding pattern — they help first-time users get started without knowing what a "good" test input looks like. They are especially valuable for non-technical security managers who may not have practiced social engineering simulation before. Remove the cognitive cost of "what should I type" entirely.

---

### DR-07 · S2 · Consistency and standards
**Location:** Chat panel — inconsistent sender labeling

**Issue:** The employee responder is labeled "Employee" in one message and "John Doe" in another. This inconsistency suggests an unresolved design decision about how to identify the target persona in the test conversation.

**Why it matters:** The manager playing the employee needs a consistent identity to maintain the mental model that they are simulating a specific person's behavior. Switching between a generic role label ("Employee") and a personal name ("John Doe") mid-conversation creates confusion: "Am I supposed to be Employee or am I John Doe?"

**Recommended fix:** Choose one approach and use it consistently. Options: (a) always use the manager's own name (pulled from their account profile — reinforces that they are playing themselves), (b) always use a fixed target persona name defined in the AEP setup, or (c) use a generic "You" label (clear and unambiguous). The "You" label is the cleanest — it matches how iMessage, WhatsApp, and most chat UIs label the local participant.

**Heuristic violated:** Consistency and standards; Match between system and the real world

---

### DR-08 · S2 · Hierarchy and clarity
**Location:** Left panel — "Reasoning ›" section

**Issue:** The collapsed "Reasoning ›" section, when expanded, shows a lengthy AI explanation of what it created. The current mock content is about building a UI (wrong), but even if correctly populated with AEP behavior reasoning, it is unclear whether security managers need to see the AI's internal reasoning to validate a behavior change.

**Why it matters:** If the Reasoning section shows AI chain-of-thought about why a behavior was changed, it adds cognitive load without clear decision-support value. A security manager testing an AEP cares about whether the behavior is now correct — not how the AI reasoned about it. Showing reasoning may create false confidence ("the AI thought about it carefully") or unnecessary anxiety ("the AI is doing complex things I don't understand").

**Recommended fix:** If Reasoning is retained, make it: (a) optional/collapsed by default (it is already collapsed, which is good), (b) plain-language and behavior-focused: "I made the opening more casual by removing formal greetings and reducing the urgency of the initial ask," not a general explanation of the AI process, and (c) scoped to what changed, not what the AEP does overall.

**Heuristic violated:** Aesthetic and minimalist design; Help and guidance (risk of over-explaining)

---

### DR-09 · S1 · Visibility of system status
**Location:** Step indicator — top header

**Issue:** The step indicator shows "① AEP Setup" and "② Test & Refine" but the visual differentiation between the active step (2) and completed step (1) is not obviously legible from the screenshot — the active state appears to be a slightly darker circle. Step indicators should make the current position immediately obvious without requiring close reading.

**Why it matters:** Low-severity here because the manager has already navigated to Step 2 and is actively testing, so the step indicator is informational, not navigational. But clearer active/complete states (e.g., checkmark on completed step, bold label on active step) would reinforce that Step 1 is done and Step 2 is in progress.

**Recommended fix:** Use a checkmark inside the Step 1 circle to signal completion. Make the Step 2 label bold and the circle clearly filled. This is the standard wizard step indicator pattern.

**Heuristic violated:** Visibility of system status

---

## Strengths

- **Inline 👍/👎 controls directly below each AEP message** — the correct placement. Positioned right at the moment of reaction, not collected separately. Matches the pattern from Gemini and ChatGPT and will feel familiar to users who have rated AI output before.
- **Refinement as a sent message (green bubble)** — showing the refinement instruction as a sent chat message in the left panel is a smart interaction pattern. It makes the admin's intent visible, creates a record of what was asked for, and gives the AI response something to respond to structurally. This is borrowed from RelevanceAI's refinement flow and works well here.
- **Two-panel split is the right structural decision** — keeping the live conversation in the main pane and the behavior refinement in a persistent sidebar lets the manager test and iterate without context loss. The AEP conversation is always visible.
- **Draft badge in chat header** — surfacing the AEP's current status in the chat context (not just in the library) is a good grounding signal. The manager always knows this is an unpublished draft being tested.
- **Channel context in messages** ("Attacker · Whatsapp") — surfacing the channel per message is a useful detail. In a multi-channel AEP, the manager needs to know which channel they are testing, since tone and format should vary by channel.

---

## Open Questions

- **[PM]** What does the employee sender label represent? Is it always the logged-in manager's own identity, a fixed "target employee" persona defined in setup, or a generic label? This affects both Step 1 (whether a target persona name is collected) and Step 2 (how the chat history reads back).
- **[Eng]** When the manager submits a refinement instruction, what specifically does the AI confirm changed? The confirmation copy needs to be behavior-specific, not generic. How does the system represent this — as a diff, as a summary, or as a re-statement of the updated behavior?
- **[Both]** The "Reasoning ›" section — is this intended to be a permanent feature or a debug/transparency aid? If permanent, it needs a well-defined content model. If a debug aid, it may belong in an "Advanced" or Operator view only.
- **[PM]** Is "Additional feedback" a way to chain multiple refinement instructions into a single generation pass? Or is it a way to rate the AI's response to a refinement? The interaction model needs to be specified before the UI can be finalized.

---

## Revision Priorities

1. **Fix the "Attacker" sender label** — replace with the AEP's configured persona name. This is the highest-impact change because it directly affects simulation immersion, which is the feature's core value.
2. **Replace all placeholder content in the left panel** — the "Generate Design Element" card, the Reasoning paragraph, and the "Additional feedback" link all need AEP-appropriate content and interaction models before this design can be reviewed meaningfully.
3. **Restore session history + New Chat** — the left sidebar is incomplete without the session list. Add session history below the refinement thread and ensure "New Chat" is always reachable.
4. **Add publish eligibility guard** — disable "Publish AEP" with tooltip at 0 sessions; add warning acknowledgment at 1 session.
5. **Add archetype quick-start chips** above the employee input — reduces cognitive load for first-time testers and improves test consistency.

---

## Verdict

**Needs revision.**

The structural concept is correct and the core interaction pattern (inline feedback + refinement sidebar) is well-chosen. But three things block handoff readiness: the Attacker label breaks simulation integrity; the left panel placeholder content makes the refinement flow unreadable; and key workflow elements (session history, publish guard, archetype chips) documented in the design strategy are missing. Address the revision priorities above before moving to dev handoff.

---

*Files saved: `design-review.md`, `design-review.json`*
