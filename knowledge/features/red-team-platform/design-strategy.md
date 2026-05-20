# Design Strategy — Red Team Platform
Dune Security · Design Strategy · Last updated: 2026-05-13 · Initial strategy — refinement run expanding from sms-phishing.

---

## Feature context

**Goal:** Enable security teams to run active, multi-channel social engineering campaigns driven by AI-adaptive AEP chatbots — then surface employee conversation threads and support admin judgment on complicity.

**Primary users:** Security admin / red team operator. Secondary: SOC/IR lead, compliance owner.

**Trigger:** Security team wants to test employee susceptibility to active, multi-step social engineering (not just passive one-shot lures) and evaluate real response behavior.

**Success:** Admin can select or build an AEP, compose a multi-channel attack, configure a campaign, submit for approval, and review conversation outcomes — without engineering support for each new scenario.

**What an AEP is:** An AEP (Adversary Emulation Pathway) is an AI-powered scenario-based chatbot that conducts the social engineering interaction autonomously. It adapts its responses in real time based on how the target employee replies. Example: a "bribe offer" AEP escalates if the employee shows curiosity, tries a different angle if they resist. An AEP is defined by a scenario prompt — not a scripted sequence. Admins create AEPs by writing a scenario, testing in a live chat simulator, and iterating with refinement prompts.

**PRD-confirmed scope:**
- Five product sections: Dashboard (already designed), AEP Library, Attack Library, Campaigns, Conversation Management
- AEPs are AI-adaptive chatbots (not linear scripts) — branching is inherent, not a future feature
- AEP creation: prompt editor + live chat simulator test loop (planned capability — Dune-seeded library ships first)
- Multi-channel: SMS confirmed; Voice, WhatsApp, Viber as additional channels (availability per tenant TBD)
- Node-based editor for attack composition (linear sequences only in v1)
- Request-start campaign model (requires approval before activation)
- Complicit / non-complicit admin marking for conversation outcomes
- Scheduling: start date, allowed days of week, start/end time (more granular than smishing)
- Inherits: audience selection, phone coverage model, compliance acknowledgment, remediation agent integration, graduated risk signals

**Still-open constraints affecting design:**
- AEP authoring availability: Dune-seeded library ships first; customer AEP creation is planned but timeline unconfirmed
- AEP LLM architecture: model, hosting, latency SLA, prompt injection guardrails — all unconfirmed
- Complicity: auto-flagged vs. manually flagged (design for manual with system-suggested flags)
- Approver role: new RBAC role vs. second admin (design for configurable approver)
- Voice channel: automated vs. human-logged (design for human-logged in v1)
- Channel availability per tenant (WhatsApp, Viber may not be universally available)
- Navigation home: top-level "Red Team" vs. sub-nav under Simulations (see strategy options)

---

## Design goal

Give security admins a structured, five-section Red Team workspace — with a composable attack builder, conversation review surface, and approval-gated campaign flow — that makes active social engineering simulation as accessible as passive phishing simulation.

---

## Key constraints

- **Node-based editor must be scoped to linear sequences in v1.** Branching attack paths are valid long-term but will overwhelm v1 delivery. A → B → C channel hops cover the primary use case (SMS → Voice, SMS → WhatsApp) without requiring recursive branch logic.
- **Complicity marking must have a confirmation step.** Marking an employee as complicit — even in simulation — has HR implications. Single-click marking is not acceptable; confirmation modal required.
- **Request-start model requires a new RBAC approver role.** Design for a configurable "Red Team Approver" role. If no approver is assigned, the request-start CTA must surface the gap, not silently disable.
- **AEP library must be Dune-seeded from day one.** If the AEP library is empty at tenant creation, campaign creation is immediately blocked. Dune must ship a library of pre-built AEPs covering common social engineering scenarios (bribe, authority impersonation, urgency, curiosity baiting, reciprocity). Customer AEP authoring is a planned capability that ships after the Dune library is established.
- **Channel availability is tenant-scoped.** Attack nodes for channels the tenant has not configured (WhatsApp, Viber, Voice) must be visually present but gated — so admins understand what's possible without being able to build unconfigured attacks.
- **Navigation must not break the existing Simulations → Smishing path.** Smishing simulation is a shipped feature. The Red Team platform must not subsume or disrupt it in v1.

