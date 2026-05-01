# Competitor Analysis — SMS Phishing (Smishing) Simulation
Dune Security · Competitive Research · Last updated: 2026-05-01

---

## Feature context

Source: `prd-research.json`

**Goal:** Extend Dune's AI-personalized phishing simulation to SMS — enabling security admins to run smishing campaigns against employee phone numbers, score interactions, and trigger remediation.

**Key open constraints shaping this analysis:**
- No existing phone number data model in Dune
- Legal/compliance clearance (TCPA, GDPR) not confirmed
- Sender identity strategy not decided
- Risk scoring integration for SMS click signal not designed
- AI personalization scope for 160-character SMS undefined

---

## Competitors reviewed

| Competitor | Tier | Reason selected | Confidence |
|---|---|---|---|
| KnowBe4 | Direct | Largest SAT incumbent; has had smishing simulation for several years; primary benchmark for enterprise admin workflows | Medium-high |
| Proofpoint SAT | Secondary | Has voice/SMS simulation; relevant for threat-intelligence template angle | Medium |
| Hoxhunt | Direct | Closest peer on adaptive phishing; email-only — included to document the deliberate absence of SMS | Low (SMS-specific) |
| Cofense | Direct | Phishing simulation specialist; email-only — included to document depth-over-breadth positioning | Medium-high |

---

## Workflow comparison

### Stage 1: Phone number and user data requirements

**KnowBe4**
Stores phone numbers in user profiles alongside email. Import paths: CSV upload, Active Directory sync, HRIS integrations (Workday, BambooHR, others). Phone field is optional per user — the platform proceeds with partial coverage and shows coverage gaps in the user management UI. [Confidence: medium-high, based on published help center documentation]

**Proofpoint SAT**
Phone numbers sourced from Active Directory attributes or CSV. Less flexible import tooling. Coverage visualization is less prominent — admins must filter the user list manually to find gaps. [Confidence: medium, based on product documentation and G2 reviews]

**Hoxhunt / Cofense**
Email-only. Phone data is not part of the user model for either. [Confidence: medium-high]

---

### Stage 2: Campaign creation entry point

**KnowBe4**
Entry from the main Phishing navigation section. Campaign type selector at wizard start includes "Smishing" as a first-class option alongside Email, Vishing, and multi-vector. Multi-vector campaigns (combined email + SMS) are a separate option. [Confidence: medium-high]

**Proofpoint SAT**
SMS/voice simulations are presented as a subsection rather than a peer channel to email — the navigation hierarchy signals it as a secondary capability. [Confidence: medium, partially inferred from documentation structure]

---

### Stage 3: Template library and message creation

**KnowBe4**
Dedicated Smishing Templates library. Categories: IT helpdesk, HR/payroll, bank and financial alerts, package delivery, executive impersonation. Variable substitution fields (first name, company name) supported. No evidence of AI-generated personalization beyond token substitution. Character count visible in the editor. [Confidence: medium-high]

**Proofpoint SAT**
Smaller template library for SMS. Templates are informed by Proofpoint's threat intelligence feed — realistic lures correlated with active campaigns in the wild. More limited customization. No observed AI personalization. [Confidence: medium]

---

### Stage 4: Scheduling, targeting, and launch

**KnowBe4**
Same scheduling and group-targeting interface as email phishing. Group selection with member count preview. Exclusion windows supported. Delivery spread (randomize send time across a window) is available to avoid simultaneous delivery. Pre-launch review shows estimated delivery count and coverage warnings for members missing phone numbers — surfaced as a warning, not a hard block. [Confidence: medium-high]

**Proofpoint SAT**
Similar scheduling structure. Exclusion logic and delivery spread are less configurable. Pre-launch review is present but less detailed on data quality issues. [Confidence: medium, partially inferred]

---

### Stage 5: Delivery and interaction tracking

**KnowBe4**
Tracks link clicks as the primary smishing event. No open event (not applicable to SMS). Bot/scanner click filtering is documented as automated — mechanism not publicly disclosed; filtered counts not shown to admins. Results in campaign detail with per-user breakdown. [Confidence: medium-high]

**Proofpoint SAT**
Similar click-tracking model. Less prominent documentation of bot-click filtering. Results in campaign reporting. [Confidence: medium]

---

### Stage 6: Debrief experience

**KnowBe4**
Employee who clicks lands on a mobile-optimized training page explaining it was a simulated attack, showing what clues they missed, and linking to a short training module. Designed for mobile viewport. [Confidence: medium-high, based on documented user experience]

**Proofpoint SAT**
Debrief landing page exists but mobile optimization quality is not clearly documented. Likely a responsive adaptation of their desktop debrief rather than a mobile-first design. [Confidence: low — inferred from product design posture]

---

### Stage 7: Risk score integration

**KnowBe4 (SmartRisk Score)**
Smishing click events contribute to the SmartRisk Score alongside email phishing events. No visible evidence of channel-specific weighting — all phishing simulation clicks appear treated with equivalent weight. [Confidence: medium]

---

## Patterns worth adopting

**1. Channel type selector at wizard start — not buried in settings.**
KnowBe4 presents Smishing as a first-class type at the wizard's opening step. This signals SMS simulation as a peer channel, not a bolt-on. Dune should adopt this: if SMS lives in a submenu or secondary tab, admins will underdiscover it.

