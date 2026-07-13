# Design Strategy — AI Phishing Template Generator
Dune Security · Design Strategy · Last updated: 2026-07-13

---

## As-built reconciliation (2026-07-13)

The strategy below was written before the Figma rebuild and remains the record of the reasoning. Where the built storyboard departs from it, the build wins. Key reconciliations:

- **Creation surface is three tabs on one page, not a mode-chooser modal.** The build uses a single **Create New Asset** page with **Generate with AI**, **Create Manually**, and **Upload EML File** tabs (Screen 2's proposed modal was dropped). "Create Manually" is a third, non-AI mode not in the original strategy — a blank WYSIWYG "full control" path.
- **The library is the existing Simulated Attacks Library, not a new standalone Template Library.** Custom assets land under its **Custom Assets** tab, reusing its channel tabs (Email/SMS/Voice/Hybrid), Sender/Difficulty/Motive/Method filters, and search. This resolves the strategy's Open Issue about library reuse in favor of extending the existing surface. Empty and view-only states were added to it.
- **Product noun is "asset"** (Create New Asset, Custom Assets), and the setup uses a **Motive** selector (Authority, Urgency, …) plus quick **prompt chips**, rather than a single "phishing category" enum.
- **The persistent right-side refine panel (Screen 5) was not needed.** Difficulty + an explicit **Regenerate** button sit inline below the body editor; no drawer-vs-panel DS reconciliation was required (Open Issue 7 moot for v1).
- **Resolved and built:** difficulty as a pre-generation input, labeled Generating progress, desktop/mobile preview toggle, redaction/safe-link confirmation banner, Regenerate confirmation modal, Asset Detail with RBAC-gated deploy, Delete confirmation modal, and an **Add Phishing Link** three-state sub-flow (select text → configure popover with auto safe tracking URL → tracked-link token + confirmation). Add QR code exists in the toolbar as a sibling capability.
- **As-built screen inventory (18 frames):** three creation tabs (each with setup + post-generation edit variants), Generating progress, Mobile preview, Regenerate confirm modal, Library empty state, Library view-only state, Library row-actions menu (with Delete), Asset Detail (deploy-enabled), Asset Detail (RBAC-disabled), Delete confirm modal, plus the 3-state Add Phishing Link sub-flow. Delete is reachable from both the library row Actions menu and Asset Detail, sharing one confirmation modal.
- **Still open after the build:** raw-upload retention policy, whether Save yields an immediately deployable (Active) asset vs. a separate downstream deploy gate, motive/category taxonomy finalization, screenshot-mode P0/P1, multilingual, risk-scoring metadata, cross-tenant sharing, and placeholder-token syntax unification.

---

## Feature context

**Goal:** Let a security analyst or admin generate a high-fidelity phishing simulation template in roughly 10 seconds from either a free-text scenario description or an uploaded real email, without depending on a central content team.

**Primary user:** Security Analyst / Admin (template creator). **Secondary:** Admin or role with deploy permission (hands the finished template to the campaign launcher).

**Trigger:** Analyst starts a new template because they need a phishing simulation asset and don't want to wait on a content team.

**Success:** No stated success metric exists in the PRD today (flagged in prd-research as an open question for PM). Functionally, success is a saved template an analyst is willing to hand off to a campaign with minimal further edits, produced inside the ~10s generation target.

**What's confirmed (resolved 2026-07-08):**
- Copy an Email uses the same RBAC tier as Describe a Scenario — no separate permission gate for raw email upload
- No mandatory human attestation step before deploying an email-sourced template; RBAC deploy permission is sufficient
- Redaction is text-based only in v1 — sensitive content embedded in images is not detected, flagged, or stripped
- Manual WYSIWYG edits are always preserved; a difficulty setting change never touches an existing draft. Getting a different-difficulty variant requires an explicit, separate **Regenerate** action

**What's not yet confirmed:** raw upload retention/deletion policy, template library delete behavior and its effect on linked campaigns, whether the phishing category list is fixed or admin-configurable, screenshot-mode P0/P1 scope, multilingual output, risk-scoring metadata capture, and cross-tenant template sharing. See Open Issues.

---

## Design goal

Get an analyst from a scenario idea or a real email to a saved, editable phishing template in under a minute of hands-on time, using a one-shot generation model plus a persistent editor — not an iterative chat-style refinement loop — so the feature matches the PRD's ~10s generation scope without overbuilding.

---

## Key constraints

- **~10 second generation target.** The wait must be visibly progressing, not a static spinner — this is a trust-critical moment per Dune's Visibility of System Status heuristic, the same principle that shaped AEP Builder's labeled generation stages.
- **Manual edits are never silently discarded.** Difficulty changes alone must not touch the current draft. Only an explicit Regenerate action may replace draft content, and because that's destructive, it needs its own confirmation step.
- **No separate RBAC gate for Copy an Email.** Both creation modes share one permission; do not design a differentiated access-request flow for upload.
- **Redaction claims must be scoped honestly.** Since image-embedded sensitive data isn't handled in v1, any UI copy describing "sanitized" or "redacted" content should avoid implying full coverage (see competitor-analysis implication: this is also a trust-risk area, not just a copy nit).
- **Template library has no confirmed behavior beyond "save to it."** This strategy proposes a library modeled on the AEP Library (Dune's closest existing precedent for an AI-generated-artifact catalog) but delete/archive semantics remain open pending the linked-campaign question.
- **RBAC for view/edit/deploy must be handled explicitly**, per Dune's RBAC-gated-flow constraint: privileged actions get a `disabled` state with tooltip, and permission gaps surface at the start of a flow, not mid-task.

---

## Strategy options considered

### Option A: AEP-style persistent AI-refine panel (chat-style iterative refinement)
Borrow AEP Builder's Step 2 pattern directly: a persistent left panel with quick-action chips ("more urgent," "less obvious," "shorter"), a custom-instruction textarea, a change history, and an Apply-and-Regenerate loop, paired with a live preview on the right.

**Rejected for v1.** The PRD describes a single generation pass followed by direct WYSIWYG editing — not an iterative, natural-language refinement conversation. Building the full AEP-style refine panel is meaningfully heavier than the PRD's stated scope and risks scope creep on a feature whose entire value proposition is speed (~10s to a usable draft). This pattern is a strong candidate for the PRD's own "future extensibility" note, but not v1.

### Option B (Recommended): One-shot generation + direct WYSIWYG editor + explicit Regenerate
Capture mode-specific input and difficulty in a short setup step, generate once with a labeled progress sequence, then hand the analyst a single-panel WYSIWYG editor with desktop/mobile preview. Difficulty lives next to an explicit **Regenerate** control, decoupled from the live draft, so changing the difficulty selector alone never mutates existing work. Regenerating is a deliberate, confirmed, destructive action.

**Why this is right:**
- Matches the PRD's actual scope: two creation modes, one generation pass, manual editing, preview — no described iteration loop
- Respects the resolved decision that edits are never silently overwritten, by making regeneration opt-in and confirmed rather than automatic
- Reuses proven Dune conventions (AEP's labeled generation progress, disabled+tooltip RBAC gating, library table/empty-state pattern) instead of inventing new structure
- Keeps the feature buildable within a ~10s-generation, self-serve promise — Option A's iterative loop would work against that speed promise

---

## Recommended strategy

**One-shot generation, mode-first branch, single WYSIWYG editor with an explicit Regenerate control.**

The flow has four stages: **Library → New Template (mode + input) → Generate → Edit & Preview → Save**, converging into one shared editor regardless of creation mode.

---

## Wireframe plan

### 1. Template Library (entry point)
**Role:** Home surface for all template work; reached via left nav (placement TBD with IA — not yet mapped in existing nav).

- **Layout:** Full-page, table pattern with filter bar above.
- **Key components:** Table (Stillsuit DS v2 table pattern), filter bar, search input, empty state with CTA, badge (status).
- **Columns:** Template Name, Category, Difficulty, Creation Mode (Scenario / Email), Status (Draft / Ready / In Use), Last Modified, Actions.
- **Filter bar:** Category, Difficulty, Creation Mode, Status, date range — mirrors AEP Library's filter-bar shape.
- **Search:** Full-text across template name and category.
- **Primary action:** "New Template" (top right) — opens the mode chooser (Screen 2).
- **Row actions:** View / Edit, Duplicate, Delete (confirmation modal; exact downstream consequence for campaign-linked templates is an open issue — see below).
- **Empty state:** Illustration + "No templates yet" + two direct CTAs, "Describe a Scenario" and "Copy an Email" — reusing the AEP Library's dual-CTA empty-state convention instead of a single generic "New Template" CTA, since the mode choice is the very next decision anyway.
- **Permission state:** A view-only role sees the same table with no "New Template" button and row actions limited to View. Permission gaps show at this entry point, not mid-flow.

### 2. New Template — Choose Mode
**Role:** First decision point; branches the rest of setup.

- **Layout:** Modal (max 560px) or first wizard step — modal recommended since the choice is binary and doesn't need its own URL/back-state.
- **Key components:** Two large selectable cards (Describe a Scenario / Copy an Email), modal footer actions.
- **Primary action:** "Continue" (activates once a card is selected).
- **Secondary action:** Cancel.
- **System content:** Each card shows a one-line description of the mode. The "Copy an Email" card shows an "optional screenshot support" sub-note only when screenshot ingestion is enabled for the workspace (screenshot mode itself is still an open P0/P1 question — this UI slot should degrade gracefully to .eml-only when disabled).

### 3a. Setup — Describe a Scenario
**Role:** Mode-specific input capture.

- **Layout:** Full-page form (single screen; the PRD's "wizard" here is short enough not to need multi-step navigation).
- **Key components:** Textarea, select, segmented control (difficulty).
- **Fields:** Free-text scenario prompt (required, textarea), Phishing category (required, select — PRD's example list plus an escape hatch; whether the list is fixed or configurable is an open issue), Difficulty (required, segmented control Easy / Medium / Hard, default Medium).
- **Primary action:** "Generate Template."
- **Secondary actions:** Back (to mode choice), Cancel.
- **Edge case handling:** No stated minimum prompt length in the PRD — flagged as an open gap; recommend a soft minimum with inline helper text rather than a hard block, to avoid punishing short-but-valid prompts.

### 3b. Setup — Copy an Email
**Role:** Mode-specific input capture for the upload path.

- **Layout:** Full-page form, same shell as 3a.
- **Key components:** Drag-and-drop upload zone, optional secondary upload zone (screenshot), segmented control (difficulty).
- **Fields:** `.eml` upload (required, drag-and-drop + browse, single file, inline format/size validation), Screenshot upload (optional, shown only when workspace-enabled), Difficulty (same control as 3a).
- **Primary action:** "Generate Template."
- **Secondary actions:** Back, Cancel.
- **System content:** A short content-handling disclosure line under the upload zone (what happens to this file) — copy itself depends on the still-unresolved retention policy; reserve the UI slot now so it isn't bolted on later.
- **Edge case handling:** Invalid file type, oversized file, and malformed/malicious content all reject inline before advancing, per `edge-cases.md`.

### 4. Generating (progress state)
**Role:** Bridges setup and the editor; must visibly progress within the ~10s target.

- **Layout:** Full-page or inline overlay on top of the setup screen just submitted.
- **Key components:** Labeled progress sequence (reusing AEP Builder's advancing-stage pattern).
- **Stages:** "Analyzing input" → "Drafting template" → "Redacting sensitive data" → "Rewriting links to safe URLs" → "Ready" — named after the specific things the PRD says generation does, not generic "Processing…" copy.
- **On failure:** Inline error with a "Try again" action; all setup inputs preserved, matching the AEP generation-failure pattern.
- **On timeout past ~10s:** Continue showing the current labeled stage rather than reverting to a blank state; only surface an error if generation fails outright.

### 5. Edit & Preview
**Role:** The core working screen for every generated draft, regardless of creation mode.

- **Layout:** Full-page, two-region: main canvas (left/center) + persistent right-side utility panel. *Not* a chat-style iterative refine panel (see Option A rejection above).
- **Key components:** WYSIWYG canvas (drag-and-drop blocks: columns, images, buttons, text), persistent side panel (badge, segmented control, button — flag for DS review, see Open Issues), desktop/mobile preview toggle, badge (Draft status), modal (regenerate confirmation).
- **Header:** Inline-editable template name, status badge (Draft), desktop/mobile preview toggle, "Save" primary action (top right).
- **Main canvas:** Renders the drafted email; supports drag-and-drop block reordering, inline copy editing, and visually distinguishes auto-inserted placeholder tokens (e.g., a distinct token style) so the analyst knows what was redacted.
- **Right panel:** Current difficulty (segmented control, editable) + explicit **Regenerate** button, visually separated from the difficulty control so it reads as "change this and confirm" rather than "change this and it happens automatically."
- **Regenerate confirmation modal:** "Regenerating will discard your current edits and create a new draft. This can't be undone. Continue?" — Cancel / Regenerate (destructive, right-aligned per DS modal convention). This directly encodes the resolved decision that edits are never silently lost.
- **Secondary actions:** Discard draft (returns to library unsaved), Back to Setup (only before the first save — after any manual edit, treat this the same as Regenerate and confirm before discarding).
- **Permission state:** View-only role sees the same canvas rendered read-only (no drag handles, no inline editing), with Regenerate and Save hidden or disabled with a tooltip explaining the missing permission.
- **Responsive:** Preview toggle covers desktop/mobile rendering of the draft as specified in the PRD. Editing itself is treated as desktop-only for v1 (drag-and-drop WYSIWYG editing on a touch/mobile viewport is out of scope) — this is an assumption, not a confirmed requirement; flagged as an open issue below since the PRD doesn't state it explicitly.
- **Accessibility:** Drag-and-drop block reordering needs a keyboard-operable alternative (e.g., "Move up / Move down" affordances alongside drag handles) — flagged as a requirement to carry into Figma, not optional polish.

### 6. Save (inline, within Edit & Preview)
**Role:** Commits the draft to the library; not a separate full screen.

- **Trigger:** Clicking "Save" in the Edit & Preview header.
- **System content:** If the template name and category weren't already set in Setup, a lightweight inline naming/category-confirm step appears pre-filled from Setup inputs.
- **Edge case handling:** Duplicate template name within the workspace blocks save with an inline validation message; analyst must rename before proceeding.
- **Post-save:** Status badge changes from Draft to Ready; toast confirms save; analyst can continue editing or return to the library.

### 7. Template Detail
**Role:** Read/landing view reached from a library row, or immediately after first save.

- **Layout:** Full-page read view (mirrors AEP Detail's read-view convention) with an Edit entry point back into Screen 5 for Draft/Ready templates.
- **Key components:** Metadata panel (Created by, Last modified, Creation mode, Category, Difficulty), badge (status), primary action button, modal (delete confirmation).
- **Primary action:** "Use in Campaign" — hands the template to the Campaign Launcher (out of scope for this feature's own UI). RBAC-gated on deploy permission: disabled with a tooltip ("You don't have permission to deploy templates") when the viewer lacks deploy rights, mirroring AEP's Publish-button gating pattern.
- **Secondary action:** Delete — confirmation modal; exact behavior when the template is linked to a campaign is an open issue (see below), so the confirmation copy should be treated as provisional pending that answer.

---

## Risks and tradeoffs

**What this strategy gives up:**
- Iterative, conversational refinement (Option A) is explicitly deferred. If analysts want to nudge tone or urgency without a full regenerate, v1 forces a choice between manual WYSIWYG edits or a full destructive regenerate — there's no middle ground. This matches PRD scope but is worth flagging to PM as a likely v1.1 request given AEP Builder already validated the pattern's value for a related AI-generation feature.
- The library's status model (Draft / Ready / In Use) is a proposal, not confirmed — it will need revisiting once delete/archive behavior against linked campaigns is resolved.

**Risks that persist:**
- **Redaction-claim honesty.** Because image-embedded sensitive data isn't handled in v1, any "sanitized" or "redacted" language in the UI must be scoped precisely (e.g., "text content is automatically redacted" rather than an unqualified "sensitive data removed"). Getting this copy wrong recreates the trust risk flagged in prd-research and competitor-analysis.
- **Regenerate-vs-edit clarity.** Even with an explicit confirmation modal, analysts may not immediately understand why changing difficulty doesn't do anything on its own. The segmented control and Regenerate button need clear adjacent microcopy (not just spatial proximity) to avoid confusion — a candidate for a first-use tooltip or inline helper text.
- **Library assumptions may not survive the delete/retention decisions.** If eng decides raw uploads must be deleted immediately after generation, or that deleted templates must hard-block if campaign-linked, some library and Setup-screen copy will need to change.

---

## Open issues

1. **[Critical — Eng]** Where are raw `.eml` uploads and screenshots stored after generation, for how long, and are they excluded from logging/training pipelines? Affects the content-handling disclosure copy on Screen 3b.
2. **[Critical — PM]** Is there a delete flow for templates, and what happens on the campaign-launcher side if a linked template is deleted or edited? Affects Screen 1 row actions and Screen 7's delete confirmation copy.
3. **[Medium — PM]** Is the phishing category list a fixed enum or admin-configurable/extensible? Affects the Category field design on Screen 3a and the filter bar on Screen 1.
4. **[Medium — PM]** Should screenshot-based generation (OCR + layout reconstruction) be P0 or P1? Affects whether Screen 3b's screenshot upload zone ships at launch or is designed but flagged off.
5. **[Medium — Both]** Is drag-and-drop WYSIWYG editing genuinely desktop-only, or does mobile/tablet editing need to be supported? Assumed desktop-only for this strategy; not confirmed in the PRD.
6. **[Low — PM]** What are the feature's actual success metrics? Not currently defined; doesn't block wireframing but should be resolved before any post-launch design review.
7. **[Low — DS]** Does the persistent right-side panel on Screen 5 (difficulty + Regenerate) map to the standard drawer component, or does it need a non-dismissible variant flagged for DS review? AEP Builder's Step 2 used an equivalent persistent panel — confirm whether that was ever formally reconciled with the DS drawer spec.

---

## Next design actions

1. Confirm feature placement in navigation IA before wireframing the Library screen in Figma — this strategy assumes a dedicated library surface but doesn't have a confirmed nav location.
2. Resolve the DS drawer-vs-persistent-panel question (Open issue 7) before building Screen 5 in Figma, since it affects component selection.
3. Draft the content-handling disclosure copy for Screen 3b as a placeholder tied explicitly to Open issue 1, so it's swapped in cleanly once retention policy is confirmed rather than requiring a redesign.
4. Design the Regenerate confirmation modal and the Screen 5 difficulty/Regenerate microcopy together — this is the UI's main mechanism for encoding the resolved "never silently discard edits" decision and deserves the same care AEP gave its checkpoint-revert confirmation.
5. Bring Open issues 2–4 back to PM before finalizing the Library screen's row actions and filter bar, since each changes what's on that screen.
