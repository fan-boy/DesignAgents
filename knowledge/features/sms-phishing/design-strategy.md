# Design Strategy — SMS Phishing (Smishing) Simulation
Dune Security · Design Strategy · Last updated: 2026-05-01

---

## Feature context

**Goal:** Extend Dune's AI-personalized phishing simulation to the SMS channel. Security admins run smishing campaigns against employee phone numbers, track interactions, and trigger remediation.

**Primary user:** Security admin configuring and launching simulation campaigns.

**Trigger:** Admin wants to test employee resilience to SMS-based social engineering attacks.

**Success:** Admin can create and launch an SMS simulation campaign, see accurate delivery and click results, and trust that those results feed correctly into risk scores.

**Key constraints:**
- No existing phone number data model in Dune — net-new infrastructure
- TCPA compliance required — legal clearance not yet confirmed
- Standard SMS limited to 160 characters (GSM-7) or 70 characters (Unicode)
- v1 personalization scope unconfirmed (AI vs. template-based)
- Risk scoring integration for SMS click signal not yet designed
- Sender identity strategy (short code, 10DLC, toll-free) not decided

---

## Design goal

Enable a security admin to configure, launch, and review an SMS phishing simulation campaign using the same campaign workflow they already know, while handling the SMS-specific constraints (phone coverage, character limits, legal disclosure, mobile debrief) with clarity and without requiring new mental models.

---

## Strategy options

### Option A: Channel-extended existing wizard (recommended)

Extend the existing email phishing campaign wizard with a channel type selector at step 1. SMS-specific screens replace email-specific screens for the relevant wizard steps (message creation, sender configuration). The campaign data model treats email and SMS as parallel channel types within a shared campaign entity. All existing patterns — group targeting, scheduling, exclusion windows, review-before-launch — carry over unchanged.

**Pros:** Least new UI surface area; reuses the wizard pattern admins already know; consistent with the KnowBe4 benchmark that works; minimizes implementation scope; campaign management view requires minimal changes.

**Cons:** SMS-specific needs (phone coverage, character counter, sender number) must be introduced incrementally within wizard steps that were designed for email; the wizard may feel slightly over-fitted to the email mental model in a few spots.

---

### Option B: Dedicated SMS campaign section

Create a new "SMS Simulation" entry point in the navigation separate from the email phishing section. A new wizard, optimized from scratch for SMS.

**Rejected because:** Two parallel wizards to maintain; campaign management would split by channel when it should be unified by goal; duplicates significant logic for no meaningful UX improvement. Proofpoint took this approach and it reduced adoption.

---

### Option C: Channel-first multi-channel wizard

Redesign the campaign creation wizard to be channel-first from the start. Users choose one or more channels (email, SMS, both). The wizard adapts to show configuration steps for each selected channel. Supports coordinated email + SMS campaigns from day one.

**Rejected for v1 because:** Requires both email and SMS delivery to be production-ready simultaneously; significantly higher complexity for the first ship; harder to scope or cut if SMS delivery slips. Correct long-term direction but wrong scope for v1.

---

## Recommended strategy: Option A with Option C data model

