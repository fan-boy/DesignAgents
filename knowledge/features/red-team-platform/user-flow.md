# User Flow — Red Team Platform
Dune Security · Design · Last updated: 2026-05-13 · Initial flow — refinement run.

---

## Entry points

1. **Global side-nav → "Red Team"** — default landing on Dashboard
2. **Red Team Dashboard → "Create Campaign" quick action** — routes to Campaign wizard Step 1
3. **Red Team Dashboard → active campaign card** — routes to Campaign detail
4. **Red Team → Conversations sub-nav** — routes directly to Conversation Management for pending reviews
5. **Risk profile → "Red Team campaigns" link** — routes to Campaigns filtered by that employee

---

## Flow A: AEP creation (prompt-based builder)

**What an AEP is:** An AI-adaptive chatbot defined by a scenario prompt. Not a linear script — the AEP responds dynamically to whatever the employee says. Admins create AEPs by writing a scenario, testing in a live chat simulator, and iterating until they are satisfied.

### Happy path

1. Admin navigates to **Red Team → AEP Library → Custom tab**.
2. Admin clicks **"Create AEP."**
3. AEP builder opens (two-panel layout). Left: scenario editor. Right: chat simulator (empty, awaiting first prompt).
4. Admin types an AEP name ("Executive Impersonation — Urgent Wire Transfer").
5. Admin selects Category ("Finance & Payment"), sets Difficulty ("Hard"), selects Channel compatibility ("SMS, Voice").
6. Admin writes the **scenario prompt** in the main textarea:
   > "You are impersonating a senior executive at [Company]. You need to urgently request the target help you process a wire transfer outside normal channels. Start by establishing authority and urgency. If the employee engages or asks for more detail, provide a plausible but vague account number and press for confirmation. If they hesitate, increase urgency. If they question your identity, provide a plausible but unverifiable response."
7. Admin switches focus to the **chat simulator** (right panel). Types as the target employee: "Hi, who is this?"
8. AEP responds (typing indicator → message appears): "Hi [First Name], it's [Executive Name]. I need your help with something urgent — can you talk?"
9. Admin continues the simulated conversation to evaluate AEP behavior across several responses.
10. Admin notices the AEP backs off too easily when the employee pushes back. Adds a **refinement instruction** (left panel, below scenario prompt): "If the employee expresses doubt or asks to verify through official channels, do not back down. Express urgency and time pressure: 'I need this done in the next 30 minutes before our window closes.'"
11. Admin resets the chat simulator and tests again. AEP now shows more persistence.
12. Admin is satisfied. Clicks **"Save & Activate."** Content safety check runs on the prompt.
13. Check passes. AEP status changes to Active. AEP appears in the Custom tab table and is available in the campaign wizard's Step 2.

### Decision points

| Decision | Condition | Outcome |
|---|---|---|
| Admin clicks Save & Activate | Content safety check passes | AEP activates; available in campaign wizard |
| Admin clicks Save & Activate | Content safety check blocked | Activation blocked; inline error on prompt field: "This AEP prompt may violate Dune's acceptable use policy. [Reason]. Revise before activating." |
| Admin clicks Save & Activate | Content safety check warning | Warning callout; admin must acknowledge to proceed |
| Admin saves with empty scenario prompt | Required field blank | Activation blocked; inline error; Save Draft allowed |
| Admin changes channel compatibility | AEP used by an active campaign | Hard block — "This AEP is used by [N] active campaigns. Channel compatibility cannot be changed while a campaign is active." |
| LLM response error in chat simulator | Network/API failure | Inline error in chat: "Unable to get a response. Check your connection and try again." AEP is not deactivated; admin can retry. |
| Dune Library AEP previewed | Admin opens preview drawer | Live demo chat available (read-only AEP); admin can interact but not save changes; "Clone to customize" CTA |

---

## Flow B: Attack sequence creation (node-based editor)

### Happy path