**2. Coverage warning before launch — warning, not a hard block.**
KnowBe4 shows how many group members will be excluded due to missing phone numbers, but lets the admin proceed. Right balance between information and autonomy. A hard block frustrates; a silent skip corrupts results.

**3. Template categories mapped to realistic lure types.**
KnowBe4 organizes templates by attack vector (HR, IT, financial, delivery) rather than by industry. Mirrors how real attacks are categorized. Worth adopting — but Dune should also surface threat intelligence freshness signals, which KnowBe4 does not clearly do on the SMS side.

**4. Delivery spread as a configurable (and default-on) option.**
Sending all campaign messages simultaneously is unrealistic and obvious. KnowBe4 supports a randomized send window. Dune should make this the smart default, not an advanced option.

**5. Mobile-first debrief landing page.**
KnowBe4 invests in a mobile-optimized debrief for smishing. Employees who click a smishing link are on mobile. This is the right call and must be a new surface, not a resize.

---

## Anti-patterns to avoid

**1. SMS as a secondary navigation item.**
Proofpoint buries SMS under a subcategory. This communicates secondary capability and reduces adoption. Do not place smishing in a sub-tab or "Other" category in campaign creation.

**2. Template-only personalization labeled as AI.**
KnowBe4 and Proofpoint both use variable substitution (first name, company name) — not AI generation. If Dune ships the same and markets it as "AI-personalized smishing," it fails the credibility test, especially against Dune's existing spear phishing positioning. If v1 is template-based, name it as such.

**3. Silent partial delivery.**
Neither competitor clearly surfaces what happened when delivery was partial. If this is buried in a log, admins draw wrong conclusions from metrics. Dune must surface delivery completeness prominently — delivered count vs. target count with reason breakdown.

**4. Desktop debrief served to mobile.**
A responsive stretch of the desktop experience on a phone screen will feel broken — small tap targets, dense copy, horizontal scroll. The debrief is where employee trust is rebuilt after a simulated attack. A poor mobile experience at that moment is a trust failure.

**5. Flat risk signal treatment — SMS click equated to email click.**
Treating a smishing click identically to an email click loses signal fidelity. SMS is a different threat vector with different susceptibility patterns. KnowBe4 appears to blend signals without weighting — a gap Dune can exploit with a channel-aware risk scoring model.

---

## Differentiation opportunities

**1. Genuine AI personalization for SMS — not template substitution.**
No observed competitor uses a spear phishing AI engine to generate contextually personalized 160-character smishing messages. All are template + token substitution. Dune's spear phishing engine — if adapted — could generate messages that reference role, department, or organizational context naturally. Meaningful differentiation if shipped correctly.

**2. Channel-aware risk scoring.**
Treating SMS clicks as a distinct behavioral signal enables more nuanced risk profiling. An employee who clicks email phishing but resists SMS has a different risk profile than one who fails both. Dune can model channel susceptibility separately. No competitor observed doing this.

**3. Coordinated multi-channel simulation — priming email + follow-up SMS.**
KnowBe4 supports multi-vector campaigns but they're effectively parallel single-channel sends. Dune could design a coordinated attack scenario: a priming email followed by a follow-up SMS — simulating real advanced social engineering. First-in-market narrative and a reinforcement of the AI personalization story.

**4. Phone number coverage health as a first-class UX element.**
No competitor treats phone number coverage quality as a visible, actionable product metric. Surfacing coverage rate per group (e.g., "74% of this group has a verified phone number") as a persistent indicator turns a data quality problem into a feature.

**5. Transparent bot-click filtering with admin visibility.**
KnowBe4 claims automated bot-click filtering but does not show the filtered count to admins. Showing admins how many clicks were filtered as scanner/bot activity (with a brief explanation) builds trust in result integrity — particularly important for enterprise security teams who scrutinize metrics.

---

## Implications for design

1. Campaign wizard must present SMS as a first-class channel type at the top-level step.
2. Phone number coverage must surface at two points: group selection step (inline covered/uncovered count) and campaign results (delivery completeness with reason breakdown).
3. Template library needs categories grounded in realistic lure types (IT, HR, financial, delivery, executive). Mark templates by threat intelligence freshness if available.
4. Message editor must show a live character counter with encoding detection — warn when message switches from GSM-7 to Unicode encoding.
5. Delivery spread should be a smart default (randomize within 4-hour window), not an advanced option.
6. Mobile debrief landing page is a new design surface — design for 375px viewport, use Pause/Verify/Report framework, under 150 words.
7. Risk score treatment should be surfaced as a visible decision in reporting UI rather than silently blended.
8. If v1 is template-based only, use "Smart Templates" — do not use AI framing until the personalization engine is genuinely operating on SMS content.

---

## Confidence notes

- KnowBe4 observations are medium-high confidence based on published help center documentation and demo recordings. UI details may have changed.
- Proofpoint SAT observations are medium confidence; some inferences from documentation structure and G2 reviews rather than direct UI observation.
- Hoxhunt SMS absence is medium confidence — no SMS simulation found in public materials; treated as email-only.
- Cofense email-only is medium-high confidence based on explicit product positioning.
- No direct product session access was used for any competitor in this analysis.
