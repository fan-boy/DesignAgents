---
name: prototype-builder
description: >
  Use when a working product prototype needs to be built or updated inside an existing Next.js codebase.
  Triggers on: prototype requests, implementation of new feature flows in an existing prototype folder,
  converting wireframes or user flows into working Next.js UI, or extending local prototype apps under
  /Users/aadi/code. Reads the local codebase first, reuses existing patterns, and creates or updates
  working prototype files without unnecessary architecture changes.
---

# Prototype Builder

## When to use
- A feature needs a working prototype in an existing Next.js folder
- A user flow, wireframe, or design strategy should be converted into a functioning UI
- An existing prototype needs a new screen, flow, or component
- A design concept needs to be tested quickly in code using local app patterns
- A designer wants to iterate inside the current prototype ecosystem instead of creating a new app

## When NOT to use
- The task is only critique or design review
- The task is only PRD analysis or user-flow creation
- A brand-new app architecture is needed from scratch and no existing prototype folder is relevant
- The request is only for static documentation rather than working UI

## Inputs
- Feature name or feature slug
- Prototype folder path under `/Users/aadi/code`
- Relevant design context: PRD, user flow, wireframes, design strategy, screenshots, or Figma context
- Optional constraints: mobile-first, accessibility, speed, visual fidelity, mock data needs

If the target prototype folder is not provided, ask:
1. Which existing prototype folder should be used?
2. If none exists, should a new folder be created under `/Users/aadi/code`?

If the design context is too thin to build responsibly, ask for:
- the primary user goal
- the core flow
- the must-have screens or states

## Path and workspace rules
- Skill files live in `/Users/aadi/code/design-intelligence-system/.claude/skills`
- Prototype code lives in `/Users/aadi/code`
- Always confirm the target code folder before making edits
- Do not assume write access outside the attached workspace or allowed directories
- Prefer working within an existing prototype folder over creating a new codebase
- Do not create a second duplicate prototype if the requested work clearly belongs in an existing one

## Required codebase lookup
Before writing code:
1. Inspect the target folder structure
2. Identify whether it is a Next.js app and whether it uses the App Router or Pages Router
3. Read the relevant local files before coding:
   - `package.json`
   - `README.md` if present
   - `CLAUDE.md` or `AGENTS.md` if present
   - top-level app structure
   - existing components, styles, utilities, and mock-data patterns
4. Reuse existing conventions for:
   - routing
   - styling
   - component composition
   - data mocking
   - icons
   - file naming
5. Read local Next.js documentation or project guidance if available before making framework-specific changes

## Build goals
The prototype should:
1. work inside the existing codebase
2. reflect the intended user flow and feature behavior
3. be believable and testable, not just visually plausible
4. include the important states needed to evaluate the concept
5. avoid overengineering

## Implementation workflow
1. Understand the feature goal and core user task
2. Read design context from the feature folder if available:
   - `prd-research-summary.md`
   - `prd-research.json`
   - `edge-cases.md`
   - `design-strategy.md`
   - `design-strategy.json`
   - `user-flow.md`
   - `user-flow.mmd`
   - `design-review.md`
3. Inspect the target prototype codebase before planning implementation
4. Decide the smallest sensible set of files to create or update
5. Reuse local components and patterns before creating new ones
6. Implement the core happy path first, then meaningful edge states
7. Include mock data or local state only as needed to make the prototype usable
8. Keep code readable, consistent, and easy to iterate on
9. Run the app or relevant checks if the environment allows it
10. Summarize what was built and what remains intentionally mocked or simplified

## Next.js rules
- Follow the existing app structure rather than imposing a new architecture
- Prefer project-local patterns over generic framework habits
- If local docs or conventions conflict with assumptions, follow local docs
- Do not add large new dependencies unless necessary
- Do not restructure the codebase unless the user asks
- If using App Router, follow the existing route and component boundaries
- If using mock data, keep it obviously local and easy to replace
- Build for prototype usefulness first: clarity, flow realism, interaction believability

## Design quality expectations
- The prototype should be good enough to evaluate the workflow, not just admire the visuals
- Include the critical states that matter to the concept
- Reuse the design system or local UI primitives where possible
- Prioritize clarity, trust, hierarchy, and interaction quality
- Avoid placeholder UX that would invalidate usability feedback

## Output behavior
After implementation:
1. List the files created or updated
2. Explain how the prototype maps to the intended flow
3. Call out what is real, mocked, simplified, or still missing
4. If helpful, suggest the next most valuable review step:
   - design-review
   - dev-handoff
   - further prototyping
   - usability testing

## Safety rules
- Do not edit unrelated prototype folders
- Do not overwrite large existing files without checking whether targeted edits are possible
- Do not invent backend integrations if the prototype only needs mocked interactions
- Do not silently ignore missing context that would materially change the implementation
- If the target folder is unclear, stop and ask before writing code

## Example requests
- "Build a working prototype for bulk user invite in /Users/aadi/code/admin-prototype"
- "Implement this onboarding flow in the existing Next.js prototype folder"
- "Use the feature folder for account-recovery and build the core flow in the prototype app"