# Design Review — AI Phishing Template Generator (existing Figma design, ~6 months old)
Dune Security · Design Review · 2026-07-09

## Rebuild update — 2026-07-09
All 10 findings below (DR-01 through DR-10) have been addressed in a rebuilt storyboard, on the same Figma page, in a new section named **"AI Phishing Template Generator — Rebuilt Storyboard (2026-07-09)"** positioned below the original (untouched) content for direct comparison. The storyboard covers 14 screens: the 6 original screens fixed in place (Generate with AI setup + edit, Upload EML setup + edit, Create Manually, Library happy path) plus 8 new screens/states built to close state-coverage gaps (Generating progress, Regenerate confirm modal, Mobile preview variant, Library empty state, Library view-only/RBAC state, Template Detail with deploy enabled, Template Detail with deploy disabled/RBAC, Delete confirm modal).

Each finding below now has an **Outcome** and **Resolution** line. Two open questions from the original review remain genuine product decisions, not design gaps — see Open Questions. **Revised verdict: ready for handoff**, pending those two product decisions and a small residual polish list (placeholder token syntax unification; a true destructive button style doesn't exist in this file's component set, so Regenerate/Delete reuse the primary green style).

**Follow-on 2026-07-13 — Add Phishing Link sub-flow added.** A three-state in-editor sub-flow was built as a labeled row below the storyboard: (1) select display text with the *Add Phishing Link* toolbar action highlighted, (2) an anchored configure popover (Link text, Landing destination, read-only auto-generated safe tracking URL with a "recipients never reach a real site" note, Cancel / Insert link), and (3) the inserted tracked-link token with a "Tracked link" badge and a confirmation toast. This reinforces the DR-04 trust signal at the moment a link is created. New residual items: Add Phishing Link needs an insert-blocked state when no landing destination is chosen, and the sibling **Add QR code** tool's configure/confirm behavior is not yet specified. All feature knowledge files (prd, user-flow, design-strategy, edge-cases, open-questions) were synced to the as-built design on this date.

---

**Reviewed artifact:** Figma file "Dune Security (Master file)," page "DUNE 628 - Custom Creation of phishing Assets" — the Simulated Attacks Library entry point plus the "Create New Asset" flow (three tabs: Generate with AI, Create Manually, Upload EML File), inspected live via Figma Desktop Bridge (9 screen frames + 1 flattened flow-diagram image + library list states). This predates all of this session's `prd.md`, `prd-research`, `competitor-analysis`, and `design-strategy` work by roughly six months, so it should be read as a strong existing foundation to reconcile with the newer requirements, not as a fresh design responding to them.

## Review summary
- **Biggest strength:** the flow already ships a mature, multi-channel "Simulated Attacks Library" (table, search, filters for Sender/Difficulty/Motive/Method, tabs for Email/SMS/Voice/Hybrid/Custom Assets) and a single-page, progressive-disclosure creation screen (prompt → generate → edit, all without leaving the page) — both stronger starting points than assuming a greenfield build.
- **Biggest risk:** several capabilities the current PRD treats as acceptance criteria are either absent or present only as inert UI — most notably, Difficulty is a dropdown that never influences generation and only gets set after the fact, there is no desktop/mobile preview toggle anywhere, and there is no visible confirmation that redaction or safe-link rewriting actually happened.
- **Second risk:** the Upload EML creation mode breaks its own WYSIWYG promise — the body editor for an uploaded email renders raw HTML source (`<html><head>...`) instead of the rendered email, which is a different and worse editing experience than the other two modes.
- **Overall confidence:** high on what was inspected (9 of 9 relevant screens plus the library, captured directly from the live file); confidence is lower on anything not visible in this page, e.g. whether RBAC is handled by a global permission layer elsewhere in the product rather than being absent.
- **Readiness:** not ready for handoff against the current PRD as-is — several stated acceptance criteria have no home in this design yet, though the core interaction model is worth preserving and extending rather than replacing.

