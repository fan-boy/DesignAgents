# Design Strategy — Red Team Campaign Launcher
Dune Security · Design Strategy · Last updated: 2026-05-08

---

## Feature context

**Goal:** Let security admins launch adversarial multi-channel campaigns (SMS + WhatsApp v1; Viber, Telegram, vishing on roadmap) targeting individuals, groups, or both — with a launch flow that inherits the SMS phishing wizard as its base pattern.

**Primary user:** Security admin / red team operator. Secondary: security leadership (approver, if dual-auth required); compliance viewer (read-only, TBD).

**Trigger:** Admin needs to conduct an adversarial test of real employee behavior across messaging channels — not for training, but to assess actual security posture.

**Success metrics:** Not defined in brief — this is an open gap. Design optimizes for launch speed and admin confidence (no surprises post-launch) until metrics are defined.

**Critical distinction from simulations:** Red team campaigns are adversarial exercises. The compliance model, remediation behavior, and risk pipeline integration differ materially from training simulations. This distinction drives every load-bearing strategy decision below.

**Still-open constraints affecting strategy:**
- Whether risk score pipeline is isolated or integrated with simulations (open question — strategy designs for isolated by default, notes the fork)
- Sub-role RBAC visibility into results not confirmed
- Template library model (shared with simulations or red-team-specific) not confirmed
- Vishing architecture not selected — strategy defers vishing entirely

---

## Design goal

Give a security admin a guided, trustworthy, and operationally complete flow to configure and launch a multi-channel red team campaign — with no compliance surprises, no ambiguous delivery outcomes, and full visibility into who was reached, on which channel, and what happened next.

---

## Key constraints

- **DS pattern:** Stillsuit DS v2 wizard pattern — 8 steps, back navigation preserves form state
- **Reference pattern:** SMS phishing wizard (inherit structure; adapt steps 2, 4, 5, 6 materially; add two new steps: Channel Selection and Compliance Pre-flight)
- **v1 channels:** SMS and WhatsApp only; architecture must support Viber, Telegram, vishing without re-engineering
- **Vishing:** Excluded from v1 design scope — architecture decision (self-serve vs. managed service) unresolved; do not design any vishing wizard steps until Eng confirms the model
- **WhatsApp Business API:** Feasibility for arbitrary custom messages unconfirmed; strategy assumes template-based sends until Eng validates; flag this dependency at the Channel Selection step
- **Individual targeting:** Net-new UX pattern not present in simulations — requires a new people-search component; flag for DS review
- **Compliance Pre-flight:** New wizard step type with no current Stillsuit DS v2 equivalent — requires DS review before detailed design
- **Multi-channel coverage indicator:** Multi-dimensional (per-channel breakdown), not a single percentage — new component variant; flag for DS review

---

## Strategy options

### Option A: Red Team as an extension of existing campaign types
Add a "Red Team" type selector to the existing Simulations wizard. Channel selection is a dropdown inside an existing step. All campaign types share one wizard and one campaign list.

**Pros:** Minimal new navigation surface. Reuses existing admin mental model.

**Cons:** Compliance model for red team is materially different from simulations — a shared wizard creates ambiguity about what each step means per type. Lucy's implementation of this approach (smishing behind Expert Mode inside a standard wizard) is the canonical anti-pattern. Remediation suppression (a red team requirement) has no home in a simulation-purpose wizard. The individual targeting mode and per-channel coverage indicator would require significant wizard step surgery, not additive steps. Mixed campaign lists (red team exercises alongside phishing simulations) create reporting confusion. **Rejected.**

---

### Option B: Dedicated Red Team section with purpose-built wizard (recommended)
Add "Red Team" as a sub-nav item under Simulations, parallel to "Smishing." The Red Team section has its own campaign list, template library tab, and creation wizard. The wizard inherits the SMS phishing wizard's structure and DS components but has two new steps (Channel Selection, Compliance Pre-flight) and materially adapted steps for audience, delivery, remediation, and review.

