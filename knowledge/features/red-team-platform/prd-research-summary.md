# PRD Research — Red Team Platform
Dune Security · Feature Research · Last updated: 2026-05-13 · Refinement run — expanded from sms-phishing scope.

---

## Feature summary

The Red Team Platform extends Dune's simulation capability from passive phishing simulation (click-and-measure) to active multi-channel social engineering campaigns that mirror real adversarial tradecraft. Security admins configure campaigns using AEPs (Adversary Emulation Pathways — AI-driven adaptive conversation scenarios that behave like scenario-based chatbots) and multi-channel attack sequences built in a node-based editor. The platform surfaces live employee conversation threads and requires admins to classify responses as complicit or non-complicit. This is a substantially broader feature than smishing simulation: it spans five distinct product sections (Dashboard, AEP Library, Attack Library, Campaigns, Conversation Management) and introduces new design patterns not currently in the product.

**What an AEP is:** An AEP is an AI-powered conversational persona that conducts the social engineering interaction autonomously. Unlike a static script, an AEP adapts its responses in real time based on how the employee responds. For example: a "bribe offer" AEP initiates contact offering something of value in exchange for information. If the employee shows curiosity or engagement, the AEP escalates — probing for more sensitive details. If the employee is resistant or suspicious, the AEP may try a different angle or back off. The AEP is defined by a scenario prompt (the attacker persona, goal, and tactics) rather than a fixed script. Admins will eventually be able to create their own AEPs by writing a scenario prompt, testing the AEP in a simulated conversation, and iterating on the prompt until the AEP behaves as intended.

**Primary users:** Security admin / red team operator. Secondary: SOC/IR lead, compliance owner.

**Trigger:** Admin wants to test employee susceptibility to multi-step, multi-channel social engineering (not just one-shot SMS lures) and measure actual response behavior — including verbal/textual responses — not just clicks.

**Success:** Admin can select or build an AEP, compose a multi-channel attack sequence, target an audience, request a campaign, and review conversation outcomes — without needing engineering support for each new attack type or scenario.

**What is already designed:** The Red Team Dashboard screen (overview, recent attacks, insights) is confirmed as designed. Document its contract but do not redesign it.

---

## Gaps and ambiguities

1. **AEP data model and LLM architecture are unconfirmed.** AEPs are now understood to be AI-driven adaptive chatbots — scenario prompts that instruct an LLM to behave as a social engineering persona and respond dynamically to employee replies. The prompt-to-behavior model is confirmed at the product level, but the underlying LLM (which model, hosted where, prompt injection guardrails, response latency SLA) is not defined. This affects architecture, security posture, and conversation review design. The branching question is **resolved** — AEPs are inherently adaptive, not linear scripts.

2. **"Complicit" has no operational definition.** The platform surfaces conversations where an employee is flagged as complicit and requires admin review. But the criteria for complicity are undefined: Is complicity auto-detected by keyword or NLP? Does the system auto-flag and the admin confirms? Does a human operator flag manually? Is complicity binary (yes/no) or graduated? The answer directly controls what the conversation management UI must surface, what permissions are needed, and what the risk score impact should be.

3. **Who controls the node-based editor?** The attack library uses a node-based editor to build multi-channel sequences. It is unclear whether this is: (a) a power-user canvas for building new attack primitives, (b) a template-configuration surface for selecting pre-built channel sequences, or (c) a runtime orchestration tool. The complexity and RBAC implications differ significantly between these interpretations.

4. **"Request campaign start" approval flow is undefined.** The campaign section uses a "request start" model rather than an instant-launch. Who approves? Is it a second admin, a designated approver role, or an automated compliance gate? What is the approval SLA? What state does the campaign enter while pending? This is a new workflow not present in smishing or email phishing.

5. **Channel orchestration for hybrid attacks is undefined.** A hybrid attack (e.g., SMS → Voice → WhatsApp) implies the platform can initiate voice calls and WhatsApp messages in addition to SMS. Whether Dune handles the channel orchestration directly, or whether these are operator-executed steps guided by the VEP, is not stated. This affects both the technical architecture and the admin UI significantly.

6. **Conversation threading model is undefined.** For the conversation management section, it is unclear how Dune associates employee replies with specific campaign threads. For SMS this is relatively clear (reply to a number = reply to a campaign). For voice calls, WhatsApp, and Viber, the threading model is non-trivial.

7. **Risk scoring model for red team is undefined.** The smishing feature has a graduated risk model (click = moderate, submit = high, etc.). The red team platform introduces "complicit" as a new outcome signal. How complicity maps to risk score — and how it differs from or supersedes smishing click/submit signals — is not defined.

8. **VEP authoring is undefined.** Are VEPs authored by Dune (library-only), by customers, or both? This mirrors the template authoring question from smishing but with higher complexity given the conversational/branching nature of a VEP.

9. **Separation of red team from smishing simulation is unclear.** The existing smishing feature targets passive simulation (no expected reply). The red team platform targets active simulation (replies are expected and reviewed). Are these the same product section with new capabilities, or separate nav sections? Navigation architecture must be resolved before screens can be designed.

