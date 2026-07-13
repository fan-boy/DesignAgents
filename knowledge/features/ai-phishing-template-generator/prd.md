## Last updated
2026-07-13 — Synced to the as-built rebuilt storyboard in Figma (page "DUNE 628 - Custom Creation of phishing Assets", section "AI Phishing Template Generator — Rebuilt Storyboard"). Material changes from the prior spec: the creation surface is a single **Create New Asset** page with **three tabs** (Generate with AI, Create Manually, Upload EML File) rather than a two-option mode chooser; the product labels the deliverable an **"asset,"** and it lives in the existing multi-channel **Simulated Attacks Library** under a **Custom Assets** tab (not a new standalone Template Library); the setup form uses a **Motive** selector (Authority, Urgency, etc.) plus quick **prompt chips** rather than a single "phishing category" enum; the WYSIWYG editor exposes in-body **Add Phishing Link** (with its own three-step sub-flow) and **Add QR code** tools; and the following are now designed and built: difficulty as a pre-generation input, a labeled **Generating** progress state, a desktop/mobile **preview toggle**, a redaction + safe-link **confirmation banner**, an explicit **Regenerate** action with a confirmation modal, an **Asset Detail** page with RBAC-gated deploy, a **Delete** confirmation modal, and library **empty** and **view-only** states.

2026-07-08 — Resolved four open questions with the feature owner following prd-research critique: Copy an Email uses the same permission tier as the AI mode (no separate gate), no mandatory attestation step is required before deploying an email-sourced asset for v1, image-embedded sensitive data gets no special handling in v1 (redaction is text-based only), and manual edits are always preserved regardless of difficulty setting changes — difficulty only applies at generation or explicit regeneration, never as a live re-adjustment on an edited draft. See `open-questions.md`.

---

Dune's agentic generative-AI engine lets a security analyst or admin produce a high-fidelity phishing simulation asset without depending on a central content team. The product surfaces this as **Create New Asset** under Simulated Attacks, with three creation tabs on a single page: **Generate with AI** (describe a scenario in a prompt), **Create Manually** (write the email from scratch in a WYSIWYG editor, no AI), and **Upload EML File** (start from a real email). For the two AI-assisted paths, the engine analyzes the input and produces a draft that preserves email type, tone, layout, and link structure, replaces sensitive or organization-specific content with placeholders, and converts every link to a safe simulation URL. Every draft is editable in the WYSIWYG editor, previewable on desktop and mobile, and gated by RBAC before it can be deployed into a campaign. Saved assets land in the existing **Simulated Attacks Library** under the **Custom Assets** tab. This covers the three creation flows, the shared Edit & Preview flow (including the Add Phishing Link sub-flow), preview, the asset library, and the Asset Detail page. It does not cover campaign scheduling or send targeting, which live in the campaign launcher.

**Naming note:** the product UI calls the deliverable an "asset" and the destination the "Simulated Attacks Library." This document uses "asset" for UI-accurate references; "template" and "asset" refer to the same object.

**Create New Asset — shared shell**

All three creation modes live on one **Create New Asset** page, chosen by a tab (not a modal). An info banner at the top frames the choice: "Generate with AI or write your own asset. AI is fast and effortless. Manual gives you full control." Each tab shows its mode-specific setup on the left and a live **Preview** panel on the right. Every mode shares a **Template Name** field (used to find the asset in the library later, distinct from the email subject line) and a **Difficulty** control positioned as a generation/authoring input, not a post-hoc label.

**Generate with AI**

| Field | Notes |
|---|---|
| Template Name | Required; the library-facing name, separate from the email Subject |
| Prompt to generate email | Free-text prompt plus quick **prompt chips** (e.g. IT helpdesk, Finance, Custom) that seed a starting prompt |
| Select motive | Social-engineering lever the simulation leans on (Authority, Urgency, etc.) — matches the Library's Motive column |
| Sender email / Sender Name | The address the simulation sends from and the display name recipients see |
| Difficulty (Easy / Medium / Hard) | Positioned above **Generate Asset** as a real generation input; default Medium; agentic reasoning adjusts urgency, visual polish, and pretext depth (see Difficulty section) |
| Generate Asset | Triggers the Generating progress state, then reveals the drafted asset in the editor |

When generation completes, the analyst is in the editor with a fully drafted asset: subject line, sender display name, body copy, layout (columns, images, buttons), and one or more CTAs pointing to Dune-safe simulation tracking URLs.

