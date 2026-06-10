# Design Strategy — Vishing Campaign Launcher

**Last updated:** 2026-06-10

---

## Feature Context

**Goal:** Let Red Team admins configure and commission voice phishing campaigns against their own employees via a managed VOIP-backed wizard, with AI-generated caller personas and per-call outcome streaming.

**Primary user:** Red Team admin (CISO, security manager, Red Team owner).
**Secondary users:** Standard admin (view only), Read-only viewer.

**Trigger:** Admin wants to run a vishing exercise — clicking "Create Campaign" in Red Teaming → selecting the Vishing channel.

**Success:** Admin can configure a vishing campaign end-to-end, submit a request, monitor live call outcomes, and review post-campaign reporting — without leaving the Red Team section or contacting Dune ops outside the product.

---

## Design Goal

Make vishing feel like a first-class channel in the Red Team Campaign Launcher — not an add-on — by inheriting the wizard and reporting infrastructure the admin already knows, replacing only the steps where voice is genuinely different from text.

---

## Key Constraints

- Vishing-only campaigns in v1 — no mixing with SMS or WhatsApp
- Admin requests a campaign; Dune operators activate delivery — admin has no direct launch control
- Execution model is unresolved (AI-driven vs. human-operated) — must design for clarity about what is automated vs. operator-driven
- Voice AEPs are non-interchangeable with text AEPs
- Remediation suppressed by default; suppression locked at launch
- Risk scoring isolated from vishing outcomes in v1
- IDP SCIM required for per-target local timezone enforcement
- Caller ID spoofing capability not confirmed — Caller Identity fields may be script briefing only
- Voice AEPs are structurally richer than text AEPs: Persona + Scenario as separately-versioned components, plus Facts/OSINT injection at runtime
- No market precedent for any of Dune's four differentiators: Voice AEP Persona+Scenario builder, OSINT-grounded scenario personalization, 5-state outcome taxonomy, compliance pre-flight wizard

---

## Execution Model: Confirmed AI-Driven

**Resolved 2026-06-08:** VOIP execution is AI-driven. The system places and conducts calls automatically using the Voice AEP persona. Dune operators provision and activate the campaign; the AI handles all call placement and conversation within the configured window.

Copy implications locked in:
- **Step 1 channel card sub-label:** "AI voice calls via Dune VOIP"
- **Step 2 AEP test call:** Admin speaks with the live AI caller persona — not a Dune operator
- **Step 5 campaign date:** Date when the AI system begins dialing; Dune ops provision first
- **Step 7 test call:** Admin calls a number and experiences the AI persona directly
- **Pending Activation:** Wait is for AI system provisioning and configuration by ops, not operator scheduling
- **Step 8 compliance acknowledgment:** "targets will receive real phone calls from an AI voice system operated by Dune's VOIP infrastructure"
- **Outcome streaming:** VOIP system emits call events in real time; no manual operator classification for standard outcomes

---

## Strategy Options

### Option A — Pure Inheritance: Treat Vishing as a Third Channel with Minimal New Patterns
Vishing steps swap in as direct replacements for their text equivalents. No new structural patterns. Compliance uses the same status card layout as the existing text campaign Step 4. Outcome states use the existing badge palette with two gray variants. Pending Activation is as described in the PRD — status badge plus email confirmation.

**Rejected because:** It leaves the three biggest trust gaps unresolved — compliance self-certification looks like platform verification; Pending Activation is a dead end; two gray badges are visually indistinguishable. These aren't polish issues; they're trust failures that affect legal exposure and admin confidence.

---

### Option B — Full Redesign: Introduce New Structural Patterns for Every Vishing-Specific Step
Treat vishing as so different from text that every step gets a bespoke design. New compliance module, new reporting surface, new campaign status model.

**Rejected because:** It abandons the established wizard infrastructure that gives the product its consistency. It creates unnecessary design debt and slows engineering. The differences between vishing and text campaigns are real but bounded — they don't justify a full parallel system.

---

### Option C (Recommended) — Channel-Swapped Wizard with Five Targeted Enhancements
Inherit the 8-step wizard and reporting infrastructure completely. Apply five focused design enhancements at the specific points where vishing departs from text in trust-critical ways:

1. **Split Step 4 into two visual groups** — platform-verified vs. admin-acknowledged compliance checks
2. **Pending Activation with a visible trust layer** — timeline estimate, in-app status updates, edit/contact path
3. **Call Log badge differentiation** — hollow vs. filled gray to separate "Not Yet Called" from "No Answer"
4. **AEP Channel Type consequence preview** — show what all 3 steps look like for Voice before the admin commits
5. **OSINT review as a named campaign step (Step 3.5)** — admin reviews and approves organizational facts before submission; makes AI realism transparent and admin-accountable

Everything else inherits directly. No new structural patterns introduced without DS review.

---

## Recommended Strategy: Option C

### The four targeted enhancements in detail

---

**Enhancement 1 — Split Step 4 Compliance Pre-flight**

The existing text campaign Step 4 uses status cards (✓ / ⚠ / ✗) for platform-verified states (API status, carrier whitelist). For vishing, the compliance checklist mixes platform-verified checks and admin self-certifications — and treating them identically is a legal and trust failure.

**Design prescription:**

Split Step 4 into two visually distinct groups within the same step:

*Group A — Platform Checks (existing status card pattern)*
- VOIP infrastructure status — platform-verified, auto-resolves when VOIP is Active
- Target phone coverage ≥ 1 — carried from Step 2, platform-calculated

*Group B — Compliance Acknowledgments (new: acknowledgment checklist pattern)*
- Call recording consent on file
- One-party consent jurisdiction (or documented consent for two-party)
- Works council clearance (EU audiences only — conditionally surfaced)

Group B uses a checklist pattern rather than the status card pattern: each item is a checkbox the admin explicitly checks, with a one-line description of what they are confirming and a **Learn more** tooltip with brief legal context. The group header reads: **"Your confirmation required"** with explanatory copy: "These items can't be verified automatically. Check each to confirm they're in order before proceeding."

Platform-verified items (Group A) can auto-resolve and unblock the step. Acknowledgment items (Group B) require explicit admin action. The Continue button activates only when all Group A items are ✓ and all Group B checkboxes are checked.

If IDP SCIM is not integrated, the works council item either hides entirely (if no EU audience can be detected) or shows with a "Unable to verify audience location — check this if any targets may be in EU jurisdictions" label.

**DS implications:** Group B's acknowledgment checklist is a new pattern. It is close to the Step 8 compliance acknowledgment checkbox but uses a multi-item vertical checklist structure rather than a single checkbox. Flag for DS review before implementation — may become a reusable compliance acknowledgment component.

---

**Enhancement 2 — Pending Activation with Trust Layer**

The Pending Activation status is the product's longest trust gap. After an admin submits, they have no idea what's happening. The design must make the wait feel managed, not abandoned.

**Design prescription for the campaign detail header during Pending Activation:**

Below the campaign name and "Pending Activation" badge, add a **Review status row** (not a modal, not a toast — persistent inline contextual content):

> **Submitted June 8 at 2:14 PM** · Dune operators typically activate within 1 business day.

Next to this, a secondary link: **Questions about your campaign?** → opens a pre-filled support contact form in a drawer with the campaign ID pre-populated.

Add a visible **Campaign configuration** card (read-only summary of Step 3–7 config) so the admin can review exactly what was submitted while waiting.

If ops make changes before activation (edge case pending resolution of that open question), an in-app notification appears on the campaign detail with a summary: "Your campaign configuration was updated before activation. Review changes." with a diff view. This handles the ops-to-admin feedback loop.

When activation occurs, an in-app notification and email confirm: "Your vishing campaign [Name] is now active. Calls will begin within the configured window." Campaign status transitions from Pending Activation to Calling.

**What to avoid:** Do not poll the admin via badge color alone. The Pending Activation badge (muted blue) is correct for the campaign list view, but the campaign detail view needs richer context — a badge alone is not enough for a wait state measured in business days.

---

**Enhancement 3 — Call Log Badge Differentiation**

Two states currently share gray: "Not Yet Called" and "No Answer." At campaign scale (200+ targets), a mixed table of gray rows is unreadable. The five-state taxonomy is a key differentiator vs. the market's binary pass/fail — but only if the states are visually distinct.

**Design prescription:**

| State | Badge style | Badge color token |
|---|---|---|
| Not Yet Called | Outlined (border only, no fill) | Gray/neutral — DS neutral-outline |
| No Answer | Filled, light | Gray/muted — DS neutral-fill |
| Engaged | Filled | Orange — DS warning-fill |
| Compromised | Filled | Red — DS danger-fill |
| Declined | Filled | Green — DS success-fill |
| Callback Requested | Filled | Blue — DS info-fill |

