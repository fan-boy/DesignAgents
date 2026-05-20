# User Flow — Red Team Campaign Launcher
Dune Security · Design · Last updated: 2026-05-08

---

## Entry points

1. **Simulations → Red Team → "Create Campaign"** — primary entry; reaches campaign wizard step 1 fresh
2. **Group detail page → "Create Red Team Campaign" shortcut** — pre-fills group in Step 2 (Audience) with "Groups" mode selected; skips to Step 2
3. **Dashboard → "Launch a new exercise" quick action** — routes to a type selector (Smishing vs. Red Team); user selects Red Team and lands on Step 1

---

## Happy path (multi-channel, group + individual targeting, suppressed remediation)

1. Admin navigates to **Simulations → Red Team**.
2. Admin clicks **"Create Campaign."** Wizard opens at Step 1.
3. **Step 1 — Channel Selection:** Admin selects SMS and WhatsApp (both). Coming-soon channels (Viber, Telegram, Vishing) are visible but inactive. WhatsApp card shows API status chip: "Active for custom sends." Admin clicks Continue.
4. **Step 2 — Audience:** Admin selects targeting mode "Both." Adds Group: "Finance — North America" (320 members). Adds 4 individual users by name-search (executives not in the group). Overlap detection fires: "1 individual is also in Finance — North America. They will receive one message." Per-channel coverage breakdown renders:
   - SMS: 316 of 324 targets (97%)
   - WhatsApp: 289 of 324 targets (89%)
   - Neither: 4 targets — inline warning: "4 targets will not receive any message." Admin views the coverage gap drawer, confirms the 4 are acceptable losses. Clicks Continue.
5. **Step 3 — Template + Message:** Admin browses the red team template library. Selects "IT Help Desk — Account Suspended (Urgent)." Preview panel shows SMS tab by default (360px SMS bubble). Admin switches to WhatsApp tab — sees formatted preview with link preview note: "WhatsApp will show a link preview. Confirm the preview title doesn't reveal the simulation." Admin acknowledges. Edits the SMS message body to add [First Name] token. Character counter: 134/160. Clicks Continue.
6. **Step 4 — Compliance Pre-flight:** System checks compliance status per channel.
   - SMS: Carrier whitelist ✓ Active | Consent documentation ✓ On file
   - WhatsApp: Business API ✓ Active for custom sends | Consent documentation ✓ On file | Works council: Not applicable
   - Overall readiness: "Ready to proceed" — green badge. Admin clicks Continue.
7. **Step 5 — Delivery:** Admin sets schedule: next Tuesday, 10 AM America/New_York. Delivery spread ON (4-hour window). Fallback routing: "Surface error only" (admin does not want silent fallbacks). Admin clicks Continue.
8. **Step 6 — Remediation:** Suppression toggle is ON (default). Explanation reads: "Suppressing automation preserves the integrity of the adversarial exercise." Admin leaves suppression ON. Clicks Continue.
9. **Step 7 — Test Send:**
   - SMS section: Admin enters personal phone number. Clicks "Send Test — SMS." Receives message on device. Confirms coaching page loads on mobile. Checks "I've reviewed the test SMS on a mobile device."
   - WhatsApp section: Admin enters personal WhatsApp number. Clicks "Send Test — WhatsApp." Receives WhatsApp message. Confirms link preview is neutral. Checks "I've reviewed the test WhatsApp message on a mobile device."
   - Both confirmation checkboxes checked. Continue activates. Admin clicks Continue.
10. **Step 8 — Review + Launch:** Summary cards render:
    - Channels: SMS, WhatsApp — API status ✓ per channel
    - Audience: 324 targets (320 group, 4 individuals, 1 overlap resolved) | SMS: 316 | WhatsApp: 289 | Not reached: 4
    - Template: "IT Help Desk — Account Suspended (Urgent)"
    - Fallback routing: "Surface error only"
    - Delivery: Tuesday [date], 10:00 AM ET, spread over 4 hours
    - Remediation: "Suppressed — no automation will fire"
    - Test send: ✓ Completed (SMS) | ✓ Completed (WhatsApp)
    - Coverage warning: "4 targets will not receive any message on any selected channel. [View list]"
    - Compliance acknowledgment checkbox: unchecked → Launch button disabled. Admin reads and checks. Launch button activates.
    - Admin clicks **"Launch Campaign."**
