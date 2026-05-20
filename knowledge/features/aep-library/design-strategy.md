# Design Strategy — AEP Library (Custom AEP Builder)
Dune Security · Design Strategy · Last updated: 2026-05-20

---

## Feature context

**Goal:** Let org admins create, configure, and test custom Adversary Emulation Pathways within the Red Teaming workspace, so security teams can run social engineering simulations with scenarios tailored to their organization.

**Primary user:** Org admin (security team lead or red team operator). Secondary: Campaign manager (selects AEPs; no edit access).

**Trigger:** Admin needs a social engineering scenario not covered by Dune's seeded library — an industry-specific persona, a company-branded impersonation, or a scenario targeting a known internal attack vector.

**Success:** Admin creates a custom AEP, validates its behavior in a live simulator, and the AEP is available for selection in the campaign builder — without engineering support.

**What's confirmed:**
- 3–4 Dune-seeded AEPs (read-only, ships at launch)
- 4–5 custom AEP limit per tenant (exact number TBD)
- RBAC: org admins create/edit; campaign managers use but don't edit
- Live chat simulator is part of the creation flow
- Adversary Method should be a controlled taxonomy

**What's not yet confirmed:** Whether Workflow Steps and Branching Logic are generated or manually authored; outcome criteria authoring model; versioning policy for AEPs in active campaigns. Strategy assumes AI-generated content that admin owns and can edit — this assumption should be validated before Figma work begins.

---

## Design goal

Give org admins a guided AEP builder that generates a well-structured adversary persona from a plain-language scenario description, lets them refine it in structured fields, and requires them to test it in a live simulator before publishing — making the quality bar clear without requiring prompt engineering expertise.

---

## Key constraints

- **No flowchart or node editor metaphors.** AEP branching is emergent LLM behavior, not wired logic. The UI must not imply that admins are programming a decision tree.
- **Structured output sections must be authoritative.** Workflow Steps, Branching Logic, and Outcome Criteria shown in the library detail view are the source of truth for how the AEP behaves. They should be accurate, not cosmetic summaries.
- **Outcome Criteria are data inputs, not labels.** Complicit / Non Complicit / Undetermined / No Response criteria feed employee risk score calculations. Their fields are consequential; the UI must treat them as such.
- **Simulator must be required, not optional.** It is the only quality gate. AEP should not be publishable without at least one simulator exchange.
- **Draft-vs-published distinction is needed.** The custom limit (4–5) applies to published AEPs. Drafts should not count against the limit, or admins will be reluctant to experiment.
- **Version-lock at campaign creation.** If an AEP is edited after being referenced in an active campaign, the campaign must use the version locked at creation. Design for this even if Eng hasn't confirmed the architecture — surface the constraint to Eng before handoff.

---

## Strategy options

### Option A: Pure free-text prompt editor
Admin writes a system prompt directly in a large text area. Structured sections (Workflow Steps, Branching Logic, Outcomes) are either auto-parsed from the prompt or manually typed in separate fields.

**Rejected because:** Most security admins are not prompt engineers. A blank prompt box produces wildly inconsistent AEP quality — ineffective personas, escaped tone, and outcome criteria that don't map to the platform's classification model. No competitor uses raw prompt as the default interface for good reason. The risk of unsafe or nonsensical AEPs entering the library is too high.

---

### Option B: Fully structured form, no prompt visible
Admin fills named fields: Persona Name, Role, Attack Goal, Workflow Steps (bullet list editor), Branching Logic description, Outcome Criteria per tab. System assembles an internal prompt the admin never sees.

**Rejected because:** Overly rigid. Advanced security teams will want raw prompt access for novel scenarios that don't fit the field structure. Also contradicts the "prompt editor" language in the prior strategy doc and loses the flexibility that makes AEPs powerful.

---

### Option C (Recommended): Guided AI-Assist with progressive disclosure

Three-step wizard: **Define → Configure → Test**

1. **Define (Step 1):** Admin writes a plain-language scenario description, selects Adversary Method from a taxonomy, and optionally adjusts behavior parameters (escalation tendency, formality). Clicks "Generate" → system produces a structured AEP draft: Workflow Steps, Branching Logic, and Outcome Criteria stubs.

