# User Flow — AEP Builder + AEP Library
Dune Security · User Flow · Last updated: 2026-05-20 (v2 update — PRD v0.2)

---

## Entry points

1. **Red Teaming > AEP Library** — Security Manager arrives at the library page directly from the nav
2. **Campaign builder — AEP selection step** — campaign creation requires an Active AEP; if none exists, a prompt links to the AEP Builder
3. **"Start from Template" path** — Security Manager selects a Dune-curated template from the library, which pre-fills Stage 1

---

## Happy path — Create a new AEP from scratch with AI generation

1. Security Manager navigates to **Red Teaming > AEP Library** via the left nav.
2. Library loads in table view with columns: AEP Name, Business Unit, Channels, Status, Last Modified, Complicit Rate, Actions.
3. Manager clicks **"New AEP"** button (top right).
4. Builder opens at **Stage 1: Guided Form + Example Upload**. Stage progress indicator shows "1 of 3".

**Stage 1 — Section 1: Account Context**
5. Manager fills: Company name (e.g., "Concentrix"), targeted business unit + headcount (e.g., "United Airlines — 920 agents"), work model (Hybrid), network type (Open).

**Stage 1 — Section 2: Attack Scenario**
6. Selects attack type: "Refund Fraud." Writes opening message: "Hi, this is Carlos from the Refund Operations team. Quick question about a PNR I flagged..." Adds attacker aliases: "Carlos Reyes, Carlos from Ops." Enables adaptive resistance toggle.

**Stage 1 — Section 3: Systems at Risk**
7. Adds row: "CRM — customer profile and refund history lookup." Adds second row: "Refund Portal — initiates and approves refunds."

**Stage 1 — Section 4: Rules & Compliance**
8. Checks: PCI-DSS, Data Privacy Act 2012. Adds no-go topic: "employee personal addresses." Sets instigation threshold: Hard Stop (persona stops immediately on first explicit refusal).

**Stage 1 — Section 5: Cultural Context**
9. Selects timezone: Asia/Manila. Payment methods: GCash, Maya. Linguistic nuances: Tagalog. Adds note: "Use Tagalog pleasantries (po, opo) in opening messages."

**Stage 1 — Section 6: Termination Logic**
10. Adds termination trigger: "I'm reporting this to my manager." Adds continuation phrase: "Let me check on that." Sets Complicit definition: "Employee provides PNR or approves a refund."

**Example Upload**
11. Manager uploads two WhatsApp screenshot images (.jpg) of real solicitation messages their team has received. Labels both as "WhatsApp / Tagalog."

**Channel Selection**
12. Selects: WhatsApp, Telegram.

13. Manager clicks **"Generate My AEP"**.
14. **Generation progress screen** displays labeled stages advancing: "Analyzing your scenario" → "Building the conversation flow" → "Configuring guardrails" → "Finalizing." Total: ~22 seconds.
15. Generation completes. Builder advances to **Stage 2: Live Chat Test**.

**Stage 2 — Live Chat Test**
16. Left panel shows AEP summary (name, attack type, channels, key workflow states). Right panel shows simulator chat, empty, with message input active.
17. Persona sends opening message automatically: "Hi po, this is Carlos Reyes from Refund Operations..."
18. Manager types: "Hi — how did you get this number?" (Skeptical Employee response)
19. State label updates: "1 — Initial." Persona responds with a contact-source deflection script.
20. Manager pushes back: "I don't think I should be doing this without manager approval."
21. State label updates: "3 — Resistance." Persona acknowledges and exits gracefully (Hard Stop threshold). Conversation state reaches a terminal state.
22. Session summary shows: states traversed, messages exchanged, final state reached, no guardrail triggers fired. Session count: "1 test session completed."
23. Manager notices the opening message feels too formal for WhatsApp. Clicks **"Refine this AEP"**.

