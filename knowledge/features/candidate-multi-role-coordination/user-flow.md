## Scope note
Every step below operates within one recruiter's own profile of a candidate. Candidate profiles are owned per recruiter, not shared platform-wide — this flow does not span or reconcile across recruiters who may separately know the same real person.

## IA note (2026-07-11 refinement)
The candidate page has two views: **Opportunities** (default landing — status and next actions, including any Para-AI-surfaced proposed matches) and **Profile & Context** (secondary, on-demand — structured facts plus the chronological, visibility-controlled evidence timeline). There is no separate Action Queue destination; approval-required items expand inline within their opportunity row on Opportunities.

## Entry points
- From a candidate search or list, the recruiter opens a candidate directly into Opportunities — never Profile or Context first.
- From any single opportunity's own pipeline board, clicking a candidate who is active in more than one opportunity routes into the same shared Opportunities view (never a duplicate, opportunity-scoped view).
- From a Para-AI-surfaced match notification, the recruiter opens Opportunities directly to the pending "Proposed by Para AI" row.
- A recruiter's cross-candidate backlog (approval-required items across every candidate they own) is a separate, global entry point outside this flow's scope — see design-strategy.md.

## Happy path
1. Recruiter sources a candidate and creates their record; uploads a resume and pastes a LinkedIn URL from Profile & Context. Both are parsed and default to Included in matching.
2. Recruiter logs or syncs a call; it's transcribed and summarized. The item defaults to excluded from matching, and a one-tap "Include this in matching?" prompt appears once, inline, right after the summary appears. This same quick-capture entry point (+ Log call, + Add note) is also reachable directly from Opportunities, so the recruiter doesn't have to leave the landing view just to log something.
3. Recruiter includes the call in matching (or leaves it excluded) and adds a freeform note about the candidate's motivations.
4. Recruiter submits the candidate to two open opportunities (Role A, Role B) from Opportunities. The view now shows two active tracks. Separately, Para AI surfaces a third match (Role D) from its broader matching layer that the recruiter never chose — it appears in a distinct "Proposed by Para AI" section, not mixed into the active list, until the recruiter reviews and confirms or dismisses it.
5. Para AI synthesizes included-in-matching context into recommended next actions per opportunity: an auto-executable scheduling email for Role A, and a recruiter-approval-required "submit to Role B" draft citing the shared call note.
6. The scheduling email auto-sends and logs to the activity timeline. The submission draft expands inline within Role B's own row on Opportunities — no separate destination to visit.
7. Recruiter reviews the drafted submission note right there in the row (with its source citation visible), edits one line, and approves it.
8. Both opportunity tracks advance stage (Role A to Interviewing, Role B to Submitted) and Opportunities reflects both without the recruiter navigating away from the candidate or the row.
9. Months later, the call note from step 2 ages past the staleness threshold; it's flagged for reconfirmation in Context, and Para AI's matching weight for that signal is discounted until the recruiter reconfirms or updates it.
10. Role A results in an offer; recruiter manually updates that track to Offer and eventually Closed (hired). Role B is manually closed as no longer pursued once the candidate accepts elsewhere.

## Decision points
- **Is this action relationship-sensitive or high-stakes?** → Auto-executed (logistics, scheduling, status confirmations) vs. Recruiter-approval-required (submissions, rejections, compensation, anything sourced from content excluded from matching).
- **Is a context item included in matching?** → Included in Para AI's synthesized understanding and citable in recommendations and new-match proposals, or excluded entirely.
- **Is a context item durable or volatile?** → Durable (resume, tenure) never goes stale. Volatile (stated preferences, comp, timing) gets a staleness flag past a set age, and a discounted matching weight to match.
- **Would an action create a same-company double submission?** → Blocked and surfaced to the recruiter as a manual conflict, never auto-executed.
- **Has an approval-required item sat past the review window?** → Escalated with a reminder shown directly on the opportunity row; never auto-sent after timeout.
- **Did the recruiter or Para AI initiate this opportunity?** → Doesn't change the gate: either way, it only becomes an active track once the recruiter confirms it.

## System responses
- Resume parsing and call transcription run asynchronously; the relevant timeline item shows a pending state until complete, and a "needs review" flag if transcription confidence is low.
- Para AI's synthesized "what it currently understands" panel — full version on Profile & Context, condensed strip on Opportunities — updates whenever a source's matching-inclusion changes, and marks any recommendation whose source was later excluded as stale.
- Opportunities reflects stage changes as they sync from each opportunity's own pipeline, with a visible sync-freshness indicator.
- An approval-required item past its timeout window shows a visible waiting-duration indicator directly on its row.
- A volatile context item past the staleness threshold shows a reconfirm prompt in Context; durable items never do.

## Edge cases
- **Candidate declines/is rejected from one opportunity while active in others:** that track closes; other tracks and their pending actions are unaffected — Para AI does not infer or propagate the outcome elsewhere.
- **A note or call is excluded from matching after Para AI already used it:** the recommendation that cited it is flagged stale rather than silently kept or retracted.
- **Same-company double submission proposed:** blocked outright, surfaced in the Opportunities conflict banner for manual resolution.
- **Approval-required item unactioned past the timeout:** escalated as a reminder on its row; never silently auto-sent.
- **Low-confidence or failed transcript:** flagged "needs review" in Context; excluded from Para AI's synthesized understanding until the recruiter confirms it.
- **Candidate withdraws entirely:** every active track closes, and any pending actions for that candidate are cancelled, not executed.
- **Para AI surfaces a match the recruiter didn't choose:** shown in the distinct Proposed section, never mixed into active tracks; the recruiter confirms or dismisses it before it ever behaves like a real opportunity.
- **The same real person is independently owned by another recruiter:** out of this flow's scope entirely — no cross-recruiter visibility, reconciliation, or duplicate-submission check happens here.
- **A volatile item ages past the staleness threshold:** flagged for reconfirmation; a durable item never is, regardless of age.

## Exit states
- **Success:** at least one opportunity reaches Closed (hired); other tracks close naturally as no longer pursued.
- **No hire:** all tracks eventually close without a placement; candidate record remains searchable/reusable for future opportunities.
- **Cancellation:** candidate withdraws mid-process; all tracks and pending actions close/cancel together.
- **Error/timeout:** an async step (transcription, sync) fails or an approval sits unresolved; both cases surface a visible flag on the relevant row rather than failing silently.