11. System transitions to Campaign detail view. Status badge: "Sending." Per-channel delivery counts begin populating.
12. Campaign completes. Status: "Completed." Per-channel stats locked. Per-user results table shows delivery status and click events per channel.

---

## Decision points

| Decision point | Condition | Outcome |
|---|---|---|
| Channel selection | One channel selected | All downstream steps show single-channel variant |
| Channel selection | Both channels selected | Coverage indicator shows per-channel breakdown; Step 3 shows channel tab selector; Step 5 shows fallback routing; Step 7 requires per-channel test confirmation |
| Channel selection | WhatsApp API not active for custom sends | WhatsApp card shows "Template sends only" chip; admin can still select WhatsApp but Step 3 is constrained to pre-approved templates |
| Audience mode | Groups only | Standard group picker; single-row coverage summary per channel |
| Audience mode | Individuals only | People-search component; per-user channel chips in results table |
| Audience mode | Both | Both selectors visible; overlap detection active |
| Individual + group overlap | User in both lists | System deduplicates; one message sent; callout shows affected count; "View overlaps" drawer available |
| Coverage | 0% on all selected channels for entire audience | Hard block; Continue disabled; inline error with resolution path |
| Coverage | Partial coverage (some users unreachable) | Warning callout with count; admin can proceed |
| Compliance Pre-flight | All items ✓ | "Ready to proceed" — Continue enabled |
| Compliance Pre-flight | Any item ✗ | "Not ready" — Continue disabled; per-item resolution CTA shown |
| Compliance Pre-flight | Any item ⚠ Pending | Soft warning; Continue enabled; campaign can be built and saved as draft; cannot launch until cleared |
| WhatsApp link preview | Message contains a link and WhatsApp is selected | Inline callout in Step 3; admin must acknowledge before proceeding |
| Fallback routing | "Fall back to SMS" selected | WhatsApp delivery failure triggers SMS send to affected user; fallback event recorded separately |
| Fallback routing | "Surface error only" selected | WhatsApp delivery failure records a per-user error; no alternate send |
| Fallback routing | "Silent exclude" selected | WhatsApp delivery failure excludes user from delivery count silently |
| Remediation suppression | Default ON | No training, no manager notification fires on any interaction |
| Remediation suppression | Admin toggles OFF | Rule cards appear; admin configures if/then rules per channel event |
| Test send | All channel checkboxes confirmed | Continue activates normally |
| Test send | Admin clicks "Skip test send" | Strong warning modal: "Red team campaigns target real employees on personal devices. We strongly recommend testing on each channel." Skip on confirm; soft warning in Step 8 summary |
| Test send delivery failure | SMS or WhatsApp test fails | Inline error with failure reason; admin can retry or skip channel test with warning |
| Compliance acknowledgment | Unchecked | Launch button disabled; tooltip: "Confirm the compliance statement before launching" |
| Compliance acknowledgment | Checked | Launch button activates |
| Cooldown conflict | Audience group was recently red-teamed | Inline warning in Step 2; admin can override |
| Exclusion window conflict | Scheduled time overlaps exclusion window | Inline warning in Step 5; admin can adjust or override |

---

## System responses

