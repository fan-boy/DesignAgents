## Last updated
2026-07-08 — Resolved four open questions with the feature owner following prd-research critique: Copy an Email uses the same permission tier as Describe a Scenario (no separate gate), no mandatory attestation step is required before deploying an email-sourced template for v1, image-embedded sensitive data gets no special handling in v1 (redaction is text-based only), and manual edits are always preserved regardless of difficulty setting changes — difficulty only applies at generation or explicit regeneration, never as a live re-adjustment on an edited draft. See below and `open-questions.md`.

---

Dune's agentic generative-AI engine lets a security analyst or admin produce a high-fidelity phishing simulation template in two ways: by describing a scenario in free text, or by uploading a real email as a starting point. The engine analyzes the input and generates a template that preserves the original email type, tone, layout, and link structure, while replacing sensitive or organization-specific content with placeholders and converting every link to a safe simulation URL. Generated templates are editable in a drag-and-drop WYSIWYG editor, previewable on desktop and mobile, and gated by RBAC before they can be deployed into a campaign. This covers the Create Template flow (both creation modes), the Edit Template flow, and the Preview flow. It does not cover campaign scheduling or send targeting, which live in the campaign launcher.

**Create Template — Describe a Scenario**

The analyst starts a new template and chooses "Describe a Scenario" as the creation mode. This opens a short wizard.

| Step | Fields | Notes |
|---|---|---|
| 1 — Choose mode | Describe a Scenario / Copy an Email | Radio choice; determines the rest of the wizard |
| 2 — Describe the scenario | Free-text prompt (required, e.g. "Fake invoice from a vendor asking for urgent payment"); Phishing category (required, single-select: Fake Invoice, IT Audit, HR Update, Vendor Notice, Password Reset, Shipping Notice, Executive Request, Other) | Category seeds the generation even if the prompt is sparse |
| 3 — Set difficulty | Difficulty (required, single-select: Easy / Medium / Hard) | Agentic reasoning adjusts urgency language, visual polish, and pretext depth based on this setting; described further below |
| 4 — Generate | No fields; shows a generation-in-progress state | Target completion is approximately 10 seconds; see Edge Cases for timeout handling |

When generation completes, the analyst lands in the template editor with a fully drafted template: subject line, sender display name, body copy, layout (columns, images, buttons), and one or more CTAs pointing to Dune-safe simulation tracking URLs.

**Create Template — Copy an Email**

The analyst chooses "Copy an Email" as the creation mode instead.

| Step | Fields | Notes |
|---|---|---|
| 1 — Choose mode | Describe a Scenario / Copy an Email | Same entry point as above |
| 2 — Upload source | .eml file upload (required, drag-and-drop or browse); Screenshot upload (optional, only shown when screenshot-based generation is enabled for the workspace) | Uploaded content is sandboxed and sanitized before any analysis runs, and is isolated per workspace — see Edge Cases |
| 3 — Set difficulty | Difficulty (required, single-select: Easy / Medium / Hard) | Same control as the Describe a Scenario flow |
| 4 — Generate | No fields; shows a generation-in-progress state | The engine infers email type, tone, layout, and link structure from the uploaded source |

The generated template reproduces the structure of the source email while stripping anything organization-specific: real names, real domains, internal references, and account-specific details are replaced with placeholders, and every link in the original is rewritten to a safe simulation URL. The analyst never sees the raw uploaded content persisted outside this sanitized, workspace-isolated pipeline.

**Difficulty and agentic reasoning**

| Difficulty | Behaviour |
|---|---|
| Easy | Obvious tells preserved or introduced: visible spoofed sender mismatches, generic greetings, low urgency |
| Medium | Balanced realism: plausible sender, moderate urgency, fewer obvious tells |
| Hard | High-fidelity mimicry: convincing branding and tone, high urgency framing, minimal visual noise, deeper pretext |

Difficulty is applied at generation time. Once a draft exists, changing the difficulty setting does not touch the current draft or discard any manual edits the analyst has made. To get a different difficulty variant of an edited draft, the analyst uses an explicit **Regenerate** action, which is a deliberate, separate step from adjusting the difficulty control.

**Edit Template**

Every generated template opens in a drag-and-drop WYSIWYG editor. The analyst can rearrange layout blocks (columns, images, buttons), edit copy inline, adjust the sender display name and subject line, and swap or reposition the CTA. Placeholder tokens inserted during generation (for organization-specific data) remain editable but visually distinguished so the analyst knows what was auto-redacted. Edits are saved to the template draft and logged for auditability, consistent with generation actions.

**Preview Template**

The analyst can toggle between a desktop and mobile preview of the template at any point in the edit flow, before saving or deploying. Preview reflects the current draft state, including unsaved edits.

**RBAC and template lifecycle**

Access to templates is gated by role: view, edit, and deploy are distinct permissions. An analyst without deploy permission can create and edit a template but cannot push it into a campaign; that action requires an admin or a role explicitly granted deploy rights. Templates are scoped to the workspace they were created in.

Integration Points

| Integration | Description |
|---|---|
| Campaign Launcher | Saved templates are selected from the template library when configuring a simulation campaign; this feature produces the template, campaign launcher consumes it |
| RBAC / Permissions | Gates who can view, edit, or deploy a given template |
| Audit Log | Every AI generation call and every manual edit is timestamped and recorded for auditability |
| Risk Scoring Engine | Metadata captured during generation (category, difficulty, pretext type) is available as future input to adaptive-risk scoring; see open questions |
| Simulation Sending Infrastructure | All links in a generated template are rewritten to Dune-safe tracking URLs before the template can be deployed |

Edge Cases & System Behaviour

| Scenario | Behaviour |
|---|---|
| Uploaded file is not a valid .eml | Upload is rejected with an inline error; wizard does not advance |
| Uploaded .eml exceeds size limit | Upload is rejected with an inline error stating the limit |
| Uploaded .eml contains malformed or malicious content (e.g. embedded scripts, oversized attachments) | Sandboxed sanitization strips or rejects the file before any analysis runs |
| Screenshot upload attempted when the feature is disabled for the workspace | Screenshot upload control is not shown; only .eml upload is available |
| Generation exceeds the ~10 second target | Editor shows a continued-processing state; if generation fails outright, the analyst sees an error with an option to retry or edit the input and regenerate |
| Generation cannot fully identify or redact sensitive data | Draft is flagged for manual review before it can be saved or deployed, rather than silently saving an unredacted template |
| Analyst attempts to deploy without deploy permission | Deploy action is disabled with a tooltip explaining the required role |
| Analyst attempts to view a template outside their workspace | Access is denied; templates do not cross workspace boundaries |
| Duplicate template name within a workspace | Save is blocked with a validation message; analyst must rename |
| Difficulty changed after generation | Existing draft is re-adjusted in place rather than regenerated from the original input |
