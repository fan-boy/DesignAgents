# Edge Cases — AEP Library (Custom AEP Builder)

## System states
- AEP save fails mid-creation (LLM validation error, network timeout, server error) — should draft be preserved?
- Live simulator fails to start (model unavailable, quota exceeded, latency >5s) — must show an error state, not a blank chat pane
- Simulator message takes >5 seconds to respond — typing indicator needed
- Dune-seeded library fails to load — skeleton placeholder vs. empty state (these must be visually distinct)
- Autosave draft: if admin closes builder mid-creation, is work preserved?

## Permission states
- Campaign manager or non-admin visits AEP Library — create/edit actions hidden or disabled with tooltip
- Tenant has not been granted custom AEP access (feature gate) — the "Create AEP" CTA must surface the gate state, not silently be absent
- View-only admin can see AEP detail but cannot edit — all fields read-only, edit button absent
- Org admin loses admin role mid-draft — draft is saved but cannot be published

## Content states
- Zero custom AEPs created — first-time empty state for the Custom section (distinct from "library failed to load")
- Custom AEP limit reached (4 or 5) — create button disabled with limit message and recovery action
- Zero Dune-seeded AEPs — shouldn't happen at launch, but must be handled gracefully
- AEP name collision — two custom AEPs with the same name (validation on save? warning inline?)
- Very long AEP name — truncation in library card, full name in detail/builder header
- Very long system prompt approaching token limit — character counter, warning at threshold, block at limit
- Adversary Method list is empty or not loaded — select field fallback state

## Action states
- Deleting a custom AEP currently used in an active campaign — must block or show a strong warning modal with campaign list
- Deleting a custom AEP used in a completed campaign — warn about historical reference impact; likely allow with confirmation
- Editing a custom AEP currently used in an active campaign — must warn that in-flight conversations may be affected; ideally block edit or version-fork
- Publishing a custom AEP (if draft → published state exists) — confirmation before it becomes campaign-eligible
- Duplicating a Dune-seeded AEP as a custom template — counts toward custom limit on duplication
- Resetting a custom AEP to a previous state — is undo/version history available?
- Discarding unsaved changes in the builder — "Leave page?" confirmation guard

## Responsive / Accessibility
- Prompt editor on narrow viewports — full-screen textarea vs. collapsible panel decision needed
- Live simulator split pane on smaller screens — tab-based layout may be needed (editor tab / simulator tab)
- Screen reader handling of simulator messages — each turn must be announced in reading order; avoid real-time live region thrashing
- Keyboard navigation through AEP library cards — focus order, card activation via Enter/Space
- Outcome tabs (Complicit / Non Complicit / etc.) — must be keyboard accessible and ARIA-labeled correctly
- Color-alone differentiation — Dune-seeded vs. Custom distinction must not rely on color alone