Outlined vs. filled badges communicate "not yet happened" vs. "happened, neutral outcome" without requiring color differentiation. This resolves the accessibility gap (color-blind and screen reader users) and the visual scanning gap at scale.

On first load of the Call Log table (or first time a new admin views it), a **Outcome legend** card appears above the table. It is dismissable and does not reappear after dismissal. It shows each state with its badge and a one-line plain-language description. This is particularly important because no competitor has this taxonomy — admins have no prior frame of reference.

**DS implications:** Outlined badge variant may not exist in DS v2. If it does not, flag for DS review — the distinction between "Not Yet Called" and "No Answer" is important enough to justify a new badge variant.

---

**Enhancement 4 — Voice AEP Channel Type Consequence Preview**

The Channel Type selector (Text / Voice) is a one-way decision that changes both builder steps and campaign compatibility. Admins have no market precedent for Voice AEPs — they cannot know what they're committing to from a label alone.

**Design prescription:**

The Channel Type selector in the AEP builder uses a two-card layout (Text | Voice), each card containing:
- A small visual thumbnail illustrating what Step 2 looks like: Text shows a chat bubble interface; Voice shows a script document with a phone icon and "Call test number" button
- A one-line description of what you're building: "A chatbot persona that conducts live text conversations" vs. "A caller persona with a script your team tests via a live phone call"
- A badge if applicable: "3 published" showing existing AEPs of that type

This gives the admin enough signal to choose correctly before committing. The card does not expand into a full preview — the thumbnail and description are sufficient.

After selecting a channel type, the selector label in the builder header (above the step indicator) shows the selected type as a persistent badge: **Voice AEP** or **Text AEP**. This ensures the admin always knows which type they're building even after scrolling.

---

## Step-by-Step Wireframe Plan

### AEP Builder — Channel Type selector (new first interaction)

**Screen:** AEP Builder launch screen (before step indicator appears)
**Layout:** Centered card, two-column type selector
**Key components:** Two-card selector (Text | Voice) with thumbnail, description, existing count badge. Voice card thumbnail should hint at the three-step structure: "Persona → Scenario → Test & Refine"
**Primary action:** Select channel type → builder opens with correct step configuration
**Edge case:** If admin clicks "New AEP" from the campaign wizard with Vishing already selected, the Channel Type selector should default to Voice (pre-selected, confirmable — not bypassed)

---

### AEP Builder Step 1 — Voice: Persona

**Screen:** Step 1 of 3 — Persona
**Layout:** Full-page form, left-aligned, within dashboard shell
**Header:** AEP title input (inline), Draft badge, "Voice AEP" persistent channel badge, three-step indicator, Save as Draft CTA
**Key components:**
- Text input (AEP Title)
- Text input (Caller Name — what the AI says its name is)
- Text input (Claimed Role — e.g., "Internal security monitoring team, extension 4471")
- Textarea (Greeting Message — exact first words the AI speaks; preview with selected voice)
- Voice selector with Preview button (plays 5s sample)
- Chip selector pick-1 (Tone: Casual / Formal / Urgent / Warm / Neutral)
- Chip selector pick-1 (Response Length: Short / Medium / Long)
- Chip selector pick-1 (Cadence: Slow / Normal / Fast)
- Optional selector (Background Audio: Office / Lobby / Road noise / None)
- Tag input (Banned Phrases — pre-populated with Dune defaults; admin can add/remove)
**Primary action:** Next: Scenario
**Secondary action:** Save as Draft
**Edge case — greeting message generation:** If admin doesn't write the greeting manually, an AI-assist button "Generate from role and tone" drafts one based on the other fields. Admin can edit before proceeding.

---

### AEP Builder Step 2 — Voice: Scenario

