## Scope note
There is one shared candidate record per person (confirmed with Paraform). This flow is about how a recruiter coordinates the opportunities **they personally submitted** the candidate to, entirely on the candidate page. Every submission originates from a recruiter's action and consent — Para AI recommends but never auto-submits. Cross-recruiter duplicate submission is platform-prevented and out of scope. Broader recruiter surfaces (home dashboard, candidates list, all-roles view) are out of scope. The private / include-in-matching control used below is a new distinction this design proposes (Paraform has no such control today).

## IA note
The candidate page has three tabs — **Opportunities** (default landing: status, next actions, proposed matches, cross-opportunity holds), **Activity** (chronological log + context intake + the call lifecycle), and **Profile** (structured facts, LinkedIn, resume history) — plus a persistent **Ask Para** assistant reachable from a floating launcher on every tab. There is no separate Action Queue; approval-required items expand inline on their opportunity row.

## Entry points
- From a candidate search or list, the recruiter opens a candidate directly into Opportunities.
- From any single role's own pipeline board, clicking a candidate active in more than one opportunity routes into this same shared Opportunities view (never a duplicate, opportunity-scoped view).
- From a Para-AI-surfaced match notification, the recruiter opens Opportunities to the pending "Proposed by Para AI" row.

## Happy path
1. Recruiter adds a candidate; uploads a resume and pastes a LinkedIn URL from Profile. Both parse and default to Included in matching. The resume upload history keeps prior versions as newer ones are added.
2. Recruiter schedules a call from Activity: a slide-in drawer offers two options — propose specific time slots, or send a booking link. Para pre-fills an editable message; the recruiter sends it via LinkedIn or email. When the candidate picks a time, the call lands on the Activity timeline automatically.
3. The call happens on-platform and is recorded + transcribed. Afterward its Activity card enters a "Review pending" state.
4. Recruiter opens the review drawer: reads Para's transcript summary, decides the **Use this call for Para AI** toggle, edits Para's suggested tags, adds an optional context note, and saves it to the timeline. (Notes work the same way — captured with a one-tap "Include in matching?" prompt.)
5. Recruiter submits the candidate to two open opportunities (Role A, Role B) from Opportunities; the view now shows two active tracks. Separately, Para AI surfaces a scored match (Role D, e.g. "Strong match · 8/10") the recruiter never chose, in a distinct "Proposed by Para AI" section.
6. Recruiter confirms or dismisses the proposed match. Only on confirm does it become an active track — the same gate as a recruiter-initiated submission.
7. Para AI synthesizes included-in-matching context into a recommended next action per opportunity: an auto-executable scheduling nudge for Role A, and an approval-required "submit to Role B" draft citing the shared call.
8. The auto action executes and logs; the approval-required draft expands inline within Role B's row. The recruiter reviews it there (source citation visible), edits a line, and approves — no separate destination.
9. Both tracks advance stage and Opportunities reflects both without the recruiter leaving the candidate.
10. At any point the recruiter opens **Ask Para** to ask about the candidate ("what's she looking for," "when did we last follow up," "who's a good fit") — answered from included-in-matching context, with citations — or to *act*: asking Para to "set up the Fieldnote intro" renders an inline action card (drafted schedule, Confirm & send / Edit), gated like every other action.
11. Role A extends an offer with an expiry. Para AI **pauses its queued auto-actions on the other opportunities** and surfaces a "paused · waiting on you" card explaining why; the recruiter resumes or keeps them paused.
12. Months later, the call from step 4 ages past the staleness threshold; it's flagged for reconfirmation in Activity/Context and Para's matching weight for it is discounted until reconfirmed.
13. Role A closes as Hired; other tracks close as no longer pursued.

## Decision points
- **Is this action relationship-sensitive or high-stakes?** → Auto-executed (logistics, scheduling, status) vs. Recruiter-approval-required (submissions, rejections, compensation, anything sourced from excluded content). This split isn't fixed — it's the recruiter's Para AI Permissions setting for this action (recruiter-level default, optionally overridden for this candidate), reached from a settings control on the Para AI summary strip. Relationship-sensitive actions are permanently locked to Ask-first regardless of setting.
- **Is a context item included in matching?** → Usable by Para AI in synthesis, recommendations, and proposed matches, or excluded entirely.
- **Is a context item durable or volatile?** → Durable never goes stale; volatile gets a staleness flag past a set age and a discounted matching weight.
- **Does a state change in one opportunity affect the others?** → e.g. an offer at Role A → Para pauses its own queued actions on Role B/C and waits for the recruiter, rather than firing them.
- **Would an action create a same-company double submission?** → Blocked, surfaced as a manual conflict, never auto-executed.
- **Has an approval-required item sat past the review window?** → Escalated with a reminder on its row; never auto-sent.
- **Did the recruiter or Para AI initiate this opportunity?** → Doesn't change the gate: active only once the recruiter confirms.

## System responses
- Resume parsing and call transcription run asynchronously; the relevant item shows a pending state, and a "needs review" flag if transcription confidence is low.
- Para AI's "what it currently understands" — full panel on Profile, condensed strip on Opportunities — updates whenever a source's matching-inclusion changes, and marks any recommendation whose source was later excluded as stale.
- Opportunities reflects stage changes as they sync from each role's pipeline, with a visible sync-freshness indicator.
- An approval-required item past its timeout shows a waiting-duration indicator on its row.
- A volatile context item past the staleness threshold shows a reconfirm prompt; durable items never do.
- Ask Para answers only from included-in-matching context and cites its sources; requested actions come back as approval-gated action cards, not silent sends.

## Edge cases
- **Candidate declines/is rejected from one opportunity while active in others:** that track closes; other tracks and their pending actions are unaffected — no cross-opportunity inference.
- **An offer arrives at one opportunity while others are mid-process:** Para pauses its queued auto-actions on the others and waits; the recruiter resumes or keeps paused — nothing auto-sends.
- **A note or call is excluded from matching after Para used it:** the recommendation that cited it is flagged stale rather than silently kept or retracted.
- **Same-company double submission proposed:** blocked, surfaced in the conflict banner for manual resolution.
- **Approval-required item unactioned past the timeout:** escalated on its row; never silently auto-sent.
- **Low-confidence or failed transcript:** flagged "needs review"; excluded from Para's understanding until the recruiter confirms.
- **Candidate withdraws entirely:** every active track closes; all pending actions across tracks are cancelled.
- **Para AI surfaces a match the recruiter didn't choose:** shown in the distinct Proposed section with a match score; confirmed or dismissed before it behaves like a real opportunity.
- **Two recruiters, same candidate, same role:** platform-prevented (the second recruiter can't submit to a taken role) and out of scope to design here — not something this flow has to handle.
- **A volatile item ages past the staleness threshold:** flagged for reconfirmation; a durable item never is.

## Exit states
- **Success:** at least one opportunity reaches Closed (hired); other tracks close naturally.
- **No hire:** all tracks close without a placement; the candidate record stays searchable/reusable.
- **Cancellation:** candidate withdraws mid-process; all tracks and pending actions close/cancel together.
- **Error/timeout:** an async step (transcription, sync) fails or an approval sits unresolved; both surface a visible flag on the relevant row rather than failing silently.
