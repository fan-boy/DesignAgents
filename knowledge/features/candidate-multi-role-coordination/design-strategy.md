## Feature context
Recruiters and Para AI jointly manage a candidate who is active in multiple open roles at once. Today that context (why they're really leaving, what they'd thrive in, call color) lives outside the model, and status per role is tracked separately, forcing recruiters to re-derive the full picture from memory or scattered tabs. This strategy is written for a design take-home exercise for Paraform and is not a Dune Security deliverable — no Stillsuit DS references or Dune-specific patterns apply. No competitor research was run for this feature (explicitly out of scope for this exercise).

**Update (2026-07-11):** further product research surfaced that candidate profiles on Paraform are owned per recruiter — the same real person can exist as an independent, unlinked profile in another recruiter's own book, and Para AI's matching reach can extend to opportunities the recruiter hasn't directly pursued. This is folded in below as a scoping clarification (the strategy still holds; "one candidate" now explicitly means "one recruiter's own record of a candidate") rather than a change of direction. See Open issues for what's still unconfirmed.

**Success metrics (finalized, tied to the original HMW):**
1. Less recruiter time spent coordinating one candidate across roles.
2. Fewer opportunities go stale from missed follow-up.
3. Recruiters keep auto-execution on, not off.
4. Recruiters act on Para AI's recommendations more often than not.
5. Zero relationship-sensitive actions sent without recruiter approval.

## Design goal
Give recruiters one place to see everything Para AI knows about a candidate, control what it's allowed to know, and direct its actions across every opportunity that candidate is in — without ever having to wonder what the AI already did on its own.

