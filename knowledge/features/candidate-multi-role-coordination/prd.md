## Last updated — 2026-07-11
Incorporated further product research: candidate profiles are owned per recruiter, not shared platform-wide, and Para AI's matching reach can extend to opportunities the recruiter did not directly pursue. Scope clarified accordingly; new integration point, edge cases, and recommendation type added. Success metrics finalized (see design-strategy.md).

Candidate Multi-Role Coordination gives a recruiter and Para AI a shared workspace for managing one candidate — specifically, that recruiter's own record of the candidate — across every opportunity they're active in at once. It covers two connected problems: how a recruiter feeds candidate context (resume, LinkedIn, call recordings, notes) into a system that both the recruiter and Para AI read from, and how that same recruiter tracks and directs a candidate's status across multiple open roles without duplicating effort per role. The feature spans two actors: the Recruiter, who owns relationship-sensitive judgment calls, and Para AI, which handles context organization, next-action recommendation, and bounded autonomous coordination.

**Scope note.** Candidate profiles on Paraform are owned per recruiter — the same real person may exist as an independent, unlinked profile in another recruiter's own book. This feature coordinates opportunities within one recruiter's relationship to a candidate; it does not reconcile, merge, or dedupe across recruiters. Para AI's matching also extends beyond opportunities the recruiter has directly pursued (it can surface a candidate-to-role match from Paraform's broader matching layer); any such match only becomes an active, tracked opportunity in this recruiter's Command Center once the recruiter confirms it — the same gate applies whether the recruiter or Para AI initiated it.