1. Admin navigates to **Red Team → Attack Library**.
2. Admin clicks **"Create Attack."**
3. Node-based editor canvas opens with an empty sequence.
4. From the left palette, admin drags an **SMS node** onto the canvas. Node appears as the first step.
5. Admin clicks the SMS node. Configuration drawer opens (480px).
6. Admin writes the SMS message content (first contact), sets delay: "Send immediately."
7. Admin closes the drawer. Admin drags a **Voice node** onto the canvas. It appears as step 2, connected by an arrow from the SMS node.
8. Admin clicks the Voice node. Drawer opens: "This step is human-executed. Add talking points for your operator." Admin writes the voice script guide.
9. Admin sets delay: "Send 30 minutes after previous step."
10. Attack sequence: SMS → Voice (30 min delay). Admin clicks **"Save & Activate."**
11. Attack appears in the Attack Library table with channel badges "SMS / Voice" and step count "2".

### Decision points

| Decision | Condition | Outcome |
|---|---|---|
| Admin adds a channel node for an unconfigured tenant channel | WhatsApp/Viber not provisioned | Node appears in palette as locked; dragging locked node shows tooltip: "This channel is not configured for your organization." |
| Admin tries to connect a locked channel node | Tenant does not have that channel | Cannot connect; inline guidance: "Contact your admin to enable this channel." |
| Admin tries to save with no nodes | Empty sequence | "Save & Activate" blocked; inline error: "Add at least one step before activating." |
| Admin navigates away with unsaved changes | Unsaved edits | Confirmation modal: "You have unsaved changes. Discard or keep editing?" |
| Admin deletes attack used by scheduled campaign | Attack referenced by active/pending campaign | Hard block: "This attack is used by [N] campaigns. Archive or re-assign those campaigns before deleting." |

---

## Flow C: Campaign creation and approval

### Happy path

1. Admin navigates to **Red Team → Campaigns**.
2. Admin clicks **"Create Campaign."**
3. **Step 1 — Campaign Details:** Admin enters name "Q3 Engineering Simulation", selects start date (next Monday), selects allowed days (Mon–Fri), sets time window (9 AM–5 PM, America/New_York). Clicks "Continue."
4. **Step 2 — Build Attack Flow:** Admin lands on the node editor canvas. A default flow is pre-configured: Initial Contact → (If replied: AEP Active) / (No reply after 3 days: Nudge → AEP Active / End).
   - Admin clicks the Initial Contact node. Selects SMS channel. Writes the opening message.
   - Admin taps the AEP node on the "If replied" branch. Selector opens — admin picks "AEP-001 · Information Gathering."
   - Admin reviews the pre-configured Nudge node (3-day delay, SMS). Writes the follow-up message.
   - Admin clicks **"+ Add nudge"** to add a second nudge at 7 days. Writes that message.
   - Admin clicks "Continue."
5. **Step 3 — Audience:** Admin selects the "Finance Team" group. Coverage indicator: "47 of 52 members have phone numbers (90%)." No cooldown conflict. Clicks "Continue."
6. **Step 4 — Remediation:** Admin enables "If employee is marked complicit → Assign Wire Transfer Fraud Awareness training." Clicks "Continue."
7. **Step 5 — Review + Request Start:** Admin reviews summary cards (AEP, attack flow, audience, remediation). Checks compliance acknowledgment checkbox. "Request Campaign Start" activates. Admin clicks "Request Campaign Start."
8. Campaign status changes to **"Pending Approval."** Toast: "Request submitted. Your Red Team Approver will be notified."
9. **Approver receives notification** (email/in-app). Approver navigates to the pending campaign. Reviews configuration. Clicks **"Approve."**
10. Campaign status changes to **"Approved."** Campaign activates automatically on start date.
11. On start date: campaign status changes to **"Active."** Initial Contact messages begin sending to audience.

### Decision points

