# Design Strategy — AEP Builder + AEP Library
Dune Security · Design Strategy · Last updated: 2026-06-01 (v3 update — v2C Inline AI confirmed)

---

## Feature context

**Goal:** Eliminate the manual Dune-operator-as-middleman AEP creation process. Give enterprise security managers a self-serve three-stage builder — guided form + example upload, live chat test, natural-language refinement — so they can create, validate, and publish custom Adversary Emulation Pathways in under 2 hours without Dune involvement.

**Primary user:** Security Manager (CISO, security manager, or Red Teaming owner). Secondary: Reviewer (optional sign-off), Dune Operator (internal support), Dune Admin (platform-level).

**Trigger:** Admin needs to create a social engineering simulation persona tailored to their organization's specific environment, employees, compliance constraints, and cultural context.

**Success:** Security Manager creates an AEP, tests it against multiple employee archetypes, refines its behavior via natural-language prompts, and publishes it — available for campaign selection, meeting the organization's compliance and cultural requirements, with a structural validation pass rate above 95%.

**What's confirmed (PRD v0.2):**
- Three-stage non-linear flow: Stage 1 (Form + Examples) → Stage 2 (Live Chat Test) → Stage 3 (Prompt Refinement) → Publish
- Stage 1 has 6 structured sections: Account Context, Attack Scenario, Systems at Risk, Rules & Compliance, Cultural Context, Termination Logic
- Example upload: 1–5 files (.txt, .docx, .png/.jpg with OCR) — optional but strongly recommended
- Channel multi-select: WhatsApp, Telegram, Viber, Facebook Messenger, SMS, Instagram, Microsoft Teams, Signal
- Generation time: P95 45s without examples, 90s with OCR; labeled progress stages required
- Stage 2 uses the full production persona runtime with state label visible to customer only
- 4 archetype starter responses (Curious, Skeptical, Hostile, Compliant) as one-click injections
- Stage 3: targeted field-level edits only, diff view with per-field accept/reject; cannot remove global guardrails
- Published AEPs are immutable; changes require cloning
- AEP Library: table view, search < 500ms, filter by status/channel/compliance/date/campaign, version history, clone, archive
- Template system: 6 Dune-curated templates at launch
- Dune Operator view: special permission overlay with raw JSON, validation override, Operator Assist
- Phase 1 target: Q3 2026

**What's not yet confirmed:**
- Whether a Reviewer is ever mandatory (blocking gate) or always optional
- Multi-channel simultaneous deployment vs. one channel per campaign
- AEP library scope: per-org vs. per-account/program
- Instigation threshold enum granularity
- Auto-save behavior for Stage 1 form

---

## Design goal

Build a three-stage AEP creation flow that abstracts a highly complex AI persona data model into a guided form + test + refine loop — so a non-technical security manager can produce a structurally complete, behaviorally validated, compliance-enforced persona in under 2 hours, without seeing JSON.

---

## Key constraints

- **No raw JSON visible to customers.** The AEP data model (system prompt, classifier prompt, 6-state machine, detection arrays, scripts, nuance packages) is only visible to Dune Operators in a dedicated technical panel. Customers interact exclusively via form fields and natural-language prompts.
- **Stage 2 must use the full production runtime.** Not a preview or simplified simulation — "what the customer sees is exactly what game changers will see." This is the product's key differentiator.
- **Generation must be non-blocking but informative.** At P95 45–90 seconds, a static spinner will destroy trust. Labeled progress stages must visibly advance.
- **Stage 3 diff view is consequential, not cosmetic.** Customers accept/reject individual field changes. If the diff is opaque, they will bypass the review. This screen needs the same design attention as a payment confirmation.
- **Published AEPs are immutable.** Cloning is the edit mechanism. This must be clearly communicated at publish time to prevent customer confusion.
- **Validation is a hard gate, not a suggestion.** Blocking errors prevent publish; warnings require explicit acknowledgment per item.
- **Compliance fields are consequential.** The instigation threshold, compliance frameworks, and termination triggers feed AEP behavior and risk scoring. They must be treated with appropriate weight and help text, not as optional form noise.
- **Templates are starting points, not finished AEPs.** Must be clearly framed as requiring customization before generation.