2. **Configure (Step 2):** Admin reviews and edits all generated content in structured fields. Every section is editable. An "Advanced" toggle reveals the underlying system prompt for technical admins who want direct control. Outcome Criteria are authored per tab (Complicit / Non Complicit / Undetermined / No Response) with bullet list input.

3. **Test (Step 3):** Live simulator. Admin plays the target role — types responses, sees the AEP adapt in real time. Publish button activates only after at least one simulator exchange. Admin can loop back to Configure from the simulator.

**Why this wins:**
- Meets admins at their level (scenario description, not system prompt)
- Teaches AEP structure via AI-generated examples — good generated content shows what good looks like
- Gives advanced users raw prompt access without making it the default
- AI-generation model is validated by KnowBe4 AIDA and is the direction of the market
- Structured form output keeps Outcome Criteria auditable for risk scoring
- Simulator as a required step enforces a quality gate that no competitor has

---

## Recommended strategy

**Option C — Guided AI-Assist with progressive disclosure**

### Library view structure

Two distinct sections on the AEP Library page:

**Dune Library** (top section)
- 3–4 seeded AEP cards in a grid
- Read-only treatment: no edit affordance on cards
- Each card: AEP ID, Name, Adversary Method badge, a one-line description
- Card actions: "View details" (opens detail drawer) and "Duplicate" (opens builder pre-filled)
- Section label: "Dune Library — managed by Dune Security"

**Your AEPs** (bottom section)
- Section header includes usage counter: "3 of 5 custom AEPs"
- "New AEP" button at section header level (disabled if limit reached, with tooltip)
- Custom AEP cards: AEP ID, Name, Adversary Method badge, Status badge (Draft / Published), Simulator status chip ("Tested" / "Not tested"), Created date, Last used in campaign (if applicable)
- Card actions: Edit, Duplicate, Delete
- Empty state: "No custom AEPs yet. Duplicate a Dune AEP to start from a proven template, or create one from scratch."

### Builder flow — three-step wizard (full-page)

**Step 1: Define**
- AEP Name (text input — unique validation)
- Adversary Method (select — controlled vocabulary: Authority, Urgency, Reciprocity, Curiosity, Scarcity, Familiarity)
- Scenario description (textarea) — placeholder: "Describe the attacker's goal, the persona they're playing, and how they should behave. For example: 'A vendor following up urgently on an overdue invoice, escalating if ignored.'"
- Behavior parameters (optional expander): Escalation tendency (Low / Medium / High), Tone (Formal / Casual / Technical)
- CTA: "Generate AEP" — loading state while system generates content
- Alternative path: "Skip generation — fill manually" → advances to Step 2 with empty structured fields

**Step 2: Configure**
- AI-generated content pre-fills all fields; each is editable
- Workflow Steps: editable bullet list (add / reorder / remove steps)
- Branching Logic: editable textarea with structured helper text ("Describe how the AEP should respond to different employee reactions")
- Outcome Criteria: four tabs — Complicit / Non Complicit / Undetermined / No Response. Each tab has an editable bullet list for criteria.
- Contextual note on Outcome Criteria: "These criteria affect how employee responses are classified and scored. Define them specifically."
- Advanced toggle (visible but secondary): "Edit system prompt directly" — opens underlying prompt in a CodeEditor / large textarea. Changes here update the displayed structured fields on toggle-off. Warning: "Editing the system prompt directly overrides the structured configuration above."
- CTA: "Continue to Test"

**Step 3: Test**
- Split layout: left panel (AEP summary — name, method, key workflow steps, non-editable), right panel (simulator chat)
- Simulator chat: chronological message thread, admin types at bottom, AEP responds with typing indicator
- Session controls: "Reset conversation" button, "Change persona" note linking back to Step 2
- Outcome preview strip: "Based on this conversation, outcome would be: [Undetermined]" — updates as conversation progresses
- Simulator status indicator: "Not yet tested" → "Test in progress" → "Tested"
- CTA: "Publish AEP" (activates after first AEP response is received in simulator)
- Secondary: "Back to Configure" (simulator state is preserved when returning)
- Simulator error state: "Simulator unavailable — try again in a moment" with retry action

