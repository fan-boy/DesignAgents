# User Flow — Vishing Campaign Launcher

**Last updated:** 2026-06-08

---

## Entry Points

1. **Red Teaming → Create Campaign** — admin selects Vishing in Step 1 Channel Selection
2. **Group detail page** — pre-populates audience step; channel type selector appears before Step 1
3. **Dashboard quick action** — "Launch a new exercise" → type selector → Vishing → wizard Step 1
4. **Red Teaming → AEP Library → New AEP** — admin creates a Voice AEP before configuring a campaign

---

## Flow A: Creating a Voice AEP

### Happy Path

1. Admin clicks **New AEP** in the AEP Library
2. Channel Type selector appears: admin selects **Voice** (previews Step 2 difference before committing)
3. Builder opens at Step 1 (AEP Setup — Voice variant)
4. Admin completes: AEP Title, Adversary Method (1–2 chips), Caller Identity (Name / Company / Role), Tone (1 chip), Target Context, Script Outline (Opening / Core Ask / Closing), optional Objection Handling Notes
5. Admin clicks **Refine and Test** → generation progress (Analyzing scenario → Building caller persona → Configuring script → Ready)
6. Builder advances to Step 2 (Test & Refine — Voice variant)
7. Admin reads Script Preview (Opening / Core Ask / Closing / Objection Handling)
8. Admin applies a Quick Action chip or custom instruction → Apply and Regenerate → script updates
9. Admin clicks **Call Test Number** → VOIP call placed to admin's phone
10. Admin completes call → "Mark test call as reviewed" checkbox appears → admin checks it
11. Admin clicks **Publish AEP** → publish confirmation modal (session count warning if < 2 test calls)
12. AEP status moves to Active → toast: "AEP published and available in campaign builder"

### Decision Points

- **Channel Type = Text:** Builder opens text AEP flow (live chat Step 2). Not this flow.
- **Generation fails (partial):** Per-section retry options; admin can fix and retry without losing other sections.
- **Generation fails (full):** Full-form retry CTA. Inputs preserved.
- **Test call not answered in 60s:** Inline error + Retry. Admin can retry or use manual fallback ("Mark manually →" with confirmation modal).
- **VOIP event not received after call:** Manual fallback link allows admin to self-attest call completed.
- **1 test call at publish:** Warning acknowledgment required before confirming.
- **0 test calls at publish:** Publish button disabled. Tooltip: "Complete at least one test call before publishing."
- **Refinement hits guardrail:** Inline message describing what cannot be changed and why.

### System Responses

- Generation progress bar advances through four labeled stages; P95 45s (no files) or 90s (with uploads)
- VOIP system places call when "Call Test Number" is clicked; 60s timeout triggers error
- Recent Changes list appends each applied instruction with timestamp
- Publish transitions AEP to Active in library; locks AEP against editing

---

## Flow B: Configuring a Vishing Campaign (Wizard)

### Happy Path

1. Admin navigates to **Simulations → Red Team → Create Campaign** (or Dashboard quick action)
2. **Step 1 — Channel Selection:** Admin selects Vishing channel card. SMS and WhatsApp cards disable. Contextual note explains operator execution model. Admin clicks Continue.
3. **Step 2 — Audience:** Admin selects targeting mode (Groups, Individuals, or Both). Phone coverage indicator shows reachable target count. Admin confirms audience. Continue.
4. **Step 3 — Voice AEP + Script:** Admin selects a published Voice AEP from selector. Script Preview populates. Admin adds optional campaign-specific calling notes. Continue.
5. **Step 4 — Compliance Pre-flight:** Admin reviews Group A (platform-verified: VOIP status ✓, phone coverage ✓). Admin checks all Group B acknowledgment items (recording consent, jurisdiction, works council if applicable). Continue.
6. **Step 5 — Call Configuration:** Admin sets call window (start/end time + timezone), max attempts per target (default 2), inter-attempt delay (default 2 hours), campaign start date. Continue.
7. **Step 6 — Remediation:** Suppression ON by default. Admin reviews and keeps default. Continue.
8. **Step 7 — Test Call:** Admin enters phone number (pre-filled). Clicks Place Test Call. Receives call. Checks "I've completed a test call." Continue.
9. **Step 8 — Review + Request:** Admin reviews all summary cards. Checks compliance acknowledgment checkbox. Clicks **Submit Campaign Request**.
10. **Post-submit confirmation screen:** "Campaign request submitted. Ops will activate within 1 business day." Admin clicks "View campaign."
11. Campaign appears in Red Team list with **Pending Activation** badge.

### Decision Points

- **No published Voice AEPs at Step 3:** Empty state → "Build one now" → AEP Builder opens in new tab. Wizard auto-saves as draft. Admin returns to Step 3 after publishing AEP.
- **VOIP Degraded at Step 1:** Admin sees warning chip on card; can proceed. Step 4 Group A item shows ⚠ Pending; Continue blocked until resolved.
- **Zero phone coverage at Step 2:** Hard block. Continue disabled. Inline error with resolution path.
- **Group B items unchecked at Step 4:** Continue blocked. Items remain visible with clear instruction.
- **EU audience detected (IDP SCIM):** Works council acknowledgment item surfaced in Group B.
- **No IDP SCIM:** Works council item shows as "if applicable" with guidance text.
- **Test call skipped at Step 7:** Strong warning modal → explicit confirm → soft warning flag in Step 8 summary.
- **VOIP event not received at Step 7:** Manual fallback: "Call completed? Mark manually →" with confirmation modal.
- **Hard block at Step 8:** Launch blocked with inline error directing admin to specific step.

