# PRD Research — SMS Phishing (Smishing) Simulation
Dune Security · Feature Research · Last updated: 2026-05-01

> **No PRD was provided.** This analysis is derived from the feature name and Dune's product context. All assumptions are flagged explicitly. A formal PRD should be created before design begins — or the gaps below serve as its draft outline.

---

## Feature summary

SMS phishing simulation ("smishing") extends Dune's existing AI-personalized phishing simulation capability to the SMS channel. Security admins would create campaigns targeting employee phone numbers with AI-crafted text messages, track interactions, surface results in the risk scoring model, and trigger remediation workflows on click. This is a meaningful platform expansion — not a variation of the email phishing campaign — because it requires net-new infrastructure (SMS delivery, phone number management), introduces new legal obligations (TCPA, GDPR on phone data), and lands on a more personal surface (employee mobile devices). **Success metric is undefined without a PRD.**

---

## Gaps and ambiguities

1. **Phone number sourcing is undefined and architecturally load-bearing.** There is no current mechanism in Dune for storing employee phone numbers. Options — HRIS sync, CSV upload, manual entry, SSO/IdP-provided — each have different data quality, latency, and admin burden profiles. This decision gates the entire feature: you cannot design the campaign setup flow without knowing where numbers come from, how fresh they are, or who can access them.

2. **Legal compliance scope is unspecified and potentially blocking.** TCPA governs commercial text messages in the US and requires prior express consent. Employer-to-employee messages used for training occupy a gray zone. EU/UK GDPR applies to phone numbers as personal data. No legal clearance is documented. This is an S0 risk that must be resolved before design starts.

3. **Sender identity strategy is undefined.** Short codes, 10DLC long codes, and toll-free numbers each have different registration requirements and realism profiles. Spoofing real brand numbers may not be legally permissible in target markets. The sender display drives how realistic the simulation feels — design cannot proceed on this screen until the infrastructure decision is made.

4. **AI personalization scope for SMS is unclear.** Dune's email spear phishing uses subject line, sender name, body, and visual design. SMS allows only 160 characters of plain text and a link. Whether the AI engine is being adapted to this constraint or v1 ships template-based determines the design of the template library and the messaging around the feature entirely.

5. **Risk score integration model is undefined.** The current model is built on email signals (open, click, credential submission). SMS has no open event — only a link click. How this maps to existing risk band thresholds needs PM/Eng alignment before the reporting UI can be designed.

6. **Multi-channel campaign coordination is not scoped.** A coordinated email + SMS attack is the natural next step and a real differentiator. If the campaign data model isn't built for multi-channel now, retrofitting will be expensive. This scoping decision should be made before the data model is finalized.

7. **Mobile debrief experience is an undesigned surface.** Dune's current debrief is desktop-optimized. Employees clicking a smishing link are on mobile. This is a genuinely new design surface, not a resize.

---

## Missing states

### System states
- SMS delivery failure at carrier level (invalid number, carrier rejection, international block)
- Partial campaign delivery — some messages sent, others queued or failed
- Phone number data goes stale mid-campaign (employee off-boards)
- Link tracking beacon fires from a link scanner (MDM/security tool auto-follow) — false positive click

### Permission states
- Admin has campaign creation rights but employee PII (phone numbers) is access-restricted
- View-only admin sees campaign results but not individual phone numbers
- Admin targets a group where some members have no phone number on file
- First-time admin — no phone number dataset uploaded yet

### Content states
- Template library with zero SMS templates (fresh tenant)
- AI personalization produces identical messages for homogeneous group members
- Group contains members with international numbers unsupported in v1
- Phone numbers in mixed formats (with/without country code, dashes, parentheses)

### Action states
- Admin cancels a campaign that has already begun sending
- Employee replies STOP — must be immediately excluded from remaining sends and future campaigns
- Admin relaunches to a group that contains prior STOP opt-outs
- Campaign delivery conflicts with a group-level exclusion window
- Bulk phone number CSV upload with partial validation errors

### Responsive / Accessibility
- Debrief landing page must be mobile-first (375px baseline) — employees are on mobile when they click the link
- SMS preview in campaign wizard must render at ~360px to simulate device appearance
- Character counter in message editor must announce remaining count accessibly (not just visual)
- Touch targets in wizard navigation must meet 44×44px minimum

---

## Questions for PM / Eng

1. `[PM]` Has legal reviewed TCPA compliance? Is there a defined consent or notice mechanism for sending simulation SMS to employee-owned devices?
2. `[PM]` Where do employee phone numbers come from — HRIS sync, CSV upload, manual entry, or IdP? Is this in scope for v1?
3. `[PM]` What is the defined success metric for this feature at launch?
4. `[Eng]` What SMS delivery infrastructure is in scope — Twilio, AWS SNS, or other? Who owns short code / 10DLC registration?
5. `[Both]` Is AI-personalized smishing in scope for v1, or is v1 template-based only?
6. `[Both]` How does an SMS link click map to the existing risk scoring model — same weight as email click, or a new signal type?
7. `[PM]` Is multi-channel campaign coordination in scope for v1 data modeling even if UI ships single-channel?
8. `[Eng]` How will link scanner false positives be detected and excluded from click metrics and risk scores?
9. `[PM]` When an employee replies STOP, is the exclusion permanent across all future campaigns, or scoped to the current campaign?
10. `[Both]` Is the mobile debrief a new mobile-first design surface or a responsive adaptation of the existing desktop debrief?

---

## Design risks

**Legal exposure.** If TCPA consent handling is not designed into the flow before launch, Dune faces regulatory risk and enterprise customer refusal to enable the feature. Not a disclaimer-later problem — must be in the product architecture.

**Employee trust erosion.** Email phishing lands in a work inbox. SMS lands on a personal device. Employees who receive a simulation may feel surveilled, especially if the message impersonates a personal service (bank, delivery). D1 (Earn Trust Before Surprising) is harder to honor on this channel. HR escalations are likely without a clear employee notice strategy.

**Link scanner false positives inflate click-through rates.** Many enterprise MDM solutions auto-follow links in SMS. Without fingerprinting real clicks, campaign metrics will be inflated and risk scores corrupted. Admin trust in results degrades.

**Phone number data quality gap tanks campaign validity.** If a meaningful percentage of the target group has missing or stale numbers, campaign metrics look like low engagement when they're actually incomplete delivery. Admins draw wrong conclusions.

**AI personalization quality.** In 160 characters, there is very little room for contextual personalization without sounding unnatural. A generic template marketed as "AI personalized" will fail the credibility test. If v1 is template-based, it must be named as such.

---

## Teaching notes

- **SMS constraints:** GSM-7 encoding = 160 chars. Unicode (emoji, non-Latin) = 70 chars. Multi-part messages are possible but reduce realism. The message editor must show a live counter with encoding detection.
- **TCPA primer:** US law restricting automated texts to mobile numbers. Employer-to-BYOD for training is a gray zone. Design must include a disclosure or acknowledgment step regardless of legal's final ruling.
- **Closest existing Dune pattern:** The email phishing campaign wizard. Adapt it — do not reinvent the wizard frame.
- **Debrief pattern:** The "Pause, Verify, Report" framework applies. Mobile-first, single column, under 150 words.
- **Short code vs. 10DLC:** Short codes (5–6 digits) are clearly automated, reducing realism. 10DLC looks like a real phone number but requires carrier registration per campaign type. Surface this tradeoff to Eng early.
- **Risk scoring gap:** SMS click is a new signal type. Do not treat it as equivalent to an email click without PM/Eng alignment — designing the reporting UI before this is settled will produce a misleading product.
