# Open Questions — Candidate Multi-Role Coordination

Most of the original scope/architecture questions were answered directly by Paraform (Kinnara) on 2026-07-14 — see Resolved. What remains open is mostly design-detail on the net-new distinctions this design proposes.

## Unresolved
- [ ] [Both] Should the Include-in-matching toggle default on for notes/calls (more context) or off (more trust and control)? This is a proposed new control, so the default is a genuine design decision.
- [ ] [Both] How does Para AI compute the match score shown on recommended opportunities (e.g. "Strong · 8/10"), and how do we keep that number legible and trustworthy rather than a black box?
- [ ] [PM] Which state changes should trigger a cross-opportunity hold — offer confirmed, verbal offer, final round scheduled? And how long does Para hold a paused action before re-escalating?
- [ ] [Both] Is a flat 60-90 day staleness threshold right for volatile context (comp floor, location, reason for leaving), or should different fact types decay at different rates?
- [ ] [Eng] Is company-to-opportunity mapping reliable enough to hard-block same-company double submission, or should that degrade to a soft warning?
- [ ] [PM] Any candidate-facing view of any of this, or is the candidate entirely the subject and never a user? (Assumed subject-only; unconfirmed.)
- [ ] [PM] How should the candidate page hand off to Paraform's existing cross-candidate Para review/approve surface — a badge count, a deep link, shared state? (The surface exists; the handoff is undefined.)

## Resolved
- [x] [PM] Is there one shared candidate record, or does each recruiter have their own view of the same person? — **Answer (Paraform):** There is one shared candidate record. An earlier draft of this design wrongly assumed per-recruiter silos; that assumption has been removed throughout.
- [x] [PM] What does "managing one candidate across multiple opportunities" mean — my own submissions, or platform-wide? — **Answer (Paraform):** Coordinating the roles you've personally submitted the candidate to. The design is scoped accordingly.
- [x] [Eng] How does Paraform handle duplicate submissions / ownership conflicts for a single role across recruiters? — **Answer (Paraform):** Not something to worry about for the take-home — the second recruiter can't submit the same candidate to the same role. Platform-prevented, out of scope to design.
- [x] [PM] Does Para AI ever initiate a submission on its own, or does every submission originate from a recruiter's action and consent? — **Answer (Paraform):** Every submission originates from a recruiter's action and consent. This confirms the design's core gate: Para recommends, the recruiter's confirmation is the submission.
- [x] [PM] Is there a single consistent place to review and approve Para AI activity, or does it depend on how far a match has progressed? — **Answer (Paraform):** Yes, there's a consistent place. The candidate page's inline approvals are the in-context view of the same decisions and roll up to that surface; redesigning the cross-candidate surface is out of scope.
- [x] [PM/Eng] How much candidate context lives in structured fields vs. general logs today, and how much new structure must recruiters add? — **Answer (Paraform):** Structured insights are derived from resume + LinkedIn; preferences are added by the recruiter; other insights come from call transcripts when recorded. The design works with all three rather than demanding hand-structuring.
- [x] [PM] Is there currently a way to mark candidate information private / excluded from Para AI? — **Answer (Paraform):** That would be a new distinction. So the Include-in-matching / private control is a proposal this design introduces, called out as an assumption.
- [x] [PM] What is the actual success metric? — **Answer:** Five metrics tied to the HMW (less coordination time, fewer stale opportunities, recruiters keep auto-execution on, recruiters act on recommendations more often than not, zero relationship-sensitive actions sent without approval). See design-strategy.md.
- [x] [PM] What notification channel does a standalone Action Queue use? — **Answer:** Superseded — no standalone Action Queue; approval-required items surface inline on the opportunity row and roll up to Paraform's existing consistent Para review surface.
