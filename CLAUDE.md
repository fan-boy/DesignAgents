# Design Intelligence System

This repository is the structured knowledge base and workflow layer for Dune Security’s design and product work.

It contains:
- reusable Claude skills
- workflow commands
- persistent design knowledge
- templates and examples for repeatable design deliverables

Use this repository as the source of truth for design research, critique, strategy, and handoff artifacts.

## Core purpose

This system exists to help:
- critique PRDs before design begins
- research competitors and product patterns
- create structured design strategy outputs
- review designs against heuristics and product-quality standards
- generate implementation-ready handoff documentation
- build working prototypes inside approved local prototype codebases

## Project structure

- `.claude/skills/` — Claude skills and their reference files
- `.claude/commands/` — multi-step workflow definitions
- `knowledge/` — persistent reference docs and feature-specific outputs
- `templates/` — blank templates for design deliverables
- `examples/` — annotated sample outputs
- `scripts/` — utility scripts

## Skills

| Skill | Typical trigger | Purpose |
|---|---|---|
| `prd-research` | `/prd-research` | Critique a PRD before design begins |
| `competitor-intelligence` | `/competitor-intelligence` | Research and profile a competitor or compare feature patterns |
| `design-strategist` | `/design-strategist` | Create strategic framing for a design problem |
| `design-review` | `/design-review` | Run a structured heuristic and quality review of a design |
| `dev-handoff` | `/dev-handoff` | Generate a developer handoff spec |
| `prototype-builder` | `/prototype-builder` | Build or extend a working prototype in an approved local Next.js codebase |
| `prd-creator` | `/prd-creator` | Build a confluence ready prd|

Skills may be invoked explicitly with `/skill-name` and may also be selected automatically when the task clearly matches the skill description. Claude Code supports prompt-based skills as reusable capabilities rather than keeping all instructions in the root context. [web:67][web:205]

## Commands

Use commands in `.claude/commands/` for multi-step workflows.
Prefer commands for orchestration and skills for specialized capability.

Example:
- `/feature-workflow` should route work across the relevant skills in sequence

## Key knowledge files

- `knowledge/product-principles/principles.md` — Dune UX principles
- `knowledge/design-system-rules.md` — token, component, and pattern rules
- `knowledge/heuristics.md` — Nielsen plus Dune-specific heuristics
- `knowledge/competitor-list.md` — competitor registry with positioning notes

## Working style

- Work sequentially in the current session
- Do not spawn parallel subagents
- Prefer explicit, durable outputs over ephemeral reasoning
- Reuse existing knowledge files before creating new ones
- Prefer updating existing feature folders over creating duplicate artifacts
- Keep the main `CLAUDE.md` focused; detailed instructions belong in skills, commands, templates, or reference files

## Paths and write rules

### Primary working tree
All work in this repository runs in the main working tree only:

`/Users/aadi/code/design-intelligence-system`

### Prototype code location
Some implementation work happens outside this repository in approved local prototype folders under:

`/Users/aadi/code`

When building prototypes:
- always confirm the target prototype folder before editing
- only read or write code inside the explicitly approved prototype folder
- do not assume that all folders under `/Users/aadi/code` are valid targets
- prefer extending an existing prototype over creating a duplicate app

### Relative-path rule
- Reads and writes for this repository should be relative to the root where this `CLAUDE.md` lives
- If a task targets an external prototype folder, state the target folder clearly before editing

## Execution constraints

- Never create git worktrees or branches
- Never use `git worktree add`
- The `.claude/worktrees/` directory must remain empty
- Do not write anything into `.claude/worktrees/`
- All skill steps execute sequentially in the same session
- Do not use parallel subagents
- Do not move or rename core project folders unless explicitly asked
- Do not create duplicate output files with suffixes like `-new`, `-v2`, or `-final` when updating an existing artifact is more appropriate

## Git workflow

After writing or updating any file in this repository, stage and commit it to `main`.

Use:
```bash
git add <file> && git commit -m "<feature-slug>: <what was written>"
```

Rules:
- keep commits scoped and descriptive
- do not batch unrelated changes into one commit
- if multiple files belong to the same deliverable, they may be committed together
- do not create branches
- do not rewrite git history unless explicitly asked

If a task edits files outside this repository under `/Users/aadi/code`, do not assume the same git rules apply unless that target folder is also a git repository and the user has asked for commits there.

## Feature artifact rules

Feature-specific outputs should usually live in:

`knowledge/features/<feature-slug>/`

Examples:
- `prd-research-summary.md`
- `prd-research.json`
- `open-questions.md`
- `edge-cases.md`
- `design-review.md`
- `design-review.json`
- `dev-handoff.md`

Before creating a new feature folder:
- derive or confirm the feature slug
- check whether the feature already exists
- update in place when appropriate

## Quality expectations

Design outputs should aim for a high bar of product quality:
- clarity before cleverness
- strong hierarchy
- complete state coverage
- trust in risky or security-sensitive flows
- accessibility by default
- design-system consistency
- thoughtful interaction details

Use Stripe as a benchmark for craft quality, not as a visual style to copy. The benchmark is clarity, coherence, trustworthiness, and polish in consequential product workflows. This kind of high-craft benchmark is most useful when translated into explicit review criteria rather than broad stylistic mimicry. [web:43][web:198]

## Prototyping expectations

When using `prototype-builder`:
- inspect the existing codebase before coding
- reuse local Next.js patterns, components, and styling conventions
- build the smallest working prototype that meaningfully tests the flow
- include important states needed for design evaluation
- avoid overengineering, unnecessary dependencies, or broad refactors
- clearly distinguish real behavior from mocked behavior

## Decision rules

When unsure which workflow to use:
- use `prd-research` for unclear or incomplete requirements
- use `competitor-intelligence` for external pattern research
- use `design-strategist` for framing and flow definition
- use `design-review` for critique and quality evaluation
- use `dev-handoff` for implementation-ready specs
- use `prototype-builder` when the request is to build a working UI in code

If the task is multi-step, prefer a command such as `/feature-workflow` to orchestrate the sequence.

## Avoid

- vague outputs with no persistent files
- duplicate feature folders
- writing implementation code before understanding the local codebase
- treating skills as generic prompts instead of structured workflows
- copying another company’s visuals directly
- broad repo changes when a targeted edit is sufficient