| Decision | Condition | Outcome |
|---|---|---|
| AEP not selected on Step 2 | Admin tries to continue without picking an AEP | Continue disabled; AEP node shows prompt: "Tap to select an AEP" |
| Initial Contact message empty | Admin tries to continue | Continue disabled; node shows inline error: "Add an opening message before continuing." |
| Nudge node message empty | Admin added a nudge but left message blank | Continue disabled; nudge node shows inline error |
| Channel not configured for tenant | Admin selects WhatsApp/Telegram on a node | Channel chip locked; tooltip: "This channel is not configured for your organization." |
| No AEPs available | AEP library empty | AEP node shows error state; Continue blocked; "Contact Dune Security" guidance shown |
| No Red Team Approver configured | Tenant has no approver role assigned | Inline callout in Step 5: "No approver configured. Go to Settings → Red Team → Configure Approver." Request Start CTA disabled. |
| Compliance checkbox unchecked | Admin tries to submit | Request Start CTA disabled; tooltip: "Confirm the compliance statement before requesting start." |
| Audience coverage 0% | Group has no phone numbers | Hard block at Step 3; Continue disabled; resolution path shown |
| Admin withdraws request | Campaign in Pending Approval state | Campaign returns to Draft; approver notified that request was withdrawn |
| Approver rejects | Approver clicks "Reject" with optional reason | Campaign returns to Draft; admin notified with rejection reason |
| Campaign approved but start date passed | Approval granted after start date | Inline callout on campaign detail: "Start date has passed. Update the start date before the campaign can activate." CTA: "Edit campaign." |

---

## Flow D: Conversation review and complicity marking

### Happy path

1. Campaign is Active. Employees receive attack contacts and some respond.
2. Admin navigates to **Red Team → Conversations**.
3. Conversations table shows threads filtered to "Pending Review." Table row: [Finance Team employee] / Q2 Red Team Campaign / Last reply: "Yes, I can help with that transfer." / Status: Pending Review.
4. Admin clicks **"Review"** on the thread row.
5. **Thread detail panel opens (480px drawer or full-page):**
   - Conversation transcript: Attacker: "Hi [Name], I need you to process an urgent wire transfer..." → Employee: "Yes, I can help with that transfer."
   - VEP step indicator: "Exchange 2 of 2 — Terminal node. Employee has engaged with the escalation message."
   - System-suggested flag (if enabled): "This response suggests engagement. Consider marking as complicit."
6. Admin reviews the exchange. Clicks **"Mark as Complicit."**
7. **Confirmation modal:** "Mark [Employee Name] as complicit in Q2 Red Team Campaign? This will update their risk score and trigger configured remediation rules." → Admin clicks "Confirm."
8. Thread status changes to **"Complicit."** Risk score updates. Remediation rule fires (training assigned).
9. Admin closes thread and reviews the next pending thread.

### Decision points

| Decision | Condition | Outcome |
|---|---|---|
| Thread has no employee reply | Employee never responded | Status "No Response"; admin can still mark non-complicit explicitly, or leave as "No Response" |
| Admin marks complicit on a thread with only one short exchange | Insufficient signal | No hard block, but inline guidance: "This conversation has only one exchange. Ensure you have sufficient signal before marking." |
| Admin wants to reverse a complicit marking | Thread already marked Complicit | "Change marking" action available; reversal confirmation modal: "Remove complicit marking for [Name]? Their risk score will be adjusted." Optional reason field. |
| Bulk marking | Admin selects multiple threads | "Mark selected as…" dropdown → Complicit / Non-Complicit. Confirmation: "You are marking [N] conversations as Complicit. This will update their risk scores and trigger remediation rules." |
| Admin closes thread without marking | Thread remains in Pending Review | Counter on Conversations sub-nav badge updates; unreviewed count persists |

---

## System responses

