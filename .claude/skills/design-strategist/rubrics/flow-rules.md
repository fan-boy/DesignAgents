# Flow Rules

Every user flow should include:

1. Entry points
- Where does the user start?
- What context do they already have?

2. Happy path
- The ideal path from entry to completion

3. Decision points
- Where does the user choose, confirm, or branch?

4. Edge cases
- Empty, loading, error, validation, permission, destructive, interrupted, retry, and recovery states

5. Exit states
- Success, cancellation, partial success, failure

6. State clarity
- What feedback should the user receive at key moments?

7. Efficiency
- How does the flow support repeat use or expert behavior?

Flow writing rules:
- Use concise step labels
- Make branching explicit
- Keep flow steps action-oriented
- Avoid vague steps like "User continues"
- Call out system actions separately when important