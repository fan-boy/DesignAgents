# User Flow — AI Phishing Template Generator

## Entry points
- Template Library, via "New Template" primary action (analyst already has library access)
- Template Library empty state, via one of two direct CTAs: "Describe a Scenario" or "Copy an Email"
- Template Detail page, via "Edit" (returns an existing Draft/Ready template to the Edit & Preview screen, not the Setup screens)

## Happy path

1. Analyst opens the Template Library and clicks **New Template**.
2. The mode chooser appears: **Describe a Scenario** or **Copy an Email**. Analyst selects one and clicks **Continue**.
3. Analyst completes the mode-specific setup screen:
   - *Describe a Scenario:* enters a free-text prompt, selects a phishing category, sets difficulty (Easy/Medium/Hard, default Medium).
   - *Copy an Email:* uploads a `.eml` file (and optionally a screenshot, if enabled for the workspace), sets difficulty.
4. Analyst clicks **Generate Template**.
5. The system shows a labeled progress sequence: "Analyzing input" → "Drafting template" → "Redacting sensitive data" → "Rewriting links to safe URLs" → "Ready." This completes in roughly 10 seconds.
6. Analyst lands on the **Edit & Preview** screen with a fully drafted template rendered in the WYSIWYG canvas: subject line, sender display name, body copy, layout blocks, and CTA(s) pointing to safe simulation URLs. Redacted fields appear as visually distinguished placeholder tokens.
7. Analyst makes manual edits directly in the canvas (copy, layout, sender name, subject line) and toggles between desktop and mobile preview to check both renderings.
8. Analyst clicks **Save**. If the template doesn't already have a name/category, a lightweight inline naming step appears, pre-filled from setup inputs.
9. The template saves; its status badge moves from Draft to Ready; a toast confirms the save.
10. Analyst either continues editing or navigates to the **Template Detail** page, where a permitted user can click **Use in Campaign** to hand the template to the Campaign Launcher (out of scope for this feature).

## Decision points

- **Mode choice (step 2):** Describe a Scenario vs. Copy an Email — determines which setup screen appears next; both converge on the same Generate → Edit & Preview → Save sequence.
- **Difficulty change after generation:** Changing the difficulty selector on the Edit & Preview screen does **not** alter the current draft by itself. Getting a different-difficulty variant requires clicking the separate **Regenerate** action.
- **Regenerate clicked:** Always triggers a confirmation modal ("Regenerating will discard your current edits and create a new draft. This can't be undone.") before proceeding, since it replaces the entire draft.
- **Save clicked without a set name/category:** Branches into the inline naming/category-confirm step before the save completes.
- **RBAC at each screen:** View-only roles see the Library and Edit & Preview screens in read-only form; users without deploy permission see a disabled "Use in Campaign" button with a tooltip on Template Detail.

## System responses

- **Generation (step 5):** Async, target ~10s, labeled stages advance visibly rather than a static spinner. On outright failure, an inline error appears with a "Try again" action and all setup inputs preserved.
- **Regenerate confirmed:** Async call replaces the draft content in the canvas; on completion the canvas re-renders with the new draft at the newly selected difficulty; on failure the prior draft remains untouched and an inline error is shown.
- **Save:** Validates the template name for duplicates within the workspace before committing; on success, status badge updates and a toast confirms.
- **Upload (Copy an Email):** `.eml` (and optional screenshot) are sandboxed and sanitized before analysis begins; the Setup screen holds a content-handling disclosure line (final copy pending the unresolved retention-policy question).

## Edge cases

| Edge case (from edge-cases.md) | Handling in this flow |
|---|---|
| Generation fails outright | Inline error with "Try again" on the Generating screen; setup inputs preserved |
| Sanitization rejects or strips part of an upload | Inline error on the Copy an Email setup screen naming what was flagged, before generation starts |
| Template library empty on first use | Empty state with dual CTAs (Describe a Scenario / Copy an Email) instead of a single generic CTA |
| View-only role opens the editor | Canvas renders read-only; no drag handles, no inline editing; Regenerate/Save hidden or disabled with tooltip |
| Copy an Email and Describe a Scenario share one permission tier | No separate permission-request branch; both modes are available to anyone who can create templates |
| Cross-workspace access attempt on a template ID | Access denied; templates never resolve outside their owning workspace |
| Sparse or single-word scenario prompt | No hard minimum enforced; soft inline helper text encourages more detail rather than blocking generation |
| Plaintext-only `.eml` with no layout to preserve | Generation proceeds; resulting template has minimal layout blocks rather than an error |
| Duplicate template name within a workspace | Save is blocked with an inline validation message at the naming step; analyst must rename |
| Template library at scale | Filter bar (category, difficulty, creation mode, status, date range) plus full-text search on the Library screen |
| Difficulty changed after manual edits | No effect on the current draft; edits are preserved. A different difficulty requires the explicit, confirmed Regenerate action |
| No delete flow was originally described | This flow proposes a Delete action with a confirmation modal on Library rows and Template Detail; exact behavior for campaign-linked templates remains an open issue |
| Editing on mobile/tablet not addressed | Assumed desktop-only for editing; mobile shows Preview only (open issue, not confirmed by PRD) |
| Drag-and-drop reordering needs a keyboard alternative | Move up / Move down affordances accompany drag handles on the canvas |

## Exit states

- **Success:** Template saved, status Ready, toast confirmation, analyst lands on Template Detail or returns to Library.
- **Cancellation:** Analyst clicks Cancel/Discard at any point in Setup or Edit & Preview; unsaved work is discarded with no template created, returning to the Library.
- **Error (generation):** Inline error on the Generating screen with retry; setup inputs preserved, no draft created until generation succeeds.
- **Error (regenerate):** Prior draft remains intact; inline error shown; analyst can retry or continue editing the existing draft.
- **Timeout (generation exceeds ~10s):** Labeled progress continues advancing rather than erroring; only an outright failure produces the error state above.
