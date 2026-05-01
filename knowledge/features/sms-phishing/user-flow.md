# User Flow — SMS Phishing (Smishing) Simulation
Dune Security · Design · Last updated: 2026-05-01 · Updated with full PRD.

---

## Template creation flow

### Entry points
1. **Simulations → Smishing → Templates tab → "Create Template"** — primary entry for standalone template creation.
2. **Clone button on a Dune Library or Custom template row** — opens the template creation form pre-filled with the source template's content; source changes to "Custom" on save.
3. **In-wizard: Step 2 (Message) → "Create new template"** — opens a 480px drawer with a simplified form (message + coaching sections only); saves as Draft with "Uncategorized" metadata; auto-selects the new template in the wizard.

### Happy path (standalone creation)
1. Admin navigates to **Simulations → Smishing → Templates tab**.
2. Admin clicks **"Create Template."**
3. Template creation form loads. Admin types a template name ("IT Help Desk — Suspicious Login").
4. **Section 1 — Details:** Admin selects category ("IT Account Verification"), sets difficulty ("Medium"), adds risk tags ("urgency", "impersonation").
5. **Section 2 — Message:** Admin writes the SMS body. Character counter shows 112/160. Variable tokens [First Name] and [Company] inserted. Preview renders in the 360px SMS bubble.
6. **Section 3 — Coaching page:** Admin fills in the Hook (pre-filled, editable), writes 3 red flags for this specific message, completes the Correct behavior field, and adds a Micro-commitment.
7. Admin clicks **"Save & Activate."** Template status changes to Active.
8. Template appears in the Templates tab table (Source: Custom) and is immediately available in the campaign wizard's Step 2 library.

### Happy path (in-wizard creation)
1. Admin is in the campaign wizard at Step 2 (Message).
2. Admin clicks **"Create new template."** A 480px drawer opens.
3. Admin writes the SMS message body and coaching page content in the drawer.
4. Admin clicks **"Save template."** Drawer closes. New template appears at the top of the template library with a "New" chip and is auto-selected.
5. Admin continues through the campaign wizard.
6. Admin can return to the Templates tab later to complete the template's metadata (category, difficulty, tags).

---

## Campaign creation flow

## Entry points

1. **Simulations → Smishing → "Create Campaign"** — primary entry per PRD §8.1.
2. **Group detail page → "Create Smishing Campaign" shortcut** — pre-fills the audience and skips to Step 1 with the group already selected.
3. **Dashboard → "Launch a new simulation" quick action** — routes to channel selection; user selects Smishing.

---

## Happy path (PRD §8.1)

1. Admin navigates to **Simulations → Smishing**.
2. Admin clicks **"Create Campaign"** from the campaign list page.
3. **Step 1 — Audience:** Admin selects a group. Coverage indicator renders: "428 of 512 members have phone numbers (84%)." No cooldown conflict. Admin clicks "Continue."
4. **Step 2 — Message:** Admin browses Smart Template library. Selects "IT Account Verification — Password Reset Required." Previews message in 360px SMS bubble. Character counter shows 118/160. No credential-harvest warning. Admin clicks "Continue."
5. **Step 3 — Sender + Landing Page:** Admin confirms Dune-managed sender number (read-only). Selects matching coaching page from the dropdown. Previews on mobile viewport. Admin clicks "Continue."
6. **Step 4 — Delivery:** Admin sets schedule (tomorrow, 9 AM, America/New_York). Delivery spread is ON by default (4-hour window). Admin clicks "Continue."
7. **Step 5 — Remediation:** Admin enables "If user clicks link → Assign Smishing & Mobile Scam Awareness training." Leaves other rules OFF. Admin clicks "Continue."
8. **Step 6 — Test Send:** Admin enters their own phone number. Clicks "Send Test." Receives message on device. Clicks coaching page link on device — confirms it loads correctly on mobile. Checks "I've reviewed the test message and coaching page on a mobile device." Admin clicks "Continue."
9. **Step 7 — Review + Launch:** Admin sees full summary. Coverage warning: "84 members will not receive this campaign (no phone number on file)." Admin checks compliance acknowledgment checkbox. "Launch Campaign" activates. Admin clicks "Launch Campaign."
10. System transitions to Campaign detail view with "Sending" status. Stats row begins populating.
11. Campaign completes. Status changes to "Completed." All 5 event metrics locked. Per-user table shows delivery, click, and risk score delta for each employee.

---

## End-user happy path (PRD §8.2)

