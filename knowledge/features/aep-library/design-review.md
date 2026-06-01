# Design Review — AEP Builder: Step 1 Setup + Step 2 Test & Refine (v2C Inline AI)
Dune Security · Feature: AEP Library · Last reviewed: 2026-06-01 (v2C update — supersedes 2026-05-22 review)

---

## What changed since the last review (2026-05-22)

The design has been significantly updated. The prior review was based on an early Step 2 draft. The current Figma file contains:

- **Step 1 (AEP Setup):** Simplified to a single "General Details" section — AEP Title, Adversary Method (chip selector), Target Context (textarea), and Example Messages upload. A "View More" disclosure expands advanced fields. Template picker is integrated into the form.
- **Step 2 (Test & Refine — v2C Inline AI):** New design with a persistent left-panel AI Refine panel (Quick Actions chips + Custom Instruction + Recent Changes + Apply and Regenerate CTA). The previous tabbed and bottom-drawer variants (v2A, v2B) are superseded by v2C.
- **Five states designed:** base, chip selected, applying/loading, applied/success, error.

The previous findings DR-01 through DR-09 have been partially addressed and are re-assessed below.

---

## Review Summary (v2C)

---

## Review Summary (v2C)

- **The v2C Inline AI design is the strongest variant and the right direction.** The persistent left panel with Quick Actions chips, Custom Instruction, Recent Changes, and Apply and Regenerate addresses the core feedback loop problem cleanly.
- **The Quick Actions chips are the best addition in v2C** — they reduce the cognitive cost of starting a refinement and match the mental model of "I know what kind of change I want, I just need to select it."
- **Three issues carry over from the prior review and still need resolution before handoff:** (1) placeholder content in the left panel ("Generate Design Element", "I've created a comprehensive admin UI…") remains wrong; (2) the publish eligibility guard (disabled state at 0 sessions) is not visible in the designs; (3) the Reasoning panel content model is undefined.
- **Overall verdict: near handoff-ready.** The structure, states, and interaction model are all correct. Fix the three issues above and the design is ready.

---

## Quality Bar Assessment (v2C)

This design is **close to a Stripe-level standard of product craft** for the interaction model. The gap is now primarily in:

1. **Content accuracy** — The left panel AI response still reads "I've created a comprehensive admin UI for the Dune Security training platform" and the action card reads "Generate Design Element Version 1." This is placeholder copy from an unrelated tool. It makes the refinement flow unreadable for stakeholder review and blocks confident handoff.
2. **Publish eligibility guard** — The Publish AEP button appears active with no visible state for the 0-sessions case. The disabled state with tooltip is documented in the user flow and edge cases but is not yet in the designs.
3. **Reasoning panel content model** — The "Reasoning ›" section is collapsed by default (good) but its expanded content is undefined beyond placeholder. If this ships, the content must be behavior-specific ("I softened the opening by removing the dollar amount from the first message") not generic LLM process explanation.

---

## Findings (v2C)

---

### DR-01 · S3 · Content accuracy (OPEN — carries over from prior review)
**Location:** Left panel — AI response area ("Reasoning ›" expanded content and action card)

**Issue:** The left panel still shows placeholder copy from an unrelated tool. The "Reasoning ›" section, when expanded, reads: "I've created a comprehensive admin UI for the Dune Security training platform… a full assignment activity tracking system, left sidebar navigation, top header with global search…" The action card reads "Generate Design Element Version 1." None of this has any relationship to AEP behavior refinement.

**Why it matters:** This makes the refinement confirmation pattern completely unreadable for stakeholder review. It also reveals that the content model for "what the AI says after applying a change" has not been defined. If this ships with equally generic responses, security managers will lose trust in the refinement flow immediately.

**Recommended fix:** Replace with AEP-behavior-specific copy. After applying "Less aggressive," the AI response should confirm what changed behaviorally — e.g., "Done. I've softened the persona's pushback resistance. It will now back off faster when the employee shows hesitation, rather than escalating. Starting a new test session." The action card should read "AEP Updated" or "Changes Applied," not "Generate Design Element."

