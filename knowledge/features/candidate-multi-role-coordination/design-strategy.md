## Feature context
Recruiters and Para AI jointly manage a candidate who is active in multiple open roles at once. Today that context (why they're really leaving, what they'd thrive in, call color) lives outside the model, and status per role is tracked separately, forcing recruiters to re-derive the full picture from memory or scattered tabs. This strategy is written for a design take-home exercise for Paraform and is not a Dune Security deliverable — no Stillsuit DS references or Dune-specific patterns apply. No competitor research was run for this feature (explicitly out of scope for this exercise).

**Update (2026-07-11):** further product research surfaced that candidate profiles on Paraform are owned per recruiter — the same real person can exist as an independent, unlinked profile in another recruiter's own book, and Para AI's matching reach can extend to opportunities the recruiter hasn't directly pursued. This is folded in below as a scoping clarification (the strategy still holds; "one candidate" now explicitly means "one recruiter's own record of a candidate") rather than a change of direction. See Open issues for what's still unconfirmed.

**Update (2026-07-11, IA refinement):** reworked the information architecture based on design review. Three changes: (1) Para AI's presence moves from a separate destination into the surfaces recruiters already use — the standalone Action Queue is gone, approval-required items now expand inline within their opportunity row. (2) The candidate page's default landing view is Opportunities, not Profile or Context — checking status and taking action is the dominant recruiter task, browsing candidate data is secondary and on-demand. (3) Profile (structured, scannable facts) and Context (the chronological, visibility-controlled evidence timeline) are now explicitly separate concerns that had been conflated into one screen. Wireframe plan below reflects all three.

**Success metrics (finalized, tied to the original HMW):**
1. Less recruiter time spent coordinating one candidate across roles.
2. Fewer opportunities go stale from missed follow-up.
3. Recruiters keep auto-execution on, not off.
4. Recruiters act on Para AI's recommendations more often than not.
5. Zero relationship-sensitive actions sent without recruiter approval.

## Design goal
Give recruiters one place to see everything Para AI knows about a candidate, control what it's allowed to know, and direct its actions across every opportunity that candidate is in — without ever having to wonder what the AI already did on its own. The default view a recruiter lands on should match the task they're actually there to do (check status, take action) rather than forcing a detour through profile or context data first.

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

### Screen 1 — Opportunities (candidate landing view, default)
- **Layout:** Header (candidate identity, a two-way nav — Opportunities / Profile & Context — with Opportunities always the default) — quick-insight strip (condensed synthesis of what Para AI currently understands, plus a "View full context →" link) — quick-capture row (+ Add note / + Log call, opens an inline panel rather than navigating away) — conflict banner when applicable — a distinct "Proposed by Para AI" section for surfaced-but-unconfirmed matches — the active-opportunity list, List view by default with a Board (grouped-by-stage) view available as a toggle.
- **Key components:** quick-insight strip, quick-capture entry points, proposed-match card (visually distinct from an active track — Confirm / Dismiss, not Approve/Edit/Reject), per-opportunity row (company/role, stage tag, days-in-stage, last activity, next recommended action with a persistent Auto / Needs your approval tag), inline-expandable approval card (drafted content, citation, Approve / Edit / Reject — appears within the row itself, not on a separate screen), List/Board view toggle, conflict banner, sync-freshness indicator.
- **Primary action:** act on an opportunity — approve/edit/reject an inline drafted action, or confirm/dismiss a proposed match.
- **Secondary actions:** quick-add a note or call without leaving the page; switch to Profile & Context; toggle List/Board view; manually add the candidate to a new opportunity; close/archive a track.
- **System content:** default sort by most-urgent-first (stage age, upcoming deadlines); escalation flag on approval-required items past the review window, shown directly on the row.
- **Edge cases:** zero active opportunities but a proposed match exists — the landing view still has something worth showing, not a hard empty state; true zero-everything shows an empty state prompting a first submission; 8-10+ opportunities is the point at which Board view (grouped by stage) becomes the more legible choice — this is the answer to what was previously an open scaling question, not a separate unresolved problem.

