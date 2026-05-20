# Implementation Workflow

Use this process every time:

1. Inspect before editing
- Read package.json
- Read route structure
- Read key local components
- Understand styling and state patterns

2. Plan the smallest viable implementation
- Which route or screen will be added?
- Which files need updates?
- Which existing components can be reused?

3. Build the happy path first
- Core screen
- Primary action
- Success path

4. Add critical states
- loading
- empty
- error
- disabled
- partial success if relevant

5. Keep prototype logic local
- mock data
- local state
- minimal fake backend behavior

6. Verify the prototype works
- run dev server or checks if possible
- sanity check routes and interactions

7. Report clearly
- files changed
- what was mocked
- what is incomplete