---

## Strategy options considered

### Option A: Pure plain-language brief → AI generates (original recommendation)
Admin writes a scenario description in free text. AI generates the full AEP from the brief. Rejected by the PRD — the AT&T, Concentrix, and Qantas accounts demonstrated that the structural complexity of AEP requirements (crown jewels, compliance frameworks, cultural nuances, termination triggers) requires structured capture. A plain-language brief produces incomplete personas and requires multiple expensive correction loops.

### Option B: Fully structured form, no AI
Admin fills every field manually — no AI generation. Rejected: the AEP JSON schema has 20+ field groups including a full state machine with 6 states, detection arrays, and cultural nuance packages. Manual authoring is what the current paper process does and takes ~1 day per AEP. This eliminates the entire product value proposition.

### Option C (Recommended and confirmed by PRD): Structured 6-section form + example upload → AI generation + natural-language refinement

Stage 1: Structured form with 6 sections captures all the context the LLM needs. Optional example upload grounds tone, vocabulary, and cultural register. Generation produces a complete AEP JSON automatically.

Stage 2: Customer plays the employee role in a live chat test using the full production persona runtime. No limit on test sessions. Archetype starters (Curious, Skeptical, Hostile, Compliant) guide systematic testing.

Stage 3: Customer describes issues in plain English. LLM makes targeted field-level edits. Diff view shows old vs. new per field. Customer accepts/rejects per field. Cycle repeats as needed.

**Why this is right:**
- Structured form capture ensures nothing is missed (required field validation enforces completeness)
- AI generation from form inputs eliminates the manual JSON authoring step
- Example upload is the highest-quality signal for realistic persona behavior
- Live test with production runtime is a genuine market differentiator — no competitor offers this
- Natural-language refinement is accessible to non-technical security managers
- Per-field diff preserves customer agency without requiring JSON knowledge
- Publish gate with validation enforces structural completeness before deployment

---

## Confirmed strategy (updated 2026-06-01)

**2-Step Builder: Simplified Setup Form + Chat Test with Inline AI Refinement Panel (v2C)**

Figma v2C (Inline AI) is the confirmed design direction. This supersedes the previous 3-stage wizard and the intermediate v2A (tabbed) and v2B (bottom drawer) variants.

The key insight from Mobbin research (Google Gemini, ChatGPT, RelevanceAI): feedback on AI outputs works best when it's inline and immediate — not batched into a separate "refinement stage." The v2C design solves this with a persistent left panel that contains Quick Actions chips, a Custom Instruction textarea, Recent Changes history, and Apply and Regenerate — always visible, never requiring a screen switch.

### Step 1: AEP Setup (confirmed — v2C)

Full-page form within the dashboard shell. Two-step progress indicator at top (① AEP Setup, ② Test & Refine). Breadcrumb: Red Teaming > New AEP.

**General Details section** — four required fields:
- **AEP Title** (text input) — the name used in the library and campaign builder
- **Adversary Method** (chip selector, pick 1–2: Authority / Urgency / Reciprocity / Curiosity / Scarcity / Familiarity) — severity shown inline (e.g., "Moderate")
- **Target Context** (textarea) — who the employees are, their role and org context
- **Example Messages** (drag-and-drop upload: .txt, .docx, .jpg, .png with OCR — up to 5 files, or paste inline) — grounds generation quality

**Template picker** — Dune-curated templates (e.g., "Ransomware", shown with duration estimate and enabled status) pre-fill the form fields as a starting point.

**View More disclosure** — expands advanced configuration: Attack Scenario, Systems at Risk, Rules & Compliance, Cultural Context, Termination Logic (the full six-section model for users who need more precision).

Primary CTA: **"Refine and Test"** — generates the AEP and advances to Step 2.
Secondary CTA: **Save as Draft** — preserves form state without generating.

### Step 2: Test & Refine (confirmed — v2C Inline AI)

Two-panel layout. Header: AEP name, Draft badge, step indicator, Publish AEP button.