**Screen:** Step 2 of 3 — Scenario
**Layout:** Two-panel split. Left: Scenario form (~50% width). Right: Scenario visualization panel (live diagram, ~50% width).
**Left panel (form):**
- Text input (Scenario Name)
- Textarea (Scenario Description — plain language pretext description)
- Chip selector 1–3 (Adversary Methods)
- Phases list (ordered, draggable): each phase card has name, goal, transition condition, tactic list. +Add phase at bottom.
- Collectibles list: each item has label, phase assignment, risk weight slider (1–5)
- Tactics list: each item has tactic name, phase, intent, templates (2–3 items), repeatable toggle. +Add tactic and "Use template" (opens Dune tactic library drawer)
- Goals list (auto-populated from collectibles, editable weight)
**Right panel (visualization):**
- Live call flow diagram updating as form is saved/previewed
- Phase nodes with collectible dots and tactic chips
- Directed transition arrows with plain-language condition labels
- Collectibles legend (risk weight color key)
- Goal summary card at terminal node
- Export diagram button (PNG download)
- Visualization is read-only (editing happens only in left panel)
**Primary action:** Next: Test & Refine
**Secondary action:** Save as Draft
**Edge case — empty phases list:** Validation requires minimum 2 phases before proceeding. Inline message: "Add at least 2 phases to define the call flow."
**Edge case — no collectibles:** Warning (not blocker): "This scenario collects no data. The call will run but cannot produce Compromised outcomes — only Engaged or Declined."

---

### AEP Builder Step 3 — Voice: Test & Refine

**Screen:** Step 3 of 3 — Test & Refine (Voice variant)
**Layout:** Two-panel split. Left: AI Refine panel (~300px fixed). Right: tabbed panel (Scenario Flow / Live Test).
**Left panel:** Quick Action chips (voice-adapted: More assertive, Less pushy, Add urgency, Soften opener, Shorter responses, More empathetic opener), Custom Instruction textarea, Recent Changes list, Apply and Regenerate CTA, Reasoning collapsible
**Right panel — Scenario Flow tab:** Read-only call flow diagram from Step 2. After a test call, phase nodes that were reached during the call are highlighted; collectibles triggered are marked with a checkmark.
**Right panel — Live Test tab (default on entry):** Voice and greeting message preview, Call Test Number button, post-call call outcome summary (phases reached, collectibles triggered), "Mark test call as reviewed" checkbox, thumbs feedback controls
**Primary action:** Call Test Number → VOIP call placed → call ends → Scenario Flow tab updates → checkbox appears → check → Publish AEP activates
**Edge case — test call not answered in 60s:** Inline error with Retry. Skip remains with strong warning.
**Edge case — VOIP event not received after call:** Manual "Call completed" fallback link with confirmation modal.
**Post-test Scenario Flow behavior:** After each test call, the Scenario Flow tab shows a "Last test run" overlay on the diagram — which phases were reached and which collectibles fired. This is the most concrete signal the admin has of how far a real target might go.

---

### Campaign Wizard Step 1 — Channel Selection (Vishing card now selectable)

**Screen:** Step 1 of 8 — Channel Selection
**Layout:** Existing wizard step layout. Three channel cards: SMS, WhatsApp, Vishing.
**Vishing card:** Full-color card (not Coming Soon greyed out). VOIP Status chip (Active / Degraded). Channel icon (phone). Label: "Vishing." Sub-label: "AI voice calls via Dune VOIP" (or "Operator-delivered calls via Dune VOIP" if human-operated — adjust once execution model is confirmed). Selecting Vishing disables SMS and WhatsApp cards with a tooltip: "Vishing campaigns are vishing-only in v1."
**Contextual note (below card, visible after selection):** "Dune operators configure and activate calling after you submit your request. You'll receive an email when calls begin." This sets execution model expectations at Step 1, not Step 8.
**Edge case — VOIP Degraded:** Card shows warning chip and degradation note. Admin can proceed; Step 4 will block launch until resolved.

---

### Campaign Wizard Step 2 — Audience (phone coverage labels)

**Screen:** Step 2 of 8 — Audience
**Layout:** Inherits directly from text campaign Step 2. One label change.
**Change:** Coverage indicator label changes from "SMS coverage" to "Phone coverage" when vishing is selected. All other behavior (group picker, individual picker, overlap detection, cooldown warning, zero-coverage hard block) inherits unchanged.

---

### Campaign Wizard Step 3 — Voice AEP + Script