1. Employee receives SMS from Dune-managed number.
2. Employee taps the link.
3. Dune records `smishing_link_clicked` event.
4. Employee's mobile browser opens the debrief landing page.
5. Employee reads the Hook ("This was a simulated text-message attack"), the red flags for that specific message, and the Pause/Verify/Report steps.
6. Employee taps "Complete a 2-minute training."
7. `smishing_training_assigned` event fires. Employee completes the module.
8. `smishing_training_completed` fires. Risk score recovers.

---

## Decision points

| Decision point | Condition | Outcome |
|---|---|---|
| Coverage threshold | 0% phone coverage | Hard block at Step 1 — Continue disabled, resolution path shown |
| Coverage threshold | 1–99% coverage | Warning callout shown; admin can proceed |
| Template selected in wizard | Custom or Dune Library template chosen | Preview renders in 360px panel; credential warning shown if applicable |
| "Create new template" clicked in wizard | Admin needs a template that doesn't exist | In-wizard drawer opens; template saved as Draft; auto-selected on close |
| Admin activates template with incomplete fields | Missing required section | Activation blocked; inline field-level errors |
| Admin archives template in active use | Template referenced by active campaign | Hard block; tooltip shows affected campaign count |
| Admin edits template used by upcoming campaign | Template referenced by scheduled campaign | Inline warning: changes apply to all upcoming campaigns using this template |
| Simulation type on selected template | Link only | Step 3 renders coaching page selector only; no form config section |
| Simulation type on selected template | Credential harvest | Step 3 renders form config summary (read-only) + coaching page selector; safety callout shown |
| Simulation type on selected template | MFA harvest | Step 3 renders MFA form config summary (read-only) + coaching page selector; safety callout shown |
| Credential harvest template selected in Step 2 | Template simulation type = Credential harvest | Safety warning callout + acknowledgment checkbox in Step 2; Step 3 shows form configuration |
| MFA harvest template selected in Step 2 | Template simulation type = MFA harvest | Safety warning callout + acknowledgment checkbox in Step 2; Step 3 shows MFA form configuration |
| Cooldown conflict | Group simulated within recent window | Inline warning; admin can override |
| Exclusion window conflict | Scheduled time overlaps window | Inline warning at Step 4; admin can adjust or override |
| Character limit | Message ≤ 160 GSM-7 chars | No warning |
| Character limit | Message > 160 or Unicode detected | Encoding warning; not a hard block |
| Delivery spread | Default ON | Randomized within 4h window |
| Remediation | All rules OFF | Campaign launches without automation |
| Test send | Admin skips | Soft warning in Step 7; not a hard block |
| Compliance checkbox | Unchecked | Launch button disabled |
| Compliance checkbox | Checked | Launch button activates |
| Employee clicks link | Any click event | Debrief page served; `smishing_link_clicked` recorded; remediation triggered if rule enabled |
| Employee submits simulated login form | Credential harvest campaign | `smishing_credential_submitted` recorded; high-risk signal; no real data stored; debrief page (State B) served immediately |
| Employee submits simulated MFA form | MFA harvest campaign | `smishing_mfa_submitted` recorded; high-risk signal; no real data stored; debrief page (State C) served immediately |
| Employee navigates back to form after debrief | Credential or MFA harvest campaign | Form page shows "This simulation has ended" state; form fields disabled; event not re-recorded |
| Employee reports message | Reporting in v1 scope (open question) | `smishing_reported` recorded; positive risk signal |
| Employee replies STOP | Any campaign | Immediate send queue removal; opt-out record created; admin banner notification |
| Bot/scanner click | Automated fingerprint | Click filtered; filtered count incremented in campaign detail |
| STOP reply on relaunch | Admin targets group with prior opt-outs | Opted-out numbers silently excluded; not counted as failures |

---

## System responses

