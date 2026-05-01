# User Flow — SMS Phishing (Smishing) Simulation
Dune Security · Design · Last updated: 2026-05-01

---

## Entry points

1. **Campaigns listing page → "New Campaign" button** — primary entry; leads to the channel selection step.
2. **Group detail page → "Create Campaign" shortcut** — secondary; pre-fills the target group and skips to Step 2 with the group already selected.
3. **Dashboard → "Launch a new simulation" quick action** — tertiary; equivalent to the "New Campaign" button.

---

## Happy path

1. Admin clicks "New Campaign" from the Campaigns listing page.
2. **Step 1 — Channel selection:** Admin selects "SMS Phishing (Smishing)" from the two channel cards (Email / SMS). Clicks "Continue."
3. **Step 2 — Target group:** Admin selects a group from the dropdown. Phone coverage indicator renders below: "428 of 512 members have phone numbers (84%)." No cooldown conflict. Admin clicks "Continue."
4. **Step 3 — Message:** Admin browses the Smart Template library. Selects a template (e.g., "IT Helpdesk — Password Reset Required"). Previews the message in the 360px SMS bubble panel. Adjusts one variable token. Character counter shows 118/160. Admin clicks "Continue."
5. **Step 4 — Delivery configuration:** Admin confirms the Dune-managed sender number (read-only). Sets a schedule (tomorrow, 9 AM, America/New_York). Delivery spread is ON by default (4-hour window). Admin clicks "Continue."
6. **Step 5 — Review + launch:** Admin sees the full summary. Coverage warning: "84 members will not receive this campaign (no phone number on file)." Admin checks the TCPA acknowledgment checkbox. "Launch Campaign" button activates. Admin clicks "Launch Campaign."
7. System transitions to the Campaign detail view with status "Sending." Stats row shows initial delivered/clicked counts updating in near real-time.
8. Campaign completes. Status badge changes to "Completed." Final stats render. Per-user results table populates with delivery status, click status, and risk score delta for employees who clicked.

---

## Decision points

| Decision point | Branch conditions | Outcome |
|---|---|---|
| Channel selection | Selects Email vs. SMS | Routes to email or SMS wizard path (this flow covers SMS) |
| Phone coverage threshold | Coverage >= 1% | Warning callout shown; admin can proceed |
| Phone coverage threshold | Coverage = 0% | Launch button disabled; hard block with resolution path |
| Cooldown conflict | Group simulated within recent window | Inline warning shown; admin can override and proceed |
| Exclusion window conflict | Scheduled time overlaps exclusion window | Inline warning at Step 4 schedule picker; admin can adjust schedule or override |
| Character limit | Message <= 160 GSM-7 chars | No warning |
| Character limit | Message > 160 or contains Unicode | Encoding warning shown; not a hard block |
| TCPA checkbox | Unchecked | Launch button disabled |
| TCPA checkbox | Checked | Launch button activates |
| STOP reply received | At any point post-launch | Employee excluded from remaining sends; opt-out record created; admin notified via banner on campaign detail |
| Bot-click detected | Any click matching scanner fingerprint | Click filtered from totals; filtered count shown in campaign detail with tooltip |

---

## System responses

| System event | What the product does |
|---|---|
| Group selected | Phone coverage indicator fetches coverage data for the selected group and renders inline |
| Coverage drawer requested | Opens 480px right-anchored drawer with per-member coverage table |
| Template selected | Preview panel renders the template as a 360px SMS bubble with variable tokens applied |
| Unicode character detected in editor | Encoding warning banner replaces standard character counter display; limit updates to 70 |
| Campaign launched | Transitions to campaign detail view with "Sending" status badge; delivery stats begin populating |
| Carrier rate-limit detected | Campaign status changes to "Delivery Slowed"; helper text explains the delay |
| Delivery complete | Status badge changes to "Completed"; final stats locked |
| Employee clicks link | Click event recorded; debrief landing page served; risk score delta queued for update |
| Bot/scanner click detected | Click filtered from totals; filtered count incremented in campaign detail |
| Employee replies STOP | Admin notification banner on campaign detail; employee status updated to "Opted out"; number added to permanent exclusion list |
| Phone number invalid at delivery | Carrier returns delivery failure; employee row in results shows "Not delivered — invalid number" |

---

## Edge cases

**From `edge-cases.md` — handled states:**

| Edge case | Handling |
|---|---|
| Group members with no phone number on file | Coverage indicator shows count; warning at review step; excluded from delivery (not from campaign target count) |
| International phone numbers unsupported in v1 | Carrier failure at delivery; per-user row shows "Not delivered — unsupported number format"; included in Excluded stats count |
| Employee replies STOP | Immediate send queue removal; permanent opt-out record; admin banner notification; "Opted out" status in per-user table |
| Link scanner false positive click | Filtered at infrastructure layer; filtered count shown in campaign detail with info tooltip |
| Carrier rate-limits mid-send | Status badge changes to "Delivery Slowed"; delivery continues; admin sees running delivered count |
| Phone number goes stale mid-campaign | Carrier delivery failure; per-user row shows failure; not retroactively removed from the targeted count |
| Unicode content drops limit to 70 chars | Encoding warning banner in editor; limit display updates; admin can resolve by removing Unicode characters |
| Admin targets group where large fraction has no phone number | Warning callout in review step; only hard block is 0% coverage |
| Campaign conflicts with exclusion window | Inline warning at schedule step; admin can override with confirmation |
| Campaign cancelled mid-send | Remaining sends stop immediately; already-sent messages cannot be recalled; campaign status changes to "Cancelled"; delivered count shows messages sent before cancellation |
| Admin relaunches to group with prior STOP opt-outs | Opted-out numbers silently excluded; coverage indicator counts them as "Opted out" (separate from "Missing"); not surfaced as a failure |
| First-time admin — no phone number data | Empty coverage indicator at Step 2 with CTA "Upload phone numbers"; group still selectable; 0% coverage hard block applies at review step |
| Template library empty (fresh tenant) | Empty state in Step 3 template panel with CTA "Request templates from your Dune account manager" |
| AI generates identical messages for homogeneous group | Not applicable in v1 (template-based); flag for AI personalization phase |

---

## Exit states

| Exit state | How reached | What happens |
|---|---|---|
| Campaign launched successfully | Admin clicks "Launch Campaign" with TCPA checkbox checked | Transitions to campaign detail view; status "Sending" |
| Campaign saved as draft | Admin clicks "Save as Draft" at any wizard step | Campaign saved with current state; accessible from Campaigns listing with "Draft" status badge |
| Campaign cancelled during wizard | Admin clicks "Cancel" (ghost button) or navigates away | Confirmation modal: "Discard this campaign?" with Cancel / Discard options. Discards if confirmed. |
| Campaign cancelled mid-send | Admin clicks "Cancel Campaign" on the campaign detail view | Confirmation modal explaining messages already sent cannot be recalled; remaining sends stop on confirm |
| Hard block — 0% coverage | Admin reaches review step with a group that has no phone numbers | Launch button disabled; inline error with resolution path |
| Error — campaign creation failed | System error during launch | Inline error banner: "Campaign could not be launched. [Error reason]. Try again or contact support." |