**Screen:** Step 3 of 8 — Voice AEP + Script (replaces Template + Message)
**Layout:** Two-column. Left: Voice AEP selector + calling notes field. Right: AEP preview card with two tabs: Persona and Scenario Flow.
**Key components:**
- Searchable selector (shows only Active Voice AEPs; filter by Adversary Method and Tone)
- Persona tab: read-only caller name, claimed role, greeting message preview, voice label, tone/cadence chips, banned phrases count
- Scenario Flow tab: read-only call flow diagram (the same visualization from the AEP builder), collectibles legend, goal summary
- Campaign-specific calling notes textarea (optional, 500 char limit)
- Edit AEP external link (opens AEP detail in new tab)
**Primary action:** Select Voice AEP → AEP preview populates → Continue
**Empty state:** "No published Voice AEPs yet. Build one now." → link to AEP Builder (opens in new tab, wizard auto-saves draft). On return, wizard is at Step 3 with the selector ready.
**Single-AEP state:** Selector shows one item, pre-selected. No search bar needed.
**Scenario Flow tab design note:** The scenario visualization is the primary reason to show this preview. Admins who skipped the AEP builder (e.g., using a Dune-provided library AEP) may have never seen the scenario. The campaign wizard is their last chance to understand what the AI will actually do on each call.

---

### Campaign Wizard Step 3.5 — Review Organizational Intelligence (new step)

