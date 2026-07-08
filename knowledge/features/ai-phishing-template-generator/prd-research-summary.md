### Feature summary
Security analysts and admins generate a phishing simulation template by describing a scenario in free text or uploading a real `.eml` (optionally a screenshot), and Dune's generative-AI engine returns a drafted template preserving tone, layout, and link structure within roughly 10 seconds. Sensitive data is redacted to placeholders, links are rewritten to safe simulation URLs, and the draft is editable in a WYSIWYG editor, previewable on desktop and mobile, and gated by RBAC before deployment into a campaign. **Missing from the PRD:** any stated success metric (the ~10s figure is a performance constraint, not an adoption or quality metric), and any description of the template library itself beyond "save to it."

### Gaps and ambiguities
1. **Redaction cannot reach content baked into images.** The PRD promises sensitive/org-specific data is "automatically replaced with placeholders," but a real logo, address, or signature block embedded as an image in an uploaded `.eml` or screenshot is pixel content, not text — text-based redaction can't touch it. This is a real risk with the "Copy an Email" mode specifically. `[Eng]`
2. **Difficulty changes after manual edits are unaddressed.** The PRD states difficulty can be changed post-generation and "re-runs the agentic adjustment pass on the existing draft." It doesn't say what happens if the analyst has since made manual WYSIWYG edits — are those edits preserved, merged, or silently overwritten? `[PM]`
3. **No data retention or handling disclosure for uploaded raw email content.** "Copy an Email" ingests real third-party email content, which may contain real PII (customer or employee names, account details, internal correspondence). The PRD says uploads are "sandboxed, sanitized, and isolated per workspace" but says nothing about retention period, deletion after generation, or whether raw uploads are excluded from any downstream logging/training pipeline. `[Eng]`
4. **Template library has no defined behavior.** The PRD references saving to "the template library" as the terminal step of both creation flows, but defines no list view, search, filter, sort, or delete behavior. This will be discovered late in estimation if not scoped now. `[PM]`
5. **No mandatory review gate for real-email-sourced templates.** Because "Copy an Email" can turn a real, possibly sensitive email into a live simulation asset, there's no described checkpoint (beyond generic RBAC) confirming a human reviewed the redaction before deploy. `[PM]`
6. **Phishing category list origin is unclear.** The PRD names example categories (fake invoice, IT audit, HR update, vendor notice) but doesn't say whether this list is fixed, admin-configurable, or extensible with custom values. `[PM]`
7. **Versioning/audit granularity is unclear.** "All AI generation and edit actions are logged for auditability" describes logging, not recoverability — it's not stated whether an analyst can view or revert to a prior draft version, which matters if a difficulty change or edit destroys prior work (see #2). `[Both]`

### Missing states
**System states**
- Generation fails outright, distinct from exceeding the ~10s target (model error, service unavailable)
- Sanitization step rejects or strips part of an upload — what does the analyst see, if anything?
- Template library loading and empty-library states (no templates created yet)

**Permission states**
- View-only role opening a template in the editor (read-only rendering, no drag/edit affordances)
- Role that can create/edit but lacks deploy permission — is "Copy an Email" itself gated separately from "Describe a Scenario," given it's a higher-risk data-ingestion path?
- Cross-workspace access attempt on a template ID

**Content states**
- Very sparse or single-word scenario prompt — is there a minimum input length, or does the model just produce a low-confidence guess?
- Plaintext-only `.eml` with no layout to preserve — what does "preserve layout" mean when there isn't one?
- Duplicate template name within a workspace
- Template library at scale (tens or hundreds of drafts) with no described search/filter

**Action states**
- Regenerate vs. manual edit — is there an explicit "regenerate" action separate from adjusting difficulty, and does either warn before overwriting current edits?
- Delete a template — no delete flow is described anywhere in the PRD
- Bulk actions on the template library (not necessarily in scope, but worth confirming explicitly rather than by omission)

**Responsive / Accessibility**
- Preview is explicitly desktop + mobile, but editing (drag-and-drop WYSIWYG) is not addressed for mobile/tablet — confirm editing is desktop-only
- Drag-and-drop block reordering needs a keyboard-operable alternative; not addressed