**Left panel — AI Refine panel (persistent, always visible):**
- **Quick Actions** chips: More casual · Less aggressive · Add urgency · More formal · Shorter · More empathetic. Selecting a chip updates the CTA to "Apply '[Chip Label]'."
- **Custom Instruction** textarea: "Describe a change to the AEP's behavior… e.g. 'Don't mention dollar amounts so early'"
- **Recent Changes** list: chronological history of applied instructions with timestamps (e.g., "Make it less pushy — 2 min ago")
- **Apply and Regenerate** CTA — applies the instruction to the AEP and auto-starts a new chat session

**States for the refinement flow:**
- *Chip selected:* Chip highlights, CTA updates to name the chip action
- *Applying:* "Applying changes…" shown while processing (P95 < 20s)
- *Applied / success:* "✦ Regenerated" tag on first new message; Recent Changes appends instruction with "just now"; toast: "Changes applied — new session started"
- *Error:* "Generation failed" in Recent Changes; "Something went wrong. Your changes weren't saved." with "Try again →"; instruction text preserved

**Right panel — Live chat area:**
- AEP sends opening message automatically; persona labeled with AEP's configured name (not "Attacker")
- "Reply as:" chips above input: Curious · Skeptical · Hostile · Compliant — inject preset first replies
- Manager's messages labeled "You • Employee"
- Message input: "Or type your own reply…"
- After each AEP response: 👍 👎 inline feedback controls appear below the message
  - **👎 Thumbs down** → reason chips (Too formal, Too aggressive, Off-topic, Unrealistic, Wrong register) + optional free-text + "Apply & Regenerate" — regenerates only that specific response
  - **👍 Thumbs up** → chips (Perfect tone, Realistic, Good adaptation) + optional note + Save
- **Reasoning ›** collapsible section — content model TBD (see design-review DR-03); collapsed by default

### Why v2C is better than v2A (tabbed) and v2B (bottom drawer)

- v2A (tabbed Chat / Refine with AI): switching between tabs loses conversation context while refining — managers must toggle back and forth
- v2B (bottom drawer Refine with AI): collapsed drawer means refinement is always one click away but never fully co-visible with the conversation — partial improvement
- v2C (persistent left panel): the full refinement toolkit is always visible alongside the conversation. Quick Actions chips eliminate the "what do I type?" problem. Recent Changes builds a visible history of what has been tried. No screen switching required.

### What this replaces

The previous Stage 3 (separate prompt-refinement screen with per-field diff view) and all intermediate tabbed/drawer variants are superseded by v2C. The diff-view pattern was borrowed from code review tools and doesn't fit the conversation-testing mental model.

---

**Option C — Structured Form + AI Generation + Natural-Language Refinement Loop** (previous — superseded)

### AEP Library — management surface

**Table view** (primary) with:
- Columns: AEP Name, Account / Business Unit, Channels, Status (Draft / Pending Review / Active / Archived), Last Modified, Complicit Rate (if deployed), Actions
- Filter bar: status, channel, compliance framework, date range, linked campaign
- Search: full-text on name + scenario description, results < 500ms
- "New AEP" button (top right, primary action)
- "Start from Template" button (adjacent to New AEP)

**Row actions:** View detail, Clone, Archive (if not in active campaign)

**AEP Detail Page** (full-page read view):
- Six-section layout mirroring Stage 1 form — human-readable, not raw JSON
- Right panel: version history, linked campaigns
- Actions: Edit (Draft only), Clone (any status), Archive (if not in active campaign)
- Version history: timestamp, author, refinement prompt that produced each version; field-level diff between any two versions

**Status flow:** Draft → (if Reviewer configured) Pending Review → Active → Archived

---

### Builder — three-stage wizard (full-page)

**Stage 1: Guided Form + Example Upload**

Left nav: stage progress indicator (1 / 2 / 3). Section navigation within Stage 1.

Six sections in sequence or via left-nav jump:

1. **Account Context:** Company name, targeted business unit(s) + headcount, work model (Hybrid / WFO / WFH), network type (Open / Restricted / Highly Restricted). Short text inputs + dropdowns.

