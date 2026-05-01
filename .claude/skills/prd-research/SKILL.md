---
name: prd-research
description: >
  Use when a PRD, feature brief, or change request needs structured critique before design work begins.
  Triggers on: new feature specs, significant scope changes, agent/automation flows, simulation targeting
  changes, RBAC-adjacent features, risk score surfaces, or any flow touching group management, scheduling,
  or remediation logic. Produces a structured design research document — not wireframes or UI proposals.
  Writes persistent output files consumed by downstream skills (ux-audit, design-review, handoff).
---

# PRD Research

## When to use
- A new feature PRD or change request needs critique before ideation starts
- A feature touches RBAC, group targeting, simulation scheduling, agent triggers, or risk scoring
- A PM or stakeholder has handed off a brief that needs design to surface gaps before estimation
- You're onboarding to a feature area and need a structured read of the requirements

## When NOT to use
- Copy or label changes with no structural impact
- Bug fixes with a clearly defined expected behavior and no UX ambiguity
- Design polish passes on shipped features
- Quick configuration changes with no new user-facing states

## Inputs
- PRD text or uploaded file
- Product context (who the user is, what they're trying to accomplish)
- Known constraints (technical, timeline, RBAC, dependencies)
- Optional: links to existing flows, Figma files, or related features for reference

If none of this is provided, the skill must enter **input collection mode** (see below) and ask for the minimum details needed to proceed.

---

## Input collection mode (when nothing is provided)

If you are invoked without a PRD, feature brief, or any clear description of the feature:

1. Ask for a concise feature description:  
   - “What is the feature called and what problem does it solve?”

2. Ask for the primary user and context:  
   - “Who is the primary user (role) and where in the product do they encounter this?”

3. Ask for the core goal and trigger:  
   - “What should happen, and what event should trigger it?”

4. Ask for any hard constraints that are already known:  
   - “Are there known technical, RBAC, or timeline constraints I should respect?”

5. Ask for links only if they exist and are easy to share:  
   - “If you have a PRD, doc, or Figma link, you can share it, but I can proceed with text answers.”

Once you have these answers, treat them as a **lightweight PRD** and continue with the standard analysis, feature slug derivation, and persistence rules below. Do not refuse to proceed just because there is no formal PRD; treat the collected answers as the source of truth.

If the user cannot answer even the basic questions above, stop and explain what is missing and why research output would not be meaningful yet.

---

## Feature slug

Before writing any output, derive or confirm the `<feature-slug>`:

1. Infer from the feature name using lowercase kebab-case. Examples:
   - "Remediation Agent — New User Trigger" → `remediation-agent-new-user-trigger`
   - "AI Spear Phishing for Groups v2" → `ai-spear-phishing-groups-v2`
   - "Scheduler Exclusion Drawer" → `scheduler-exclusion-drawer`
2. If the feature name is ambiguous, too long, or overlaps with an existing feature, **ask for clarification before writing files.**
3. Never append `new`, `v2`, `final`, or similar suffixes to resolve ambiguity — clarify instead.
4. Once confirmed, use the slug consistently across all output files and folder paths.

---

## Instructions

1. **If no input is provided**, follow the **Input collection mode** questions above to gather a minimal feature brief, then proceed.
2. **Extract the core frame:** goal, primary user, trigger event, success metric, dependencies, and hard constraints.
3. **Identify ambiguity:** contradictions between stated goals and constraints, undefined terms, assumptions baked in as facts.
4. **Map missing states** (grouped by type):
   - **System states:** loading, empty, error, timeout, partial data
   - **Permission states:** view-only, no access, role-restricted action, first-time user
   - **Content states:** single item, many items, max limit reached, stale data
   - **Action states:** destructive actions, irreversible actions, bulk actions, async confirmation
   - **Responsive/a11y:** mobile constraints, keyboard navigation, screen reader considerations
5. **Ask only high-leverage questions** — those that would change the design direction if answered differently. Skip clarifications that can be resolved in Figma.
6. **Surface design risks** — patterns that are technically feasible but likely to fail in production UX: scope creep vectors, trust/safety concerns, RBAC edge cases, flows that punish error.
7. **Write teaching notes** — concepts, existing precedents at Dune, or patterns the designer needs to understand before starting. Point to the closest existing reference in the product.
8. **Do not propose polished UI.** Rough flow descriptions are acceptable only to illustrate a gap or risk.
9. **Write all output files** as described in the Persistence and Output files sections below.

---

## Persistence

### When to write
Write output files after completing the full analysis — not incrementally. If the feature slug or scope is ambiguous, resolve that first before writing anything.

### Where to write
All files go in:
`knowledge/features/<feature-slug>/`

Create the folder if it doesn't exist. Never create duplicate files with suffixes like `-new`, `-v2`, or `-final`.

### How to update existing files
If files already exist for this slug:
- Read the existing content before overwriting.
- Preserve answered questions (move resolved items from `open-questions.md` to a `## Resolved` section with the answer inline).
- Update `last_updated` in `prd-research.json`.
- Add to edge cases and gaps — do not replace unless the prior content is directly contradicted.

### Downstream consumers
These files are read by other skills. Write with that in mind:
- `prd-research.json` — machine-readable; used by `ux-audit`, `design-review`, and `handoff` skills to load feature context automatically.
- Markdown files — human-readable; used as Claude context in downstream skill runs and design critique sessions.
- Do not embed commentary or meta-notes in JSON values. Keep values clean and parseable.

---

## Output files

### `prd-research-summary.md`
The primary human-readable output. Contains all sections from the output format below. Optimized for readability in a design review or PM sync. This is the file a designer reads before opening Figma.

### `prd-research.json`
Machine-readable structured summary. Used by downstream skills to load feature context without re-parsing prose. Required keys:

```json
{
  "feature_name": "Human-readable feature name",
  "feature_slug": "kebab-case-slug",
  "goal": "One sentence.",
  "user_segments": ["primary user", "secondary user if applicable"],
  "success_metrics": ["metric 1", "metric 2"],
  "constraints": ["constraint 1", "constraint 2"],
  "assumptions": ["assumption baked into the PRD"],
  "gaps": ["gap or ambiguity 1", "gap or ambiguity 2"],
  "edge_cases": ["edge case 1", "edge case 2"],
  "critical_questions": [
    { "owner": "PM", "question": "question text" },
    { "owner": "Eng", "question": "question text" },
    { "owner": "Both", "question": "question text" }
  ],
  "design_risks": ["risk 1", "risk 2"],
  "teaching_notes": ["note 1", "note 2"],
  "last_updated": "YYYY-MM-DD"
}
```

Values should be strings or arrays of strings — no nested objects except `critical_questions`. Keep values factual and terse.

### `open-questions.md`
Standalone list of unresolved questions for async PM/Eng review. Format:

```md
# Open Questions — <Feature Name>

## Unresolved
- [ ] [PM] Question text
- [ ] [Eng] Question text
- [ ] [Both] Question text

## Resolved
- [x] [PM] Question text — **Answer:** answer text
```

This file is updated in place as questions are answered. Never delete resolved items — move them to the Resolved section with the answer appended.

### `edge-cases.md`
Standalone list of unhandled states and edge cases, grouped by category. Format:

```md
# Edge Cases — <Feature Name>

## System states
- description

## Permission states
- description

## Content states
- description

## Action states
- description

## Responsive / Accessibility
- description
```

Downstream skills use this file to validate that design explorations cover the full state surface.

---

## Output format (for `prd-research-summary.md`)

### Feature summary
2–4 sentences. Goal, primary user, trigger, and how success is measured. Flag missing elements explicitly.

### Gaps and ambiguities
Numbered list. Each item: what the ambiguity is + why it matters to the design. Drop items where the impact is unclear.

### Missing states
Grouped by category (system / permission / content / action / responsive+a11y). Only include genuinely unaddressed states.

### Questions for PM / Eng
Numbered. High-leverage only. Label each `[PM]`, `[Eng]`, or `[Both]`.

### Design risks
Short, direct. Name the risk, name the failure mode, name the condition under which it occurs.

### Teaching notes
Concepts, patterns, or precedents the designer needs before starting. Reference the closest existing Dune flow. Include relevant design system constraints.

---

## Example

### Input PRD (condensed)
> **Feature: Remediation Agent — New User Trigger**
> When a new user is added to a high-risk group, the remediation agent should automatically assign them a training module. The agent should detect when this happens and trigger within 24 hours.

**Derived slug:** `remediation-agent-new-user-trigger`  
**Output path:** `knowledge/features/remediation-agent-new-user-trigger/`


---

## Example

### Input PRD (condensed)
> **Feature: Remediation Agent — New User Trigger**
> When a new user is added to a high-risk group, the remediation agent should automatically assign them a training module. The agent should detect when this happens and trigger within 24 hours.

**Derived slug:** `remediation-agent-new-user-trigger`
**Output path:** `knowledge/features/remediation-agent-new-user-trigger/`

---

### Feature summary
The remediation agent needs a second trigger: detecting when a new user joins a high-risk group and auto-assigning a training module within 24 hours. The primary user is a security admin who has configured an agent on a group. Success is measured by whether the assignment fires correctly and within the SLA window. **Missing from PRD:** how "high-risk group" is defined (risk score threshold? admin-designated?), and what happens if the user already has the module assigned.

### Gaps and ambiguities
1. **"New user added to a group" is undefined at the data layer.** Groups are dynamic database queries — there is no stored join timestamp. Real-time event detection may not be feasible without a snapshot-diff architecture. This affects whether the "within 24 hours" SLA is achievable. `[Eng]`
2. **"High-risk group" has no definition.** Is this a risk score threshold on the group? An admin-designated flag? A calculated value? The answer changes whether the admin needs new configuration UI or if this is implicit. `[PM]`
3. **Duplicate assignment behavior is unspecified.** If the new user already completed or has the module assigned, does the agent skip, reassign, or notify? `[PM]`
4. **First-activation bootstrap problem.** When an admin activates this trigger for the first time, do users already in the group get evaluated, or only users added after activation? `[Both]`

### Missing states
**System states**
- Agent trigger fires but module assignment fails (API error, module unavailable)
- Snapshot diff runs but detects no change (silent success — should this surface anywhere?)

**Permission states**
- Admin has agent access but not module-assignment permissions — can they still configure this trigger?
- View-only admin sees the agent panel — what is visible vs. actionable?

**Content states**
- Group has 0 users at activation (valid edge case — agent sits idle)
- User added to multiple high-risk groups simultaneously — does the trigger fire once or N times?

**Action states**
- Admin deactivates the agent mid-cycle — what happens to pending assignments?

**Responsive/a11y**
- Not flagged as primary concern for this feature — confirm mobile is out of scope.

### Questions for PM / Eng
1. `[Eng]` Are groups truly dynamic queries with no stored membership events? If so, snapshot diffing is the only viable v1 architecture — confirm this is acceptable.
2. `[PM]` What defines a "high-risk group" — is this a configurable threshold, a manual flag, or derived from group-level risk score?
3. `[PM]` What is the intended behavior when the new user already has the target module assigned or completed?
4. `[Both]` Does the 24-hour SLA start from user addition or from the next scheduled snapshot diff run? These may not be the same.
5. `[PM]` Should the agent trigger be retroactive on first activation (evaluate existing group members) or prospective only?

### Design risks
- **Snapshot diff latency vs. stated SLA.** If diffs run on a schedule (e.g., hourly), the "within 24 hours" claim may be technically met but feel broken to admins expecting near-real-time response. Risk: admin trust erosion if a user joins and doesn't receive training for hours.
- **Bootstrap ambiguity creates support load.** If retroactive behavior on first activation is undefined, admins will make incorrect assumptions and file support tickets when existing users aren't assigned. Must be explicit in the UI at activation.
- **Silent failures.** If an assignment fails after trigger, there is currently no described error surface. Agents that fire but don't complete will be invisible — admins will assume it worked.

### Teaching notes
- **Snapshot diffing pattern:** This feature requires the same diff architecture discussed for the risk score threshold trigger. The agent record stores a snapshot of group membership at last check; the next run compares against it. Review the remediation agent architecture doc before designing the configuration UI.
- **Closest existing reference:** The scheduler exclusion drawer (user profile surfacing) is the nearest UI pattern for surfacing affected users in an agent context. Use it as the starting point for any "who will this affect" preview UI.
- **RBAC constraint to design for:** Agent configuration is a privileged action. The trigger setup UI must have a `disabled` state with tooltip for view-only admins. Flag any new permission boundaries to Eng before handoff.
