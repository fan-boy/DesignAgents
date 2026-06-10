## Last updated
2026-06-10 — Major revision. Voice AEP data model updated to reflect actual Persona + Scenario + Facts architecture. Scenario visualization added. OSINT/Facts review added as a campaign wizard step. Collectibles and goals surfaced as the outcome engine.

---

The Vishing Campaign Launcher extends the existing Red Team Campaign Launcher to support voice phishing (vishing) as a third adversarial channel alongside SMS and WhatsApp. Admins configure and request a vishing campaign through the same 8-step wizard used for text-based red team campaigns. Dune executes calls via AI-driven VOIP infrastructure — the system places and conducts calls automatically using the configured Voice AEP. Call outcome events stream into the platform per call. Voice AEPs are a new, more detailed type in the AEP Library, comprising two separately-versioned components: a **Persona** and a **Scenario**. In v1, vishing campaigns are vishing-only — they cannot be combined with SMS or WhatsApp channels in the same campaign.

---

## Voice AEP Architecture

A Voice AEP is structurally richer than a text AEP. It is composed of two versioned components that are built and managed separately but published together:

**Persona** — the caller's identity and voice. Defines the name and claimed role the AI caller presents, the voice model and audio characteristics (voice ID, speed, background ambience), the system prompt that governs the caller's personality and hard constraints, a greeting message, and a list of banned phrases the AI will never say. The persona is the "who" of the call.

**Scenario** — the call's operational playbook. Defines the sequence of phases (discrete stages of the conversation), the transition rules that move the call from one phase to the next, the tactics available to the AI in each phase (specific persuasion moves with templates and intent descriptions), the collectibles the AI is trying to extract from the target (keyed data points matched by regex — e.g., last-4 SSN, email confirmation, password, MFA code), and the goals that determine call success (weighted objectives). The scenario is the "what" and "how" of the call.

**Facts (OSINT)** — tenant-level intelligence injected into the AI at call time. Facts are stored separately per organization and include org chart data (CISO name, head of finance), tooling context (SSO provider, EDR product, ticketing system, MFA provider), company news (recent funding rounds, acquisitions), and internal policies (wire approval thresholds, helpdesk hours). Facts are not part of the AEP itself — they are reviewed and approved at campaign configuration time and make the AI's conversation specifically convincing for each target's organization.

---

## Voice AEPs in the AEP Library

Voice AEPs are created and managed in the same AEP Library accessed via **Red Teaming > AEP Library**. They are distinguished from text AEPs by a **Voice** channel badge on their library row and a **Channel Type** attribute on their detail page. Voice AEPs and text AEPs are non-interchangeable: a vishing campaign can only select a Voice AEP, and an SMS or WhatsApp campaign can only select a text AEP.

When an admin clicks **New AEP**, the builder opens with a **Channel Type** selector: **Text** or **Voice**. Selecting Voice opens the Voice AEP builder, which uses a three-step progress indicator: **① Persona** · **② Scenario** · **③ Test & Refine**.

---

**Step 1 — Persona**

The Persona step configures who the AI caller is. Fields:

**AEP Title** (required, text input) — the name used to identify this AEP in the library and campaign builder.

**Caller Name** (required) — the name the AI caller uses to introduce itself (e.g., "Tessa").

**Claimed Role** (required) — the role the caller claims to hold (e.g., "Internal security monitoring team, extension 4471"). This appears in the caller's self-introduction and is used to establish authority or context.

**Greeting Message** (required, textarea) — the exact first words the AI speaks when the target picks up. Shown in preview with the selected voice. Example: "Hey, this is Tessa from the security team. I'm calling about an alert that just came through on your account. Got a sec?"

**Voice** (required, selector) — chooses the AI voice model. A **Preview voice** button plays a 5-second sample. Voice options are drawn from Dune's configured voice library.

**Personality Constraints** (structured fields) — controls that govern the caller's conversational behavior:
- *Tone* (chip selector, pick 1): Casual, Formal, Urgent, Warm, Neutral
- *Response length*: Short (1–2 sentences per turn) / Medium / Long
- *Cadence*: Slow / Normal / Fast (maps to the voice speed setting)
- *Background audio* (optional selector): Office ambience, Lobby, Road noise, None

