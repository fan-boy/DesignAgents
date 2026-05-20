# Competitor Analysis — AEP Library (Custom AEP Builder)
Dune Security · Competitor Intelligence · Last updated: 2026-05-20

---

## Feature context

The AEP Library is Dune's section for managing Adversary Emulation Pathways — AI chatbot personas that conduct live social engineering conversations autonomously. The feature includes a Dune-seeded library of 3–4 pre-built AEPs and a custom AEP builder for org admins to create up to 4–5 tenant-specific ones. The central design question is: what is the right authoring model for an AI agent persona — free-text prompt, structured form, or hybrid?

Research focus:
1. How do competitors handle custom AI agent or persona authoring for simulations?
2. How do platforms present a library of pre-built vs. custom scenarios?
3. How do platforms support testing or previewing agent behavior before campaign deployment?
4. What adversary method taxonomies do competitors use?

---

## Competitors reviewed

| Competitor | Relevance | Confidence |
|---|---|---|
| KnowBe4 | Template library UX, AI-assisted generation (AIDA), clone-and-customize pattern | High — public KB docs reviewed |
| Adaptive Security | AI persona building, deepfake simulation, custom persona configuration | Medium — product blog + landing pages; UX internals inferred |
| Hoxhunt | Adaptive scenario delivery, multi-channel simulation, difficulty adjustment | Medium — public product pages and blog reviewed |
| Breacher.ai | Orchestrated multi-stage social engineering, playbook model, closest to AEP concept | Medium — product pages reviewed; admin UX not directly observed |

**Not included:** Proofpoint, Cofense, Ninjio, Curricula, CybSafe, SoSafe, Mimecast — none have AI-driven conversational agent building for social engineering.

---

## Workflow comparison

### KnowBe4 — Template Library + AIDA AI Generation

**Entry point:** Phishing > Phishing Templates > My Templates

**Library model:**
- Two tiers: System Templates (KnowBe4-managed, read-only) and My Templates (custom, admin-owned)
- System templates are browseable by category (industry, seasonal, current events), attack vector, difficulty, and language
- Custom templates live under "My Templates" — clear visual and nav separation from the KnowBe4 catalog
- Templates can be cloned from System Templates into My Templates — clone → edit is the primary customization path

**Custom template creation:**
- Manual path: WYSIWYG email body editor + form fields for sender name, subject, landing page URL
- AI-assisted path (AIDA — Diamond tier add-on): admin writes a brief plain-language description ("a Microsoft Office 365 login alert pretending to be from IT"), selects attack vector type, sets difficulty via a 1–5 star slider → AIDA generates a complete email template
- Difficulty slider maps to Social Engineering Indicators (SEI) from the NIST Phish Scale Framework — higher difficulty means fewer obvious red flags in the generated email
- Quick Create vs. Advanced mode — Quick Create reduces fields visible to the admin; Advanced exposes all parameters

**Preview/testing:**
- Template preview renders the email as the recipient would see it before saving
- No live behavioral simulation — templates are static email artifacts; preview is visual only
- Can send a test phishing email to oneself before full campaign deployment

**RBAC:** Admin role required for template creation; all admins have the same template authoring access

**Adversary method taxonomy:** KnowBe4 uses attack vectors (email, callback phishing, vishing, QR code) and Social Engineering Indicators (SEI) as their classification system — not a persona or adversary method taxonomy. Attack "type" is the channel, not the psychological manipulation technique.

---

### Adaptive Security — Custom AI Deepfake Personas

**Entry point:** Admin platform — Simulations or Personas section (exact nav inferred from product blog)