Use Option A for the v1 UI — extend the existing wizard with a channel selector. Design the underlying campaign data model to support multi-channel (Option C's architectural benefit) so that coordinated email + SMS campaigns can be built later without retrofitting. This decouples the UI scope from the data model scope and enables the differentiated "coordinated attack simulation" capability to ship as an upgrade rather than a rebuild.

---

## Risks and tradeoffs

**What Option A gives up:** The coordinated multi-channel attack simulation (a meaningful differentiator) cannot ship in v1. Admins who want to run simultaneous email + SMS campaigns will need to create two separate campaigns and manually coordinate timing. This is acceptable for v1 if the data model is built to support multi-channel natively.

**TCPA blocker risk:** If legal does not clear the TCPA disclosure requirement before design is finalized, the wizard's review-and-launch step will need to be redesigned. Build the acknowledgment checkbox into the review step from day one — even if legal determines it's not technically required, the disclosure step is a product trust signal worth keeping.

**AI personalization gap:** If v1 ships template-based only, marketing and product messaging must be carefully calibrated. "Smart Templates" is the right framing. Dune's personalization story should not be attached to this feature until the spear phishing engine is adapted for SMS.

**Phone coverage cold-start:** The feature is immediately limited by phone number data quality. Admins who launch without a full phone number dataset will see partial delivery and may distrust the results. The onboarding path for phone data (CSV upload, HRIS sync setup) must be visible and actionable before the first campaign is created.

---

## Wireframe plan

### Screen 1: Campaigns listing page

**Role:** Existing page; minimal change.

**Layout:** Existing table layout with campaigns list.

**Changes for SMS:**
- Add a "Channel" column (or icon badge) to the campaigns table: Email / SMS.
- "New Campaign" button unchanged — channel selection happens inside the wizard.

**System content:** No change to empty state. If first SMS campaign exists, channel badge appears inline.

---

### Screen 2: Campaign wizard — Step 1: Channel selection (new step)

**Role:** Entry point into the campaign wizard. Admin selects the simulation channel before any other configuration.

**Layout:** Centered card selection layout within the wizard frame. Wizard step bar (Stillsuit DS v2 wizard pattern) at top.

**Key components:**
- Wizard step bar (step 1 of 5 highlighted)
- Two option cards: "Email Phishing" and "SMS Phishing (Smishing)"
- Each card: channel icon, channel name, one-line description, prerequisite note
- SMS card prerequisite note: "Requires employee phone numbers in group profiles."
- Future option card: "Multi-channel" marked as "Coming soon" (locked, grayed out) — signals roadmap direction without blocking v1
- Primary CTA: "Continue"

**Edge cases:**
- No phone numbers in any group: card is still selectable. The coverage gap is surfaced at Step 2 when a group is selected, not here. Do not block channel selection.

---

### Screen 3: Campaign wizard — Step 2: Target group

**Role:** Admin selects the employee group to receive the campaign. For SMS campaigns, phone coverage is surfaced inline.

**Layout:** Standard wizard step body. Group selector above the fold. Coverage indicator immediately below.

**Key components:**
- Group selector dropdown (searchable, member count displayed)
- Phone coverage indicator (SMS campaigns only): "428 of 512 members have phone numbers (84%)" — rendered as a progress bar + count below the group selector
- "View coverage gaps →" text link — opens the phone coverage drawer (480px drawer, Stillsuit DS v2 drawer pattern)
- Cooldown warning: inline callout banner if this group was simulated recently ("This group received a simulation X days ago. Consider a different group or extend the cooldown window.")
- Exclusion window conflict: inline warning if a group exclusion window overlaps the intended schedule

**Phone coverage drawer (480px):**
- Header: "Phone Coverage — [Group Name]"
- Coverage summary: donut metric + "X members missing phone numbers"
- Table: members without phone numbers (name, department, last updated)
- Actions: "Download CSV for IT" (bulk action) + close
- Empty state: "All members in this group have phone numbers on file."

**Permission states:**
- Admin without PII access: coverage indicator shows percentage only, "View coverage gaps" link is hidden, tooltip: "You don't have permission to view employee phone numbers."
- View-only admin: group selector is read-only; step is non-interactive.

**Edge cases:**
- Group with 0% phone coverage: coverage indicator renders red, inline warning: "No members in this group have phone numbers. Add phone numbers before launching."
- Group has 0 members: inline error on group selection.

---

### Screen 4: Campaign wizard — Step 3: Message

**Role:** Admin selects a template and optionally customizes the message. For v1, this is template-based (Smart Templates). For future AI personalization, this step is where personalization configuration would be introduced.

**Layout:** Two-column: template library (left, scrollable) + message preview panel (right, simulates device SMS view).

**Key components:**
- Template library panel: category tabs (IT Helpdesk / HR & Payroll / Financial Alert / Package Delivery / Executive) + template cards
- Each template card: scenario name, preview text (truncated to 2 lines), threat intelligence freshness badge (optional in v1 — flag for Eng)
- Message editor: single text area below the preview panel, live character counter ("142 / 160 · GSM-7")
- Encoding warning: inline banner when non-GSM-7 characters are detected ("Message contains special characters. Limit is now 70 characters.")
- Variable tokens: rendered as highlighted chips in both editor and preview ([First Name], [Company])
- Preview panel: renders message at 360px as a native SMS bubble (dark/light mode), showing sender number and message body

**v1 framing:** Section header reads "Smart Templates" — not "AI-generated." Tooltip on the label: "Templates are crafted from current threat intelligence patterns and adapted with your employees' names and company."

**Edge cases:**
- Empty template library (fresh tenant): empty state with CTA "Request templates from your Dune account manager."
- Character limit exceeded: counter turns red; "Continue" button remains enabled but shows inline warning below the editor. Do not block progression — warn instead.
- Unicode encoding breach: banner replaces standard counter display; character limit visually updates to 70.

---

### Screen 5: Campaign wizard — Step 4: Delivery configuration

**Role:** Admin sets the sender configuration, schedule, and delivery spread.

**Layout:** Standard wizard form layout (stacked fields).

**Key components:**
- Sender number: read-only field (Dune-managed), displays the 10DLC number or shared pool number that will appear on employee devices. Tooltip: "Sender numbers are managed by Dune Security to comply with carrier requirements."
- Schedule: date/time picker with timezone selector (defaults to the admin's detected timezone)
- Delivery spread: toggle (default ON) with dropdown — "Spread delivery over [4 hours]." Options: 1h / 2h / 4h / 8h. Helper text: "Messages are sent at random intervals within this window. This increases realism and reduces detection."
- Optional: cooldown setting override (advanced, collapsed by default)

**Edge cases:**
- Schedule set to past: inline date picker validation error.
- Timezone not detected: defaults to UTC with an inline prompt "Your timezone couldn't be detected. Verify before scheduling."

---

### Screen 6: Campaign wizard — Step 5: Review + launch

**Role:** Admin reviews the full campaign before committing to launch. Last chance to catch coverage issues, confirm the TCPA acknowledgment, and understand exactly what will happen.

**Layout:** Summary card layout. Sticky footer with primary CTA.

**Key components:**
- Summary sections: Target group + coverage count / Message preview (truncated, expandable) / Sender number / Schedule + delivery spread
- Coverage warning callout (if applicable): "143 members will not receive this campaign — no phone number on file. [View list]" — `color/feedback/warning` token, not danger. Warning icon + label, never color alone.
- TCPA acknowledgment: checkbox + label: "I confirm that employees have been informed that Dune Security may send simulated security awareness messages, including SMS, as part of the [Company] security training program." — Required to be checked before launch button activates.
- Launch CTA: "Launch Campaign" (primary button, disabled until TCPA checkbox is checked)
- Secondary: "Save as Draft" (ghost button)
- Back navigation available; form state preserved

**Edge cases:**
- 0% phone coverage: launch button is disabled. Inline error: "No members in this group have phone numbers. Add phone numbers to proceed." — This is the one hard block.
- TCPA checkbox unchecked: "Launch Campaign" button remains visually disabled with tooltip "Confirm the SMS notice before launching."

---

### Screen 7: Campaign detail view — SMS

**Role:** Post-launch view showing delivery status, click metrics, and per-user results.

**Layout:** Page header + stats row + timeline chart + per-user table (Stillsuit DS v2 table pattern).

**Key components:**
- Header: campaign name, channel badge (SMS · `color/feedback/info` token), status badge (Sending / Completed / Partially Delivered)
- Stats row (4 metric cards): Targeted / Delivered / Clicked / Excluded
  - "Excluded" card: tooltip — "Members excluded due to missing phone number, carrier failure, or prior opt-out."
- Bot-click filtered count: secondary metric below the "Clicked" card — "X clicks filtered (automated scanner activity)" with an info icon tooltip: "Dune automatically filters clicks made by email security tools and MDM scanners. These are excluded from click totals and risk score calculations."
- Timeline chart: click events over time (useful for spotting scanner spikes vs. organic click patterns)
- Per-user results table: Name / Department / Delivery status / Click status + timestamp / Risk score delta
- Risk score delta column: before/after badge pairs (e.g., "Medium → High") for employees who clicked
- Table empty state: "No results yet — campaign is still sending."

**Edge cases:**
- Carrier rate-limited: status badge reads "Delivery Slowed" with helper text: "Carrier delivery is slower than expected. Messages will continue sending."
- STOP reply received: per-user row shows "Opted out" status badge. Admin sees a banner: "1 employee replied STOP and has been removed from this campaign. Their number will not be used in future SMS campaigns."
- Partial delivery with 0 clicks: stats row shows low delivery count; tooltip on Delivered card explains the gap.

---

### Screen 8: Group management — Phone coverage tab (new section)

**Role:** Persistent view of phone number coverage per group, accessible outside of campaign creation. Addresses the cold-start problem by making data quality a visible, actionable first-class concern.

**Layout:** Tab within the existing Group detail view.

**Key components:**
- Coverage summary: donut chart — Covered / Missing / Invalid (bad format)
- Coverage percentage badge: "84% covered" with `color/risk/*` token based on threshold (e.g., <50% = critical, 50–80% = medium, >80% = low)
- Members table: name, phone number status (Verified / Missing / Invalid), last updated timestamp
- Bulk actions: "Download missing numbers CSV" / "Notify IT team" (sends a pre-formatted email to IT)
- Import shortcut: "Upload phone numbers" (CSV) — opens upload drawer
- HRIS sync status (if connected): "Last synced: 3 hours ago · [Configure sync]"

**Empty state:** "No phone numbers on file for this group. Upload a CSV or connect your HRIS to get started." + primary CTA.

---

### Screen 9: Employee mobile debrief landing page (new surface)

**Role:** The page an employee sees after clicking a smishing link. Explains the simulation, delivers the learning moment, and links to a short training module. This is a new design surface — not a resize of the desktop debrief.

**Layout:** Single-column, mobile-first (375px baseline). Scrollable. Short enough to read in under 60 seconds.

**Key components:**
- Header: [Company] logo + "Security Training" wordmark — client-branded
- Alert strip: "This was a simulated text message attack." — `color/feedback/warning` background, not alarming
- SMS replica: shows the exact message the employee received, presented as a chat bubble — visual anchor for the explanation below
- "What to look for" section: 2–3 short bullets covering the red flags in this specific message (unfamiliar number, urgency language, unexpected link). Not generic — derived from the template used.
- Pause. Verify. Report. section: 3 numbered steps, each one sentence. This is Dune's behavioral north star.
- Training CTA: "Complete a 2-minute training" — primary button, links to mobile-optimized module
- Footer: "Questions? Contact [IT Security Team email]." — admin-configurable

**Copy constraints:**
- Total body copy: under 150 words
- No security jargon ("phishing simulation" is acceptable; "smishing vector" is not)
- Tone: matter-of-fact, not alarming, not condescending — Dune product principle #1

**Edge cases:**
- Employee arrives on desktop browser (they forwarded the link): show same page at standard viewport; it should be responsive but designed mobile-first.
- Employee has already seen this debrief (revisit): same page, no special state needed.
- Training module link is broken: CTA still shows; fallback copy below: "Can't access the training? Contact your IT security team."

---

## Open issues

The following unresolved questions would change the strategy if answered differently:

1. **[PM] TCPA legal clearance.** If legal determines that explicit employee consent (not just acknowledgment) is required, the TCPA step becomes a pre-campaign setup flow, not a wizard checkbox. This would add a new screen to the admin flow and potentially a new admin notification to employees before any campaign can be launched.

2. **[Both] AI vs. template-based v1.** If AI personalization is confirmed for v1, Step 3 (Message) needs a personalization preview mode showing how the message adapts per employee. The template library becomes secondary. This is a significant screen-level change.

3. **[Eng] Sender identity (short code vs. 10DLC).** If the sender is a short code (recognized as automated), the SMS preview in Step 3 should show a 5–6 digit number as the sender. If 10DLC, it shows a full phone number. The employee debrief copy may also need to acknowledge this distinction.

4. **[PM] STOP reply permanence.** If STOP exclusions are permanent across all campaigns, the coverage indicator in Step 2 needs a new "Opted out" segment separate from "Missing." If scoped to current campaign, the indicator logic is simpler.

5. **[Both] Risk score signal weighting.** If SMS clicks are confirmed as a new signal type (not equivalent to email), the risk score delta column in the campaign detail view needs a channel-aware label and the tooltip copy changes. If they're treated equivalently, the current design is correct.

---

## Next design actions

1. **Resolve the TCPA question with PM before starting Figma.** The acknowledgment checkbox is in the strategy now, but its placement and copy will change if legal requires a pre-campaign employee notice flow.
2. **Get Eng confirmation on v1 personalization scope.** This determines whether Step 3 (Message) is a template library or a personalization wizard — two very different screens.
3. **Open the Group detail view in Figma** and map the phone coverage tab against the existing Group component. This is the most contained new surface and a good place to start.
4. **Design the mobile debrief landing page first.** It's the highest-stakes new surface (learner-facing), most clearly scoped, and requires no unresolved decisions to begin.
5. **Confirm with Eng which sender identity will be used in v1** so the SMS preview panel in Step 3 renders the correct sender format.