**Pros:** Clear separation of adversarial exercises from training simulations at the navigation, reporting, and RBAC level. Compliance Pre-flight becomes a first-class wizard step — a genuine market differentiator. Remediation suppression is a natural default in a red-team-only wizard. Multi-channel architecture (step 1 channel selection → downstream steps adapt) produces the cleanest targeting, coverage, and template experience. Mirrors the SMS phishing architecture decision (Option B won there for the same reasons). Extensible to Viber, Telegram, vishing as additional channel cards in Step 1 without rewiring the wizard.

**Cons:** Separate navigation adds a surface. Admins cannot see red team campaigns and simulations in one unified list without a future cross-type campaign view (Should priority — same tradeoff accepted for the SMS phishing section).

---

### Option C: Unified Campaign Launcher with channel/type selector at step 0
Redesign the entire campaign creation experience to unify Email, Smishing, and Red Team under one entry point with a type + channel selector before the wizard.

**Pros:** Correct long-term direction; no duplicate wizard patterns.

**Cons:** Requires all channel types to be production-ready simultaneously. Red team compliance model and simulation compliance model are different enough that a unified wizard would need conditional branching at nearly every step — producing a more complex wizard than two simpler parallel ones. Not a v1 scope decision. **Rejected for v1.**

---

## Recommended strategy: Option B — Dedicated Red Team section with purpose-built 8-step wizard

Use a dedicated "Simulations → Red Team" sub-nav section. The section has two tabs: Campaigns and Templates. The creation wizard is 8 steps, adapted from the SMS phishing wizard:

| Step | Name | Status vs. SMS phishing |
|---|---|---|
| 1 | Channel Selection | **New** — sets the context for all downstream steps |
| 2 | Audience | **Adapted** — adds individual targeting mode + per-channel coverage breakdown |
| 3 | Template + Message | **Adapted** — adds per-channel message config (tab selector on preview panel) |
| 4 | Compliance Pre-flight | **New** — inline carrier whitelist + consent + works council status |
| 5 | Delivery | **Adapted** — adds fallback routing decision |
| 6 | Remediation | **Adapted** — adds explicit suppression toggle (default: suppressed) |
| 7 | Test Send | **Adapted** — per-channel test send + confirmation per channel |
| 8 | Review + Launch | **Adapted** — per-channel summary + stronger compliance acknowledgment |

---

## Risks and tradeoffs

**Multi-channel wizard complexity.** An 8-step wizard with conditional branching (single-channel vs. multi-channel affects steps 2, 3, 5, and 7) is more complex than the 7-step SMS phishing wizard. Each step must have a single-channel variant and a multi-channel variant — design both before moving to Figma.

**WhatsApp API dependency.** If WhatsApp Business API restricts arbitrary custom messages to pre-approved templates, the Template + Message step must surface this constraint inline. Design the channel selection step to show carrier/API status per channel — if WhatsApp is not yet cleared for custom sends, it should be visually disabled with an explanation, not silently excluded.

**Compliance Pre-flight is a new DS pattern.** The compliance status panel (carrier whitelist / consent / works council) has no Stillsuit DS v2 equivalent. This requires DS collaboration before detailed design. Do not begin Figma work on Step 4 until the DS pattern is approved.

**Individual targeting component is net-new.** A people-search input with an ad-hoc list table, overlap detection, and per-channel coverage per row is a significantly more complex audience selector than the group picker. Requires DS review as a new component pattern.

**Vishing deferred.** The strategy does not include vishing in v1. Channel cards in Step 1 should visually represent vishing as "Coming soon" (greyed card, no interaction) rather than omitting it — this communicates the roadmap without implying the capability exists.

**Open risk pipeline question.** If red team results are later confirmed to feed the same pipeline as simulations, the campaign detail view's per-user results table must show risk score deltas. The current strategy design assumes isolated results (no risk score delta column). When this is confirmed, the detail view will need a branch.

---

## Wireframe plan

### Screen 0: Red Team section — Campaign list (entry point)

**Role:** Entry point and persistent home for all red team campaigns.

**Layout:** Page header + tab bar (Campaigns | Templates) + table body + empty state.

**Header:** "Red Team" page title + tab bar + "Create Campaign" primary button (top right).

