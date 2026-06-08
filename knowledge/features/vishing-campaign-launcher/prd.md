## Last updated
2026-06-08 — First full PRD written from confirmed design decisions, Red Team Campaign Launcher PRD, and AEP Library PRD. No Figma designs yet.

---

The Vishing Campaign Launcher extends the existing Red Team Campaign Launcher to support voice phishing (vishing) as a third adversarial channel alongside SMS and WhatsApp. Admins configure and request a vishing campaign through the same 8-step wizard used for text-based red team campaigns. Dune executes calls via managed VOIP infrastructure connected to the AEP library; call outcome events stream into the platform automatically. Voice AEPs are a new type in the AEP Library with voice-specific configuration. In v1, vishing campaigns are vishing-only — they cannot be combined with SMS or WhatsApp channels in the same campaign. Like all red team campaigns, admins request the campaign and Dune operators set it live; the admin cannot initiate delivery unilaterally.

---

## Voice AEPs in the AEP Library

Voice AEPs are created and managed in the same AEP Library accessed via **Red Teaming > AEP Library**. They are distinguished from text AEPs by a **Voice** channel badge on their library row and a **Channel Type** attribute on their detail page. Voice AEPs and text AEPs are non-interchangeable: a vishing campaign can only select a Voice AEP, and an SMS or WhatsApp campaign can only select a text AEP.

**Creating a Voice AEP**

When an admin clicks **New AEP**, the builder opens with a new **Channel Type** selector before any other fields: **Text** or **Voice**. Selecting Voice adapts both builder steps to voice-specific configuration. The two-step progress indicator remains identical: **① AEP Setup** and **② Test & Refine**.

**Step 1 — AEP Setup (Voice)**

The setup form contains the following fields under **General Details**:

**AEP Title** (required, text input) — the name used to identify this AEP in the library and campaign builder. Example placeholder: "Add an AEP title."

**Adversary Method** (required, chip selector, pick 1–2) — the psychological levers the caller persona uses. Options are identical to text AEPs: Authority, Urgency, Reciprocity, Curiosity, Scarcity, Familiarity. Severity level shown inline.

**Caller Identity** (required, structured inputs) — three sub-fields defining who the VOIP caller claims to be: **Caller Name** (e.g., "James from IT Security"), **Claimed Company or Team** (e.g., "Acme IT Support"), and **Claimed Role** (e.g., "Security Analyst"). These values are what Dune's VOIP system presents as the caller's identity during the call.

**Tone / Character** (required, chip selector, pick 1) — the dominant emotional register for the caller persona. Options: Urgent, Friendly, Authoritative, Casual, Concerned. The selected tone informs the AI's script generation and call delivery style.

**Target Context** (required, textarea) — a description of the employee population being called: their role, department, and organizational context. Same field as text AEPs.

**Script Outline** (required, structured textarea) — the talking points the AI caller persona follows. The field is structured as three labeled sections: **Opening** (how the call begins and the pretext established), **Core Ask** (the specific action the caller attempts to persuade the target to take), and **Closing** (how the caller handles success or exits the call). Placeholder per section: "Describe what the caller says at this stage…"

**Objection Handling Notes** (optional, textarea) — instructions for how the persona should respond to common pushback: "who is this?", "I'll call you back on the main number", "I don't give out that information over the phone." These notes are passed to the AI as behavioral guardrails during the call.

**Example Calls or Scripts** (optional, upload zone) — real vishing call transcripts or scripts the organization has encountered or collected. Accepted formats: .txt, .docx, .pdf. Up to 5 files.

The **View More** disclosure expands additional advanced fields: Attack Scenario, Systems at Risk, Rules & Compliance, Cultural Context, and Termination Logic — the same extended configuration available for text AEPs.

The primary CTA is **Refine and Test**; the secondary CTA is **Save as Draft**.

**Step 2 — Test & Refine (Voice)**

Step 2 for a Voice AEP replaces the live chat interface with a **Script Preview** panel and a **Test Call** action.

The **AI Refine panel** on the left is identical in structure to the text AEP refine panel — Quick Actions chips, Custom Instruction textarea, and Recent Changes list — but the quick-action chips are adapted for voice: More assertive, Less pushy, Add urgency, Soften opener, Shorter script, More empathetic opener.