2. **Attack Scenario:** Attack type dropdown (Refund Fraud / Credential Theft / SIM Swap / Account Action / Data Exfiltration / Other), opening message (textarea), known attacker aliases (tag input), adaptive resistance toggle. Long text + tag input.

3. **Systems at Risk:** Repeatable row input — each row: application name + what it does. "Add another system" link. Separate section for internal platform apps.

4. **Rules & Compliance:** Multi-select checklist (Data Privacy Act 2012, PCI-DSS, GDPR, ISO 27001 pre-populated), topics to never mention (tag input), instigation threshold radio (None / Soft Stop / Hard Stop on first resistance) with inline contextual help per option.

5. **Cultural Context:** Target timezone(s) multi-select, payment methods multi-select (GCash, Maya, BPay, credit card, etc.), linguistic nuances (Tagalog / Hinglish / Taglish / Arabic / Other + free text notes, sample phrases).

6. **Termination Logic:** Structured list builder for termination triggers (what ends the simulation), continuation phrases (what keeps it going), impact level definitions (Complicit / Non-Complicit / Undetermined / No Response).

**Example Upload section** (below the six sections or in a dedicated card):
- Drag-and-drop zone + file picker button
- Up to 5 examples; accepted: .txt, .docx, .png, .jpg
- Each example: optional channel label (WhatsApp, Telegram, etc.) + language code
- Per-file state: uploading → OCR processing (for images) → ready / failed
- Optional "Paste text instead" inline option per example slot
- Section label: "These examples help calibrate tone and cultural register. Recommended but not required."

**Channel Selection** (prominent, near top or after Attack Scenario):
- Multi-select: WhatsApp, Telegram, Viber, Facebook Messenger, SMS, Instagram, Microsoft Teams, Signal
- Help text: "Channels affect persona register and deployment targets."

**Primary CTA:** "Generate My AEP" — triggers generation with labeled progress screen.
**Secondary CTA:** "Save draft" — preserves form state without generating.

**Generation progress screen:**
- Full-page overlay or dedicated step
- Labeled stages: "Analyzing your scenario" → "Building the conversation flow" → "Configuring guardrails" → "Finalizing"
- Estimated time indicator
- On partial failure: inline error per failed section with per-section retry option; preserved form inputs

---

**Stage 2: Live Chat Test**

Split layout:
- Left panel: AEP summary (name, attack type, channels, key workflow states — non-editable read view)
- Right panel: live chat simulator

Chat simulator:
- Persona sends opening message automatically when test begins
- Customer types in message input field as the employee
- Typing indicator while persona is responding
- Conversation state label shown in a sidebar or header strip: "Current state: 2 — Slight Interest" (visible to customer only, never in live campaign)
- Confidence indicator per state (real-time)

Archetype starters:
- 4 one-click options: Curious Employee, Skeptical Employee, Immediately Hostile, Gradually Compliant
- Each injects a pre-written opening response into the message field with a single click

Controls:
- "Reset conversation" — clears chat, starts a new session
- "Refine this AEP" — navigates to Stage 3

Session history:
- All test sessions preserved in draft (for operator review)
- Session count indicator: "2 test sessions completed"

**Publish pathway:** After at least 1 completed test session, "Publish AEP" CTA activates. Publish with 1 session triggers a warning acknowledgment.

---

**Stage 3: Prompt-Based Refinement**

Layout:
- Left panel: AEP field summary (same read view as Stage 2 left panel)
- Right panel: refinement interface

Refinement interface:
- Text input: "Describe what you'd like to change..." with example prompts (hint text rotates)
- "Submit" → processing state (< 20s P95)
- Diff view below: list of changed fields, each showing old value → new value
  - Each field row: field name, section label (e.g., "Attack Scenario > Opening Message"), old value (struck-through), new value (highlighted)
  - Per-field action: "Accept" / "Reject" buttons
  - "Accept all" / "Reject all" bulk actions at top
- After accepting changes: "Back to Stage 2" to re-test; or "Publish AEP" if satisfied
- "Check AEP" button triggers on-demand validation run, results inline with section highlighting

