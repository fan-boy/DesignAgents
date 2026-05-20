# Competitor Analysis — Red Team Campaign Launcher
Dune Security · Competitive Intelligence · Last updated: 2026-05-08

---

## Feature context

**Goal:** Let security admins launch adversarial multi-channel campaigns (SMS + WhatsApp v1; Viber, Telegram, vishing on roadmap) against real employees, targeting individuals and groups, with a launch flow that inherits the SMS phishing wizard pattern.

**Key open design questions this research informs:**
- Is unified multi-channel campaign orchestration a differentiator or table stakes?
- What does the market do about SMS/WhatsApp compliance gating?
- How do competitors handle delivery failure?
- Is self-serve vishing achievable, or is managed service the only viable model?
- What's the right channel-selection targeting model (campaign-level, group-level, user-level)?

**Source:** `prd-research.json` + `open-questions.md` (2026-05-08)

---

## Competitors reviewed

| Competitor | Tier | Rationale | Confidence |
|---|---|---|---|
| KnowBe4 | Direct | Largest SAT market share; most mature simulation feature set; smishing history (now discontinued via different path) | High — support docs, changelog, official KB |
| Hoxhunt | Direct | Closest peer on adaptive targeting; confirmed real SMS delivery; most formalized SMS consent framework | High — product pages, help docs, changelog |
| Proofpoint SAT + Lucy | Direct | Confirmed SMS as first-class campaign type; acquired Lucy (WhatsApp support); threat-correlated simulation | Medium — product pages; some features inferred from LUCY acquisition |
| Cofense | Direct | Multi-channel positioning; explicit stance on real-SMS compliance risk; vishing as managed service | High — official blog, product docs, services pages |
| Gophish (open source) | Adjacent | UX simplicity benchmark; widely used by red teamers who bolt on SMS tooling externally | High — open source, fully observable |

**Not included:** CybSafe, SoSafe — neither has documented multi-channel simulation capability at the campaign-launcher level.

---

## Workflow comparison

### KnowBe4

**Entry point:** Phishing > Campaigns > +Create Phishing Campaign (email). Callback Phishing is a separate navigation area. No SMS campaign type exists.

**Campaign creation:** Single-page form (not a wizard). Fields: campaign name, audience (All Users or Specific Groups), template topics + difficulty filter, template selection, frequency, timing window, start date, tracking duration. Notably flat — no step-by-step progression, no per-step validation gates.

**Channel model:** Implicit per-campaign-type, not selectable. Email campaigns, QR code campaigns, callback phishing campaigns, and USB tests each live in separate nav areas. An admin cannot run a single campaign that sends email to some users and SMS to others.

**Targeting:** Group-based only (no per-user assignment). Smart Groups (Platinum/Diamond) allow rule-based dynamic group composition based on prior behavior.

**Delivery failure:** Email shows a "Bounced" count in the campaign dashboard. Admins download a CSV of failures. No automatic retry. No documented failure-handling for callback phishing.

**Vishing situation:** Direct outbound vishing (true attacker-initiated calls) was **discontinued January 1, 2023** — carriers cannot distinguish simulation from real attacks, creating legal exposure for customers. The replacement is "Callback Phishing" (Diamond-only): an email is sent with a phone number and code; the employee calls in to KnowBe4's IVR. This is email-initiated with an inbound voice component — not adversarial vishing.

**SMS/smishing:** No native feature. Not listed in the Types of Simulated Phishing Tests documentation. Blog content covers smishing as a threat vector but does not correspond to a product capability.

**Compliance gates:** None documented for campaign creation. No pre-launch acknowledgment step.

**RBAC:** Full admin or nothing below Platinum. Granular security roles (e.g., view-only campaign results without launch permission) are Platinum/Diamond only.

**Reporting:** Per-campaign dashboard: Phish-prone Percentage, clicks in first 8 hours, click-by-day chart, bounced count, Top 50 Clickers. No unified cross-channel report — email and callback results live in separate dashboards.

