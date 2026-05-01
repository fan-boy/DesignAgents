# Design Strategy — SMS Phishing (Smishing) Simulation
Dune Security · Design Strategy · Last updated: 2026-05-01 · Updated with full PRD.

---

## Feature context

**Goal:** Let security teams run controlled SMS phishing simulations, measure user behavior per graduated risk signals, and trigger targeted remediation from existing risk-management workflows.

**Primary users:** Security admin / awareness owner. Secondary: SOC/IR lead, people manager, end user.

**Trigger:** Admin wants to test and measure employee resilience to SMS-based social engineering, then act on results.

**Success:** Admin creates and launches a campaign in under 10 minutes. Results are accurate, risk scores update within 60 seconds, and remediation fires automatically on configured triggers.

**PRD-confirmed constraints:**
- v1 = SMS-only, US-first (limited supported-region beta)
- Template-based personalization only in v1 (approved library + light customization)
- No real credential, OTP, or sensitive data collection at any time
- Phone numbers stored as hashes, not raw values
- Customer owns legal basis (TCPA/GDPR); Dune provides admin acknowledgment at creation
- Architecture must be extensible to WhatsApp, Signal, Telegram, QR-code lures, and vishing from day one
- Risk scoring: graduated model with separate weighting from email phishing
- Remediation Agent integration is a Must requirement

**Still-open constraints that affect design:**
- Phone number sourcing strategy (HRIS, CSV, manual) — Phase 0 discovery
- Exact risk-weighting values for each signal
- Approval workflow scope for high-sensitivity templates
- Template customer-editability in v1 (full custom vs. token-substitution only)
- Sender identity (short code, 10DLC, toll-free) — Should priority, not decided

---

## Design goal

Enable a security admin to configure, test, and launch an SMS phishing simulation campaign — including remediation automation — in under 10 minutes, using a guided wizard that is additive to the existing simulation workflow, not a replacement for it.

---

## Strategy options

### Option A: Extend the existing campaign wizard with a channel selector

Add "Smishing" as a channel type at wizard step 1 alongside Email. All subsequent wizard steps adapt to the selected channel. This is the minimal-new-surface approach.

**Pros:** Reuses patterns admins already know. Minimal new navigation.

**Cons:** The PRD explicitly specifies a dedicated Simulations → Smishing navigation path, suggesting the product team envisions this as a distinct section. A channel selector at wizard step 1 would work technically, but it diverges from the PRD-stated navigation intent and makes the smishing campaign list harder to reach without going through the email wizard entry point.

---

### Option B: Dedicated Smishing section under Simulations (recommended, PRD-aligned)

Add "Smishing" as a sub-nav item under Simulations. The Smishing section has its own campaign list and "Create Campaign" entry point. The creation wizard is purpose-built for SMS but uses identical DS wizard components and identical patterns for audience targeting, scheduling, and review that the email phishing wizard uses.

**Pros:** Matches the PRD-stated navigation path (Simulations → Smishing). Makes the smishing campaign list independently accessible. Campaign list and reporting are scoped to SMS, making cross-channel comparison an explicit product decision rather than a filter. Easier for admins to find smishing results without parsing email and SMS campaigns in a combined list.

**Cons:** Slightly more navigation surface than Option A. The wizard is technically a parallel implementation of some shared patterns (audience selector, schedule picker) — these must be DS-governed components, not one-offs.

---

### Option C: Channel-first unified campaign wizard

Redesign the campaign creation wizard to support multiple channels (email + SMS) simultaneously. Not recommended for v1.

**Rejected for v1:** Significantly higher complexity; requires both channels to be production-ready simultaneously; correct long-term direction but wrong v1 scope.

---

## Recommended strategy: Option B (PRD-aligned dedicated Smishing section) with multi-channel-capable data model

Use a dedicated "Simulations → Smishing" sub-nav section with its own campaign list and creation wizard. The wizard is SMS-specific but shares DS components with the email phishing wizard. The underlying campaign data model uses `type = smishing` within a shared campaign entity that supports future multi-channel types.

The wizard has 7 steps:
1. Audience
2. Message
3. Sender + Landing Page
4. Delivery
5. Remediation
6. Test Send
7. Review + Launch

This matches the PRD's recommended flow (§8.1) and ensures all Must requirements (test send, remediation config) are first-class steps rather than advanced settings.

---

## Risks and tradeoffs

