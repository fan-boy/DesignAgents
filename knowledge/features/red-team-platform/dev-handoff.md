# Dev Handoff — Red Team Platform
Dune Security · Engineering Handoff · Last updated: 2026-05-13

---

## Feature summary

The Red Team Platform enables security admins to run active, multi-channel social engineering campaigns against their organization's employees — going beyond passive one-shot phishing simulation to full adversarial tradecraft. Admins build attack flows inline using a node-based editor embedded in the campaign wizard, select Adversary Emulation Pathways (AEPs), configure campaigns with scheduling granularity, submit them for approval, and review employee conversation threads post-activation to classify outcomes as complicit or non-complicit. Complicity classifications drive risk score updates and remediation rule triggers. The platform is organized into five sections under a new top-level "Red Team" nav item: Dashboard, AEP Library, Attack Library, Campaigns, and Conversations.

---

## Scope

### In scope (v1)

- Top-level "Red Team" nav item with five sub-sections (Dashboard, AEP Library, Attack Library, Campaigns, Conversations)
- AEP Library: browse Dune-seeded VEPs, create/edit/clone/archive customer VEPs, linear conversation script editor
- Attack Library: browse, create, edit, clone, archive attack sequences; node-based editor scoped to **linear sequences only** (A → B → C channel hops; no branching)
- Campaign wizard: 5-step flow (Details, Build Attack Flow, Audience, Remediation, Review + Request Start) — VEP selection and attack sequencing are combined into a single inline node editor step
- Request-start campaign model: campaign enters Pending Approval state on submit; requires Red Team Approver confirmation before activation
- Channel support: SMS (confirmed), Voice (human-logged only — no automated call initiation), WhatsApp (tenant-provisioned), Viber (tenant-provisioned)
- Audience selection: groups, departments, risk cohorts, CSV upload — inherits smishing audience selector component
- Phone coverage model: inherits smishing coverage drawer
- Scheduling: start date, allowed days of week, start time, end time, timezone — day-of-week selector is new (not in smishing)
- Compliance acknowledgment checkbox at campaign submission
- Remediation rule builder: inherits smishing rule builder, extended for complicity outcome trigger
- Conversation management: cross-campaign thread table, thread detail with full transcript, complicity/non-complicit marking with confirmation, marking reversal
- Risk score update on complicity marking (integration with existing risk scoring system)
- Audit log entry on every complicity marking and reversal

### Out of scope (v1)

- Branching VEP decision trees (VEPs are linear sequences only)
- Automated voice call initiation and transcription (voice is human-logged)
- VEP-to-attack channel compatibility enforcement beyond a warning (hard block deferred)
- System-automated complicity detection (NLP/keyword flagging is optional enhancement, not confirmed)
- Cross-section campaign view combining Red Team + smishing + email phishing campaigns
- Red Team mobile app / mobile-first experience
- Test send for red team campaigns (not applicable — real conversations replace test sends)
- Approval notification outside of in-app + email (Slack, etc. deferred)

---

## Navigation architecture

### Change required
A new top-level nav item **"Red Team"** must be added to the global side-nav. This item expands to reveal five sub-nav items using the existing expandable section pattern (Stillsuit DS v2 side-nav).

### Sub-nav items (in order)
1. Dashboard
2. AEP Library
3. Attack Library
4. Campaigns
5. Conversations

### Default landing
Clicking "Red Team" collapses to show the sub-nav and navigates to **Dashboard** (first sub-item).

### Conversations badge
The "Conversations" sub-nav item must display a **count badge** showing the number of threads in "Pending Review" status across all active campaigns. Badge updates in real time (or on page load with a refresh interval). Badge is hidden when count is zero.

### Routes

| Section | Route |
|---|---|
| Dashboard | `/red-team` |
| AEP Library | `/red-team/aep-library` |
| AEP detail (drawer, no route change) | Opens over `/red-team/aep-library` |
| Attack Library | `/red-team/attack-library` |
| Attack Create/Edit | `/red-team/attack-library/new` / `/red-team/attack-library/:id/edit` |
| Campaigns | `/red-team/campaigns` |
| Campaign Create (wizard) | `/red-team/campaigns/new` |
| Campaign Detail | `/red-team/campaigns/:id` |
| Conversations | `/red-team/conversations` |
| Conversation Thread | `/red-team/conversations/:threadId` |

---

## Section 1: Dashboard

**Status:** Already designed. Document contract only.

### Data contracts (confirm with Eng before handoff)
- Time window for "recent attacks": confirm with PM (suggested: last 14 days)
- Metrics displayed: number of campaigns active, employees contacted, complicit outcomes, pending reviews
- Data refresh cadence: on page load; background polling interval TBD
- Entry points to Campaigns and Conversations from dashboard cards must deep-link to the correct filtered view

### Implementation notes
- "Create Campaign" quick action on dashboard routes to `/red-team/campaigns/new`
- Active campaign cards link to `/red-team/campaigns/:id`
- "Pending review" count on dashboard links to `/red-team/conversations?status=pending`

---

## Section 2: AEP Library

**Model:** Dune provides 2 generic AEPs available to all tenants. Customer-authored AEPs are not self-serve — admins request a new AEP from Dune. The library grows only as Dune fulfills requests.

### Screen: AEP Library list

**DS components:**
- `PageHeader` — title "Adversary Emulation Pathways" + "Request AEP" button (top right)
- `Card / md` — one per AEP (grid layout, 2-column)
- `Badge` — adversary method, difficulty, channel compatibility
- `EmptyState` — if no AEPs are seeded (edge case)
- `Drawer / 480px` — AEP detail (opens on card click or "View details")

**Layout:** 2-column card grid below the page header. "Request AEP" button top-right of the header (ghost or secondary style — not primary, since it exits the browse flow).