### Screen 2 — Profile & Context (secondary view, on-demand)
- **Layout:** Header (same nav, Profile & Context active) — Profile summary block (name, title, location/remote preference, comp range, resume and LinkedIn links — structured, scannable facts, not chronological) — Context timeline below (chronological, newest-first) — full "What Para AI sees" panel with per-signal citations (the detailed counterpart to the landing page's condensed strip).
- **Key components:** profile summary card, timeline list, per-item "Include in matching" toggle (renamed from "Visible to Para AI" so the toggle's actual consequence — whether Para AI can use this signal when proposing new opportunities — is explicit rather than implied), a staleness indicator on aging **volatile** context (stated preferences, comp expectations, timing — things that can genuinely go out of date), synthesized-understanding card.
- **Primary action:** add or edit a context item.
- **Secondary actions:** toggle a context item's matching inclusion; reconfirm a stale item; open a full transcript or note.
- **System content:** parsing/sync-in-progress state per item; "needs review" flag on low-confidence transcripts; staleness threshold for volatile items (proposed default: 60-90 days, to be confirmed against real usage rather than treated as final).
- **Edge cases:** empty timeline (candidate just sourced, no context yet) shows an empty state prompting first upload; a source marked private after Para AI already used it is flagged stale on the synthesized card, not silently dropped; **durable** facts (resume history, tenure) are never shown as stale regardless of age — only preference-like signals decay.

### Cross-cutting requirements
- The Auto-executed vs. Recruiter-approval-required distinction must use one consistent tag/label treatment everywhere an action or its status appears — the Opportunities row, its inline-expanded state, and any activity log — so a recruiter is never in a position to be surprised by something that already happened. This includes new-opportunity actions: whether the recruiter or Para AI initiated it, entering an active track is always Recruiter-approval-required, never a special case.
- If a context item is shown as "stale" in the UI, Para AI's actual matching logic must already be discounting it by a comparable amount — a staleness indicator that doesn't correspond to real signal-weighting underneath would mislead the recruiter about what the model is actually using, the same trust failure as a false "undo."

## Global surface (related, out of per-candidate scope)
A recruiter's cross-candidate backlog — every approval-required item across every candidate they own, not just this one — still needs a single entry point; removing the per-candidate Action Queue doesn't remove that need. Proposed direction: a lightweight "Needs your review (N)" notification affordance in the main app navigation, not a heavy dedicated destination like the current product's separate ParaAI page. Not wireframed here — this candidate-level design only covers the per-candidate inline surfacing.

## Open issues
- Whether company-to-opportunity mapping and call-sync integration genuinely exist reliably enough to support the conflict-detection and auto-transcription assumed here.
- Whether the one-tap share prompt at capture-time is enough to counter under-sharing, or whether Para AI needs a periodic nudge ("you have 3 unshared notes on an active candidate") — deferred as a v2 consideration.
- Whether Paraform performs any identity resolution across independently-owned recruiter profiles for the same real person — without it, the same candidate could be submitted to the same role twice by two different recruiters, and this feature has no way to detect or prevent that from within one recruiter's Opportunities view.
- Whether Para AI's platform-wide matching reach (surfacing opportunities the recruiter didn't choose) reliably routes through the same recruiter-confirmation gate as a recruiter-initiated submission, or whether that's an assumption this design is making without confirmation.
- Whether a flat 60-90 day staleness threshold is right for all volatile context, or whether different fact types (comp floor vs. location preference vs. reason for leaving) should decay at different rates.
- What the global cross-candidate "needs your review" surface should actually be — notification bell, dedicated inbox, something else — a real next step but outside this candidate-level design.

## Next design actions
1. Sketch the Opportunities row anatomy with its inline-expanded approval state first — one row now carries what used to be split across two screens (Command Center + Action Queue).
2. Design the List/Board view toggle and the proposed-match card treatment before finalizing row anatomy, since both change what a row needs to support.
3. Write the exact tag taxonomy (Auto / Needs approval / Proposed / Stale) before laying out any screen, so it's applied consistently rather than retrofitted.