---

## Strategy options

### Option A: Red Team as a top-level nav section (recommended)

Create a dedicated "Red Team" top-level nav item alongside Simulations, Training, Risk, etc. The Red Team section contains all five sub-sections as a tab bar or sub-nav: Dashboard, AEP Library, Attack Library, Campaigns, Conversations.

**Pros:**
- Makes the conceptual distinction clear: Simulations = passive measurement; Red Team = active adversarial. These are genuinely different operational contexts requiring different admin mindsets.
- Avoids polluting the Simulations section — which email phishing, smishing, and training admins depend on — with red team complexity.
- Five sub-sections fit cleanly under a single Red Team nav home with a tab bar or sub-nav strip.
- Mirrors how enterprise security platforms (e.g., Cobalt Strike, Mandiant Attack Surface Management) treat red team as a distinct operational module.

**Cons:**
- Adds a new top-level nav item — requires product and design alignment on the nav information architecture.
- May feel like a premium/separate product. If the intent is to present Red Team as a natural extension of Simulations, a dedicated section creates more distance.

---

### Option B: Red Team as a sub-section under Simulations

Add "Red Team" as a sub-nav item under Simulations, alongside Email Phishing, Smishing, Training. The five Red Team sub-sections become nested nav items under Simulations → Red Team.

**Pros:**
- Keeps all simulation types under one roof. Admins who do both smishing and red team stay in the same nav section.
- Lower nav-level change — easier to ship without nav architecture re-work.

**Cons:**
- Five nested sub-sections under Simulations → Red Team creates three navigation levels (Top nav → Simulations → Red Team → [section]), which exceeds DS-recommended depth.
- The Simulations section already has sub-nav items. Adding a Red Team "parent" item with its own five children would require a fundamentally different nav component pattern — more work than creating a top-level item.
- Red team and passive simulation are different enough in operator mindset that co-locating them creates context-switching friction.

---

### Option C: Absorb into Simulations with a new "Red Team" campaign type

Extend the existing campaign wizard with a "Red Team" campaign type at step 1. VEP and attack sequence selection become wizard steps. Conversation management becomes a tab in the campaign detail view.

**Rejected for v1:** Does not support the AEP Library and Attack Library as standalone sections (which are design and management surfaces, not wizard steps). Conversation management at the campaign level is fine, but VEP and attack authoring require their own dedicated spaces outside the campaign wizard. This option undersells the product and creates an unmaintainable wizard with too many conditional paths.

---

## Recommended strategy: Option A — Dedicated "Red Team" top-level nav section

Use a dedicated "Red Team" top-level nav section with five sub-sections navigable via a persistent sub-nav strip (tab bar pattern, Stillsuit DS v2):

1. **Dashboard** — overview of recent attacks and insights (already designed)
2. **AEP Library** — browse, create, manage Adversary Emulation Pathways
3. **Attack Library** — browse, create, manage multi-channel attack sequences (node-based editor)
4. **Campaigns** — campaign list, creation wizard, campaign detail
5. **Conversations** — cross-campaign conversation thread review and complicity marking

The campaign creation wizard has 5 steps:
1. Campaign details (name, start date, allowed days, start/end time)
2. Build Attack Flow (AEP + channel + opening message + nudge sequence — inline node editor)
3. Audience (groups, departments, cohorts, CSV)
4. Remediation (rules triggered by complicity outcome)
5. Review + Request Start

This is 5 steps vs. the smishing wizard's 7 steps. The smishing wizard's "Test Send" step is removed (red team campaigns involve real conversations, not one-shot lures needing a preview test). The previous separate VEP Selection and Attack Selection steps are consolidated into the single "Build Attack Flow" step. Remediation remains a step, inheriting from smishing.

---

## Risks and tradeoffs

**What Option A gives up vs. Option B:**
Admins who want to see all simulation types in one list (email phishing + smishing + red team) cannot do so without a future cross-type reporting view. This is acceptable — red team campaigns produce conversation threads, not click rates; combining them with passive simulations in a single list would conflate incompatible outcome models.

**AEP library cold-start.**
If Dune does not ship pre-built VEPs at launch, campaign creation is immediately blocked. The AEP Library empty state must have a "Request VEP from Dune" CTA as a fallback. This is the same cold-start risk as the smishing template library — but higher stakes because VEPs require more expertise to author than SMS templates.

