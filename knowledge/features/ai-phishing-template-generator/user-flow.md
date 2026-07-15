# User Flow — AI Phishing Template Generator

_As-built, synced 2026-07-13 to the rebuilt Figma storyboard. The product labels the deliverable an "asset"; the library is the existing Simulated Attacks Library (Custom Assets tab)._

## Entry points
- **Simulated Attacks Library**, via the **Create New Asset** button (creator role)
- **Library empty state**, via one of two direct CTAs: **Describe a Scenario** or **Copy an Email**
- **Asset Detail** page, via **Edit** (returns an existing draft to the Edit & Preview editor)

## Happy path

1. Analyst opens the Simulated Attacks Library and clicks **Create New Asset**.
2. The **Create New Asset** page opens with three tabs: **Generate with AI**, **Create Manually**, **Upload EML File**. The analyst picks a tab (no modal chooser). Each tab shows mode-specific setup on the left and a live Preview on the right.
3. Analyst completes the mode-specific setup:
   - *Generate with AI:* Template Name, a prompt (optionally seeded by a prompt chip), Select motive, Sender email/name, and Difficulty (default Medium). Clicks **Generate Asset**.
   - *Create Manually:* Template Name, Sender email/name, Subject, and starts writing in the blank Body editor; sets Difficulty. Clicks **Save Asset** (no generation step).
   - *Upload EML File:* Template Name, uploads a `.eml` (and optionally a screenshot if enabled), sets Difficulty. Clicks **Upload**.
4. For the two AI-assisted modes, the **Generating** screen shows a labeled progress sequence: Analyzing input → Drafting template → Redacting sensitive data → Rewriting links to safe URLs → Ready. Roughly 10 seconds.
5. Analyst lands in the **Edit & Preview** editor with the drafted asset in the WYSIWYG canvas. Above the Preview panel, a confirmation reads "Sensitive data redacted · Links converted to safe simulation URLs," and a **Desktop / Mobile** toggle switches the preview viewport.
6. Analyst edits directly in the canvas — copy, layout blocks, sender name, subject — and can insert attack vectors via the toolbar's **Add Phishing Link** and **Add QR code** (see sub-flow below).
7. To try a different difficulty, the analyst changes the Difficulty control and clicks the explicit **Regenerate** action, which first shows a confirmation modal (regenerating discards current edits). Changing Difficulty alone never alters the draft.
8. Analyst clicks **Save Asset**. Duplicate names in the workspace are blocked with an inline validation message.
9. The asset saves into the Simulated Attacks Library under **Custom Assets**; a success confirmation appears.
10. From the **Asset Detail** page, a deploy-permitted user clicks **Use in Campaign** to hand the asset to the Campaign Launcher (out of scope for this feature). Delete is also available here.

## Add Phishing Link sub-flow (within Edit & Preview)

1. **Select text** — analyst selects the display text in the body (e.g. "Verify My Account"); the *Add Phishing Link* toolbar control is the next action.
2. **Configure** — an anchored popover opens with Link text (pre-filled from the selection), Landing destination (what the simulation points at), and a read-only Tracked simulation URL with the note "Automatically rewritten. Recipients never reach a real site." Actions: Cancel / Insert link.
3. **Inserted** — the link becomes a visually distinct tracked-link token with a "Tracked link" badge, and a confirmation appears: "Phishing link added — routed through a safe simulation URL."

## Add Variable (personalization) sub-flow (within Edit & Preview)

1. **Insert variable** — with the cursor in the body, the analyst clicks the **Insert variable** (`{ }`) toolbar control.
2. **Pick a variable** — an anchored menu opens with a search field and plain-English variables grouped Recipient / Location / Company (First name, Last name, Email, Job title, Office location, Mailing address, City, Company name, Department), each with a faint sample value and a footer note: "Missing values fall back to a default — e.g. First name → 'there'."
3. **Inserted** — the variable drops in at the cursor as an atomic token chip (not editable free text, so it can't be typo'd or half-deleted). The Preview renders it filled with sample data (e.g. "Hi John,"). Variables resolve per recipient at send time.

