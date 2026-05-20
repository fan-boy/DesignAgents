# PRD Research Summary — AEP Builder + AEP Library
Dune Security · PRD Research · Last updated: 2026-05-20 (v2 update — PRD v0.2)

---

## Feature summary

The AEP Builder + Library gives enterprise security managers a self-serve platform to create, test, and manage Adversary Emulation Pathways — AI-powered chatbot personas that conduct live social engineering simulations against employees ("game changers"). Today the entire process is manual: customers fill Word/Excel forms outside the platform, email them to Dune operators, who then generate a JSON persona by hand and load it directly into the backend. One AEP takes approximately one full day.

The PRD replaces this entirely with a three-stage in-platform flow: **Stage 1** (guided 6-section intake form + optional example upload → AI generation), **Stage 2** (live chat test where the customer plays the employee role against the generated persona), and **Stage 3** (natural-language refinement prompts that make targeted field-level edits). Customers cycle between Stage 2 and Stage 3 until satisfied, then publish. Published AEPs are immutable — edits require cloning to a new version.

The AEP Library is a searchable catalog of all customer AEPs with status management, version history, campaign linkage, and a Dune-curated template system as starting points.

**Primary user:** Customer — Security Manager (CISO, security manager, or Red Teaming owner). **Secondary:** Customer — Reviewer (optional sign-off), Dune Operator (internal support), Dune Admin (platform-level).

**Success metrics:** AEP creation < 2 hours (vs. ~1 day today), 0 Dune operator touchpoints for standard cases, > 95% structural validation pass rate on first publish, < 3 refinement rounds avg, > 30% clone/reuse rate.

---

## Gaps and ambiguities

1. **Mandatory reviewer gate vs. optional Reviewer role.** The PRD says publishing "triggers a notification to the Reviewer" if one is configured, and the AEP goes to "Pending Review." But it does not say whether a Reviewer is ever mandatory. If it is, the publish flow needs a blocking "Pending Review" state and a Reviewer approval surface. This changes the end-to-end flow.

2. **Multi-channel deployment model.** Open question #4: does one AEP support simultaneous deployment across multiple channels in one campaign, or is it one channel per campaign per deployment? The data model allows `channels[]`, but the campaign integration section does not define how multi-channel deployment works operationally.

3. **Library scoped per organization or per account/program.** Open question #3: a customer like Concentrix has 10+ account programs (Meta, Google, United Airlines, AT&T). Do they share one library or have one per program? Affects filtering, search, and whether the library counter is per-org or per-program.

4. **AEP hard limit not in PRD.** The initial brief mentioned 4–5 custom AEPs per tenant. The PRD does not specify a hard limit — it describes a searchable library with archive functionality. Unclear if a count cap still applies or if archiving is the management mechanism.

5. **Test LLM cost model is undefined.** Stage 2 uses the full production persona runtime, and there is no limit on test sessions. Open question #5: full production LLM or a lighter model? Cost per session has significant implications for how the unlimited session model is positioned.

6. **Instigation threshold enum may be too coarse.** Three values (none / soft_stop / hard_stop) may not capture real variation. AT&T uses hard stop on first resistance, BUZZ uses "assess but don't overcome," Qantas uses "continue on curiosity." Open question #6.

7. **Refinement prompt cross-field cascading.** Open question #7: can a single prompt cascade changes across dependent field groups (e.g., updating opening message also updates the 1_INITIAL state script)? Affects diff view complexity.

8. **Reviewer notification surface undefined.** PRD mentions notification but does not specify channel (email, in-platform) or what the Reviewer's approval surface looks like.

---

## Missing states

### System states
- Generation failure (partial): some sections succeed, others fail — per-section retry required (REQ-SS-05); all form inputs preserved
- Generation in progress: 15–45s (up to 90s with image OCR); labeled stages: "Analyzing your scenario", "Building the conversation flow", "Configuring guardrails", "Finalizing"
- OCR extraction in progress or failed on image upload (image files require OCR per REQ-SS-03)
- Refinement in progress (< 20s P95) — should the prompt input be disabled until the round completes?
- Form auto-save / resume: can customers close the browser mid-Stage-1 and resume?
- Stage 2 persona response timeout (P95 < 3s; what happens at 4s, 10s?)
- Validation running on demand from Stage 3 ("Check AEP" button)

### Permission states
- Reviewer: read-only AEP detail + approve/request-changes CTA; no Builder access
- Dune Operator: same UI as customer with operator overlay — raw JSON panel, validation override, operator refinement, Operator Assist flag
- Dune Admin: all Operator permissions + global template promotion, global ban list management
- Customer without Red Teaming access: no AEP Library visibility (nav-level RBAC)
- Non-owner customer viewing teammate's draft: visible or private?

### Content states
- Empty library (no AEPs): first-use empty state with "New AEP" + "Start from Template" CTAs
- Draft with 0 test sessions: Publish blocked
- Draft with 1 test session: Publish allowed with acknowledgment warning
- AEP in active/scheduled campaign: Archive blocked; must show blocking campaign names (REQ-LIB-04)
- AEP in completed campaign: Archive allowed with confirmation; version history retains linkage
- Template picker unavailable: graceful error state with retry
- No Active AEPs when creating a campaign: prompt links to AEP Builder

