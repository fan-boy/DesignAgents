# Open Questions — Red Team Platform
Last updated: 2026-05-13 · Updated after dev-handoff run — blocking questions labeled.

---

## Unresolved

### 🔴 Blocks build — must be answered before engineering starts

- [ ] [Eng] **[Blocks build]** Which LLM powers AEP conversations? Where is it hosted (Anthropic API, Azure OpenAI, on-prem)? What is the expected response latency (target: under 3 seconds per message)? How are prompt injections from employee replies detected and blocked? Must be confirmed before AEP chat infrastructure can be designed.

- [ ] [Eng] **[Blocks build]** Which LLM powers AEP conversations in the live campaign? Where is it hosted? What is the expected response latency SLA? How are prompt injections from employee replies detected? Must be confirmed before AEP campaign infrastructure can be designed.

- [ ] [PM] **[Blocks build]** What is the risk score delta for a complicity marking? Does it replace or augment the smishing click/submit graduated model? Must be confirmed before `red_team_complicit_marked` can be wired to the risk scoring system.

- [ ] [Both] **[Blocks build]** Red Team Approver RBAC: is this a new permission level in the Dune permission model, or a flag on an existing admin role? Must be confirmed before campaign wizard Step 6 and the approval flow can be built.

- [ ] [Eng] **[Blocks build]** Thread model for non-SMS channels: how are inbound employee replies associated with the correct campaign thread for WhatsApp, Viber, and Voice? Must be confirmed before conversation management can be built for any channel other than SMS.

- [ ] [PM] **[Blocks build]** SOC/IR lead PII access in conversation thread view: does the SOC/IR lead see full employee PII (name, department, message content), or is some PII redacted? Must be confirmed before RBAC implementation for thread detail.

- [ ] [PM] What is the operational definition of "complicit"? Is it auto-flagged by the system using keyword matching or NLP, manually flagged by a human operator monitoring live conversations, or a combination? (Design assumes: manually marked by admin with optional system-suggested flags.)

- [ ] [Both] Who is the approver for campaign start requests? Is this a new RBAC role (e.g., "Red Team Approver"), a designated second admin, or an automated compliance gate? What is the approval SLA, and what happens when no approver is available?

- [ ] [Eng] For hybrid channel attacks (e.g., SMS → Voice → WhatsApp), does Dune's platform orchestrate the channel transitions directly (initiate the call, send the WhatsApp message), or does the VEP guide a human operator who executes each step?

- [ ] [Both] How are employee replies threaded back to a campaign for Voice and WhatsApp channels? For SMS this is relatively clear (reply to a number = reply to a campaign). The threading model for other channels must be defined before conversation management can be designed.

- [ ] [PM] How does the "complicit" outcome map to risk scoring? Does it replace the smishing click/submit graduated model, augment it, or is it an entirely separate risk signal?

- [ ] [PM] Are VEPs authored by Dune only (library-only), by customers, or both? If customer-authored, what guardrails exist for harmful or out-of-policy conversation scripts?

- [ ] [PM] Is the Red Team platform a separate top-level nav section, or does it live under Simulations (e.g., Simulations → Red Team)? Navigation architecture must be settled before screen design begins.

- [ ] [Both] What does the "allowed sending days" constraint interact with in the approval flow? If a campaign is approved on Monday but is only allowed to run on Tuesday/Thursday, does it auto-start on the next allowed day?

- [ ] [PM] Can an employee's complicity marking be reversed once set? Who has permission to reverse it, and what is the audit trail requirement?

- [ ] [Eng] For the Voice channel node: does Dune initiate the call, play a scripted audio lure, and transcribe/record the response? Or is voice a human-executed step that the admin logs manually in the platform?

- [ ] [PM] What is the long-term relationship between the Red Team platform and the existing smishing simulation feature? Separate products, separate nav sections, or will smishing eventually be absorbed into Red Team?

- [ ] [Eng] What channel providers are confirmed and in what regions? WhatsApp Business API and Viber Business require separate registration and platform approval. Which customers will have access to which channels at launch?

- [ ] [PM] What is the minimum attack sequence length? Can a single-node attack (SMS only) be built in the attack library, or is the library exclusively for multi-channel sequences?

- [ ] [PM] When a campaign is force-cancelled while active (conversations in progress), what happens to open conversation threads? Are employees notified? Are partial conversations still reviewed for complicity?

- [ ] [Both] Is there a bulk action for complicity marking, or must each conversation be reviewed individually? At scale (50+ conversations), individual review creates a significant admin burden.

- [ ] [PM] Does the Red Team Dashboard aggregate data from both the red team campaigns AND the smishing simulation campaigns, or only from red team campaigns?

---

## Resolved

- [x] [PM] Is the Red Team platform a broader feature than the original smishing simulation? — **Answer:** Yes. The red team platform is a five-section expansion: Dashboard, AEP Library, Attack Library, Campaign section, and Conversation Management. The existing smishing simulation campaign flow is preserved and referenced as a predecessor. The campaign creation flow for red team is similar but adapted (request-start model, VEP selection, multi-channel attack selection). (Product owner input, 2026-05-13)

- [x] [PM] Does the campaign creation flow include scheduling constraints beyond start date and time? — **Answer:** Yes. Campaign config includes: Name, Start date, Allowed sending days (days of week), Start time, End time. This is more granular than the smishing wizard's single date/time/spread model. (Product owner input, 2026-05-13)

- [x] [PM] Is complicity marking an admin review step, not an automated system event? — **Answer:** Yes. Admin review is required. The system may flag conversations, but admin must explicitly mark as complicit or non-complicit. (Product owner input, 2026-05-13)

- [x] [PM] Is the node-based editor confirmed for the attack library? — **Answer:** Yes. The node-based editor is for the Attack Library (channel sequences). Scoped to linear sequences in v1. (Product owner input, 2026-05-13)

- [x] [PM] Is an AEP a linear script or a branching/adaptive system? — **Answer:** AEPs are AI-driven adaptive chatbots — they are inherently branching/dynamic. An AEP is defined by a scenario prompt (who the attacker is, what they want, how they escalate) and responds in real time to whatever the employee says. For example: a bribe-offer AEP escalates if the employee shows curiosity, tries a different angle if they resist. Admins create AEPs by writing a scenario prompt, testing in a live chat simulator, and iterating with refinement prompts. The "linear vs. branching" question is resolved — AEPs are adaptive by design, not linear scripts. (Product owner input, 2026-05-13)

- [x] [PM] Is customer AEP authoring self-serve at launch? — **Answer:** No. V1 ships with 2 Dune-seeded generic AEPs available to all tenants. Customer-authored AEPs are not self-serve — admins submit a request form and Dune fulfills them. The two-panel prompt builder is out of scope for v1. (Product owner input, 2026-05-14)

- [x] [PM] Content guardrails for admin-authored AEP prompts — **Answer:** Not applicable in v1. AEPs are Dune-managed content. Content guardrail design is deferred until self-serve authoring is in scope. (Product owner input, 2026-05-14)