### System Responses

- Wizard auto-saves state on each step advance and on back navigation
- Step 2 recalculates phone coverage in real time as audience is modified
- Step 4 Group A items auto-resolve when underlying platform state changes (e.g., VOIP restores to Active)
- Post-submit: campaign record created with Pending Activation status; email confirmation sent to admin
- Dune ops receive submitted campaign for review (out-of-platform ops process)

---

## Flow C: Monitoring a Campaign in Calling Status

### Happy Path

1. Admin opens campaign detail. Status badge: "Calling" (pulsing).
2. Stats row shows live: Total Targets, Reached, No Answer, Compromised (%), Declined.
3. Call Log table shows one row per attempted target with State badge, Attempt Count, Last Attempt Time, Call Duration.
4. Outcome legend card appears above table on first view (dismissable after reading).
5. Admin clicks a row → Transcript/Notes drawer opens (right-anchored, 480px) showing call recording or operator notes, timestamps.
6. Stats and table auto-refresh every 30 seconds.
7. Admin pauses campaign if needed (confirmation modal with explanation).

### Decision Points

- **Admin pauses mid-campaign:** Confirmation modal. Remaining scheduled attempts cancelled. In-progress calls: behavior depends on Eng confirmation (complete naturally or terminate immediately — open issue).
- **Admin cancels mid-campaign:** Confirmation modal explains already-placed calls cannot be recalled. Remaining attempts cancelled.
- **Target has Callback Requested state:** Row shows Callback Requested badge. No action available for admin; Dune ops manage follow-up.
- **VOIP degrades during Calling:** Platform auto-pause OR ops handle externally (open issue). Campaign detail shows degradation banner if auto-pause occurs.

---

## Flow D: Post-Campaign Reporting (Completed Status)

### Happy Path

1. Campaign transitions to Completed. Overview tab is default.
2. Admin reviews locked stats row, charts (Daily Activity, Complicit by AEP, Attempt Distribution, Complicit by Geo if SCIM available).
3. Admin switches to Call Log tab.
4. Admin reviews per-target rows; clicks Transcript/Notes for individual call detail.
5. Admin re-tags a Non-Complicit outcome to Complicit if needed (RBAC-gated; disabled with tooltip for Standard admin).
6. Admin exports CSV (Red Team admin and Standard admin only).

### Decision Points

- **Zero Reached targets:** Susceptibility rate shows "N/A" with tooltip explaining denominator is 0.
- **Admin re-tags outcome:** Confirm modal before change is applied. Susceptibility rate in Overview tab updates retroactively — behavior must be confirmed with PM before designing.
- **No IDP SCIM:** Complicit by site/geo chart shows unavailable state with integration CTA.

---

## Edge Case Handling

| Edge case | Handling in flow |
|---|---|
| VOIP degrades during Calling | Degradation banner on campaign detail; ops handle externally or auto-pause (open issue) |
| Test call checkbox doesn't appear after call ends | Manual fallback link: "Call completed? Mark manually →" with confirmation modal |
| Empty AEP library at Step 3 | Empty state with "Build one now" → AEP Builder in new tab; wizard auto-saves as draft |
| Zero phone coverage at Step 2 | Hard block; Continue disabled; inline error with resolution path |
| Campaign auto-completes with un-attempted targets | Final stats show "Not Attempted" (distinct from No Answer) — language TBD with Eng |
| Admin has no registered phone number at Step 7 | Empty phone input with placeholder; no pre-fill |
| Mobile device simultaneous call + browser interaction | Contextual note at Step 7 recommending a second device |
| Two gray badges visually indistinguishable | Outlined (Not Yet Called) vs. filled muted gray (No Answer) badge treatment |
| Pending Activation with no status updates | Review status row on campaign detail shows submission timestamp + SLA estimate + contact link |
| Admin submits on weekend / holiday | Campaign date copy: "on or after this date" — SLA language handles non-business day submissions |
| Voice AEP updated after campaign submission | Open issue — campaign detail should surface which AEP version was submitted |

---

## Exit States

| State | How user reaches it | What the product shows |
|---|---|---|
| AEP Draft saved | Save as Draft in builder | AEP library row with Draft badge; builder resumes from Step 1 |
| AEP Published | Publish confirmed in Step 2 | Active badge in library; available in campaign AEP selector |
| Campaign Draft | Save as Draft in wizard | Campaign list with Draft badge; wizard resumes from last step |
| Campaign Pending Activation | Submit Campaign Request in Step 8 | Confirmation screen + campaign detail with Pending Activation badge + review status row |
| Campaign Calling | Ops activate the campaign | Campaign detail transitions to Calling status; admin email notification sent |
| Campaign Paused | Admin clicks Pause Campaign | Status badge changes to Paused; remaining attempts halted |
| Campaign Cancelled | Admin confirms Cancel | Status badge changes to Cancelled; call log reflects attempts before cancellation |
| Campaign Completed | All targets terminal or window closed | Status badge changes to Completed; reporting tabs unlock |