**Card content (per AEP):**

| Element | Notes |
|---|---|
| AEP ID | Muted label, e.g. "AEP-001" |
| AEP name | Bold title, e.g. "Impersonated IT Support" |
| Adversary method | Badge, e.g. "Authority-based" |
| Difficulty | Badge — Easy / Medium / Hard |
| Channel compatibility | Chip row — SMS / Voice / WhatsApp / Viber |
| Description | 1–2 sentence plain-language summary of the scenario |
| "View details" | Ghost button — opens detail drawer |

**Scale trigger:** At 5+ AEPs, migrate from card grid to a filterable table (Adversary Method filter + search by title). Design the detail drawer now; it will work for both patterns.

**States:**

| State | Handling |
|---|---|
| Loading | 2 skeleton cards |
| Empty | "No AEPs are available for your account. Contact Dune Security." — no self-serve CTA |
| AEP used by active campaign — detail drawer | Read-only; no actions beyond "Close" |

---

### Panel: AEP detail drawer (480px)

Opens from card "View details." Read-only — no edit actions in v1 (Dune-managed content).

**Header:**
- AEP name (bold title) + X close
- Divider

**Metadata row (below divider):**
- ID — e.g. "AEP-001"
- Adversary Method — e.g. "Authority-Based"

**Workflow Steps section:**
- Section label: "Workflow Steps"
- Muted rounded card containing a bullet list of the AEP's sequential tactics (plain language), e.g.:
  - Claim to be IT/Security doing a routine audit
  - Build trust by saying it's management-approved
  - Ask what systems and tools they use
  - Push for specific access levels and permissions
  - Apply pressure if resisted ("your manager approved this")
  - Fall back to asking for basic info if they won't share everything

**Branching Logic section:**
- Section label: "Branching Logic"
- Muted rounded card containing:
  - Method: [short description of core approach]
  - Flow: [linear narrative of the attack flow, e.g. "IT audit claim → Management approved → List your tools → What's your access level → Pressure if needed → Accept any info"]
  - Pivots: [comma-separated or bulleted pivot rules, e.g. "Curious → Explain more | Hesitant → Add pressure | Soft no → 'It's mandatory' | Silent → 'This is urgent'"]

**Outcome section:**
- Section label: "Outcome"
- Tab bar: **Complicit** | **Non-Complicit** | **Undetermined** | **No Response**
- Below tab bar: muted card with bullet list of criteria for the selected outcome tab
  - Example for Complicit: "Target provides system names, access levels, tool list, or admin capabilities"
  - Example for Non-Complicit: "Target refuses to share any access details and verifies through official channels"
  - Example for Undetermined: "Target engages but does not provide or deny actionable information"
  - Example for No Response: "Target does not reply to any message in the sequence"

**Footer:** Single "Close" button — no clone/edit actions in v1.

---

### Flow: Request AEP

Triggered by "Request AEP" button on the library page.

**Pattern:** Modal (max 560px) — a short form, not a full-page wizard.

**Form fields:**

| Field | Component | Notes |
|---|---|---|
| AEP name / title | Input / Text | What should this AEP be called? Required. |
| Scenario description | Textarea / md | Describe the social engineering scenario you want to simulate. Max 500 chars. Required. |
| Target behavior | Textarea / md | What does employee complicity look like? What would a compromised employee do or say? Max 300 chars. Optional. |
| Urgency | Select | Standard / High — affects Dune's fulfillment queue |

**Footer:** "Cancel" (ghost) + "Submit request" (primary)

**Post-submit state:** Modal replaced with success message: "Your AEP request has been submitted. Dune Security will follow up at [admin email] within 5 business days."

**States:**

| State | Handling |
|---|---|
| Form incomplete | Submit disabled until required fields filled |
| Submit in progress | Submit button shows spinner; fields disabled |
| Submit error | Inline error below form: "Request could not be submitted. Try again or email support@dune.security." |

---

## Section 3: Attack Library + Node-Based Editor

### Screen: Attack Library list

**DS components:**
- `Table`
- `Button / Primary / md` — "Create Attack"
- `Badge strip` — channel icons per attack
- `EmptyState`

**Table columns:**

| Column | Type | Notes |
|---|---|---|
| Attack name | Text | |
| Channels | Badge strip | Channel icons in sequence order |
| Steps | Number | Count of nodes |
| Status | Badge | Draft / Active |
| Last modified | Date | |
| Actions | Menu | Edit / Clone / Archive / Preview flow |

**Preview flow action:** Opens a 480px drawer showing the attack sequence as a static node diagram (read-only canvas). Nodes shown as cards in horizontal sequence with arrows.

**States:**

| State | Handling |
|---|---|
| Loading | Skeleton rows |
| Empty | "No attack sequences yet. Build your first attack using the sequence editor." + "Create Attack" CTA |
| Archive — attack in active/pending campaign | Hard block: "This attack is used by [N] campaigns. Archive or re-assign those campaigns before deleting." |

---

### Screen: Attack node-based editor (new pattern — DS review required)

**Layout:**
- **Left panel (240px):** Channel node palette
- **Center canvas:** Attack sequence (horizontal, left-to-right)
- **Right: Node configuration drawer** (480px, opens on node click)
- **Top toolbar:** Attack name (inline editable) + Status badge + "Save Draft" + "Save & Activate" + Back button

**Channel node palette (left panel):**

Each channel is shown as a draggable chip:

| Channel | Icon | Available condition |
|---|---|---|
| SMS | SMS icon | Always available |
| Voice | Phone icon | Always visible; "human-executed" label in v1 |
| WhatsApp | WhatsApp icon | Visible always; locked if tenant not provisioned |
| Viber | Viber icon | Visible always; locked if tenant not provisioned |