**Campaigns tab (default):**
- Table columns: Name / Channel badges (SMS, WhatsApp) / Status badge / Audience / Sent / Reached / Created / Actions (…)
- Status badges: Draft / Scheduled / Sending / Completed / Cancelled — identical DS badge pattern to SMS phishing
- Row distinction from simulations: "Red Team" type label or visual indicator on each row (confirm with DS — could be a left-edge accent or a type chip)
- Filter bar: by status, channel, date range
- Empty state: "No red team campaigns yet. Run your first adversarial exercise to test real employee behavior across SMS and WhatsApp." + "Create Campaign" CTA

**Templates tab:**
- Same structure as SMS phishing Templates tab
- Source badge: Dune Library (read-only) / Custom (editable)
- Confirm with PM whether red team templates are a shared library or separate — flag as open issue

**Permission states:**
- View-only admin: table visible; "Create Campaign" disabled with tooltip "You don't have permission to create red team campaigns"
- Admin without red team feature access: page shows locked state with explanation

---

### Screen 1: Wizard Step 1 — Channel Selection

**Role:** Admin chooses which channel(s) the campaign will use. This decision propagates to all subsequent steps — templates, coverage, delivery, compliance, and test send all adapt to the selected channels.

**Layout:** Wizard frame (Stillsuit DS v2 wizard pattern, 8 steps, step 1 active). Body: large channel card grid.

**Key components:**
- Channel cards (multi-select, not radio): SMS / WhatsApp / *(Viber — Coming soon, greyed)* / *(Telegram — Coming soon, greyed)* / *(Vishing — Coming soon, greyed)*
- Each card: channel icon + name + 1-line description + compliance note ("Requires carrier whitelist") + API status chip (Ready / Setup required)
- WhatsApp card: conditional API status chip — if WhatsApp Business API not yet validated for custom sends, shows "Template sends only — contact your CSM" with an info tooltip; card is still selectable but Next shows a callout at the compliance step
- "Both" selection: inline note appears below the cards: "Multi-channel campaigns deliver one message per user. Duplicate targeting is resolved at the audience step."
- Coming-soon cards: greyed, not interactive, "Coming soon" chip — communicates roadmap without implying capability

**Primary action:** Continue (disabled until at least one non-greyed channel is selected)

**Edge cases:**
- Only coming-soon channels exist (no eligible channels): cannot occur in v1 (SMS is always available)
- Admin selects WhatsApp only but carrier setup is incomplete: flag surfaces at Step 4 (Compliance Pre-flight); not a hard block here

---

### Screen 2: Wizard Step 2 — Audience

**Role:** Admin defines who receives the campaign. First wizard step to show multi-channel coverage. Supports groups, individuals, or both.

**Layout:** Wizard frame. Body: targeting mode selector + audience selector + coverage panel.

**Key components:**

**Targeting mode selector (segmented control — 3 options):**
- "Groups" — same group picker as SMS phishing wizard
- "Individuals" — new people-search component (see sub-section below)
- "Both" — shows both selectors stacked

**Group selector (Groups or Both mode):**
- Searchable dropdown supporting groups, departments, locations, risk cohorts
- Cooldown warning if group was recently red-teamed

**Individual selector (Individuals or Both mode — NEW DS COMPONENT):**
- Search input: "Search users by name, email, or department"
- Results table: Name / Department / Risk score badge / SMS coverage chip / WhatsApp coverage chip
- Selected individuals accumulate in a list panel below or to the right
- Maximum individual count TBD — flag as open question for Eng

**Overlap detection (Both mode only):**
- System detects individuals who are also members of selected groups
- Inline callout below the selectors: "3 individuals are also members of [Group Name]. Each will receive one message." — warning color, not danger
- "View overlaps" link opens a 480px drawer listing the affected users — Stillsuit DS v2 drawer pattern

**Per-channel coverage indicator (replaces single-percentage indicator from SMS phishing):**
- Multi-row breakdown per channel selected:
  - SMS: [progress bar] X of Y targets have SMS-compatible numbers (N%)
  - WhatsApp: [progress bar] X of Y targets have WhatsApp-reachable accounts (N%)
  - Neither: X targets have no coverage on any selected channel
