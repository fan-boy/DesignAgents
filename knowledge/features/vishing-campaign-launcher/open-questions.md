# Open Questions — Vishing Campaign Launcher

## Unresolved

- [ ] [Both] Is VOIP execution AI-driven (automated bot places and conducts calls using the Voice AEP persona) or human-operated (Dune red teamers place calls manually using the script as a guide)? This is the highest-leverage question — it changes the AEP test-and-refine UX, campaign scale expectations, and how outcome events stream into the platform.
- [ ] [Eng] Does Dune's VOIP infrastructure support caller ID spoofing — displaying an arbitrary caller name and company on the recipient's caller ID? If not, what identity information is shown to call recipients? This determines whether "Caller Identity" fields are VOIP-level configuration or script briefing only, and affects all help text and Step 3 script preview copy.
- [ ] [PM] Where is "call recording consent on file" stored and verified in the platform? Is there a Compliance Settings document upload flow, or is this a per-campaign self-certification? Same question for the one-party/two-party consent jurisdiction check — is the platform verifying this or is the admin self-certifying?
- [ ] [PM] Is there a mechanism for Dune ops to request changes to a submitted campaign before activating it, or is ops' only option to activate or contact the admin outside the platform?
- [ ] [Eng] How are call outcomes classified — does the VOIP system emit semantic outcome events (target compromised, declined), or do Dune operators manually enter classifications in an internal ops panel after each call? What is the expected latency between a call completing and the classification appearing in the platform?
- [ ] [PM] Should campaign edits be allowed while in Pending Activation status? If yes, does editing reset the ops review queue? If no, what copy and UI treatment makes this limitation explicit to admins?
- [ ] [PM] Should the susceptibility rate denominator be Reached (targets who answered) or Total Targets? The current PRD uses Reached for vishing vs. Total Delivered for text campaigns — these are non-comparable. Is cross-channel rate comparability a goal?
- [ ] [PM] Is debrief entirely out-of-platform for v1? Should the post-campaign reporting view include debrief guidance, a disclosure message template, or any resources for admins managing the disclosure process?
- [ ] [Eng] When an admin pauses a vishing campaign, do in-progress calls (calls currently connected and ongoing) terminate immediately or complete naturally before the pause takes effect?
- [ ] [PM] Is the Voice AEP locked at campaign submission (Pending Activation status) or only at campaign activation (Calling status)? If locked at submission, can an admin modify the AEP between submission and activation?
- [ ] [PM] What is Dune's committed SLA for campaign activation after submission — "within one business day" is described in the confirmation copy but not confirmed as a product commitment.
- [ ] [Eng] What happens to a campaign in Calling status if VOIP infrastructure degrades mid-execution — is the campaign paused automatically, or do operators handle this manually outside the platform?

## Resolved

_(None yet — move items here with answers as PM/Eng respond.)_
