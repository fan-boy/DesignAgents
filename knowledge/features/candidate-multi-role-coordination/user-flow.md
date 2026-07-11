## Scope note
Every step below operates within one recruiter's own profile of a candidate. Candidate profiles are owned per recruiter, not shared platform-wide — this flow does not span or reconcile across recruiters who may separately know the same real person.

## Entry points
- From a candidate search or list, the recruiter opens a candidate directly into the Command Center.
- From any single opportunity's own pipeline board, clicking a candidate who is active in more than one opportunity routes into the same shared Command Center record (never a duplicate, opportunity-scoped view).
- From a queue notification/badge, the recruiter opens the Action Queue directly.
- From a Para-AI-surfaced match notification, the recruiter opens the Command Center directly to the pending (unconfirmed) opportunity row.

## Happy path
1. Recruiter sources a candidate and creates their record; uploads a resume and pastes a LinkedIn URL. Both are parsed and default to Visible to Para AI.
2. Recruiter logs or syncs a call; it's transcribed and summarized. The item defaults to Private, and a one-tap "Share this with Para AI?" prompt appears once, inline, right after the summary appears.
3. Recruiter shares the call (or leaves it private) and adds a freeform note about the candidate's motivations.
4. Recruiter submits the candidate to two open opportunities (Role A, Role B). The Command Center now shows two parallel tracks. Separately, Para AI surfaces a third match (Role D) from its broader matching layer that the recruiter never chose — it appears as a pending, unconfirmed row, visually distinct from an active track, until the recruiter reviews and confirms or dismisses it.
5. Para AI synthesizes shared context into recommended next actions per opportunity: an auto-executable scheduling email for Role A, and a recruiter-approval-required "submit to Role B" draft citing the shared call note.
6. The scheduling email auto-sends and logs to the activity timeline. The submission draft lands in the Action Queue.
7. Recruiter opens the Action Queue, reviews the drafted submission note (with its source citation visible), edits one line, and approves it.
8. Both opportunity tracks advance stage (Role A to Interviewing, Role B to Submitted) and the Command Center reflects both without the recruiter navigating away from the candidate.
9. Role A results in an offer; recruiter manually updates that track to Offer and eventually Closed (hired). Role B is manually closed as no longer pursued once the candidate accepts elsewhere.

## Decision points
- **Is this action relationship-sensitive or high-stakes?** → Auto-executed (logistics, scheduling, status confirmations) vs. Recruiter-approval-required (submissions, rejections, compensation, anything sourced from a private item).
- **Is a context item marked Visible to Para AI?** → Included in Para AI's synthesized understanding and citable in recommendations, or excluded entirely.
- **Would an action create a same-company double submission?** → Blocked and surfaced to the recruiter as a manual conflict, never auto-executed.
- **Has an approval-required item sat past the review window?** → Escalated with a reminder in the queue; never auto-sent after timeout.
- **Did the recruiter or Para AI initiate this opportunity?** → Doesn't change the gate: either way, it only becomes an active Command Center track once the recruiter confirms it.

## System responses
- Resume parsing and call transcription run asynchronously; the relevant timeline item shows a pending state until complete, and a "needs review" flag if transcription confidence is low.
- Para AI's synthesized "what it currently understands" card updates whenever a source's visibility changes, and marks any recommendation whose source was later made private as stale.
- The Command Center reflects opportunity stage changes as they sync from each opportunity's own pipeline, with a visible sync-freshness indicator.
- The Action Queue flags items past the timeout window with a visible waiting-duration indicator.

## Edge cases
- **Candidate declines/is rejected from one opportunity while active in others:** that track closes; other tracks and their queued actions are unaffected — Para AI does not infer or propagate the outcome elsewhere.
- **A note or call is marked private after Para AI already used it:** the recommendation that cited it is flagged stale in the queue/log rather than silently kept or retracted.
- **Same-company double submission proposed:** blocked outright, surfaced in the Command Center conflict banner for manual resolution.
- **Approval-required item unactioned past the timeout:** escalated as a reminder; never silently auto-sent.
- **Low-confidence or failed transcript:** flagged "needs review" on the Context Timeline; excluded from Para AI's synthesized understanding until the recruiter confirms it.
- **Candidate withdraws entirely:** every active track closes, and any actions still sitting in the queue for that candidate are cancelled, not executed.
- **Para AI surfaces a match the recruiter didn't choose:** shown as a pending, unconfirmed row rather than an active track; the recruiter confirms or dismisses it before it ever behaves like a real opportunity.
- **The same real person is independently owned by another recruiter:** out of this flow's scope entirely — no cross-recruiter visibility, reconciliation, or duplicate-submission check happens here.

## Exit states
- **Success:** at least one opportunity reaches Closed (hired); other tracks close naturally as no longer pursued.
- **No hire:** all tracks eventually close without a placement; candidate record remains searchable/reusable for future opportunities.
- **Cancellation:** candidate withdraws mid-process; all tracks and queued actions close/cancel together.
- **Error/timeout:** an async step (transcription, sync) fails or an approval sits unresolved; both cases surface a visible flag rather than failing silently.
