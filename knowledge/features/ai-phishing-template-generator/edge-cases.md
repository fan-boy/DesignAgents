# Edge Cases — AI Phishing Template Generator

## System states
- Generation fails outright (model or service error), distinct from exceeding the ~10s target
- Sanitization step rejects or strips part of an upload, with no described analyst-facing message for what was flagged
- Template library loading state and empty-library state on first use
- Uploaded .eml contains malformed or malicious content (embedded scripts, oversized attachments) caught by sandboxing

## Permission states
- View-only role opens a template in the editor (read-only rendering, no drag/edit affordances)
- Analyst can create/edit but lacks deploy permission
- Copy an Email may warrant a distinct permission tier from Describe a Scenario given the higher-risk data-ingestion path
- Cross-workspace access attempt on a template ID
- Screenshot upload control appears or is hidden based on workspace-level enablement

## Content states
- Very sparse or single-word scenario prompt with no stated minimum input length
- Plaintext-only .eml with no layout to preserve
- Duplicate template name within a workspace
- Template library at scale (tens or hundreds of drafts) with no described search, filter, or sort
- Sensitive data embedded in an image (logo, signature block, address) that text-based redaction cannot reach
- Uploaded .eml exceeds file size limit

## Action states
- Difficulty changed after manual WYSIWYG edits have been made — outcome on those edits is unspecified
- Regenerate action (if distinct from difficulty-triggered re-adjustment) with no stated overwrite warning
- No delete flow described for templates
- Bulk actions on the template library not addressed
- Deploy attempted without deploy permission

## Responsive / Accessibility
- Preview is explicitly desktop + mobile; editing (drag-and-drop WYSIWYG) is not addressed for mobile/tablet
- Drag-and-drop block reordering needs a keyboard-operable alternative; none described
