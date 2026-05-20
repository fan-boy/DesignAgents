# Open Questions — AEP Builder + AEP Library

## Unresolved

- [ ] [PM] Is there a scenario where a Dune operator must approve an AEP before it goes live? Or is the optional Reviewer role + the validation layer sufficient for all standard cases? *(Affects whether a mandatory blocking review gate is needed and what the Pending Review state looks like)*
- [ ] [Both] Does one AEP support simultaneous deployment across multiple channels in one campaign, or is it one channel per campaign per deployment? *(Affects channel display in library, data model, and deployment infrastructure)*
- [ ] [PM] Is the AEP library scoped per customer organization (all programs share one library) or per account/program (e.g., Concentrix's Meta program and United Airlines program have separate libraries)? *(Affects filtering, search scope, and counter display)*
- [ ] [Eng] Does Stage 2 use the full production LLM or a lighter model? What is the cost-per-test-session assumption and is there a guardrail on excessive testing? *(Affects whether unlimited sessions are viable and how they should be positioned)*
- [ ] [Both] Can a single refinement prompt cascade changes across dependent field groups (e.g., changing the opening message should also update the 1_INITIAL state script)? *(Critical for diff view design — must show all affected fields)*
- [ ] [PM] Is the instigation threshold (none / soft_stop / hard_stop) sufficient, or do we need a richer configuration model given the variation across AT&T (hard stop), BUZZ (assess, don't overcome), and Qantas (continue on curiosity)? *(Affects both Stage 1 form design and help text)*
- [ ] [PM] Is there a hard limit on the number of Active AEPs per tenant, or is archiving the management mechanism? *(If a limit exists, the library needs a counter and a disabled New AEP state)*
- [ ] [PM] What is the Reviewer notification surface? Email, in-platform notification, or both? And what does the Reviewer's approval UI look like (list of pending approvals? Direct link to AEP detail)?
- [ ] [Eng] What is the auto-save behavior for Stage 1 form data? Can customers close the browser mid-form and resume where they left off?

## Resolved

- [x] [Both] Is AEP behavior defined by a single system prompt, or are Workflow Steps and Branching Logic independently authored fields? — **Answer:** AEP content (system prompt, classifier prompt, state machine, scripts, detection arrays) is entirely AI-generated from the Stage 1 form + examples. Customers do not author JSON or raw prompts. They configure via structured form fields and refine via natural-language prompts (Stage 3). *(PRD v0.2, Sections 6.1 and 7)*
- [x] [PM] Are Outcome Criteria defined globally by Dune or authored per AEP? — **Answer:** Authored per AEP. The Stage 1 Termination Logic section captures compliant/continuation/impact definitions per AEP. These feed directly into the `terminationLogic` field of the AEP data model. *(PRD v0.2, Section 6.1 Stage 1 and Section 7)*
- [x] [Eng] In the simulator, does the customer play the employee role manually or is it AI-vs-AI? — **Answer:** Customer plays the employee (game changer) role manually in Stage 2 Live Chat Test. The customer types responses as if they were the targeted employee. There is no AI-vs-AI mode in Phase 1. *(PRD v0.2, Section 6.1 Stage 2)*
- [x] [Both] What is the recommended builder UX pattern — guided generation vs. hybrid vs. raw prompt? — **Answer:** Confirmed as structured 6-section intake form + optional example upload → AI generation. Customers never write a raw prompt. Stage 3 allows natural-language refinement prompts that make targeted field-level edits. Raw JSON is visible only to Dune Operators. *(PRD v0.2, Section 6.1)*
- [x] [PM] Is duplication from Dune-seeded AEPs a confirmed supported path? — **Answer:** Yes, confirmed as "Start from Template" flow. Dune-curated templates pre-fill Stage 1; customer updates values and regenerates. Template lineage tracked in metadata. *(PRD v0.2, Section 6.3)*
- [x] [Both] Version-locking policy — are AEPs locked at campaign creation? — **Answer:** Yes. Published AEPs are immutable (REQ-SS-12). Campaigns are locked to the AEP version at creation. Changes require cloning to a new version. *(PRD v0.2, Sections 6.1 and 9.2)*
- [x] [PM] What RBAC roles are needed? — **Answer:** Four roles: Security Manager (creates, tests, publishes), Reviewer (read-only + approve), Dune Operator (full access including raw JSON and validation override), Dune Admin (all Operator + global template/ban list management). *(PRD v0.2, Section 5)*