Locked state: greyed chip + lock icon + tooltip on hover: "This channel is not configured for your organization. Contact your admin to enable [Channel]."

**Canvas:**
- v1: nodes rendered in a single horizontal row, left-to-right
- Each node is a card (approx 180×120px):
  - Channel icon (top left)
  - Channel name
  - Message preview (truncated, 2 lines) OR "Human-executed" label for Voice
  - Delay label: "After X min/hr/day"
  - Edit icon (opens configuration drawer)
  - Delete icon (removes node; confirmation if node has content)
- Nodes connected by right-to-left arrows
- "Add step →" button after the last node
- "Add branch" button: visible but **disabled** with tooltip: "Branching attack paths are coming in a future update."
- Drag-to-reorder: nodes can be reordered by drag within the sequence. Keyboard alternative: up/down arrow keys on focused node (accessibility requirement).

**Node configuration drawer (480px):**
- Channel: read-only label
- For SMS / WhatsApp / Viber:
  - Message body: textarea + character counter (same limits as smishing: 160 GSM-7 / 70 Unicode for SMS)
  - Variable tokens: [First Name] [Company] [Department] chips
- For Voice (v1 human-executed):
  - Talking points: textarea. Label: "Operator script guide". Helper: "Notes for the person making this call. This is not sent to the employee."
  - No character limit
- Delay before this step:
  - Number input + unit selector (Minutes / Hours / Days)
  - For the first node: "Send immediately" — delay field hidden
- Step label: optional text field (internal name for this node)

**States:**

| State | Handling |
|---|---|
| Empty canvas (no nodes) | "Drag a channel from the left panel to start building your attack." — instructional empty state |
| Unsaved changes on navigate away | Confirmation modal: "You have unsaved changes to this attack. Discard or keep editing?" — "Discard" / "Keep editing" |
| Save & Activate with no nodes | Blocked: "Add at least one step before activating." |
| Locked channel node dragged onto canvas | Drag action is disabled for locked chips; cursor: not-allowed |
| Node deleted with 8+ nodes (canvas overflows) | Canvas scrolls horizontally; no truncation |

---

## Section 4: Campaigns

### Screen: Campaign list

**DS components:**
- `Table`
- `Button / Primary / md` — "Create Campaign"
- `Badge` — status (see State Matrix below)
- `EmptyState`

**Table columns:**

| Column | Type | Notes |
|---|---|---|
| Name | Text link | Links to Campaign detail |
| Status | Badge | See State Matrix |
| AEP | Text | AEP name used in this campaign |
| Channels | Badge strip | Channel icons from the attack flow |
| Audience | Text | Group name + count |
| Start date | Date | |
| Conversations | Number | Count of threads |
| Actions | Menu | View / Edit (Draft only) / Withdraw Request (Pending Approval) / Cancel (Active) / Archive |

**States:**

| State | Handling |
|---|---|
| Loading | Skeleton rows |
| Empty | "No red team campaigns yet." + "Create Campaign" CTA |

---

### Screen: Campaign wizard

**DS component:** Wizard pattern (Stillsuit DS v2). Step bar at top showing 5 steps: Campaign Setup / Build Attack Flow / Select Users & Groups / Remediation / Review & Confirm. Back navigation preserves all form state including node canvas state.

#### Step 1: Campaign Details

**Fields:**

| Field | Component | Validation |
|---|---|---|
| Campaign name | `Input / Text / md` | Required |
| Start date | `DatePicker` | Must be today or future |
| Allowed sending days | Day-of-week multi-select (new component — see below) | Minimum 1 day required |
| Start time | `TimePicker` + `Select / Timezone` | Required |
| End time | `TimePicker` | Must be after start time |

**New component: Day-of-week multi-select**
Seven toggle buttons (Mon / Tue / Wed / Thu / Fri / Sat / Sun), multi-selectable. Default: Mon–Fri selected. This pattern does not exist in smishing — flag for DS review. Nearest analog: `CheckboxGroup` rendered as toggle chips.

**Validation:**
- Start date in the past: inline error on date field
- End time ≤ start time: inline error on end time field: "End time must be after start time."
- No days selected: inline error: "Select at least one allowed sending day."

---

#### Step 2: Build Attack Flow

**Role:** Admin configures the full attack sequence for this campaign — which AEP drives the conversation, how the initial contact is made, and what happens when an employee replies or ignores. This step replaces the old separate VEP Selection and Attack Selection steps.

**Layout:** Full-width node editor canvas with a dotted-grid background. Nodes are connected by arrows. Flow reads top-to-bottom. A small node palette appears at the top of the canvas.

**Node types:**

| Node | Description |
|---|---|
| Initial Contact | The first message sent to the employee. Admin selects channel (SMS / WhatsApp / Telegram) and writes the opening message. Every flow starts with exactly one of these. |
| AEP | Represents the AI taking over the conversation. Shows selected AEP name and method. Placed on all "If replied" branches — read-only, admin selects AEP by tapping the node. |
| Nudge | A follow-up message sent after a configurable delay (in days) when the employee has not replied. Admin selects channel and writes the message. Can be chained (nudge → nudge). |
| End | Terminates a branch. System stops sending to this employee. Auto-generated; cannot be deleted, only repositioned. |

**Default flow on step load (pre-configured):**

```
[Initial Contact]  ← admin writes opening message, picks channel
        |
   ┌────┴─────────────────────┐
   ↓                          ↓
[If replied]          [No reply after N days]
[AEP Active]               |
(AI handles            [Nudge]  ← admin writes follow-up message
 conversation)              |
                       ┌────┴──────────────────┐
                       ↓                       ↓
                  [If replied]           [No reply]
                  [AEP Active]             [End]
```

