# Open Questions — Candidate Multi-Role Coordination

## Unresolved
- [ ] [Both] Should Visible-to-Para-AI default to on for notes and calls (maximizing model context) or off (maximizing recruiter trust and control)?
- [ ] [PM] Is there any candidate-facing view of any of this, or is the candidate entirely opaque to the system?
- [ ] [Eng] Is company-to-opportunity mapping reliable enough today to auto-block same-company double submission, or does that require a manual recruiter check?
- [ ] [PM] Is call-recording sync from a connected tool assumed to already exist, or is manual upload the only real v1 path?
- [ ] [PM] Given candidate profiles are owned per recruiter rather than shared platform-wide, is this feature's scope correctly bounded to "opportunities within one recruiter's own profile of a candidate" — never opportunities visible only through another recruiter's independent profile of the same person?
- [ ] [Eng] Does Paraform perform any identity resolution across independently-owned recruiter profiles for the same real person, to catch duplicate submissions to the same role from different recruiters? If not, is that an accepted platform-level risk this feature isn't expected to solve?
- [ ] [PM] Can Para AI surface a match to an opportunity the recruiter hasn't chosen (drawing on a broader, platform-wide matching layer)? If so, does entering it as an active tracked opportunity always require recruiter confirmation, the same as a recruiter-initiated submission?

## Resolved
- [x] [PM] What is the actual success metric — time-to-fill, recruiter hours saved per multi-role candidate, reduction in dropped/stale opportunities, or something else? — **Answer:** Five metrics finalized, all tied to the original HMW: (1) less recruiter time coordinating one candidate across roles, (2) fewer opportunities go stale from missed follow-up, (3) recruiters keep auto-execution on rather than disabling it, (4) recruiters act on Para AI's recommendations more often than not, (5) zero relationship-sensitive actions sent without recruiter approval. See design-strategy.md.
- [x] [PM] Is multi-recruiter/team ownership of a single candidate in scope for v1? — **Answer:** Further product research indicates candidate profiles are owned per recruiter by platform design, not just a v1 scoping choice — there is no single shared candidate record across recruiters to build multi-recruiter ownership on top of. This feature stays scoped to one recruiter's own profile of a candidate; cross-recruiter coordination is now understood as an architecture question, not a feature scope question (see new unresolved questions above on identity resolution and Para-AI-surfaced matches).
