# Edge Cases — AEP Builder + AEP Library
Last updated: 2026-06-01 (v2C Inline AI design)

## System states

- **Generation partial failure:** Some AEP sections generate successfully, others fail (LLM timeout or malformed output). Must surface which specific sections failed and allow per-section retry. All form inputs must be preserved. *(REQ-SS-05)*
- **Generation full failure:** All sections fail. Retry full generation or allow customer to proceed to Stage 2 only if no partial results exist.
- **Generation timeout (image OCR path):** P95 < 90s but may feel very long. Progress stages must visibly advance; if a stage stalls beyond expected time, surface estimated remaining wait rather than silence.
- **OCR failure on image upload:** Individual image file fails OCR extraction. Surface per-file error with option to paste the text content manually instead.
- **Stage 2 persona response timeout:** P95 < 3s, but what happens if exceeded? Needs in-chat timeout message with "Try again" and "Reset conversation" options.
- **Step 2 test session saves mid-conversation:** Customer closes browser during an active test session. Should the transcript be preserved in the Recent Changes / session log?
- **Refinement round timeout:** Refinement P95 < 20s; if exceeded, "Generation failed" appears in Recent Changes with "Something went wrong. Your changes weren't saved." and "Try again →". Instruction text not lost.
- **Quick Action chip + custom instruction conflict:** Manager selects a chip (e.g., "Less aggressive") and also types in the custom instruction field. Does Apply combine both? Define precedence — likely: custom instruction overrides or appends to chip selection.
- **Auto-save / resume for Step 1 form:** If customer closes the browser mid-Step-1, is the draft preserved and resumable? (Unresolved — Eng question)
- **Validation on demand fails:** "Check AEP" button returns an error rather than validation results — retry CTA needed.
- **Draft auto-save failure:** Background save of form state fails silently — customer may lose work. Need a visible save-state indicator.

## Permission states

- **Reviewer role:** Read-only access to AEP detail page. Must see: AEP name, scenario, all six sections of Stage 1 data, stage indicators, version, linked campaigns. Actions: Approve, Request Changes. No Builder access.
- **Reviewer accessing a non-pending AEP:** Can view but Approve/Request Changes CTAs are inactive or hidden for Active/Archived AEPs.
- **Dune Operator view:** Full customer view plus: raw JSON panel (technical debugging), validation warning override (logged), operator refinement prompt (logged as operator-authored), Operator Assist flag toggle, access to test session transcripts.
- **Dune Admin:** All Operator permissions plus: global template promotion (promote customer AEP to global template), global ban list management.
- **Customer without Red Teaming access:** AEP Library not visible in navigation. Direct URL to AEP detail returns permission error.
- **Non-owner customer viewing teammate's draft:** Is a draft visible to other Security Managers in the same org? (Unresolved — treat as visible within org for now, flag for PM confirmation.)
- **Customer with Reviewer-configured account attempting to launch campaign:** Campaign launch blocked until AEP status = Active (approved). Must surface which AEP is pending and link to the approval state. *(REQ-CAM-02)*

## Content states

- **Empty library (first visit):** Illustration + "No AEPs yet" + "New AEP" button + "Start from Template" button. No table, no filter bar. *(REQ-LIB-01)*
- **Library with only Draft AEPs and no Active ones:** "Start from Template" and "New AEP" entry points visible; campaign creation will prompt to publish an AEP.
- **Draft AEP with 0 test sessions:** Publish button disabled. Tooltip: "Test this AEP in Stage 2 before publishing."
- **Draft AEP with exactly 1 test session:** Publish enabled but with validation warning: "Only 1 test session completed. We recommend testing at least 2–3 sessions with different archetypes before publishing." Requires acknowledgment.
- **AEP in active or scheduled campaign:** Archive blocked. Error: "This AEP is attached to [Campaign Name]. Archive is blocked until the campaign concludes." *(REQ-LIB-04)*
- **AEP in completed campaign:** Archive allowed with confirmation: "This AEP was used in [N] past campaign(s). Archiving will not affect historical records. Continue?"
- **Template picker has no templates available:** Error state in Stage 1 template modal. "Templates are temporarily unavailable. Start from scratch or try again shortly." Retry CTA.
- **No Active AEPs in library when customer creates campaign:** AEP selector shows empty state: "No published AEPs yet. Build one now." Links to AEP Builder Stage 1.
- **AEP name collision:** Two AEPs with identical names (possible after cloning). Allow duplicates but add visual disambiguation (version + created date shown on card/row).
- **Very long scenario description:** Approaching generation token limit — character counter with warning at 80% and hard stop at 100%.

## Action states

- **Archive blocked by campaign:** Error dialog names the blocking campaign(s) with a link to each. No bulk-archive past this block.
- **Refinement prompt blocked (guardrail removal attempt):** User-facing message: "This change would weaken a required safety guardrail. Refinements cannot disable hate speech, violence, or PII collection protections. Describe what behavior you want to change instead." Prompt input persists for editing.
- **Refinement prompt blocked (compliance framework removal):** "To remove a compliance framework, return to Stage 1 and update the Rules & Compliance section."
- **Publish blocked — blocking validation failure:** In-flow redirect to the specific section and field causing the failure. Highlight the field with inline error. Do not just show a toast.
- **Publish with warnings — acknowledgment required:** Each warning shown as a distinct checkbox item. Customer must check each one before the Confirm Publish CTA activates. *(REQ-VAL-03)*
- **Clone action:** New Draft created with all source AEP fields, incremented version (e.g., 1.0.0 → 2.0.0), and lineage recorded in metadata.templateLineage. Customer lands on Stage 1 of the clone with a banner: "This is a clone of [Source AEP Name]. Update the details below and regenerate."
- **Operator Assist flag set:** Customer receives a prominent in-platform notification with: operator name, timestamp, summary of what changed, and a diff view. Customer can review changes and republish when ready (requires cloning if original is already Active).
- **Delete vs. Archive:** PRD uses "Archive" (soft-delete) not "Delete" (hard-delete). Archive is reversible — confirm whether Unarchive is a supported action.

## Responsive / Accessibility

- **Generation progress screen (15–90s):** Must not use a static spinner. Labeled stage text ("Analyzing your scenario", "Building conversation flow", "Configuring guardrails", "Finalizing") must update visibly. Consider progress bar with time estimate.
- **Stage 3 diff view:** Accept/reject per field — keyboard navigable (Tab between fields, Space to accept/reject). Screen reader must announce each changed field name, old value, and new value.
- **Example upload (Stage 1):** Drag-and-drop zone with visible focus state + keyboard-accessible fallback (file picker button). Per-file processing status (queued, OCR processing, ready, failed) visible for each uploaded file.
- **Stage 1 form long scroll:** Six sections on one page may be very long on smaller viewports. Consider sticky section nav or accordion grouping. Ensure each section is reachable via keyboard.
- **AEP library table:** Column sort, filter bar, and search must be keyboard accessible. Search result count announced to screen readers.
- **Stage 2 chat simulator:** Message input must be focusable and navigable. Archetype starter buttons must be keyboard accessible. State label indicator must be announced when it changes.
- **Opening message exceeds 280 characters:** Validation warning: "May be truncated on SMS or mobile channels." Surface before publish if SMS or mobile channels are selected.