**Node-based editor complexity in v1.**
The v1 attack flow in the campaign wizard supports branching on a single condition: whether the employee replied or did not reply. This is not a pure linear sequence — it is a two-branch conditional (replied → AEP; no reply → nudge). This is intentionally designed to extend to hybrid multi-channel attacks: future versions can insert additional channel nodes before the AEP terminal node on the replied branch, or add more sophisticated branching conditions. Build the node renderer extensibly.

**Complicity marking consistency.**
Because complicity is a judgment call (not a system event), inter-admin consistency is unpredictable. Two admins reviewing the same thread may reach different conclusions. The UI must surface guidance at the point of marking — inline criteria, examples of complicit vs. non-complicit responses — to improve consistency.

**Approval workflow dead-end.**
If no Red Team Approver is configured in the tenant, the "Request Start" CTA becomes a dead end. The system must detect this condition before the admin reaches Step 6 and surface a resolution path (go to Settings → Configure Approver).

**Channel availability gaps.**
If a tenant does not have WhatsApp or Viber configured, attack nodes for those channels must be visually present but gated. Admins can see what multi-channel attacks look like and plan ahead, but cannot activate those nodes until their tenant is provisioned.

---

## Wireframe plan

### Section 0: Red Team — Navigation entry

**Role:** Top-level nav entry point to the Red Team section.

**Layout:** New top-level nav item "Red Team" in the global side-nav. Expands to reveal five sub-nav items: Dashboard / AEP Library / Attack Library / Campaigns / Conversations.

**DS pattern:** Existing side-nav expandable section pattern. No new component. Active sub-item is highlighted.

**Default landing:** Dashboard (first sub-item).

---

### Section 1: Red Team Dashboard (contract documentation only — screen already designed)

**Role:** At-a-glance overview of recent red team activity, attack outcomes, and insights.

**Contract (what downstream sections depend on):**
- Surfaces aggregate metrics for attacks sent in the past N days
- Entry point to Campaigns and Conversations for in-progress work
- Does not replace Campaign detail or Conversation detail — links to those
- "Create Campaign" quick action CTA — routes to Campaign creation wizard

**Design action:** Confirm the dashboard data contracts with Eng (what time window, what metrics, what update cadence) before the handoff. Do not redesign the screen.

---

### Section 2: AEP Library

**Role:** Admin can browse, preview, create, clone, and manage Adversary Emulation Pathways — AI-driven social engineering chatbots defined by scenario prompts. AEPs are adaptive by nature; they respond differently to each employee based on what that employee says.

**Layout:** Page header + tab bar ("Dune Library" | "Custom") + table + primary action.

**Dune Library tab:**
- Table columns: AEP name / Scenario category / Tactics badges / Difficulty / Actions (Preview / Clone)
- Dune-provided AEPs are read-only. Clone creates a customer-owned copy that can be edited.
- Empty state: not applicable (Dune must seed this at launch with scenarios covering: bribe/exchange, authority impersonation, urgency, curiosity baiting, reciprocity)
- Preview: opens a 480px drawer showing a **live demo chat** of the AEP in action. Admin can type as the target employee and see how the AEP responds in real time. This is not a static script — it is an actual LLM interaction in a sandboxed preview context.

**Custom tab:**
- Table columns: AEP name / Scenario category / Tactics badges / Difficulty / Status (Draft / Active) / Last modified / Actions (Edit / Clone / Archive)
- "Create AEP" primary button (top right)
- Empty state: "No custom AEPs yet. Browse the Dune Library to find a starting point, or build one from scratch." + "Browse Dune Library" (primary) + "Create AEP" (secondary)
- Filter: by category, tactics, difficulty, status

**AEP creation/edit form — two-panel layout (new pattern — DS review required):**

This is the core AEP authoring experience. Two panels side by side:

