## Problem framing

Recruiters and Para AI jointly manage a candidate who is active in multiple open roles at once. Today the context that makes a match good (why they're really leaving, what they'd thrive in, call color) lives outside the model, and status per role is tracked separately, forcing recruiters to re-derive the full picture from memory or scattered tabs. The design has to give Para AI enough reach to remove repetitive coordination work while keeping the recruiter in control of every relationship-sensitive decision — the whole feature is a series of answers to "where does Para act on its own, and where does it wait for the recruiter."

This is a design take-home for Paraform (not a Dune Security deliverable — no Stillsuit DS or Dune patterns apply; no competitor research was run, out of scope for this exercise). Everything lives on **one candidate's page**. Broader recruiter surfaces (home dashboard, candidates list, all-roles view) are the product *around* this feature and are explicitly out of scope.

**Success metrics (tied to the original HMW):**
1. Less recruiter time spent coordinating one candidate across roles.
2. Fewer opportunities go stale from missed follow-up.
3. Recruiters keep auto-execution on, not off.
4. Recruiters act on Para AI's recommendations more often than not.
5. Zero relationship-sensitive actions sent without recruiter approval.

**Where AI adds leverage:** synthesizing scattered calls/notes/resume into one legible picture; drafting repetitive low-stakes coordination; catching cross-opportunity conflicts a busy recruiter would miss (double-booked interviews, same-company submissions, an offer that changes the stakes elsewhere). **Where it gets in the way:** acting on relationship-sensitive moments without a human voice; making context-sharing feel like a one-way door; turning bulk approval into rubber-stamping. The design leans into the first and gates the second.

## Design goal

Give recruiters one place to see everything Para AI knows about a candidate, control what it's allowed to use, and direct its actions across every opportunity that candidate is in — without ever wondering what the AI already did on its own. The default view matches the recruiter's actual task (check status, take action), not a data-browsing detour.

## Key constraints

- The recruiter retains final say on any relationship-sensitive action (rejections, compensation, anything sourced from an excluded item). This is the load-bearing constraint, not a nice-to-have.
- Candidate profiles are owned per recruiter — real platform architecture, not a v1 simplification. This feature coordinates opportunities within one recruiter's own profile of a candidate; it does not reconcile or dedupe across recruiters, and there is no candidate-facing surface.
- Para AI's matching extends beyond opportunities the recruiter directly submitted to (a platform-wide layer). Any surfaced match is a scored recommendation only, active solely on recruiter confirmation.
- Para AI has no page of its own — it lives inline on the candidate page, attributed wherever it appears.
- Assumed available: on-platform calls with automatic recording/transcription, and reliable company-to-opportunity mapping (for same-company conflict detection). If either is weaker in reality, the auto-transcription and conflict-blocking pieces degrade to manual equivalents.
- Matching-inclusion defaults: resume/LinkedIn on; notes/calls off, with a one-tap "Include this in matching?" prompt at capture so inclusion isn't buried in settings.

## Strategy options

**Option A — Candidate record with opportunity tabs.** Opportunities as tabs within one page. *Rejected* — tabs show one opportunity at a time, preserving the exact fragmentation the brief is trying to solve.

**Option B — Opportunities view: candidate-centric parallel-track view (recommended).** One screen per candidate showing every active opportunity as a parallel track, each with its own stage, next action, and handling mode, all glanceable at once. Directly answers the brief's stated problem and gives Para AI a natural home for cross-opportunity reasoning (conflict detection, the cross-opportunity hold, prioritization).

**Option C — Opportunity-first, candidate as a cross-reference.** Recruiters keep working from each role's board; a drawer surfaces linked opportunities. *Rejected* — keeps the shared-candidate view secondary, undercutting the premise that the candidate is the right unit of coordination.

## Recommended strategy

Option B. The recruiter's pain point is reconstructing one candidate's picture from fragments; a view that makes every active opportunity glanceable in one place is the most direct response, and it's the only structure where Para AI can reason *across* opportunities (hold an action on Role B because Role A extended an offer) rather than only within each.

## Risks and tradeoffs

- **Depth vs. breadth on the main view.** A compact per-opportunity row can't show everything; mitigated by inline expansion rather than cramming detail into the row.
- **Assumes cross-opportunity data plumbing that may not exist yet.** Same-company conflict detection and a unified stage model need backend integration; if unavailable, conflict-blocking degrades to a soft manual warning.
- **Bulk-approve remains a genuine trust risk** even with a forced per-item preview — watch post-launch, don't assume the UI solves it.
- **The cross-candidate backlog is now uncovered.** Removing a standalone queue means an approval-required item is only as visible as its row. A recruiter's book-wide "everything waiting on me" view is a real need — but it lives on the home dashboard, which is out of this feature's scope. Flagged as a dependency, not solved here.

## Wireframe plan

The candidate page is three tabs (Opportunities, Activity, Profile) plus a persistent Ask Para assistant.

