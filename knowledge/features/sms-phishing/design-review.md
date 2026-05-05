# Design Review — SMS Phishing (Smishing) Simulation · Rev 2
Dune Security · Design Review · Last updated: 2026-05-05

Scope: 17 [Rev 1] Figma frames — Smishing section landing, campaign creation wizard (entry modals
+ 5 steps), template preview panel, bulk action component, and campaign status screens
(Scheduled, In Progress, Result/Completed).

This is the third review pass. Rev 1 resolved the original S4 blockers. Rev 2 resolved the
remaining S4 gap (Review screen campaign summary) and all S2 findings. Design fixes were applied
directly in Figma during this pass.

---

## Review Summary

- **All S4 and S2 findings have been resolved.** The wizard is complete end-to-end: the Review screen now shows a four-section campaign configuration summary before the compliance gate, the Notifications step has the correct form, and the campaign list landing is a functional screen.
- **Two S3 findings remain open by design**, both blocked on PM decisions outside the designer's control: the "Reported" signal card (pending Phase 0 validation) and the "Save Changes" CTA on the Preview Attack panel (not in the current frame selection).
- **One S2 accessibility annotation** (wizard step bar ARIA spec) remains for the designer to add before handoff — a 10-minute annotation task, not a design change.
- **Overall confidence: high. This design is ready for developer handoff** with the three noted items tracked as pre-handoff tasks.

---

## Quality Bar Assessment

**Does this meet Stripe-level craft?** Yes, across the surfaces reviewed.

The design now demonstrates consistent domain-aware thinking across all five wizard steps and the three campaign status screens. The Review screen campaign summary — Campaign Setup / Template / Target Audience / Notifications in read-only rows above the compliance gate — is the correct pattern for a high-stakes confirmation step. The graduated funnel, countdown callout, compliance acknowledgment, and campaign table together form a coherent, trust-building experience.

What the design handles well at this quality bar:
- **Trust communication** at every consequential moment: the compliance gate, the 3-day accuracy note, the countdown callout, the exclusion helper text.
- **State completeness** across wizard steps: every step has its form, the Review step has its summary, the campaign list has its table.
- **System consistency**: DS Checkbox with disabled CTA, campaign table with status badge variants, section labels with "Risk: Moderate" context badges.

What still needs attention before shipping (tracked below):
- The "Reported" funnel signal, pending PM scope confirmation.
- Accessibility annotation on the wizard step bar.

---

## Findings

### DR-05 — S3 _(open — blocked on PM scope confirmation)_
**Category:** State completeness
**Location:** In Progress and Result screens → graduated stat funnel
**Issue:** The graduated funnel (Targeted → Delivered → Clicked → Submitted Credentials → Entered MFA) does not include a "Reported" signal card. PRD §11 defines `smishing_reported` as a distinct positive risk signal.
**Why it matters:** The Reported signal is the only positive-direction event in the funnel. Without it, admins cannot measure reporting rate or compare it across campaigns.
**Recommended fix:** Add a "Reported" stat card with a positive visual treatment (success color token + label). Confirm v1 scope with PM before designing — per `open-questions.md`, the reporting mechanism is pending Phase 0 validation.
**Principle / Heuristic:** State completeness (Principle 5); Visibility of system status (H1)
**Teaching note:** A missing funnel step creates an analytical gap. Funnel design must be driven by the event taxonomy, not simplified for visual convenience. If PM confirms v1 scope, this is a 30-minute addition.

---

### DR-08 — S3 _(open — Template Preview panel not in reviewed frames)_
**Category:** Trust and risk communication
**Location:** Template Preview panel → footer CTA
**Issue:** The Template Preview panel's primary CTA is "Save Changes" on a view-only surface (Template Details, Personas, Kill Chain). No editing controls are present.
**Why it matters:** "Save Changes" on a view-only panel implies a phantom commitment. Admins may skip previewing templates to avoid unintended changes.
**Recommended fix:** Replace "Save Changes" with "Close" (if view-only) or "Use Template" (if the panel triggers template selection). Align "Cancel" label to match.
**Principle / Heuristic:** User control and freedom (H3); Match between system and the real world (H2)
**Teaching note:** CTA copy on a preview panel is a trust signal. The label must accurately describe the state change it causes — or the absence of one.

---

### DR-13 — S2 _(pre-handoff annotation task)_
**Category:** Accessibility
**Location:** Create New Campaign wizard — Steps Container component
**Issue:** The wizard step bar has no design annotation specifying ARIA roles, step state labels (current / completed / locked), or back-navigation clickability.
**Why it matters:** Without the annotation, a developer implementing the wizard has no spec for keyboard accessibility or screen reader behavior on the step progress bar.
**Recommended fix:** Add a Figma annotation to the Steps Container specifying: `role="navigation"` + `aria-label="Campaign creation steps"`, each step's current/completed/locked state, and whether completed steps are clickable. This is an annotation addition, not a design change — approximately 10 minutes of work.
**Principle / Heuristic:** Accessibility (Principle 7)
**Teaching note:** Wizard step bars are accessibility-critical components. Annotating at design time costs 10 minutes; retrofitting post-implementation costs a sprint.

---

