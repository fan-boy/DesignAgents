# UX Heuristics
Dune Security · Internal Knowledge · Last updated: 2026

---

## Nielsen's 10 Heuristics (Applied to Dune)

### 1. Visibility of System Status
Keep users informed about what's happening, with appropriate feedback in reasonable time.

**Dune context:** Simulation campaigns, agent runs, and risk score calculations are async. Users must always know if something is running, queued, completed, or failed — never leave them in a void.

- Show progress states for campaign launch, agent activation, and module delivery.
- Risk score changes should surface as a visual delta (before/after), not a silent update.

### 2. Match Between System and the Real World
Use language and concepts familiar to the user — not internal system terminology.

**Dune context:** Our end users are employees at banks, healthcare orgs, and retailers — not security professionals.

- "Phishing simulation" not "simulated threat vector."
- "Your training is due" not "module assignment pending."
- Admins can handle more technical language; learner-facing UI must be plain English.

### 3. User Control and Freedom
Support undo, redo, and clear exits. Users make mistakes.

**Dune context:** Simulation scheduling, group targeting, and agent configuration are high-stakes. Users need escape hatches.

- Wizards must support Back navigation without data loss.
- Destructive actions (delete campaign, deactivate agent) require a confirmation step.
- Modals with form state must confirm before closing — not silently discard.

### 4. Consistency and Standards
Users shouldn't have to wonder whether different words, situations, or actions mean the same thing.

**Dune context:** The design system exists to enforce this. Deviation must be intentional and documented.

- One pattern per interaction type (one drawer pattern, one wizard pattern, one empty state pattern).
- Terminology is locked: "simulation" not "test," "group" not "cohort," "risk score" not "risk rating."
- Action button placement follows the same left/right convention across all flows.

### 5. Error Prevention
Better to prevent errors than to recover from them.

**Dune context:** Misconfigured simulations and agent triggers can have real organizational impact — surface constraints early.

- Validate schedule conflicts before the wizard's final step, not at submission.
- Surface RBAC permission gaps at the start of a flow, not at the point of action.
- Warn before targeting a group that was recently simulated (cooldown awareness).

### 6. Recognition Over Recall
Minimize the user's memory load. Make options, actions, and objects visible.

**Dune context:** Admins configure infrequently used features. Don't make them remember syntax or IDs.

- Exclusion windows should be selectable from a calendar/list, not typed as date strings.
- Group selection uses a searchable dropdown with member count — not a raw ID field.
- Agent configuration surfaces affected users in context, not in a separate lookup.

### 7. Flexibility and Efficiency of Use
Accelerators for experts; defaults for novices.

**Dune context:** Power admins manage hundreds of simulations. New admins need guardrails.

- Smart defaults everywhere (suggested schedule, recommended group, pre-filled cadence).
- Bulk actions for campaign and group management.
- Advanced options (custom RBAC, snapshot diffing, fine-grained triggers) are available but not front-and-center.

### 8. Aesthetic and Minimalist Design
Every extra unit of information competes with relevant information and diminishes its relative visibility.

**Dune context:** Dashboard overload is a real failure mode. Risk scores, campaign stats, and training completion compete for attention.

- One primary metric per card. Supporting metrics are secondary.
- Empty states are clean — not a list of possible next actions.
- Settings pages are organized by task, not by data model.

### 9. Help Users Recognize, Diagnose, and Recover from Errors
Error messages should be in plain language, indicate the problem, and suggest a solution.

**Dune context:** Configuration errors (scheduling conflicts, invalid group targets, agent trigger failures) need actionable resolution paths.

- Error messages: what happened + why + what to do. Never just "Something went wrong."
- Inline validation (below the field) for form errors. Toast/banner for system-level errors.
- Failed simulations surface in the campaign detail view, not just in a log.

### 10. Help and Documentation
Even though it's better if the system doesn't need explanation, it's sometimes necessary.

**Dune context:** Security concepts (spear phishing, vishing, AI simulation) need contextual education for non-technical admins.

- Tooltip copy for advanced configuration fields.
- Inline "What is this?" links on first-exposure to simulation types.
- Empty states include a brief explanation of the feature, not just a CTA.

---

## Dune-Specific Heuristics

**D1. Earn Trust Before Surprising**
Simulated attacks land in employee inboxes. Anything that could alarm or confuse must be followed immediately by a debrief. No simulation ends without a safe landing page explaining what just happened and what to do next.

**D2. Show the Why, Not Just the What**
Risk scores and compliance stats without context breed confusion. Always explain what drives the number and what action it implies. "72 — above average risk. Recent click on phishing simulation." is better than "72."

**D3. Design to the Permission Boundary**
Every feature that surfaces user data or triggers actions must be designed for the least-permissioned user who might access it. RBAC is a design constraint, not an engineering afterthought.

**D4. Respect the Learner's Time**
Employee-facing training must be completable in one focused session. No module should require more cognitive context than the average employee has available in a 5-minute break. Respect cognitive load as a real constraint.

**D5. Failure States Are Data, Not Punishment**
When a user clicks a phishing link or fails a quiz, the system reacts with education — not shame. Copy, visual design, and flow must reinforce this. Remediation is a feature, not a consequence.