**Left panel: Scenario editor (prompt builder)**
- AEP name (inline editable, top)
- Scenario category: dropdown (Bribe & Exchange / Authority Impersonation / Urgency & Pressure / Curiosity Baiting / Reciprocity / IT Support / Executive Impersonation / HR & Benefits / Finance & Payment)
- Channel compatibility: multi-select tags (SMS / Voice / WhatsApp / Viber)
- Difficulty: segmented control (Easy / Medium / Hard)
- **Scenario prompt** (the core field): large textarea. Label: "Describe the social engineering scenario." Helper text: "Describe who the attacker is, what they want, and how they should approach the target. Be specific about escalation behavior." Placeholder: "You are a vendor representative offering a $200 gift card in exchange for the employee's help verifying their account credentials. If they seem interested, press for more detail. If they hesitate, offer a higher reward. If they refuse outright, thank them and end the conversation."
- **Refinement prompts** (iterative additions): below the main scenario prompt, a list of "Additional instructions" the admin can add after testing. Each is a text field with a label like "Refinement #1". Example: "Be more persistent if the user says they need to check with their manager. Try urgency: the offer expires today." The admin adds these after observing the AEP's behavior in the simulator. Up to 10 refinements.
- "Reset to base prompt" link (clears refinements, keeps original scenario)
- Save Draft / Save & Activate actions (sticky footer)

**Right panel: Chat simulator**
- Label: "Test your AEP — type as if you are the target employee."
- Chat interface: admin types as the target; AEP responds as the attacker persona
- "Reset conversation" button (clears the test chat; does not affect the prompt)
- "Start over" restores to the opening attacker message
- Tone indicator (optional): badge showing the current conversation state as inferred by the system (e.g., "Employee: Curious", "Employee: Resistant", "AEP: Escalating")
- The simulator calls the live LLM with the current prompt — it reflects what the AEP will actually do in production

**Workflow:** Admin writes scenario → tests in simulator → observes behavior → adds refinement instruction → tests again → repeats until satisfied → activates.

**Guardrails (content safety):**
- On "Save & Activate": Dune runs a content safety check on the prompt. If the prompt triggers a content policy violation (e.g., contains protected class language, promotes illegal activity), activation is blocked with an inline error: "This scenario prompt may violate Dune's acceptable use policy. [Reason]. Revise the prompt before activating."
- Guardrail check is non-blocking for "Save Draft" — admins can save work-in-progress prompts.

**DS patterns:** Table, drawer (preview demo chat), full-page two-panel layout, inline-editable name field, textarea.

**New patterns required — DS review:**
1. Two-panel AEP editor (prompt editor + live chat simulator side-by-side)
2. Refinement prompt list (repeatable instruction fields below the main prompt)
3. AEP preview drawer (live demo chat, not a static preview)

---

### Section 3: Attack Library + Node-Based Editor

**Role:** Admin builds and manages multi-channel attack sequences. Each attack is a linear sequence of channel nodes (e.g., SMS → Voice, SMS → WhatsApp → SMS follow-up).

**Layout:** Page header + attack list table + primary action. Node editor opens in full-screen or large right-panel on "Create Attack" / "Edit Attack."

**Attack list:**
- Table columns: Attack name / Channels used (badge strip) / Step count / Status (Draft / Active) / Last modified / Actions (Edit / Clone / Archive / Preview flow)
- "Create Attack" primary button
- Empty state: "No attack sequences yet. Build your first attack using the sequence editor." + "Create Attack" CTA

**Node-based editor (full-page canvas or full-width panel):**

*This is a new DS pattern. Flag for DS review.*

**Canvas layout:**
- Left sidebar: channel node palette — available channel types as draggable chips: SMS, Voice, WhatsApp, Viber. Channels not configured for the tenant are shown as locked (greyed + lock icon + "Contact your admin to enable").
- Center canvas: the attack sequence. Nodes are arranged left-to-right (v1: linear only). Each node is a card:
  - Channel icon + channel name
  - Message/script field (for SMS/WhatsApp/Viber: text; for Voice: script prompt or "Human-executed" label in v1)
  - Delay setting (send X minutes/hours after previous step)
  - Condition label (v1: always → next step)
- Connections between nodes are drawn as arrows (left-to-right sequence)
- "Add step" button to append a new node at the end of the sequence
- No branching in v1 — "Add branch" is visible but disabled with tooltip: "Branching attack paths are coming soon."

**Node configuration drawer (480px, opens on node click):**
- Channel: read-only (set at node creation)
- Message/script content (same character limits and variable tokens as smishing template editor for SMS/WhatsApp/Viber)
- For Voice (v1): "This step is human-executed. Add talking points for your operator:" — free-text field for the operator's script guide
- Delay before this step: number field + unit (minutes / hours / days)
- Step label: optional internal name for this node

