# Open Questions — AI Phishing Template Generator

_Updated 2026-07-13 after the Figma rebuild. Product noun is "asset."_

## Unresolved
- [ ] [PM] Should screenshot-based generation (OCR + layout reconstruction) be P0 or P1? _(Built as an optional, workspace-gated upload zone — scope decision still needed.)_
- [ ] [PM] Should multilingual output be supported at launch?
- [ ] [Both] Which metadata should be captured to enhance adaptive-risk scoring? _(Build captures motive + difficulty + creation mode; confirm what feeds risk scoring.)_
- [ ] [PM] Should assets be shareable across tenants with governance review?
- [ ] [Eng] Where are raw .eml uploads and screenshots stored after generation, for how long, and are they excluded from logging or model-training pipelines given they may contain real PII?
- [ ] [PM] Does **Save** produce an immediately deployable (Active) asset, or is deploy a separate gated step downstream? _(Library rows show "Active"; Asset Detail shows "Ready" + a gated Use in Campaign — the model needs confirming.)_
- [ ] [PM] What happens on the campaign-launcher side when a linked asset is deleted or edited? _(Delete confirmation modal is built and warns of impact, but downstream behavior is unspecified.)_
- [ ] [Both] Is the taxonomy final — a **Motive** selector (Authority, Urgency, …) plus quick prompt chips (IT helpdesk, Finance, Custom) — and is it a fixed enum or admin-configurable/extensible?
- [ ] [PM] What are the feature's actual success metrics? _(None defined; doesn't block build but needed before post-launch review.)_
- [ ] [Design] Placeholder-token syntax is not unified across creation modes — worth a follow-up pass.
- [ ] [DS] A true destructive (red) button style is absent in this file's component set, so Regenerate and Delete reuse the primary style — confirm whether a destructive variant should be added.
- [ ] [Both] Add QR code exists in the toolbar as a sibling to Add Phishing Link, but its configure/confirm behavior is not yet specified.

## Resolved
- [x] [Both] Should Copy an Email require a distinct or higher permission tier than the AI mode? — **Answer:** No. Same permission tier; no separate gate for v1.
- [x] [PM] Should deploying an email-sourced asset require an explicit human attestation step beyond RBAC deploy permission? — **Answer:** No. RBAC deploy permission is sufficient for v1.
- [x] [Eng] Can sensitive-data redaction reach content embedded in images, and if not, what's the fallback? — **Answer:** No special handling in v1. Redaction is text-based only; images carry through as-is.
- [x] [PM] If an analyst edits a draft and then changes difficulty, are the edits preserved? — **Answer:** Always preserved. Difficulty never touches an existing draft; a different-difficulty variant requires an explicit, confirmed **Regenerate**.
- [x] [Design] Should this feature use a new standalone Template Library or the existing library? — **Answer (by build):** Extends the existing **Simulated Attacks Library** under a **Custom Assets** tab, reusing its filters, search, and channel tabs.
- [x] [Design] Is there a delete flow? — **Answer (by build):** Yes — a Delete confirmation modal on Asset Detail. (Downstream campaign-link behavior still open, above.)
- [x] [Design] Does the difficulty/Regenerate control need a persistent side panel reconciled against the DS drawer spec? — **Answer (by build):** No — difficulty + Regenerate sit inline below the body editor; no drawer needed.
- [x] [Design] Is there a third creation mode beyond describe-a-scenario and copy-an-email? — **Answer (by build):** Yes — **Create Manually**, a blank WYSIWYG "full control" path with no AI generation.