**Problem framing.** Today, ~40% of interviews on Paraform are AI-matched and ~40% of hires come from candidates submitted to multiple roles simultaneously, but the context that makes a match good (why a candidate is really leaving, what they'd thrive in, team fit) mostly lives outside the model, in notes, calls, and recruiter instinct. When a candidate is active across 3-5 roles at once, the recruiter today re-derives status and next steps per role from memory or scattered tabs, and there's no consistent mechanism for the recruiter to say "the model can act on this" versus "this stays between me and the candidate." The core design tension: give Para AI enough visibility and latitude to remove repetitive coordination work, without letting it make or imply relationship-sensitive decisions (rejections, compensation conversations, sensitive personal context) on the recruiter's behalf.

**Candidate Context Intake.** Recruiters build a candidate's context record from four source types: resume, LinkedIn, call recordings, and notes. Resume is uploaded as a file and parsed automatically into structured fields (roles, tenure, skills). LinkedIn is added by pasting a profile URL; Paraform fetches public profile data on that URL rather than requiring manual re-entry. Call recordings are either uploaded directly or synced from a connected call tool; each recording is transcribed and Para AI generates a call summary highlighting stated preferences, concerns, and constraints (e.g., compensation floor, remote preference, reason for leaving). Notes are freeform text the recruiter adds at any point, optionally tagged to a specific opportunity or left general.

Every source item (a note, a call summary, an extracted resume field) carries a visibility toggle: **Visible to Para AI** or **Private to recruiter**. Default visibility is Visible to Para AI for resume and LinkedIn data, and Private for notes and call recordings until the recruiter explicitly shares them — call recordings and notes are where the most sensitive relationship context lives, so the system does not assume consent to share by default. The recruiter can change visibility on any item at any time from the candidate's context timeline. Items visible to Para AI are labeled with a small indicator so the recruiter always knows, at a glance, what the model can currently see.

When Para AI surfaces a recommendation or takes an action, it cites the specific source item that informed it (e.g., "Based on your March 3 call notes, mentioned preferring hybrid roles"). If the underlying source is later marked private, previously-surfaced recommendations that relied on it are flagged as stale rather than silently retained.

**Multi-Opportunity Pipeline View.** A candidate can be attached to multiple opportunities (open roles) at once. The Candidate Command Center shows all of a candidate's active opportunities as parallel tracks in one view, each with its own pipeline stage (Sourced, Submitted, Interviewing, Offer, Closed) and its own next action. This replaces navigating to each role's pipeline separately to check a shared candidate's status.

Para AI can also surface an opportunity the recruiter hasn't already submitted the candidate to, drawn from Paraform's broader matching layer rather than the recruiter's own submissions. A Para-AI-surfaced match appears as a recommendation, not a track — it only becomes an active Command Center track once the recruiter confirms it, exactly like a recruiter-initiated submission would.

For each opportunity track, Para AI surfaces a recommended next action (e.g., "Submit to Role B," "Propose Role D — a new match found outside what you've submitted," "Send interview availability to Role C's hiring manager," "Follow up — no response in 5 days"). Each recommendation carries one of two handling modes:

| Mode | Description |
|---|---|
| Auto-executed | Low-risk, reversible, logistical actions Para AI performs directly and logs (e.g., sending a scheduling link, a status confirmation email, a reminder to an unresponsive hiring manager). Recruiter sees it in the activity log after the fact and can undo within a defined window. |
| Recruiter-approval required | Relationship-sensitive or higher-stakes actions Para AI drafts but does not send until the recruiter approves, edits, or rejects (e.g., submitting the candidate to a new role, confirming a Para-AI-surfaced match as an active opportunity, any rejection or withdrawal communication, compensation or offer-related messaging, anything referencing private notes). |

Recruiter-approval-required actions land in an **Action Queue**, where the recruiter can approve as-is, edit before sending, or dismiss. Repetitive low-stakes approval-required items across multiple opportunities (e.g., the same scheduling confirmation format for three roles) can be bulk-approved.

**Recruiter view of candidate status.** From the Command Center, the recruiter sees, per opportunity: current stage, days in stage, last activity, and the pending or recently-taken Para AI action. A single candidate-level status banner flags cross-opportunity conflicts the recruiter needs to resolve manually (e.g., two active interview requests landing the same day, or an offer at one company while another is mid-interview).

Integration Points

| Integration | Description |
|---|---|
| Call recording / transcription tool | Recordings sync in automatically where connected; each is transcribed and summarized by Para AI into candidate-context signals |
| ATS / role pipeline system | Opportunity stage data (Sourced through Closed) is shared between the per-role pipeline and the candidate's unified Command Center view |
| LinkedIn (public profile fetch) | Recruiter pastes a profile URL; public profile data is fetched into the candidate record, not scraped beyond public fields |
| Email / outbound messaging | Auto-executed and recruiter-approved actions are sent through Paraform's outbound messaging, logged to the candidate's activity timeline |
| Para AI matching layer (platform-wide) | Surfaces candidate-to-role matches beyond opportunities the recruiter has directly pursued; a surfaced match is a recommendation only and becomes an active Command Center track solely on recruiter confirmation |

Edge Cases & System Behaviour

| Scenario | Behaviour |
|---|---|
| Candidate declines or is rejected from one opportunity while active in others | That track moves to Closed; other tracks are unaffected; Para AI does not infer or propagate the outcome to other opportunities |
| A note or call recording is marked private after Para AI already used it in a recommendation | Prior recommendations sourced from it are flagged stale in the activity log; Para AI does not retroactively "forget" already-sent messages, but stops citing or reusing that source going forward |
| Para AI proposes submitting the candidate to two roles at the same hiring company | Action is blocked and surfaced to the recruiter as a conflict requiring manual resolution, never auto-executed |
| An approval-required action sits unactioned past a defined window (e.g., 48 hours) | Para AI escalates with a reminder in the recruiter's queue; it does not auto-send after timeout |
| Call recording fails to transcribe or produces a low-confidence transcript | Recruiter sees a "needs review" flag on that source; Para AI does not generate recommendations from low-confidence transcripts without recruiter confirmation |
| Candidate withdraws from the process entirely | All active opportunity tracks move to Closed; any queued Para AI actions across all tracks are cancelled, not executed |
| The same real-world candidate is independently sourced or owned by another recruiter | Out of scope for this feature to detect or reconcile; no cross-recruiter deduplication is performed here — flagged as a platform-level identity question, not something this feature's design solves |
| Para AI surfaces a new opportunity match the recruiter did not initiate | Treated identically to a recruiter-initiated submission: it only becomes an active Command Center track after explicit recruiter confirmation, never automatically |