- "View coverage gaps →" opens a 480px coverage drawer showing per-user channel status (name / SMS status / WhatsApp status)
- "Neither" count: if > 0, inline warning callout: "X targets will not receive any message — they have no coverage on the selected channels." Not a hard block unless X = total audience.

**Hard blocks:**
- 0% coverage on all selected channels for the entire audience: Continue disabled; inline error with resolution path

**Permission states:**
- Admin without PII access: percentages only; no "View coverage gaps" link; tooltip explanation

---

### Screen 3: Wizard Step 3 — Template + Message

**Role:** Admin selects a template and configures the message content per channel.

**Layout:** Two-column. Template library (left, scrollable) + preview panel (right, 360px device frame).

**Key components:**

**Template library:**
- Category tabs matching threat categories
- Template cards: name / category / difficulty badge / channel compatibility chips (SMS / WhatsApp)
- Filter by compatible channel (pre-filtered to channels selected in Step 1 by default; admin can remove filter)
- If template is SMS-only and WhatsApp is selected: inline note on card: "This template is SMS only. A separate WhatsApp version must be configured." — not a hard block

**Preview panel:**
- Single-channel selection: same 360px SMS bubble or WhatsApp message preview as SMS phishing
- Multi-channel selection: tab selector above preview — "SMS preview" | "WhatsApp preview"
  - SMS tab: 360px SMS bubble, 160-char counter, encoding warning on Unicode
  - WhatsApp tab: 360px WhatsApp message bubble (shows formatting: bold, italic, link preview rendering); link preview meta-warning if applicable
- Character counter, token chips ([First Name] [Company] [Department]) — same as SMS phishing

**WhatsApp link preview warning (conditional):**
- If WhatsApp is selected and the message contains a link: inline callout — "WhatsApp shows a link preview before the user taps. Ensure the preview title and image don't reveal the simulation." Info tooltip with guidance on setting neutral meta tags.
- Not a hard block — admin must acknowledge (checkbox) to proceed

**In-wizard template creation:** same "Create new template" drawer pattern as SMS phishing

---

### Screen 4: Wizard Step 4 — Compliance Pre-flight (NEW PATTERN)

**Role:** Admin confirms that all channel-level compliance prerequisites are met before the campaign can proceed to delivery configuration. This step is a first-class wizard step, not an out-of-band process.

**Layout:** Wizard frame. Body: compliance status cards per channel + resolution paths. New pattern — requires DS review before Figma.

**Key components:**

**One compliance status card per selected channel:**

*SMS Compliance Card:*
- Carrier whitelist status: ✓ Active / ⚠ Pending (shows estimated completion date) / ✗ Not started
- Consent documentation: ✓ On file / ✗ Required — "Upload consent documentation"
- Resolution link per unresolved item: "Contact your CSM" / "Upload document" (opens a file-upload drawer)

*WhatsApp Compliance Card:*
- WhatsApp Business API status: ✓ Active for custom sends / ⚠ Template sends only / ✗ Not configured
- Consent documentation: ✓ On file / ✗ Required
- Works council clearance (shown only if org has EU recipients): ✓ On file / Not applicable / ✗ Required

**Overall readiness state:**
- All items ✓: Step summary shows "Ready to proceed" — green badge. Continue enabled.
- Any item ✗: "Not ready — resolve the items above before launching." — warning badge. Continue disabled. Each unresolved item has an inline resolution CTA.
- Any item ⚠ (Pending): "Carrier setup in progress. You can configure the rest of the campaign and return when setup completes." — Continue enabled with a soft warning; campaign will not be launchable until pending items clear.

**Important design note:** This is the compliance gate that every competitor currently handles out-of-band. The pattern must make compliance state legible and actionable — not just a checklist. An admin who hits a "Pending" state should understand exactly what's happening, who owns it, and what to do while they wait. The "save as draft and return" path must be explicitly surfaced.