**Heuristic violated:** Match between system and the real world; Recognition rather than recall

---

### DR-02 · S2 · Error prevention (OPEN — carries over)
**Location:** Top right — "Publish AEP" button

**Issue:** "Publish AEP" is visible and appears active in the base state (v2C — frame 1) with no indication of publish eligibility. The 0-sessions disabled state with tooltip and the 1-session warning acknowledgment state are documented in the user flow and edge cases but are not yet in the Figma designs.

**Why it matters:** Published AEPs are immutable. A manager who publishes after 0 test sessions could run a live campaign against real employees with an unvalidated persona. This is the most consequential error the design needs to prevent.

**Recommended fix:** Add the disabled state (Publish AEP button greyed, tooltip: "Complete at least one test session before publishing") to the v2C base frame. Add the 1-session warning acknowledgment modal. Consider a subtle session counter in the step header ("1 session completed") so the manager always knows where they stand.

**Heuristic violated:** Error prevention; Trust and risk communication (Dune-specific)

---

### DR-03 · S2 · Hierarchy and clarity (NEW)
**Location:** Left panel — "Reasoning ›" section (collapsed)

**Issue:** The "Reasoning ›" disclosure is collapsed by default (correct) but its content model when expanded is undefined beyond the placeholder. The question of whether this section should exist at all — and what it says when it does — has not been resolved. Security managers testing an AEP care about behavioral outcomes, not AI process explanation.

**Recommended fix:** Define the content model before handoff. If retained: (a) collapsed by default; (b) plain-language, behavior-focused: "I removed the dollar amount from the opening message and added a rapport-building phrase before the ask"; (c) scoped to what changed, not how the AI works. If not retained: remove the section entirely. It adds complexity without clear decision-support value.

**Heuristic violated:** Aesthetic and minimalist design

---

### DR-04 · S1 · State completeness (NEW — Step 1)
**Location:** Step 1 setup form — "View More" disclosure

**Issue:** The Step 1 form has a "View More" disclosure control, suggesting additional fields are hidden below the visible General Details section. The content of this expanded area is not designed in the Figma frames. If these are the advanced 6-section fields (Attack Scenario, Systems at Risk, Rules & Compliance, Cultural Context, Termination Logic), the disclosure label and affordance need to be clear about what's inside and why a manager would want to open it.

**Recommended fix:** Design the expanded state for "View More." Label it clearly — e.g., "Advanced Configuration" or "More scenario details (optional)" — so the manager understands the tradeoff between a quick generate and a higher-fidelity one. Show which fields are inside so the manager can decide whether they need them.

**Heuristic violated:** Visibility of system status; User control and freedom

---

### DR-05 · S2 · Visibility of system status (PARTIALLY RESOLVED)
**Location:** Chat panel — message sender labeling

**Previous issue:** AEP messages were labeled "Attacker." This was the highest-priority finding in the prior review.

**Current state:** The v2C design labels AEP messages as "IT Support Scam AEP" — the AEP's configured name. This is correct in principle and addresses the simulation integrity issue. The employee responder is labeled "You • Employee," which is consistent and clean.

**Remaining gap:** The sender label pattern uses the AEP name (good) but also appends a channel and timestamp inline — "IT Support Scam AEP · 10:23 am." This is cleaner than the prior version but should be verified against the live production format. The test session timestamp should be the real wall-clock time of the test session, not an artificial scenario time.

**Status: resolved with minor verification needed.**

---

### DR-06 · S2 · Flexibility and efficiency of use (RESOLVED)
**Previous issue:** Archetype quick-start chips (Curious / Skeptical / Hostile / Compliant) were missing.

**Current state:** The v2C design includes "Reply as:" with four chips — Curious, Skeptical, Hostile, Compliant — above the message input. This is correctly placed and matches the design strategy. **Resolved.**

---

### DR-07 · S2 · Consistency and standards (RESOLVED)
**Previous issue:** Inconsistent sender labeling (Employee vs. John Doe).

**Current state:** v2C consistently uses "You • Employee" for all manager messages. **Resolved.**