The **Script Preview panel** on the right shows the current generated script rendered as a structured read-only document: Opening, Core Ask, Closing, and Objection Handling sections. A **Call Test Number** button appears at the top of this panel. Clicking it triggers a VOIP call to the admin's registered phone number, allowing them to experience the AI caller persona live before approving the script.

After completing a test call, an inline confirmation appears in the panel: "Mark test call as reviewed" checkbox. The admin must check this before the **Publish AEP** button activates. The 1-session and 2+ session warning logic from text AEPs applies equivalently — "1 test call completed" triggers the acknowledgment warning; "2+ test calls" proceeds to standard publish confirmation.

Thumbs-up and thumbs-down feedback controls appear below each Script Preview render after a test call is completed, rather than after each AI message. The thumbs-down chips are adapted: Script too long, Wrong tone, Opener unrealistic, Core ask too aggressive, Off-brand language.

**Publishing, version history, and detail page** behavior is identical to text AEPs. Voice AEPs are locked once referenced in an active campaign; cloning creates a new Draft with the same Voice channel type.

---

## Creating a Vishing Campaign

Admins reach the campaign wizard from **Simulations → Red Team → Create Campaign**. The entry points from the Group detail page and Dashboard quick action ("Launch a new exercise") are unchanged; when the type selector appears, Vishing is now a selectable option alongside SMS and WhatsApp.

The wizard uses the Stillsuit DS v2 wizard pattern: 8 linear steps with a persistent step bar, back navigation that preserves all form state, Save as Draft available at any step, and no hard-lock on forward navigation unless a hard block condition is present.

**Step 1 — Channel Selection**