**What Option B gives up vs. Option A:** Admins must navigate to the Smishing section to see SMS campaigns — they can't see all simulation campaigns in a unified list without a future cross-channel campaign view. This is acceptable if the cross-channel comparison view (Should priority per PRD §7.4) ships within a cycle or two of smishing.

**Approval workflow design dependency:** If high-sensitivity templates require approval (PRD §16.7, unresolved), the campaign flow gains an "Awaiting Approval" state between Review+Launch and live delivery. The Review step must be designed now with this state in mind — the Launch button becomes "Submit for Approval" in that configuration. Design for both states.

**Phone coverage cold-start:** Without a clear phone number sourcing path (Phase 0 discovery), the audience step will frequently dead-end. The empty coverage state must have an immediately actionable resolution path (CSV upload, HRIS sync prompt) or the campaign creation experience will feel broken on day one.

**Graduated risk scoring UI complexity:** Five event types (delivered, clicked, submitted, reported, training_completed) require a reporting UI that surfaces each distinctly. A simple click-rate metric is insufficient and misrepresents the PRD's intent. The campaign detail view must show all five event types — this is a more complex table than the current email phishing result view.

**Credential-harvest and MFA-harvest template safety:** Simulated login forms (credential harvest) and verification code forms (MFA harvest) are confirmed v1 simulation types per PRD §7.2, §9. The design must enforce zero data collection at the UI level through three layers: (1) client-side — form submit handler fires event + redirect only, no data serialization; (2) server-side — endpoint accepts no payload beyond the campaign token; (3) admin UI — the form safety lock callout on Screen 1a is non-dismissible and explicitly states this. The coaching page must always follow the form page immediately on submit — no intermediate page that could be confused for a real service.

---

## Wireframe plan

### Screen 0: Simulations navigation — Smishing sub-nav (entry)

**Role:** Navigation-level entry point to the smishing section.

**Layout:** Existing Simulations nav section gains a "Smishing" sub-item alongside existing items (e.g., Email Phishing, Training). Sub-item links to the Smishing campaign list.

**DS pattern:** Existing side-nav pattern. No new component needed.

---

### Screen 1: Smishing section — Campaigns + Templates tabs

**Role:** The Smishing section has two tabs: Campaigns and Templates. Both are accessible from the same top-level Smishing nav item. The Campaigns tab is the default view.

**Layout:** Page header with tab bar. Tab bar renders above the content area using the existing Stillsuit DS v2 tab pattern.

**Tab: Campaigns (default)**
- Page header: "Smishing" + tab bar ("Campaigns" | "Templates")
- "Create Campaign" (primary button, top right)
- Table columns: Name / Status badge / Audience / Sent / Click rate / Created date / Actions (…)
- Status badges: Draft / Scheduled / Sending / Completed / Paused / Archived
- Filtering: by status, date range, group/department
- Empty state: "No smishing campaigns yet. Run your first simulation to measure SMS risk across your organization." + "Create Campaign" CTA

**Tab: Templates**
- "Create Template" (primary button, top right)
- Table columns: Name / Category / Difficulty badge / Source badge (Dune Library / Custom) / Status / Last modified / Actions (…)
- Source badge distinguishes Dune-provided templates (read-only) from customer-created templates (editable)
- Actions for Dune Library templates: Preview / Clone
- Actions for Custom templates: Edit / Clone / Archive
- Filtering: by category, difficulty, source (Dune Library / Custom), status
- Empty state for Custom section: "No custom templates yet. Create a template or clone a Dune Library template to get started." + "Create Template" CTA

---

### Screen 1a: Template creation / edit form

**Role:** Full-page form for creating or editing a customer template. Also serves as the clone-and-customize flow for Dune Library templates. Accessed from the Templates tab or from within the campaign wizard (via drawer — see Screen 3).

**Layout:** Single-page form with three clearly delineated sections. No wizard — all sections visible simultaneously, since message and coaching content are interdependent and admins benefit from seeing both while writing. Sticky header with Save actions.

**Header:**
- Template name field (inline editable, placeholder: "Untitled Template")
- Status badge: Draft / Active
- "Save Draft" (ghost button) + "Save & Activate" (primary button)
- Back link to Templates tab

