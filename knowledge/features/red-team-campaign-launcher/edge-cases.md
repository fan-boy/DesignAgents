# Edge Cases — Red Team Campaign Launcher

## System states

- WhatsApp delivery fails for a target: account not approved, message template rejected by WhatsApp Business API, target not on WhatsApp — fallback behavior undefined (see open questions)
- WhatsApp Business API rate-limits campaign mid-send — per-channel delivery count diverges from plan
- Partial multi-channel delivery: SMS sends complete for all targets but WhatsApp sends are pending or partially failed — campaign status must reflect per-channel state, not only aggregate
- WhatsApp message template pending API approval at the time admin attempts to launch — campaign cannot start until template is approved; Pending state needed
- Vishing call not answered: voicemail, no answer, call blocked, or call rejected — outcome cannot be auto-recorded; admin must manually log result (if vishing is manual-outcome model)
- Campaign in "Sending" state across two channels simultaneously: admin views campaign detail mid-execution — per-channel send counts must be independently displayed
- Admin schedules campaign across a timezone boundary (e.g., campaign targets users in US and EU) — delivery spread and scheduling must account for recipient local time, not only admin local time

## Permission states

- Admin has campaign launch permission but not WhatsApp channel access (if channels are feature-flagged separately) — WhatsApp option grayed out with tooltip; SMS-only is still available
- Read-only admin views red team campaign results — more sensitive than simulation results; individual-level adversarial detail may warrant a separate permission scope
- Department manager: their report is individually targeted in a red team campaign — does the manager receive the standard automated notification (as with simulations), or is manager notification suppressed to protect exercise integrity?
- Red team campaign in progress: second admin attempts to modify or cancel a campaign initiated by another admin — must confirm whether red team campaigns are admin-scoped or org-scoped
- Sub-admin without red team permission attempts to access the red team launcher entry point — must show a clear locked state with explanation, not a 404

## Content states

- Zero targets in selected audience have WhatsApp-reachable accounts (0% channel coverage for WhatsApp) — hard block on WhatsApp channel selection equivalent to 0% phone coverage in SMS phishing
- Zero targets in selected audience have phone numbers (0% SMS coverage) — hard block on SMS channel selection; same pattern as SMS phishing wizard Step 1
- Target list includes users who have opted out of SMS — these users are silently excluded from SMS sends; WhatsApp opt-out is platform-level (user blocks the sender), not Dune-level — different handling required
- Both individual targets and group targets selected in same campaign — overlap detection must identify users who appear in both; system must warn admin and offer deduplication
- Template library empty for red team (if separate from simulation templates) — empty state with CTA to create first template
- Admin selects simulation template for a red team campaign (if libraries are shared) — must flag that simulation templates are designed for educational exercises, not adversarial realism; not a hard block but an advisory

## Action states

- Admin cancels red team campaign mid-execution: some SMS sent, some WhatsApp messages delivered, some sends still queued — already-sent messages on both channels cannot be recalled; cancellation stops queued sends only; campaign status must accurately show what was delivered before cancellation
- Admin targets individual user who is also a member of a targeted group — single contact or two contacts? System must resolve before launch; duplicate contact with a red team lure is an operational security incident
- Admin launches with remediation automation ON: training assignment fires immediately when target clicks link, alerting target before any debrief — if suppression is not available, this breaks the adversarial exercise
- Admin launches red team campaign with no remediation and no test send (both optional) — allowed; not a hard block; soft warning at review step
- Admin attempts to edit a red team campaign while it is in "Sending" state — same constraints as SMS phishing: audience and channel cannot be changed; schedule and remediation rules may be editable depending on Eng constraints
- Admin relaunches red team campaign targeting users who received a prior red team lure in the same window — cooldown conflict should apply; confirm whether red team campaigns respect the same cooldown rules as simulations or have separate cooldown logic

## Responsive / Accessibility

- Debrief/coaching page opened via WhatsApp link: opens in WhatsApp in-app browser, not native Safari/Chrome — rendering constraints differ; fixed position elements, viewport height, and font rendering may behave differently
- WhatsApp shows link preview (URL + page title + meta image) before user taps the link — if the debrief page's meta title or image reveals the simulation context ("Security Awareness Training"), the lure is broken before the user even taps; debrief page meta tags must be designed to not reveal the simulation type
- Multi-channel campaign results table: per-channel columns (SMS Delivered / WhatsApp Delivered / SMS Clicked / WhatsApp Clicked) may exceed readable width at 1024px — requires horizontal scroll, column collapse, or a channel-tab pattern in the results view
- Vishing outcome recording (if admin-manual model): admin enters outcome in a form field after each call — must be usable on mobile if admin is conducting calls in the field
- Character limits and formatting: WhatsApp supports richer formatting than SMS (bold, italic, links with preview) — the message editor must reflect per-channel formatting constraints, not assume SMS-only rules