## Quality bar assessment
This falls short of a Stripe-level standard in three specific ways, not across the board. **Clarity and structural craft are actually good** — the tab model, the info banner setting AI-vs-manual expectations, and the single-page reveal-on-generate pattern are all confident, restrained decisions. Where it falls short is **trust communication and state completeness**: a feature whose entire value proposition rests on "we redact sensitive data and rewrite links safely" currently gives the analyst zero visual confirmation that either happened, and a ~10-second AI generation call has no progress feedback at all. Stripe-level craft would not ship an invisible multi-second wait or a claimed safety transformation with no on-screen evidence it occurred.

## Findings

### DR-01
**Severity:** S3
**Category:** Error prevention / State completeness
**Location:** "Generate with AI," "Create Manually," and "Upload EML File" tabs — Difficulty dropdown
**Issue:** Difficulty (Select difficulty) sits at the bottom of the form, after Sender/Subject/Body, and remains unset (placeholder text) even in every post-generation screenshot reviewed. Nothing in the generation flow reads this value before or during generation — it appears to be a library-filter tag set after the content already exists, not an input to the AI.
**Why it matters:** The PRD's acceptance criteria state difficulty "adjusts cues and sophistication using agentic reasoning" — i.e., it's supposed to shape the generated content (urgency, visual polish, pretext depth), not classify it after the fact. As designed, an analyst could ship a template labeled "Hard" that was never actually generated with hard-difficulty characteristics.
**Recommended fix:** Move Difficulty above the generate action on the AI and Manual tabs so it's part of the generation input, and pass it as a parameter to whatever produces the draft. If it's intentionally decoupled (e.g., difficulty is purely a post-hoc library tag and sophistication is controlled elsewhere), that should be stated explicitly in the flow so it isn't mistaken for an input.
**Principle/Heuristic violated:** Match between system and the real world; Dune's Trust & Risk Communication heuristic.
**Teaching note:** When a control's position in a form implies causality ("set this, then generate"), verify it actually participates in that causality — a control that looks like an input but behaves like a label is a quiet but serious trust gap in an AI feature.
**Outcome:** Fixed. Difficulty moved above the Generate/Upload action on all three setup screens, defaulted to Medium; the Edit screen pairs it with an explicit Regenerate action instead of auto-applying.

### DR-02
**Severity:** S3
**Category:** State completeness / Trust and risk communication
**Location:** All three "Create New Asset" tabs — Preview panel
**Issue:** No desktop/mobile preview toggle exists anywhere in the reviewed frames. The Preview panel renders a single, fixed-width rendering regardless of tab or state.
**Why it matters:** This is a named PRD acceptance criterion ("Template preview supports desktop and mobile"), and most target employees will open a phishing simulation on their phone — an analyst currently has no way to verify how the template actually renders there before it goes live.
**Recommended fix:** Add a desktop/mobile toggle to the Preview panel header, consistent with how other Dune preview surfaces handle responsive states.
**Principle/Heuristic violated:** State completeness for enterprise workflows; PRD acceptance criteria compliance.
**Teaching note:** A "preview" that only shows one viewport is half a preview for anything that ends up in an inbox — email rendering is one of the few remaining places where desktop/mobile divergence is still common and consequential.
**Outcome:** Fixed. Added a Desktop/Mobile segmented toggle to the Preview panel header on both edit screens, plus a dedicated Mobile Preview screen showing the narrower, correctly-wrapped rendering.

### DR-03
**Severity:** S3
**Category:** Consistency and standards / Hierarchy and clarity
**Location:** Upload EML File tab, Body editor (frame `13947:20653`)
**Issue:** After uploading an `.eml`, the Body field in the rich-text editor shows raw HTML markup (`<html><head><meta content="text/html"...`) rather than the rendered email content that the AI-generated and Manual tabs show in the same editor.
**Why it matters:** This breaks the WYSIWYG promise specifically for the "Copy an Email" path — the mode the PRD frames as the fast, no-technical-skill route for turning a real email into a simulation. An analyst editing raw HTML risks breaking the rendering entirely, and the editor's own toolbar (bold, alignment, font) is useless against a wall of markup.
**Recommended fix:** Parse and render uploaded `.eml` HTML into the same WYSIWYG canvas used by the other two modes before the analyst ever sees it; if rendering fails, show an explicit fallback state ("We couldn't fully render this email's formatting — edit the raw content below") rather than silently defaulting to source view.
**Principle/Heuristic violated:** Match between system and the real world; Consistency and standards (same editor behaves differently per creation mode with no explanation).
**Teaching note:** When one of three parallel paths through a shared component behaves differently from the other two with no visible reason, assume it's an unhandled edge case, not a deliberate variant, until proven otherwise.
**Outcome:** Fixed. The rebuilt Upload EML edit screen shows fully rendered body content (verified via screenshot — a rendered Zendesk-branded email, not markup); the redundant duplicate frame that had shown raw HTML was removed from the rebuilt storyboard.

