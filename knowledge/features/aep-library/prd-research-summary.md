# PRD Research — AEP Library (Custom AEP Builder)
Dune Security · Design Research · Last updated: 2026-05-20

---

## Feature summary

The AEP Library is one of five sections in Dune's Red Teaming workspace (Agentic Simulation > Red Teaming). It holds Adversary Emulation Pathways — AI-powered chatbot personas that conduct live social engineering conversations autonomously, adapting in real time to how an employee responds.

The feature has two layers:
1. **Dune-seeded library** — 3–4 pre-built AEPs (e.g. "Impersonated IT Support") that ship with the platform and are available to all tenants, read-only.
2. **Custom AEP builder** — org admins can create up to 4–5 custom AEPs by authoring a persona prompt and configuring structured metadata (adversary method, outcome criteria). This is the primary design surface being shaped.

**Primary user:** Org admin (security team lead, red team operator). **Trigger:** Admin needs a social engineering scenario that doesn't exist in Dune's seeded library — an industry-specific persona, a company-branded attacker, or a scenario targeting a known internal vector. **Success:** Admin creates a custom AEP, validates its behavior in a simulator, and successfully deploys it in a red team campaign without Dune engineering involvement.

**What is not defined in the brief:** The exact authoring model (what the admin writes vs. what the system infers), the role of the live simulator in the creation flow, outcome definition methodology, and what happens when the custom limit is reached.

---

## Gaps and ambiguities

1. **The relationship between the prompt and structured metadata is undefined.** An AEP has named sections — Workflow Steps, Branching Logic, Outcome criteria. It's unclear whether these are manually authored by the admin, generated from the prompt, or a combination. If the prompt is the single source of truth and the sections are generated/parsed from it, the UX is a prompt editor with AI-assisted preview. If sections are manually authored, the UX is a structured form with a prompt field for overall behavior. The answer changes the entire builder layout and complexity.

2. **"Adversary Method" appears to be a taxonomy, not free-form.** The screenshot shows "Authority-Based" as the adversary method for AEP-001. It's unclear whether this is a fixed list (Authority-Based, Urgency-Based, Curiosity-Based, Bribe, Reciprocity…), a free-text label, or a controlled vocabulary that maps to LLM behavior. If it maps to model behavior, it's a meaningful selection; if it's a label, it's metadata.

3. **Outcome definitions — authored or generated?** The screenshot shows outcome tabs (Complicit, Non Complicit, Undetermined, No Response) each with criteria bullets. It's unclear whether the admin writes these criteria or whether Dune defines them globally per outcome type, or whether they're generated from the scenario prompt. Outcome definitions directly affect how conversation analysis works downstream — this is not just a display decision.

4. **Live simulator scope is undefined.** The prior strategy describes "prompt editor + live chat simulator test loop" as the creation flow. The simulator presumably runs the AEP's LLM against a test target. Open questions: Does the admin play the role of the target, or is it AI vs. AI? Does simulator behavior count toward any quota or logging? Is it a modal, a split pane, or a separate step?

5. **Custom AEP limit (4–5) has no stated enforcement UX.** When a company has created 4 or 5 custom AEPs, what happens? Can they delete one to make room? Can they request a limit increase? Is the CTA for "New AEP" disabled, hidden, or does it surface an upgrade prompt? Unanswered limits create blocked states with no recovery path.

6. **Editing and versioning are not addressed.** If a custom AEP is edited after being used in a campaign, does the campaign continue using the old version or the new one? AEPs are live LLM prompts — a mid-campaign edit could change agent behavior for in-flight conversations. This is a data integrity question with real HR implications.

7. **Dune-seeded AEPs as templates — is duplication supported?** Admins may want to start from a Dune AEP and customize it. If duplication from a seeded AEP is not supported, admins must recreate similar scenarios from scratch. If it is, the seeded AEPs function as templates, which changes how the library is presented.

8. **There is no stated review or approval flow for custom AEPs.** The campaign builder has a request-start model (requires approval before activation). Does a custom AEP require internal review before it can be used in campaigns? Or is creation and use immediate for org admins?

---

## Missing states

### System states
- AEP creation save fails (LLM validation error, network timeout, server error)
- Live simulator fails to start (model unavailable, quota exceeded, latency timeout)
- Simulator response takes >5 seconds — loading/typing indicator state
- Dune-seeded library fails to load (skeleton vs. empty state handling)
- AEP creation in progress — is there an autosave draft state?

### Permission states
- User is not an org admin but can view the AEP library — what is the read-only state of the builder?
- User is an org admin but their tenant hasn't been granted custom AEP access yet — is this a feature gate?
- Campaign manager can use AEPs in campaigns but cannot edit them — the card/list view must reflect this distinction

