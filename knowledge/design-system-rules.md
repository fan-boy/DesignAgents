# Design System Rules
Dune Security · Internal Knowledge · Last updated: 2026

---

## Typography

### Type Ramp

| Role | Usage | Weight |
|---|---|---|
| Display | Hero headlines, marketing moments | Semibold (600) |
| H1 | Page titles | Semibold (600) |
| H2 | Section headers | Semibold (600) |
| H3 | Card titles, subsection headers | Medium (500) |
| H4 | Labels in context, table section breaks | Medium (500) |
| Body Default | All paragraph and UI copy | Regular (400) |
| Body Small | Secondary descriptions, metadata | Regular (400) |
| Label | Form labels, button text, badges | Medium (500) |
| Caption | Timestamps, footnotes, helper text | Regular (400) |
| Code | Inline code, token display | Regular (400) — monospace |

### Rules

- Do: Use text styles exclusively. Never set font size, weight, or line height directly on a node.
- Do: Load fonts with `await figma.loadFontAsync({family, style})` before any text operation.
- Don't: Use Bold (700) in body copy or UI chrome. Reserve for Display only if needed.
- Don't: Mix weight and size to create ad-hoc hierarchy not defined in the ramp.
- Don't: Set `lineHeight` or `letterSpacing` as bare numbers — always `{unit: 'PIXELS', value: N}`.

### Accessibility

- Minimum body text: 14px / Body Small.
- Caption text (12px) must never carry critical information alone — always paired with an icon or label.
- Avoid all-caps for body copy. Labels and badges in all-caps must be tracked (+0.5–1px letter spacing).

---

## Spacing

### Scale (4px base grid)

| Token | Value | Uses |
|---|---|---|
| `spacing/xs` | 4px | Icon-to-label gaps, tight inline padding |
| `spacing/sm` | 8px | Input internal padding, compact list items |
| `spacing/md` | 16px | Card padding, form field gaps |
| `spacing/lg` | 24px | Section gaps within a page area |
| `spacing/xl` | 32px | Between major layout sections |
| `spacing/2xl` | 48px | Page-level top/bottom breathing room |
| `spacing/3xl` | 64px | Hero/empty state vertical centering |

### Rules

- Do: Snap all values to the 4px grid. Use tokens — not literals.
- Do: Use auto-layout gap to control spacing between children — never manual positioning.
- Don't: Use odd pixel values (e.g., 6px, 10px, 18px) unless forced by external asset constraints.
- Don't: Use margin or padding inconsistently within the same component family.

### Accessibility

- Tap/click targets: minimum 44×44px (WCAG 2.5.5). Apply padding to meet this even when the visual element is smaller.
- Adequate breathing room around interactive elements prevents mis-taps in dense UI.

---

## Color

### Semantic Roles

| Token | Role |
|---|---|
| `color/surface/default` | Base page and card backgrounds |
| `color/surface/elevated` | Modals, drawers, popovers |
| `color/surface/subtle` | Table row alternates, sidebar backgrounds |
| `color/border/default` | Standard strokes |
| `color/border/strong` | Focus rings, active selection |
| `color/text/primary` | Body and heading copy |
| `color/text/muted` | Secondary/supporting text |
| `color/text/inverse` | Text on dark/filled surfaces |
| `color/interactive/primary` | CTAs, primary buttons, links |
| `color/interactive/primary-hover` | Hover state for primary interactive |
| `color/feedback/danger` | Destructive actions, error states |
| `color/feedback/warning` | Caution states, risk indicators |
| `color/feedback/success` | Completion, confirmed states |
| `color/feedback/info` | Neutral informational callouts |

### Risk Score Scale

Treated as a data visualization token group — not interchangeable with feedback colors.

| Level | Token | Use |
|---|---|---|
| Critical | `color/risk/critical` | Score 90–100 |
| High | `color/risk/high` | Score 70–89 |
| Medium | `color/risk/medium` | Score 40–69 |
| Low | `color/risk/low` | Score 0–39 |

### Rules

- Do: Use semantic tokens in all components. Never use primitive tokens (raw hex aliases) directly in a component fill.
- Do: Apply color in Figma via variable binding (`setBoundVariableForPaint`) — capture and reassign the returned paint object.
- Don't: Use `color/feedback/danger` for risk score visualization. Use the risk scale.
- Don't: Hardcode colors in fills/strokes. No magic hex values.
- Don't: Use color alone to convey meaning — always pair with icon, label, or pattern (WCAG 1.4.1).

### Accessibility

- Text on backgrounds must meet WCAG AA contrast: 4.5:1 for body, 3:1 for large text (18px+ regular or 14px+ bold).
- Interactive elements (buttons, links) need 3:1 contrast against adjacent non-interactive surfaces.
- Never rely solely on color to indicate state (error, disabled, selected) — use shape, icon, or label too.

---

## Components

### Core Principles

- One source of truth per pattern. One-offs require documented justification.
- All components use auto-layout. No manually positioned children.
- Every component has a disabled state. Every interactive component has hover and focus states.
- Components that trigger privileged actions must have RBAC-aware disabled variants with tooltip copy explaining why.

### Variant Properties (Standard)

| Property | Values |
|---|---|
| state | default, hover, focus, active, disabled, error |
| size | sm, md, lg (as applicable) |
| variant | primary, secondary, ghost, danger (as applicable) |
| hasIcon | true, false |

### Do/Don't Patterns

#### Buttons

- Do: Use primary for the single most important action per view. One primary button per screen section.
- Do: Use danger variant (not just red color) for destructive actions — delete, revoke, remove.
- Don't: Use primary for navigation or passive links.
- Don't: Label buttons with vague copy ("Click here", "Submit"). Use action verbs ("Save Changes", "Start Simulation").

#### Forms

- Do: Stack labels above inputs. Inline labels are not supported.
- Do: Show validation errors inline, below the field, with a `color/feedback/danger` token and an error icon.
- Don't: Disable the submit button to prevent errors. Show errors on attempt instead.
- Don't: Use placeholder text as a substitute for labels — placeholders disappear and fail accessibility.

#### Modals

- Do: Use for blocking decisions only. Not for forms longer than 3 fields.
- Do: Place destructive action (red) on the right, Cancel on the left.
- Don't: Stack multiple modals. Use a wizard or drawer instead.
- Don't: Close a modal on backdrop click if it contains unsaved form state — confirm first.

#### Drawers

- Do: Right-anchor. Fixed width (360px standard / 480px complex forms). Scrollable body.
- Do: Always include a close icon in the header and a cancel action in the footer.
- Don't: Use drawers for simple confirmation — use a modal.
- Don't: Open a drawer from within a drawer.

#### Tables

- Do: Place sort/filter controls above the table, not inline with column headers.
- Do: Include an empty state with message + primary CTA. Never a blank table.
- Don't: Display raw risk score numbers without the semantic badge (color + label).

#### Badges / Status Indicators

- Do: Always pair color with a text label inside the badge.
- Don't: Use badge color as the sole indicator of meaning.

### Accessibility

- All interactive components must be keyboard navigable (Tab, Enter/Space, Escape to dismiss).
- Focus rings must be visible — use `color/border/strong` token. Never suppress outline without a custom replacement.
- Icon-only buttons must have an `aria-label` — document the label in the component description.
- Disabled elements should not receive focus (use `aria-disabled` + visual state where keyboard focus is needed).
- Form fields must be associated with their labels via `htmlFor`/`id` or `aria-labelledby`.
