## Problem framing

Today, ~40% of interviews on Paraform are AI-matched and ~40% of hires come from candidates submitted to multiple roles simultaneously — but the context that makes a match good (why a candidate is really leaving, what they'd thrive in, team fit) mostly lives outside the model, in notes, calls, and recruiter instinct. When one candidate is active across three-to-five roles at once, the recruiter re-derives status and next steps per role from memory or scattered tabs, and there's no consistent mechanism for the recruiter to say "the model can act on this" versus "this stays between me and the candidate."

The core design tension this feature is built around: give Para AI enough visibility and latitude to remove repetitive coordination work, **without** letting it make or imply relationship-sensitive decisions (rejections, compensation conversations, sensitive personal context) on the recruiter's behalf. Every decision below resolves to that tension — where Para AI acts on its own, and where it waits for the recruiter.

**Scope (confirmed with Paraform).** Paraform has **one shared candidate record** per person. This feature is about how a recruiter coordinates the opportunities **they have personally submitted** that candidate to — not every role the candidate might be in platform-wide. Every submission originates from a recruiter's action and consent; Para AI recommends matches and next actions but never submits on its own. Duplicate submissions across recruiters (two recruiters, same candidate, same role) are prevented by the platform and are out of scope here. There is no candidate-facing surface — the candidate is always the subject, never a user. The entire feature lives on **one candidate's page**; broader recruiter surfaces (a home dashboard, a candidates list, an all-roles view) were explored and scoped out — they're the product around this feature, not the feature.

**Assumptions we're introducing (called out per the brief's guidance).** A few things below are net-new distinctions this design proposes, not existing Paraform behavior: (1) the **Include-in-matching** control that lets a recruiter mark context private or shared with Para AI — confirmed as a new distinction, not something the product has today; (2) the **cross-opportunity hold** and which state changes trigger it; (3) **match scores** on Para's recommendations; (4) the **per-call review** step; (5) **configurable Para AI permissions** — recruiter-level defaults with per-candidate overrides, with sensitive actions permanently locked to Ask-first. Each is a reasonable proposal in service of the trust boundary, flagged as an assumption rather than a fact.

## Actors

- **Recruiter** — owns every relationship-sensitive judgment call.
- **Para AI** — organizes context, recommends next actions, executes bounded low-risk coordination, and surfaces matches. It has no page of its own; it shows up inline wherever the recruiter is already working, always attributed (a persistent "Para AI active" indicator plus labeled tags on its output) and always citing the source behind a recommendation.

## The candidate page

The page is one candidate with three tabs — **Opportunities** (default landing), **Activity**, and **Profile** — plus a persistent **Ask Para** assistant reachable from a floating launcher on every tab.

### Opportunities (landing view)

The page a recruiter lands on when they open a candidate — the actual task of checking status and deciding next actions, not a data-browsing detour. It shows every active opportunity as a parallel track, each with its own pipeline stage (Sourced, Submitted, Interviewing, Offer, Closed), days in stage, last activity, and next action. A condensed "what Para AI currently understands" strip sits at the top (key signals plus an X-of-Y-included-in-matching count) with a link into Profile, and a quick-capture affordance (+ Add note, + Log call) opens inline rather than routing the recruiter away.

Para AI also surfaces **recommended opportunities** the recruiter hasn't submitted the candidate to — drawn from Paraform's broader matching layer — in a visually distinct "Proposed by Para AI" section, each with a **match score** (e.g. "Strong match · 8/10") and a one-line rationale. A proposed match is a recommendation only; it becomes an active tracked opportunity only when the recruiter confirms it (Add to Pipeline / Dismiss) — the same gate whether the recruiter or Para AI initiated it.

For each active opportunity, Para AI surfaces a recommended next action carrying one of two handling modes:

| Mode | Description |
|---|---|
| Auto-executed | Low-risk, reversible, logistical actions Para AI performs directly and logs (a scheduling link, a status confirmation, a reminder to an unresponsive hiring manager). The recruiter sees it in the activity log after the fact and can undo within a defined window. |
| Recruiter-approval required | Relationship-sensitive or higher-stakes actions Para AI drafts but does not send until the recruiter approves, edits, or rejects (submitting to a new role, confirming a proposed match, any rejection or withdrawal message, compensation or offer-related messaging, anything referencing content excluded from matching). |

