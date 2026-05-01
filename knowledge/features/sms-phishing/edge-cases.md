# Edge Cases — SMS Phishing (Smishing) Simulation
Last updated: 2026-05-01 · Updated with PRD-confirmed scope.

---

## System states
- SMS delivery failure at the carrier level: number invalid, carrier rejection, international block, or spam filter
- Partial campaign delivery: some messages sent, others queued, failed, or pending with no clear completion ETA
- Carrier rate-limits campaign mid-send: delivery stalls with no ETA for completion
- Link tracking beacon fires but employee device did not render the page (pre-fetch by link scanner or MDM tool) — false positive click event
- Unicode characters in message reduce character limit from 160 to 70 without warning — message silently truncates or splits into multi-part SMS
- SMS delivery confirmation receipt not available for all carriers — send success vs. delivery success cannot always be distinguished
- `smishing_form_submitted` event fires — must confirm no real credential, OTP, or sensitive data was stored in any field on the landing page before the event is recorded
- Test-send message is delivered to internal reviewers — must be visually distinguishable from a live simulation (labeled "TEST" or sent from a distinct sub-account)
- Approval workflow is enabled by customer — campaign transitions to "Awaiting Approval" and cannot be launched until an approver acts; approver is unavailable or inactive account

## Permission states
- Admin has campaign creation rights but employee PII (phone numbers) is access-restricted — can configure campaign but cannot verify number coverage
- View-only admin sees campaign results but cannot see individual employee phone numbers in result drill-down
- Admin targets a group where some members have no phone number on file — partial group coverage
- First-time admin in a tenant with no phone number data uploaded — campaign creation reaches a dead end at the audience step
- Admin attempts to export a CSV of phone numbers used in a campaign — which roles are permitted to export raw vs. hashed numbers?
- SOC/IR lead views repeat-offender list — may need a separate permission boundary from standard campaign reporting
- People manager receives automated alert — should not have direct access to individual user event logs; alert is the boundary

## Content states
- Template library is empty (fresh tenant, no templates seeded) — campaign creation cannot proceed without at least one template
- Admin selects a credential-harvest or MFA-code template — must trigger a safety warning callout: "This template includes a simulated form. No real credentials will be collected. Your coaching page must clearly explain this."
- Admin selects an executive impersonation template — warn if the impersonated name matches a real executive in the tenant's directory (requires name-matching check)
- Message contains Unicode characters (emoji, non-Latin) — character limit drops to 70; editor must warn before submission
- Message contains characters that look like real emergency alerts (AMBER Alert formatting, government warning headers) — requires a content guardrail; design TBD (see open question §16.9)
- AI generates identical messages for homogeneous group members — not applicable in v1 (template-based); flag for AI personalization phase
- Group contains members with phone numbers in mixed formats (with/without country code, parentheses, dashes) — normalization must happen before send
- Group contains only international phone numbers unsupported in v1 — entire campaign may fail if US-only is the initial constraint
- Campaign target group changes between schedule time and send time (employee added or removed) — snapshot at schedule time or at send time?
- Phone number goes stale during campaign (employee off-boards mid-campaign)

## Action states
- Admin cancels a campaign that has already begun sending — messages already sent cannot be recalled; remaining sends must stop
- Employee replies STOP — must be removed from active send queue immediately; opt-out record created; permanence TBD (see open questions)
- Admin relaunches to a group that contains prior STOP opt-outs — opted-out numbers silently excluded; not surfaced as failures
- Admin schedules campaign that conflicts with an existing group-level exclusion window — warn at schedule step, not at send time
- Admin uploads a CSV of phone numbers with validation errors on some rows — partial import with inline error list, not a silent partial import
- Admin attempts to launch campaign where 0% of the target group has phone numbers — hard block with resolution path
- Admin sends test message — test recipients should be separate from the campaign's live recipient list; test events should not update risk scores
- Admin clones an email phishing campaign concept into SMS format — field mapping (subject line has no SMS equivalent; sender display name maps to sender number) must be handled gracefully
- Approval-required campaign rejected by approver — admin notified with reason; campaign returns to "Draft" state with rejection note
- Bulk pause or archive of multiple campaigns (legal hold scenario) — all queued sends must stop immediately across all affected campaigns
- Admin attempts to send a message body that exceeds 160 characters — editor must warn; message should not send if it would silently truncate in a way that removes the tracking link

## Responsive / Accessibility
- Mobile debrief landing page: employee who clicked the smishing link is on a mobile browser — this is a new mobile-first design surface (375px baseline), not a resize of the desktop debrief
- SMS preview in campaign wizard must render at approximately 360px to simulate how the message appears in a device's native SMS thread UI
- Admin UI for phone number management (upload, review, status) must be usable on tablet
- Character counter in message editor must announce remaining characters accessibly (not just visual) — important for admins using assistive technology
- Touch targets in the campaign wizard's mobile-responsive view must meet 44×44px minimum for wizard navigation controls
- Executive summary / campaign comparison view must be readable in print or PDF export (used in QBR reporting per PRD §14)