**Section 1 — Template details:**
- **Simulation type:** segmented control — "Link only" (default) / "Credential harvest" / "MFA harvest." This field determines what landing page the employee sees, what events are recorded, and what remediation rules are available. Cannot be changed after a template has been used in a completed campaign.
  - *Link only:* SMS lure links to the coaching/debrief page only. No form presented to the employee.
  - *Credential harvest:* Landing page shows a simulated login form (username + password fields). On submit, Dune records `smishing_credential_submitted`; no data is transmitted or stored. Debrief page follows immediately.
  - *MFA harvest:* Landing page shows a simulated verification code form (single-field OTP/code input). On submit, Dune records `smishing_mfa_submitted`; no data is transmitted or stored. Debrief page follows immediately.
- Category: dropdown matching PRD §7.2 categories (IT Account Verification / MFA Reset & Security Alert / HR Benefits & Payroll / Package Delivery / Finance & Payment / Executive Impersonation / Travel Alerts / QR Code Follow-up / Event Registration / E-Signature & Document Review)
- Difficulty: segmented control (Easy / Medium / Hard)
- Recommended audience: multi-select tag input (groups, departments, or cohort types)
- Risk tags: free-form tag input (e.g., "credential-harvest", "urgency", "impersonation")
- Compliance notes: optional text area for internal documentation

**Section 2 — SMS message:**
- Identical component to the campaign wizard's Step 2 message editor: text area + live character counter + encoding detection + variable token chips ([First Name] [Company] [Department])
- 360px SMS bubble preview panel (right side on desktop, below editor on mobile)
- Credential-harvest warning (conditional): same warning as in campaign Step 2 — appears if the message body or risk tags suggest a form-submission lure

**Section 3 — Landing page configuration:**

*Varies by simulation type. The section header and available fields change based on the Simulation type selected in Section 1.*

**If Simulation type = Link only:**
- Section header: "Coaching page"
- Four labeled text fields matching PRD §13 structure:
  - Hook (required): "This was a simulated text-message attack." — pre-filled, editable
  - Red flags (required): bullet list editor, minimum 2 items, maximum 5
  - Correct behavior (required): single text field — 1–2 sentences
  - Micro-commitment (optional): single text field — the pledge the employee makes
- Mobile preview panel: renders coaching page at 375px as the employee will see it
- Guardrail: inline error if any coaching page field contains a form element or credential prompt — hard block on activation

**If Simulation type = Credential harvest:**
- Section header: "Simulated login form + Coaching page"
- **Form configuration (sub-section, rendered above coaching content):**
  - Page title field: shown at top of the form (e.g., "Sign in to your account") — required
  - Logo / brand: optional image upload (bounded; Dune-hosted; simulated company branding only)
  - Username field label (e.g., "Email address" / "Username") — required
  - Password field label (e.g., "Password" / "Passcode") — required
  - Submit button label (e.g., "Sign in" / "Continue") — required
  - Form safety lock: read-only callout, cannot be disabled — "No data entered into this form is transmitted, stored, or accessible. The submit action fires a risk signal and immediately serves the coaching page."
- Coaching content fields: same four fields (Hook / Red flags / Correct behavior / Micro-commitment)
  - Hook pre-fill: "This was a simulated login page. No information you entered was stored."
- Mobile preview panel: two-screen preview — form screen + coaching screen, swipeable
- Guardrail: inline warning (not hard block) if the form title or brand closely matches a real SSO provider Dune can detect (e.g., Okta, Microsoft, Google Workspace); admin must acknowledge before saving.

**If Simulation type = MFA harvest:**
- Section header: "Simulated verification form + Coaching page"
- **Form configuration (sub-section):**
  - Page title field (e.g., "Enter your verification code") — required
  - Instruction text (e.g., "We sent a 6-digit code to your mobile number.") — required
  - Code field label (e.g., "Verification code" / "One-time passcode") — required
  - Submit button label (e.g., "Verify" / "Continue") — required
  - Form safety lock: same read-only callout — no data transmitted or stored
- Coaching content fields: same four fields
  - Hook pre-fill: "This was a simulated MFA phishing page. No code you entered was stored or used."
- Mobile preview panel: two-screen preview — form screen + coaching screen
- Guardrail: same SSO-impersonation warning as credential harvest

**Permission states:**
- Dune Library template (accessed via Clone): all fields pre-filled and editable; source changes to "Custom" on save; original Dune template is unaffected
- View-only admin: form is read-only; Save buttons hidden