**Persona model:**
- Adaptive generates AI personas modeled on the organization's executives — voice, video, name, visual likeness
- Two persona types: (1) OSINT-driven email personas (auto-generated from public data about the target employee and org), (2) Custom Deepfake Personas (admin triggers generation of a specific executive's AI voice/video clone)
- Custom deepfake persona creation: admin selects an executive (by name/role), triggers AI generation, platform produces a synthetic voice profile and video avatar — admin does not write a behavior prompt; the AI generates the persona from existing data
- "Interactive AI Avatar" (in Feature Preview as of 2026): a conversational deepfake video agent for live simulations — admin configuration scope not publicly documented

**Key distinction from Dune AEPs:** Adaptive's custom personas are audio/visual representations of real people (deepfakes of executives), not behavioral/scenario authoring. The "prompt" is implicit in the person being impersonated — the admin selects who to impersonate, not how to behave.

**Testing/preview:** Deepfake Experience demo available externally. Internal simulator scope not documented.

**Adversary method taxonomy:** Not publicly exposed. Attack categories map to channel: email, SMS, voice call, video call. No psychological technique taxonomy visible.

---

### Hoxhunt — Adaptive Simulation Delivery

**Entry point:** Admin dashboard → Simulation settings

**Scenario model:**
- All scenarios are Hoxhunt-managed — no custom scenario authoring by admins
- Admin controls: select active threat types (email, Slack/Teams, SMS, deepfake video), set difficulty range per group, enable/disable specific threat channels
- Adaptive difficulty: platform auto-adjusts scenario difficulty per employee based on their performance history (more likely to click → easier scenarios; consistent reporters → harder ones)
- Deepfake Attack Simulation (launched 2025): phishing email → mock video call page with AI-generated manager deepfake — scenario structure is Hoxhunt-defined, not custom
- Multi-channel: email phishing, Slack/Teams phishing, SMS/smishing, deepfake video

**Custom authoring:** None observed. Admins parameterize delivery (who, when, which channels, difficulty range) but cannot author new scenarios or personas.

**Testing/preview:** Not publicly documented. Likely limited to seeing what a simulation looks like as an employee before enabling it.

**Adversary method taxonomy:** Attack categories are channel-based (email, Slack, SMS, video), not technique-based. No influence taxonomy visible.

---

### Breacher.ai — Orchestrated Social Engineering Simulations

**Entry point:** Platform admin → Simulation campaigns

**Scenario model:**
- Two modes: ready-made playbooks (Breacher-defined, covering common multi-stage attack chains) and custom campaign builder (admin configures the specific attack chain)
- Playbooks cover specific attack patterns: voice + email + deepfake combinations, targeting specific roles (finance, HR, IT)
- Custom campaigns: admin selects attack types to chain (email → voice call → Teams deepfake), configures targeting and timing — behavioral content of each step is AI-generated at runtime, not authored by admin
- "Agentic AI social engineering": AI bots conduct adaptive conversations during the attack — scenario content is generated dynamically, not scripted
- Admin role is orchestration (what channels, what sequence, who is targeted) not persona authoring (what the agent says or how it behaves)

**Key distinction from Dune AEPs:** Breacher focuses on multi-stage attack orchestration. The AI generates conversation content at runtime; admins don't write system prompts. The closest analogue is the Attack Library (sequencing channels), not the AEP builder (authoring behavior).

**Testing/preview:** Not documented publicly.

**Adversary method taxonomy:** Playbook names map to attack goals ("BEC Wire Transfer," "Executive Impersonation," "IT Help Desk") — role and objective based, not psychological technique based.

---

## Patterns worth adopting

**1. Clone-and-customize as the primary creation path (KnowBe4)**
The fastest way for an admin to create a custom artifact is to clone an existing managed one and modify it — not start from scratch. Applied to AEPs: "Duplicate from library" on a Dune-seeded AEP should be a primary entry point into the builder, not a secondary option. This also prevents blank-canvas anxiety for admins unfamiliar with prompt engineering.

**2. Guided generation with plain-language input + structured parameters (KnowBe4 AIDA)**
AIDA's model — admin writes a brief description in plain language, selects a few structured parameters (attack vector, difficulty), AI generates the artifact — is more admin-friendly than a raw prompt editor. For AEPs: "Describe the scenario in your own words" + structured fields for Adversary Method and difficulty → system generates a starting prompt and workflow steps. Admin refines from there rather than starting with a blank prompt box.

**3. Tiered library with clear visual separation between managed and custom (KnowBe4)**
KnowBe4's consistent nav split between "System Templates" and "My Templates" sets clear expectations: you can use and clone the managed ones, but you only own and can edit the custom ones. The card design should signal this without requiring the user to read labels carefully — ownership badge, edit affordance, or different card weight.

**4. Difficulty / behavior parameter as a slider or structured control, not free-form (KnowBe4 AIDA)**
Presenting key behavioral parameters as sliders or select fields (difficulty level, aggression level, persona formality) reduces the cognitive load of prompt engineering for non-technical admins while still giving fine-grained control. Raw prompt is available in advanced mode; structured controls are the default.

**5. Channel + target role as the primary attack categorization (Breacher.ai)**
Breacher's playbook model — named by target role and goal, not by psychological technique — shows that admins respond to "IT Help Desk Impersonation" more intuitively than "Authority-Based Scenario." The AEP name and description should be human-readable and role-specific; Adversary Method (Authority-Based, Urgency, etc.) is a secondary classification for analytics, not the primary browse label.

---

## Anti-patterns to avoid

**1. Exposing raw system prompt as the only authoring interface**
No competitor exposes a raw LLM system prompt editor directly. Even the most technical platforms (AIDA, Adaptive) abstract the prompt behind structured inputs or AI generation. A blank text area labeled "Write your AEP prompt here" will produce poor-quality AEPs from most admins and erode trust in the feature. The prompt should be surfaced in Advanced mode — not the default entry point.

**2. No behavioral preview before deployment (industry-wide gap)**
None of the competitors offer a live conversational simulator. KnowBe4's preview is static (visual email render + test send). Hoxhunt has no documented preview. Adaptive shows deepfake examples. This is a gap across the market — Dune's live chat simulator is genuinely differentiating. The anti-pattern to avoid: making the simulator optional or burying it at the bottom of the builder flow. It must be a required step — or at least strongly encouraged — before the AEP is published.

**3. Attack type as channel, not technique (all competitors)**
Every competitor classifies attacks by delivery channel (email, SMS, voice, video) rather than by psychological manipulation technique (Authority, Urgency, Reciprocity, Scarcity, Social Proof). This limits analytics to "what channel did we use" rather than "which cognitive biases are our employees most vulnerable to." Dune's Adversary Method taxonomy (Authority-Based, Urgency-Based, etc.) is a meaningful differentiator for risk reporting — but it must be a controlled vocabulary, not free-form, to be analytically useful.

**4. No versioning or campaign-lock for deployed templates (industry assumption)**
KnowBe4 templates are typically static artifacts — once created and used in a campaign, they're fixed. There is no documented version-locking behavior. For Dune's conversational AEPs, this is higher-stakes: editing an AEP mid-campaign would change live conversation behavior in unpredictable ways. Design for explicit version-locking at campaign creation — this is not solved by competitors and must be addressed from the start.

**5. Duplicate-name risk in large libraries (KnowBe4)**
KnowBe4's "My Templates" section can accumulate many templates with similar names over time. Admins have reported confusion between template versions. With a small custom limit (4–5 AEPs), this is less of a risk for Dune — but AEP naming conventions (unique name validation, clear display of method and creation date on the card) should be enforced from the start.

---

## Differentiation opportunities

**1. The live conversational simulator is a genuine market gap**
No competitor offers a live chat test loop where the admin plays the target and tests the AEP's behavior before deployment. Breacher and Adaptive do AI-vs-target testing, but not an admin-interactive preview. A well-designed simulator — split-pane, real-time, with conversation reset and iteration — is a product differentiator and a quality gate that competitors don't have.

**2. Adversary Method as an influence taxonomy, not a channel label**
Dune can own the psychological technique dimension of social engineering reporting. "Your employees are most vulnerable to Authority-Based attacks" is a more actionable insight than "your employees failed SMS simulations more often." A controlled Adversary Method vocabulary (Authority, Urgency, Reciprocity, Curiosity, Scarcity, Familiarity) tied to AEP metadata enables risk reporting that no competitor currently offers at this granularity.

**3. AI-assisted AEP generation from a brief**
Following the AIDA model but applied to conversational agents: admin describes the scenario in plain language ("A vendor following up on a payment request, escalating urgency if ignored") → system generates a starting system prompt, workflow steps, and suggested adversary method → admin reviews and refines. This makes the builder accessible to non-technical admins without sacrificing the depth of a prompt editor for advanced users.

**4. Outcome criteria tied to risk scoring**
Dune's outcome classification (Complicit / Non Complicit / Undetermined / No Response) feeds directly into employee risk scores. No competitor connects simulation outcome definitions to a behavioral risk model in this way. The AEP builder should surface this connection explicitly — "How you define Complicit here will affect employee risk score calculations" — making it clear that outcome criteria are not just display labels.

**5. Dune-seeded AEPs as quality benchmarks**
By shipping 3–4 well-crafted reference AEPs, Dune sets a quality bar that educates admins on what a good AEP looks like. This is more effective than documentation. Clone-and-customize from a Dune AEP lets admins see the structure before they write their own — the best templates teach their own conventions.

---

## Implications for design

1. **Default to guided generation, not a blank prompt box.** The primary builder flow should be: plain-language scenario description + Adversary Method selector + difficulty/aggression controls → AI generates starting prompt and workflow steps → admin edits and refines. Advanced mode exposes the raw prompt.

2. **Make "Duplicate from Library" a first-class entry point.** The seeded AEP cards should have a visible "Use as template" or "Duplicate" action. New AEP creation from scratch is the secondary path.

3. **The simulator is a required step, not an optional preview.** Given that no competitor offers this and it's Dune's primary quality gate, the builder flow should guide admins through at least one simulator session before publishing. Consider a completion indicator: "Simulator test: not yet run" as a visible status on the AEP card.

4. **Adversary Method must be a controlled taxonomy select, not free text.** Define the full list before design begins (Authority, Urgency, Reciprocity, Curiosity, Scarcity, Familiarity/Social Proof — confirm with PM) and wire it to outcome reporting from day one.

5. **Card design for the library grid must separate Dune-seeded and Custom tiers.** Not just by filter — by visual hierarchy. Dune-seeded AEPs may appear in a distinct section header or with a "Dune Library" badge. Custom AEPs show owner, created date, and last used date. Both show Adversary Method as a scannable label.

---

## Confidence notes

- KnowBe4 observations are high-confidence — based on public Knowledge Base documentation, which is authoritative for admin workflows
- Adaptive Security observations are medium-confidence — based on product blog post about Custom Deepfake Personas and marketing landing pages; admin UX internals are inferred
- Hoxhunt observations are medium-confidence — based on public product pages and help docs; no direct admin console access
- Breacher.ai observations are medium-confidence — based on product marketing pages; admin campaign builder UX not directly documented
- No competitor was directly observed operating a conversational AI agent persona builder — this confirms the market gap claim