The Vishing channel card is now selectable. It was previously a Coming Soon card. The card shows the current VOIP infrastructure status: **Active** or **Degraded** (if Dune's VOIP provider is experiencing issues). Selecting Vishing deselects SMS and WhatsApp and disables their cards — vishing campaigns are vishing-only in v1. A contextual note below the card reads: "Vishing campaigns are executed by Dune operators via managed VOIP infrastructure. You configure the campaign; Dune sets it live."

If VOIP status is **Degraded**, the card shows a visible warning chip and a status detail (e.g., "Call delivery may be delayed — infrastructure issue in progress"). The admin may still proceed; the constraint surfaces again in Step 4.

**Step 2 — Audience**

Audience configuration is identical to the text-channel wizard: Groups, Individuals, or Both targeting modes, with the same per-channel coverage indicators adapted for vishing. Coverage for vishing is based on **reachable phone number** — the same signal used for SMS coverage. A target is considered reachable if a mobile or work phone number is on file. Coverage that was previously labeled "SMS coverage" in the audience step is labeled "Phone coverage" when vishing is the selected channel.

The same overlap detection, deduplication callout, cooldown conflict warning, and zero-coverage hard block behavior apply without change.

**Step 3 — Voice AEP + Script**

Instead of the template and message editor used for SMS and WhatsApp, Step 3 presents the **Voice AEP selector** and a read-only script preview.

The admin selects a Voice AEP from their AEP Library. Only published (Active) Voice AEPs appear in the selector. If no Voice AEPs exist, the selector shows an empty state: "No published Voice AEPs yet. Build one now." with a link to the AEP Builder.

After selecting a Voice AEP, the step renders a read-only preview of the AEP's Script Outline (Opening, Core Ask, Closing, Objection Handling) as a structured card. An **Edit AEP** link opens the AEP detail page in a new tab; the campaign wizard state is preserved. A **Campaign-specific calling notes** field (optional, textarea) allows the admin to add instructions specific to this campaign that supplement the AEP script — for example, referencing an actual internal system name or a real calendar event at the company. These notes are passed to Dune operators alongside the campaign configuration.

**Step 4 — Compliance Pre-flight**

The compliance checklist is adapted for voice delivery. Items checked for vishing campaigns:

| Check | Description |
|---|---|
| VOIP infrastructure status | Dune's managed VOIP service is Active and confirmed for this campaign's target geography |
| Call recording consent on file | Organization has documented consent to record calls for security testing purposes |
| One-party vs. two-party consent jurisdiction | Target employees are in jurisdictions where one-party consent applies, or documented consent covers recording |
| Works council clearance | Required and on file for EU-based targets (surfaced only if audience includes EU employees) |
| Target phone coverage ≥ 1 | At least one target has a reachable phone number (coverage check carried forward from Step 2) |

Each item renders as a status card: ✓ Active, ⚠ Pending, or ✗ Unresolved. If VOIP infrastructure status is Degraded, the item shows ⚠ Pending with a note: "Dune is monitoring an active infrastructure issue. Launch will be held until service is confirmed Active." The campaign can be saved as draft; launch is blocked until this clears. Two-party consent jurisdiction failures are ✗ Unresolved and block launch — the admin must confirm targets are in one-party consent jurisdictions or provide documented consent before proceeding.

**Step 5 — Call Configuration**

Delivery configuration is replaced by call-specific settings.

**Call window** — the time-of-day range within which Dune operators will place calls to targets. The admin sets a start time and end time (e.g., 9:00 AM – 5:00 PM) and a timezone. Calls will not be placed outside this window. The window applies to the target's local timezone if geo data is available from IDP SCIM; otherwise it applies to the timezone set here.

**Max attempts per target** — how many times Dune operators will attempt to reach a target who does not answer. Options: 1 attempt, 2 attempts, 3 attempts. Default: 2 attempts. A contextual note: "Unanswered targets after the configured attempt limit are recorded as No Answer."

**Inter-attempt delay** — the minimum delay between call attempts to the same target. Options: 1 hour, 2 hours, 4 hours, Next business day. Default: 2 hours.

**Campaign date** — the date on which the AI VOIP system begins placing calls. A single date picker. The admin sets a requested start date; Dune ops provisions and activates the AI system before calls begin. Once activated, the system dials automatically within the configured call window.

There is no batch sending, delivery spread, or fallback routing configuration in v1. The AI VOIP system places calls sequentially within the configured call window and attempt settings.

**Step 6 — Remediation**

Remediation automation is suppressed by default, identical to text-channel red team campaigns. Suppression toggle is ON by default with the same explanatory copy. The admin may toggle suppression OFF and configure remediation rules. Suppression status is locked at launch and displayed on the campaign detail banner for the campaign's lifetime.

When remediation is active for a vishing campaign, the rule events are adapted to voice outcomes: **Answered — Compromised** (target provided requested information or confirmed credential), **Answered — Engaged** (target engaged with the caller and followed the pretext), **Answered — Declined** (target refused or terminated the call). Standard admin roles see the rule configuration in read-only state.

**Step 7 — Test Call**

The admin places a test call to their registered device before submitting the campaign request to Dune operators. The step shows the selected Voice AEP name, a **Phone number** input (pre-filled with the admin's registered number, editable), and a **Place Test Call** button.

When the test call is placed, the platform initiates a VOIP call from Dune's infrastructure to the entered number. The admin experiences the AI caller persona live. After the call ends, an inline confirmation appears: "I've completed a test call and reviewed the script on a live call" checkbox. The Continue button activates only when this checkbox is checked.

If the admin clicks **Skip test call**, a strong warning modal appears — identical in tone to the test send skip warning — explaining that vishing campaigns use real VOIP infrastructure to call employees on their actual phone numbers, and that reviewing the caller persona before submission is strongly recommended. The admin must explicitly confirm to skip. A soft warning flag appears in the Step 8 summary if the test call was skipped.

If the test call fails (VOIP infrastructure error or call not answered within 60 seconds), an inline error shows the failure reason with a **Retry** option.

**Step 8 — Review + Request**

The final step is a read-only summary of all configured steps, identical in structure to the text-channel wizard's Review + Launch step, with one material difference: the primary CTA reads **Submit Campaign Request** rather than **Launch Campaign**. This reflects the operational model — the admin is submitting a configuration for Dune operators to execute, not triggering delivery directly.

Summary cards show: selected channel (Vishing) with VOIP status; audience targeting mode and counts; selected Voice AEP name with script outline preview; campaign-specific calling notes (if entered); compliance pre-flight status; call window, max attempts, and requested start date; remediation setting; and test call status (Completed or Skipped with warning).

The compliance acknowledgment checkbox above the CTA is adapted for vishing: the admin confirms the campaign has appropriate internal authorization, that targets will receive real phone calls from an AI voice system operated by Dune's VOIP infrastructure, and that the admin is responsible for managing the debrief and disclosure process.

When the admin clicks **Submit Campaign Request**, the campaign moves to **Pending Activation** status. A confirmation screen reads: "Campaign request submitted. Dune operators will review your configuration and activate calling within one business day. You'll receive an email confirmation when calls begin." The campaign appears in the Red Team campaign list with a **Pending Activation** status badge.

---

## Campaign Status Flow

Vishing campaigns move through the following statuses:

| Status | Description |
|---|---|
| Draft | Admin has saved the wizard but not submitted |
| Pending Activation | Admin has submitted; Dune operators are reviewing before activating calls |
| Calling | Dune operators are actively placing calls within the configured window |
| Paused | Campaign has been paused by admin or Dune operator |
| Completed | All targets have reached a terminal call outcome or the campaign window has closed |
| Cancelled | Campaign was cancelled before or during calling |

The campaign list renders the **Pending Activation** badge in a distinct muted blue to differentiate it from the active orange/green badges of running campaigns.

---

## Campaign Detail — In-Progress View

When a campaign is in **Calling** status, the detail view shows a live monitoring dashboard that auto-refreshes every 30 seconds.

**Campaign header** shows the campaign name with a pulsing "Calling" status badge, a metadata row (Voice AEP name, call window, target count, start date), and two action buttons: **Pause Campaign** and **Cancel Campaign**. Both are gated to Red Team admin RBAC.

**Stats row** shows five live counters:

| Stat | Description |
|---|---|
| Total Targets | Total audience size |
| Reached | Targets who answered at least one call attempt |
| No Answer | Targets who did not answer across all configured attempts |
| Compromised | Targets classified as Complicit (Engaged, Compromised) |
| Declined | Targets classified as Non-Complicit (actively refused or terminated call) |

**Call log table** shows one row per target who has been attempted. Columns: Employee Name (with phone number sub-label), State (badge), Attempt Count, Last Attempt Time, Call Duration (for answered calls), and a Transcript link (opens call recording or operator notes drawer). The table is sorted by Last Attempt Time descending by default.

---

## Call Outcome States

Each call is classified in real time as Dune operators work through the campaign. States are displayed as color-coded badges.

| State | Classification | Badge Color | Description |
|---|---|---|---|
| Not Yet Called | — | Gray | Target has not yet been attempted |
| No Answer | Ignored | Gray | All configured attempts made; target did not answer |
| Engaged | Complicit | Orange | Target answered and engaged with the pretext |
| Compromised | Complicit | Red | Target provided requested information, confirmed credential, or took the target action |
| Declined | Non-Complicit | Green | Target refused, challenged the caller, or terminated the call early |
| Callback Requested | Pending | Blue | Target asked to call back later; follow-up attempt is pending |

The susceptibility rate is the percentage of Complicit conversations (Engaged + Compromised) as a share of total Reached targets.

---

## Campaign Detail — Post-Campaign Reporting

When the campaign reaches **Completed** status, the detail view transitions to the reporting dashboard. The view has two tabs: Overview and Call Log.

**Overview tab** shows the locked stats row, a filter bar (date range, geo/site filter, AEP filter, Export CSV), and the following charts:

- **Daily activity stacked bar chart** — Calls Attempted / No Answer / Complicit / Declined by day
- **Complicit by AEP chart** — horizontal bar chart with one row per Voice AEP used across campaigns
- **Complicit by site/geo chart** — requires IDP SCIM; shown in unavailable state if not integrated
- **Attempt distribution** — bar chart of targets reached on attempt 1 vs. attempt 2 vs. attempt 3

**Call Log tab** shows a per-target table: Employee Name, Employee ID, Email, Attempt Count, Call Duration, Geo/Site, AEP Used, Outcome State, Complicit (re-taggable, RBAC-gated), Recording/Notes link, Reporting Status.

Re-tagging behavior is identical to the text-channel Conversations tab: Red Team admins can reclassify Non-Complicit to Complicit; the reverse is not available post-campaign.

---

## RBAC

| Action | Red Team admin | Standard admin | Read-only viewer |
|---|---|---|---|
| Create and submit campaign request | ✓ | ✗ | ✗ |
| Pause or cancel campaign | ✓ | ✗ | ✗ |
| View Overview tab | ✓ | ✓ | ✓ |
| View Call Log tab | ✓ | ✓ | ✓ |
| Re-tag Non-Complicit → Complicit | ✓ | ✗ (disabled + tooltip) | ✗ |
| Export CSV | ✓ | ✓ | ✗ |
| Configure email alerts | ✓ | ✗ | ✗ |
| Create and publish Voice AEPs | ✓ | ✗ | ✗ |

---

## Integration Points

| Integration | Description |
|---|---|
| Dune VOIP Infrastructure | Managed VOIP service that places and records calls on behalf of Dune operators. Provides real-time call status events (answered, no answer, duration, outcome) that populate the campaign detail view. Infrastructure status surfaced in Step 1 and Step 4. |
| AEP Library | Voice AEPs are created and managed in the AEP Library. Published Voice AEPs feed into the vishing campaign builder's AEP selector. AEPs in active campaigns are locked. |
| IDP / SCIM | Required for target-local-timezone call window application and geo/site chart in reporting. Shows unavailable state if not integrated. |
| Risk Scoring Engine | Assumed isolated from vishing results in v1 — vishing campaign outcomes do not generate risk score deltas for targeted employees. Confirm with PM before implementation. |
| Workday | Source for Employee ID in the Call Log export; placeholder state while integration is pending. |
| Email Notification System | Used for campaign activation confirmation email (sent when Dune ops activates the campaign) and post-campaign completion notification. Uses configured Training Sender Email Domain. |
| Domo API | Out of v1 scope. Deferred to v3 reporting suite. |

---

## Edge Cases & System Behaviour

| Scenario | Behaviour |
|---|---|
| VOIP infrastructure is Degraded at Step 1 | Channel card shows Degraded warning chip. Admin can proceed to configure; launch is blocked in Step 4 until status clears to Active. |
| No published Voice AEPs when admin reaches Step 3 | AEP selector shows empty state: "No published Voice AEPs yet. Build one now." Link to AEP Builder. Campaign cannot proceed past Step 3 without a Voice AEP selection. |
| Target has no phone number on file | Target excluded from vishing coverage. Shown in "0 reachable targets" breakdown in Step 2. Not a hard block unless entire audience is unreachable. |
| Entire audience has zero phone coverage | Hard block at Step 2. Continue disabled. Inline error with resolution path. |
| Two-party consent jurisdiction conflict | Step 4 compliance check shows ✗ Unresolved. Launch blocked. Admin must confirm targets are in one-party consent jurisdictions or provide documented consent. |
| Call window spans timezone boundary | If IDP SCIM is not integrated, call window is applied in the admin-configured timezone. A warning callout notes: "Target local timezones are unknown without IDP integration — calls will be placed within this window in the timezone you selected." |
| Max attempts reached, target never answered | Target moves to No Answer state. No further attempts made. Reflected in stats row and Call Log. |
| Target requests a callback | State set to Callback Requested. Dune operators schedule a follow-up attempt. State updates to outcome classification when follow-up is complete. |
| Campaign submitted but VOIP degrades before activation | Dune operators notify admin via email. Campaign remains in Pending Activation status. Admin can cancel and resubmit. |
| Admin cancels during Calling status | Confirmation modal explains calls already placed cannot be recalled. Remaining scheduled attempts are cancelled. Status shows Cancelled. Call log reflects attempts made before cancellation. |
| Remediation suppressed + admin wants retroactive trigger | Not supported. Suppression locked at launch. |
| Test call not answered in 60 seconds | Inline error: "Test call wasn't answered. Make sure the number is correct and try again." Retry available. Skip still requires explicit confirmation. |
| Voice AEP archived while referenced in a scheduled campaign | Archive blocked. Error dialog names the blocking campaign with a link to it. |
| Works council clearance not on file for EU targets | Step 4 shows ✗ Unresolved for works council item. Launch blocked until clearance is documented. |
| Call recording transcript not available (operator notes only) | Recording/Notes link opens a notes drawer with operator-entered call summary instead of a recording player. Tooltip on column header: "Recordings available when supported by VOIP provider configuration." |