| System event | Product response |
|---|---|
| Channel selected | Coverage indicator in Step 2 adapts to selected channels |
| Group selected | Per-channel coverage breakdown fetches and renders inline |
| Individual added to target list | Coverage breakdown updates; overlap detection re-evaluates |
| WhatsApp link detected in message | Link preview warning callout appears in Step 3 |
| Compliance Pre-flight loaded | System queries carrier whitelist status, API status, consent documentation per channel |
| Carrier whitelist pending | Step 4 shows ⚠ Pending with estimated completion date; Continue enabled; campaign saves as draft |
| Compliance item ✗ unresolved | Continue disabled; per-item CTA shown |
| Test send triggered | Message dispatched on selected channel; inline status shows; per-channel confirmation checkbox activates |
| Test send fails | Inline error with channel-specific failure reason |
| Campaign launched | Transitions to campaign detail; "Sending" status; per-channel delivery counts populate |
| WhatsApp delivery failure + fallback ON | SMS fallback send triggered for affected user; fallback event recorded in campaign detail |
| WhatsApp delivery failure + fallback OFF (surface error) | Per-user error row in results table: "WhatsApp failed — [reason]" |
| WhatsApp delivery failure + silent exclude | User excluded from delivery count; no error surfaced to admin |
| Link clicked (SMS) | `red_team_sms_link_clicked` event recorded; debrief page served; remediation evaluated if not suppressed |
| Link clicked (WhatsApp) | `red_team_whatsapp_link_clicked` event recorded; debrief page served in WhatsApp in-app browser |
| Remediation suppressed | No training assigned, no manager notification sent |
| Remediation active + rule triggered | Rule evaluated; training assigned or notification sent per rule configuration |
| Employee replies STOP to SMS | Immediate queue removal; opt-out record created; admin banner notification |
| Campaign completed | Status locked to "Completed"; per-channel stats finalized; per-user table fully populated |

---

## Edge cases

| Edge case | Handling |
|---|---|
| WhatsApp delivery fails for a target (API inactive, not on WhatsApp) | Per fallback routing setting: fall back to SMS / surface per-user error / silent exclude. Per-user row shows channel received and failure reason. |
| WhatsApp Business API restricted to template-only sends | Channel selection card shows "Template sends only" chip. Step 3 template library is constrained to pre-approved WhatsApp templates. Arbitrary message editor is unavailable for WhatsApp. |
| Target appears in both individual list and selected group | System deduplicates; one message sent; inline callout shows count; "View overlaps" drawer lists affected users |
| Zero targets with any channel coverage (0% SMS + 0% WhatsApp) | Hard block at Step 2; Continue disabled; inline error with resolution path |
| Partial channel coverage (some users have SMS only, some WhatsApp only, some both) | Per-channel coverage breakdown in Step 2 shows each segment; fallback routing in Step 5 determines how failures are handled |
| WhatsApp message contains link → link preview reveals simulation context | Warning callout in Step 3; admin must acknowledge; guidance on setting neutral meta tags |
| Admin cancels mid-execution | Confirmation modal explains already-sent messages cannot be recalled; remaining sends stop; campaign status "Cancelled"; per-channel sent counts show messages delivered before cancellation |
| Carrier whitelisting pending at compliance step | ⚠ Pending state in Step 4; Continue enabled; campaign can be configured and saved as draft; Launch is blocked until status clears to ✓ |
| Target has opted out of SMS | User silently excluded from SMS sends; counted as "Opted out" in SMS coverage breakdown |
| WhatsApp opt-out | WhatsApp opt-out is platform-level (user blocks the sender), not Dune-level; treated as delivery failure, not an opt-out record |
| Admin launches with remediation suppressed + later wants to review results | Remediation status banner on campaign detail confirms suppression; no retroactive remediation can be enabled post-launch |
| Admin launches with suppression OFF and remediation fires on click | Target receives training assignment or manager notification — alerts them they were tested. Expected behavior if suppression is OFF; clearly communicated in Step 6 copy. |
| Test send fails for one channel | Admin can retry that channel's test or skip with explicit warning; must confirm intent before skipping |
| Multi-channel campaign results table overflows at 1024px | Horizontal scroll on results table; column priority order: Name / Channel received / Delivery status / Clicked / Not reached — lower-priority columns collapse first |
| Debrief page opened in WhatsApp in-app browser | Same debrief content; rendering constraints differ from native browser. Flag to Eng: fixed-position elements and viewport height may behave differently. Test in WhatsApp in-app browser specifically. |
| Admin targets individual user who is a department manager | If remediation is ON and manager notification rule is active, the target would receive a notification that they were targeted — which is the same person. Flag as an edge case in remediation rule config; may warrant a guard in the rule evaluation logic. |
| Campaign saved as draft mid-wizard | All form state preserved; draft appears in campaign list with "Draft" badge; admin can resume from any step |