**AEP node — detail:**
- Displays: AEP name ("Information Gathering"), AEP ID ("AEP-001"), adversary method badge
- Tap to open AEP selector: shows the 2 available AEPs as cards; admin picks one
- Cannot be removed from "If replied" branches — it is always the terminal node on that branch

**Initial Contact node — detail:**
- Channel selector: SMS (default) | WhatsApp | Telegram — rendered as pill chips
- Message composer: textarea, placeholder "Write the opening message…"
- Character limit displayed inline

**Nudge node — detail:**
- Delay field: "Send after [N] days of no reply" — number input, default 3
- Channel selector: same as Initial Contact
- Message composer: textarea

**"+ Add nudge" affordance:**
- A dashed-border "+ Add nudge" card appears below the last nudge on the "No reply" branch
- Clicking it appends a new Nudge node with default delay + empty message
- Maximum 3 nudges per flow in v1

**Branch labels:**
- "If replied" — auto-labeled, not editable
- "No reply after [N] days" — the N value is set on the Nudge node; the branch label updates to reflect it

**States:**

| State | Handling |
|---|---|
| Loading | Skeleton canvas with placeholder nodes |
| No AEP selected | "Continue" disabled; inline prompt on AEP node: "Tap to select an AEP" |
| Initial Contact message empty | "Continue" disabled; inline error on node: "Add an opening message before continuing." |
| Nudge message empty | Nudge node shows inline error; "Continue" disabled |
| No AEPs available | AEP node shows error state: "No AEPs available. Contact Dune Security." — Continue blocked |
| Channel not configured for tenant | Channel chip shown locked in node selector; tooltip: "This channel is not configured for your organization." |

**Validation on Continue:**
- Initial Contact must have a channel selected and a non-empty message
- All added Nudge nodes must have a non-empty message
- At least one AEP must be selected

**Future extensibility note (implementation):** The branch model (replied / no reply) and node types are designed to extend to hybrid multi-channel attacks. In v1, the "If replied" branch always terminates at AEP. In future, an additional channel hop could be inserted before the AEP node for multi-channel escalation (e.g., SMS → Voice → AEP). Build the node renderer to support this without requiring a canvas rewrite.

---

#### Step 3: Audience

**Inherited entirely from smishing wizard Step 1.** Same components, same behavior, same coverage drawer.

**Components (inherited):**
- Audience searchable dropdown (groups / departments / locations / risk cohorts)
- CSV upload toggle
- Phone coverage indicator (progress bar + count)
- "View coverage gaps →" link → 480px coverage drawer
- Cooldown warning callout (if group was recently targeted)

**Hard block condition:** 0% phone coverage — Continue disabled; inline error with resolution path.

---

#### Step 4: Remediation

**Inherited from smishing remediation step, extended for complicity outcome.**

**Rule cards (pre-built, toggle ON/OFF):**
- "If employee is marked complicit → Assign [module selector] training"
- "If employee is marked complicit → Notify manager"
- "If employee engages with 2+ red team campaigns in 90 days → Notify manager"
- "If employee is marked complicit → Create ServiceNow ticket" *(requires ServiceNow integration)*

**Trigger label:** "Rules for Red Team campaigns — triggered when an admin marks an employee as complicit."

**RBAC gate:** ServiceNow rule card disabled with tooltip if integration not configured: "Enable ServiceNow integration in Settings to use this rule."

---

#### Step 5: Review + Request Start

**Components:**
- Summary cards (one per prior step): Campaign details / Attack flow / Audience + coverage / Remediation rules
- Coverage warning callout (if applicable): `color/feedback/warning` — "N members will not receive this campaign (no phone number on file). [View list]"
- **Approver configuration warning** (conditional, `color/feedback/danger`): "No Red Team Approver is configured for your organization. Go to Settings → Red Team → Configure Approver before requesting start." — Request Start CTA disabled until resolved.
- Compliance acknowledgment checkbox: "I confirm that [Company] has informed employees that Dune Security may conduct simulated security exercises, including multi-channel social engineering simulations, as part of its security training program, and that [Company] has a lawful basis for this activity."
- Primary CTA: **"Request Campaign Start"** — `Button / Primary / md`; disabled until: (a) compliance checkbox checked AND (b) approver is configured
- Secondary: **"Save as Draft"** — `Button / Ghost / md`

**On submit:**
- Campaign status → "Pending Approval"
- Approver receives notification (in-app + email)
- Admin sees toast: "Campaign start requested. Your Red Team Approver will be notified."
- Redirect to campaign detail (Pending Approval state)

---

### Screen: Campaign detail

**DS components:**
- `PageHeader` — name + badges + actions menu
- `StatCard` row — 6 cards
- `TabBar` — Overview | Conversations
- `Table` — Conversations tab
- `Timeline chart` — Overview tab

**Header:**
- Campaign name (H1)
- "Red Team" channel badge
- Status badge (see State Matrix)
- Actions menu: Cancel Campaign (Active only) / Archive (Completed/Cancelled) / Edit (Draft only)

**Stats row:**

| Metric | Description |
|---|---|
| Targeted | Total audience count |
| Contacted | Employees who received at least one attack message |
| Responded | Employees who replied to at least one message |
| Complicit | Marked complicit by admin |
| Non-Complicit | Marked non-complicit by admin |
| Pending Review | Threads awaiting admin review |

**Conversations tab:** Same table as the Conversations section (Section 5), filtered to this campaign.

**Pending Approval state:**
- Approver name callout: "Awaiting approval from [Approver Name]."
- "Withdraw Request" action available to campaign creator
- Edit is not available in Pending Approval state

**Approved state:**
- "Campaign approved. Activates on [start date] at [start time]." callout
- Edit is not available in Approved state
- No Withdraw action (approval already granted; admin can cancel after activation begins)

---

## Section 5: Conversation Management

### Screen: Conversations table (cross-campaign)