**Edge cases:**
- Admin saves as Draft with incomplete required fields: allowed; Draft status means the template cannot be selected in a campaign
- Admin attempts to activate a template with incomplete required fields: activation blocked with inline field-level errors showing what is missing
- Admin clones a Dune Library credential-harvest template: credential warning callout and SSO-impersonation guardrail check trigger immediately on page load
- Template name already exists: inline validation error below the name field on save attempt
- Character limit exceeded in message: same encoding warning as campaign wizard; Save is not blocked but the template cannot be activated until resolved
- Admin attempts to change Simulation type on a template used by a completed campaign: hard block — "Simulation type cannot be changed after a template has been used in a campaign. Clone this template to create a new version."
- Admin attempts to change Simulation type on a template used by a scheduled campaign: hard block with same message; scheduled campaign must be cancelled or its template swapped before type change is allowed
- Credential/MFA form title closely matches a known SSO provider: inline warning with provider name — "This form title resembles [Okta / Microsoft / Google Workspace] sign-in. Ensure your template doesn't prompt employees to enter real credentials." Admin must acknowledge. Not a hard block.
- Password manager browser extension autofills the simulated form fields during preview: expected behavior in preview; no action needed. Note in Section 3 helper text: "Employees using password managers may see an autofill prompt. No data entered is stored."

---

### Screen 2: Campaign wizard — Step 1: Audience

**Role:** Admin defines who receives the campaign. Supports users, groups, departments, risk cohorts, and CSV import.

**Layout:** Wizard frame (Stillsuit DS v2 wizard pattern). Step bar shows 7 steps, step 1 active.

**Key components:**
- Audience selector: searchable dropdown supporting groups, departments, locations, risk cohorts (new cohort type — flag for DS review)
- Import CSV toggle: "Or upload a recipient list" (opens CSV upload drawer)
- Phone coverage indicator (below selector): "428 of 512 members have phone numbers (84%)" — progress bar + count
- "View coverage gaps →" link — opens phone coverage drawer (480px)
- Cooldown warning: inline callout if group was recently simulated
- Exclusion window conflict: inline warning if scheduled time (from Step 4) conflicts

**Phone coverage drawer (480px, Stillsuit DS v2 drawer pattern):**
- Coverage summary: donut metric, count of missing/invalid
- Table: members without phone numbers (name, department)
- Actions: "Download CSV for IT" / "Configure HRIS sync" (if integration available)
- Empty state: "All members have phone numbers on file."

**Permission states:**
- Admin without PII access: percentage only, no "View coverage gaps" link, tooltip explaining restriction
- 0% coverage: hard-block callout with resolution path; Continue button disabled
- View-only admin: read-only

---

### Screen 3: Campaign wizard — Step 2: Message

**Role:** Admin selects a template and customizes message content. v1 = Smart Templates (approved library + token substitution). Future: AI personalization.

**Layout:** Two-column. Template library (left, scrollable) + SMS preview panel (right, 360px device frame).

**Key components:**
- Template library: category tabs matching PRD §7.2 (IT Account Verification / MFA Reset & Security Alert / HR Benefits & Payroll / Package Delivery / Finance & Payment / Executive Impersonation / Travel Alerts / QR Code Follow-up / Event Registration / E-Signature & Document Review)
- Template card: name, preview (truncated), difficulty badge (Easy / Medium / Hard), recommended audience chip
- Message editor: text area with live character counter ("118 / 160 · GSM-7")
- Encoding warning banner: appears when Unicode characters detected; limit updates to 70
- Variable token chips: [First Name] [Company] [Department] rendered in both editor and preview
- Preview panel: 360px SMS bubble (sender number + message body)
- Section header: "Smart Templates" — not "AI-generated." Tooltip: "Templates are based on real smishing lure patterns and personalized with employee details."

**Simulation type indicator (always visible when a template is selected):**
When any template is selected, a badge below the template name shows the simulation type: "Link only" / "Credential harvest" / "MFA harvest." This is read-only in the wizard — type is set on the template.

**Credential-harvest template warning (conditional):**
When admin selects a template with Simulation type = Credential harvest or MFA harvest:
- Inline warning callout (color/feedback/warning):
  - Credential harvest: "This template includes a simulated login form. No real credentials will be collected or stored. The employee will see the coaching page immediately after submitting."
  - MFA harvest: "This template includes a simulated verification form. No real codes will be collected or stored. The employee will see the coaching page immediately after submitting."
- Admin must acknowledge (checkbox) to proceed past this step.
- The acknowledgment is per-session, not per-template — admin must re-acknowledge each time they pass this step with a credential or MFA template.