**Edge cases:**
- Admin sees this step for the first time (fresh tenant): likely multiple ✗ items; clear empty-state-style messaging explaining each item and pointing to the CSM or setup flow
- Carrier setup takes 4 weeks (Lucy precedent): campaign can be built, saved as draft, and launched when clearance arrives — do not trap the admin

---

### Screen 5: Wizard Step 5 — Delivery

**Role:** Admin sets the send schedule, delivery spread, and — for multi-channel campaigns — the fallback routing decision.

**Layout:** Standard wizard form. Two sections: Schedule + Delivery Behavior.

**Key components:**

**Schedule section:** Identical to SMS phishing — date/time picker, timezone selector, delivery spread toggle (ON by default, 1h/2h/4h/8h options).

**Fallback routing (multi-channel campaigns only — new):**
- Section header: "If delivery fails on a channel"
- Three options (radio or segmented control):
  - **Fall back to SMS** (available only if SMS is also a selected channel and WhatsApp is the failing channel): "If WhatsApp delivery fails for a user, attempt delivery via SMS."
  - **Surface error only:** "If any channel delivery fails for a user, show a per-user error in campaign results. No alternate send."
  - **Silent exclude:** "If any channel delivery fails for a user, exclude them from results without an error."
- Default recommendation: "Surface error only" — most transparent, least surprising for a red team exercise
- Helper text: "Fallback sends count as a separate delivery event in your campaign results."

**Region note:** Same carrier-scope note as SMS phishing if audience contains international numbers.

---

### Screen 6: Wizard Step 6 — Remediation

**Role:** Admin decides whether automated remediation fires when a target interacts with the red team campaign. Default is suppressed to preserve adversarial exercise integrity.

**Layout:** Wizard form. Suppression toggle at top; rule cards below (conditional on toggle state).

**Key components:**

**Suppression toggle (top of step — prominent):**
- Label: "Suppress remediation automation"
- Default: ON (suppressed)
- Explanation text (always visible, not behind a tooltip): "Red team campaigns are adversarial exercises. Triggering training assignment or manager notification when a target clicks a link alerts them that they were tested, compromising the exercise. Automation is suppressed by default."
- If toggled OFF: rule cards animate in below with same patterns as SMS phishing remediation step
- Toggle state is reflected in the Review + Launch summary

**Rule cards (visible only if suppression is OFF):**
- Same if/then card pattern as SMS phishing Step 5
- Cards adapt to channel: SMS-specific events, WhatsApp-specific events, or both depending on channel selection
- Default for all rules: OFF (double-default: suppression is OFF, and individual rules are OFF)
- "Skip remediation" not needed — suppression toggle already covers this

**RBAC states:**
- ServiceNow rule disabled if integration not configured (same tooltip pattern as SMS phishing)
- Manager notification disabled if manager mapping not set up

---

### Screen 7: Wizard Step 7 — Test Send

**Role:** Admin sends a preview message on each selected channel before launching to the full audience. Per-channel test confirmation required to advance.

**Layout:** Wizard form. One test send section per selected channel.

**Key components:**

**Per-channel test send sections (one per selected channel in Step 1):**

*SMS test send:*
- Recipient field: phone number input (up to 3 recipients)
- "Send Test — SMS" button
- Status: "Test sent to [number]. Check your device." / error state
- Confirmation checkbox: "I've reviewed the test SMS on a mobile device"

*WhatsApp test send:*
- Recipient field: phone number input (WhatsApp-registered numbers only)
- "Send Test — WhatsApp" button
- Status: "Test sent via WhatsApp. Check your device." / error state
- Confirmation checkbox: "I've reviewed the test WhatsApp message on a mobile device"
- Additional note: "Confirm the link preview does not reveal the simulation context before proceeding."

**Continue gate:** All confirmation checkboxes for selected channels must be checked. "Skip test send" (ghost button) shows a stronger warning than SMS phishing: "Red team campaigns target real employees on personal devices. We strongly recommend testing on each channel before launching." — still not a hard block.

**Test send note (both channels):** "Test messages are labeled [TEST] and will not affect risk scores, remediation rules, or campaign results."

