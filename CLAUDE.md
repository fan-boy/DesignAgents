# Design Intelligence System

This project is a structured knowledge base and skill library for Dune Security's design and product work.

## Structure

- `.claude/skills/` — Claude Code skills, each invocable as a slash command
- `.claude/commands/` — multi-step workflow definitions
- `knowledge/` — source-of-truth reference docs (principles, heuristics, competitors, features)
- `templates/` — blank output templates for design deliverables
- `examples/` — annotated sample outputs
- `scripts/` — utility scripts

## Skills

| Skill | Trigger | Purpose |
|---|---|---|
| prd-research | `/prd-research` | Critique a PRD before design begins |
| competitor-intelligence | `/competitor-intelligence` | Research and profile a competitor |
| design-strategist | `/design-strategist` | Strategic framing for a design problem |
| design-review | `/design-review` | Structured heuristic review of a design |
| dev-handoff | `/dev-handoff` | Generate a developer handoff spec |

## Key knowledge files

- `knowledge/product-principles/principles.md` — UX principles for Dune
- `knowledge/design-system-rules.md` — token, component, and pattern rules
- `knowledge/heuristics.md` — Nielsen + Dune-specific heuristics and review checklist
- `knowledge/competitor-list.md` — competitor registry with positioning notes