**Edge cases in editor:**
- Attack with no terminal node: "Save & Activate" blocked; inline warning: "Add at least one step before activating."
- Node using a channel not available for this tenant: node shown locked; cannot connect it into the sequence
- Admin navigates away with unsaved changes: confirmation modal — "You have unsaved changes to this attack. Discard or keep editing?"

**DS patterns:** Table, full-page canvas (new — DS review required), drawer (node config), modal (unsaved changes).

---

### Section 4: Campaigns

**Role:** Campaign list and campaign creation wizard for red team campaigns.

**Layout:** Campaigns list (default view) with "Create Campaign" entry point. Campaign creation opens a 5-step wizard. Campaign detail is a sub-page of this section.

#### Screen 4a: Campaign list

- Table columns: Name / Status badge / Audience / Attack / VEP / Start date / Conversations / Actions (…)
- Status badges: Draft / Pending Approval / Approved / Active / Completed / Cancelled
- Filter: by status, date range, attack channel
- "Create Campaign" primary button (top right)
- Empty state: "No red team campaigns yet." + "Create Campaign" CTA
- Pending Approval row: shows an "Awaiting approval" badge and a "Withdraw Request" action for the campaign owner

#### Screen 4b: Campaign wizard — Step 1: Campaign Details

**Role:** Admin names the campaign and sets the scheduling parameters.

**Layout:** Wizard frame (Stillsuit DS v2 wizard pattern). Step bar shows 5 steps, step 1 active.

**Key components:**
- Campaign name: text input (required, placeholder: "Red Team Campaign — Q2 2026")
- Start date: date picker
- Allowed sending days: day-of-week multi-select (Mon / Tue / Wed / Thu / Fri / Sat / Sun) — default: Mon–Fri
- Start time: time picker + timezone selector (defaults to detected timezone)
- End time: time picker (must be after start time; system validates)
- Helper text: "Messages will only be sent on the selected days, within the start–end time window."

**Edge cases:**
- Start date in the past: inline date picker validation error
- End time before start time: inline error on the end time field
- No days selected: inline error — "Select at least one allowed sending day"

---

#### Screen 4c: Campaign wizard — Step 2: Build Attack Flow

**Role:** Admin configures the complete attack for this campaign in a single step — which AEP drives conversations, what the opening message is, which channel to use, and what happens when the employee replies or ignores. Replaces the previous separate VEP Selection and Attack Selection steps.

**Layout:** Full-width node editor canvas with a dotted-grid background. Nodes connect top-to-bottom via arrows. A branch node auto-generates from every contact node.

**Default state on load (pre-configured flow):**
- Initial Contact node (top center) — channel pre-selected to SMS, message empty
- Branch: "If replied" (left) → AEP node (green accent, shows "Select AEP")
- Branch: "No reply after 3 days" (right) → Nudge node (channel SMS, message empty)
  - Nudge branches: "If replied" → AEP node; "No reply" → End node
- "+ Add nudge" dashed card below the nudge chain

**Node types:**
1. **Initial Contact** — channel pill selector (SMS / WhatsApp / Telegram) + message textarea
2. **AEP** — tap to select from 2 available AEPs; shows AEP name + adversary method; always terminal on "If replied" branches
3. **Nudge** — delay (days) input + channel selector + message textarea; chainable, max 3 in v1
4. **End** — auto-generated terminal; cannot be deleted

**Branch labels:** "If replied" (fixed) and "No reply after [N] days" (N set on the Nudge node; label updates live)

**Continue blocked until:** Initial Contact has channel + message; all Nudge nodes have messages; one AEP is selected.

**DS pattern:** Node canvas (new pattern — DS review required). Node cards use existing Card component. AEP selector uses Drawer / 480px. Inline validation uses existing error state tokens.

**Future extensibility:** In v1 the "If replied" branch always terminates at AEP. The node model supports inserting additional channel nodes before AEP for multi-channel escalation in future versions without a canvas redesign.

---

#### Screen 4d: Campaign wizard — Step 3: Audience

**Role:** Admin selects the target audience. Inherits entirely from the smishing wizard audience step.

