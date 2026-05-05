# Review Output Format

Use this structure for every design review.

## Review Summary
Start with 2–4 bullets covering:
- the biggest strengths
- the most serious risks
- overall confidence in the design
- whether the design appears ready for handoff

## Quality Bar Assessment
Answer these directly:
- Does this meet the expected Stripe-level standard of product craft?
- If not, what specifically falls short?
- Is the main gap in clarity, trust, consistency, state design, accessibility, or polish?

Keep this section concise and direct.

## Findings
List findings in priority order.

For each finding include:

### ID
Use `DR-01`, `DR-02`, etc.

### Severity
Use S0–S4 from `severity-scale.md`.

### Category
Choose the most relevant category, such as:
- Visibility of system status
- Error prevention
- Trust and risk communication
- RBAC / permissions
- Accessibility
- Design system compliance
- Hierarchy and clarity
- State completeness
- Operator efficiency

### Location
Name the screen, panel, frame, or interaction area.

### Issue
Describe what is wrong in concrete terms.

### Why it matters
Describe the user or business consequence.

### Recommended fix
Give a practical improvement, not a vague suggestion.

### Principle / Heuristic violated
Reference the most relevant heuristic(s) or product principle(s).

### Teaching note
Add one short lesson explaining what a strong product designer should notice here.

## Strengths
List 2–5 things working well.
These should be specific and useful, not generic praise.

## Open Questions
Only include questions that materially affect confidence in the review.
Label ownership when possible:
- [PM]
- [Eng]
- [Both]
- [Design]

## Revision Priorities
List the top 3–5 changes in order of importance.

## Verdict
End with exactly one of:
- Ready for handoff
- Needs revision
- Blocked on open questions

## Files Saved
List the output files written to the feature folder.

## Writing rules
- Prefer fewer, stronger findings over long shallow lists
- Be direct and specific
- Avoid generic praise
- Avoid vague advice like “improve spacing” without explaining the consequence
- Focus on critique that will change the design meaningfully