**Screen:** Step 3.5 of 8 — Review Organizational Intelligence
**Layout:** Single column, full-width table within dashboard shell. Step indicator shows this as a named step between Voice AEP and Compliance.
**Key components:**
- Categorized facts table: columns = Fact, Value, Source (manual / OSINT), Sensitivity (public / internal / sensitive), Relevant Phases
- Category headers as section rows: Org Chart, Tooling, Company News, Internal Policies, Vendor Relationships
- Per-row actions: Edit (inline value edit), Suppress (removes from this campaign's injection; fact remains in library), Flag (sends correction request to Dune data team)
- Scenario relevance column: pill badges showing which phases in the selected scenario this fact is relevant to (matched from the scenario's phase keys)
- Summary bar at top: "X facts active · Y suppressed for this campaign"
**States:**
- Normal: table populated, some facts may have no scenario relevance (shown in muted style)
- Empty (no facts configured): empty state with guidance to contact Dune representative; admin can continue with warning
- All suppressed: warning state; admin can still proceed
**Continue:** always available; contextual warning if fewer than 3 facts are active
**DS note:** The Scenario relevance column is a novel UI element — phase badges tied to a specific AEP selection. The relevance mapping changes if the admin goes back and changes the Voice AEP in Step 3.

---

### Campaign Wizard Step 4 — Compliance Pre-flight (split pattern)

**Screen:** Step 4 of 8 — Compliance Pre-flight (voice variant)
**Layout:** Single column, two labeled groups separated by a visual divider.

*Group A — Platform Checks (status card pattern, inherited)*
- VOIP infrastructure status (auto-resolved)
- Target phone coverage ≥ 1 (auto-resolved from Step 2)

*Group B — Your Confirmation Required (acknowledgment checklist, new pattern)*
Header: "**Your confirmation required**" + sub-label: "These items can't be verified automatically. Check each to confirm they're in order before submitting your campaign."
- [ ] Call recording consent is documented for this exercise
- [ ] Targets are in one-party consent jurisdictions, or written consent covers recording
- [ ] Works council clearance is on file *(shown only if EU audience detected via IDP SCIM, or always shown as "if applicable" fallback when SCIM is not integrated)*

Each acknowledgment item has a **Learn more** tooltip with 2–3 sentences of legal context and a link to Dune's compliance guidance doc (external).

**Continue button:** Active only when Group A items are all ✓ and all Group B checkboxes are checked.
**Save as Draft:** Available even with unchecked items — admin can return later.
**DS flag:** Group B acknowledgment checklist is a new pattern. Document for DS review.

---

### Campaign Wizard Step 5 — Call Configuration (replaces Delivery)

**Screen:** Step 5 of 8 — Call Configuration
**Layout:** Single column form. Three configuration sections: Call Window, Attempt Settings, Campaign Date.

*Call Window:* Start time + End time (time pickers) + Timezone selector. Contextual note if IDP SCIM is not integrated: "Without directory integration, all calls will use this timezone regardless of target location."
*Attempt Settings:* Max attempts per target (radio: 1 / 2 / 3; default: 2) + Inter-attempt delay (radio: 1 hour / 2 hours / 4 hours / Next business day; default: 2 hours). Contextual help: "Targets who don't answer after the configured attempts are recorded as No Answer."
*Campaign Date:* Date picker. Sub-label: "Dune operators will begin calls on or after this date, within your configured call window. You'll receive an email confirmation when calling starts." This copy sets the expectation that the date is a requested start, not a guaranteed instant trigger.

---

### Campaign Wizard Step 6 — Remediation (minor voice adaptation)

**Screen:** Step 6 of 8 — Remediation
**Layout:** Inherits from text campaign Step 6. One content change.
**Change:** When suppression is toggled OFF, the remediation rule event types use voice outcome labels: Answered — Compromised, Answered — Engaged, Answered — Declined. All structural behavior (suppression default, toggle, rule cards, lock-at-launch) is unchanged.

---

### Campaign Wizard Step 7 — Test Call (replaces Test Send)

**Screen:** Step 7 of 8 — Test Call
**Layout:** Single column, centered card.
**Key components:** AEP name display (read-only), Phone number input (pre-filled with admin's registered number, editable), Place Test Call button, Call status indicator (Idle → Calling… → Call ended), "I've completed a test call and reviewed the caller persona on a live call" checkbox (appears only after call-ended state), Continue button (active only when checkbox checked)
**Edge case — no registered phone number:** Phone number input is empty with placeholder: "Enter your phone number." Help text: "Use a mobile number where you can receive the test call."
**Edge case — mobile browser on same device:** Contextual note above the phone input: "If you're on a mobile device, use a second device or use a number you can answer while keeping this tab open."
**Edge case — test call not answered in 60s:** Inline error "Test call wasn't answered." + Retry button. Checkbox does not appear; admin must either retry or skip.
**Edge case — VOIP event not received after call ends:** Manual fallback link: "Call completed but confirmation didn't arrive? Mark manually →" → confirmation modal before checkbox activates.
**Skip path:** Skip test call → modal warning (strong, matching existing text campaign skip warning) → explicit confirm → soft warning flag in Step 8.

---

### Campaign Wizard Step 8 — Review + Request (CTA label change)

**Screen:** Step 8 of 8 — Review + Request
**Layout:** Inherits review card structure from text campaign Step 8.
**Changes:**
- Primary CTA: "Submit Campaign Request" (not "Launch Campaign")
- Summary cards: Channel (Vishing + VOIP status), Audience (targeting mode + phone coverage), Voice AEP (name + script outline excerpt), Calling Notes (truncated if long), Compliance (all items confirmed), Call window + max attempts + start date, Remediation setting, Test call status (Completed / Skipped with warning flag)
- Compliance acknowledgment checkbox copy updated for voice: "I confirm this campaign has appropriate internal authorization. Targets will receive real phone calls from Dune's VOIP infrastructure. I am responsible for managing the debrief and disclosure process."
**Post-submit:** Full-screen confirmation (not a toast): "Campaign request submitted. Dune operators will review and activate calling within 1 business day. You'll receive an email when calls begin." + "View campaign" CTA + "Create another campaign" secondary link.

---

### Campaign Detail — Pending Activation Status

**Screen:** Campaign detail header (Pending Activation status)
**Layout:** Inherits campaign detail header layout.
**New elements:**
- Status badge: "Pending Activation" (muted blue)
- Review status row (below campaign name): "Submitted [date] at [time] · Operators typically activate within 1 business day." + "Questions about this campaign?" link → support contact drawer with campaign ID pre-populated
- Read-only configuration summary card (collapsible): shows submitted Step 3–7 configuration
- Action area: No Pause or Cancel button — only "Cancel request" with confirmation modal. Reason: campaign is not yet executing; cancellation is low-stakes.
**Standard admin view:** View all panels, no actions. "View only" label in action area.
**Ops-initiated change notification (if implemented):** Yellow banner: "Your campaign configuration was updated before activation. [Review changes →]" with diff drawer.

---

### Campaign Detail — Calling Status (in-progress)

**Screen:** Campaign detail, Calling status
**Layout:** Inherits in-progress layout from text campaign.
**Changes:**
- Header badge: "Calling" (pulsing, orange)
- Stats row: Total Targets, Reached, No Answer, Compromised (Complicit %), Declined
- Call Log table: columns = Employee Name + phone sub-label, State (badge), Attempt Count, Last Attempt Time, Call Duration, Transcript/Notes link
- Outcome legend card: appears above table on first view, dismissable
- Badge differentiation: outlined gray (Not Yet Called), filled muted gray (No Answer), orange (Engaged), red (Compromised), green (Declined), blue (Callback Requested)
**Column collapse on narrow viewports (1024px):** Call Duration → Last Attempt Time → Transcript/Notes → Attempt Count. Employee Name and State always visible.

---

### Campaign Detail — Post-Campaign Reporting

**Screen:** Campaign detail, Completed status — two tabs: Overview and Call Log
**Overview tab:** Locked stats row, filter bar (date range, geo/site, AEP filter, Export CSV), four charts: Daily activity stacked bar, Complicit by AEP, Complicit by site/geo (SCIM required), Attempt Distribution (reached on attempt 1/2/3)
**Call Log tab:** Per-target table with re-tag control (RBAC-gated). Column collapse order: Call Duration → Geo/Site → Reporting Status → Email (Employee Name, State, Attempt Count always visible)
**Zero Reached edge case:** Stats row shows "Reached: 0" and susceptibility rate displays "N/A" (not 0% — the denominator is 0, not the result). Tooltip on hover: "Susceptibility rate requires at least one answered call."

---

## Risks and Tradeoffs

**Execution model is AI-driven (confirmed 2026-06-08).** Copy across all steps is locked to reflect AI-driven execution. No human-operator variant copy needed.

**Acknowledgment checklist (Group B in Step 4) is a new DS pattern.** It is the right call — treating self-certifications as verified states is a legal risk — but it requires DS review before implementation. If DS does not have a multi-item acknowledgment checklist component, one must be designed. This is a scope item for engineering estimation.

**Outlined badge variant may not exist in DS v2.** If it does not, the outlined vs. filled gray distinction for "Not Yet Called" vs. "No Answer" requires a new badge variant. This must be confirmed with the DS before designing the Call Log table.

**Manual fallback for test call VOIP event non-receipt is pragmatic but imperfect.** Allowing an admin to self-attest "call completed" removes the assurance that they actually reviewed the persona. This is an acceptable v1 tradeoff — the alternative is blocking the admin indefinitely — but it should be logged for audit purposes.

---

## Open Issues Before Design Can Be Finalized

1. **[PM]** Is Group B compliance acknowledgment a self-certification or does a document upload flow need to be designed? If upload, that's a new settings surface (Compliance Settings) with non-trivial scope.
2. **[Eng]** Does the outlined badge variant exist in DS v2? Confirm before designing the Call Log table.
3. **[PM]** What is Dune's committed activation SLA? The "within 1 business day" copy in multiple places needs to be an explicit product commitment before it ships.
4. **[PM]** Is debrief out-of-platform? If yes, should the post-campaign Overview tab include a "Debrief resources" section or template?
5. **[Eng]** Does the VOIP system emit semantic outcome events (Engaged, Compromised, Declined) automatically from call behavior, or does a Dune ops team member classify each call post-completion? This affects whether the Call Log table updates in real time or with latency.
6. **[Eng]** How does the OSINT facts system get populated for new customers? Is there an onboarding flow or a Dune-side admin tool? The Step 3.5 design depends on whether facts are always present or frequently empty.
7. **[PM]** When the admin suppresses a fact for a campaign, is that suppression persisted per-campaign or does it reset for each new campaign? If per-campaign, the review step must be completed each time.
8. **[Eng/DS]** The Scenario Flow visualization in the campaign wizard is the first time a read-only embedded diagram appears in a wizard step. Confirm whether the DS diagram component is composable enough for this context, or whether a simplified static diagram is needed for v1.

---

## Next Design Actions

1. **Confirm DS v2 badge variants** — check whether outlined badge exists; if not, create a DS-tracked request before designing the Call Log table.
2. **Flag Group B acknowledgment checklist for DS review** — propose the component spec and get sign-off before implementing Step 4.
3. **Begin with AEP builder Persona step** — establish the voice-specific field vocabulary (voice selector, greeting preview, banned phrases) before building the more complex Scenario step.
4. **Design the Scenario visualization component** — this is the highest novelty element in the entire feature. Start with a simplified read-only diagram and confirm with Eng how it will be rendered (SVG, canvas, or a DS graph primitive).
5. **Design Step 3.5 OSINT Review** — define the facts table and category structure; establish what the empty state and suppression states look like.
6. **Use the existing Red Team Campaign Launcher Figma file as the base** — copy existing step frames for Steps 1, 2, 6, 8 and make the described adaptations; create new frames for Steps 3, 3.5, 4, 5, 7 as voice variants.
