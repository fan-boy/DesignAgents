# PRD Research — SMS Phishing (Smishing) Simulation
Dune Security · Feature Research · Last updated: 2026-05-01 · Full PRD added.

---

## Feature summary

Source: PRD v1 Draft (product@dune.security, 2026-05-01).

Smishing simulation extends Dune's existing phishing simulation capability to the SMS channel. Security admins create campaigns using a guided builder, target employees by group, department, risk cohort, or CSV, send AI-crafted or template-based SMS lures, and track interactions through a graduated risk model. Smishing events become first-class user-risk signals and trigger Remediation Agent workflows — training assignment, manager notification, ServiceNow ticket creation.

**v1 scope is confirmed:** SMS-only, US-first or limited-region beta, approved templates plus light customization. Architecture must anticipate WhatsApp, Signal, Telegram, QR-code lures, and vishing from day one but those channels are explicitly excluded from v1.

**Compliance model:** Customer-responsibility. Dune provides an admin acknowledgment step at campaign creation. The customer owns the underlying lawful basis and employee-notice process (TCPA/GDPR). Phone numbers are stored as hashes, not raw values.

**Success is measured as:** Admin creates and launches in under 10 minutes; 95%+ test send success rate; user events on risk profile within 60 seconds; 50% of pilot customers launch a second campaign within 60 days; zero real credential collection at any time.

---

## Gaps and ambiguities

1. **Phone number sourcing is undefined and architecturally load-bearing.** The PRD acknowledges this as open question 16.1 and defers it to Phase 0 customer interviews. Whether customers will provide HRIS-synced numbers, CSV uploads, or manual entry determines the entry experience for every campaign. This is the most impactful unresolved gap for design.

2. **SMS sending provider and supported countries not selected.** PRD §16.3 defers this to Phase 0. Sender identity (short code, 10DLC, toll-free) and carrier behavior directly affect the SMS preview panel design in the campaign wizard and the realism of the simulation from the employee's perspective.

3. **Risk-weighting values not defined.** PRD §11 defines the graduated signal model (click = moderate, submit = high, report = positive, etc.) but leaves the weighting values as an open question (§16.5). The reporting UI design is complete, but the magnitude of risk score deltas shown will depend on these values.

4. **Approval workflow scope not confirmed.** PRD §16.7 asks whether approval is required for high-sensitivity templates. If yes, the campaign creation wizard's final step CTA changes from "Launch Campaign" to "Submit for Approval" and an "Awaiting Approval" campaign state must be designed.

5. **Template editability not confirmed for v1.** PRD §16.8 asks whether templates are customer-editable or library-only during beta. This changes the message editor in Step 2 from a full text area to a token-substitution preview — a significant scope difference.

6. **Reporting mechanism not confirmed for v1.** PRD §16.6 leaves user-report behavior (employee forwarding suspicious SMS) as a Phase 0 validation item. The `smishing_reported` event and the "Reported" metric card in the campaign detail view are designed but conditioned on this decision.

7. **Content guardrails for harmful impersonation not designed.** PRD §16.9 asks how Dune will prevent customers from sending messages that look like real emergencies, legal notices, or government alerts. A credential-harvest template warning is designed; the broader content policy guardrails are not yet defined.

---

## Missing states

### System states
- SMS delivery failure at carrier level (invalid number, carrier rejection, international block)
- Partial campaign delivery — some sent, others queued or failed
- Carrier rate-limits campaign mid-send
- Link scanner false positive click (MDM/security tool auto-follow)
- Unicode character detected — character limit silently drops to 70
- `smishing_form_submitted` fires — must confirm zero real data stored before event is recorded
- Approval workflow pending — campaign blocked by approver inaction or inactive approver account
- Test-send delivery failure

### Permission states
- Admin without PII access cannot view phone number coverage gaps (percentage only)
- View-only admin: read-only wizard; cannot launch or configure
- SOC/IR lead: repeat-offender list access may require separate permission from standard campaign view
- People manager: receives automated alerts but must not have direct access to individual user event logs