---

## Conversation states

Each conversation in a red team campaign is classified into one of six states. These drive the badge display in the in-progress dashboard and the Complicit/Non-Complicit classification in the post-campaign report.

| State | Classification | Color | Description |
|---|---|---|---|
| Awaiting Response | Ignored | Gray | Message delivered; no reply from target yet |
| Curious | Complicit | Amber | Target replied with a question or exploratory response |
| Engaged | Complicit | Orange | Target is actively responding and following the lure |
| Hesitant | Complicit | Yellow | Target engaged but expressed doubt or slowed response |
| Compromised | Complicit | Red | Target clicked the link, submitted credentials, or took the target action |
| Declined | Non-Complicit | Green | Target refused or reported the message |

**Complicit grouping:** Curious + Engaged + Hesitant + Compromised all count toward the susceptibility rate. The distinction between them is preserved at the row level for analyst review but collapsed in the headline stat.

**Re-tagging rules:** Red Team admin can manually move a conversation from Non-Complicit → Complicit (e.g. if a target verbally disclosed information before declining). Standard admin sees the control disabled. Cannot move Complicit → Non-Complicit post-launch.

---

## Campaign detail view — in-progress state

When a campaign status is "Sending," the detail view shows the live in-progress dashboard. This is the primary monitoring surface during an active campaign and transitions to the full reporting view when the campaign reaches "Completed."

### In-progress layout

**Campaign header**
- Campaign name (human-readable) + status badge: "Sending" (amber pulsing dot)
- Metadata row: AEP · Channel(s) · Targets count · Scheduled window
- Action row: Pause campaign | Cancel campaign (both require Red Team admin RBAC; Cancel shows confirmation modal)

**Stats row** (live, auto-refreshing)
- Total Targets
- Delivered (count + % of total)
- Awaiting Response (gray)
- Complicit (red — sum of Curious + Engaged + Hesitant + Compromised; shows susceptibility rate %)
- Non-Complicit / Declined (green)
- Not Reached (gray — failed delivery + opted out)

**Batch progress bar**
- Shows current batch / total batches and messages sent / total
- Batch size % and delivery spread window displayed below bar
- Only shown when batch sending is enabled

**Conversations table** (live, auto-refreshing every 30s)
- Columns: Employee Name · Phone · State (badge) · Channel · Last Activity · Denials · Action (Nudge)
- Sorted by Last Activity desc by default
- State badge uses six-state color system above
- Nudge: sends a follow-up message to Awaiting Response targets; gated to Red Team admin only
- Clicking a row opens the conversation transcript drawer (right-anchored, 480px)

---

## Campaign detail view — reporting dashboard

After launch, the campaign detail view is the primary reporting surface. It replaces the customer-built spreadsheet dashboards currently constructed from raw data exports (confirmed pattern: TaskUs, Concentrix — Feb–Apr 2026 feedback).

### Layout

The detail view has two tabs:

**Overview tab** (default after launch)
- **Stats row** — Total targets | SMS delivered | WhatsApp delivered | Total clicked (click rate %) | Not reached
- **Filter bar** — Date range picker (calendar, not presets) · Geo/site filter · Campaign AEP filter · Export CSV
- **Daily activity chart** — Stacked bar: Messages Sent / Ignored / Complicit by day of week; matches the weekly cadence customers track manually
- **Complicit by campaign chart** — Horizontal bar; one row per campaign AEP; human-readable campaign name (not internal slug)
- **Complicit by site/geo chart** — Horizontal bar; one row per geographic site code; requires IDP SCIM integration (flag if unavailable)
- **Channel breakdown** — % delivered by channel (SMS / WhatsApp / Viber) per geography
- **Remediation suppressed banner** — persistent callout if suppression is ON