**Para AI permissions (proposed).** The Auto vs. Approval-required split isn't hard-coded — the recruiter configures it. The drawer opens from a settings control on the Para AI summary strip (present on every tab of the candidate page, and candidate-scoped — so the entry point itself signals "this configures Para for this candidate"); a gear inside the Ask Para panel header is a secondary route to the same drawer. Permissions are **recruiter-level defaults with per-candidate overrides**: defaults capture the recruiter's general trust in Para (set once, apply everywhere); an override tightens or loosens autonomy for one relationship (an exec candidate mid-offer vs. a junior pipeline candidate). Each action gets one of three access levels — **Auto** (Para does it and logs it), **Ask first** (Para drafts, recruiter approves), or **Off** (Para doesn't do it at all). Relationship-sensitive actions (submissions, rejection/withdrawal messages, compensation and offer messaging) are **permanently locked to Ask first** — they can be turned Off, but can never be set to Auto, at either level; the feature's core promise is not one mis-set toggle away from broken. A candidate whose settings are overridden shows a "Customized" indicator, with one tap back to defaults. The cross-opportunity hold composes with this: permissions set the baseline, the hold is Para temporarily tightening its own autonomy based on state.

Approval-required actions expand **inline within their own opportunity row** — the drafted content, its source citation, and Approve / Edit / Reject appear right there, in the context of the opportunity they affect. Paraform already has a consistent place where a recruiter reviews and approves Para AI activity across candidates (confirmed); these in-context approvals are the on-candidate view of the same decisions and roll up to that surface. That cross-candidate review surface itself is out of scope to redesign here. By default opportunities show as a list ranked most-urgent-first; a Board view (grouped by stage) is a toggle on the same page for candidates active in many opportunities at once.

**Cross-opportunity hold.** Because a candidate is live in several roles at once, Para AI reasons across them, not just within each. When one opportunity reaches a state that changes the stakes elsewhere — e.g. a company extends an **offer** with an expiry — Para AI **pauses its own queued auto-actions on the other opportunities** (a follow-up nudge, a scheduling reminder) rather than firing them, and surfaces a "Para paused N actions · waiting on you" card explaining why, with Keep paused / Resume all / Review each. This is the sharpest expression of the act-vs-wait boundary: Para holds back on its own accord based on cross-opportunity state, and hands the decision to the recruiter.

### Profile

A structured, scannable summary — name, title, location and remote preference, comp range — plus the candidate's **LinkedIn** (connected/fetched) and a **resume upload history** (current + prior versions, with the ability to upload a newer resume). The facts a recruiter checks in five seconds, not a chronological feed.

### Activity + Context intake

The chronological log of everything that has happened with the candidate — calls, notes, emails, stage changes, system events — newest first, filterable by **date range**, **company/opportunity**, and **activity type**. This is also where context enters the model.

Context on Paraform comes from three places today (confirmed): **structured insights auto-derived from the resume and LinkedIn**; **preferences the recruiter adds** (comp floor, location/remote, what they'd thrive in); and **insights captured from call transcripts when a call is recorded**. This design works with all three rather than asking recruiters to hand-structure everything.

Layered on top is a **new distinction this design proposes** (Paraform has no private/exclude control today): every context item carries an **Include in matching** toggle (on / off) — named for what it controls: whether Para AI can use that signal when matching and recommending, not whether the model "knows" it abstractly. Resume and LinkedIn default on; notes and calls default off until the recruiter includes them (that's where the most sensitive relationship context lives, so consent isn't assumed). A one-tap "Include this in matching?" prompt appears right when a note or call is captured, so inclusion isn't buried in a settings screen.

Context items are **durable** or **volatile**. Durable facts (resume history, tenure) never decay. Volatile signals (a stated comp floor, a location preference, a reason for leaving) go out of date; past a set threshold (default 60-90 days, not finalized) they carry a staleness flag prompting reconfirmation, and Para AI's matching weight discounts them correspondingly — the indicator isn't cosmetic.

**Calls happen on-platform**, so they produce a transcript automatically. The call lifecycle:

1. **Schedule** — from Activity, the recruiter schedules a call via a slide-in drawer with two options: **propose specific times** (pick slots for the candidate to choose) or **send a booking link** (candidate books any open slot). Either way Para pre-fills an editable outreach message, and the recruiter sends it via **LinkedIn** or **email**. Once the candidate picks a time, the call is added to the Activity timeline automatically.
2. **Completed → review pending** — when the call finishes, its Activity card enters a "Review pending" state.
3. **Review** — a slide-in drawer shows Para's auto-summary of the transcript (with a full-transcript link) and asks the recruiter to decide: an **Use this call for Para AI** toggle, plus Para-suggested **tags** (comp, remote, timeline) the recruiter can edit, and an optional context note. Saving adds it to the timeline; the Para toggle is the per-call version of the Include-in-matching decision.

### Ask Para (assistant)

A floating launcher on every tab opens a right slide-in chat panel scoped to the current candidate ("Chatting about Olivia Rhye"), answering **only from context the recruiter has included in matching**. The recruiter can ask questions ("what's she looking for," "when did we last follow up," "who's a good fit") and get cited answers. Crucially, Para can also **take actions from the chat**: when the recruiter asks it to do something (e.g. "set up the Fieldnote intro"), Para renders an inline **action card** (the drafted schedule, its details, Confirm & send / Edit) — the same approval gate as everywhere else, so the assistant can *do* work, not just answer.

Integration Points

| Integration | Description |
|---|---|
| Call recording / transcription | Calls happen on-platform and are recorded + transcribed automatically; Para summarizes each into candidate-context signals |
| ATS / role pipeline system | Opportunity stage data (Sourced through Closed) is shared between each role's own pipeline and the candidate's unified Opportunities view |
| LinkedIn (public profile fetch) | Recruiter pastes a profile URL; public profile data is fetched into the record, not scraped beyond public fields |
| Email + LinkedIn outreach | Auto-executed and recruiter-approved actions (including scheduling messages) are sent through Paraform's outbound messaging and logged to the activity timeline |
| Para AI matching layer (platform-wide) | Surfaces candidate-to-role matches beyond the recruiter's own submissions; each is a scored recommendation and becomes an active track only on recruiter confirmation |

Edge Cases & System Behaviour

| Scenario | Behaviour |
|---|---|
| Candidate declines or is rejected from one opportunity while active in others | That track moves to Closed; other tracks are unaffected; Para AI does not infer or propagate the outcome |
| One opportunity extends an offer while others are mid-process | Para AI pauses its queued auto-actions on the other opportunities and surfaces a "paused · waiting on you" card; the recruiter resumes or keeps paused — nothing auto-sends |
| A note or call is excluded from matching after Para AI already used it | Recommendations sourced from it are flagged stale; Para stops citing/reusing it going forward but does not "unsend" already-sent messages |
| Para AI proposes submitting the candidate to two roles at the same hiring company | Blocked and surfaced as a conflict requiring manual resolution, never auto-executed |
| An approval-required action sits unactioned past a defined window | Para AI escalates with a reminder on the opportunity row; it does not auto-send after timeout |
| Call fails to transcribe or produces a low-confidence transcript | The source is flagged "needs review"; Para does not generate recommendations from it without recruiter confirmation |
| Candidate withdraws entirely | All active tracks move to Closed; all queued Para AI actions across tracks are cancelled, not executed |
| Two recruiters, same candidate, same role | Prevented by the platform — the second recruiter can't submit to a role already taken; out of scope to design here (confirmed with Paraform) |
| Para AI surfaces a new opportunity match | Para recommends only; every submission originates from the recruiter's action and consent, so a proposed match becomes an active track solely on recruiter confirmation, shown in the distinct "Proposed by Para AI" section |
| A volatile context item ages past the staleness threshold | Flagged for reconfirmation; Para's matching weight for it is discounted correspondingly, not just visually marked |
| A durable context item (resume, tenure) ages | Never flagged stale — durable facts don't decay the way stated preferences do |

---
*Revision history: written 2026-07-09 from the take-home prompt; refined 2026-07-11 (Opportunities-as-landing IA; inline approval replacing a standalone queue; durable-vs-volatile context). Refocused 2026-07-14 onto the candidate page and expanded with the Activity tab + call lifecycle (schedule → review), scored recommended opportunities, the cross-opportunity hold, and the Ask Para assistant with in-chat actions. Reconciled 2026-07-14 with Paraform's answers to clarifying questions: there is one shared candidate record (an earlier per-recruiter-silo assumption was wrong and has been removed); coordination is scoped to the roles the recruiter personally submitted the candidate to; every submission originates from a recruiter's action and consent (Para never auto-submits); cross-recruiter duplicate submission is platform-prevented and out of scope; and the private / include-in-matching control is a new distinction this design proposes, not existing behavior.*
