# Severity Scale

Use the following S0–S4 scale for every finding.

## S0 — Not a real issue
Use when the observation is not actually a usability or design problem after closer inspection.
This should be rare in the final report.

## S1 — Cosmetic
Minor polish issue with low user impact.
Examples:
- small spacing inconsistency
- minor label awkwardness that does not change understanding
- subtle visual roughness with no workflow consequence

Fix if time permits, but it does not materially affect usability or trust.

## S2 — Minor
Usability issue with noticeable but limited impact.
Examples:
- slight hierarchy weakness
- helper text that is missing but not essential
- a state that is understandable but could create hesitation

Task completion is still likely, but the experience is less efficient or less clear than it should be.

## S3 — Major
Important issue with meaningful impact on comprehension, efficiency, trust, or recovery.
Examples:
- unclear CTA hierarchy
- weak validation or poor feedback
- confusing permission boundaries
- missing state coverage that can cause user mistakes
- accessibility issues that meaningfully reduce usability

These issues should be fixed before handoff or release.

## S4 — Critical
Severe issue that blocks task completion, creates serious trust or safety risk, or causes major accessibility failure.
Examples:
- user cannot complete a core task
- risky or destructive actions are ambiguous
- failure states leave users stranded
- permission behavior is dangerously unclear
- critical information is inaccessible or missing

These issues make the design not ready for handoff or release.

## How to score severity

Consider all three of these:

### Frequency
How often will users encounter this issue?

### Impact
How much does it harm task success, comprehension, trust, or efficiency?

### Persistence
Can users easily recover, or does the issue continue to cause confusion or damage?

## Severity guidance

Escalate severity when:
- the task is high stakes
- the workflow is admin, security, permissions, or risk related
- the issue affects trust or irreversible actions
- the problem affects accessibility in a meaningful way
- the issue appears at a critical step in the flow

Do not assign high severity just because something feels unpolished.
Do not assign low severity to trust, permission, or destructive-action problems simply because they occur infrequently.

## Reporting rule
Each finding must include exactly one severity rating: S0, S1, S2, S3, or S4.