**DS components:**
- `Table` — with sort/filter
- `FilterBar` — status / campaign / department / channel / date range
- `Badge` — thread status
- `Avatar + text` — reviewed-by column

**Table columns:**

| Column | Type | Notes |
|---|---|---|
| Employee | Text + avatar | Name + department |
| Campaign | Text link | Campaign name |
| First contacted | Date | |
| Last message | Date + preview | Truncated message preview |
| Channels | Badge strip | Sequence of channel icons used in this thread |
| Status | Badge | Pending Review / Complicit / Non-Complicit / No Response / Opted Out |
| Reviewed by | Avatar + name | Admin who classified the thread; empty for Pending Review |
| Reviewed at | Date + time | Timestamp of classification; empty for Pending Review |
| Actions | Inline | "Review" button |

**Default filter:** Status = "Pending Review"

**Bulk actions:** Available when rows are selected. "Mark selected as…" → Complicit / Non-Complicit. Requires confirmation modal.

**States:**

| State | Handling |
|---|---|
| Loading | Skeleton rows |
| Empty (no pending) | "No conversations pending review." — no CTA needed |
| Empty (filtered) | "No conversations match your filters." + "Clear filters" link |

---

### Screen / Panel: Conversation thread detail

**DS component:** 480px right-anchored drawer. Triggered by "Review" on any table row.

**Drawer header:**
- Title: "[Employee Name] conversation history"
- Close button (X) — top right; unsaved changes prompt on close if classification is in progress

**Metadata row (below header, above transcript):**
- Start Time — ISO timestamp of first attacker message
- End Time — ISO timestamp of last message in thread
- Phone Number — masked (e.g., "+1 (415) ••• 8821")
- Recommended Status — system-derived badge: `FAIL` (`color/negative`) or `PASS` (`color/positive`) + category tag (e.g., "Sensitive Disclosure", "Wire Transfer") — visible only when system-suggested flag is generated

**Conversation transcript:**
- Chronological exchange, oldest first
- Attacker messages: left-aligned, muted background, label "Attacker · [AEP Name] · [timestamp]"
- Employee messages: right-aligned, white background, label "[Employee First Name] · [timestamp]"
- For Voice nodes: rendered as a system event row (not a message bubble): "Voice call — [date/time] — Logged by: [Admin Name]. Notes: [operator notes]"

**AEP step indicator:**
- Below each attacker message: muted label "AEP: Exchange N of N — [Node label]"
- Terminal node indicator: "Terminal node — employee engagement signal"

**System-suggested complicity flag (if in scope):**
- Callout above the classify section: "This response may indicate engagement: '[excerpt]'" — with "Accept" / "Dismiss" buttons
- Accepting pre-selects "Complicit" radio; dismissing hides the suggestion for this thread

**Classify this conversation (section below transcript):**
- Section label: "Classify this conversation"
- Radio group:
  - ○ Complicit
  - ○ Non-complicit
- No default selection for Pending Review threads
- For already-marked threads: pre-selected to current classification; changing the selection enables the "Apply updates" CTA

**Reporting section (below classify):**
- Checkbox: "Send report to internal team"
- Helper text: "Includes conversation, classification, and optional notes."
- Notes textarea (visible when checkbox is checked): placeholder "Add optional notes…", max 500 chars

**Drawer footer (sticky):**
- Left: `Button / Ghost / md` — "Cancel" — closes drawer without saving; no state change
- Right: `Button / Primary / md` — "Apply updates" — disabled until a classification radio is selected (or changed from existing); confirms and saves

**"Apply updates" behavior:**
- Marking Complicit → triggers risk score update + remediation rules. No separate confirmation modal. The radio selection + primary CTA pattern replaces the destructive modal.
- Marking Non-Complicit → no risk impact. No confirmation modal.
- Changing an existing marking → same behavior as first-time marking. Reversal is logged in audit trail automatically.

**Post-apply state:**
- Drawer closes
- Table row Status badge updates immediately
- "Reviewed by" and "Reviewed at" columns populate with current admin + timestamp
- Toast: "Conversation classified as [Complicit / Non-Complicit]."

**States:**

| State | Handling |
|---|---|
| Thread loading | Skeleton in transcript area; metadata row shows placeholder dashes |
| Thread with no employee reply | Transcript shows only attacker messages; below transcript: "No reply received from this employee." Classify section still visible; admin may mark Non-Complicit explicitly. |
| Thread with only one short exchange | Inline guidance above classify section: "This conversation has only one exchange. Ensure you have sufficient signal before marking." — informational, not a block |
| Already marked Complicit | Radio pre-selected to "Complicit"; footer "Apply updates" disabled until selection changes; audit entry shown below classify section: "Classified as Complicit by [Admin Name] on [date]" |
| Already marked Non-Complicit | Same pattern; "Non-Complicit" pre-selected |
| Voice log entry | System event row: "Voice call — [date/time] — Logged by: [Admin Name]. Notes: [text]" |
| Reporting checkbox checked | Notes textarea expands inline below the checkbox |
| Apply updates in progress | "Apply updates" shows loading spinner; radio and checkbox disabled; cancel disabled |
| Apply updates error | Toast error: "Could not save classification. Try again." Drawer stays open; state preserved |

---

## State matrix

### Campaign statuses

| Status | Color token | Description | Available actions |
|---|---|---|---|
| Draft | `color/neutral` | Wizard incomplete or saved before submission | Edit, Delete, Resume wizard |
| Pending Approval | `color/feedback/warning` | Request submitted, awaiting approver | View, Withdraw Request |
| Approved | `color/feedback/info` | Approved, queued for start date | View |
| Active | `color/positive` | Campaign is live, attacks being sent | View, Cancel Campaign |
| Completed | `color/neutral/muted` | End date reached, campaign closed | View, Archive |
| Cancelled | `color/negative/muted` | Force-cancelled by admin | View, Archive |

