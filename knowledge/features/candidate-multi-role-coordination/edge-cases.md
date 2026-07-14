# Edge Cases — Candidate Multi-Role Coordination

## System states
- Resume upload parsing in progress / parsing failed (unreadable file, unsupported format); prior resume versions retained in upload history
- Call scheduled but candidate hasn't booked yet; booking link expires unused → prompt to resend
- Call completed → "Review pending" state on its Activity card until the recruiter reviews it
- On-platform call recording fails to transcribe or produces a low-confidence transcript
- ATS/pipeline sync lag or failure between an opportunity's own pipeline and the unified Opportunities view

## Permission states
- No role above Recruiter currently defined (no team lead/admin visibility into other recruiters' candidates)
- View-only or read-only access to a candidate record when a recruiter is covering for a colleague
- Recruiter changes their default Para AI permissions after per-candidate overrides already exist elsewhere — overridden candidates keep their overrides; open question whether that should also surface a "defaults changed" notice (see open-questions.md)
- Every action's permission is set to Off — Para AI degrades to a read-only summarizer for that candidate; this should be stated plainly in the UI, not implied
- A recruiter attempts to set a relationship-sensitive action (submission, rejection/withdrawal, comp/offer messaging) to Auto — not offered as an option; Ask first is the only non-Off state for these, enforced by the system

## Content states
- Candidate sourced but not yet submitted to any opportunity (zero-opportunity empty state)
- Candidate with only one active opportunity — does the multi-track UI still render, or collapse to a single-pipeline view?
- Candidate active in a high number of opportunities (8-10+) — this is the threshold where the List view's default toggles to Board (grouped by stage) rather than an unresolved scaling question
- A note or call recording is marked excluded from matching after Para AI already used it in a recommendation
- Two recruiters, same candidate, same role — platform-prevented (the second recruiter can't submit to a taken role); out of scope to design here, confirmed with Paraform. There is one shared candidate record, not per-recruiter silos.
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
- Para AI surfaces a new opportunity match the recruiter did not initiate (from Paraform's broader matching layer) — treated identically to a recruiter-initiated submission: it only becomes an active tracked opportunity after explicit recruiter confirmation, shown in a distinct "Proposed by Para AI" section with a match score, never mixed into active tracks
- One opportunity extends an offer while others are mid-process — Para AI pauses its own queued auto-actions on the other opportunities (follow-up nudges, scheduling reminders) and surfaces a "paused · waiting on you" card; the recruiter keeps paused / resumes all / reviews each — nothing auto-sends while a hold is active
- Recruiter asks Para to take an action from the Ask Para chat (e.g. schedule a call) — Para returns an inline action card behind the same approval gate (Confirm & send / Edit), never a silent send
- Approval-required item now expands inline on its opportunity row instead of routing to a separate Action Queue — a recruiter's cross-candidate backlog across their whole book belongs on an out-of-scope home dashboard (see open-questions.md)

## Responsive / Accessibility
- Not addressed in the PRD. Recruiter workflows are frequently mobile/on-the-go — needs an explicit scope call on whether mobile is in v1.