The design goal here is foolproofness: named variables chosen from a menu, one click to insert, never hand-typed merge-tag syntax, and a per-variable fallback so a missing value never leaks raw tokens into a live simulation.

## Decision points

- **Tab choice (step 2):** Generate with AI vs. Create Manually vs. Upload EML File — determines the setup fields. AI and Upload modes go through Generating; Create Manually goes straight to editing.
- **Difficulty change after generation:** changing the Difficulty selector does **not** alter the current draft. A different-difficulty variant requires the explicit **Regenerate** action.
- **Regenerate clicked:** always triggers a confirmation modal before replacing the draft.
- **Insert phishing link:** blocked until a landing destination is chosen; the tracked URL is generated once a destination exists.
- **Insert variable:** one click from the menu inserts an atomic token; no typed syntax. Each variable carries a per-variable fallback so missing recipient data never renders raw tokens.
- **Save with duplicate name:** blocked with an inline validation message; rename required.
- **RBAC:** roles without create permission see a view-only library (no Create New Asset); roles without deploy permission see a disabled "Use in Campaign" with tooltip on Asset Detail.
- **Delete an asset:** available from two places — the library row **Actions** menu (View details / Duplicate / Delete) and the **Delete** button on Asset Detail. Both open the same Delete confirmation modal, which warns if the asset is linked to a campaign. View-only roles do not see Delete.

## System responses

- **Generation (step 4):** async, target ~10s, labeled stages advance visibly. On outright failure, inline error with "Try again" and setup inputs preserved; past ~10s the current stage keeps showing rather than blanking.
- **Regenerate confirmed:** async call replaces the draft; on failure the prior draft remains untouched with an inline error.
- **Save:** validates name uniqueness in the workspace; on success the asset appears under Custom Assets with a confirmation.
- **Upload:** `.eml` (and optional screenshot) are sandboxed, scanned, and isolated per workspace before analysis; a disclosure line under the upload zone states this. In the editor, the uploaded email renders as a formatted email, never raw HTML.

## Edge cases

| Edge case | Handling in this flow |
|---|---|
| Generation fails outright | Inline error with "Try again" on the Generating screen; setup inputs preserved |
| Sanitization rejects or strips part of an upload | Inline error on the Upload EML setup naming what was flagged, before generation |
| Library empty on first use | Empty state with dual CTAs (Describe a Scenario / Copy an Email) |
| Role without create permission opens the library | View-only library, no Create New Asset action, "View-only access" indicator |
| View-only role opens the editor | Canvas renders read-only; Regenerate/Save hidden or disabled with tooltip |
| Copy an Email and the AI mode share one permission tier | No separate permission-request branch for upload |
| Cross-workspace access attempt on an asset ID | Access denied; assets never resolve outside their owning workspace |
| Sparse or single-word prompt | No hard minimum; soft helper text encourages more detail rather than blocking |
| Plaintext-only `.eml` with no layout | Generation proceeds; minimal layout blocks rather than an error |
| Create Manually saved with an empty body | Save blocked/warned; the blank body needs content to be a usable asset |
| Add Phishing Link with no destination | Insert blocked until a landing destination is selected |
| Duplicate asset name in a workspace | Save blocked with inline validation; rename required |
| Difficulty changed after edits | No effect on the draft; a different difficulty requires the explicit, confirmed Regenerate |
| Delete an asset linked to a campaign | Confirmation modal warns deletion may affect the campaign; downstream behavior is an open question |
| Editing on mobile/tablet | Editing treated as desktop-only for v1; mobile is preview-only (open issue) |
| Drag-and-drop reordering needs a keyboard alternative | Move up / Move down affordances alongside drag handles |

## Exit states

- **Success:** asset saved into Custom Assets, confirmation shown, analyst lands on Asset Detail or returns to the library.
- **Cancellation:** Cancel/Discard in setup or editor discards unsaved work with no asset created.
- **Error (generation):** inline error with retry on the Generating screen; no asset created until generation succeeds.
- **Error (regenerate):** prior draft intact; inline error; analyst can retry or keep editing.
- **Timeout (past ~10s):** labeled progress keeps advancing; only outright failure produces the error state.
