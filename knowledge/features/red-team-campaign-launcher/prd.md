The Red Team Campaign Launcher lets security admins configure and send adversarial test campaigns to real employees over SMS and WhatsApp. Unlike simulation campaigns, which are educational exercises with immediate remediation, red team campaigns are adversarial assessments of real security posture — the target does not know they are being tested until a debrief. This distinction drives every material product decision: compliance gating, remediation defaults, risk pipeline routing, and reporting access. The feature lives in a dedicated Red Team section within Simulations, separate from the phishing simulation campaign list. Campaign creation follows an 8-step wizard. Once launched, admins monitor live delivery via an in-progress dashboard and review outcomes in a two-tab post-campaign reporting view.

---

## Creating a Red Team Campaign

Admins reach the campaign wizard from **Simulations → Red Team → Create Campaign**. The wizard also accepts a pre-filled entry from any Group detail page (pre-populates the audience step with the selected group) and from the Dashboard quick action "Launch a new exercise" (type selector appears before Step 1).

The wizard uses the Stillsuit DS v2 wizard pattern: 8 linear steps with a persistent step bar, back navigation that preserves all form state, Save as Draft available at any step, and no hard-lock on forward navigation unless a hard block condition is present.

**Step 1 — Channel Selection**

The admin selects which channels the campaign will deliver on. Available in v1: SMS and WhatsApp. Viber, Telegram, and Vishing appear as Coming Soon cards and are not selectable. Each channel card shows its current API status: "Active for custom sends" or "Template sends only" (the latter indicates WhatsApp Business API has restricted bulk sends to pre-registered templates for this account). The admin can select one or both active channels. Channel selection drives which variants appear in every subsequent step — single-channel mode and multi-channel mode are distinct flows through Steps 2, 3, 5, and 7.

If WhatsApp is selected but the API status is "Template sends only," the card displays a visible warning chip and the admin may still proceed; the constraint surfaces again in Step 3 where the message editor will be restricted to pre-approved templates.

**Step 2 — Audience**

The admin sets who will receive the campaign. Three targeting modes are available: Groups, Individuals, or Both.

In **Groups mode**, the admin uses the existing group picker to add one or more groups. A per-channel coverage indicator renders inline showing how many targets in the combined audience have a reachable number for each selected channel: SMS coverage, WhatsApp coverage, targets reachable on both, and targets reachable on neither. Neither coverage is a hard block — the admin cannot continue until at least one target has coverage on at least one selected channel.

In **Individuals mode**, the admin uses a people-search component (net-new in v1) to find and add named employees. The search field queries by name or email. Results display per-user channel coverage chips so the admin can see at a glance which channels each person can be reached on before adding them. The selected individual list appears in a panel alongside the search results.

In **Both mode**, both selectors are active simultaneously and overlap detection is running. When a user appears in both the individual list and a selected group, the system deduplicates automatically and surfaces a callout showing the count of resolved overlaps. The admin can open a "View overlaps" drawer to see which users were affected. One message is sent to deduplicated users regardless of which targeting mode selected them.

If partial coverage means some targets are unreachable on all selected channels, a warning callout shows the count and a link to view the gap list. The admin can proceed — this is not a hard block. Zero coverage across all channels for the entire audience is a hard block; the Continue button is disabled and an inline error shows the resolution path.

The step also checks for cooldown conflicts: if any targeted group was recently red-teamed, an inline warning surfaces. The admin can override.

**Step 3 — Template + Message**

The admin selects a template from the red team template library and optionally edits the message body. In multi-channel mode, the preview panel shows a tab selector for SMS and WhatsApp — the admin configures each channel's message independently or uses a single template for both.

The SMS editor shows a character counter (e.g., 134/160) and supports merge tokens such as [First Name]. The WhatsApp editor reflects WhatsApp's formatting capabilities (bold, italic, link preview) and displays a character-appropriate counter.

If the message contains a URL and WhatsApp is selected, an inline callout warns that WhatsApp renders a link preview showing the URL, page title, and meta image before the user taps the link. The admin must acknowledge this before proceeding and is advised to ensure the debrief page's meta tags do not reveal the simulation context.

