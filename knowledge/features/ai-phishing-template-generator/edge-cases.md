# Edge Cases — AI Phishing Template Generator

_Updated 2026-07-13 to match the as-built storyboard. Items marked ✅ are now designed/handled in the build; others remain to validate. Product noun is "asset."_

## System states
- Generation fails outright (model or service error), distinct from exceeding the ~10s target — ✅ inline error + Try again on the Generating screen
- ✅ Labeled Generating progress state (Analyzing input → Ready) instead of a static spinner
- Sanitization step rejects or strips part of an upload — surface an analyst-facing message naming what was flagged (copy still to finalize)
- ✅ Library empty state (dual CTA) and view-only state built
- Uploaded .eml contains malformed or malicious content (embedded scripts, oversized attachments) caught by sandboxing

## Permission states
- ✅ View-only role: sees the library with no Create New Asset action and a "View-only access" indicator
- ✅ Role with create/edit but not deploy: Use in Campaign disabled with tooltip on Asset Detail
- Copy an Email uses the same permission tier as the AI mode (resolved — no separate gate)
- Cross-workspace access attempt on an asset ID — access denied
- Screenshot upload zone appears or is hidden based on workspace-level enablement

## Content states
- Very sparse or single-word prompt — soft helper text, no hard minimum
- Plaintext-only .eml with no layout to preserve — generation proceeds with minimal layout blocks
- ✅ Create Manually starts with a genuinely blank body — saving with an empty body should be blocked/warned (needs content to be a usable asset)
- Duplicate asset name within a workspace — save blocked with inline validation
- Sensitive data embedded in an image that text-based redaction cannot reach (v1: text-only redaction, images carry through as-is)
- Uploaded .eml exceeds file size limit — rejected inline

## Action states
- ✅ Difficulty changed after manual edits — no effect on the draft; a different difficulty requires the explicit, confirmed Regenerate
- ✅ Regenerate is an explicit action with a confirmation modal (discards current edits)
- ✅ Delete flow designed — confirmation modal on Asset Detail; downstream behavior for a campaign-linked asset still open
- **Add Phishing Link — no landing destination chosen:** Insert should be blocked until a destination is selected; the tracked URL only generates once a destination exists
- **Add Phishing Link — cursor placed with no text selected:** define whether it inserts a new link or requires a selection (build shows selection-first)
- **Add QR code:** insertion path exists in the toolbar as a sibling to Add Phishing Link — its own configure/confirm behavior still to spec
- Bulk actions on the library not addressed
- Deploy attempted without deploy permission — disabled with tooltip

## Responsive / Accessibility
- ✅ Preview has a desktop/mobile toggle; a dedicated mobile-preview rendering is built
- Editing (drag-and-drop WYSIWYG) treated as desktop-only for v1 — mobile is preview-only (open issue, not confirmed)
- Drag-and-drop block reordering needs a keyboard-operable alternative (Move up / Move down)
- The tracked-link token and "Tracked link" badge must not rely on color alone to signal a link is safe/tracked
