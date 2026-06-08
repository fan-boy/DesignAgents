# Edge Cases — Vishing Campaign Launcher

## System states

- VOIP infrastructure degrades while campaign is in Calling status — auto-pause behavior not defined; ops handling path not described
- Test call in AEP Step 2 completes but the "Mark test call as reviewed" checkbox does not appear because the VOIP completion event was not received — admin is stuck with no unblock path
- Call classification event arrives from VOIP system but cannot be matched to a target record — call log row rendering in error/unknown state not described
- Campaign auto-completes because the campaign date window has closed, but some targets were never attempted — how is this reflected in final stats (No Answer vs. Not Attempted)?
- Campaign in Pending Activation when VOIP infrastructure degrades — email notification behavior and admin-visible status not described

## Permission states

- Admin with Red Team admin role has no registered phone number — Step 7 test call has no pre-filled number and no guidance on what number is valid
- Standard admin views a campaign in Pending Activation — no actions available; empty action area needs a "view only" treatment
- Dune Operator reviewing a submitted campaign — no described operator-side UI, permission model, or access surface
- Admin views a campaign that ops have internally paused (ops-side action, not admin-initiated) — admin-visible status and notification path not described
- Admin who created a campaign loses Red Team admin role mid-campaign — can they still view? Can they still pause or cancel?

## Content states

- Voice AEP library has exactly one published Voice AEP — single-item selector state (no filtering or search needed; selector should not feel broken)
- Campaign-specific calling notes are very long — no character limit defined; operator panel rendering of long notes is undefined
- Call Log table on a large campaign (500+ targets) — pagination, initial load performance, and column collapse order on narrow viewports not described
- Campaign completes with zero Reached targets (all No Answer) — susceptibility rate denominator is 0; display behavior undefined
- Reporting charts when campaign has only 1 day of activity — daily activity stacked bar chart renders as a single bar; visual adequacy not confirmed
- No Voice AEPs exist in the org when admin reaches Step 3 — empty state described but "Build one now" link navigates away from wizard; return path not described

## Action states

- Admin pauses campaign while a call is currently connected (in-progress live call) — undefined whether live call terminates immediately or completes before pause takes effect
- Admin cancels campaign while some calls are in Callback Requested state — follow-up attempts in queue behavior not described
- Admin re-tags a call outcome from Non-Complicit to Complicit after campaign is completed — whether this retroactively updates the susceptibility rate in the Overview tab is not specified
- Export CSV during Calling status — whether export includes in-progress/partial call data or only completed call records is not described
- Voice AEP is edited (new version published) after being selected in a submitted-but-not-yet-activated campaign — which AEP version does the campaign execute against?
- Admin tries to archive a Voice AEP that is referenced in a campaign in Pending Activation (not yet active) — PRD says archive blocked only for Active campaigns; Pending Activation may be a gap
- Admin submits campaign request on a weekend or public holiday — "within one business day" SLA interpretation for non-business days not addressed

## Responsive / Accessibility

- Step 7 test call on mobile — admin may be receiving the test call on the same device they're completing the wizard on; simultaneous browser interaction and phone call not feasible on mobile without hands-free
- Call Log table column collapse order on narrow viewports not defined (text campaign PRD specifies this explicitly for Conversations tab at 1024px)
- "Not Yet Called" and "No Answer" both use gray badges — visually indistinguishable by color; screen reader and color-blind users require distinct text labels and preferably distinct visual treatments
- "Callback Requested" blue badge — confirm this blue is accessible against both light and dark admin dashboard backgrounds per DS v2 color token specs
- Script Outline structured textarea in AEP Step 1 (three labeled sections) — keyboard navigation between Opening / Core Ask / Closing sub-sections needs explicit tab order definition
- Test call placement in Step 2 and Step 7 — if admin is using screen reader or keyboard-only navigation, the "call in progress" state needs a programmatic announcement (ARIA live region) when the call connects and ends
