# Dune Security — Product UX Principles

## 1. Tone of Interaction

Calm authority, not alarm.

The platform trains users on high-stakes topics (phishing, social engineering, deepfakes) without inducing paranoia. Language is direct, accessible, and non-technical by default — written for a Wells Fargo branch employee, not a security analyst.

- Use plain English. Avoid jargon unless the audience is explicitly technical.
- Confidence over hedging. The product should feel like a trusted advisor, not a warning label.
- Brevity wins. If/then formatting for actionable guidance. Short sentences. No em dashes. No ellipses.
- Tone scales with context: informational content is matter-of-fact; risk alerts are serious but not catastrophic.


## 2. Error Handling Philosophy

Errors inform, they don't punish.

The platform surfaces mistakes (missed phishing simulations, failed assessments) as learning moments, not failures.

- Error states explain what happened and what to do next — never a dead end.
- Simulation outcomes (e.g., a user clicked a phishing link) are framed as data, not judgment.
- Admin-facing errors (misconfigured flows, edge cases in scheduling) should surface the specific constraint, not a generic failure message.
- RBAC edge cases and permission gaps should be caught early in a workflow, not at the point of action.
- System errors visible to end users should be minimal, recoverable, and unthreatening.


## 3. Trust & Safety Expectations

The platform must earn trust at every layer.

Dune Security sells to enterprise security teams who are themselves skeptical buyers. The product's credibility depends on behaving exactly as it claims.

- Simulated attacks (phishing, vishing, spear phishing) must feel real but debrief safely and immediately after interaction.
- User data (risk scores, behavior history) is handled with the assumption that employees are being evaluated — transparency in what is tracked and why is a product value, not just a compliance checkpoint.
- Client-branded modules must maintain the fidelity of the brand. White-label quality is a trust signal.
- Admin controls (exclusion windows, group targeting, agent triggers) must behave predictably. Surprises erode trust faster than missing features.
- The "Pause, Verify, Report" framework is the behavioral north star — the product should model the same deliberateness it teaches.


## 4. Speed vs. Control

Default to speed; expose control progressively.

Most users (employees receiving training) need zero configuration. Most admins need meaningful control without being overwhelmed.

- Guided flows (wizards, step-by-step setup) for complex configurations like spear phishing campaigns or agent triggers.
- Smart defaults everywhere — pre-filled schedules, recommended group targets, suggested exclusion windows.
- Power controls (custom RBAC, snapshot diffing, advanced scheduling) are available but not front-and-center.
- Bulk actions and automation (the SAT module factory, ElevenLabs Flows integration) prioritize throughput for content and campaign production.
- When in doubt: launch fast, surface edge cases inline, and let admins adjust — don't gate deployment on perfect configuration.


## 5. Prioritization Heuristics

| Scenario | Default |
|---|---|
| New feature with unclear scope | Design for the most common enterprise persona first |
| Admin flow vs. employee flow | Employee simplicity > admin flexibility |
| Speed of simulation delivery | Prefer scheduled/async over real-time where architecture allows |
| Localization | English-first; localization as a structured second pass |
| Risk score surfacing | Show scores in context of action, not as raw data |