| System event | Product response |
|---|---|
| Group selected | Coverage indicator fetches and renders inline |
| Coverage drawer requested | 480px drawer opens with per-member coverage table |
| Template selected | Preview panel renders 360px SMS bubble with variable tokens |
| Credential harvest template selected | Simulation type badge shown; safety warning callout + acknowledgment checkbox appear; Step 3 renders form config summary |
| MFA harvest template selected | Simulation type badge shown; safety warning callout + acknowledgment checkbox appear; Step 3 renders MFA form config summary |
| Unicode character detected in editor | Encoding warning banner replaces standard counter; limit updates to 70 |
| Test send triggered | Message dispatched; inline status: "Test sent. Check your device." |
| Test send fails | Inline error with carrier reason if available |
| Campaign launched | Transitions to campaign detail; "Sending" status; stats begin populating |
| Carrier rate-limit detected | Status changes to "Delivery Slowed"; helper text explains delay |
| Delivery complete | Status locked to "Completed"; final stats render |
| `smishing_link_clicked` | Click recorded; debrief page (State A) served for link-only campaigns; for credential/MFA campaigns, simulated form page served first; remediation rule evaluated |
| `smishing_credential_submitted` | Event recorded; high-risk signal queued; zero real data stored confirmed; debrief page State B served immediately |
| `smishing_mfa_submitted` | Event recorded; high-risk signal queued; zero real data stored confirmed; debrief page State C served immediately |
| `smishing_reported` | Positive signal recorded (if v1 scope confirmed) |
| `smishing_training_assigned` | Training module assigned to employee |
| `smishing_training_completed` | Recovery signal recorded; risk score updates |
| Bot/scanner click detected | Click filtered; filtered count incremented with info tooltip |
| Employee replies STOP | Send queue removal; opt-out record; admin banner notification |
| Phone number delivery failure | Per-user row: "Not delivered — [reason]"; excluded stats updated |
| Manager notification rule fires | Manager email sent per remediation configuration |
| ServiceNow rule fires | Ticket created in connected ServiceNow instance |

---

## Edge cases

All from `edge-cases.md` — handled states:

| Edge case | Handling |
|---|---|
| Group with 0% phone coverage | Hard block at Step 1; Continue disabled; resolution path (upload CSV, configure HRIS sync) |
| International numbers unsupported in v1 | Carrier failure at delivery; per-user row "Not delivered — unsupported number"; included in Excluded count |
| Credential harvest template selected | Safety warning callout + acknowledgment checkbox in Step 2; Step 3 renders form config summary (read-only) + coaching page selector; coaching page checked for form fields (guardrail applies to coaching page only, not simulated form) |
| MFA harvest template selected | Safety warning callout + acknowledgment checkbox in Step 2; Step 3 renders MFA form config summary; same coaching page guardrail |
| Coaching page contains form field (link-only or coaching section of credential/MFA) | Hard block: "Coaching pages cannot contain form fields. Remove the form to continue." |
| Employee submits simulated credential form | `smishing_credential_submitted` recorded; no data stored; debrief (State B) served; remediation rule for credential submission evaluated |
| Employee submits simulated MFA code | `smishing_mfa_submitted` recorded; no data stored; debrief (State C) served; remediation rule for MFA submission evaluated |
| Employee navigates back to simulated form after debrief | "This simulation has ended" state shown; form disabled; event not re-recorded |
| Employee replies STOP | Immediate queue removal; permanent opt-out record created; admin banner; "Opted out" status in results |
| Prior STOP opt-outs on relaunch | Silently excluded; counted as "Opted out" in coverage indicator |
| Link scanner false positive | Filtered at infrastructure layer; filtered count shown with tooltip |
| Carrier rate-limits mid-send | Status "Delivery Slowed"; delivery continues; running delivered count visible |
| Phone number goes stale mid-campaign | Carrier failure; per-user row shows failure; not retroactively removed from targeted count |
| Unicode drops limit to 70 | Encoding warning banner; limit updates; admin resolves by removing Unicode characters |
| Test send delivery fails | Inline error; admin can retry or skip with warning |
| Campaign cancelled mid-send | Remaining sends stop; already-sent messages cannot be recalled; status "Cancelled"; delivered count shows messages sent before cancellation |
| Admin clones from email phishing | Field mapping: email subject → SMS sender number (read-only); email body → SMS message (with character count reset); attachments dropped |
| Template library empty (fresh tenant) | Empty state in Step 2 with "Create your first template" primary CTA + "Browse Dune Library" secondary CTA |
| Repeat offender across campaigns | Escalating risk signal fires; flag icon in per-user table |

---

## Exit states

| Exit state | How reached | What happens |
|---|---|---|
| Campaign launched | Admin clicks "Launch Campaign" with compliance checkbox checked | Transitions to campaign detail; status "Sending" |
| Campaign saved as draft | Admin clicks "Save as Draft" at any wizard step | Saved with current state; Draft status badge in campaign list |
| Wizard cancelled | Admin clicks "Cancel" or navigates away | Confirmation modal: "Discard this campaign?" — discards on confirm |
| Campaign cancelled mid-send | Admin clicks "Cancel Campaign" on detail view | Confirmation modal explaining messages already sent cannot be recalled; remaining sends stop |
| Hard block — 0% coverage | Review step reached with group that has no phone numbers | Launch disabled; inline error with resolution path |
| Hard block — coaching page with form | Step 3 reached with coaching page containing form fields | Continue blocked; inline error with resolution path |
| System error on launch | API or infrastructure failure during launch | Inline error banner: "Campaign could not be launched. [Reason]. Try again or contact support." |