### Questions for PM / Eng
1. `[Eng]` Where are raw `.eml` uploads and screenshots stored after generation, for how long, and are they excluded from logging or model-training pipelines given they may contain real PII?
2. `[PM]` If an analyst manually edits a draft and then changes the difficulty setting, does the agentic re-adjustment pass preserve those edits, merge with them, or overwrite them?
3. `[Both]` Should "Copy an Email" require a distinct or higher permission tier than "Describe a Scenario," given it involves ingesting real, potentially sensitive third-party content rather than a text prompt?
4. `[PM]` What are the actual success metrics for this feature — adoption rate, time saved versus the prior content-team workflow, or percentage of AI drafts deployed with no manual edits? None are currently defined.
5. `[Eng]` Can sensitive-data redaction reach content embedded in images (a logo, a signature block, an address baked into a graphic)? If not, what's the fallback — strip all inline images from uploaded sources by default, or flag them for mandatory manual review?
6. `[PM]` Is there a delete flow for templates, and if a template already linked to a campaign is deleted or edited, what happens on the campaign launcher side?
7. `[PM]` Should deploying a template generated from a real uploaded email require an explicit human attestation step, beyond generic RBAC deploy permission, given the legal/HR sensitivity of that source material?
8. `[Eng]` Is the phishing category list a fixed enum or admin-configurable/extensible with custom values?

### Design risks
- **Silent edit loss on difficulty change.** If the agentic re-adjustment pass runs on top of a draft without regard to manual edits, an analyst who spent time polishing copy loses that work the moment they toggle difficulty to preview a harder variant, with no stated undo path. This directly violates the "user control and freedom" principle around wizard/edit flows losing data.
- **Redaction blind spot on embedded images.** A "sanitized" template can still carry a legible real logo, address, or signature baked into an image pulled from the source `.eml` or screenshot, because text redaction doesn't operate on pixels. This undermines the entire "sensitive data replaced with placeholders" claim for image-bearing sources.
- **Unscoped raw-content ingestion.** Any analyst permitted to use "Copy an Email" can upload arbitrary real correspondence, including third-party PII, with no stated retention limit or review gate. This creates a compliance liability that is distinct from — and arguably larger than — the phishing-simulation product itself, since Dune would be voluntarily ingesting and storing sensitive customer/employee data as "template source material."
- **Underspecified library at scale.** Templates save into "the template library" with no described list, search, filter, or delete behavior. Left unscoped, this either balloons scope late in eng estimation or ships as an unusable flat list the moment a workspace has more than a handful of drafts.

### Teaching notes
- **Closest existing precedent: `knowledge/features/aep-library/`.** The AEP Builder is functionally the nearest analog already shipped at Dune — it's an AI-generated artifact (an adversary persona, not a template) created through a guided setup step, then refined in a **Test & Refine** step before publishing, backed by an **AEP Library** management surface with a filterable table (status, channel, date range), full-text search, row actions (View, Clone, Archive), an empty state with dual CTAs, and a Draft → Pending Review → Active → Archived status flow. Model the phishing template library on this pattern directly rather than inventing a new one — reuse the status flow, the filter/search bar, and the empty-state convention.
- **Apply the "errors inform, don't punish" principle** (`knowledge/product-principles/principles.md`) to generation failures and sanitization rejections: an analyst whose `.eml` gets stripped or rejected needs to know specifically what was flagged and why, not a generic upload error.
- **Trust & Safety principle applies directly here**: "the product's credibility depends on behaving exactly as it claims" — since this feature explicitly claims to redact sensitive data and produce safe links, any gap between that claim and actual behavior (e.g., the image-redaction blind spot above) is a trust failure, not just a bug, and should be scoped or disclosed rather than silently shipped.
- **Visibility of system status** (`knowledge/heuristics.md` #1) applies to the ~10s generation window and to sanitization — show a progress state, not a blank wait, and never leave the analyst wondering whether an upload passed sanitization silently or is still being checked.
- Review `knowledge/features/aep-library/prd.md` in full before design-strategist starts on the library surface for this feature — it already has field-level detail (columns, filter bar, empty state copy pattern) that can be adapted rather than redesigned from scratch.