### Thread (conversation) statuses

| Status | Color token | Description | Reviewer attribution |
|---|---|---|---|
| Pending Review | `color/feedback/warning` | Employee replied; admin has not reviewed | "Reviewed by" and "Reviewed at" columns empty |
| Complicit | `color/negative` | Admin marked as complicit | "Reviewed by" = admin name; "Reviewed at" = classification timestamp |
| Non-Complicit | `color/positive` | Admin marked as non-complicit | Same as Complicit |
| No Response | `color/neutral/muted` | Employee received attack but did not reply | Columns empty |
| Opted Out | `color/neutral` | Employee replied STOP; removed from send queue | Columns empty |

### AEP statuses

| Status | Color token | Description |
|---|---|---|
| Draft | `color/neutral` | Incomplete; cannot be selected in campaign wizard |
| Active | `color/positive` | Available for selection in campaigns |

### Attack statuses

Same as AEP: Draft / Active, same color tokens.

---

## RBAC and permissions

### Role matrix

| Action | Security Admin | Red Team Approver | SOC/IR Lead | View-Only Admin | People Manager |
|---|---|---|---|---|---|
| View Red Team section | ✅ | ✅ | ✅ | ✅ | ❌ |
| Create / edit VEPs | ✅ | ✅ | ❌ | ❌ | ❌ |
| Clone Dune Library VEPs | ✅ | ✅ | ❌ | ❌ | ❌ |
| Create / edit attack sequences | ✅ | ✅ | ❌ | ❌ | ❌ |
| Create / configure campaigns | ✅ | ✅ | ❌ | ❌ | ❌ |
| Request campaign start | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Approve campaign start** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **Reject campaign start** | ❌ | ✅ | ❌ | ❌ | ❌ |
| Cancel active campaign | ✅ (own campaigns) | ✅ | ❌ | ❌ | ❌ |
| View conversation threads | ✅ | ✅ | ✅ | ✅ (no PII) | ❌ |
| **Mark complicit / non-complicit** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Reverse complicity marking** | ✅ (own markings) | ✅ | ❌ | ❌ | ❌ |
| View employee PII in threads | ✅ | ✅ | ✅ | ❌ | ❌ |
| Export conversation data | ✅ | ✅ | ✅ | ❌ | ❌ |
| Configure Red Team Approver role | Super Admin only | | | | |

### Disabled state specs

| Action | Disabled condition | Tooltip copy |
|---|---|---|
| Request Campaign Start | Compliance checkbox unchecked | "Confirm the compliance statement before requesting start." |
| Request Campaign Start | No approver configured | "No Red Team Approver is configured. Go to Settings → Red Team → Configure Approver." |
| Request Campaign Start | 0% audience coverage | "No phone numbers on file for the selected audience. Upload a CSV or configure HRIS sync." |
| Save & Activate (VEP) | Required field incomplete | "Complete all required fields before activating." |
| Save & Activate (Attack) | No nodes added | "Add at least one step before activating." |
| Create VEP (Custom tab) | View-only admin | "You don't have permission to create VEPs. Contact your administrator." |
| Mark Complicit / Non-Complicit | View-only admin or SOC/IR | "You don't have permission to mark conversations. Contact your administrator." |
| Archive VEP / Attack | In use by active campaign | "This [VEP/attack] is used by [N] active campaigns." |
| Approve campaign | Security Admin (not Approver) | "Only designated Red Team Approvers can approve campaigns." |

### PII handling in threads
- View-only admins see conversation threads with employee names replaced by "Employee [ID]" — no name, department visible
- SOC/IR leads see full PII (confirmed in role matrix above — **confirm with PM: [Blocks build]**)

---

## API contract — new events and signals

These are the new behavioral signals the Red Team platform must emit. Engineering must confirm exact event schemas before build.

| Event name | Trigger | Properties |
|---|---|---|
| `red_team_campaign_created` | Campaign saved as Draft | campaign_id, admin_id, attack_id, vep_id |
| `red_team_campaign_start_requested` | Admin clicks "Request Campaign Start" | campaign_id, admin_id, approver_id |
| `red_team_campaign_approved` | Approver approves | campaign_id, approver_id |
| `red_team_campaign_rejected` | Approver rejects | campaign_id, approver_id, reason |
| `red_team_campaign_activated` | Start date reached | campaign_id |
| `red_team_attack_sent` | Channel node fires for an employee | campaign_id, employee_id (hashed), channel, node_index |
| `red_team_employee_replied` | Employee reply received | campaign_id, employee_id (hashed), channel, node_index |
| `red_team_complicit_marked` | Admin marks complicit | campaign_id, thread_id, employee_id (hashed), admin_id, timestamp |
| `red_team_noncomplicit_marked` | Admin marks non-complicit | campaign_id, thread_id, employee_id (hashed), admin_id, timestamp |
| `red_team_complicit_reversed` | Admin reverses complicit marking | campaign_id, thread_id, employee_id (hashed), admin_id, reason, timestamp |
| `red_team_campaign_completed` | End date reached | campaign_id, complicit_count, non_complicit_count, no_response_count |
| `red_team_campaign_cancelled` | Admin force-cancels | campaign_id, admin_id |

**Risk score integration:** `red_team_complicit_marked` must trigger a risk score update for the employee. The exact delta weighting for complicity vs. smishing click/submit signals must be confirmed with PM. **[Blocks build]**

---

## New DS patterns (require DS review before build)