---

### Screen 8: Wizard Step 8 — Review + Launch

**Role:** Full campaign summary before committing. Final compliance acknowledgment. Channel-aware launch CTA.

**Layout:** Summary cards + sticky footer with CTA.

**Key components:**

**Summary cards:**
- Channel(s) + API/carrier status chip per channel
- Audience: total count / per-channel breakdown / "neither" exclusion count / overlap resolution note
- Template(s): name / preview thumbnail / channel label
- Fallback routing setting (displayed plainly: "If WhatsApp fails → Fall back to SMS" or "Surface error only")
- Delivery: date + time + spread window + timezone
- Remediation: "Suppressed — no automation will fire" (green chip) or "Active — N rules configured" (with rule list)
- Test send: ✓ Completed per channel / ⚠ Not completed (soft warning, not a block)

**Coverage warning (if applicable):**
- "X targets will not receive any message on any selected channel. [View list]" — warning callout, not danger unless X = entire audience (hard block)
- Per-channel partial miss: "Y targets will not receive a WhatsApp message (falling back to SMS per your setting)" — info callout

**Compliance acknowledgment (stronger than simulation):**
- Checkbox (required to enable Launch): "I confirm that [Company] has appropriate internal authorization to conduct adversarial red team testing against the targeted employees, and that [Company] has a lawful basis for sending simulated attack messages via [SMS / WhatsApp] to these individuals."
- The acknowledgment copy differs materially from the simulation acknowledgment — confirm legal review of this copy before launch.

**Launch CTA:** "Launch Campaign" (primary, disabled until compliance checkbox checked). "Save as Draft" (ghost button).

**Hard blocks (Launch button stays disabled):**
- Any compliance item in Step 4 is ✗ (not pending — red, unresolved): launch blocked, inline error directing back to Step 4
- 0% coverage on all channels for entire audience

---

### Screen 9: Campaign detail view — Red Team

**Role:** Post-launch monitoring and results for a single red team campaign.

**Layout:** Page header + per-channel stats row + per-channel timeline + per-user results table.

**Key components:**

**Header:** Campaign name / "Red Team" type badge / channel badges (SMS, WhatsApp) / status badge

**Per-channel stats sections (one section per channel, collapsible):**
- *SMS section:* Targeted → Delivered → Clicked → [Form submitted if applicable] → Fallback events (if WhatsApp fell back to this channel)
- *WhatsApp section:* Targeted → Delivered → Clicked → Failed (count) → Fell back to SMS (count, if fallback enabled)
- Aggregate row: total reached across channels (deduplicated — each user counted once)

**Remediation status banner:**
- If suppressed: "Remediation automation was suppressed for this campaign. No training was assigned and no manager notifications were sent." — info banner, neutral tone
- If active: collapsible remediation log (same pattern as SMS phishing)

**Per-user results table:**
- Name / Department / Channel received (SMS / WhatsApp / Fell back to SMS / Not reached) / Delivery status / Clicked / [Form event] / Remediation status (Suppressed / Training assigned / N/A)
- "Not reached" rows: failure reason chip (Invalid number / Not on WhatsApp / Carrier rejection / Excluded)
- Sort and filter above table (by channel, delivery status, click status)
- Export: CSV of full results

**Risk score delta column:** Absent by default (isolated pipeline assumption). If PM confirms integrated pipeline, add before/after risk score badge pair per user — same pattern as SMS phishing detail view.

---

### Screen 10: Individual targeting — people search component (Step 2 variant)

**Role:** When admin selects "Individuals" or "Both" targeting mode in Step 2, this component replaces or supplements the group selector.

**Layout:** Search input + results table (left/main) + selected individuals panel (right or below).

**Key components:**
- Search input: "Search by name, email, or department" — debounced, min 2 characters
- Results table: Name / Department / Risk score badge / SMS coverage chip (✓ / ✗) / WhatsApp coverage chip (✓ / ✗) / "Add" button per row
- Selected individuals panel: running list of added users with per-user channel coverage chips; "Remove" per row
- Bulk add: "Add all in results" (use with care — limit results before using)
- Coverage summary bar: updates live as individuals are added (same multi-row coverage breakdown format as group coverage)

