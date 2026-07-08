# Open Questions — AI Phishing Template Generator

## Unresolved
- [ ] [PM] Should screenshot-based template generation (OCR + layout reconstruction) be P0 or P1?
- [ ] [PM] Should multilingual template output be supported at launch?
- [ ] [Both] Which metadata should be captured to enhance adaptive-risk scoring?
- [ ] [PM] Should templates be shareable across tenants with governance review?
- [ ] [Eng] Where are raw .eml uploads and screenshots stored after generation, for how long, and are they excluded from logging or model-training pipelines given they may contain real PII?
- [ ] [PM] If an analyst manually edits a draft and then changes the difficulty setting, does the agentic re-adjustment pass preserve, merge with, or overwrite those edits?
- [ ] [Both] Should Copy an Email require a distinct or higher permission tier than Describe a Scenario, given it ingests real third-party content rather than a text prompt?
- [ ] [PM] What are the actual success metrics for this feature — adoption, time saved versus the prior content-team workflow, or percentage of AI drafts deployed with no manual edits?
- [ ] [Eng] Can sensitive-data redaction reach content embedded in images, and if not, what's the fallback — strip inline images by default, or flag for mandatory manual review?
- [ ] [PM] Is there a delete flow for templates, and what happens on the campaign launcher side if a linked template is deleted or edited?
- [ ] [PM] Should deploying a template generated from a real uploaded email require an explicit human attestation step beyond generic RBAC deploy permission?
- [ ] [Eng] Is the phishing category list a fixed enum or admin-configurable/extensible with custom values?

## Resolved