**Layout and components:** Identical to smishing wizard Step 1 (Audience):
- Audience selector: searchable dropdown supporting groups, departments, locations, risk cohorts
- CSV upload toggle
- Phone coverage indicator (same coverage model as smishing)
- "View coverage gaps →" drawer
- Cooldown warning if group was recently targeted

---

#### Screen 4e: Campaign wizard — Step 4: Remediation

**Role:** Admin configures automated actions triggered by campaign outcomes. Inherits from smishing wizard remediation step, extended for complicity outcome.

**Layout:** Rule-builder panel. Each rule is an if/then card.

**Pre-built rule cards (toggle ON/OFF):**
- "If employee is marked complicit → Assign [module selector] training"
- "If employee is marked complicit → Notify manager"
- "If employee engages with 2+ red team campaigns → Notify manager"
- "If employee is marked complicit → Create ServiceNow ticket" (requires ServiceNow integration)

**Extends the smishing remediation model** — complicity replaces click/submit as the outcome trigger.

---

#### Screen 4f: Campaign wizard — Step 5: Review + Request Start

**Role:** Full campaign summary before submitting for approval. Compliance acknowledgment. Request-start CTA.

**Layout:** Summary cards + sticky footer with CTA.

**Key components:**
- Summary cards: Campaign details (name, schedule, allowed days) / VEP name + category / Attack name + channel strip / Audience + coverage count / Remediation rules summary
- Coverage warning (if applicable): same as smishing — "N members will not receive this campaign (no phone number on file)."
- Compliance acknowledgment checkbox: "I confirm that [Company] has informed employees that Dune Security may conduct simulated security exercises, including multi-channel social engineering simulations, as part of its security training program, and that [Company] has a lawful basis for this activity."
- **Approver configuration warning** (conditional): if no Red Team Approver is configured — inline callout: "No Red Team Approver is configured for your organization. Configure an approver in Settings before requesting campaign start." CTA disabled until resolved.
- Primary CTA: **"Request Campaign Start"** (not "Launch Campaign") — disabled until compliance checkbox is checked and approver is configured
- Secondary: "Save as Draft"
- On submit: campaign status changes to "Pending Approval"; confirmation toast: "Request submitted. Your Red Team Approver will be notified."

---

#### Screen 4h: Campaign detail view

**Role:** Post-activation monitoring and conversation summary for a single red team campaign.

**Layout:** Page header + stats row + tab bar (Overview | Conversations) + content.

**Header:**
- Campaign name / "Red Team" badge / status badge
- Actions menu: Cancel Campaign / Archive (status-dependent)

**Stats row:**
- Targeted / Contacted / Responded / Marked Complicit / Non-Complicit / Training Assigned
- Complicit and Non-Complicit counts are the primary outcome metrics (replaces click-rate)

**Conversations tab:**
- Table of conversation threads: Employee name / Department / Contact date / Last response / Status (Active / Complicit / Non-Complicit / No Response)
- "Review" action on each row — opens conversation thread detail (see Section 5)
- Filter: by status, department, date range
- Bulk action: "Mark selected as…" (Complicit / Non-Complicit) with confirmation modal

**Overview tab:**
- Timeline chart: contacts and responses over time
- Remediation log: rules fired, for which employees, outcomes

**Approval state view (Pending Approval):**
- Approver name + "Awaiting approval" callout
- "Withdraw Request" action — returns campaign to Draft

---

### Section 5: Conversation Management

**Role:** Cross-campaign view of all conversation threads requiring review. This is the primary workspace for red team operators reviewing campaign outcomes.

**Layout:** Page header + filter bar + conversation thread table + thread detail panel (right side, 480px, or full-page on selection).

**Conversation thread table:**
- Columns: Employee / Department / Campaign / First contacted / Last message / Channel path (badge strip: e.g., SMS → Voice) / Status (Pending Review / Complicit / Non-Complicit / No Response) / **Reviewed by** (admin name, empty for Pending Review) / **Reviewed at** (timestamp, empty for Pending Review)
- Default filter: "Pending Review" — shows all threads not yet marked
- Sort: by last message (most recent first by default)
- Filter: by campaign, status, department, channel, date range

**Thread detail (480px right-anchored drawer):**
Triggered by clicking "Review" on any thread row. The drawer is the primary review surface.

