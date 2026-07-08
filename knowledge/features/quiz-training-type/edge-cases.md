# Edge Cases — Quiz Training Type

## System states
- Uploaded JSON fails to parse or is missing required fields
- Parsed JSON yields zero questions
- Publish succeeds on the backend but the success toast/redirect fails to render
- Network failure or timeout during the "Publishing quiz..." state
- "Download JSON Template" fails or returns a stale template

## Permission states
- Non-admin role attempts to access the Quiz tab, Create Quiz, or the per-row Assign action
- View-only admin views Quiz tab and detail screens without action affordances

## Content states
- Very large question set (50+) in the "Review Questions" list — scroll/pagination behavior
- Quiz with a single question
- Duplicate quiz titles across the library
- Quiz assigned to a user who already has it assigned
- Quiz with all four answer options showing as correct or none marked correct in the uploaded JSON (malformed answer key)

## Action states
- Admin abandons the Create Quiz wizard mid-flow (any step) — draft persisted or fully discarded?
- Admin uses "Change file" after already reviewing questions — do Basic Info fields (title/description) persist across the re-upload?
- Admin edits or re-publishes an already-published quiz
- Learner leaves a quiz in progress before completing — resumable or restarts from Question 1?
- Learner exhausts all 3 attempts without meeting the passing score
- Learner fails and Retake on fail is disabled

## Responsive / Accessibility
- Keyboard-only navigation through MCQ answer options and the Next button
- Screen reader announcement of "Question N of M" and "Attempt X/3" progress indicators
- Passing score and retake-toggle hint text legible and operable at mobile widths, if admin flows are supported on mobile
