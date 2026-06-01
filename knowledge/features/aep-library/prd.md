## Last updated
2026-06-01 — First full PRD written from Figma v2C (Inline AI) designs + all prior research artifacts. Covers two-step builder flow and AEP Library management surface.

---

The AEP Builder gives enterprise security managers a self-serve, two-step workflow to create, test, and publish Adversary Emulation Pathways — AI-generated chatbot personas that conduct live social engineering simulations against employees. Today the process is entirely manual: customers complete Word and Excel forms, email them to Dune operators, and wait approximately one full day for a JSON persona to be loaded into the backend. The AEP Builder eliminates all operator involvement for standard cases. Step 1 captures the scenario context through a focused setup form; Step 2 lets the manager test the generated persona in a live chat simulation and refine its behavior using quick-action chips or natural-language instructions. The AEP Library is the searchable management catalog for all customer AEPs, with version history, status management, and campaign linkage.

**Primary user:** Security Manager (CISO, security manager, or Red Teaming owner). **Secondary users:** Reviewer (optional sign-off), Dune Operator (internal support), Dune Admin (platform-level).

---

**AEP Library**

The AEP Library is the entry point for all AEP work. Admins reach it via **Red Teaming > AEP Library** in the left navigation. The library presents a table view of all AEPs in the organization, with the following columns: AEP Name, Adversary Method, Status, Last Modified, Complicit Rate (if deployed), and Actions.

Above the table, a filter bar supports filtering by status (Draft / Pending Review / Active / Archived), channel, compliance framework, date range, and linked campaign. Full-text search across name and scenario description returns results within 500ms. The primary action in the top right is **New AEP**; adjacent is a **Start from Template** path for users who want a curated starting point.

Row-level actions are: View detail, Clone, and Archive (blocked if the AEP is attached to an active or scheduled campaign). The library dashboard header surfaces key metrics: active campaigns count, next scheduled campaign date, average complicit rate with trend direction, pending review count, and flagged items needing action.

When no AEPs exist — for example on first access — the table is replaced by an empty state with an illustration, "No AEPs yet" messaging, and two CTAs: **New AEP** and **Start from Template**.

**Status flow:** Draft → Active (direct publish) or Draft → Pending Review → Active (when a Reviewer is configured). Active AEPs may be Archived when not in an active campaign.

---

**Step 1: AEP Setup**

When an admin clicks **New AEP**, the builder opens as a full-page experience within the dashboard shell. A two-step progress indicator at the top shows **① AEP Setup** and **② Test & Refine**. The breadcrumb path reads **Red Teaming > New AEP**.

The setup form is organized under a **General Details** section with four fields:

**AEP Title** (required, text input) — The name used to identify this AEP in the library and campaign builder. Example placeholder: "Add an AEP title."

**Adversary Method** (required, chip selector, pick 1–2) — The psychological levers the persona uses. Options include: Authority, Urgency, Reciprocity, Curiosity, Scarcity, Familiarity. The severity level of the selected combination is displayed inline (e.g., "Moderate").

**Target Context** (required, textarea) — A description of the employee population being targeted: their role, business unit, and organizational context. Placeholder: "Who is the target? Describe their role, department, and org context…"

**Example Messages** (optional, drag-and-drop upload zone) — Real social engineering messages the organization has received. These ground the AI's generation quality — tone, vocabulary, and cultural register. Accepted formats: .txt, .docx, .png, .jpg (images processed via OCR). Up to 5 files. Label: "Upload real social engineering messages your org has received. Improves generation quality. Up to 5 files." An alternative inline paste option is available per example slot.

A **View More** disclosure control expands additional configuration fields below General Details. These include advanced scenario parameters from the full six-section model (Attack Scenario, Systems at Risk, Rules & Compliance, Cultural Context, Termination Logic) for users who need more precise control.

A **template picker** appears in the form area. Dune-curated templates (e.g., "Ransomware") include a content duration estimate and enabled status. Selecting a template pre-fills the General Details fields as a starting point. When a template is used, a banner in Step 2 reads: "Based on [Template Name]. Regenerate to apply your changes."

**Primary CTA:** **Refine and Test** — generates the AEP and advances to Step 2. **Secondary CTA:** **Save as Draft** — preserves form state without generating.

