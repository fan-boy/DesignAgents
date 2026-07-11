# Edge Cases — Candidate Multi-Role Coordination

## System states
- Resume upload parsing in progress / parsing failed (unreadable file, unsupported format)
- Call recording sync in progress from a connected call tool; sync failure (auth expired, tool disconnected)
- ATS/pipeline sync lag or failure between an opportunity's own pipeline and the unified Opportunities view
- Call recording fails to transcribe or produces a low-confidence transcript

## Permission states
- No role above Recruiter currently defined (no team lead/admin visibility into other recruiters' candidates)
- View-only or read-only access to a candidate record when a recruiter is covering for a colleague

## Content states
- Candidate sourced but not yet submitted to any opportunity (zero-opportunity empty state)
- Candidate with only one active opportunity — does the multi-track UI still render, or collapse to a single-pipeline view?
- Candidate active in a high number of opportunities (8-10+) — this is the threshold where the List view's default toggles to Board (grouped by stage) rather than an unresolved scaling question
- A note or call recording is marked excluded from matching after Para AI already used it in a recommendation
- The same real-world candidate exists as an independently-owned profile in another recruiter's own book — this feature has no visibility into or reconciliation with that; duplicate submission across recruiters to the same role is a platform-level risk this feature does not detect or prevent
- A volatile context item (comp expectation, location preference, timing) ages past the staleness threshold — flagged for reconfirmation in Context, and Para AI's matching weight for it is discounted correspondingly
- A durable context item (resume, tenure history) ages — never flagged as stale; only preference-like signals decay

## Action states
- Candidate declines or is rejected from one opportunity while active in others — other tracks unaffected, no cross-opportunity inference
- Para AI proposes submitting the candidate to two roles at the same hiring company — blocked, surfaced as a manual conflict
- Recruiter edits an AI-drafted message before approving — is the edit logged/versioned; does it change future drafts for this candidate?
- Recruiter rejects (not edits) a recommended action — does Para AI drop it silently or attempt a revised recommendation?
- Approval-required action left unactioned past the timeout window — escalation reminder, no auto-send after timeout
- Bulk-approve flow — what the recruiter sees per item before a batch send; items still show full drafted content inline, never just a count
- Candidate withdraws from the process entirely — all tracks close, all queued actions across tracks cancelled
- Para AI surfaces a new opportunity match the recruiter did not initiate (from Paraform's broader matching layer) — treated identically to a recruiter-initiated submission: it only becomes an active tracked opportunity after explicit recruiter confirmation, shown in a distinct "Proposed by Para AI" section rather than mixed into active tracks
- Approval-required item now expands inline on its opportunity row instead of routing to a separate Action Queue — a recruiter's cross-candidate backlog of these across their whole book is a related but separate, unresolved concern (see open-questions.md)

## Responsive / Accessibility
- Not addressed in the PRD. Recruiter workflows are frequently mobile/on-the-go — needs an explicit scope call on whether mobile is in v1.