If the WhatsApp API status is "Template sends only," the WhatsApp message editor is replaced by a constrained template picker showing only pre-approved WhatsApp templates. Arbitrary message editing is unavailable.

**Step 4 — Compliance Pre-flight**

The system runs a readiness check for each selected channel before the campaign can proceed to delivery configuration. This step is a purpose-built checklist pattern (new to DS v2) — not a user input step.

For SMS: carrier whitelist status, consent documentation on file.
For WhatsApp: Business API active status, consent documentation on file, works council clearance (if applicable for EU targets).

Each item renders as a status card: ✓ Active, ⚠ Pending, or ✗ Unresolved. If all items are ✓, the step shows "Ready to proceed" and Continue is enabled. If any item is ✗ Unresolved, Continue is disabled and each failing item shows a resolution CTA (e.g., "Set up carrier whitelisting"). If any item is ⚠ Pending, a soft warning explains the pending state, Continue remains enabled, and the campaign can be configured and saved as draft — but the Launch button in Step 8 will be blocked until all pending items clear to ✓.

**Step 5 — Delivery**

The admin configures the send schedule and, in multi-channel mode, the fallback routing behavior.

Schedule fields: date, time, and timezone. A delivery spread toggle enables a configurable window (e.g., 4 hours) within which sends are distributed — this prevents a recognizable spike in simultaneous delivery that could alert targets or IT monitoring systems. Batch sending is also configurable: the admin sets batch size as a percentage of total targets and the delay between batches (e.g., 3% per batch, 24 hours between batches).

Exclusion window conflicts surface inline if the scheduled time overlaps with a configured exclusion window. The admin can adjust or override.

In **multi-channel mode**, fallback routing controls what happens when WhatsApp delivery fails for a specific target. Three options are available:

| Option | Behaviour |
|---|---|
| Fall back to SMS | WhatsApp delivery failure triggers an SMS send to the affected target; the fallback event is recorded separately in the campaign detail |
| Surface error only | WhatsApp delivery failure records a per-user error in the results table ("WhatsApp failed — [reason]"); no alternate send is attempted |
| Silent exclude | WhatsApp delivery failure silently excludes the user from the delivery count; no error is surfaced |

**Step 6 — Remediation**

Remediation automation is suppressed by default for red team campaigns. The suppression toggle is ON by default with explanatory copy: "Suppressing automation preserves the integrity of the adversarial exercise. Targets will not receive training assignments or manager notifications until you choose to act on results."

The admin may toggle suppression OFF. When toggled off, rule cards appear for each channel event type — the admin configures if/then remediation rules as in the simulation wizard. If suppression is toggled off and remediation fires on a click, the target will receive a training assignment or manager notification before any debrief is conducted. This is clearly communicated in the step copy before the admin toggles.

Suppression status is locked at launch and cannot be changed retroactively. A persistent banner on the campaign detail view shows suppression status for the life of the campaign.

**Step 7 — Test Send**

The admin sends a test message on each selected channel to a personal device before launching to the full audience. Each channel gets its own test send section with a phone number input, a Send Test button, and a per-channel confirmation checkbox.

The admin must check "I've reviewed the test [channel] message on a mobile device" for each channel. The Continue button activates only when all channel checkboxes are checked.

If the admin clicks "Skip test send," a strong warning modal appears explaining that red team campaigns target real employees on personal devices and that testing each channel before launch is strongly recommended. The admin must explicitly confirm to skip. A soft warning flag appears in the Step 8 summary if test send was skipped.

If a test send fails for a channel, an inline error shows the channel-specific failure reason. The admin can retry or skip that channel's test with an explicit warning.

**Step 8 — Review + Launch**

A read-only summary of all configured steps renders as a series of summary cards before the final launch action. Each card is a condensed view of one configuration step with an Edit link.

Summary cards show: selected channels with API status per channel; audience targeting mode and counts (group count, individual count, overlap-resolved count, per-channel coverage breakdown); selected template name; fallback routing setting (multi-channel only); scheduled delivery date, time, timezone, and spread window; remediation setting (Suppressed or active rule summary); and test send status per channel (Completed or Skipped with warning).

If any hard block is present — zero audience coverage on all channels, or an unresolved Compliance Pre-flight ✗ item — the Launch button remains disabled and an inline error directs the admin to the specific blocking step.