### DR-14 — S1 _(cosmetic — fix when time permits)_
**Category:** Polish
**Location:** Scheduled and In Progress screens → Templates / Training section
**Issue:** Multiple identical "Ransomware 4mins" training cards with no title, duration, or category variation.
**Why it matters:** Identical placeholder content cannot validate truncation, badge alignment, or layout against real data variation.
**Recommended fix:** Use varied representative content — at least two different titles, a range of durations, and different category badges.
**Principle / Heuristic:** Polish supports trust (Principle 8)
**Teaching note:** Placeholder repetition hides layout fragility. Use varied content to stress-test components at design time.

---

## Resolved Findings

All findings from Rev 1 and the direct-fix pass have been resolved. Listed here for traceability.

**DR-01 — S4 — RESOLVED (Rev 1)**
Notifications step rebuilt with Training Assignment card and Notifications Config card.

**DR-02 — S4 — RESOLVED (Rev 1)**
PLAYGROUND sidebar label replaced with Simulations.

**DR-03 — S4 — RESOLVED (Rev 1)**
Compliance checkbox replaced with DS Checkbox component + disabled CTA state.

**DR-04 — S3 — RESOLVED (Rev 1)**
Coming Soon / Secondary placeholder text replaced in stat cards.

**DR-06 — S3 — RESOLVED (Rev 1)**
Result screen stats corrected to Did Not Engage: 89.3%.

**DR-07 — S3 — RESOLVED (Rev 1)**
Campaign list table added with 5 representative rows and toolbar.

**DR-09 — S4 — RESOLVED (direct fix)**
Review screen Form Container rebuilt with four-section campaign summary: Campaign Setup (name, channel, schedule, duration), Template (templates selected, persona, kill chain stage), Target Audience (users, groups, exclusions), Notifications (trigger, recipients, event). Compliance checkbox and disabled CTA remain as the final gate below the summary.

**DR-10 — S2 — RESOLVED (direct fix)**
Section header "Moderate" badges updated to "Risk: Moderate" across all 18 direct-node instances in In Progress and Result screens. Table-cell instance badges (where the column header provides context) left as-is.

**DR-11 — S2 — RESOLVED (direct fix)**
3-day accuracy note on Result screen updated to past tense: "Results include a 3-day post-campaign window before interactions were marked as 'did not engage.'"

**DR-12 — S2 — RESOLVED (Rev 1)**
Secondary token-name text nodes removed.

**DR-15 — S2 — RESOLVED (direct fix)**
Tab 1 placeholder labels in User Performance section replaced with: Risk Scores, Training Progress, Time on Platform, Simulation History — in both In Progress and Result screens.

**DR-16 — S2 — RESOLVED (direct fix)**
"Log In" instance default text replaced with "—" in both In Progress and Result screens.

---

## Strengths

- **Review screen campaign summary is the right pattern.** Four read-only summary sections above the compliance gate give the admin full visibility before confirming an irreversible action. This is how a consequential wizard step should be designed.
- **Graduated stat funnel remains the strongest individual surface.** Targeted → Delivered → Clicked → Submitted Credentials → Entered MFA with absolute numbers and percentages tells the full campaign story. The "Risk: Moderate" section headers now add explicit context to the risk badge pattern.
- **Compliance acknowledgment is correctly implemented.** DS Checkbox with a disabled CTA that enables on check, plus a checked-state annotation — unambiguous for both admins and developers.
- **Campaign table landing is production-ready.** Five status types, seven columns, filter toolbar, and representative row data. An admin can evaluate the full list surface without guessing.
- **Notifications step rebuild correctly mirrors the Scheduled detail screen.** The wizard form and the read-only detail view are now in sync — a strong sign of coherent feature design.

---

## Open Questions

- **[PM]** Is the "Reported" signal card confirmed for v1? Per `open-questions.md`, smishing_reported is pending Phase 0 validation. Answer determines whether DR-05 needs to be designed before handoff or deferred.
- **[PM]** What are the confirmed v1 tabs for the User Performance section? The current design shows Users, Departments, Risk Scores, Training Progress, Time on Platform, Simulation History — confirm which are in scope before handoff.
- **[Design]** Wizard step bar ARIA annotation (DR-13) — needs to be added before handoff doc is written.

---

## Revision Priorities

1. **Confirm DR-05 scope with PM.** If Reported signal is v1, add the stat card to the funnel before handoff. If deferred, close the question.
2. **Add wizard step bar accessibility annotation** (DR-13) — 10-minute annotation task, required before `dev-handoff` is run.
3. **Fix "Save Changes" CTA on Template Preview panel** (DR-08) — replace with "Close" or "Use Template."
4. **Replace Ransomware 4mins placeholder content** (DR-14) with varied training card data when time permits.

---

## Verdict

**Ready for handoff** — pending the DR-13 accessibility annotation and PM confirmation on DR-05 scope.

The wizard flow is complete and trust-correct. All S4 and S2 blockers have been resolved. The two remaining S3 findings (Reported signal and Preview panel CTA) do not block handoff for the rest of the feature — they can be addressed in parallel or in a follow-up.

Run `/dev-handoff` once the step bar annotation is in place.