**Create Manually**

The analyst writes the email themselves with no AI generation. The body canvas starts genuinely blank ("Start writing your email, or drag in a block from the toolbar above"), and Sender Name / Subject start empty. Fields: Template Name, Sender email, Sender Name, Subject, Body (the same WYSIWYG editor and toolbar as the other modes, including Add Phishing Link and Add QR code), and Difficulty. The primary action is **Save Asset**. This mode is the "full control" path referenced in the intro banner.

**Upload EML File**

| Field | Notes |
|---|---|
| Template Name | Required, as above |
| Upload EML File | Required; drag-and-drop or browse, single `.eml`. Content is sandboxed, scanned, and isolated per workspace before any analysis runs |
| Screenshot (optional) | Second upload zone, shown only when screenshot-based generation is enabled for the workspace |
| Difficulty (Easy / Medium / Hard) | Same control and placement as the AI mode |
| Content-handling disclosure | A line under the upload zone: "Uploaded files are sandboxed, scanned, and isolated to your workspace" |
| Upload | Triggers generation |

The generated asset reproduces the structure of the source email while stripping anything organization-specific: real names, real domains, internal references, and account-specific details are replaced with placeholders, and every link in the original is rewritten to a safe simulation URL. In the editor, the uploaded email renders as a fully formatted email in the body canvas — never as raw HTML source.

**Generating (progress state)**

After Generate/Upload, a labeled progress sequence advances through named stages rather than showing a static spinner: **Analyzing input → Drafting template → Redacting sensitive data → Rewriting links to safe URLs → Ready.** Target completion is approximately 10 seconds. On outright failure the analyst sees an inline error with a retry option and all setup inputs preserved; if generation runs past ~10s the current labeled stage keeps showing rather than reverting to a blank state.

**Difficulty and agentic reasoning**

| Difficulty | Behaviour |
|---|---|
| Easy | Obvious tells preserved or introduced: visible spoofed sender mismatches, generic greetings, low urgency |
| Medium | Balanced realism: plausible sender, moderate urgency, fewer obvious tells |
| Hard | High-fidelity mimicry: convincing branding and tone, high urgency framing, minimal visual noise, deeper pretext |

Difficulty is applied at generation time. Once a draft exists, changing the difficulty setting does not touch the current draft or discard any manual edits. To get a different-difficulty variant of an edited draft, the analyst uses an explicit **Regenerate** action next to the difficulty control — a deliberate, separate step that always shows a confirmation modal ("Regenerating will discard your current edits and create a new draft. This can't be undone.") before replacing the draft.

**Edit & Preview**

Every draft opens in a drag-and-drop WYSIWYG editor. The analyst can rearrange layout blocks (columns, images, buttons), edit copy inline, adjust the sender display name and subject line, and swap or reposition the CTA. Placeholder tokens inserted during generation remain editable but are visually distinguished so the analyst knows what was auto-redacted. Above the Preview panel, a **redaction and safe-link confirmation** reads "Sensitive data redacted · Links converted to safe simulation URLs," making the safety transformation visible rather than implicit. The Preview panel has a **Desktop / Mobile toggle** so the analyst can check both renderings. Edits are saved to the draft and logged for auditability, consistent with generation actions.

**In-body authoring: phishing links and QR codes**

The editor toolbar includes **Add Phishing Link** and **Add QR code** for embedding the actual attack vector directly while editing. Adding a phishing link is a three-step in-editor sub-flow:

| Step | Behaviour |
|---|---|
| 1 — Select text | The analyst selects the display text in the body (e.g. "Verify My Account"); the *Add Phishing Link* toolbar control is the next action |
| 2 — Configure | An anchored popover opens with: **Link text** (pre-filled from the selection), **Landing destination** (what the simulation points at, e.g. a Dune landing page), and a read-only **Tracked simulation URL** shown with the note "Automatically rewritten. Recipients never reach a real site." Actions: Cancel / Insert link |
| 3 — Inserted | The link is inserted as a visually distinct **tracked-link token** with a "Tracked link" badge, and a confirmation appears: "Phishing link added — routed through a safe simulation URL" |

This makes the safe-URL conversion visible at the exact moment a link is created, and keeps the analyst in the email context rather than navigating away.

**Preview**

The analyst can toggle between desktop and mobile preview of the asset at any point in the edit flow, before saving or deploying. Preview reflects the current draft state, including unsaved edits. The mobile preview renders the email at a narrower viewport with wrapped content.

