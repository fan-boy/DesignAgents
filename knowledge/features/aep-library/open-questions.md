# Open Questions — AEP Library (Custom AEP Builder)

## Unresolved

- [ ] [Both] Is AEP behavior defined by a single system prompt, or are Workflow Steps and Branching Logic independently authored fields that feed the LLM separately? *(Determines entire builder layout and authoring model)*
- [ ] [PM] Is "Adversary Method" a fixed taxonomy with a known list, or a free-form label? Does the selection affect LLM behavior or is it display/categorization only?
- [ ] [PM] Are outcome criteria (Complicit, Non Complicit, Undetermined, No Response) defined globally by Dune, authored per AEP in the builder, or generated from the prompt?
- [ ] [Eng] In the live simulator, does the admin manually play the target role, or does a second AI model simulate employee responses? What infrastructure does this require?
- [ ] [PM] When the custom AEP limit is reached, what is the intended recovery path — delete an existing AEP, request a limit increase, or prompt an upgrade?
- [ ] [Both] If a custom AEP is edited after being referenced in an active campaign, does the campaign use the version locked at creation time, or the live edited version?
- [ ] [PM] Can an org admin duplicate a Dune-seeded AEP as a starting point for a custom one?
- [ ] [PM] Is there a review or approval step before a custom AEP becomes available in the campaign builder, or is it immediately usable upon save?
- [ ] [Eng] Is there a character or token limit on the AEP system prompt field? What happens when the limit is exceeded?
- [ ] [PM] What is the exact custom AEP limit — 4 or 5? Is this configurable per tenant or fixed globally?
- [ ] [PM] Can a custom AEP be deleted if it was used in a completed (historical) campaign? What happens to the historical record?

## Resolved

*(No resolved questions yet — update this section as answers come in)*
