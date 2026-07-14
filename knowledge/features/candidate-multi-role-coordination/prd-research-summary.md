### Feature summary
Candidate Multi-Role Coordination lets a Recruiter and Para AI jointly manage one candidate across every opportunity they're active in, covering context intake (resume, LinkedIn, calls, notes with per-item visibility control) and a unified pipeline view where Para AI recommends and, within bounds, executes actions. The primary user is the Recruiter; the trigger is a candidate becoming active in 2+ opportunities at once. **Correction (2026-07-14, confirmed with Paraform):** there is ONE shared candidate record — an earlier assumption that profiles are owned per recruiter was wrong and has been removed. "Managing across multiple opportunities" means coordinating the roles the recruiter personally submitted the candidate to. Every submission originates from a recruiter's action and consent (Para never auto-submits); cross-recruiter duplicate submission is platform-prevented and out of scope; a consistent Para review/approve surface already exists; and private/exclude-from-Para is a new distinction this design proposes. Success metrics are now finalized (see design-strategy.md). **Update (2026-07-11, IA refinement):** Opportunities is now the default landing view, Profile split from Context, the Action Queue is gone (approval-required items expand inline). **Update (2026-07-14, refocus + expansion):** scoped the whole feature to the candidate page — an earlier home/candidates-list/all-opportunities dashboard set was dropped as out of scope (the brief is about one candidate across multiple opportunities). Expanded the candidate page with an Activity tab (log + date/company/type filters), the on-platform call lifecycle (schedule via propose-times or booking-link over LinkedIn/email → post-call review with a per-call Para toggle + tags), scored recommended opportunities, the cross-opportunity hold (Para pauses its own actions when an offer lands elsewhere), and the Ask Para assistant (cited Q&A + in-chat approval-gated actions). **Still missing:** no candidate-facing surface (is the candidate ever aware of any of this?), and no confirmation of how Para computes the match score it now shows.

