# Review Output Format

Standard output structure for design reviews produced by the `/design-review` skill.

## Sections

### 1. Review summary
2–3 sentences. What was reviewed, who it's for, and the overall verdict.

### 2. Heuristic violations
Grouped by Nielsen heuristic number or Dune-specific heuristic (D1–D5). Each finding:
- **Severity:** S0–S4 (see `severity-scale.md`)
- **Heuristic:** which principle is violated
- **Finding:** what the problem is
- **Location:** where in the design it occurs
- **Recommendation:** what to do about it

### 3. Design system compliance
Checklist pass/fail against token usage, component variants, spacing, and accessibility.

### 4. RBAC & permissions
Any permission boundary gaps or missing disabled states.

### 5. Open questions
Unresolved decisions that need PM or Eng input before the review can be fully closed.

### 6. Verdict
- **Ready for handoff** — no S0/S1 issues
- **Needs revision** — one or more S0/S1 issues must be resolved first
- **Needs PM/Eng input** — blocked on open questions