**Generation progress:** After "Refine and Test" is clicked, a labeled progress sequence displays: "Analyzing scenario" → "Building persona" → "Configuring behavior" → "Ready." Duration is P95 45 seconds without image examples and P95 90 seconds with OCR. Each labeled stage advances visibly. On partial generation failure, the failed sections are identified individually with per-section retry options; all form inputs are preserved.

---

**Step 2: Test & Refine**

Step 2 is the live chat testing and behavior refinement surface. The header shows the AEP name ("Meta IT Impersonator"), the Draft status badge, the two-step progress indicator, and a **Publish AEP** button in the top right.

The screen is divided into two panels: the **AI Refine panel** on the left and the **live chat area** on the right.

**AI Refine Panel (left)**

The refine panel is always visible during testing. It contains three sections:

*Quick Actions* — Six one-click behavior chips: More casual, Less aggressive, Add urgency, More formal, Shorter, More empathetic. Clicking a chip selects it and updates the Apply CTA to read "Apply '[Chip Label]'" (e.g., "Apply 'Less aggressive'").

*Custom Instruction* — A textarea for free-form behavior instructions. Placeholder: "Describe a change to the AEP's behavior… e.g. 'Don't mention dollar amounts so early'." Supports any natural-language description of a desired change.

*Recent Changes* — A chronological list of applied refinement instructions with timestamps (e.g., "Make it less pushy" — 2 min ago; "Add more urgency" — 5 min ago). This list grows as the session progresses, giving the manager a record of what has been tried.

The panel CTA is **Apply and Regenerate** (or **Apply '[Chip Label]'** when a quick-action chip is selected). Clicking it applies the behavioral instruction to the AEP and automatically starts a new chat session.

**Refinement states:**

- *Chip selected:* The chip highlights, the CTA updates to name the selected action, and the instruction is passed to the AI on Apply.
- *Applying:* The CTA area shows "Applying changes…" while the request processes (P95 < 20s).
- *Applied / success:* The chat panel shows a "✦ Regenerated" label on the first message of the new session. The Recent Changes list appends the new instruction with "just now." A toast confirms: "Changes applied — new session started."
- *Error:* "Generation failed" appears in the Recent Changes area. An inline message reads: "Something went wrong. Your changes weren't saved." A "Try again →" link allows retry without losing the instruction text.

The panel also shows a collapsible **Reasoning ›** section. When expanded, this displays the AI's explanation of what changed in the persona's behavior as a result of the instruction. Content must be behavior-specific: what field changed, how, and why. The section is collapsed by default.

**Live Chat Area (right)**

The chat area renders the live conversation between the AEP persona and the manager, who plays the employee role.

When the test session begins, the AEP persona sends its opening message automatically. The persona's messages are labeled with the AEP's configured name (e.g., "IT Support Scam AEP") — the same identity the employee would see in a live campaign, not a system-level role label.

Above the message input, **archetype quick-start chips** allow the manager to inject a preset first reply without composing one from scratch: Curious, Skeptical, Hostile, Compliant. These are available at session start and help standardize testing across sessions. The manager's own messages appear labeled "You • Employee."

The message input placeholder reads: "Or type your own reply…" The "Reply as:" label precedes the archetype chips.

After each AEP response, inline **👍 / 👎 feedback controls** appear below the message. Clicking either expands an inline feedback panel:

- *Thumbs up:* Quick-select chips (Perfect tone, Realistic, Good adaptation, Felt natural) + optional note. "Save" logs the positive signal to the session.
- *Thumbs down:* Quick-select chips (Too formal, Too aggressive, Off-topic, Unrealistic, Wrong language register) + free-text field: "Describe the issue or suggest a better response…" + **Apply & Regenerate** — regenerates only that specific AEP response using the feedback as context.

**Publishing**

The **Publish AEP** button in the header activates only after at least one completed test session.

- *0 sessions:* Button is disabled. Tooltip on hover: "Complete at least one test session before publishing."
- *1 session:* Button is enabled. Clicking opens a warning acknowledgment: "Only 1 test session completed. We recommend testing at least 2–3 sessions with different archetypes before publishing." Manager must acknowledge before confirming.
- *2+ sessions:* Standard publish confirmation modal.

**Publish confirmation modal:**
> "Publish [AEP Name]?"
> "This AEP will be available in the campaign builder immediately. Once referenced in an active campaign, it cannot be edited until the campaign concludes. To make changes later, you'll need to clone this AEP."

Validation warnings (if any) appear as individual checklist items requiring acknowledgment before the Confirm Publish CTA activates.