**Blocked refinement:**
- Guardrail removal attempt: inline blocked message above diff, prompt input persists for editing
- Compliance framework removal: redirect message pointing to Stage 1 Rules & Compliance section

**Version sub-history:** Refinement rounds create sub-versions (v0.1 → v0.1.1). Visible in version panel labeled by timestamp + refinement prompt, not version numbers.

---

**Publish confirmation:**
- Modal: "Publish [AEP Name]?"
- Body: "This AEP will be available in the campaign builder immediately. Once referenced in an active campaign, it cannot be edited until the campaign concludes. To make changes later, you'll need to clone this AEP."
- Validation warnings (if any): shown as checklist items requiring acknowledgment
- Actions: Cancel, Publish AEP (primary)

---

### Dune Operator view

Same UI as customer with an "Operator mode" indicator. Additional panels:
- Raw JSON panel (collapsible technical debug view)
- Validation warning override toggle (logged)
- Operator refinement prompt (submitted as operator-authored, logged)
- Operator Assist flag — triggers customer notification with diff summary
- Test session transcript access (not visible to customer users)

---

## Risks and tradeoffs

**What this strategy gives up:**
- Speed for experienced users. The six-section form is thorough but long. The Clone + edit path mitigates this for repeat users. Templates pre-fill Stage 1 for common account types.
- Simplicity. Six sections with 30+ fields plus example upload is substantial. Help text and sensible defaults must carry a lot of weight. Consider whether sections 3–6 can be collapsed by default with "Advanced" disclosure.

**Risks that persist:**
- **Generation quality is the product's core promise.** If the generated persona is poor quality, every subsequent stage is fighting an uphill battle. The form structure, example upload, and generation prompt quality are all load-bearing.
- **Stage 3 diff complexity.** A single refinement prompt may cascade changes across many field groups (e.g., opening message update → 1_INITIAL state script update → detection pattern update). A flat list of changed fields may be overwhelming. Consider grouping by section.
- **Template adoption vs. template quality.** If templates don't accurately reflect the targeted customer segment (e.g., BPO Philippines template doesn't feel realistic to a telecom in India), customers will skip templates entirely and the reuse metric will underperform.

---

## Open issues

1. **[Critical — PM]** Is a Reviewer ever mandatory? If yes, the publish flow needs a blocking Pending Review state and a Reviewer approval surface — a materially different screen.
2. **[Critical — Both]** Multi-channel deployment model — one AEP / multiple channels in one campaign, or one-channel-per-campaign? Affects channel field design and campaign integration.
3. **[Medium — Eng]** Stage 2 LLM model — full production vs. lighter model for test sessions. Affects how "unlimited sessions" is positioned.
4. **[Medium — PM]** Instigation threshold enum — three values sufficient? Affects Stage 1 field design and help text.
5. **[Medium — Eng]** Auto-save behavior for Stage 1 form. Affects whether a "save draft" CTA is needed or if background save is sufficient.

---

## Next design actions (updated 2026-06-01)

1. **Fix left panel placeholder copy** — replace "Generate Design Element Version 1" and the wrong Reasoning paragraph with AEP-behavior-specific confirmation copy. This is the single blocking issue for handoff readiness.
2. **Add publish eligibility guard states** — design the 0-sessions disabled state (Publish AEP greyed + tooltip) and 1-session warning acknowledgment modal. Add to v2C base frame.
3. **Design "View More" expanded state in Step 1** — label, field list, and help text for the advanced configuration section. Decide which fields are required vs. optional inside the expanded view.
4. **Define Reasoning section content model** — either spec the AEP-specific behavior-change explanation format or remove the section. Do not ship a placeholder.
5. **Design generation progress screen** — P95 45–90s wait with labeled advancing stages is a trust-critical moment. Must visibly progress; static spinner is not acceptable.
6. **Verify Stillsuit DS v2 components** — step indicator (active/complete/upcoming states), chat bubble pattern, chip component, collapsible disclosure, modal, and toast. Flag any gaps to DS.