---

### Hoxhunt

**Entry point:** Two modes. Adaptive (default): admin configures the program once; AI runs simulations continuously without per-campaign decisions. Manual: admin selects template, target group, frequency — closest to a traditional campaign wizard.

**Channel model:** Real SMS to devices (confirmed). Microsoft Teams (confirmed). Voice/vishing via two modes: (a) callback simulations (email-initiated inbound IVR, similar to KnowBe4 Callback Phishing); (b) AI deepfake voice/video targeting executive-support roles — a custom managed engagement, not self-serve. WhatsApp not confirmed in reviewed sources. Channel enrollment is part of the program setup, not per-campaign selection.

**Targeting:** Most granular of all reviewed platforms. Behavioral cohort rules by role, department, and location. Frequency tiers: high-risk roles (finance, IT, exec support) at 1–4 weeks; baseline at monthly/quarterly; new hires on 30/60/90-day tracks; repeat clickers on weekly micro-drills. **Inference:** True per-user cross-channel routing (send user A SMS because they're mobile-heavy) is likely AI-driven inference, not admin configuration.

**SMS compliance gate (most formalized reviewed):** Before any SMS campaign can launch:
1. A legal amendment documenting sub-processors must be signed.
2. Documented opt-in proof (handbook acknowledgment, portal screenshot) is required for US/Canada recipients per FCC/FTC.
3. Works council review documentation is required for EU recipients under GDPR.

This gate is enforced out-of-band by Hoxhunt's team, not as a self-serve in-product checklist. The platform confirms consent status but does not walk admins through it.

**Delivery failure:** Not publicly documented. Carrier-aware geographic distribution is noted for SMS, suggesting carrier-level routing exists, but per-user failure surfaces are not confirmed.

**Reporting:** Strongest multi-channel posture reviewed. Unified Human Risk Dashboard across all channels: reporting rate, fail rate, time-to-report, behavior trend over time. SMS reporting integrates with native iOS "Report Message" — reported SMS flows into the same threat feed as email. Post-click micro-training (30–60 second push notifications) is the primary immediate remediation.

**RBAC:** Enterprise RBAC with delegated admin, multi-entity (region/BU) structures, and audit logs. Meaningful split: who can modify program parameters (cohort rules, channel enrollment, frequency) vs. who can only view the Human Risk Dashboard.

---

### Proofpoint SAT (+ Lucy)

**Entry point:** Proofpoint lists SMS/smishing as a named campaign type alongside email — channel selection happens at campaign creation, not as a post-setup toggle. Lucy (acquired by Proofpoint, integration status unclear) has two creation paths: Wizard Mode (email only) and Expert Mode (smishing and WhatsApp available, but Expert Mode only — not in the simplified flow).

**Channel model:** Parallel single-channel campaigns. Picking "smishing" templates is a top-level campaign-type decision. AI ThreatFlip (converts real-world phishing lures to simulation templates in one click) is email-only. WhatsApp: inferred from Lucy v5.5 acquisition — not confirmed in Proofpoint's main product marketing.

**Targeting:** Auto-enrollment of high-risk users into training is documented. Satori AI provides "threat-informed simulation recommendations" by group/cohort. Per-user channel routing is not documented.

**Lucy SMS specifics (high operational friction):**
- Smishing is **Expert Mode only** — not in the simplified wizard.
- **4-week carrier whitelisting lead time** required before first SMS campaign (range: 4 days to 4 weeks by jurisdiction).
- Formal written consent document must be submitted to the SMS carrier.
- Lucy recommends involving a CSM or Solutions Engineer before any SMS campaign starts.

**Compliance gates:** No in-product pre-launch compliance gate documented in Proofpoint's main product. Lucy's whitelisting requirement is an operational prerequisite handled out-of-band, not surfaced as a UI checkpoint.

**Delivery failure:** No documented per-user failure handling or fallback logic. The 4-week whitelisting process is framed as failure prevention, not failure recovery.

**Reporting:** Threat-intelligence integration (real-world lure conversion) is Proofpoint's strongest differentiator. Multi-channel reporting structure not confirmed.

**RBAC:** Not detailed in reviewed sources.

---

### Cofense

**Entry point:** PhishMe Playbooks — a guided wizard that configures a 12-month program (scenarios, templates, training content) in a few clicks. Azure AD sync provisions targets automatically.

**Channel model:** "Multi-channel" is marketed but means different things per channel:
- **Email:** Self-serve, full wizard.
- **SMS/WhatsApp:** In-platform simulation module only — a training module that displays a mock SMS/WhatsApp UI inside the LMS, not real messages sent to employee devices. Cofense explicitly avoids real-device SMS simulation, citing TCPA (FCC), GDPR, and UK PECR exposure in a published blog post: "Thinking of Smishing Your Employees? Think Twice."
- **Vishing:** Fully managed service — trained Cofense callers using IVR scripts, launched December 2023. This is scoped through a Cofense services intake process (scope call, target list submission, script review, scheduling), not a self-serve campaign launcher.

**Compliance:** Cofense's explicit policy is that real-device SMS simulation pushes legal/regulatory exposure onto the customer, and they recommend in-platform simulation as the safe alternative. For vishing, compliance is handled by the Cofense services team during the intake engagement.

**Delivery failure:** Not applicable for in-platform SMS simulation (no real send, no carrier risk). Vishing failure handling is managed by the Cofense callers directly.

**Reporting:** Email results in the admin dashboard. Vishing post-engagement reports are delivered as a PDF/presentation deliverable from the Cofense services team — not auto-populated in the dashboard. Multi-channel reporting is siloed.

**RBAC:** Access controls and AD group sync are documented. Meaningful RBAC split for vishing: customer admin (initiates engagement, views summary) vs. Cofense services team (executes). No "launch voice campaign" button.

---

### Gophish (open source)

**Entry point:** Clean 3-step campaign creation: name + select template + select targets + launch.

**Channel model:** Email only. No SMS, WhatsApp, or vishing capabilities. Red teamers who use Gophish frequently extend it with external SMS tooling (custom scripts, Twilio, etc.) — the platform provides no multi-channel support.

**Compliance:** No gates. No acknowledgment. No RBAC. Fully open.

**Delivery failure:** No per-user failure handling. Results dashboard shows opens and clicks.

**Key signal:** Gophish is the UX simplicity benchmark. Its launch UX (create → launch in 3 steps) is the aspiration for efficiency. The gap between Gophish's simplicity and the operational complexity of real-device SMS reveals exactly where product investment is required.

---

## Patterns worth adopting

**1. Separate campaign type per channel (KnowBe4, Proofpoint, Lucy)**
Every platform that supports multiple channels treats channel selection as a campaign-type decision — you choose what kind of campaign you're creating before entering the wizard. This is cleaner than a channel toggle buried inside a step of the campaign wizard, and it pre-filters the template library, targeting options, and compliance steps to what's relevant for that channel.

**2. Coverage/delivery-gap visibility before launch (KnowBe4)**
KnowBe4's "Bounced" metric and CSV download give admins a post-mortem on delivery failures. Surfacing coverage gaps *before* launch (à la the SMS phishing coverage indicator) is more valuable — but the pattern of per-user delivery status being accessible after launch is worth keeping.

**3. Behavioral cohort targeting with AI-driven frequency tiers (Hoxhunt)**
High-risk roles get more frequent, harder simulations automatically. This is the most sophisticated targeting model reviewed. The underlying segmentation logic (role + department + location + behavior history → frequency tier) is a pattern Dune's risk scoring model is well-positioned to adopt.

**4. Unified behavioral dashboard across channels (Hoxhunt)**
Reporting rate, fail rate, and behavior trend in one view regardless of whether the event came from email, SMS, or Teams. This is the correct long-term pattern — siloed reporting (Cofense) is an anti-pattern.

**5. Micro-training immediately on click, not after a separate training assignment (Hoxhunt)**
30–60 second push notification with the teaching point fires the moment a simulated link is clicked, before the admin has to configure remediation. This lowers the cognitive gap between failure and learning. The SMS phishing remediation agent model (assign module, then training completes) is heavier but more configurable — worth examining whether a lighter micro-feedback layer could co-exist.

---

## Anti-patterns to avoid

**1. Smishing as Expert Mode only (Lucy / Proofpoint)**
Locking SMS campaign creation behind an advanced mode signals that the channel is a power-user afterthought. It also means that the simplified wizard doesn't benefit from the constraints and guardrails that SMS requires (character limits, compliance acknowledgment, coverage indicator). Dune's SMS phishing wizard bakes these in as first-class steps — don't regress to Expert Mode hiding.

**2. Out-of-band compliance gates (all reviewed platforms)**
No competitor surfaces SMS consent status, carrier whitelist state, or works council clearance inside the product. Admins must chase these down externally before launching. This is where friction accumulates and launches get blocked without clear resolution paths. Building a pre-flight compliance checklist into the launch flow is both a differentiation opportunity and a trust mechanism — the admin always knows what's cleared and what's pending.

**3. Vishing discontinued due to carrier risk without a clear successor (KnowBe4)**
Discontinuing a feature because carriers can't distinguish simulation from real attacks — and replacing it with a non-equivalent inbound IVR workaround — damages admin trust and limits red team realism. The lesson: any vishing architecture must have a clear carrier/legal compliance model from day one, not a reactive shutdown later. Dune's vishing architecture must answer this question before a single UI element is designed.

**4. Siloed multi-channel reporting (KnowBe4, Cofense)**
Admins comparing email phishing results and SMS red team results have to open two separate dashboards and manually correlate. This is friction at the insight layer — the moment when a security program is supposed to tell a coherent behavioral story. A unified view is not yet common; it's a real differentiator.

**5. No per-user delivery failure surface (universal)**
Every platform either doesn't document delivery failure handling or treats it as a post-hoc CSV export. Admins who launch a red team campaign to 200 people and get 30 SMS failures have no in-product way to understand which users were missed, why, or what to do next. Per-user failure states with actionable resolution paths (fix the number, fall back to a different channel, exclude from count) are absent across the board.

**6. Real-device SMS avoided via in-platform simulation (Cofense)**
Simulating SMS inside an LMS module (a mock SMS bubble on screen) is not red teaming — it's a training exercise. It doesn't test real behavior on a real device. Cofense's conservative stance is legally defensible but defeats the purpose of a red team campaign. Dune's model of actually delivering real SMS to devices is correct; the compliance model must be rigorous, not the delivery model neutered.

---

## Differentiation opportunities

**1. Unified multi-channel campaign orchestration (unoccupied by all reviewed platforms)**
No competitor supports a single campaign that routes different users to different channels — email for some, SMS for others, based on role, device profile, or risk score. This is the most significant structural gap. For red team campaigns, the ability to say "send executive-targeted WhatsApp lures to the finance team and SMS to field employees in a single exercise" is both more realistic (attackers don't pick one channel) and more operationally efficient for the admin.

**2. Embedded pre-flight compliance checklist**
Hoxhunt requires a legal amendment, opt-in proof, and works council clearance before SMS launches — but enforces this out-of-band. An in-product compliance status panel (carrier whitelisted ✓, consent documented ✓, works council cleared pending) embedded in the campaign review step would be a first-of-its-kind UX for this space. It removes the admin's burden of tracking compliance state in email threads and gives Dune a clear paper trail.

**3. Per-user delivery failure surface with fallback routing**
The market has no documented answer to "what happens when an SMS doesn't deliver?" A per-user delivery status view with failure reasons (carrier rejection, invalid number, not on WhatsApp) and an explicit fallback decision (retry on different channel, exclude, notify admin) would be a genuine improvement over the current industry norm of silent exclusion or post-hoc CSV.

**4. Self-serve vishing with clear carrier-compliance architecture**
KnowBe4 discontinued outbound vishing because carrier policy creates legal exposure. Cofense and Hoxhunt moved vishing to managed service. The self-serve vishing opportunity is real — but only with a well-designed compliance model upfront (carrier-aware sending, admin-confirmed consent, pre-approved scripts). The architecture question from the PRD research must be answered before design begins, but if Dune solves this, it's a category differentiator.

**5. Behavioral risk score as a targeting input**
Hoxhunt's adaptive model uses behavioral history to drive targeting automatically. Dune's existing risk scores are richer (tied to email phishing failures, training completion, group risk profile). Using risk score thresholds as targeting criteria for red team campaigns (e.g., "target all users who scored Medium or above on the SMS risk module") would make red team exercises more adversarially accurate and reduce the blast radius of broad group targeting.

---

## Implications for design

1. **Channel selection should be a campaign-type decision, not a wizard-step toggle.** Follow the Proofpoint/KnowBe4 pattern: the admin chooses "Red Team — SMS," "Red Team — WhatsApp," or "Red Team — Multi-channel" before entering the wizard. This pre-filters templates, compliance steps, and targeting options. Don't bury a channel dropdown inside Step 2.

2. **SMS and WhatsApp coverage indicators must be per-channel, not aggregate.** "428 of 512 have SMS coverage" is not enough when some users are WhatsApp-only. The audience step needs a multi-row breakdown: X have SMS, Y have WhatsApp, Z have both, W have neither.

3. **Design the compliance pre-flight panel as a first-class wizard step.** The market leaves compliance out-of-band. Dune should surface carrier whitelist status, consent documentation state, and any works council flags inline — with a clear "not ready to launch" state if any are unresolved. This is a trust and liability differentiator.

4. **The vishing architecture question must be resolved before any UI is designed.** KnowBe4's discontinuation is a direct warning: self-serve outbound vishing creates carrier compliance exposure that has forced at least one major vendor to shut the feature down. If Dune builds vishing as a self-serve campaign type, the carrier compliance model must be solved first. If it's a managed service model, the UX is not a campaign wizard but an intake flow.

5. **Design per-user delivery failure states explicitly.** The market doesn't. For the campaign detail view, each target row should show channel-specific delivery status (SMS delivered, WhatsApp failed — reason: not on WhatsApp), with a fallback action available at the row level (send via alternate channel, exclude from exercise).

6. **Do not neuter the delivery model to avoid compliance complexity.** Cofense's in-platform SMS simulation (a mock bubble in an LMS) is not red teaming. The compliance model must be rigorous — but the SMS and WhatsApp messages must actually reach the employee's device. Don't trade realism for compliance ease.

---

## Confidence notes

- **KnowBe4:** High confidence. All findings from official support documentation, changelogs, and KB articles. The vishing discontinuation is confirmed via an official KB article with a specific date.
- **Hoxhunt:** High confidence on SMS delivery model, compliance framework requirements, and adaptive targeting. Deepfake vishing engagement model is from product pages but terms are less precise — labeled as inference where appropriate.
- **Proofpoint SAT:** Medium confidence. Main product page confirms SMS as a campaign type, but depth of feature is unclear from public docs. LUCY acquisition integration status is inferred — WhatsApp support is from Lucy's own changelog pre-acquisition, not from Proofpoint's current product marketing.
- **Cofense:** High confidence. In-platform SMS simulation stance is from an official Cofense blog post with explicit TCPA/GDPR reasoning. Vishing as managed service is from the product pages and press release (December 2023 launch).
- **Gophish:** High confidence — open source, fully observable.
- **Lucy Security:** High confidence on Expert Mode constraint and 4-week carrier whitelisting — from official Lucy wiki documentation.