**In-wizard template creation:**
- "Create new template" link below the template library panel — opens a 480px drawer (Stillsuit DS v2 drawer pattern)
- Drawer contains a simplified version of the full template creation form: Section 2 (message) + Section 3 (coaching page) only. Template metadata (category, difficulty, tags) defaults to values inferred from context or left as "Uncategorized/Draft."
- On save, the new template appears at the top of the template library with a "New" chip, and is automatically selected for this campaign.
- Admin can complete template metadata later from the Templates tab.
- "Manage templates →" link below the library panel navigates to the full Templates tab (leaves the wizard; unsaved campaign state is preserved as a Draft).

**Edge cases:**
- Empty template library on first use: empty state + "Create your first template" primary CTA + "Browse Dune Library" secondary CTA — no longer requires requesting from an account manager
- Template in use by an active campaign: template cannot be archived; inline tooltip on archive action: "This template is used by [N] active campaigns."
- Character limit exceeded: counter turns red; continue button remains enabled but inline warning shows below editor
- Unicode encoding breach: encoding warning banner; limit updates; admin can resolve by removing Unicode characters

---

### Screen 4: Campaign wizard — Step 3: Sender + Landing Page

**Role:** Admin confirms the sender identity and selects or configures the coaching/landing page employees see after clicking.

**Layout:** Standard wizard step. Two stacked sections.

**Sender section:**
- Sender number: read-only field showing Dune-managed number (10DLC or pool). Tooltip: "Sender numbers are managed by Dune Security to comply with carrier requirements."
- Future: branded sender profile selector (Should priority per PRD)

**Landing page section:**

*This section renders differently based on the Simulation type of the selected template. The simulation type is shown as a read-only badge at the top of this section.*

**If Simulation type = Link only:**
- Landing page selector: dropdown of approved coaching pages, organized by template category
- Preview link: "Preview landing page →" opens a modal with mobile-viewport preview (375px)
- Custom coaching page: "Customize" option opens a light inline editor for the four content blocks from PRD §13: Hook / Red flags / Correct behavior / Micro-commitment
- Guardrail: if admin edits a coaching page and adds any form element, inline error: "Link-only coaching pages cannot contain form fields. Remove the form to continue." — hard block on Continue.

**If Simulation type = Credential harvest:**
- Read-only summary of the simulated form configured in the template:
  - Page title / Username label / Password label / Submit label
  - "Edit form →" link navigates to the template in a new tab (cannot edit form config inside the wizard)
- Coaching page: same selector + "Customize" option as Link only
- Safety confirmation callout (cannot be dismissed): "This campaign will present a simulated login form to employees. No data entered is transmitted or stored. Employees are redirected to the coaching page immediately on submit."
- Preview: "Preview credential form + coaching page →" opens a 2-screen mobile preview (form → coaching) in a modal

**If Simulation type = MFA harvest:**
- Read-only summary of the simulated form: Page title / Instruction text / Code field label / Submit label
- "Edit form →" link navigates to template
- Same coaching page selector + "Customize" option
- Safety confirmation callout: "This campaign will present a simulated MFA verification form to employees. No codes entered are transmitted or stored."
- Preview: "Preview MFA form + coaching page →" — 2-screen mobile preview

---

### Screen 5: Campaign wizard — Step 4: Delivery

**Role:** Admin sets the schedule and delivery behavior.

**Layout:** Standard wizard form.

**Key components:**
- Schedule: date/time picker with timezone selector (defaults to detected timezone)
- Delivery spread: toggle (default ON) — "Spread delivery over [4 hours]" — options: 1h / 2h / 4h / 8h. Helper text: "Messages are sent at random intervals within this window to increase realism."
- Throttle: for large groups, throttle rate shown (Eng-determined; read-only in v1)
- Region/carrier note: "Sending is currently supported in [US only]. International recipients will be excluded." — rendered if group contains international numbers

**Edge cases:**
- Schedule set to past: inline date picker validation error
- Timezone not detected: defaults to UTC with inline prompt

---

### Screen 6: Campaign wizard — Step 5: Remediation

**Role:** Admin configures what happens automatically when employees interact with the simulation. This is a Must requirement per PRD §7.6.

**Layout:** Rule-builder panel. Each rule is an if/then card.