## Key constraints
- The recruiter must retain final say on any relationship-sensitive action (rejections, compensation, anything sourced from a private note) — this is the load-bearing constraint the entire feature is built around, not a nice-to-have.
- No existing design system to build against (unlike Dune's Stillsuit DS v2) — wireframes reference generic interaction patterns (list, drawer, modal, table, tag/badge, review inbox) and flag anything that would need a real DS review.
- Scope decisions made to keep this tractable as a take-home: no candidate-facing surface (candidate is always the subject, never a user of this system), and single-recruiter ownership per candidate — now understood as a reflection of real platform architecture (candidate profiles are independently owned per recruiter, not shared across recruiters), not just a v1 simplification. This feature coordinates opportunities within one recruiter's own profile of a candidate; it does not reconcile or dedupe across recruiters who may separately know the same person.
- Para AI's matching is assumed to extend beyond opportunities the recruiter has directly submitted the candidate to (a broader, platform-wide matching layer). Any such surfaced match is a recommendation only — it becomes an active Command Center track solely on recruiter confirmation, the same gate as a recruiter-initiated submission.
- Assumed as available: reliable company-to-opportunity mapping (for same-company conflict detection) and an existing call-recording sync/transcription integration. If either doesn't actually exist, this strategy's auto-detection and auto-transcription pieces degrade to manual-entry equivalents.
- Visibility defaults: resume/LinkedIn default Visible to Para AI (low-sensitivity, largely public data already). Notes and calls default Private, with a one-tap "Share this with Para AI" prompt surfaced right when the item is captured — this is the mechanism meant to prevent the feature from starving the model of context just because sharing was buried in a settings toggle nobody visits.

## Strategy options

**Option A — Candidate record with opportunity tabs.** One candidate page, opportunities as tabs/sub-navigation within it. Familiar, low-effort pattern. *Rejected because* tabs only ever show one opportunity at a time — the exact fragmentation the brief is trying to solve (recruiter can't see status across roles at a glance) persists, just inside one page instead of across several.

**Option B — Command Center: candidate-centric parallel-track dashboard.** One screen per candidate showing every active opportunity as a parallel horizontal track, each with its own stage, next action, and handling mode, all visible without switching context. *Recommended* — directly answers the brief's stated problem (confidently manage one candidate across multiple roles) by making the cross-role picture the default view rather than something assembled by clicking around.

**Option C — Opportunity-first, candidate as a cross-reference.** Recruiters keep working primarily from each role's own pipeline board; a "this candidate is also in..." panel surfaces linked opportunities as a drawer. *Rejected because* it preserves too much of the status quo — the shared-candidate view stays secondary, which undercuts the whole premise that the candidate (not the role) is the right unit of coordination when someone's in multiple processes.

## Recommended strategy
Option B, the Command Center. The recruiter's actual pain point, as described in the brief, is needing to reconstruct one candidate's full picture from fragments; a dashboard that makes every active opportunity glanceable in one place is the most direct response to that, and it gives Para AI a natural home for cross-opportunity reasoning (conflict detection, prioritization) that a tabbed or role-first structure would make awkward to surface.

## Risks and tradeoffs
- **Depth vs. breadth on the main screen.** A compact per-opportunity row can't show everything a recruiter might want mid-process. Mitigated by making each row expand into a detail drawer rather than trying to cram detail into the row itself.
- **Assumes cross-opportunity data plumbing that may not exist yet.** Same-company conflict detection and a unified stage model across opportunities require more backend integration than Option A or C would need. If that data isn't reliably available, this strategy's conflict-blocking behavior would need to degrade to a manual recruiter check with a soft warning instead of a hard block.
- **Bulk-approve remains a genuine trust risk even with mitigation.** Requiring an expandable preview per item in bulk mode reduces but doesn't eliminate the risk of recruiters skimming past drafted content — this should be watched post-launch, not assumed solved by the UI alone.

## Wireframe plan

### Screen 1 — Candidate Record: Context Timeline
- **Layout:** Header (candidate identity, source, active-opportunity count as a summary tag) — Body (chronological timeline, main column) — Right rail ("What Para AI currently understands about this candidate," a synthesized card with each point linked to its source item).
- **Key components:** timeline list, per-item visibility pill (Visible to Para AI / Private), inline one-tap share prompt (appears once per new note/call, dismissible), synthesized-understanding card.
- **Primary action:** add a context item (upload resume, paste LinkedIn URL, log/sync a call, write a note).
- **Secondary actions:** toggle visibility on any single item; open full transcript/note; jump to Command Center.
- **System content:** parsing/sync-in-progress state per item, "needs review" flag on low-confidence transcripts.
- **Edge cases:** empty timeline (candidate just sourced, no context yet) shows an empty state prompting first upload; a source marked private after Para AI already used it is flagged stale on the synthesized card, not silently dropped.

### Screen 2 — Command Center: Multi-Opportunity View
- **Layout:** Header (candidate identity strip, link back to Context Timeline, conflict banner when applicable) — Body (parallel horizontal tracks, one row per active opportunity).
- **Key components:** per-opportunity row (company/role, stage tag, days-in-stage, last activity, next recommended action with a persistent Auto / Needs your approval tag), conflict banner, sync-freshness indicator, a distinct "Para AI proposed this" row style for a surfaced-but-unconfirmed match (visually separate from an active track, since it isn't one yet).
- **Primary action:** click a row to open its detail drawer (fuller history, actions specific to that opportunity).
- **Secondary actions:** add candidate to a new opportunity; close/archive a track; confirm or dismiss a Para-AI-proposed match before it becomes an active track.
- **System content:** default sort by most-urgent-first (stage age, upcoming deadlines).
- **Edge cases:** zero opportunities shows an empty state ("not yet submitted anywhere"); a single opportunity still renders as a one-row track rather than switching to a different layout, so the mental model never changes shape; 8-10+ opportunities collapse into a scrollable, sortable list rather than growing the page indefinitely.

### Screen 3 — Para AI Action Queue
- **Layout:** Header (queue count, filter by opportunity/urgency) — Body (list of pending items).
- **Key components:** per-item card (candidate + opportunity context, the actual drafted content, a citation back to the source that generated it, Approve / Edit / Reject), bulk-select mode with an expandable per-item preview strip (never a collapsed "5 items selected" with no visible content).
- **Primary action:** Approve, Edit, or Reject an item; Approve Selected in bulk mode only after each selected item's draft has been shown, not just counted.
- **Secondary actions:** snooze/defer an item.
- **System content:** escalation flag on items past the review-timeout window (e.g., "waiting 2 days").
- **Edge cases:** empty queue state ("nothing needs your review right now"); an item whose source was made private after generation is flagged and requires explicit confirm-or-discard rather than a silent approve.

### Cross-cutting requirement
The Auto-executed vs. Recruiter-approval-required distinction must use one consistent tag/label treatment everywhere an action or its status appears — Command Center rows, Action Queue cards, and any activity log — so a recruiter is never in a position to be surprised by something that already happened. This now explicitly includes new-opportunity actions: whether the recruiter or Para AI initiated a new opportunity, it is always Recruiter-approval-required before it becomes an active track — never a special case.

## Open issues
- Whether company-to-opportunity mapping and call-sync integration genuinely exist reliably enough to support the conflict-detection and auto-transcription assumed here.
- Whether the one-tap share prompt at capture-time is enough to counter under-sharing, or whether Para AI needs a periodic nudge ("you have 3 unshared notes on an active candidate") — deferred as a v2 consideration.
- Whether Paraform performs any identity resolution across independently-owned recruiter profiles for the same real person — without it, the same candidate could be submitted to the same role twice by two different recruiters, and this feature has no way to detect or prevent that from within one recruiter's Command Center.
- Whether Para AI's platform-wide matching reach (surfacing opportunities the recruiter didn't choose) reliably routes through the same recruiter-confirmation gate as a recruiter-initiated submission, or whether that's an assumption this design is making without confirmation.

## Next design actions
1. Sketch the Command Center row anatomy first — it's the screen every other decision (queue design, timeline design) takes its cues from.
2. Design the Action Queue's bulk-approve interaction carefully; it's the single highest-risk interaction in the feature from a trust standpoint.
3. Write the exact tag taxonomy (label + color logic) for Auto vs. Approval-required before laying out any screen, so it's applied consistently rather than retrofitted.
