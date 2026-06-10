## Last updated
2026-06-10 — Added OSINT/Facts differentiator section. Dune's organizational intelligence injection (facts system) has no equivalent in any reviewed competitor.

---

## Feature Context

The Vishing Campaign Launcher adds voice phishing as a third adversarial channel to Dune's Red Team Campaign Launcher. Admins configure campaigns through the existing 8-step wizard, select a Voice AEP as the caller persona, and submit a campaign request. Dune executes calls via managed VOIP; outcome events stream per call. Key design questions: how should compliance gating work, what outcome states serve red team buyers, and how does the admin experience of configuring a voice persona differ from templated vishing tools?

---

## Competitors Reviewed

| Competitor | Tier | Vishing Status | Confidence |
|---|---|---|---|
| KnowBe4 | Direct | Production — IVR-based VST (template-driven, automated) | High (support docs + press release observed) |
| Adaptive Security | Direct | Production — AI voice personas, exec impersonation, multi-channel | Medium (product page + blog observed; config details inferred) |
| Hoxhunt | Direct | Managed service only — deepfake + voice as vendor-delivered custom engagement | High (blog + buyer's guide confirmed) |
| SoSafe | Direct | Early access — demo-style one-off call, not self-serve recurring campaigns | Medium (product news observed) |
| Proofpoint | Direct | Not a documented core feature; voice via ecosystem integrations only | High (confirmed absent from docs) |

**Registry gap noted:** Brightside AI is not in `knowledge/competitor-list.md` but appeared as the most fully featured vishing-specific product in market research. Observations included for context, labeled as non-registry. Recommend adding to competitor list.

---

## Workflow Comparison

### KnowBe4 — Vishing Security Test (VST)

**Entry point:** KSAT Admin Console > Phishing section > Vishing Security Tests (Gold tier and above).

**Setup friction:** Admin must upload a CSV file of employee phone numbers. Phone numbers are not sourced from the directory/group system used for email phishing — this is a separate, manual data import step. No group targeting integration.

**Core flow:**
1. Upload CSV with phone numbers
2. Select a VST template (5 Kevin Mitnick VST Scenarios™ available; also supports admin-customized TTS scripts)
3. Set campaign frequency (recurring or one-time)
4. Configure time window (business hours by default; admin can adjust)
5. Launch — fully automated from this point

**Execution model:** Fully automated. Calls are placed by KnowBe4's IVR system without human involvement. The system uses pre-recorded messages or text-to-speech. No live AI conversation — the call plays a scripted message and waits for keypad input. Real-time adaptive conversation is not supported.

**Outcome states:** Binary. **Pass** = target did not enter data via keypad. **Fail** = target entered data via keypad in response to the vishing prompt. No behavioral gradations (engaged vs. compromised vs. declined). No "no answer" differentiation from "answered and declined."

**Reporting:** Outcomes appear in the standard phishing activity report. Vishing is treated as another phishing test type — no dedicated vishing reporting surface. Admins can filter by "Vishing Security Test Outcome." Email report dispatch available on test completion.

**Compliance:** Not addressed in-product. No call recording consent check, no jurisdiction handling, no works council gate.

**Trust model:** Low. No pre-flight review, no compliance acknowledgment. Campaign launches immediately after setup completion.

**Repeat use efficiency:** Set-and-forget recurring frequency selector. Templates are reusable. CSV upload must be repeated to update targeting.

**RBAC notes:** Gold tier account required. No described sub-admin role differentiation for vishing specifically.

**Differentiation note:** KnowBe4's VST is an awareness training tool, not a red team tool. Binary pass/fail + IVR execution is appropriate for "did the user press 1" tests, not for measuring adversarial engagement depth. The CSV-upload audience model is a regression from group-based targeting.

---

### Adaptive Security — AI Voice Phishing

**Entry point:** Platform > Phishing Simulations > Voice (within broader automated campaign program).

**Setup friction:** Admin uploads audio/video files or selects from available voice personas. Executive voice cloning requires headshot photos and recorded audio. Multi-channel campaigns (email → voice follow-up → SMS) are configured as coordinated scenario sequences.

**Core flow (inferred from product page + blog):**
1. Define the attack goal and target role
2. Select or create a voice persona (executive impersonation or generic personas)
3. Configure scenario context and social engineering tactics
4. Set targeting (role-based, adaptive difficulty)
5. Launch — automated execution, always-on campaigns with continuous delivery

**Execution model:** Fully automated. AI-generated voice calls using custom executive personas or generic caller voices. The system places and conducts calls without human involvement. Adaptive difficulty — the AI adjusts scenario complexity based on per-user behavior history.

**Outcome states:** Not publicly documented in detail. Behavioral outcome metrics implied (engagement patterns, information disclosure rates). Risk score integration — simulation outcomes feed into the platform's human risk score.

**Reporting:** Unified dashboard. Remediation training triggers automatically on failure. Risk-correlated reporting connects simulation outcomes to behavioral risk scores.

**Compliance:** Not explicitly described in-product. No public documentation of call recording consent gates, jurisdiction handling, or works council requirements.

**Trust model:** Medium. Continuous "always-on" execution model — admins configure once, campaigns run indefinitely. Limited described pre-flight review.

**Repeat use efficiency:** High — always-on model means no per-campaign relaunch. Role-based targeting updates dynamically.

**AI personalization surface:** Strong. Executive voice cloning, OSINT-driven scenario personalization, adaptive difficulty per user. Most sophisticated AI voice model in the registry.

**Risk score surface:** Strong. Vishing outcomes feed into human risk scores — integration is a core product differentiator.

---

### Hoxhunt — Deepfake + Voice (Managed Service)

**Entry point:** Not a self-serve platform feature. Accessed through engagement with Hoxhunt's team as a custom managed service.

**Setup friction:** High. Admin cannot configure or launch independently. Hoxhunt's team builds the scenario: selects/creates a specific executive's likeness and voice, designs the pretext, and delivers on the organization's behalf.

**Core flow:**
1. Admin engages Hoxhunt team (sales/CS)
2. Hoxhunt team captures executive voice/video sample
3. Hoxhunt builds deepfake scenario
4. Hoxhunt delivers the campaign on agreed timeline
5. Results returned to admin in platform

**Execution model:** Fully managed. Human-operated by vendor. Not self-serve.

**Outcome states:** Per-employee reporting tied to the behavioral model (who fell, who reported). Adaptive difficulty feedback loop.

**Reporting:** Integrated into Hoxhunt's standard reporting. "What changed" behavioral metrics emphasized over binary pass/fail.

**Compliance:** Not described. Managed service model implies compliance responsibility sits with Hoxhunt team, not admin.

**Trust model:** High for capability, low for admin control. Admins have no direct visibility into what scenario will be used or when it will execute until post-delivery.

**Repeat use efficiency:** Low — each engagement is custom. Not repeatable without vendor involvement.

---

### SoSafe — Vishing (Early Access)

**Entry point:** Not available as a self-serve recurring campaign. Described as a "demo experience" and "exclusive simulation" for demonstrating vishing risk to executives.

**Execution model:** One-off managed demo call using publicly available data to craft a personalized scenario. SoSafe team executes the call.

**Outcome states:** Not documented.

**Compliance:** Not described.

**Differentiation note:** SoSafe's vishing offering is positioned for executive buy-in, not employee-scale training programs. It is not a competing product for the use case Dune is building.

---

## Patterns Worth Adopting

**Automated execution is the market expectation.** Every platform except Hoxhunt's custom service uses automated VOIP/AI calls. Admins submitting campaigns and waiting for human operators is a below-market pattern. If Dune's v1 execution model is human-operated, the product must set this expectation clearly and explicitly — admins familiar with KnowBe4 or Adaptive will assume automation and be confused by the "Pending Activation" model.

**Time window configuration is standard.** KnowBe4 defaults to business hours with admin override. Adaptive uses always-on with role-based timing. Defining a call window is a recognized concept — no need to explain it in the UI.

**Role-based targeting is expected for self-serve.** Adaptive's role-based targeting and KnowBe4's group-based phishing model set an expectation that admins target by role or group, not by CSV upload. Dune's group picker for vishing is correct and differentiated vs. KnowBe4's CSV model.

**Immediate remediation coupling.** Adaptive automatically assigns training on failure. Dune's opt-in remediation suppression model is more appropriate for red team, but the UI should make clear how it differs from standard simulation behavior — admins may expect auto-remediation.

---

## Anti-Patterns to Avoid

**CSV upload for phone number targeting.** KnowBe4 requires a CSV file separate from its user directory, forcing duplicate data management. Dune's group picker integration is strictly better. Never regress to CSV upload for audience selection.

**Binary pass/fail outcomes for red team campaigns.** KnowBe4's "entered keypad data = fail" is adequate for IVR-based awareness training but completely inappropriate for a red team adversarial context. Red team buyers need behavioral gradations (Engaged, Compromised, Declined, Callback Requested) to distinguish between a target who asked one clarifying question and a target who provided their MFA code. Dune's 5-state model is the right design.

**Vishing siloed from other red team channels.** Competitors treat vishing as a separate product section or add-on. Unified red team management (vishing + SMS + WhatsApp in one campaign launcher) is a material UX and operational advantage. Do not introduce a separate "Vishing" nav item.

**Always-on execution without admin control points.** Adaptive's continuous execution model removes admin visibility into when campaigns fire. Dune's explicit campaign date + call window + review step preserves admin agency, which is particularly important for red team (debrief scheduling depends on knowing when calls will happen).

**No compliance surface at all.** No competitor has explicit in-product compliance gating. This is a gap Dune can own — especially for enterprise and EMEA customers. The compliance pre-flight step is differentiated, not overhead.

---

## Differentiation Opportunities

**Richest outcome taxonomy in the market.** Dune's 5-state model (Not Yet Called, No Answer, Engaged, Compromised, Declined, Callback Requested) vs. binary pass/fail across all competitors. For red team buyers — the security teams who want to understand behavioral depth, not just click-through rates — this is a material product advantage. Design the Call Log table and badge system to make this depth immediately visible in the reporting surface.

**Voice AEP as a structured Persona + Scenario builder.** No competitor has a purpose-built workflow for creating, testing, and versioning voice caller personas and their call playbooks as distinct, separately-versioned components. KnowBe4 uses fixed Kevin Mitnick templates with binary script branching. Adaptive does exec impersonation via audio upload with no admin-configurable scenario structure. Dune's Persona step (voice, greeting, banned phrases, tone) + Scenario step (phases, tactics, collectibles, goals) + visual call flow diagram is unlike anything in the market. The tactic library — with per-phase intent descriptions, example templates, and `allowed_next` graph edges — is an engineering-grade playbook that no competitor surfaces to admins.

**OSINT-grounded scenario personalization via organized facts.** No competitor has a mechanism for injecting company-specific organizational intelligence into the AI caller at runtime. KnowBe4 and Adaptive use generic templates with static variable substitution (first name, company name). Dune's facts system — with 15+ fact types organized by category (org chart, tooling, news, policies, vendors), sensitivity ratings, relevant phase mapping, and per-campaign admin review — makes each call specifically convincing in a way that cannot be replicated by script-based competitors. This is a structural moat: the quality of a Dune vishing call improves as the facts database deepens. The admin review step (Step 3.5) that surfaces this data is itself a differentiator — it makes AI realism transparent and admin-accountable rather than a black box.

**Voice AEP as a structured caller persona builder.** No competitor has a purpose-built workflow for creating, testing, and versioning voice caller personas. KnowBe4 uses fixed Kevin Mitnick templates. Adaptive does exec impersonation via audio upload. Dune's Persona configuration + Scenario configuration + test call workflow is genuinely differentiated. The AEP library model (version history, publish workflow, campaign linkage) is unique in the market.

**Compliance-aware wizard as a trust signal.** The compliance pre-flight step (Step 4) with explicit consent, jurisdiction, and works council checks is absent from every competitor. For enterprise accounts — particularly EMEA — this turns a compliance anxiety into a product feature. The design language should frame it as "we built the compliance work into the product" rather than making it feel like a blocker.

**Unified red team campaign surface.** Positioning vishing alongside SMS and WhatsApp in one wizard, with unified reporting and RBAC, is unique. Competitors silo vishing. The single Red Team campaign launcher narrative is a story Dune can tell that no competitor can match in v1.

**Live call monitoring during campaign.** Auto-refresh call log with per-call state tracking during execution is more sophisticated than any described competitor reporting surface for vishing. The in-progress view (Calling status, real-time stats row, Call Log table) is a meaningful UX differentiator for campaigns running over multiple days.

**Request model with explicit debrief responsibility.** The "admin configures, Dune executes" model (vs. Hoxhunt's fully opaque managed service) keeps the admin informed and in control of the debrief process. This is appropriate for enterprise red team buyers who must manage internal disclosure. The Step 8 CTA language ("Submit Campaign Request") and the compliance acknowledgment copy should emphasize this agency, not minimize it.

---

## Implications for Design

1. **Set execution model expectations at Step 1, not Step 8.** The "Dune executes" note currently lives as a contextual callout on the Vishing channel card. Given that every competitor uses automated execution, admins who have used other tools will assume automation unless told otherwise upfront and clearly.

2. **Compliance pre-flight UI needs to distinguish verified from self-certified.** Competitors use no compliance gates at all. Dune is introducing a new concept. The UI must make the distinction between platform-verified states (VOIP status) and self-certified acknowledgments (consent, jurisdiction) obvious — or admins will treat self-certifications as verified checks, creating false compliance confidence.

3. **Outcome states need legend and education on first use.** No competitor has 5-state outcome taxonomy for vishing. Red team buyers may be familiar with binary pass/fail from previous tools. A brief glossary or first-use tooltip on the Call Log table (and during the in-progress view) will reduce confusion about what "Engaged" vs. "Compromised" means in a voice context.

4. **Voice AEP Channel Type selector must show downstream consequences.** No competitor has a comparable concept. Admins new to Voice AEPs won't understand the 3-step structure (Persona → Scenario → Test & Refine) until they commit. The channel type selector in the AEP builder should preview the 3-step structure and hint at the scenario visualization before the admin commits.

5. **OSINT review step must feel like empowerment, not bureaucracy.** The facts review in Step 3.5 is structurally new — no competitor requires this. Position it as "here's what the AI knows about your company" rather than a compliance gate. The scenario relevance column (showing which phases each fact feeds into) is key to making this feel purposeful rather than a checkbox exercise.

5. **Reporting must not look like a phishing dashboard.** KnowBe4 surfaces vishing results in the same report table as email phishing. The risk is that Dune's vishing reporting feels like a bolted-on addition to the simulation dashboard. The two-tab (Overview + Call Log) structure should have distinct vishing-specific charts (Attempt Distribution, Reached vs. No Answer) that signal this is a purpose-built reporting surface, not a repurposed email phishing template.

---

## Confidence Notes

- KnowBe4 VST: **High confidence.** Support documentation and press release directly observed. Product behavior confirmed.
- Adaptive Security: **Medium confidence.** Product page and blog observed. Campaign configuration workflow inferred from feature descriptions — not directly observed in product console.
- Hoxhunt: **High confidence.** Managed service nature confirmed across multiple sources (blog post, buyer's guide). Absence of self-serve vishing confirmed.
- SoSafe: **Medium confidence.** Early access nature confirmed from product news. Limited detail on actual workflow.
- Proofpoint: **High confidence.** Absence of vishing as documented core feature confirmed.
- Brightside AI (non-registry): Observed for market context only. Not a direct competitor per registry. Five-step configuration framework and dedicated vishing metrics dashboard patterns noted as market leading.