### Action states
- Archive blocked: must name the blocking campaigns in the error message
- Refinement blocked by guardrail: prompt attempts to remove hate speech, violence, or PII patterns — blocked with plain-language explanation (REQ-SS-11)
- Publish blocked: blocking validation failure — customer directed to specific section and field (REQ-VAL-02)
- Publish with warnings: checkbox acknowledgment required per warning before proceeding (REQ-VAL-03)
- Clone: new Draft at incremented version; lineage tracked in metadata.templateLineage
- Operator Assist: customer notification with diff summary of operator changes

### Responsive / Accessibility
- Generation progress screen (up to 90s): labeled stages must visually progress; static spinner would feel broken
- Diff view in Stage 3: accept/reject per field; must be keyboard navigable
- Example upload: drag-and-drop + file picker; per-example OCR feedback on image uploads
- Library table: sort, filter, search must be keyboard accessible

---

## Questions for PM / Eng

1. **[PM]** Is there a scenario where a Dune operator must approve an AEP before it goes live? Or is the optional Reviewer role + validation layer sufficient for all standard cases?

2. **[Both]** Does one AEP support simultaneous deployment across multiple channels in one campaign, or is it one channel per campaign per deployment?

3. **[PM]** Is the AEP library scoped per customer organization or per account/program? (Concentrix has 10+ programs.)

4. **[Eng]** Does Stage 2 use the full production LLM or a lighter model? What is the assumed cost per test session and is there a guardrail on excessive testing?

5. **[Both]** Can a single refinement prompt cascade changes across dependent field groups? How does the diff view surface cross-field dependencies?

6. **[PM]** Is the three-value instigation threshold (none / soft_stop / hard_stop) sufficient, or do we need a richer model given the observed variation across AT&T, BUZZ, and Qantas?

7. **[PM]** Is there a hard limit on Active AEPs per tenant, or is archiving the management mechanism?

8. **[PM]** What is the Reviewer's notification and approval surface? Email, in-platform, or both?

9. **[Eng]** What is the auto-save behavior for Stage 1 form data? Can customers close and resume mid-form?

---

## Design risks

- **Generation wait time + bad feedback = trust failure.** At P95 45s (90s with OCR), a static spinner will feel broken. Labeled stages must visibly progress. If a stage stalls, it should surface an estimated wait, not silence.

- **Stage 3 diff view is the most consequential screen.** Customers accept/reject individual field changes here. If the diff is hard to parse, they will either rubber-stamp everything (negating refinement value) or reject everything (blocking the workflow). Diff legibility needs dedicated design work — not a developer default.

- **Refinement loop without exit signal.** No limit on refinement rounds; customers cycle Stage 2 → Stage 3 indefinitely. Without a quality indicator or completion nudge, customers may publish too early or never publish. Consider a "test coverage" signal based on archetype completion.

- **Templates misrepresented as finished AEPs.** If templates look like deployable AEPs, customers may skip Stage 1 customization and deploy a generic persona without their org's crown jewels or cultural context. Templates must be clearly framed as starting points.

- **Validation warnings becoming click-through.** If warnings fire frequently (especially "only 1 test session completed"), customers will learn to dismiss them. Reserve warnings for genuinely high-risk states and review the threshold for what counts as a warning vs. a UX nudge.

- **Operator Assist trust asymmetry.** An operator modifying a customer's AEP without prior consent (even with notification) creates a trust issue. The Operator Assist notification must be prominent, include a clear diff, and offer the customer a rejection path.

---

## Teaching notes

- **AEP is not a single prompt.** The PRD reveals the full data model: system prompt, classifier prompt, 6-state state machine with scripts per state, detection arrays (denial phrases, interest patterns, guardrail patterns, jailbreak patterns), cultural nuance packages, termination logic, and bot name lists. The Builder form abstracts all of this — customers never interact with JSON — but the designer must understand the complexity to make good decisions about progressive disclosure.

- **6 fixed conversation states.** The state machine has 6 required states: 1_INITIAL through 6_VULNERABILITY. These are fixed in the platform schema; customers configure scripts and transitions, not the states. The state label visible in Stage 2 ("2 — Slight Interest") references this machine.

- **Published AEPs are immutable by design (REQ-SS-12).** Once published, an AEP cannot be edited. Changes require cloning. This means the library accumulates versions over time, and version history is load-bearing UX.

- **Example upload grounds the generation quality.** The PRD Appendix notes that example conversations (real WhatsApp screenshots, forwarded messages) are "the most reliable signal for generating accurate opening messages and cultural register." The upload UI should feel prominent and helpful, not buried or daunting.

- **Template lineage tracked in metadata.** Clones from templates record `metadata.templateLineage`. This powers the reuse rate success metric. Surface lineage in the library (e.g., "Based on: BPO Refund Fraud template") to make templates feel valuable rather than invisible.

- **"Game changers" = employees.** Dune's internal term for the employees being targeted. The customer-facing UI should use "employee" — confirm with PM.

- **Phase 1 target is Q3 2026.** Phase 2 (cross-AEP analytics, multi-version comparison, webhook reviewer flow) is Q4 2026. Phase 3 (marketplace, bot-vs-bot testing, compliance export) is 2027. Design must not scope for Phase 2 features in Phase 1 UI.