Post-publish: AEP status moves to Active (or Pending Review if a Reviewer is configured). Toast: "AEP published and available in campaign builder."

---

**AEP Detail and Version History**

The AEP detail page presents all Step 1 fields in human-readable form organized into the same sections used during setup. A right panel shows version history with timestamps, authors, and the refinement instruction that produced each version. Linked campaigns are listed in the same right panel.

Actions available on the detail page depend on status: Draft AEPs can be Edited (returning to Step 1) or Cloned. Active AEPs can be Cloned or Archived (if not in an active campaign). Archived AEPs can be Cloned.

**Clone behavior:** Cloning creates a new Draft with all source fields pre-filled, an incremented version (e.g., 1.0 → 2.0), and lineage metadata recorded. The manager lands on Step 1 with a banner: "This is a clone of [Source AEP Name]. Update the details below and regenerate."

---

**Integration Points**

| Integration | Description |
|---|---|
| Risk Scoring Engine | AEP testing completion and publish status feed into the organization's simulation activity score. Published AEPs tied to active campaigns affect employee risk profiles on complicit/non-complicit outcomes. |
| Campaign Builder | Published (Active) AEPs appear in the campaign builder's AEP selector. AEPs in active campaigns are locked — Archive is blocked and the detail page is read-only until the campaign concludes. |
| Email Notifications | If a Reviewer is configured, publishing triggers a notification to the Reviewer's email. Assignment and overdue reminders use the configured Training Sender Email Domain. |
| Adaptive Workflows | Active AEPs can be referenced in Adaptive Workflow triggers — automated simulation assignments triggered by risk events or onboarding milestones. |
| Smart Groups | Campaign targeting for AEP-based simulations supports Smart Groups (dynamically computed groups). Group selection occurs in the campaign builder, not the AEP builder. |
| Dune Operator Panel | Dune Operators have a special permission overlay: raw JSON panel, validation override toggle, operator refinement prompt, Operator Assist flag, and access to test session transcripts. All operator actions are logged. |

---

**Edge Cases & System Behaviour**

| Scenario | Behaviour |
|---|---|
| Generation partial failure | Failed sections identified individually. Per-section retry available. All form inputs preserved. Succeeded sections retained. |
| Generation full failure | Error state with full-form retry CTA. Form state preserved. Error message describes which component failed. |
| OCR failure on image upload | Per-file error with option to paste text content manually. |
| Stage 2 persona response timeout | In-chat timeout message with "Try again" and "Reset conversation" options. |
| Behavior refinement timeout (> P95 20s) | Error displayed in Recent Changes area. Retry available. Instruction text not lost. |
| Refinement blocked — guardrail removal | Inline message: "This change would weaken a required safety guardrail. Refinements cannot disable hate speech, violence, or PII collection protections. Describe what behavior you want to change instead." |
| Refinement blocked — compliance framework removal | "To remove a compliance framework, return to AEP Setup and update the Rules & Compliance section." |
| Archive blocked by active campaign | Error dialog names the blocking campaign(s) with a link to each. Bulk archive past this block is prevented. |
| Archive of completed-campaign AEP | Confirmation: "This AEP was used in [N] past campaign(s). Archiving will not affect historical records. Continue?" |
| Publish blocked — validation failure | In-flow redirect to the specific section and field causing the failure. Field highlighted with inline error. |
| Publish with warnings | Each warning shown as a distinct checkbox item. All must be checked before Confirm Publish activates. |
| 0 test sessions at publish | Publish button disabled. Tooltip: "Complete at least one test session before publishing." |
| 1 test session at publish | Warning acknowledgment required before confirming. |
| Clone from Active AEP | Step 1 pre-filled with banner: "Based on [Source AEP]. Regenerate to apply your changes." |
| AEP name collision after clone | Allow duplicates. Disambiguate visually with version + created date in library row. |
| Template picker unavailable | Error state: "Templates are temporarily unavailable. Start from scratch or try again shortly." Retry CTA. |
| No Active AEPs when creating a campaign | AEP selector empty state: "No published AEPs yet. Build one now." Links to AEP Builder Step 1. |
| Operator Assist triggered | Customer receives prominent in-platform notification: operator name, timestamp, change summary, and diff view. Customer can review and republish (requires cloning if AEP is already Active). |
| Customer without Red Teaming access | AEP Library not visible in navigation. Direct URL to detail returns permission error. |