| System event | Product response |
|---|---|
| Campaign created (Draft) | Appears in Campaigns list with Draft status; all wizard steps resumable |
| "Request Campaign Start" submitted | Status → Pending Approval; approver notification sent; toast shown to admin |
| Approver approves | Status → Approved; admin notification sent; campaign queued for start date |
| Approver rejects | Status → Draft; admin notification with rejection reason; rejection note visible on campaign detail |
| Campaign start date reached | Status → Active; attack sequences begin orchestration |
| Attack SMS node fires | SMS sent to employee; contact record created in Conversations |
| Attack Voice node (human-executed) | Operator prompted; conversation record created manually when operator logs the call |
| Employee replies to SMS | Reply threaded to conversation record; status updates to "Replied — Pending Review"; counter on Conversations nav badge increments |
| Complicity marked (Confirmed) | Thread status → Complicit; risk score update queued; remediation rules evaluated; audit log entry created |
| Non-complicit marked | Thread status → Non-Complicit; no risk score impact; audit log entry created |
| Complicity reversal confirmed | Thread status reverted; risk score adjustment queued; reversal logged in audit trail |
| Remediation rule fires | Training assigned / manager notified / ServiceNow ticket created per configured rules |
| Campaign end date reached | Status → Completed; all conversation threads locked; final stats rendered |
| Campaign force-cancelled | Status → Cancelled; remaining sends stopped; existing threads remain reviewable |

---

## Edge cases

| Edge case | Handling |
|---|---|
| AEP library empty at campaign creation Step 2 | Hard block empty state: "No VEPs available. Contact Dune Security." + "Create VEP" secondary CTA |
| Attack library empty at campaign creation Step 3 | Hard block empty state: "Create your first attack in the Attack Library." + primary CTA |
| Attack uses tenant-unconfigured channel | Warn in Step 3; admin must acknowledge to continue; channel nodes locked in Attack Library |
| No approver configured | Warning callout in Step 6; Request Start CTA disabled; link to Settings → Configure Approver |
| Audience 0% phone coverage | Hard block at Step 4; same resolution path as smishing |
| Approver account inactive | Approver notification undeliverable; system escalates to tenant admin with notification |
| Campaign approved but start date passed | Inline callout on campaign detail; edit start date CTA |
| Attack node fails mid-sequence | Per-employee: attack halted; conversation thread shows "Delivery failed — [node type] step [N]"; campaign continues for other employees |
| Employee replies in non-English | Reply displayed in thread as-is; system-suggested flag disabled for that thread; admin reviews manually |
| Employee replies STOP | Immediate removal from send queue; opt-out record created; thread status "Opted out" |
| Admin edits VEP while campaign is active | Hard block: "This VEP is used by [N] active campaigns. Changes cannot be made while campaigns are active." |
| Admin closes conversation review without marking | Thread remains "Pending Review"; Conversations nav badge count persists |
| Bulk complicity marking — 50+ conversations | Bulk action available in campaign Conversations tab and in cross-campaign Conversations section; confirmation modal shows count |
| Complicity reversal | "Change marking" action on any marked thread; confirmation modal with optional reason; audit log updated |
| Campaign force-cancelled mid-send | Remaining sends stop; active conversation threads remain open for review; completed threads remain marked |

---

## Exit states

| Exit state | How reached | What happens |
|---|---|---|
| Campaign in Draft | Admin saves at any wizard step, or request is rejected | Saved with current state; Draft badge in list |
| Campaign in Pending Approval | Admin submits Request Start | Approver notified; status "Pending Approval" |
| Campaign Approved | Approver approves | Campaign queued for start date; status "Approved" |
| Campaign Active | Start date reached | Attack orchestration begins; status "Active" |
| Campaign Completed | End date reached | All threads locked; final stats rendered; status "Completed" |
| Campaign Cancelled | Admin force-cancels | Sends stop; threads remain reviewable; status "Cancelled" |
| Conversation Complicit | Admin marks + confirms | Risk score updated; remediation triggered; thread locked to Complicit status (reversible) |
| Conversation Non-Complicit | Admin marks | Thread closed with Non-Complicit status; no risk impact |
| Conversation No Response | Campaign completes with no employee reply | Thread status "No Response"; not counted in risk signals |
| Request Start withdrawn | Admin withdraws pending request | Campaign returns to Draft; approver notified |