### 1. Two-panel AEP builder (prompt editor + live chat simulator)
**What:** Full-page two-panel layout. Left: scenario prompt editor with refinement instructions. Right: live chat interface where admin plays the role of the target employee and the AEP responds via LLM.
**Closest existing pattern:** None in DS. Nearest analog: split-pane code editors or AI playground interfaces.
**Requirements for DS review:** Panel resize/collapse behavior; chat bubble rendering (admin right, AEP left); typing indicator during LLM response; refinement instruction list (repeatable fieldset); "Reset conversation" action; content safety error state on activation; empty/instructional state before first test; mobile/tablet layout (stacked panels).

### 2. AEP preview drawer (live demo chat)
**What:** 480px drawer with a live chat interface for previewing a Dune Library AEP. Admin can interact with the AEP in real time to evaluate its behavior before cloning.
**Closest existing pattern:** Existing 480px drawer + real-time chat. Chat component itself may need to be built.
**Requirements for DS review:** Left/right message bubble layout; typing indicator; "Reset conversation" button; drawer height management for long conversations (scrollable transcript); read-only treatment for Dune Library AEPs (cannot save changes, only demo).

### 3. Node-based canvas editor (linear attack sequence)
**What:** Drag-and-drop canvas for composing multi-channel attack sequences. Linear only in v1.
**Closest existing pattern:** None in DS.
**Requirements for DS review:** Canvas interaction model (drag to add, drag to reorder, click to configure); locked node treatment; "Add step" affordance; horizontal overflow handling; keyboard accessibility (arrow keys to navigate, Enter to open config, Delete to remove); empty canvas instructional state.

### 4. Day-of-week multi-select (toggle chip group)
**What:** Seven toggle chips for selecting allowed sending days.
**Closest existing pattern:** `CheckboxGroup` or `SegmentedControl` — neither maps exactly.
**Requirements for DS review:** Multi-select toggle behavior; default state (Mon–Fri selected); error state when none selected; mobile touch target sizing.

---

## Inherited components from smishing (no redesign needed)

| Component | Inherited from | Notes |
|---|---|---|
| Audience selector (searchable dropdown) | smishing wizard Step 1 | Used in Campaign wizard Step 3 — same behavior |
| Phone coverage indicator | smishing wizard Step 1 | Same progress bar + count component |
| Coverage drawer (480px) | smishing wizard Step 1 | Same drawer — shows members with missing numbers |
| CSV upload drawer | smishing wizard Step 1 | Same component |
| Cooldown warning callout | smishing wizard Step 1 | Same condition and copy pattern |
| Compliance acknowledgment checkbox | smishing wizard Step 7 | Copy updated for red team context |
| Remediation rule builder | smishing wizard Step 5 | Extended with complicity trigger; same rule card component |
| Module selector dropdown | smishing remediation | Same searchable dropdown |
| Schedule date/time picker + timezone | smishing wizard Step 4 | Same component; day-of-week selector is NEW |
| Wizard step bar (5 steps) | smishing wizard | Same DS wizard component; step count differs (5 vs 7) |

---

## Accessibility requirements

1. **Node-based canvas editor:** All node operations must be achievable without a mouse. Tab focus moves between nodes; Enter opens the config drawer; Delete key removes the focused node (with confirmation). Arrow keys reorder the focused node within the sequence. Add step button is keyboard-reachable.

2. **Conversation thread table:** Table rows must announce "Employee [Name], Campaign [Name], Status [Status]" to screen readers. Bulk selection checkboxes must have accessible labels that include the employee name.

3. **Complicity marking confirmation modal:** Focus must move to the modal on open. Tab order: "Cancel" → "Confirm". Escape key dismisses (equivalent to Cancel, not Confirm — this is a destructive action). Focus returns to the "Mark as Complicit" button on cancel; to the thread status badge on confirm.

4. **AEP chat simulator:** Chat input must be keyboard-accessible (Tab to focus, Enter to send). Screen reader must announce new AEP messages as they appear: "Attacker: [message text]." Typing indicator must be announced: "AEP is responding."

5. **Day-of-week toggle chips:** Each chip must have an accessible role of "checkbox" and announce its checked state. "Mon selected", "Tue not selected", etc.

6. **AEP preview drawer (live demo chat):** Chat messages must be announced in order by screen reader. Attacker messages annotated as "Attacker: [text]". Typing indicator announced as "AEP is responding."

7. **Status badges:** Never communicate status by color alone. Every badge must have a visible text label. Color token is supplemental.

8. **Complicit/Non-Complicit marking:** "Mark as Complicit" button uses `color/feedback/danger` background. Ensure the text label ("Mark as Complicit") remains legible against the danger background — check color/feedback/danger token contrast with white text (must be ≥ 4.5:1 for AA).

---

## Acceptance criteria

**Navigation**
1. Given any page in the app, when the user navigates to Red Team in the side-nav, then the Red Team section loads with Dashboard as the default sub-view.
2. Given there are threads in "Pending Review" status, when the user views the Red Team nav, then the "Conversations" sub-nav item shows a count badge with the correct pending count.

**AEP Library**
3. Given the VEP custom library is empty, when the user navigates to AEP Library → Custom, then the empty state shows "No custom VEPs yet" with two CTAs: "Browse Dune Library" and "Create VEP."
4. Given a Dune Library VEP, when the user clicks "Clone," then a copy is created in the Custom tab with source = "Custom" and the original is unmodified.
5. Given a VEP is used by an active campaign, when the user attempts to archive the VEP, then the action is blocked with an error message naming the campaign count.

**Attack Library**
6. Given the attack library is empty, when the user navigates to Attack Library, then the empty state includes a "Create Attack" CTA.
7. Given a tenant without WhatsApp provisioned, when the user opens the node editor, then the WhatsApp channel chip is visually locked and dragging it onto the canvas is prevented.
8. Given an attack sequence with unsaved changes, when the user navigates away, then a confirmation modal appears before navigation proceeds.