A compliance acknowledgment checkbox appears above the Launch button. The checkbox must be checked before Launch activates. The checkbox copy states that the admin confirms the campaign has appropriate internal authorization, that targets will receive real messages on personal devices, and that the admin is responsible for managing the debrief and disclosure process. This copy requires legal review before finalization.

When the admin clicks **Launch Campaign**, the system transitions to the campaign detail view with status "Sending."

---

## Campaign Detail — In-Progress View

When a campaign is in "Sending" status, the detail view shows the live monitoring dashboard. This view auto-refreshes every 30 seconds.

**Campaign header** shows the campaign name with a pulsing "Sending" status badge, a metadata row (AEP, channel(s), target count, delivery window), and two action buttons: Pause Campaign and Cancel Campaign. Both are gated to Red Team admin RBAC. Cancelling a mid-execution campaign requires a confirmation modal that explains already-sent messages cannot be recalled and shows the count of messages delivered before cancellation. Remaining queued sends stop on confirmation.

**Stats row** shows five live counters:

| Stat | Description |
|---|---|
| Total Targets | Total audience size for this campaign |
| Delivered | Messages delivered across all channels; percentage of total targets shown as sub-label |
| Awaiting Response | Delivered targets who have not yet replied |
| Compromised | Count of targets classified as Complicit (any of: Curious, Engaged, Hesitant, Compromised); susceptibility rate shown as percentage sub-label |
| Declined | Targets classified as Non-Complicit |

**Batch progress bar** appears when batch sending is enabled. It shows the current batch number out of the total batch count, a progress bar filled proportionally to messages sent vs. total targets, and the configured batch size and delay settings below the bar.

**Conversations table** shows one row per target who has been contacted. Columns are Employee Name (with phone number sub-label), State (badge), Channel, Last Activity, Denials, and action columns. The table is sorted by Last Activity descending by default. Clicking any row opens the conversation transcript drawer (480px, right-anchored) showing the full message thread, timestamps, and delivery events.

---

## Conversation States

Each conversation is classified in real time as the campaign runs. States are displayed as color-coded badges throughout the in-progress view and post-campaign reporting surface.

| State | Classification | Badge Color | Description |
|---|---|---|---|
| Awaiting Response | Ignored | Gray | Message delivered; target has not replied |
| Curious | Complicit | Amber | Target replied with an exploratory question |
| Engaged | Complicit | Orange | Target is actively following the lure |
| Hesitant | Complicit | Yellow | Target engaged but expressed doubt or slowed |
| Compromised | Complicit | Red | Target clicked the link, submitted credentials, or took the target action |
| Declined | Non-Complicit | Green | Target refused or reported the message |

The susceptibility rate in the stats row is the percentage of Complicit conversations (Curious + Engaged + Hesitant + Compromised) as a share of total delivered. Declined is the Non-Complicit count.

**Nudge action** is available on rows in Awaiting Response state. Clicking Nudge sends a follow-up message to the target on the same channel. The Nudge action is gated to Red Team admin RBAC only.

**Re-tagging** is available on the Complicit column in the post-campaign Conversations tab. Red Team admins can manually reclassify a Non-Complicit conversation to Complicit (for cases where a target verbally disclosed information before declining). The reverse — Complicit to Non-Complicit — is not available post-launch. Standard admins see the re-tag control in a disabled state with a tooltip explaining the RBAC restriction.

---

## Campaign Detail — Post-Campaign Reporting

When the campaign reaches "Completed" status, the detail view transitions to the reporting dashboard. Per-channel stats are locked. The view has two tabs: Overview and Conversations.

**Overview tab**

The Overview tab is the default view after completion. It shows a stats row matching the in-progress counters (now locked), followed by a filter bar and a set of charts.

The filter bar includes a calendar date range picker (not presets — customers need week-by-week granularity), a geo/site filter (requires IDP SCIM integration; shows an "Unavailable — integration required" state if SCIM is not connected), a campaign AEP filter, and an Export CSV button (admin roles only; read-only viewers see no export option).

Charts in the Overview tab:

- **Daily activity stacked bar chart** — Messages Sent / Ignored / Complicit by day of week, matching the weekly reporting cadence customers currently track manually in spreadsheets
- **Complicit by campaign chart** — horizontal bar chart with one row per campaign AEP; campaign names are human-readable (not internal slugs)
- **Complicit by site/geo chart** — horizontal bar chart with one row per geographic site; requires IDP SCIM; shown in unavailable state if not integrated
- **Channel breakdown** — percentage delivered by channel (SMS / WhatsApp) per geography

A persistent banner at the top of the Overview tab shows remediation suppression status for the campaign. If suppression was ON, the banner reads "Remediation suppressed — no training or notifications were sent to any target." If suppression was OFF and rules fired, the banner summarizes rule execution count.

**Conversations tab**

The Conversations tab shows a per-conversation table with the following columns (in display priority order): Employee Name, Employee ID, Email, Start Date, Geo/Site, Campaign (human-readable), Channel, Delivery Status, State (six-state badge), Complicit (re-taggable, RBAC-gated), Transcript (link to conversation drawer), Reporting Status.

Employee ID is sourced from Workday integration. While that integration is pending, the column shows a placeholder value ("—") with a tooltip explaining the pending state. Once the Workday integration is complete, historical rows are backfilled.

The Transcript column links directly to the conversation detail drawer showing the full message thread, timestamps, and delivery events for that target.

At narrower viewports, the table uses horizontal scroll. Column collapse priority order on narrow viewports: Start Date → Email → Reporting Status → Geo/Site.

---

## Email Alert Configuration

From the campaign detail header, admins can configure automated email alerts. Clicking **Set up alerts** opens a right-anchored drawer with three fields: recipients (multi-email input), frequency (daily digest or per-event on each new Complicit classification), and format (summary count or full target list). On save, the system sends the first alert at the next scheduled window. Alert emails include the campaign name, date range covered, current Complicit count, and a direct link to the Conversations tab.

Email alert configuration is gated to Red Team admin RBAC only.

---

## RBAC

| Action | Red Team admin | Standard admin | Read-only viewer |
|---|---|---|---|
| Create and launch campaign | ✓ | ✗ | ✗ |
| Pause or cancel campaign | ✓ | ✗ | ✗ |
| Nudge a target | ✓ | ✗ | ✗ |
| View Overview tab | ✓ | ✓ | ✓ |
| View Conversations tab | ✓ | ✓ | ✓ |
| Re-tag Non-Complicit → Complicit | ✓ | ✗ (disabled + tooltip) | ✗ |
| Export CSV | ✓ | ✓ | ✗ |
| Configure email alerts | ✓ | ✗ | ✗ |

Sub-admin visibility into red team results beyond these roles is unconfirmed. See Open Questions.

---

## Integration Points

| Integration | Description |
|---|---|
| WhatsApp Business API | Required for WhatsApp channel sends; determines whether custom messages or template-only sends are available; API status surfaced in Step 1 channel card and Step 4 compliance pre-flight |
| SMS carrier whitelist | Required for SMS channel; whitelist status surfaced in Step 4; pending status blocks launch until cleared |
| AEP (Adversarial Exercise Persona) library | Provides the template and message configuration for Step 3; one AEP per campaign in v1 |
| IDP / SCIM | Required for geo/site filter and the Complicit by site/geo chart; shows unavailable state in reporting if not integrated |
| Workday | Source for Employee ID in the Conversations tab export; placeholder state displayed while integration is pending |
| Risk Scoring Engine | Assumed isolated from simulation pipeline in v1 — red team results do not generate risk score deltas for targeted employees; confirm with PM before final implementation |
| Email notification system | Used for the daily alert digest from campaign detail; requires AWS API connection (currently pending for N8N automations) |
| Domo API | Out of v1 scope; requested by Concentrix for automated reporting; deferred to v3 reporting suite |

---

## Edge Cases & System Behaviour