**Key components:**
- Pre-built rule cards (PRD §7.6 examples, each toggle-able ON/OFF). Cards shown depend on the simulation type of the selected template:
  - **All simulation types:**
    - "If user clicks link → Assign [module selector] training"
    - "If user fails 2+ smishing simulations in 90 days → Notify manager"
  - **Credential harvest templates only:**
    - "If user submits simulated login form → Assign [module selector] training + notify manager"
    - "If user submits simulated login form → Create ServiceNow ticket" (requires ServiceNow integration enabled)
  - **MFA harvest templates only:**
    - "If user submits simulated MFA code → Assign [module selector] training + notify manager"
    - "If user submits simulated MFA code → Create ServiceNow ticket" (requires ServiceNow integration enabled)
  - A simulation-type label above the rule cards: "Rules for [Link only / Credential harvest / MFA harvest] campaigns" — so admins know why certain rules appear or not
- Module selector: searchable dropdown of available training modules, including new modules from PRD §13: Smishing & Mobile Scam Awareness / MFA Code Theft / Executive Impersonation by Text / Payroll & HR Text Scams / Delivery & QR-Code Scams / Messaging-App Account Takeover
- "Add custom rule" (ghost button): opens rule-builder drawer (480px) — for power users
- "Test remediation" toggle: allows admin to test trigger logic without sending real emails or tickets (PRD §9, Must)
- "Skip remediation" option: all rules set to OFF; admin can proceed without any automation

**RBAC states:**
- ServiceNow rule is disabled with tooltip if ServiceNow integration is not configured: "Enable ServiceNow integration in Settings to use this rule."
- Manager notification rule is disabled with tooltip if manager mapping is not set up in user profiles

---

### Screen 7: Campaign wizard — Step 6: Test Send

**Role:** Admin sends a preview message to 1–5 internal recipients before launching to the full audience. Confirms delivery, message rendering, landing page, and remediation rules in a safe context. Must requirement per PRD §9.

**Layout:** Simple form within wizard step.

**Key components:**
- Test recipient field: email or phone number input, accepts up to 5 recipients (comma-separated or tag input)
- "Send Test" button (primary): fires the test send
- Status indicator: "Test sent to [number]. Check your device." / error state if delivery fails
- Test send note: "Test messages are labeled [TEST] and will not affect risk scores or trigger remediation rules."
- Confirmation checkbox: "I've reviewed the test message and coaching page on a mobile device." — required to activate the Continue button
- Skip option: "Skip test send" — ghost button with warning tooltip: "We recommend testing before launching to your full audience."

**Edge cases:**
- Test recipient has no phone number (admin enters email): inline info note explaining test sends require a phone number
- Test message delivery fails: inline error with carrier reason if available
- Admin has already tested once: shows "Last tested [time ago]" with option to send another test

---

### Screen 8: Campaign wizard — Step 7: Review + Launch

**Role:** Full campaign summary before committing to launch. Final chance to catch configuration issues. Includes compliance acknowledgment.

**Layout:** Summary cards. Sticky footer with CTA.

**Key components:**
- Summary sections: Audience + coverage count / Message preview (truncated, expandable) / Sender number / Landing page name / Delivery schedule + spread / Remediation rules summary
- Coverage warning (if applicable): inline callout — "143 members will not receive this campaign (no phone number on file). [View list]" — color/feedback/warning, not danger
- Compliance acknowledgment: checkbox — "I confirm that [Company] has informed employees that Dune Security may send simulated security-awareness messages, including SMS, as part of the security training program, and that [Company] has a lawful basis for this activity." — Required before launch activates.
- Launch CTA: "Launch Campaign" (primary, disabled until compliance checkbox checked)
- "Save as Draft" (ghost button)
- Back navigation: available at all steps; form state preserved

**Edge cases:**
- 0% coverage: Launch button disabled; inline error with resolution path — only hard block
- Compliance checkbox unchecked: Launch button visually disabled; tooltip: "Confirm the compliance statement before launching."
- Test send not completed: soft warning callout, not a block — "You haven't tested this campaign. Consider sending a test before launching to your full audience."

---

### Screen 9: Campaign detail view — SMS

**Role:** Post-launch monitoring and results for a single smishing campaign.

**Layout:** Page header + graduated stats row + timeline chart + per-user results table.