**Campaign wizard**
9. Given Step 5 of the campaign wizard, when no Red Team Approver is configured, then the "Request Campaign Start" button is disabled and a warning callout links to Settings.
10. Given the compliance acknowledgment checkbox is unchecked, when the user attempts to click "Request Campaign Start," then the button remains disabled.
11. Given 0% phone coverage for the selected audience, when the user reaches Step 3, then the "Continue" button is disabled and a resolution path (CSV upload / HRIS sync) is shown.
12. Given a valid campaign submission, when the user clicks "Request Campaign Start," then campaign status changes to "Pending Approval," the approver receives a notification, and the admin sees a success toast.
13. Given Step 2 of the campaign wizard, when the page loads, then the node canvas shows a pre-configured default flow: Initial Contact → (If replied: AEP Active) / (No reply after 3 days: Nudge → AEP Active / End).
14. Given the AEP node is unselected, when the admin tries to continue, then Continue is disabled and the AEP node shows "Tap to select an AEP".
15. Given a Nudge node with an empty message, when the admin tries to continue, then Continue is disabled and the nudge node shows an inline error.
16. Given the admin taps the AEP node, then a selector opens showing the available AEPs as cards; selecting one updates the node.
17. Given the admin clicks "+ Add nudge", then a new Nudge node is appended to the "No reply" branch with a default 3-day delay.
18. Given 3 nudge nodes already on the flow, then the "+ Add nudge" affordance is hidden.
19. Given a channel chip that is not configured for the tenant, when the admin tries to select it on any node, then the chip is locked and shows a tooltip explaining it is unavailable.

**Approver workflow**
13. Given a campaign in Pending Approval, when the Red Team Approver clicks "Approve," then campaign status changes to "Approved" and the admin receives a notification.
14. Given a campaign in Pending Approval, when the Red Team Approver clicks "Reject" with a reason, then campaign status returns to "Draft" and the admin receives a notification with the rejection reason.
15. Given a campaign in Pending Approval, when the admin clicks "Withdraw Request," then campaign status returns to "Draft."

**Conversation management**
16. Given an employee thread in "Pending Review," when the admin clicks "Mark as Complicit" and confirms, then the thread status changes to "Complicit," the employee's risk score is updated, and configured remediation rules trigger.
17. Given a thread marked "Complicit," when the admin clicks "Change marking" and confirms the reversal, then the thread status reverts to "Pending Review," the risk score adjustment is triggered, and the reversal is recorded in the audit log.
18. Given a thread with no employee reply, then the thread status must be "No Response," not "Pending Review."
19. Given an employee who replied STOP, when the system processes the reply, then the employee is immediately removed from the send queue, an opt-out record is created, and the thread status changes to "Opted Out."
20. Given a view-only admin, when they view a conversation thread, then the "Mark as Complicit" and "Mark as Non-Complicit" buttons are absent or disabled, and employee PII (name, department) is masked.

---

## Open questions

### [Blocks build]

- **[PM/Eng] Risk score delta for complicity.** What is the risk score impact of a complicity marking? Does it replace or augment the smishing click/submit model? This must be confirmed before `red_team_complicit_marked` can be wired to the risk scoring system. **Blocks:** Conversation management feature completion and risk score integration.

- **[Both] Red Team Approver RBAC role.** Does this require a new permission level in the Dune RBAC model, or can it be achieved by assigning a specific permission flag to an existing admin role? **Blocks:** Campaign wizard Step 5, approval flow, and approver notification system.

- **[Eng] Thread model for non-SMS channels.** For WhatsApp and Viber: how are inbound employee replies associated with the correct campaign thread? For Voice (human-logged): what is the data model for the operator's log entry? **Blocks:** Conversation management build for any channel other than SMS.

- **[PM] SOC/IR lead PII access in thread view.** The RBAC matrix above assumes SOC/IR leads can see full PII in conversation threads. Confirm this is correct, or specify what PII is redacted for SOC/IR. **Blocks:** RBAC implementation for the conversation thread detail screen.

- **[Eng] LLM infrastructure for AEP conversations.** Which LLM powers AEP conversations in production? Where is it hosted? What is the target response latency (suggested: under 3 seconds per message)? How are prompt injections from employee replies detected and blocked? **Blocks:** AEP chat infrastructure build (both production conversations and the chat simulator in the AEP builder).

- **[PM] Customer AEP authoring — launch vs. post-launch.** Is the two-panel AEP builder (prompt editor + chat simulator) in the initial launch scope, or does the product ship with Dune-seeded library only and customer authoring comes later? **Blocks:** AEP Library build scope and the AEP creation/edit form screen.

- **[PM] AEP prompt content guardrails.** What content safety check runs on Save & Activate? What is blocked (protected class language, illegal activity), what triggers a warning, what is always permitted? Must be defined before the content safety check in the AEP builder can be implemented. **Blocks:** AEP Save & Activate flow.

### [Nice to resolve]

- **[PM]** System-suggested complicity detection (NLP/keyword flagging): in scope for v1 or future? If in scope, confirm the detection model and what excerpt is surfaced in the callout.

- **[PM]** Dashboard data contracts: what time window for "recent attacks," what metrics, what refresh cadence?

- **[PM]** Allowed sending days + approval timing: if a campaign is approved on a non-allowed day, does it auto-activate on the next allowed day, or does the admin need to manually trigger activation?

- **[Eng]** Channel provider availability at launch: which tenants have WhatsApp and Viber provisioned from day one, and what is the provisioning flow?

- **[PM]** Complicity marking reversal: is reversal available to any Security Admin, or only to the admin who made the original marking (plus Super Admin)?

- **[Both]** Bulk complicity marking limit: is there a cap on how many threads can be bulk-marked in one action? (Suggested: confirm with Eng before building bulk action.)