### Gaps and ambiguities
1. ~~No success metric is defined.~~ **Resolved 2026-07-11** — five metrics finalized, tied to the original HMW: less recruiter time coordinating a candidate across roles, fewer stale opportunities, recruiters keep auto-execution on, recruiters act on Para AI's recommendations more often than not, zero relationship-sensitive actions sent without approval.
2. **Default visibility assumptions are a designed guess, not a stated fact.** The PRD defaults notes/calls to Private and resume/LinkedIn to Visible. If defaults lean too private, Para AI may rarely get real context and the feature fails at its stated goal ("bring context inside the model"); if too open, it undermines the trust premise. This is the central design tension of the whole assignment and should be argued explicitly, not asserted. `[Both]`
3. **Bulk-approve is underspecified and carries a rubber-stamp risk.** The PRD allows batch-approving "repetitive" approval-required items but doesn't say what the recruiter actually sees before approving in bulk. If bulk approval doesn't force a real skim of each drafted action, the approval gate becomes theater — the exact failure mode the assignment is trying to avoid. `[PM]`
4. **"Undo" on auto-executed actions is not literally possible for sent communications.** An email or scheduling message that's already been delivered can't be unsent. The PRD should distinguish "undo before send" (a short grace window) from "correct after send" (a follow-up message), and only claim the one that's real. `[Eng]`
5. **Same-company conflict detection assumes a clean company↔opportunity mapping.** The PRD blocks double-submission to the same company, but this requires knowing which opportunities share a hiring company — not stated whether that data exists reliably at the opportunity level. `[Eng]`
6. ~~No notification channel for the Action Queue is defined.~~ **Resolved 2026-07-11** — the standalone Action Queue is gone; approval-required items surface inline on their opportunity row, so no candidate-level notification channel is needed. The smaller version (a recruiter's cross-candidate backlog across their whole book) is **out of scope**: it belongs on a home dashboard, which this candidate-page feature deliberately doesn't own. Flagged as a product-level handoff dependency in open-questions.md, not solved here. `[PM]`
7. ~~Single-recruiter assumption may not hold.~~ **Resolved 2026-07-14** — Paraform confirmed one shared candidate record; "managing across multiple opportunities" is scoped to the roles the recruiter personally submitted the candidate to. The earlier per-recruiter-silo framing was wrong and is removed.
8. ~~Para AI's matching reach beyond recruiter-initiated submissions is unconfirmed.~~ **Resolved 2026-07-14** — Para AI recommends matches, but every submission originates from a recruiter's action and consent; it never auto-submits. This confirms the design's confirm-gate on proposed matches.
9. ~~No cross-recruiter deduplication is addressed.~~ **Resolved 2026-07-14** — platform-prevented (the second recruiter can't submit the same candidate to the same role) and explicitly out of scope for the take-home.

### Missing states
**System states**
- Resume upload parsing in progress / parsing failed (unreadable file, unsupported format)
- Call recording sync in progress from the connected call tool; sync failure (auth expired, tool disconnected)
- ATS/pipeline sync lag or failure between an opportunity's own pipeline and the unified Opportunities view

**Permission states**
- Not addressed at all: is there a role above Recruiter (team lead, admin) with visibility into other recruiters' candidates? Currently the PRD has exactly one actor role.
- View-only or read-only access to a candidate record if a recruiter is covering for a colleague

**Content states**
- Candidate sourced but not yet submitted to any opportunity — Opportunities view's zero-opportunity empty state
- Candidate with only one active opportunity — does the multi-track UI still render, or collapse to a simpler single-pipeline view?
- Candidate active in a high number of opportunities (8-10+) — how the parallel-track layout scales before it becomes unscannable

**Action states**
- Recruiter edits an AI-drafted message before approving — is the edit logged/versioned, and does it change how future drafts are generated for this candidate?
- Recruiter rejects (not just edits) a recommended action — does Para AI drop it silently, or attempt a revised recommendation?
- Bulk-approve flow specifically — what the recruiter sees per-item before a batch send

**Responsive / Accessibility**
- Not addressed in the PRD at all. Recruiter workflows are frequently mobile/on-the-go (reacting to a candidate reply between meetings) — worth an explicit scope call on whether mobile is in v1.

### Questions for PM / Eng
1. `[Both]` Should Visible-to-Para-AI default to on for notes and calls (maximizing model context, per the brief's stated goal) or off (maximizing recruiter trust and control)? The brief frames this as a deliberate tradeoff the candidate should reason about, not default away.
2. `[PM]` Is there any candidate-facing view of any of this, or is the candidate entirely opaque to this system (only ever the subject, never a user)?
3. `[Eng]` Is company-to-opportunity mapping reliable enough today to auto-block same-company double submission, or does that require a manual recruiter check?
4. `[PM]` How should the candidate page hand off to Paraform's existing cross-candidate Para review/approve surface?

*Answered by Paraform 2026-07-14 (moved to open-questions.md → Resolved): shared candidate record; coordination scoped to the recruiter's own submissions; cross-recruiter dedup is platform-handled; Para never auto-submits; a consistent review/approve surface exists; context comes from resume/LinkedIn + recruiter preferences + transcripts; private/exclude is a new distinction.*

### Design risks
- **Rubber-stamp risk on bulk approval.** If batch-approving multiple recruiter-approval-required actions doesn't force a genuine per-item skim, the approval gate becomes a formality and Para AI effectively acts unsupervised on sensitive actions — directly contradicting the assignment's core constraint.
- **Context starvation from over-cautious defaults.** If recruiters rarely flip notes/calls to Visible-to-Para-AI (because it's effortful or feels risky), Para AI's recommendations stay shallow and the feature fails to deliver on "bring context inside the model," even though the visibility control itself works as designed.
- **False "undo" erodes trust.** If the UI implies an auto-executed email can be undone when it actually can't, the first time a recruiter discovers this (after a candidate replies to something they thought was retracted) will break trust in the whole auto-execute tier, likely causing recruiters to disable auto-execution altogether.
- **Invisible mode boundary.** If Auto-executed vs. Recruiter-approval-required isn't visually obvious everywhere an action appears (not just in the queue), recruiters will be surprised by actions they didn't know had already gone out — the same trust failure as the current real-world problem this feature is meant to fix.
- **Cross-opportunity hold could over-pause.** A hold that fires too aggressively (or on the wrong triggers) would feel obstructive rather than protective — the trigger set (offer confirmed vs. verbal vs. final round) and hold duration need real-world tuning. This is now the sharpest expression of the act-vs-wait boundary, so it's worth getting right.
- **A match score without a legible "why" reads as a black box.** Para now shows scored recommendations (e.g. 8/10); if the reasoning behind the number isn't visible, it can erode rather than build trust.

### Teaching notes
- The brief's linked "Passive Placements" concept implies Para AI already has a submission-recommendation capability today. This feature should read as extending that existing muscle across simultaneously-active opportunities, not inventing a new AI capability from scratch — frame the design strategy that way.
- **Superseded 2026-07-11:** the Action Queue as a standalone triage inbox is gone. Approval-required items now expand inline within their opportunity row on the Opportunities landing view — same fast approve/edit/reject interaction, but embedded where the recruiter already is rather than a separate destination they have to remember to check.
- The single most important piece of information architecture in this feature is the Auto-executed vs. Recruiter-approval-required distinction. It should be a persistent, legible visual signal wherever an action or its status appears — the opportunity row, its inline-expanded state, and any activity log alike — not something the recruiter has to open a detail view to learn.
- The candidate page is three tabs: Opportunities (default landing, task-oriented), Activity (log + context intake + the call lifecycle), and Profile (facts, LinkedIn, resume history), plus a persistent Ask Para assistant. Default design decisions toward keeping recruiters on Opportunities unless they deliberately go deeper.
- The two moments that make "where Para waits" concrete rather than asserted are the **cross-opportunity hold** (Para pauses its own queued actions on other opportunities when an offer lands elsewhere) and the **per-call review toggle** (the recruiter decides, after each on-platform call, whether the transcript feeds Para). Keep both prominent — they are the strongest answer to the brief's core question.
- Ask Para can *take actions*, not just answer — a requested action (e.g. schedule a call) comes back as an inline action card behind the same approval gate as everywhere else. This is the most AI-native surface and worth foregrounding.