### Content states
- Template library empty (fresh tenant)
- Credential-harvest template selected — safety warning + acknowledgment required
- Executive impersonation template selected — name-match check against tenant directory needed
- Coaching page contains form field — hard block on Step 3
- Campaign cloned from email phishing — field mapping edge cases (subject → sender, attachment → dropped)

### Action states
- Admin cancels mid-send (already-sent messages cannot be recalled)
- Employee replies STOP (permanence TBD)
- Admin relaunches to group with prior STOP opt-outs
- Approval rejected — campaign returns to Draft
- Bulk campaign pause/archive under legal hold

### Responsive / Accessibility
- Mobile debrief landing page is a new design surface (375px baseline)
- SMS preview in campaign wizard must render at 360px
- Character counter must be accessible (not just visual)
- Executive summary / comparison view must be readable in print/PDF for QBR

---

## Questions for PM / Eng

1. `[PM/Eng]` Where do customer phone numbers live today in Dune, and what permissions exist around them? Do customers expect personal or work-issued numbers? (PRD §16.1–16.2)
2. `[Eng]` What SMS sending provider and which countries for v1? (PRD §16.3)
3. `[PM]` How should opt-out and consent be handled by customer, region, and campaign type? (PRD §16.4)
4. `[PM/Eng]` What are the exact risk-weighting values for smishing signals vs. email phishing? (PRD §16.5)
5. `[PM]` Is user reporting (forwarding suspicious SMS) in scope for v1? (PRD §16.6)
6. `[PM]` Are approval workflows required for high-sensitivity templates? (PRD §16.7)
7. `[PM]` Are templates customer-editable in v1, or library-only? (PRD §16.8)
8. `[PM]` How will Dune prevent harmful impersonation templates? (PRD §16.9)
9. `[Eng]` How will link scanner false positives be detected and excluded?
10. `[PM]` When an employee replies STOP, is exclusion permanent or campaign-scoped?

---

## Design risks

**Phone coverage cold-start.** The feature is immediately limited by phone number data quality. Without a clear sourcing path, the campaign creation wizard dead-ends at Step 1 for most customers on day one. The onboarding path for phone data must be visible and actionable before any campaign is created.

**Credential template trust risk.** Templates that include simulated login forms require two-layer safety: (1) an admin warning at selection, and (2) a coaching page that cannot prompt for real credentials. If either layer fails, employees may attempt to submit real passwords, OTPs, or MFA codes. This is not just a UX problem — it is a data safety requirement.

**Graduated risk model UI complexity.** Five distinct event types (delivered, clicked, submitted, reported, training_completed) require a reporting UI that surfaces each separately. Collapsing to a single click-rate metric loses the PRD's behavioral nuance and undermines the risk-scoring differentiation story.

**Approval workflow gap.** If high-sensitivity templates require approval and the approval state is not designed, campaigns will be blocked with no visible resolution path.

**Harmful impersonation templates.** The content guardrails for emergency alerts, legal notices, or government impersonations are not yet defined. Without guardrails, customers could create simulations that cause genuine alarm or legal exposure.

---

## Teaching notes

- **PRD data model (§10):** `campaign.type = smishing`; `recipient_event.phone_hash` (not raw); five trackable events per recipient: `smishing_message_delivered`, `smishing_link_clicked`, `smishing_form_submitted`, `smishing_reported`, `smishing_training_assigned`, `smishing_training_completed`
- **Graduated risk model (PRD §11):** Delivered = no impact; clicked = moderate negative; submitted = high negative; reported = positive; training completed = positive recovery; repeat failure = escalating negative
- **Debrief content structure (PRD §13):** Hook → Red flags from specific message → Correct behavior → Micro-commitment. Under 150 words. No jargon.
- **Entry point:** Simulations → Smishing (sub-nav), not a channel selector at wizard start
- **Compliance model:** Customer confirms lawful basis at Step 7 (acknowledgment checkbox). Dune does not own the underlying legal basis — the customer does.
- **Architecture extensibility (PRD §1):** v1 = SMS only; data model must anticipate WhatsApp, Signal, Telegram, QR-code, and vishing from day one
- **Template guardrails (PRD §12):** Admins must see clear warnings when creating credential-style templates; users must never be asked for actual credentials on coaching pages