**Stage 3 — Prompt-Based Refinement**
24. Refinement text input appears. Manager types: "The opening message sounds like an email. Make it shorter and more casual — like a real WhatsApp message from a stranger."
25. Platform processes the prompt (< 15s). Diff view appears:
    - "Attack Scenario > Opening Message" — old: formal multi-sentence text → new: shorter casual text
    - "State Machine > 1_INITIAL > Script[0]" — old: formal greeting → new: casual Tagalog variant
26. Manager accepts both changes. Draft updates. "Back to Stage 2" CTA activates.
27. Manager returns to Stage 2. Runs a second test session with Gradually Compliant archetype starter.
28. Manager is satisfied with behavior. Clicks **"Publish AEP"**.

**Publish**
29. **Publish confirmation modal** appears: "Publish Concentrix — UA Refund Fraud?" Body explains: AEP will be available in campaign builder immediately; once referenced in an active campaign, changes require cloning to a new version.
30. No blocking errors. One warning: "Only 2 test sessions completed. We recommend 3 or more." Manager checks acknowledgment checkbox and clicks **"Publish AEP"**.
31. Builder closes. AEP Library table shows new row: **Active** status, WhatsApp + Telegram channels, last modified timestamp.

---

## Happy path — Start from a Dune-curated template

1. Manager arrives at AEP Library.
2. Clicks **"Start from Template"** button.
3. Template picker modal opens with 6 templates: BPO — Refund Fraud (Filipino), Telecom — SIM Swap Recruitment (India), Aviation — Booking System Fraud, Social Media — Account Action Recruitment, Generic — Bribe / Information Trade, Contact Center — Credential Request.
4. Manager selects "BPO — Refund Fraud (Filipino)."
5. Builder opens at **Stage 1** with all sections pre-filled from template values. Banner: "This is based on the BPO — Refund Fraud (Filipino) template. Update the fields below to match your organization and regenerate."
6. Manager updates: company name, business unit (United Airlines, 920 agents), specific crown jewel apps (CRM + refund portal), known attacker aliases.
7. Clicks **"Generate My AEP"** — generation runs using updated form values, not the template persona directly.
8. Continues from Stage 2 (same as happy path above, steps 16–31).

---

## Decision points

| Decision | Condition | Outcome |
|---|---|---|
| New AEP vs. Template | Manager clicks "New AEP" vs. "Start from Template" | New: blank Stage 1 / Template: pre-filled Stage 1 with banner |
| Example upload | Manager uploads files vs. skips | With examples: richer generation calibration; without: generation proceeds with form data only (warning on publish if no examples uploaded) |
| Channel selection | Channels selected | Drives both deployment target and generation context (register, language nuance) |
| Generation completes | All sections succeed | Advances to Stage 2 |
| Generation partially fails | Some sections fail | Per-section retry; preserved form inputs; cannot proceed until all sections complete |
| Test → Refine | Manager clicks "Refine this AEP" | Navigates to Stage 3; session history preserved |
| Refine → Test | Manager accepts changes, clicks "Back to Stage 2" | Returns to Stage 2; new test session begins; previous sessions preserved in history |
| Publish eligibility | At least 1 completed test session? | No: Publish CTA disabled with tooltip / Yes: Publish enabled (1 session = warning; 2+ = clean) |
| Reviewer configured | Account has Reviewer role set? | No: direct publish → Active / Yes: publish → Pending Review; Reviewer notified |
| Edit Active AEP | Is AEP referenced in active campaign? | Blocked — must clone to new version to make changes |
| Archive AEP | Is AEP in active/scheduled campaign? | Yes: Archive blocked with blocking campaign name / No: Archive confirmation modal |

---

## System responses