**Banned Phrases** (optional, tag input) — a list of phrases the AI will never say. Pre-populated with common over-explicit social engineering language: "verify your identity," "for security purposes," "I need you to," "company policy." Admin can add or remove entries.

The primary CTA is **Next: Scenario**; the secondary CTA is **Save as Draft**.

---

**Step 2 — Scenario**

The Scenario step defines the call's operational playbook. The step is split into two panels: a **Scenario builder** on the left and a **Scenario visualization** on the right that updates live as the admin configures phases and tactics.

**Scenario overview fields:**

**Scenario Name** (required, text input) — human-readable name for this scenario (e.g., "IT Security Verification Call").

**Scenario Description** (required, textarea) — a plain-language description of what the scenario is attempting: the pretext, the goal, and the type of target it is designed for. This appears on the AEP detail page and is shown to admins reviewing the campaign.

**Adversary Methods** (required, chip selector, pick 1–3) — the psychological levers the scenario uses. Options: Authority, Urgency, Reciprocity, Curiosity, Scarcity, Familiarity, Fear. Severity level shown inline.

**Phases** — the scenario's conversation stages, configured as an ordered list. Each phase has:
- *Phase name* (e.g., "Greeting," "Verify Identity," "Gather MFA Code")
- *Phase goal* (plain-language description of what this phase accomplishes)
- *Transition condition* (when does the call advance to the next phase — e.g., "target has provided identity confirmation")
- *Tactics* (the specific persuasion moves available in this phase — see below)

The admin can add, reorder, and remove phases. A minimum of 2 phases is required. A **+Add phase** button appends a new phase below the current last phase.

**Collectibles** — the data points the AI is actively trying to extract from the target. Each collectible has:
- *Label* (e.g., "Employee ID / Last-4 SSN," "Account password," "Live MFA code")
- *Phase* — which phase this collectible is relevant to
- *Risk weight* (1–5 slider) — how sensitive this data point is; informs the susceptibility score

Collectibles drive the campaign's outcome classification. A target who provides a high-weight collectible (password, MFA code) is classified as Compromised; a target who engages but provides only low-weight data (confirms their email) is classified as Engaged.

**Tactics** — the persuasion moves available to the AI within each phase. Each tactic has:
- *Tactic name* (e.g., "Concede then pivot," "Manager implication," "Authority protocol")
- *Phase* — which phase this tactic is used in
- *Intent* (textarea) — what this tactic is trying to accomplish and when to use it
- *Example templates* (2–3 example phrasings the AI can draw from)
- *Repeatable* toggle — whether the AI can use this tactic more than once per call

The admin can add custom tactics or use Dune-provided tactic templates appropriate for the selected adversary methods.

**Goals** — the weighted objectives for the scenario. Goals are auto-populated from collectibles but can be edited. Each goal shows its weight (contribution to the overall susceptibility score) and the condition that marks it achieved.

The primary CTA is **Next: Test & Refine**; the secondary CTA is **Save as Draft**.

---

**Scenario Visualization**

The right panel of the Scenario step renders a live **call flow diagram** that updates as the admin configures phases, transitions, and collectibles. The visualization shows:

- **Phase nodes** — each phase rendered as a labeled card showing the phase name, goal summary, and collectibles targeted in that phase
- **Transition edges** — directed arrows between phases labeled with the transition condition in plain language
- **Tactic chips** — small chips on each phase node listing the tactics available in that phase; hovering a chip shows the tactic's intent
- **Collectibles legend** — a sidebar showing all collectibles with their risk weights as colored dots (green = low, amber = medium, red = high)
- **Goal summary** — at the terminal node (final phase), a summary card shows the maximum achievable susceptibility score and what data the scenario attempts to collect

The visualization is read-only during active editing — it reflects the saved/previewed state of the scenario. An **Export diagram** button downloads the flowchart as a PNG for use in stakeholder presentations or debrief documents.

