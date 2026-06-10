# PRD Research — Vishing Campaign Launcher

**Last updated:** 2026-06-10

---

## Feature Summary

The Vishing Campaign Launcher adds voice phishing as a third adversarial channel to the existing Red Team Campaign Launcher. Security admins (Red Team admin role) configure campaigns through the same 8-step wizard (+1 for OSINT review), select a Voice AEP as the caller persona, and submit the configuration. Dune executes calls via AI-driven VOIP; outcome events stream into the platform per call. Voice AEPs are a new, structurally richer type in the AEP Library: a three-step builder covering Persona (caller identity, voice, tone, banned phrases), Scenario (phases, collectibles, tactics, goals with a live visualization), and Test & Refine (live call + scenario flow replay). A Facts/OSINT system stores per-organization intelligence (CISO name, tooling, company news, internal policies) that is injected into the AI at runtime and reviewed by the admin in a dedicated wizard step (Step 3.5) before campaign submission. Success means an admin can commission a vishing exercise with confidence in what the AI will say, who it is impersonating, and what organizational context it will use.

**Missing from PRD:** No success metric defined. No explicit SLA commitment from Dune ops for activation. No operator-side interaction model described.

---

## Gaps and Ambiguities

**1. Fundamental execution model contradiction — AI-driven vs. human-operated calls.**
The PRD states in the AEP Step 2 section that clicking "Call Test Number" lets the admin "experience the AI caller persona live," confirming AI-driven calls. But Step 5 says "vishing calls are placed manually within the configured window" and the campaign detail calls operators "actively placing calls." This is not a documentation inconsistency — it's an unresolved architecture decision. If calls are AI-driven (VOIP bot), the entire AEP system translates into real call behavior. If calls are human-operated (Dune red teamers using the script as a guide), the AEP fields are just a briefing document, and the "live test call" means calling a human caller who is using the script. This distinction changes: the test-call UX, the campaign timeline expectations, the scalability of campaign size, and the "live streaming" outcome model. **This is the single highest-leverage open question in the feature.**