- **Header:** "[Employee Name] conversation history" + X close button
- **Metadata row** (below header, above transcript): Start Time / End Time / Phone Number (masked) / Recommended Status (system-derived FAIL/PASS badge + category tag — visible when system flag present)
- **Conversation transcript:** Chronological exchange. Attacker messages: left-aligned, labeled "Attacker · [AEP Name] · [timestamp]". Employee messages: right-aligned, labeled "[Employee First Name] · [timestamp]". Voice entries as system event rows.
- **AEP step indicator:** Muted label below each attacker message: "AEP: Exchange N of N — [Node label]". Terminal node labeled as engagement signal.
- **System-suggested flag (if in scope):** Callout above classify section with excerpt + Accept/Dismiss. Accepting pre-selects Complicit radio.
- **Classify this conversation section:**
  - Radio group: ○ Complicit / ○ Non-complicit
  - No default for Pending Review threads; pre-selected to current status for classified threads
- **Reporting section:**
  - Checkbox: "Send report to internal team"
  - Helper: "Includes conversation, classification, and optional notes."
  - Notes textarea (visible when checkbox checked, max 500 chars)
- **Sticky footer:** Cancel (ghost) + Apply updates (primary, disabled until radio selected or changed)
- **Apply updates behavior:** No separate confirmation modal. Radio selection + primary CTA is the confirmation pattern. Post-apply: drawer closes, table row updates, Reviewed by/at columns populate, toast shown.

**Reclassification (reversal):**
- Open any classified thread — drawer shows radio pre-selected to current status
- Admin changes radio → Apply updates enables → click → reclassification saved, audit entry created, risk score adjusted
- No separate reversal modal needed — same pattern handles first-time marking and reclassification

---

## Open issues

1. **[PM] VEP branching scope.** Strategy recommends linear VEPs for v1 and disables branching in the editor. If the product decision is to support branching from day one, the conversation script editor must be redesigned as a full tree editor (significantly higher complexity). Do not start screen design on VEP authoring until this is confirmed.

2. **[Both] Approver role RBAC.** Strategy assumes a configurable "Red Team Approver" role. If this requires a new permission level not in the current Dune RBAC model, it is a blocking eng dependency. Must be confirmed before the Review + Request Start step is finalized.

3. **[Eng] Voice channel in v1.** Strategy assumes voice is a "human-executed step" — the platform provides a script guide for the operator, but does not initiate or record the call. If automated voice call orchestration is in scope for v1, the Attack node for Voice must be redesigned as a fully configurable step (similar to SMS node but with audio/script parameters).

4. **[PM] Complicity auto-suggestion.** Strategy includes a "system-suggested complicity flag" as an optional enhancement. This requires NLP/keyword detection on employee responses. If this is in scope for v1, confirm the detection model before designing the flag display. If out of scope, remove from thread detail.

5. **[PM] Dashboard data contracts.** The Dashboard screen is already designed. Before dev handoff, confirm: what time window does "recent attacks" cover, what metrics are shown, and what is the data refresh cadence.

6. **[Both] Channel provider availability.** WhatsApp and Viber nodes in the attack editor are gated by tenant configuration. Before launch, the channel provisioning flow (how an admin enables WhatsApp for their tenant) must be designed. Flag as a Settings-level dependency.

---

## Next design actions

1. **Resolve VEP branching scope with PM** before designing the VEP creation form. This is the highest-leverage decision in the entire platform — it determines whether the editor is a simple form or a full graph editor.
2. **Confirm approver RBAC model with Eng** before designing Step 6 of the campaign wizard.
3. **Design the AEP Library section first** — it has the fewest unresolved dependencies and establishes the pattern for the Attack Library.
4. **Design the conversation thread detail and complicity marking** — this is the most novel UI in the platform and the highest risk for HR/legal misuse. Get it right before anything else in Conversation Management.
5. **Scope the node-based editor with Eng** — confirm linear-sequence-only constraint for v1 and define the canvas interaction model (drag-to-reorder, click-to-configure) before opening Figma.
6. **Review the Stillsuit DS v2 token set** for any new color/feedback tokens needed for the "Complicit" outcome state — risk score badges and conversation status badges will need new semantic tokens if "complicit" is not covered by existing risk color tokens.