**Conversations tab**
- Per-conversation table columns (in priority order): Employee Name · Employee ID · Email · Start Date · Geo/Site · Campaign (human-readable) · Channel · Delivery Status · State (Awaiting Response / Curious / Engaged / Hesitant / Compromised / Declined) · Complicit? (re-taggable, RBAC-gated) · Transcript (link) · Reporting Status
- Row-level re-tagging: Non-Complicit → Complicit is gated to Red Team admin RBAC role only; standard admin sees a disabled control with tooltip explaining the restriction
- Transcript column links directly to the conversation detail drawer (phone number + message thread + timestamps)
- Horizontal scroll at narrower viewports; column priority collapse order: Start Date → Email → Reporting Status → Geo/Site

### Key design decisions from customer feedback

| Decision | Rationale | Source |
|---|---|---|
| Date filter must be a calendar range picker | Customers track weekly cadence; 30/60/90 presets are too coarse | TaskUs #4, Critical |
| Campaign names must be human-readable | "Frontier Batch 1" not "taskus_meta_frontier_batch1" | TaskUs #3, High (DB fix confirmed easy) |
| Employee ID + Email + Start Date in table and export | Required for HR tracking and disciplinary process | TaskUs #6, High (JIRA RT-97) |
| RBAC re-tagging gate | Only Red Team admin role can re-tag Non-Complicit → Complicit | TaskUs #8, High |
| Transcript link in table and export | Per-conversation link required for compliance review | TaskUs #13, Medium |
| Geo/site filter + chart | Admins guide fallback channel decisions by site; blocked on IDP SCIM | TaskUs #10, Concentrix #26 |
| Automated email alerts (daily digest) | Not all admins monitor dashboard continuously | Concentrix #25, High |
| 1 year historical data | Repeat offender tracking and disciplinary record | Concentrix #24, High |
| Campaign status clarity | "Completed" state with no data causes confusion; add explanation | Concentrix #23 |
| Separate Red Team tab | Dashboard must not be embedded in Org Insights scroll | Both #14/#30, High |

### RBAC states in detail view

| Action | Red Team admin | Standard admin | Read-only viewer |
|---|---|---|---|
| View Overview tab | ✓ | ✓ | ✓ |
| View Conversations tab | ✓ | ✓ | ✓ |
| Re-tag Non-Complicit → Complicit | ✓ | ✗ (disabled + tooltip) | ✗ |
| Export CSV | ✓ | ✓ | ✗ |
| Cancel campaign | ✓ | ✗ | ✗ |
| Configure email alerts | ✓ | ✗ | ✗ |

### Email alert flow

Admin configures a daily digest from the detail view:
1. Click "Set up alerts" button in the detail view header
2. Drawer opens: recipients (email input, multi), frequency (daily / on each complicit event), format (summary count / full list)
3. Save — system sends first alert at the next scheduled window
4. Alert email contains: campaign name, date range, complicit count, link back to Conversations tab

---

## Exit states

| Exit state | How reached | What happens |
|---|---|---|
| Campaign launched | Admin clicks "Launch Campaign" with compliance checkbox checked and no hard blocks | Transitions to campaign detail Overview tab; status "Sending"; per-channel delivery counts begin populating |
| Campaign saved as draft | Admin clicks "Save as Draft" at any wizard step | Saved with current state; Draft badge in campaign list; resumable from last completed step |
| Wizard cancelled | Admin clicks "Cancel" or navigates away | Confirmation modal: "Discard this campaign?" — discards on confirm; preserves as draft on cancel |
| Campaign cancelled mid-send | Admin clicks "Cancel Campaign" on detail view | Confirmation modal explains already-sent messages cannot be recalled; remaining sends stop; status "Cancelled" |
| Hard block — 0% coverage all channels | Entire audience has no coverage on any selected channel | Launch disabled; inline error with resolution path (fix coverage gaps, change audience) |
| Hard block — compliance unresolved | Step 4 has ✗ items and admin reaches Review step | Launch blocked; inline error directing back to Step 4 with specific items to resolve |
| System error on launch | API or infrastructure failure during launch | Inline error banner: "Campaign could not be launched. [Reason]. Try again or contact support." Campaign state preserved as Draft. |
| Carrier whitelist pending at launch attempt | Admin completes all steps but carrier setup not yet ✓ | Launch blocked with explanation: "Carrier setup is still in progress. You'll receive a notification when this campaign is ready to launch." Campaign saved as draft. |