| Scenario | Behaviour |
|---|---|
| WhatsApp delivery fails for a target | Per fallback routing setting in Step 5: falls back to SMS, surfaces per-user error row, or silently excludes. Failure reason shown in per-user row in Conversations tab. |
| WhatsApp API status is "Template sends only" | Channel card in Step 1 shows "Template sends only" chip. Step 3 WhatsApp editor is replaced by a constrained template picker. Arbitrary message editing unavailable for WhatsApp. |
| Target appears in both individual list and selected group | System deduplicates. One message sent. Inline callout shows overlap count. "View overlaps" drawer lists affected users. |
| Zero coverage on all selected channels for entire audience | Hard block at Step 2. Continue disabled. Inline error with resolution path. |
| Partial coverage — some targets unreachable | Warning callout with count of unreachable targets. Admin can proceed. |
| WhatsApp link preview reveals simulation context | Warning callout in Step 3 when a URL is detected. Admin must acknowledge. Guidance on setting neutral meta tags shown. |
| Admin cancels mid-execution | Confirmation modal explains already-sent messages cannot be recalled. Remaining sends stop. Status shows "Cancelled." Per-channel sent counts reflect messages delivered before cancellation. |
| Carrier whitelisting pending at launch | Launch blocked. Banner: "Carrier setup is in progress. You'll be notified when this campaign is ready to launch." Campaign saved as draft. |
| Target has opted out of SMS | User silently excluded from SMS sends. Counted as "Opted out" in SMS coverage breakdown. |
| WhatsApp opt-out | WhatsApp opt-out is platform-level (user blocks sender), not Dune-level. Treated as a delivery failure, not an opt-out record. |
| Remediation suppressed + admin later wants to retroactively trigger | Not supported. Remediation suppression is locked at launch. Banner on campaign detail confirms suppression. No retroactive change available. |
| Remediation active and rule fires on click | Target receives training assignment or manager notification before any debrief. Expected behaviour when suppression is OFF. Communicated clearly in Step 6 copy. |
| Test send skipped | Soft warning flag in Step 8 summary. Not a hard block. Strong modal warning shown when admin chooses to skip. |
| Admin targets individual who is also a department manager | If remediation is ON and manager notification rule is active, the targeted user would receive a notification about themselves. Flag in remediation rule evaluation logic; consider a guard for this scenario. |
| Campaign saved as draft | All form state preserved. Draft badge in campaign list. Admin can resume from any step. |
| Debrief page in WhatsApp in-app browser | Opens in WhatsApp's in-app browser, not native mobile browser. Fixed-position elements and viewport height may behave differently. Test specifically in WhatsApp in-app browser before launch. |
| Multi-channel results table at 1024px | Horizontal scroll on results table. Column priority collapse order: Start Date → Email → Reporting Status → Geo/Site. |
| Employee ID shows placeholder | While Workday integration is pending, Employee ID column shows "—" with tooltip. Historical rows backfilled once integration is complete. |
| Geo/site chart when SCIM not integrated | Chart shows "Unavailable — IDP integration required" state with CTA. Other charts remain functional. |

---

## Gaps

The following items are unresolved in the source material and are flagged here rather than designed around. Each represents a decision that could change a section of this PRD.

- **Risk pipeline integration** — this PRD assumes red team results are isolated from the simulation risk score pipeline. If PM confirms integrated pipeline, the detail view design changes materially (risk delta column, risk score impact summary).
- **WhatsApp Business API custom message feasibility** — this PRD assumes custom messages are possible. If Eng confirms template-only, Step 3 WhatsApp editing is unavailable and adversarial realism is reduced.
- **Template library model** — this PRD describes a red-team-specific template library. If the library is shared with simulations, Step 3 needs an advisory callout distinguishing simulation templates from red team templates.
- **Compliance acknowledgment copy** — the Step 8 acknowledgment text requires legal review before finalisation.
- **Sub-admin RBAC visibility** — exact roles and permissions for department managers and compliance viewers are unconfirmed beyond the table above.
- **Vishing** — out of v1 scope. Architecture decision (Dune-managed VOIP vs. manual outcome recording) is required before any vishing UI is designed.
- **Individual targeting maximum user count** — confirm with Eng before DS component spec for the people-search component.
- **IDP SCIM timeline** — geo/site chart unavailable state is the designed fallback; confirm SCIM availability with Eng before setting expectation with customers.
- **Workday integration ETA** — Employee ID placeholder state is the designed fallback; confirm ETA with PM.
- **Email alert AWS API connection** — N8N automations exist but AWS API connection is pending; confirm readiness before designing alert configuration as a launch-blocking feature.
