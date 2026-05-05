# Heuristics

Use these heuristics to review the design. Evaluate every review against all 10 Nielsen heuristics plus the 5 Dune-specific heuristics below.

## Nielsen's 10 Heuristics

### 1. Visibility of system status
Check whether the interface clearly communicates what is happening now.
Look for:
- loading, saving, processing, syncing, or queued states
- clear confirmation after important actions
- clear progress or completion feedback
- visible distinction between idle, pending, success, and failure

### 2. Match between system and the real world
Check whether the design uses concepts, language, and structure users will understand.
Look for:
- plain-language labels
- familiar mental models
- information grouped in a way that matches user expectations
- warnings and outcomes described in user terms, not internal jargon

### 3. User control and freedom
Check whether users can recover, undo, cancel, or safely exit.
Look for:
- cancel / back / close pathways
- confirmation before irreversible actions
- ability to revise inputs before committing
- graceful recovery from unintended actions

### 4. Consistency and standards
Check whether patterns are applied consistently across the flow.
Look for:
- consistent labels and interaction patterns
- known Dune patterns reused appropriately
- consistent hierarchy, spacing, and control usage
- no unnecessary novelty where a standard pattern already exists

### 5. Error prevention
Check whether the design prevents mistakes before they happen.
Look for:
- validation before submission
- guardrails on destructive or risky actions
- constrained input where appropriate
- clear defaults and previews before commitment

### 6. Recognition rather than recall
Check whether users can act without depending on memory.
Look for:
- visible context at key decision points
- discoverable actions
- preserved information across steps
- reduced need to remember previous selections or hidden rules

### 7. Flexibility and efficiency of use
Check whether the design supports both new and experienced users.
Look for:
- efficient paths for repeat tasks
- shortcuts or bulk behaviors where relevant
- reduced unnecessary repetition
- smooth handling of frequent workflows

### 8. Aesthetic and minimalist design
Check whether the interface is focused and readable.
Look for:
- strong visual hierarchy
- reduced noise
- clear CTA emphasis
- no unnecessary content competing with the main task

### 9. Help users recognize, diagnose, and recover from errors
Check whether errors are understandable and actionable.
Look for:
- specific error messages
- clear cause and next step
- recovery paths
- no dead-end failure states

### 10. Help and guidance
Check whether users get the support they need at the right time.
Look for:
- helper text where ambiguity exists
- good empty states
- setup cues
- contextual guidance for risky, unfamiliar, or enterprise-heavy workflows

## Dune-Specific Heuristics

### 11. Trust and risk communication
Check whether the design builds confidence in security-sensitive workflows.
Look for:
- consequences explained clearly
- calm, actionable warning language
- no ambiguity around risky actions
- enough context for admins to trust the action they are taking

### 12. RBAC and permission boundary clarity
Check whether access boundaries are legible and predictable.
Look for:
- clear distinction between visible vs actionable states
- disabled states for restricted users
- explanation of why access is limited
- no hidden permission traps

### 13. State completeness for enterprise workflows
Check whether the flow accounts for the full state surface.
Look for:
- loading, empty, success, error, partial success
- permission-restricted states
- interrupted, retry, stale-data, and async states
- multi-item and bulk-action edge cases where relevant

### 14. System-pattern compliance
Check whether the design fits the Dune product and design system.
Look for:
- proper component usage
- reuse of known workflows and interaction patterns
- no ad hoc structure where a system pattern exists
- consistency with product-wide hierarchy and behavior

### 15. Operator efficiency without ambiguity
Check whether the design supports fast action without sacrificing understanding.
Look for:
- efficient admin workflows
- progressive disclosure rather than overwhelming density
- bulk or expert actions that remain understandable
- no speed optimization that creates costly mistakes

## Quality Bar Overlay

In addition to the heuristics above, review the design against a Stripe-level craft standard.

This is not a request to copy Stripe’s visual style.
It is a benchmark for:
- clarity
- polish
- restraint
- interaction quality
- trustworthiness
- state handling
- precision of feedback

A design can technically satisfy heuristics and still fall short on quality if:
- hierarchy feels muddy
- actions are understandable but not obvious
- states exist but feel underdesigned
- risky workflows are functional but not confidence-inspiring
- the overall experience feels merely acceptable rather than thoughtfully crafted