**2. Caller identity and VOIP caller ID spoofing — legally and technically constrained.**
The PRD describes "Caller Name, Claimed Company, Claimed Role" as values that "Dune's VOIP system presents as the caller's identity during the call." In practice, STIR/SHAKEN (US) and equivalent frameworks (EU's ETSI TS 103 120) govern caller ID authenticity. VOIP caller ID spoofing to display an arbitrary business name is restricted or illegal in many jurisdictions. If Dune cannot spoof caller ID at the VOIP layer, these fields are script context for operators only — not VOIP configuration. The field labels, help text, and Step 3 script preview copy all need to accurately represent what is technically achievable, or admins will expect a call displaying "Acme IT Support" and get one showing Dune's VOIP number.

**3. Compliance checks are self-certified, not platform-verified — but the UI implies verification.**
Step 4 renders compliance items as ✓ Active / ⚠ Pending / ✗ Unresolved status cards — the same pattern used for WhatsApp API status and SMS carrier whitelist, which are platform-verified states. But "Call recording consent on file" and "One-party vs. two-party consent jurisdiction" have no described upload or verification mechanism. Without IDP SCIM, the platform cannot know target jurisdictions. Without a consent document store, it cannot confirm consent is on file. If these checks are self-certified (admin checks a box), the UI should reflect that — a checkbox or affirmation pattern, not a status card that implies platform verification. Presenting self-certifications as verified checks creates a false compliance signal.

**4. "Pending Activation" is a UX dead end — no feedback loop described.**
After the admin submits a campaign request, the campaign enters Pending Activation. The PRD describes the status badge and confirmation screen but nothing about what happens if Dune ops need to request changes before activating — for example, if the script contains legally risky language, the call window is implausible, or the compliance consent documentation is absent. There is no described ops-to-admin feedback channel. Admins have no way to know if their request is "under review," "approved," or "needs revision." This is a trust gap: admins submitting a carefully configured campaign and hearing nothing until it activates (or doesn't) will erode confidence in the product.

**5. Call outcome classification responsibility is unspecified.**
The call outcome states (Engaged, Compromised, Declined) are described as classified "in real time as Dune operators work through the campaign." This implies operators manually classify each call's outcome — there is no described automatic classification for voice calls the way there is for text (link clicked = Compromised). The PRD doesn't describe where or how operators enter these classifications, what the latency is between a call completing and the classification appearing in the platform, or whether outcomes can be misclassified and corrected. This is a data pipeline gap that affects the entire live monitoring surface.

**6. OSINT / Facts system is a new design surface with no precedent in the existing product.**
The PRD now includes a Step 3.5 (Review Organizational Intelligence) where admins review the tenant-level facts database before submitting a campaign. This surface has no analog in the existing wizard or AEP Library. It introduces: a categorized facts table, a scenario-relevance column (which phases each fact is relevant to), per-fact actions (edit, suppress, flag), and two new states (empty-facts and all-suppressed). The design risk is that admins may skip this step perfunctorily without understanding its impact on call realism. The copy and layout of Step 3.5 must frame facts as a capability ("here's what the AI knows about your company"), not a compliance gate.

**7. Debrief flow is absent.**
The Step 8 compliance acknowledgment states the admin "is responsible for managing the debrief and disclosure process." For vishing, this is significant — employees received real phone calls from what appeared to be a legitimate caller. There is no described debrief functionality in the platform: no bulk notification tool, no debrief message template, no timing control for when targets receive disclosure. The text campaign PRD is equally silent on debrief, but voice is higher-stakes because employees may have taken action (called IT, flagged to a manager, experienced distress). This is likely out-of-platform in v1, but should be explicitly flagged.

**7. Campaign edit flow during Pending Activation is unspecified.**
Can an admin edit a submitted campaign while it's in Pending Activation? For text campaigns, editing a submitted campaign is not described either, but the stakes are lower — a delayed SMS campaign is recoverable. For vishing, the admin may want to adjust the call window, update the AEP, or add campaign notes after submission but before calls begin. The absence of this flow is either intentional (frozen after submit) or an oversight. Either way, the behavior must be explicit.

**8. Susceptibility rate denominator differs from text campaigns — inconsistency risk.**
In text campaigns (Red Team Campaign Launcher), susceptibility rate = Complicit / Total Delivered. In the vishing PRD, susceptibility rate = Complicit / Reached (targets who answered). These denominators are different: a vishing campaign with 50% No Answer will show a higher susceptibility rate than a text campaign with the same number of Compromised targets, because the denominator is smaller. If these rates appear in the same reporting surface (e.g., a "Red Team Campaigns" overview), they will be non-comparable. Either standardize on Total Targets as the denominator across all channels, or label rates differently and explain the basis.

---

## Missing States

### System states
- VOIP infrastructure goes from Active to Degraded while a campaign is in Calling status — does the platform detect this and pause automatically, or do ops handle it manually?
- Call classification event arrives but cannot be matched to a target (data pipeline error) — what appears in the Call Log row?
- Test call in AEP Step 2 completes but the "Mark test call as reviewed" checkbox doesn't appear (VOIP event not received) — how does the admin unblock themselves?
- Campaign auto-completes because the campaign date window has passed, but some targets were never attempted — how is this surfaced in the final stats?

### Permission states
- Admin with Red Team admin role who does not have a registered phone number tries to place a test call in Step 7 — no pre-filled number, no guidance on what number to use
- Standard admin views a campaign in Pending Activation — no relevant actions available; empty action area needs a clear "view only" affordance
- Dune Operator reviews a submitted campaign — no described operator-side UI or permission model for this role
- Admin views a campaign while Dune ops have internally paused it (ops-side pause, not admin-initiated) — is the campaign status visible?

### Content states
- Voice AEP library has only one published AEP — single-item selector state (no search, no filter needed)
- Campaign submitted with campaign-specific calling notes that are very long — no character limit described; operator panel rendering of long notes is undefined
- Call Log table on a large campaign (500+ targets) — pagination behavior, loading state, and initial load performance not described
- Campaign with zero Reached targets at completion (all No Answer) — stats row shows 0/0 susceptibility; how is this displayed without a division error?

### Action states
- Admin pauses a campaign mid-execution — do in-progress calls (calls currently connected) complete or are they cut off?
- Admin edits the Voice AEP after it's been selected in a submitted-but-not-yet-activated campaign — since the AEP is locked once in an active campaign, is it locked at submission or at activation?
- Admin re-tags a call outcome from Non-Complicit to Complicit after the campaign is completed — does this change the susceptibility rate in the Overview tab retroactively?
- Admin clicks Export CSV while the campaign is still in Calling status — does export include in-progress data or only completed campaigns?

### Responsive / Accessibility
- Step 7 test call on mobile — admin may want to receive the test call on the same device they're configuring the campaign on; simultaneous browser interaction and receiving a call may not be feasible on mobile
- Call Log table column collapse order on narrow viewports not described (text campaign PRD describes this explicitly for the Conversations tab)
- Color-coded badge states (Not Yet Called = gray, No Answer = gray) — two states use the same color; screen reader and color-blind users cannot distinguish them by color alone; text label differentiation is required

---

## Questions for PM / Eng

1. **[Both]** Is the VOIP execution AI-driven (automated bot calls each target using the Voice AEP persona) or human-operated (Dune red teamers place calls manually using the script)? This is the highest-leverage unresolved question — answer changes the AEP test flow, campaign scale limits, and outcome streaming model.

2. **[Eng]** Does Dune's VOIP infrastructure support caller ID spoofing — presenting an arbitrary name and company on the recipient's caller display? If not, what identity information, if any, is surfaced to the call recipient? This affects whether the "Caller Identity" fields are VOIP-level config or script briefing only, and how the help text and Step 3 preview should be written.

3. **[PM]** Where is "call recording consent on file" stored and verified? Is this an org-level document uploaded in a Compliance Settings section, a per-campaign self-certification, or something Dune ops confirm manually? Same question for the one-party/two-party consent jurisdiction check.

4. **[PM]** Is there a feedback mechanism for Dune ops to request changes to a submitted campaign before activating it? Or is ops' only option to activate or contact the admin outside the platform?

5. **[Eng]** How are call outcomes classified — does the VOIP system emit semantic outcome events (e.g., "target disclosed MFA code"), or do Dune operators manually enter classification in an ops panel after each call? What is the expected latency between a call completing and its classification appearing in the platform?

6. **[PM]** Should campaign edits be allowed while in Pending Activation? If yes, does editing reset the review queue? If no, how is this communicated to admins who want to make last-minute adjustments?

7. **[PM]** How should the susceptibility rate denominator work for vishing — Complicit / Reached or Complicit / Total Targets? The current PRD uses Reached, which makes vishing rates non-comparable to text campaign rates. Is comparability a goal?

8. **[PM]** Is debrief entirely out-of-platform for v1? If so, should the post-campaign reporting view include a "Debrief resources" section or guidance on the disclosure process?

9. **[Eng]** When the admin pauses a vishing campaign, are in-progress calls (currently connected) terminated immediately, or do they complete naturally before the pause takes effect?

10. **[PM]** Is the Voice AEP locked at campaign submission (Pending Activation) or only at campaign activation (Calling)? If locked at submission, can an admin edit the AEP between submission and activation?

---

## Design Risks

**AI-vs-human execution ambiguity creates false expectations about campaign scale and speed.**
If admins believe calls are AI-driven (automated), they may configure campaigns of 200+ targets expecting overnight completion. If execution is human-operated, a 200-target campaign requires significant Dune operator bandwidth. The product must set accurate expectations at Step 1 and the campaign submission confirmation — or admins will submit large campaigns and be confused when they take days to complete.

**Compliance check UI implies verification where none exists.**
The Step 4 status card pattern (✓ / ⚠ / ✗) is used for platform-verified states throughout the product. Using it for self-certified compliance items (consent documentation, jurisdiction) will cause admins to assume the platform has checked these items. If a campaign runs without actual consent on file, Dune has legal exposure. The pattern should visually distinguish self-certifications from platform-verified checks.

**Pending Activation is a trust vacuum for admins.**
Submitting a configured campaign and waiting with no status update is a high-anxiety experience — particularly for admins who have budget pressure or scheduled debriefs. Without a visible review status, estimated activation time, or contact path, admins will generate support tickets. If ops take longer than the described "one business day," there's no mechanism for the admin to know why.

**Call outcome states are ambiguous at the boundary.**
"Engaged" and "Compromised" are classified by operators (or system) based on subjective call behavior. For text campaigns, Compromised is objective (link clicked). For voice, there may be ambiguous calls where the target provided partial information, asked clarifying questions, or stated intent to comply but did not yet act. Without clear classification criteria for operators and for re-tagging purposes, the re-tag direction (Non-Complicit → Complicit only) may not capture the full nuance of voice call outcomes.

**Two gray badge states break visual scanning in the Call Log table.**
"Not Yet Called" and "No Answer" both use gray badges. On a large campaign in progress, a mix of gray-badged rows will be visually indistinguishable at a glance. Admins scanning the table to find targets who need follow-up (Callback Requested) or to monitor for engagement will have to read badge text, not scan badge color. At minimum, "Not Yet Called" should use a neutral non-gray (e.g., white with border) or a different visual treatment.

**Voice AEP channel type selector is a one-way decision with late consequences.**
The Channel Type selector (Text / Voice) is the first step in the AEP builder — but its consequences (completely different Step 2 UI, non-interchangeable campaign selection) aren't visible until later. An admin who builds a full Text AEP and realizes they needed a Voice AEP must start over. The selector should show what changes downstream (brief preview of "what you're configuring") before the admin commits.

---

## Teaching Notes

**Closest existing reference — Red Team Campaign Launcher:** The 8-step wizard pattern, all campaign detail patterns (stats row, in-progress view, post-campaign reporting tabs), and the RBAC model are directly inherited from the Red Team Campaign Launcher (`knowledge/features/red-team-campaign-launcher/prd.md`). Design for vishing wizard steps should visually diff against the text-channel steps, not start from scratch.

**Closest existing reference — AEP Library:** The two-step AEP builder pattern, publish flow, version history, and library table are inherited from the AEP Library (`knowledge/features/aep-library/prd.md`). The Channel Type selector is net-new; it must integrate into the existing builder header without disrupting the established flow.

**Stillsuit DS v2 — wizard pattern:** The 8-step wizard uses the DS v2 wizard pattern with persistent step bar. Steps that "swap variants" based on channel selection (Step 3, 4, 5, 7) are not a new concept — WhatsApp vs. SMS already created multi-variant steps. Design each vishing variant as a step-level replacement, not a new wizard fork.

**Compliance check pattern — verified vs. self-certified:** The existing compliance pre-flight in Step 4 of the text campaign uses status cards for platform-verified states (API status, carrier whitelist). Vishing introduces self-certified items that need a different visual treatment. The DS v2 has a checkbox / acknowledgment pattern (used in Step 8 of the existing wizard) that may be more appropriate for unverifiable items. Mixing them carelessly will read as inconsistent.

**Re-tagging RBAC pattern:** Re-tagging (Non-Complicit → Complicit) is already designed for text campaigns. The vishing Call Log tab re-uses this pattern. Ensure the re-tag drawer or inline interaction handles voice-specific outcome labels (Engaged, Compromised, Declined) rather than the text-channel labels (Curious, Engaged, Hesitant, Compromised, Declined).

**Risk scoring isolation:** Per the existing red team PRD, red team results are assumed isolated from the risk scoring pipeline. This is confirmed for vishing in v1. Do not design any risk score delta indicators in the vishing campaign detail or reporting surfaces — this would contradict the isolation assumption and require Eng confirmation to include.