10. **The "days on which sending is allowed" constraint is new.** The campaign config includes allowed sending days in addition to start/end time. This is a scheduling granularity not present in the smishing wizard and may interact with the approval flow timing.

---

## Missing states

### System states
- Attack node fails mid-sequence (e.g., voice call leg fails; does the sequence continue on next channel or abort?)
- Campaign approved but start date has passed (activation grace window? auto-cancel?)
- Campaign in "pending approval" state with no active approvers (all approvers inactive or out of office)
- VEP script reaches a terminal node with no matching employee response (fallback behavior undefined)
- Hybrid channel unavailable at send time (e.g., WhatsApp delivery fails; fallback to SMS?)
- Node-based editor auto-save state (unsaved attack sequence; admin navigates away)
- Conversation thread with no employee reply (passive non-engagement — is this a data point?)
- Complicity flag auto-raised by system; admin has not yet reviewed (pending state visibility)
- Bulk complicity review (admin needs to mark 50+ conversations — no bulk action defined)
- Campaign ends with no conversations marked — zero-signal campaign (what does the summary show?)

### Permission states
- Admin with campaign creation rights but without "request start" permission (can build but not submit)
- Admin without red team access trying to access VEP or Attack Library
- View-only admin seeing conversation threads with PII (employee name, phone number, message content)
- Approver role: who can approve a campaign start request? Is this a new RBAC role?
- Complicity marking: is this a separate permission from campaign management?
- Audit access: can compliance officers view all complicit flags across campaigns without full admin access?

### Content states
- AEP library empty (no VEPs created or seeded) — campaign creation cannot proceed
- Attack library empty — no attack sequences available
- Node-based editor: attack sequence with no terminal node (incomplete attack — cannot be saved as active)
- Campaign with no matching VEP for the selected attack channel (VEP was built for SMS; attack is hybrid)
- Conversation thread with attachments or media (employee responds with an image — how is this handled?)
- Employee responds in a language other than English (VEP assumes English)
- Campaign has zero conversations (attack sent but no replies received — is this displayed differently from a compliant audience?)

### Action states
- Admin deletes an attack sequence used by a scheduled campaign
- Admin edits a VEP while a campaign using it is active (do live conversations re-script?)
- Admin revokes campaign start request (before approval)
- Approver rejects campaign start request — admin notified, campaign returns to draft
- Admin force-cancels an active campaign (conversations in progress — what happens?)
- Admin marks a conversation as complicit and then changes the marking (reversal workflow)
- Admin attempts to mark complicit on a conversation with insufficient content (only one exchange)
- Bulk campaign archive for compliance/legal hold

### Responsive / Accessibility
- Node-based editor on tablet — drag-and-drop is touch-heavy; keyboard navigation for a11y is non-trivial
- Conversation thread view on mobile — security admins may review conversations on mobile
- Complicity marking action on mobile — confirmation affordance must meet 44×44px touch targets
- VEP branching diagram — complex visual graph may not be accessible without a text-representation fallback

---

## Questions for PM / Eng

1. `[PM]` Is a VEP a branching decision tree or a linear script? Does it drive automated attacker responses, or is it a reference guide for a human operator?

2. `[PM]` What is the operational definition of "complicit"? Is it auto-flagged by the system (keyword, NLP), manually flagged by a human operator monitoring live conversations, or some combination?

3. `[Both]` Who is the "approver" for campaign start requests? Is this a new RBAC role, a designated second admin, or an automated compliance gate? What is the approval SLA and what happens when no approver is available?

4. `[Eng]` For hybrid channel attacks, does Dune's platform orchestrate the channel transitions directly (initiate the voice call, send the WhatsApp message), or does the VEP guide a human operator who executes the steps?

5. `[Both]` How are employee replies threaded back to a campaign? For SMS this is straightforward; for WhatsApp and Voice the threading model needs defining before conversation management can be designed.

6. `[PM]` How does the "complicit" outcome map to risk scoring? Does it replace or augment the smishing click/submit graduated model?

7. `[PM]` Are VEPs authored by Dune only (library), by customers, or both? If customer-authored, what is the guardrail for harmful or out-of-policy conversation scripts?

8. `[PM]` Is the Red Team platform a separate nav section from the existing Simulations → Smishing section, or does it expand Simulations? Navigation architecture must be settled before any screen design begins.

9. `[Both]` What does the "allowed sending days" constraint interact with? If a campaign is approved on Monday but only allowed to run on Tuesday/Thursday, does it auto-start on the next allowed day?

10. `[PM]` Can an employee's complicity marking be reversed once set? Who has permission to reverse it, and what is the audit trail requirement?

11. `[Eng]` For voice channel nodes: does Dune initiate the call, play a script, and transcribe the response? Or is voice a human-executed step that the admin logs manually?

12. `[PM]` What is the relationship between the Red Team platform and the existing smishing simulation? Are they separate products, separate sections, or the smishing section is eventually absorbed into Red Team?

---

## Design risks