The admin cannot interact with the diagram to edit — all editing happens in the left panel. The diagram is a comprehension tool, not an editing surface.

---

**Step 3 — Test & Refine (Voice)**

Step 3 is the live testing and refinement surface. It is structurally similar to the text AEP test-and-refine step but adapted for voice.

The **AI Refine panel** on the left contains Quick Action chips adapted for voice (More assertive, Less pushy, Add urgency, Soften opener, Shorter responses, More empathetic opener), a Custom Instruction textarea, a Recent Changes list, and an Apply and Regenerate CTA.

The **right panel** shows two tabs: **Scenario Flow** (the visualization from Step 2, now read-only) and **Live Test**. The default tab on entry is Live Test.

The **Live Test panel** shows the selected voice, greeting message preview, and a **Call Test Number** button. When clicked, the platform places a VOIP call to the admin's phone — the admin experiences the full AI caller persona in real time, including the persona's voice, pacing, background audio, and live response to the admin's replies. The call progresses through the scenario phases in real time; after the call ends, the **Scenario Flow** tab updates to show which phases were reached and which collectibles were triggered during the test session. This gives the admin a concrete picture of how far a real target might progress through the scenario.

After a test call, an inline confirmation appears: "Mark test call as reviewed" checkbox. The admin must check this before the **Publish AEP** button activates. The 1-session and 2+ session warning logic from text AEPs applies equivalently.

Thumbs-down feedback chips after a test session: Persona felt scripted, Scenario too aggressive, Transition too abrupt, Opener unrealistic, Wrong tone for target.

**Publishing, version history, and detail page** behavior is identical to text AEPs. Voice AEPs are locked once referenced in an active campaign. Cloning a Voice AEP creates a new Draft that inherits both the Persona and Scenario from the source, with independent versioning from that point forward.

---

## OSINT / Facts Review

Before any vishing campaign is submitted, the admin reviews the **Organizational Facts** that Dune has collected about their company. These facts are what make the AI caller specifically convincing — it can reference the real CISO's name, name-drop the actual EDR product in use, or use the company's real wire approval policy to structure a financial pretext.

Facts are stored per-organization and populated by Dune through a combination of OSINT research and data the admin provides during onboarding. They are versioned separately from AEPs and campaigns.

Facts are reviewed in **Campaign Wizard Step 3.5** (inserted between Step 3 Voice AEP selection and Step 4 Compliance Pre-flight) as a dedicated review step. The step is titled **Review Organizational Intelligence**.

The facts review step shows all active facts for the organization in a categorized table:

| Category | Example facts |
|---|---|
| Org chart | CISO name, head of finance, key executives |
| Tooling | SSO provider, EDR product, MFA provider, ticketing system, VPN |
| Company news | Recent funding rounds, acquisitions, public announcements |
| Internal policies | Wire approval thresholds, helpdesk hours and extension, on-call coverage |
| Vendor relationships | Key partners, resellers, suppliers |

Each fact row shows: fact label, current value, data source (manual / OSINT), sensitivity (public / internal), and which call phases it is relevant to. The admin can:
- **Edit** a fact value inline (e.g., correct the CISO's name if it has changed)
- **Suppress** a fact from this campaign (it remains in the facts library but will not be injected into the AI for this campaign)
- **Flag** a fact as incorrect (sends a review request to Dune's data team)

A **Scenario relevance indicator** on each fact row shows a pill badge for each scenario phase the fact is relevant to, matched to the selected Voice AEP's scenario. This lets the admin understand exactly when and how each fact will be used during the call.

If no facts exist for the organization (new customer), the step shows an empty state with guidance: "Dune populates your organizational intelligence during onboarding. Contact your Dune representative to configure facts before running vishing campaigns." The admin cannot proceed past this step without at least reviewing the facts state.

The step does not block on empty facts — an admin can proceed with zero facts, but a contextual warning reads: "No organizational intelligence is configured. The AI caller will not be able to reference company-specific details, which reduces realism and susceptibility rates."

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