### Content states
- Zero custom AEPs created yet — first-time empty state for the "Custom" section
- Custom AEP limit reached (4 or 5) — create button behavior
- Zero Dune-seeded AEPs loaded — fallback if seeded library is empty (shouldn't happen but must be handled)
- AEP name collision — can two custom AEPs have the same name?
- Very long AEP name — truncation rules in the library card view
- Very long prompt (system instruction) — character limit, scroll behavior, or wrapping

### Action states
- Deleting a custom AEP that is currently used in an active campaign — block or warn?
- Deleting a custom AEP that was used in a completed campaign — historical reference integrity
- Editing a custom AEP that is mid-campaign — block or warn?
- Publishing a custom AEP (if there's a draft → published state)
- Duplicating a Dune-seeded AEP as the starting point for a custom one

### Responsive / Accessibility
- The prompt editor on smaller viewports — a full-screen text area may need special handling
- The live simulator (two-pane chat) will need a responsive layout decision
- Screen reader handling of the simulator — each message must be announced in order
- Keyboard navigation through AEP cards in the library grid

---

## Questions for PM / Eng

1. **[Both]** Is the AEP's behavior defined entirely by a system prompt, or are the structured sections (Workflow Steps, Branching Logic) independently authored fields that feed the LLM separately? The answer is the most fundamental architectural question for the builder UX.

2. **[PM]** Is "Adversary Method" a fixed taxonomy (list of types like Authority-Based, Urgency, Curiosity, Bribe, Reciprocity) or a free-form label? If fixed, what is the full list? Does the selection affect LLM behavior or is it purely display/categorization?

3. **[PM]** Are outcome criteria (Complicit, Non Complicit, Undetermined, No Response) universally defined by Dune, or does each AEP define its own criteria per outcome type? If per-AEP, do admins write these in the builder?

4. **[Eng]** In the live simulator: who plays the "target" role — the admin manually types responses, or a second AI model simulates a target employee? What infrastructure does this require, and does it run against the same model as production?

5. **[PM]** When the custom AEP limit is reached, what is the intended recovery path — delete an existing AEP, request a limit increase, or upgrade plan?

6. **[Both]** If a custom AEP is edited after being referenced in an active campaign, does the campaign use the locked version at the time of creation, or the live edited version? This needs an explicit policy before any versioning UI is designed.

7. **[PM]** Can an org admin duplicate a Dune-seeded AEP as a starting point for a custom one? This would significantly reduce authoring friction for admins unfamiliar with prompt engineering.

8. **[PM]** Is there a review or approval step before a custom AEP can be used in campaigns, or is it immediately available upon save?

9. **[Eng]** Is there a character limit or token limit on the AEP system prompt? This affects the editor UI (counter, truncation warning, submit guard).

---

## Design risks

**Prompt quality variance will be high.** Unlike a structured form, a free-text prompt gives admins creative control but produces wildly inconsistent AEP quality. An admin who doesn't understand prompt engineering may create an AEP that behaves unpredictably — escalating inappropriately, breaking persona, or failing to classify outcomes correctly. Risk: poor custom AEPs damage the reliability of the entire red team program. Mitigation: the live simulator must be prominent in the creation flow, not optional.

**The simulator is the only quality gate, but it's subjective.** There is no automated validation that an AEP prompt produces reliable, legal, or on-brand behavior. The simulator shows the admin one or two test conversations. A bad prompt may behave well in a test and fail in production. Risk: admin marks the AEP as good, it ships in a campaign, and produces a problematic conversation that requires HR intervention. Mitigation: consider a structured checklist or validation prompt that runs behind the scenes and surfaces warnings ("This AEP may escalate to profanity" / "This persona references company names — confirm this is intentional").

**Editing mid-campaign is a data integrity risk.** If the system does not version-lock AEPs at campaign creation, an edit during an active campaign changes the behavior of in-flight conversations. An employee who has been compliant might be re-evaluated differently. Risk: unfair or inconsistent outcome classification. Mitigation: version-lock at campaign creation; surface the locked version in the campaign detail.

**The custom limit (4–5) is very low.** If a company fills their limit with experimental or poorly-tested AEPs, they have no room for production-quality ones without deleting existing work. Risk: admins are reluctant to experiment because the limit feels permanent. Mitigation: drafts don't count toward the limit — only published AEPs do.

**Empty Dune library blocks the whole feature.** If Dune-seeded AEPs are not shipped simultaneously with the builder, the library launches empty. An empty AEP library means campaigns cannot be started. Risk: feature ships but is unusable. Mitigation: seed library is a hard dependency for launch; custom AEP builder is a layer on top.

---

## Teaching notes

**AEPs are live LLM system prompts, not scripts.** The branching logic shown in the screenshot is a description of emergent behavior, not a programmatic decision tree. When an admin writes an AEP, they're writing a system prompt that instructs the model how to behave — the "branching" is the model adapting to context, not a wired node graph. Designers should not introduce visual metaphors (node editors, flowcharts) that imply scripted branching. The interaction model is closer to writing a character brief for a conversational AI.

**The closest existing Dune reference for prompt-based configuration is the remediation agent instruction field.** Use that as a design system precedent for a large text editor in an admin form context. Stillsuit DS v2 may have a `TextArea` or `CodeEditor` component that fits.

**Outcome classification drives downstream analytics.** The Complicit / Non Complicit / Undetermined / No Response tabs in the AEP detail are not just labels — they define how the system classifies the outcome of each conversation in Conversation Management and feeds into employee risk scoring. Outcome criteria authored in the AEP builder directly affect risk score delta calculations. This is a high-stakes field, not a display preference.

**Adversary Method taxonomy is likely tied to attack vector classification.** In security awareness training, attack method taxonomies (Authority, Urgency, Scarcity, Reciprocity, Social Proof, Liking/Familiarity) come from influence science (Cialdini) and are used to categorize phishing and social engineering simulations. Dune likely uses this taxonomy for reporting ("your employees are most vulnerable to Authority-based attacks"). The Adversary Method field should be a controlled select, not a free-text field, so reports can aggregate across AEPs.

**The AEP library has two distinct card types: Dune-seeded (read-only) and Custom (editable).** The visual distinction between these must be clear in the library view — not just a label, but enough affordance that admins understand they can only edit custom ones. This is the same read-only/editable pattern used in Dune's SAT module catalog.