### Opportunities (default landing view)
- **Layout:** candidate identity header with three-tab nav (Opportunities default) — condensed "what Para AI understands" strip with a link into Profile — quick-capture (+ Add note / + Log call, inline) — cross-opportunity hold card when applicable — conflict banner when applicable — a distinct "Proposed by Para AI" section — the active-opportunity list (List default, Board toggle).
- **Key components:** per-opportunity row (company/role, stage tag, days-in-stage, last activity, next action with a persistent Auto / Needs-approval tag); inline-expandable approval card (draft + citation + Approve/Edit/Reject); scored proposed-match card (match score + rationale, Add to Pipeline / Dismiss); the **cross-opportunity hold card** (amber "waiting" treatment, the paused actions listed with their cross-opportunity cause, Keep paused / Resume all / Review each); conflict banner.
- **Primary action:** act on an opportunity — approve/edit/reject an inline draft, confirm/dismiss a proposed match, resolve a hold.
- **Edge cases:** zero active but a proposed match exists → still worth showing; true zero → empty state prompting a first submission; many opportunities → Board view.

### Activity + context intake
- **Layout:** tab nav — Schedule call / Add note actions — filter bar (**date range**, **company/opportunity**, **type**) — chronological log (newest first) of calls, notes, emails, stage changes, system events, each attributed to Para where relevant.
- **Call lifecycle:**
  - **Schedule (slide-in drawer):** two options — *propose specific times* (pick slots) or *send a booking link*; Para pre-fills an editable outreach message; send via **LinkedIn** or **email**. Candidate's booked time lands on the timeline automatically.
  - **Completed → review pending:** the call card enters a highlighted "Review pending" state with a Review call action.
  - **Review (slide-in drawer):** Para's transcript summary + full-transcript link; an **Use this call for Para AI** toggle (the per-call inclusion decision); Para-suggested **tags** (editable); optional context note; Save to timeline.
- **Context intake:** per-item **Include in matching** toggle (renamed from "Visible to Para AI" so the consequence is explicit); durable-vs-volatile distinction with a staleness flag + matching-weight discount on aging volatile items.

### Profile
- **Layout:** structured facts (title, location/remote, comp range) — **LinkedIn** (connected/fetched) — **resume upload history** (current + prior versions, upload-newer) — the full "What Para AI sees" panel with per-signal citations.

### Ask Para (assistant, persistent)
- **Launcher:** a floating action button on every tab.
- **Panel:** right slide-in, scoped to the current candidate; answers only from included-in-matching context; cited answers.
- **In-chat actions:** when asked to *do* something, Para renders an inline action card (e.g. a drafted call schedule with Confirm & send / Edit) — the same approval gate as everywhere else, so the assistant can take action, not just answer.

### Cross-cutting requirements
- The Auto vs. Recruiter-approval distinction uses one consistent tag treatment everywhere an action or its status appears — opportunity row, inline-expanded state, Ask Para action cards, activity log. A recruiter is never surprised by something that already happened.
- Para AI is always attributed (persistent "Para AI active" indicator + labeled tags on its output) since it has no page of its own.
- If a context item reads as "stale" in the UI, Para's matching logic must already be discounting it comparably — a staleness indicator not backed by real weighting misleads the recruiter, the same trust failure as a false "undo."
- The cross-opportunity hold and the per-call review toggle are the two places the act-vs-wait boundary is dramatized rather than asserted — keep both legible.

## Open issues
- Whether on-platform call transcription and company-to-opportunity mapping genuinely exist reliably enough to support the auto-transcription and conflict-detection assumed here.
- Whether the one-tap include prompt at capture is enough to counter under-sharing, or whether Para needs a periodic nudge ("3 unshared notes on an active candidate").
- Whether Paraform does any identity resolution across independently-owned recruiter profiles — without it, the same candidate could be submitted to the same role by two recruiters, undetectable from within one recruiter's page.
- Whether Para AI's platform-wide matching reliably routes every surfaced match through the recruiter-confirmation gate, or whether that's an unconfirmed assumption.
- Whether a flat 60-90 day staleness threshold fits all volatile context or should vary by fact type.
- The cross-candidate "needs your review" backlog: real need, but it belongs on the (out-of-scope) home dashboard — a dependency to resolve at the product level, not within this feature.

## Next design actions
1. Pressure-test the Opportunities row + inline approval + cross-opportunity hold as one system — they share the act-vs-wait tag language and must stay consistent.
2. Decide whether Board (kanban) view needs its own full wireframe or stays a stated capability.
3. Confirm the 60-90 day staleness threshold against real usage rather than treating it as final.

---
*Revision history: written 2026-07-11 (per-recruiter scoping; Opportunities-as-landing IA; inline approval; durable-vs-volatile context). Refocused 2026-07-14 onto the candidate page only — home/candidates-list/all-opportunities dashboards dropped from scope — and expanded with the Activity tab + call lifecycle (schedule → review with the per-call Para toggle), scored recommended opportunities, the cross-opportunity hold, and the Ask Para assistant with in-chat actions.*