### DR-04
**Severity:** S3
**Category:** Trust and risk communication
**Location:** All "Create New Asset" tabs — Preview panel and Body editor, post-generation/post-upload
**Issue:** Nothing in the UI confirms that sensitive/organization-specific data was replaced with placeholders, or that links were rewritten to safe simulation URLs. Placeholder tokens do appear in the content (`{{firstname}}` in the AI-generated example, `__FIRST_NAME__ __LAST_NAME__` in the uploaded-EML example) but use two different, unexplained conventions and no distinct visual treatment (highlight, badge, or styling) marks them as auto-inserted.
**Why it matters:** Sensitive-data redaction and safe-link rewriting are the feature's core safety claims. An analyst has no way to visually verify either happened — they'd have to take it entirely on faith, which is a real trust gap for a security product whose customers are themselves security-skeptical buyers.
**Recommended fix:** Give placeholder tokens a single, consistent syntax and a distinct visual style (e.g., a light-colored pill) across all three creation modes, and add a small explicit confirmation near the Preview panel (e.g., "Links converted to safe simulation URLs" with a checkmark) once generation/upload completes.
**Principle/Heuristic violated:** Trust and risk communication (Dune heuristic #11); Consistency and standards (two token syntaxes for the same concept).
**Teaching note:** A safety claim a user can't see evidence of is functionally the same as no safety claim, from a trust standpoint — surfacing the transformation is not decoration, it's the proof of the promise.
**Outcome:** Fixed. Added a green confirmation line under the Preview header on both edit screens: "✓ Sensitive data redacted · Links converted to safe simulation URLs." Placeholder token syntax unification across modes was not completed — tracked as a residual item below, not blocking.

### DR-05
**Severity:** S2
**Category:** State completeness / Visibility of system status
**Location:** Transition between clicking "Generate Asset" and the Preview/Edit reveal
**Issue:** No loading, progress, or labeled-stage state was found anywhere in the reviewed frames between submitting a prompt/upload and seeing the generated result.
**Why it matters:** The PRD targets ~10 seconds for generation. Ten seconds with a static or absent loading state reads as broken, especially compared to Dune's own established pattern (AEP Builder's labeled progress stages — "Analyzing scenario" → "Building persona" → "Configuring behavior" → "Ready") for a materially similar wait.
**Recommended fix:** Reuse the AEP Builder's labeled, advancing-stage progress pattern rather than designing a new one — name the stages after what generation actually does (analyzing input, drafting template, redacting sensitive data, rewriting links), which also does double duty as trust communication for DR-04.
**Principle/Heuristic violated:** Visibility of system status (Nielsen #1).
**Teaching note:** Any async action in the 3–15 second range needs a designed waiting state — below that, a simple spinner is fine; above that, silence reads as failure.
**Outcome:** Fixed. Added a new Generating screen with 5 labeled advancing stages (Analyzing input, Drafting template, Redacting sensitive data, Rewriting links to safe URLs, Ready), matching the AEP Builder precedent named above.

### DR-06
**Severity:** S2
**Category:** Recognition rather than recall / Consistency and standards
**Location:** Create New Asset — no field labeled "Template Name" or "Asset Title" on any of the three tabs
**Issue:** The Library table has a "Title" column, but none of the three creation tabs shows a distinct field for it — only Sender email, Sender Name, Subject, and Body. It's unclear whether the library Title is auto-derived from the email Subject line or set somewhere not visible in these frames.
**Why it matters:** Conflating "the internal name admins use to find this template in the library" with "the subject line the target employee sees" is a real risk: two templates with similar bait subjects ("Your account requires action" / "Your account needs verification") would be hard to tell apart in the library, and the PRD's own open question about duplicate-name handling has no field to attach validation to.
**Recommended fix:** Add an explicit Template Name field, separate from Subject, on all three tabs — even if it's pre-filled from the category/prompt by default.
**Principle/Heuristic violated:** Recognition rather than recall; ties directly to the still-open "is there duplicate-name validation" question in `open-questions.md`.
**Teaching note:** Any object with a library/list view needs an explicit name field distinct from its user-facing content — don't let the two merge just because they're often similar.
**Outcome:** Fixed. Added an explicit Template Name field, separate from Subject, at the top of all three creation tabs and both edit screens, with helper text clarifying it's used to find the template in the library later.

### DR-07
**Severity:** S2
**Category:** Consistency and standards
**Location:** "Create Manually" tab (frame `5202:98882`)
**Issue:** The Manual creation tab's Body field is pre-filled with the exact same fixture content as the AI-generated example ("Hi {{firstname}}... Verify My Account...") rather than starting blank or with a minimal scaffold.
**Why it matters:** This is very likely a mock artifact (reused fixture data) rather than an intended behavior, but as designed it undermines the tab's own value proposition — the intro banner says "Manual gives you full control," but a pre-filled body that's identical to the AI output doesn't read as a blank slate.
**Recommended fix:** Confirm this is fixture reuse rather than intended default content; if manual mode is meant to start from a light scaffold (a bare HTML shell, or no body at all), design that state explicitly rather than reusing the AI example.
**Principle/Heuristic violated:** Match between system and the real world.
**Teaching note:** Reused mock content is easy to mistake for a real default — flag it explicitly in the file (e.g., a comment or a "placeholder fixture" annotation) so it doesn't ship as-is.
**Outcome:** Fixed. Create Manually's body canvas now starts genuinely blank with placeholder guidance text ("Start writing your email..."); Sender Name, Subject, and the Preview panel were all reset to blank/placeholder state to match.

### DR-08
**Severity:** S1
**Category:** Consistency and standards (craft)
**Location:** "Generate with AI" tab, "Select motive" field (frame `5040:166284`)
**Issue:** The field labeled "Select motive" displays "Sender" as its current value, not a motive-type value (the Library's own Motive column shows values like "Authority," which is what this field should presumably show).
**Why it matters:** Likely a copy-paste artifact from the adjacent Sender field, but it reads as a wiring bug and would confuse a reviewer or engineer picking this up for handoff.
**Recommended fix:** Correct the placeholder/selected-value shown in this control to match the Motive taxonomy (Authority, Urgency, etc.), and verify it during any Figma QA pass before this file is used for handoff.
**Principle/Heuristic violated:** Consistency and standards.
**Teaching note:** Small mismatches like this are cheap to fix now and expensive to discover during dev handoff — worth a dedicated QA pass on any file being reused after a long gap.
**Outcome:** Fixed. The Select motive field now displays "Authority" (a real motive value matching the Library's own Motive taxonomy) instead of "Sender."

### DR-09
**Severity:** S2
**Category:** RBAC / permissions
**Location:** Entire reviewed flow (Library + all three creation tabs)
**Issue:** No view-only, restricted-action, or disabled-with-tooltip states were found anywhere in the file. "Save Asset" appears as a single, always-enabled green button in every frame reviewed, and the post-save toast shows the asset already at "Active" status with no visible deploy/publish gate.
**Why it matters:** The current PRD requires "RBAC controls govern who can view, edit, or deploy templates," and treats save/deploy as potentially separable actions. This design shows Save producing an immediately Active asset with no distinct deploy step, gate, or confirmation — a materially different (and simpler) model than what design-strategy.md proposes (Draft → Ready → In Use, with a separate RBAC-gated "Use in Campaign" hand-off).
**Recommended fix:** This needs a product decision, not just a design fix: confirm whether "Active" immediately means live/deployed in this existing model, or whether Active vs. deployed-to-a-campaign are already distinct concepts handled downstream of this screen. Either way, RBAC view/edit/deploy states need to be designed explicitly before handoff.
**Principle/Heuristic violated:** RBAC and permission boundary clarity (Dune heuristic #12).
**Teaching note:** Absence of RBAC states in a mock isn't proof RBAC is unhandled — it's equally possible permissions are enforced by a layer this file doesn't show. Confirm before treating this as a gap to design versus a gap to document.
**Outcome:** Fixed (design gap). Added a Library view-only state (no Create/Request action, explicit "View-only access" label) and a new Template Detail screen with two RBAC variants: Use in Campaign enabled, and disabled at 40% opacity with a "You don't have permission to deploy templates" note. The underlying product question — whether Active-on-save is intentional or a downstream deploy gate exists elsewhere — remains open (see Open Questions).

### DR-10
**Severity:** S1
**Category:** Craft / polish
**Location:** Upload EML File tab, helper text below Body editor
**Issue:** The helper text under the Body field literally reads "This is a hint text to help user." — unfinished placeholder copy left in the file.
**Why it matters:** Low severity on its own, but a signal this file needs a copy pass before reuse.
**Recommended fix:** Replace with real guidance (e.g., what the analyst can/should edit here, or a note about redaction).
**Principle/Heuristic violated:** Help and guidance (Nielsen #10).
**Teaching note:** Placeholder copy left in a file for six months is a good prompt to do a full copy audit before treating any part of the file as ready for handoff.
**Outcome:** Fixed. Replaced all instances of "This is a hint text to help user." across Sender email, Sender Name, Subject, and Difficulty fields on every screen with real, field-specific guidance copy.

## Strengths
- The single-page, progressive-disclosure creation model (prompt/upload → generate → same-screen edit reveal, no separate wizard steps) is more efficient than a multi-screen wizard and is worth carrying forward into the newer strategy work rather than replacing.
- The existing **Simulated Attacks Library** (table with Sender/Difficulty/Motive/Method/Vector filters, Email/SMS/Voice/Hybrid/Custom Assets tabs, search, and an org-level "Simulated Attack Frequency" module) is a mature, already-built surface this feature should extend, not duplicate.
- The "Motive" taxonomy (Authority, etc.) already echoes AEP Builder's Adversary Method concept — a real opportunity for cross-feature consistency that's already half-built.
- In-body authoring tools ("Add Phishing Link," "Add QR code") are a thoughtful, already-solved capability for embedding the actual attack vector directly during editing, and aren't addressed at all in the current PRD — worth explicitly deciding to carry forward.
- The intro banner ("Generate with AI or write your own asset. AI is fast and effortless. Manual gives you full control.") sets expectations clearly and calmly across all three tabs — good adherence to Dune's "calm authority" tone principle.

## Open questions (post-rebuild)
- **[Design]** Does this Figma page reflect the current production experience, or is it a superseded/parked exploration? Unresolved — a process question, not a design gap.
- **[PM]** Is "Active" status on save the intended final state, or is there a downstream deploy/campaign-attach gate not visible in this file? The rebuild adds RBAC-gated deploy states on the new Template Detail screen but does not resolve this underlying product question — still needs a PM decision.
- **[Design]** Should this feature's library be the existing "Simulated Attacks Library" rather than the standalone Template Library proposed in `design-strategy.md`? The rebuild extends the existing library directly (empty + view-only states added to it), implicitly answering this in favor of reuse — confirm with the team before treating it as final.
- **[Design]** Placeholder token syntax (`{{firstname}}` vs. `__FIRST_NAME__`) was not unified across creation modes in the rebuild — worth a follow-up pass.
- **[Design]** Regenerate and Delete buttons reuse the primary green button style since no destructive/red variant exists in this file's component set — confirm whether a true destructive style should be added to the DS.

## Revision priorities (post-rebuild)
1. Resolve the Active-on-save vs. downstream-deploy-gate product question with PM (open, not a design fix).
2. Confirm the Simulated Attacks Library reuse direction with the team (open, not a design fix).
3. Unify placeholder token syntax and add a true destructive button style to the DS (residual polish, non-blocking).

## Verdict
~~Needs revision.~~ **Revised 2026-07-09: Ready for handoff**, pending the two open product decisions above.

## Files saved
- `knowledge/features/ai-phishing-template-generator/design-review.md`
- `knowledge/features/ai-phishing-template-generator/design-review.json`