---

### DR-08 · S1 · Visibility of system status (RESOLVED)
**Previous issue:** Step indicator active/complete states were not clearly differentiated.

**Current state:** The v2C design uses numbered circles (① ②) with the step labels. Visual differentiation between active and completed states should be verified in the live component, but the structure is correct. **Resolved pending component check.**

---

## Strengths (v2C)

- **Quick Actions chips are the right addition.** Six one-click behavior chips (More casual, Less aggressive, Add urgency, More formal, Shorter, More empathetic) eliminate the blank-page problem for refinement. Most managers know the direction of change they want; the chips capture that intent without requiring them to articulate it in prose. This is the single most impactful UX improvement from the prior design.
- **Inline 👍/👎 controls directly below each AEP message** — correctly placed at the moment of reaction. Matches Gemini, ChatGPT, and Claude's output rating patterns. Feedback is contextual, not collected in a separate form.
- **Recent Changes list** — the chronological history of applied instructions in the left panel gives the manager a record of what has been tried and closes the "did my change actually apply?" loop. Showing timestamps ("2 min ago", "just now") makes the session feel active and responsive.
- **Applied/Success state (v2C-4)** — the "✦ Regenerated" label on the first message of the new session, the "Changes Applied" chip state, and the toast "Changes applied — new session started" together form a complete feedback loop. The manager knows the change was applied, knows a new session has started, and can see it in the conversation immediately.
- **Error state (v2C-5)** — "Generation failed" in the Recent Changes area with "Something went wrong. Your changes weren't saved." and "Try again →" is the right error pattern. The instruction text is not lost; the manager can retry without re-typing.
- **Draft badge in the header** — surfacing AEP status in the test context is a good grounding signal. The manager always knows this is an unpublished draft.
- **Simplified Step 1 form** — reducing the setup form to four required fields (AEP Title, Adversary Method, Target Context, Example Messages) with advanced options under "View More" dramatically lowers the barrier to first generation. This is the right tradeoff for the primary use case.

---

## Open Questions (v2C)

- **[Eng]** What does the AI confirm changed after a behavior instruction is applied? The confirmation copy in the left panel needs to be behavior-specific per the PRD. How does the system represent this — as a natural-language summary, a field diff, or a re-statement of updated behavior? This shapes the Reasoning section content model.
- **[Both]** Is "Reasoning ›" a permanent feature or a debug/transparency aid? If permanent, define the content model before handoff. If a debug aid, move it to the Operator overlay only.
- **[PM]** Does "View More" in Step 1 expose the full six-section advanced form, or a subset? Which fields are mandatory vs. optional in the expanded view?
- **[PM]** Is there a session counter visible anywhere in Step 2 so the manager knows how many sessions they have completed before the Publish guard activates?

---

## Revision Priorities (v2C)

1. **Replace left panel placeholder copy** — the "Generate Design Element Version 1" card and "I've created a comprehensive admin UI…" paragraph must be replaced with AEP-behavior-specific confirmation copy before this design can be reviewed for handoff readiness. This is the single blocking issue.
2. **Add publish eligibility guard** — design the 0-sessions disabled state (Publish AEP greyed + tooltip) and add it to the base v2C frame. The 1-session warning acknowledgment modal should also be designed.
3. **Define and design the "View More" expanded state in Step 1** — what fields are inside, how they are labeled, and when a manager would use them.
4. **Specify Reasoning section content model** — either define it (behavior-specific, collapsed by default) or remove it. Ship one or the other, not a placeholder.

---

## Verdict (v2C)

**Near handoff-ready.**

The v2C (Inline AI) design is the right direction. The Quick Actions chips, persistent refine panel, Recent Changes list, and full state coverage (chip selected, applying, applied, error) represent a meaningfully better design than the prior version. The three remaining blockers are content and state design gaps — they do not require structural rethinking. Address the placeholder copy, publish guard, and View More expanded state, then this is ready for dev handoff.

---

*Files updated: `design-review.md`, `design-review.json` — 2026-06-01*
