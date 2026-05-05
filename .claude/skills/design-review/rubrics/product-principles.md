# Product Principles

Use these principles alongside the heuristics when reviewing Dune product work.

## 1. Clarity before cleverness
The interface should be immediately understandable.
Prefer obvious structure, labels, and actions over novelty or clever interaction patterns.

Review for:
- obvious next actions
- understandable labels
- low ambiguity at key moments
- minimal interpretation burden on the user

## 2. Trust is part of the UX
Security products must feel calm, precise, and dependable.
When actions affect risk, automation, permissions, or remediation, the design must explain what will happen and why.

Review for:
- clear consequences
- understandable warnings
- explicit risky actions
- no hidden assumptions in high-stakes workflows

## 3. Reduce cognitive load
Enterprise workflows can be dense, but they should never feel mentally expensive without reason.
The design should simplify choices, reveal complexity progressively, and preserve context.

Review for:
- manageable information density
- progressive disclosure
- preserved context across steps
- reduced need to remember hidden rules

## 4. Reuse system patterns before inventing new ones
Consistency makes the product easier to learn and trust.
Use known component patterns, flows, and interaction models unless there is a strong reason not to.

Review for:
- appropriate component reuse
- familiar workflow structures
- no unnecessary novelty
- pattern consistency across the product

## 5. State completeness matters
A design is not complete if it only covers the happy path.
All meaningful states should be designed clearly and intentionally.

Review for:
- loading, empty, success, error, partial success
- permission states
- destructive and recovery states
- interrupted or async states where relevant

## 6. Fast for experts, safe for everyone
Experienced users should move quickly, but never at the cost of hidden risk or ambiguity.
Efficiency should coexist with clarity.

Review for:
- efficient repeat actions
- smart defaults
- bulk-action safety
- support for high-frequency workflows without confusion

## 7. Accessibility is a product-quality requirement
Accessibility is not an extra layer added at the end.
A strong design should support clear structure, readability, keyboard use, and non-visual comprehension from the start. Accessibility heuristics are useful early in design because they surface issues before implementation becomes expensive. [web:155][web:153][web:187]

Review for:
- readable hierarchy and language
- likely keyboard accessibility
- non-color-dependent meaning
- understandable errors and status changes
- touch and focus considerations where relevant

## 8. Polish supports trust
Craft is not just aesthetics.
Polish shows up in hierarchy, spacing, feedback, edge cases, and interaction detail.

Use Stripe as a benchmark for craft quality:
- high clarity
- restrained but precise interface decisions
- thoughtful state design
- high trust in consequential flows
- feedback that feels intentional and complete

Do not copy Stripe visually.
Use it as a benchmark for the level of care and coherence expected.