**Asset library, detail, and lifecycle**

Saved assets appear in the existing **Simulated Attacks Library** under the **Custom Assets** tab, alongside the library's channel tabs (Email / SMS / Voice / Hybrid) and its filter bar (Sender, Difficulty, Motive, Method) and search. Each row shows Preview, Title, Sender, Difficulty, Motive, Method, Vector, Status, and Actions. Entry to creation is the **Create New Asset** button; a **Request New Asset** secondary action exists for roles without create permission.

- **Empty state:** when no custom assets exist, the table is replaced by "No templates yet" with two direct CTAs, **Describe a Scenario** and **Copy an Email**.
- **Row actions:** each library row has an Actions menu (View details, Duplicate, **Delete**). Delete is a destructive item that opens the shared Delete confirmation modal, so an analyst can delete an asset directly from the list without opening its detail page.
- **View-only state:** a role without create permission sees the library with no Create New Asset action and an explicit "View-only access" indicator; row actions are limited to viewing (no Delete).
- **Asset Detail:** a read view showing metadata (Created by, Last modified, Creation mode, Motive, Difficulty) and a status badge (Draft / Ready). Primary action **Use in Campaign** hands the asset to the Campaign Launcher and is RBAC-gated on deploy permission — disabled with the tooltip "You don't have permission to deploy templates" when the viewer lacks deploy rights. Secondary action **Delete** opens a confirmation modal ("Delete this template? This can't be undone. If this template is linked to a campaign, deleting it may affect that campaign."). The same Delete action and confirmation modal are also reachable from the library row Actions menu.

**RBAC and asset lifecycle**

Access is gated by role: view, edit/create, and deploy are distinct permissions. A role without deploy permission can create and edit an asset but cannot push it into a campaign; a role without create permission sees the view-only library. Assets are scoped to the workspace they were created in. Whether "Save" produces an immediately deployable (Active) asset or whether deploy is a separate gated step downstream remains an open product question (see `open-questions.md`).

Integration Points

| Integration | Description |
|---|---|
| Campaign Launcher | Saved assets are selected from the Simulated Attacks Library when configuring a simulation campaign; this feature produces the asset, campaign launcher consumes it |
| Simulated Attacks Library | Custom assets land under the Custom Assets tab of the existing multi-channel library, reusing its filters, search, and row actions |
| RBAC / Permissions | Gates who can view, create/edit, or deploy a given asset |
| Audit Log | Every AI generation call and every manual edit is timestamped and recorded for auditability |
| Risk Scoring Engine | Metadata captured during creation (motive, difficulty, pretext type) is available as future input to adaptive-risk scoring; see open questions |
| Simulation Sending Infrastructure | All links in an asset are rewritten to Dune-safe tracking URLs before the asset can be deployed |

Edge Cases & System Behaviour

| Scenario | Behaviour |
|---|---|
| Uploaded file is not a valid .eml | Upload is rejected with an inline error; the flow does not advance |
| Uploaded .eml exceeds size limit | Upload is rejected with an inline error stating the limit |
| Uploaded .eml contains malformed or malicious content | Sandboxed sanitization strips or rejects the file before any analysis runs |
| Screenshot upload attempted when the feature is disabled for the workspace | Screenshot upload zone is not shown; only .eml upload is available |
| Generation exceeds the ~10 second target | The Generating screen keeps showing the current labeled stage; only an outright failure surfaces an error with retry |
| Generation cannot fully identify or redact sensitive data | Draft is flagged for review before it can be saved or deployed, rather than silently saving unredacted content |
| Create Manually saved with an empty body | Save is blocked or warned; the body starts blank by design and needs content before it is a usable asset |
| Add Phishing Link confirmed with no landing destination chosen | Insert is blocked until a destination is selected; the tracked URL is only generated once a destination exists |
| Analyst attempts to deploy without deploy permission | Use in Campaign is disabled with a tooltip explaining the required role |
| Role without create permission opens the library | Sees a view-only library with no Create New Asset action and a "View-only access" indicator |
| Analyst attempts to view an asset outside their workspace | Access is denied; assets do not cross workspace boundaries |
| Duplicate asset name within a workspace | Save is blocked with a validation message; analyst must rename |
| Difficulty changed after generation | No effect on the current draft; edits are preserved. A different difficulty requires the explicit, confirmed Regenerate action |
| Delete an asset linked to a campaign | Confirmation modal warns that deleting may affect the linked campaign; exact downstream behavior is an open question |