**Publish confirmation modal:**
- Title: "Publish [AEP Name]?"
- Body: "This AEP will be available in the campaign builder immediately. Once referenced in an active campaign, it cannot be edited until the campaign concludes."
- Actions: Cancel (left), Publish AEP (right — primary, green)

### Entry points into the builder

1. "New AEP" button (Your AEPs section) → blank Step 1
2. "Duplicate" on a Dune-seeded card → Step 1 pre-filled with seeded AEP values, Name field cleared and focused (signal: "give this a new name")
3. "Duplicate" on a custom AEP → same as above, from custom source
4. "Edit" on a custom AEP in Draft status → returns to whichever step was last active
5. "Edit" on a Published custom AEP not in active campaign → opens with warning: "This AEP will return to Draft status while you edit it. Re-publish to make it available again."
6. "Edit" on a Published custom AEP in active campaign → edit is blocked; banner: "This AEP is in use by an active campaign. Editing is locked until the campaign concludes."

---

## Risks and tradeoffs

**What this strategy gives up:**
- Speed. The three-step wizard is slower than a single-page form. Admins creating their second or third AEP may find the step structure overhead. Mitigation: the "Duplicate" path skips Step 1 effectively and pre-fills everything.
- Transparency. The AI-generated content may not accurately reflect what the underlying system prompt does. If Workflow Steps and Branching Logic are cosmetic summaries (not literal LLM instructions), admins may be misled about what the AEP will actually do. Mitigation: this must be resolved with Eng before Figma work — the structured fields need to be authoritative, not decorative.

**Risks that persist:**
- Simulator as a checkbox, not a real test. Admins may do one quick simulator exchange to unlock Publish, not genuinely validate behavior. This is a behavior design problem, not a UI problem — but consider adding a minimum exchange count (e.g., 3 turns) before Publish activates.
- Open questions on outcome criteria authoring could change Step 2 significantly. If Dune defines outcome criteria globally (not per AEP), the Outcome Criteria tabs in Configure become display-only, and Step 2 collapses significantly.

---

## Open issues

These unresolved questions would materially change the strategy if answered differently. Do not advance to Figma without resolving at least #1 and #3.

1. **[Critical — Both]** Are Workflow Steps and Branching Logic AI-generated from the scenario description, or manually authored by the admin? This determines whether Step 2 starts pre-filled or empty.
2. **[Critical — PM]** Are Outcome Criteria (Complicit / Non Complicit / Undetermined / No Response) defined globally by Dune, or authored per AEP? If global, Step 2 collapses; Outcome tabs become display-only.
3. **[Critical — Eng]** In the simulator, does the admin play the target manually, or is it AI-vs-AI? If AI-vs-AI, the simulator UI is an observation interface, not a chat interface — a fundamentally different screen.
4. **[Medium — Both]** Version-locking policy. Strategy assumes campaign creation locks the AEP version. If Eng cannot implement this, "Edit" on published AEPs must be more restrictively gated.
5. **[Medium — PM]** Exact custom AEP limit (4 or 5). Affects the counter display in the library header.
6. **[Medium — PM]** Is duplication from Dune-seeded AEPs confirmed as an intended path? Strategy depends on it as the primary onboarding path for new admins.

---

## Next design actions

1. **Resolve open issues #1, #2, and #3 with PM and Eng** — these three answers determine the shape of the Configure step and the Simulator screen. Don't open Figma until they're answered.
2. **Confirm the Adversary Method taxonomy list** — get the full controlled vocabulary from PM (expected: Authority, Urgency, Reciprocity, Curiosity, Scarcity, Familiarity — confirm and finalize).
3. **Audit Stillsuit DS v2 for:** wizard step bar, textarea / CodeEditor, split pane layout, card grid, badge variants, drawer (for AEP detail view). Flag any gaps for DS review.
4. **Design the library grid first** — it's the entry and return point for all flows. Dune Library section + Your AEPs section + card states is a self-contained deliverable that can be validated independently.
5. **Design the AEP detail drawer second** — this is how both admins and campaign managers read an AEP. It's also how the existing AEPs in the seeded library communicate quality and structure to new admins.
6. **Design the wizard third** — Step 1 → 2 → 3, starting with the happy path. Use the detail drawer visual language for the AEP summary panel in the simulator.