**Overlap detection (Both mode):**
- "Overlap" chip appears on rows in the individuals panel if the user is also a member of a selected group
- Summary callout: "N individuals are also in a selected group. Each will receive one message."

**DS note:** This is a net-new component pattern — not a variant of an existing Stillsuit DS v2 component. Requires DS review and component definition before Figma work on Step 2 begins.

---

## Open issues

1. **[PM] Risk score pipeline: isolated or integrated?** Strategy assumes isolated (no risk score delta column in campaign detail). If confirmed integrated, the per-user table requires a before/after risk badge pair — design branches on this answer.

2. **[Eng] WhatsApp Business API custom message feasibility.** Channel selection step shows WhatsApp API status chip. If arbitrary custom sends are not feasible, the chip shows "Template sends only" and the template step must constrain to pre-approved WhatsApp templates. Design the channel card with both states before Figma.

3. **[PM] Template library model.** Strategy shows a red team template library tab but doesn't specify whether it shares the simulation library or is separate. Confirm before designing Screen 0 (Templates tab) and Screen 3 (template library panel).

4. **[PM/Eng] Individual targeting max count.** The people-search component needs an upper bound. If targeting 500 named individuals is a valid use case, the component needs pagination and bulk-add behavior. Confirm before DS component work begins.

5. **[DS] Compliance Pre-flight panel pattern.** Step 4 is a new structural pattern in the wizard — a "readiness checklist" step where the system surfaces third-party state (carrier, API, legal docs) before proceeding. No Stillsuit DS v2 equivalent. Requires DS collaboration to define the pattern before Figma.

6. **[DS] Per-channel coverage indicator.** Multi-row breakdown (SMS / WhatsApp / neither) is a new variant of the existing coverage indicator. Requires DS review.

7. **[DS] Individual targeting people-search component.** Net-new component. Requires DS review and component spec before Figma work on Step 2 begins.

8. **[Legal] Compliance acknowledgment copy.** The stronger red-team-specific acknowledgment in Step 8 must be reviewed by legal before it ships. Don't finalize copy in Figma — leave a placeholder and flag for legal review in the design file.

9. **[PM] Sub-role RBAC visibility.** Who can see red team campaign results beyond the launching admin? If department managers get a read-only view, the campaign detail must have a restricted-data variant.

10. ~~**[Eng] Vishing architecture.**~~ **Deferred.** Vishing is explicitly out of v1 design scope. Channel card shows "Coming soon" state. No wizard steps designed.

---

## Next design actions

1. **Resolve DS dependencies before opening Figma.** Three components require DS alignment before any screen work begins: (a) Compliance Pre-flight wizard step pattern, (b) per-channel coverage indicator variant, (c) individual targeting people-search component. Schedule a DS sync; bring this strategy doc.

2. **Get Eng confirmation on WhatsApp Business API feasibility.** Design the Channel Selection card (Screen 1) with both states — "Active for custom sends" and "Template sends only" — so Figma work doesn't need to wait. But confirm before the template library and message configuration steps are designed.

3. **Design Screen 1 (Channel Selection) first.** It's the simplest new screen with the highest downstream impact — every subsequent step depends on knowing which channels were selected. Validate the card layout and multi-select pattern before proceeding.

4. **Design Screen 2 (Audience) second — single-channel variant first.** Single-channel audience step with group targeting only is the closest to existing patterns (SMS phishing Step 1 reference). Once approved, layer in individual targeting and the multi-channel coverage breakdown.

5. **Design Screen 4 (Compliance Pre-flight) as a standalone component first.** Don't design it inside the full wizard until the DS pattern is approved. Start with a 3-card (SMS + WhatsApp + aggregate readiness) layout and iterate with DS.

6. **Use the SMS phishing design files as a structural reference for Screens 5–8.** Steps 5, 6, 7, 8 are adaptations of the SMS phishing wizard steps 4–7. Open the SMS phishing Figma file and adapt rather than starting from scratch.