**AEP prompt authoring is a novel admin skill.** Writing a good LLM scenario prompt requires understanding of prompt engineering — a skill most security admins do not have. The AEP builder must abstract this: the admin describes a scenario in plain English (e.g., "You are offering a bribe in exchange for login credentials"), and the system handles prompt structure. The iterative test-and-refine loop (chat simulator + prompt editor side-by-side) is the primary UX that makes AEP authoring accessible. Without a live preview of how the AEP actually behaves, admins cannot assess quality before deployment.

**Node-based editor scope creep.** Node-based editors are one of the highest-complexity UI patterns in enterprise software. Without tight scope constraints (e.g., limited to linear sequences in v1), the editor surface will consume disproportionate engineering and design effort. Recommend defining whether v1 supports only linear sequences (A → B → C) before designing the editor.

**"Complicit" as a legal/HR exposure.** Marking an employee as complicit — even in a simulation — has potential HR and legal implications. The UI must make it unambiguously clear that this is a simulation outcome, not an HR action. The label "complicit" itself may need review; softer alternatives ("responded to attack," "engaged with lure," "susceptible") reduce the risk of misuse.

**Approval workflow dead-end.** If the approver role is not clearly defined and an approver account is inactive, campaign start requests will sit in limbo indefinitely. The system must have an escalation path (notify alternate approver, auto-expire after SLA, allow requester to withdraw and re-submit).

**Conversation management at scale.** If a campaign targets 500 employees and 40% respond, there are 200 conversation threads to review. Without bulk actions and smart sorting (flag highest-risk conversations first), admins will not be able to complete the review. The conversation management UI must be designed for volume, not just individual thread review.

**Multi-channel channel availability gaps.** WhatsApp and Viber require business account registration and platform approval. If these channels are not operationally available for all customers (due to region, account setup, or platform policy), the attack library's node editor will allow admins to build attacks they cannot actually send. This must be gated by channel availability at the tenant level.

---

## Teaching notes

- **AEP is a scenario-based AI chatbot, not a script.** Unlike the smishing template (a static message), an AEP is a live conversational AI that decides its next message based on the employee's reply. The analogy is a customer support chatbot — except the "support goal" is social engineering. The AEP holds a persona (who it is), a goal (what it wants), and tactics (how it adapts). For example: persona = "IT contractor", goal = "obtain VPN credentials", tactics = "urgency, authority, reciprocity." The closest existing design precedent is the smishing template library browse/create/clone pattern, but the creation form is a prompt editor + live chat simulator, not a message editor.

- **AEP builder = prompt editor + chat simulator.** The admin AEP creation experience has two panels side by side: (1) a prompt/scenario editor where the admin writes and refines the scenario description and behavioral rules, and (2) a live chat simulator where the admin can play the role of the target employee and see how the AEP responds. The admin iterates: writes a prompt → tests it → adds refinement instructions ("be more persistent if the user hesitates") → tests again → marks as ready. This is the primary novel interaction in the product.

- **Node-based editors in the product context.** The node-based editor is for the Attack Library (channel sequences), not for AEP authoring. In Dune's context, keep the editor minimal: nodes represent channel steps, edges represent sequence order, and the canvas is read-only in campaign creation. The AEP and the attack are separate concerns — the AEP defines *what the AI says*, the attack defines *which channels it uses and in what order*.

- **Dune-seeded AEP library is essential for day-one usability.** If the AEP library is empty at tenant creation, campaign creation is immediately blocked. Dune must ship a library of pre-built AEPs covering common social engineering scenarios (bribe, urgency, authority impersonation, curiosity baiting, reciprocity). Admins can select these directly or clone and customize them using the prompt editor.

- **"Request start" campaign model.** The smishing wizard uses an instant-launch model (admin clicks "Launch Campaign" and the campaign starts). The red team platform uses a request-start model (admin submits a request; a second party approves; system activates on the scheduled date). This is a new workflow. The closest analogy in enterprise tools is a change request / CAB approval flow. The key design requirements: clear pending state, notification to approver, status visibility for requester, graceful rejection path.

- **Complicit vs. non-complicit marking.** This is a new outcome model, not present in any current Dune simulation feature. The smishing model is event-based (system records click/submit events automatically). The red team model is judgment-based (admin reviews a conversation and decides). This means the outcome data quality depends on admin attention and consistency — design for inter-rater clarity (what counts as complicit? what doesn't?) with inline guidance and examples at the point of marking.

- **Multi-channel risk inheritance from smishing.** The graduated risk model from smishing (knowledge/features/sms-phishing/prd-research.json) must be extended for red team outcomes. Complicity is likely a higher-severity signal than a smishing click. The risk scoring extension must be confirmed with PM before the campaign detail and reporting UI is designed.

- **Navigation architecture first.** The five sections (Dashboard, AEP Library, Attack Library, Campaigns, Conversation Management) need a nav home before any individual screen is designed. Whether this lives under "Simulations → Red Team" or as a top-level "Red Team" nav section affects everything downstream. Resolve this in the design-strategist skill run.