**Key components:**
- Header: campaign name / "Smishing" channel badge / status badge (Sending / Completed / Delivery Slowed / Cancelled)
- Graduated stats row (5–6 metric cards, per PRD's graduated risk model; cards adapt to campaign simulation type):
  - **Link only:** Targeted → Delivered → Clicked → Reported* → Training Completed
  - **Credential harvest:** Targeted → Delivered → Clicked → Credential Submitted → Reported* → Training Completed
  - **MFA harvest:** Targeted → Delivered → Clicked → MFA Code Submitted → Reported* → Training Completed
  - Each card shows count + percentage of delivered
  - Card labels use plain language: "Credential Submitted" or "MFA Code Submitted" (not "Submitted Form") — specificity reduces admin confusion when reading results
  - "Reported" card marked with asterisk: only visible if reporting is confirmed for v1 (see open question §16.6)
- Bot-click filtered count: below the "Clicked" card — "X clicks filtered (automated scanner activity)" with info icon tooltip
- Timeline chart: click and submission events over time
- Per-user results table: Name / Department / Delivery status / Clicked / [Form event column] / Risk score delta
  - Form event column header adapts to simulation type: "Credential Submitted" / "MFA Code Submitted" / hidden for link-only campaigns
  - Risk score delta: before/after badge pairs (color/risk/* tokens), e.g., "Medium → High"
  - Repeat-offender flag: icon badge on users who have failed multiple smishing simulations
- Export button: CSV export of results (audit-log requirement per PRD §12)

**Remediation log section:**
- Separate collapsible section showing which rules fired, for which users, and outcome
- "Test Remediation" button: lets admin verify rules will fire correctly without triggering actual assignments

**Edge cases:**
- STOP reply received: banner notification + per-user status "Opted out" + send queue removal
- Carrier rate-limited: status badge "Delivery Slowed"; helper text with delivery estimate

---

### Screen 10: Campaign comparison view — Email vs. Smishing (Should priority)

**Role:** Cross-channel comparison of click rates and risk impact between email phishing campaigns and smishing campaigns. Used in QBR reporting. Should priority per PRD §7.4.

**Layout:** Dashboard-style section within the Reporting area, or a dedicated Simulations overview.

**Key components:**
- Side-by-side metric bars or table: Email phishing click rate vs. Smishing click rate by department/group/risk cohort
- Time trend: repeat-campaign improvement rate for each channel
- Export: PDF/CSV for QBR use

**Note:** Defer detailed screen design until risk-weighting values are confirmed (open question §16.5). The component structure is a table pattern — no new DS components needed.

---

### Screen 11: Employee mobile debrief landing page (new surface)

**Role:** The page an employee sees after clicking a simulated smishing link. Three distinct states based on simulation type. New mobile-first surface. Must never prompt for real credentials — in any state.

**Layout:** Single-column, mobile-first (375px baseline). Under 60 seconds to read.

---

**State A — Link only (employee clicked link directly to debrief):**

Content structure (PRD §13):
1. **Hook:** "This was a simulated text-message attack." — `color/feedback/warning` strip, not alarming
2. **Red flags:** Shows the exact message the employee received as a chat bubble + 2–3 specific red flags from this message (unfamiliar number, urgency language, unexpected link)
3. **Correct behavior:** "Pause. Verify. Report." — 3 numbered steps, one sentence each
4. **Micro-commitment:** "Next time I will pause and verify before tapping." — optional tap-to-confirm (consider for engagement metric)
5. **CTA:** "Complete a 2-minute training" — primary button, links to mobile-optimized module

---

**State B — Credential harvest (employee submitted the simulated login form; now on debrief):**

This state is reached immediately after the employee submits the fake credential form. The debrief must:
- Acknowledge that the form submission happened — never silently omit it
- Reassure the employee that no data was stored

Content structure:
1. **Hook:** "You just submitted a simulated login form." — `color/feedback/warning` strip, slightly more urgent than State A but not alarming
2. **What happened:** Screenshot or recreation of the form the employee submitted + copy: "No information you entered was stored, transmitted, or accessible to anyone. This was a safe simulation."
3. **Red flags:** Same as State A — specific red flags from the original SMS message
4. **Why this works:** 1–2 sentences on how fake MFA/credential pages work in real attacks
5. **Correct behavior:** "Pause. Verify. Report." — same 3 steps
6. **Micro-commitment + CTA:** Same as State A

---

**State C — MFA harvest (employee submitted the simulated verification code; now on debrief):**

Content structure:
1. **Hook:** "You just entered a simulated verification code." — `color/feedback/warning` strip
2. **What happened:** Recreation of the verification form + copy: "No code you entered was stored or used. This was a safe simulation."
3. **Red flags:** Specific red flags + context: "Real attackers use pages like this to steal one-time codes and take over accounts in real time."
4. **Correct behavior:** "Pause. Verify. Report." — same 3 steps
5. **Micro-commitment + CTA:** Same as State A

---

**Copy constraints (all states):** Under 150 words total. No jargon. Tone: matter-of-fact, not alarming, not condescending. Never use guilt language.

**Client branding:** [Company] logo + "Security Training" wordmark. White-label quality per product principles.

**Edge cases:**
- Desktop browser (link forwarded): page is responsive; designed mobile-first but readable at desktop widths
- Training link broken: fallback copy "Can't access training? Contact your IT security team."
- Employee navigates back to the simulated form after seeing the debrief: form page should show a "This simulation has ended" state — form fields disabled, debrief CTA shown. Prevents confusion if employee hits back button.
- Employee reloads the debrief page: debrief content remains available; `smishing_link_clicked` is not double-counted (idempotent event recording).

---

### Screen 12: Group management — Phone coverage tab (new section)

**Role:** Persistent phone number coverage health view per group. Makes data quality a first-class, actionable metric outside of campaign creation.

**Layout:** New tab within existing Group detail view.

**Key components:**
- Coverage summary: donut chart — Covered / Missing / Invalid (bad format) / Opted out (STOP replies)
- Coverage percentage badge: color/risk/* token based on threshold
- Members table: name, phone status (Verified / Missing / Invalid / Opted out), last updated
- Bulk actions: "Download missing numbers CSV" / "Notify IT team" (sends pre-formatted email)
- Import shortcut: "Upload phone numbers" opens CSV upload drawer
- HRIS sync status (if connected): "Last synced: 3 hours ago · [Configure sync]"

**Empty state:** "No phone numbers on file. Upload a CSV or connect your HRIS to get started." + primary CTA.

---

## Open issues

1. **[PM] Approval workflow scope.** If high-sensitivity templates require approval, the Launch button becomes "Submit for Approval" on Step 7. Design includes both states, but the transition logic (who approves, what triggers the approval gate) must be confirmed before the approval notification design can be finalized.

2. ~~**[PM] Template editability in v1.**~~ **Resolved.** Customer template creation is confirmed for v1. Full template management UI (creation, editing, cloning, archiving) is in scope. See Screen 1 (Templates tab) and Screen 1a (Template creation form).

3. **[PM] Reporting in scope for v1?** The "Reported" metric card in Screen 9 is designed but should only render if reporting is confirmed for v1. If not in scope, omit the card and the `smishing_reported` event from the graduated stats row.

4. **[Eng] Sender identity.** Short code vs. 10DLC changes the sender display in Screen 3's SMS preview panel and potentially the debrief copy on Screen 11.

5. **[PM/Eng] Risk-weighting values.** The graduated stats row in Screen 9 is designed. The risk score delta column is designed. Credential-submitted and MFA-submitted events are expected to carry higher risk weight than click-only events (as with email spear phishing). Confirm values and whether credential vs. MFA warrant different weights before QA.

6. **[PM] Guardrails for harmful impersonation templates.** Screen 3 includes a warning for credential-harvest and MFA-harvest templates but not yet for templates that impersonate emergency services, legal notices, or government entities. This needs a content policy decision before the template library ships.

7. **[Eng] Credential/MFA form client-side behavior.** Confirm that the form submit handler fires the event + redirect with no data serialization at the browser layer — not just at the server layer. Password manager autofill behavior and browser "save password" dialogs are expected on credential forms; confirm no security event is triggered by autofill alone.

---

## Next design actions

1. ~~**Confirm approval workflow scope with PM (open question §16.7)**~~ — **Resolved.** No approval workflow in v1. "Launch Campaign" is the only CTA at Step 7. No "Awaiting Approval" campaign state.
2. **Design the mobile debrief landing page (Screen 11) first** — three states now defined (link-only, credential harvest, MFA harvest); no remaining blockers; highest-stakes new surface.
3. **Design Screen 1a (Template creation form)** — now confirmed in v1 scope with simulation type selector and type-conditional Section 3. Start with the segmented control + the credential/MFA form configuration sub-section; these are the riskiest new patterns requiring DS review.
4. **Align with Eng on credential/MFA form client-side behavior** (open issue 7) — must be confirmed before designing the form back-navigation "simulation ended" state.
5. **Open the Group detail view in Figma and map the phone coverage tab (Screen 12)** — most contained new admin surface, no unresolved blockers.
6. **Align with Eng on sender identity** before designing the SMS preview panel in Step 2 (Screen 3) and Screen 1a.