| Trigger | System behavior |
|---|---|
| "Generate My AEP" clicked | POST to generation API; progress screen with labeled stages; P95 45s (90s with OCR) |
| Generation completes successfully | Advances to Stage 2; generated content populates AEP draft |
| Generation partially fails | Error per failed section with per-section retry; form inputs preserved; cannot advance until all sections complete |
| Generation fully fails | Full-page error state with retry; option to save draft and resume later |
| Persona sends message in Stage 2 | Typing indicator (~1–2s); response appears within 3s P95; state label updates |
| Stage 2 persona response timeout (> 3s P95) | In-chat timeout message: "Response is taking longer than expected." Retry and Reset options |
| "Refine this AEP" clicked | Navigates to Stage 3; refinement interface with text input |
| Refinement prompt submitted | Processing state (< 20s P95); diff view with changed fields |
| Refinement prompt blocked (guardrail removal) | Inline blocked message above diff; prompt input persists for editing |
| Refinement prompt blocked (compliance framework removal) | Redirect message pointing to Stage 1 Rules & Compliance section |
| "Accept" clicked on diff field | Field updated in draft; sub-version incremented; session continues |
| "Reject" clicked on diff field | Field unchanged in draft; original value retained |
| "Publish AEP" confirmed | Validation runs; if passes: AEP status → Active (or Pending Review if Reviewer configured); library table refreshes |
| Blocking validation failure | In-flow redirect to specific section and field with inline error highlighting; publish blocked |
| Validation warning(s) | Warning acknowledgment modal with per-warning checkboxes; publish proceeds after all checked |
| AEP published (no Reviewer) | Status → Active; toast: "AEP published and available in the campaign builder" |
| AEP submitted for review (Reviewer configured) | Status → Pending Review; toast: "AEP submitted for review"; Reviewer notified |
| Reviewer approves | Status → Active; Security Manager notified |
| Operator Assist flag set | Customer notification: operator name, timestamp, diff summary; customer can review and republish (clone required if Active) |
| Archive confirmed | Status → Archived; row removed from default table view; accessible via "Archived" filter |

---

## Edge cases in flow

| Edge case | Handling |
|---|---|
| Generation partial failure | Per-section retry with preserved form inputs; must complete all sections before Stage 2 |
| OCR failure on image upload | Per-file error; "Paste text instead" option inline |
| Example upload > 5 files | File picker blocks additional uploads with max-limit message |
| Refinement prompt blocks guardrail removal | Inline blocked message; prompt editable for retry |
| Draft with 0 test sessions | Publish CTA disabled; tooltip: "Test this AEP in Stage 2 before publishing" |
| Draft with 1 test session | Publish enabled with warning acknowledgment required |
| No Active AEPs when creating campaign | AEP selector empty state with "Build one now" link to Stage 1 |
| Archive blocked by active campaign | Error names blocking campaign(s) with link to each |
| Clone from Active AEP | New Draft at incremented version; Stage 1 pre-filled with banner noting source AEP |
| Reviewer configured at account | Publish creates Pending Review status; campaign launch blocked until Reviewer approves |
| Operator modifies AEP via Operator Assist | Customer receives notification with diff summary; changes do not auto-publish; customer must clone + republish |
| Opening message > 280 chars with SMS/mobile channel | Validation warning: "Opening message may be truncated on SMS and mobile channels" |
| Instigation threshold = None | Validation warning: "Persona will continue pushing on all resistance signals. Verify this is intentional." |
| Stage 2 persona response timeout | In-chat timeout message with retry and "Reset conversation" options |

---

## Exit states

| State | How reached | What happens |
|---|---|---|
| **Active** | Manager completes all stages and confirms publish (no Reviewer) | AEP row in library shows Active badge; available in campaign builder |
| **Pending Review** | Manager publishes but account has Reviewer configured | AEP row shows Pending Review badge; Reviewer notified; campaign creation blocked at launch until approved |
| **Draft** | Manager saves or exits before publishing | AEP visible in library with Draft badge; Stage 1 form state preserved; not available in campaign builder |
| **Draft (from Active)** | Not possible directly — Active AEPs are immutable | Manager must clone → new Draft version |
| **Cancelled (no save)** | Manager closes browser without any form input | Nothing saved; no AEP created |
| **Archived** | Manager confirms Archive action | AEP soft-deleted; not visible in default table view; accessible via Archived filter; historical campaign records preserved |
| **Blocked (validation failure)** | Publish attempt fails blocking validation | Inline error directs manager to specific section/field; publish blocked until resolved |
