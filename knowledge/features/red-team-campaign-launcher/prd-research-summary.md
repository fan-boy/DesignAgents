# PRD Research — Red Team Campaign Launcher
Dune Security · Feature Research · Last updated: 2026-05-08

---

## Feature summary

The Red Team Campaign Launcher lets security admins run adversarial test campaigns against real employees using SMS and WhatsApp (v1), with architecture for Viber, Telegram, and vishing. Campaigns can target individual users, groups, or both. The launch flow lives inside or alongside the existing campaign scheduler, inheriting the SMS phishing wizard as its base UI pattern.

**Critical distinction from simulations:** Red team campaigns are adversarial assessments of real security posture — not educational exercises. This difference drives materially different requirements for risk pipeline integration, compliance/consent, RBAC, and remediation behavior. The PRD brief does not yet surface this distinction explicitly, which is the single largest design risk.

**Missing from brief:** No success metrics defined. No compliance position for red team vs. simulation. No decision on whether red team is a separate campaign type or an extension. No multi-channel targeting model selected. These are blocking gaps, not optional clarifications.

---

## Gaps and ambiguities

1. **Separate campaign type vs. extension — the foundational decision.** The brief says the launch flow lives "inside or alongside" the existing scheduler, leaving this open. If red team is a separate type, it gets its own nav section, data model, and reporting surface. If it's an extension, it shares the simulation wizard but gains channel and targeting options. Every downstream design decision — navigation, risk pipeline, RBAC, compliance acknowledgment — branches on this choice. The channel scope (SMS + WhatsApp vs. SMS-only simulations), targeting model (individuals vs. groups-only), and compliance stakes all push toward separate type. `[PM]`

2. **Risk score pipeline: isolated vs. integrated is unanswered.** If red team results feed the same pipeline as simulations, a failed red team test permanently changes a user's risk profile — based on targeting the admin chose, not the user's training trajectory. This may be intentional (unified risk picture) or a trust/fairness risk (employees penalized for adversarial exercises). If red team results are isolated, they need a separate reporting surface outside the user risk dashboard. Neither path is designed yet. `[Both]`

3. **Compliance and consent requirements are underspecified.** The SMS phishing model (customer confirms lawful basis via checkbox at campaign creation) is a customer-responsibility baseline appropriate for training simulations. Red team campaigns are higher-deception and more aggressive. WhatsApp messages arrive on personal devices and are governed by WhatsApp's Business Policy (which prohibits bulk sends without opt-in). Whether the existing compliance acknowledgment is sufficient — or whether red team campaigns require legal-level approval, additional employee notice, or a Dune policy layer — is not addressed. `[PM]`

4. **WhatsApp Business API constraints may invalidate v1 WhatsApp scope.** WhatsApp Business API requires: Business account approval, pre-registered message templates for bulk sends, and recipient opt-in before a business can message them. If these constraints apply to red team lures (arbitrary custom messages), WhatsApp v1 may be limited to pre-approved templates only — which significantly reduces the adversarial realism that makes red teaming valuable. This is an Eng discovery item but is prerequisite to all WhatsApp UI design. `[Eng]`

5. **Multi-channel targeting model is unselected.** Three models are possible:
   - **Campaign-level default:** All targets receive the same channel. Simpler; appropriate for bulk exercises.
   - **Group-level override:** Group A gets SMS, Group B gets WhatsApp. Enables channel comparison.
   - **User-level override:** Admin specifies channel per target. Most realistic for targeted adversarial exercises; most complex to design.
   These are different interaction models, not design variations. Without a decision, the wizard's audience and delivery steps cannot be designed. `[PM]`

6. **"Individual user" targeting is undefined.** SMS phishing targets groups and departments. "Individual users" is new. It's unclear whether this means a single named user (executive targeting), an ad-hoc list of named users, or any subset not organized as a formal group. Individual targeting may warrant different RBAC controls (e.g., requires a second admin to approve) given the adversarial nature of red teaming. `[PM]`

7. **Delivery failure behavior is undefined.** If WhatsApp delivery fails, three behaviors are possible: fall back to SMS (silent to admin), surface a per-user error in the campaign detail, or silently exclude the user. This is a product decision with direct UX consequences for the delivery status model and per-user results table. `[PM]`

8. **Remediation automation conflicts with adversarial exercise design.** If red team campaigns auto-trigger training assignment or manager notification (as simulations do) immediately on a click or interaction, the target is alerted that they were tested. This breaks the adversarial premise — the subject should not know the exercise happened until the debrief. The remediation step must support explicit suppression for red team campaigns, or the feature is compromised. `[PM]`

9. **RBAC sub-role visibility is unconfirmed.** The brief says Admin-initiated without addressing whether sub-admins, compliance viewers, or department managers get read-only access to red team results. Red team results are more sensitive than simulation results — they reveal specific adversarial vulnerabilities for named individuals. Treating red team and simulation results as equivalent from an RBAC perspective may not be acceptable. `[PM]`

10. **Success metrics are absent.** The brief defines no success criteria. Without a target (launch in under N minutes? N% of pilot customers run a second red team in M days?), there's no design optimization target.

---

## Missing states

### System states
- WhatsApp delivery failure: account not approved, message template rejected by WhatsApp Business API, target not on WhatsApp
- WhatsApp Business API rate limit mid-campaign
- Partial multi-channel delivery: SMS sent to some targets, WhatsApp pending or failed for others — mixed delivery status on the campaign detail
- Fallback routing: WhatsApp fails → SMS fallback (if enabled) vs. per-user error
- Vishing call not answered: voicemail, no answer, call blocked — how is this recorded?
- Individual + group targeting overlap: same user appears in both the individual list and a targeted group
- Campaign in "Sending" state across two channels: per-channel delivery counts vs. aggregate

### Permission states
- Admin has campaign launch permission but not WhatsApp channel access (if channels are feature-flagged separately)
- Read-only admin visibility into red team results — more sensitive than simulation results
- Department manager: notified when their employee is red-teamed, or not?
- Red team campaign in progress: can a non-initiating admin modify, pause, or cancel it?
- Dual-admin approval requirement for individual targeting (if warranted by RBAC decision)

### Content states
- Zero targets with WhatsApp-reachable numbers/accounts (0% coverage for selected channel — hard block equivalent)
- Target list includes users who have opted out of SMS (WhatsApp opt-out is platform-level, not Dune-level — different handling needed)
- WhatsApp message template not yet approved by WhatsApp Business API (pending state)
- Red team template library empty (if red team templates are separate from simulation templates)
- Individual target list and group targeting both selected — overlap detection required

### Action states
- Admin cancels mid-execution: some WhatsApp messages sent, some SMS messages sent — mixed recall state (already-sent messages cannot be recalled on either channel)
- Admin targets individual who is also a group member — single contact or two?
- Remediation suppressed for red team exercise: admin intentionally disables automation — no training assignment fires even if target clicks
- Admin deactivates campaign before delivery completes — what happens to queued multi-channel sends?

### Responsive / Accessibility
- Debrief/coaching page opened inside WhatsApp in-app browser: rendering constraints differ from native mobile browser (SMS link click). WhatsApp shows link previews before tap — may expose lure URL or page title prematurely.
- Multi-channel campaign results table: must show per-channel columns without collapsing to unreadable width on 1024px breakpoints
- Vishing: no mobile debrief surface. Post-call outcome recording is an admin UI surface — confirm scope and layout.

---

## Questions for PM / Eng

1. `[Both]` Is red team a separate campaign type with its own nav section, data model, and reporting surface — or an extension of existing simulation types with additional channel and targeting options? Every downstream design decision branches on this.

2. `[PM]` Do red team campaign results feed the same risk score pipeline as simulations? If yes, a failed red team test changes the target's risk profile based on admin targeting choices, not training trajectory — this is a trust/fairness risk worth naming explicitly.

3. `[PM]` Is the SMS phishing compliance model (customer confirms lawful basis via acknowledgment checkbox) sufficient for red team? Or do red team campaigns require a higher-level approval step, given higher deception and WhatsApp's Business Policy constraints?

4. `[Eng]` Can Dune send arbitrary custom red team messages via WhatsApp Business API, or are bulk sends restricted to pre-registered message templates? If restricted, does WhatsApp v1 scope shrink to template-only lures?

5. `[PM]` When WhatsApp delivery fails for a target: fall back to SMS, surface a per-user error in campaign detail, or silently exclude? This is the primary decision driving the multi-channel delivery status model.

6. `[PM]` Should red team campaigns suppress remediation automation (training assignment, manager notification) by default to avoid alerting the target that they've been tested? Or is immediate remediation expected regardless of campaign type?

7. `[PM]` What does "individual user" targeting mean exactly — single named user, ad-hoc multi-user list, or any subset not organized as a formal group? Does individual targeting require a second admin to approve?

8. `[Both]` If a user appears in both the individual target list and a targeted group, are they contacted once or twice? Who resolves the deduplication — the system, or the admin at review?

9. `[PM]` Do sub-admin roles get read-only visibility into red team campaign results? Red team results reveal specific adversarial vulnerabilities for named individuals and may warrant a stricter visibility model than simulations.

10. `[Eng]` What is the vishing architecture? Dune-managed outbound VOIP (requires calling infrastructure, admin scheduling UI) or manual operator calls with Dune used as an outcome-recording tool (requires intake form UI, not a campaign scheduler)? These are completely different design surfaces.

---

## Design risks

**WhatsApp API constraints may block v1 WhatsApp scope before design begins.** WhatsApp Business API requires template pre-approval for bulk sends and recipient opt-in. If these constraints apply to red team lures, arbitrary custom messages are not possible at launch. This is an Eng discovery item — but designing the WhatsApp channel UI without this answer wastes design cycles.

**Remediation auto-trigger breaks the adversarial exercise.** If training assignment or manager notification fires immediately when a target clicks a red team link, the subject knows they were tested. This destroys the adversarial value. The remediation step must have an explicit "suppress for red team" mode — this is not a nice-to-have. \Design the wizard's remediation step with suppression as a first-class option, not an afterthought.

**Multi-channel targeting has no established Dune pattern.** SMS phishing is single-channel. The channel selection model (campaign-level, group-level, or user-level) produces three genuinely different interaction patterns in the wizard. Without a decision, the designer cannot begin the audience or delivery steps. Do not proceed to wireframes until the targeting model is confirmed.

**Individual + group overlap creates duplicate contact risk.** If the same user appears in both an individual target list and a targeted group within the same campaign, the system must deduplicate. The audience step must surface and resolve overlaps — without explicit handling, an executive could receive the same red team lure twice, which is both a data quality failure and an operational security incident.

**Compliance acknowledgment may be insufficient for red team.** The simulation acknowledgment is a low-friction checkbox. Red team campaigns against real users on personal messaging platforms (WhatsApp) may require legal or security leadership sign-off before launch — especially if results are not isolated from risk scoring. If the compliance model is the same as simulations, customers may launch red team campaigns without appropriate internal authorization, creating legal exposure.

**Navigation ambiguity creates operational confusion.** "Inside or alongside the existing campaign scheduler" is not a navigation decision. If red team campaigns appear in the same list as simulations, admins must parse two fundamentally different types of exercises from the same table. At minimum, red team campaigns need a prominent type badge; at best, a separate sub-nav section keeps the concerns cleanly separated.

---

## Teaching notes

**Inherit from SMS phishing (`sms-phishing/design-strategy.md`):**
- Wizard structure: 7-step pattern with Stillsuit DS v2 components — same skeleton applies. Adapt step names and content for multi-channel.
- Audience selector with coverage indicator: reuse the pattern; adapt to show per-channel coverage (X have SMS, Y have WhatsApp, Z have neither). The coverage indicator must be multi-dimensional, not a single percentage.
- Campaign list + detail view: reuse layout; add channel badge and type badge (Red Team vs. Simulation). Graduated stats row adapts to channel-specific events.
- Compliance acknowledgment at review step: reuse the pattern, but confirm whether red team requires a stronger version.
- Test send step: reuse; adapt to send a test via each channel in scope (test SMS, test WhatsApp separately).
- Delivery spread toggle: reuse pattern; multi-channel delivery spread may need per-channel controls.

**What must change vs. SMS phishing:**
- **Channel selector:** New UI pattern. Either a step-1 addition (select channels before audience) or embedded in the delivery step. No existing Dune precedent — establish this pattern before the wizard is designed.
- **Multi-channel coverage indicator:** SMS phishing shows "428 of 512 have phone numbers (84%)." Red team needs "X have SMS, Y have WhatsApp, Z have both, W have neither" — a multi-row coverage breakdown per channel, not a single coverage percentage.
- **Template model:** Red team templates may be distinct from simulation templates (more realistic, higher-deception lures). Confirm whether template library is shared or separate. If separate, the Step 2 template library is net-new.
- **Remediation step:** Must offer explicit "Suppress remediation automation" option for adversarial exercises. This is a new state not present in the simulation wizard.
- **Campaign type badge:** Red team campaigns must be visually distinct from simulations in all lists, detail views, and reporting surfaces — a prominent badge, not a filter-level distinction.
- **Risk pipeline routing:** If red team results are isolated, the campaign detail view does not show risk score deltas in the same way as simulations. The per-user results table must reflect this.

**WhatsApp-specific rendering constraint:** WhatsApp links open in WhatsApp's in-app browser, not Safari or Chrome. Debrief pages must be tested in this context — rendering constraints differ. WhatsApp also shows link previews (URL + page title + meta image) before the user taps a link — this may prematurely expose the lure page's purpose. The debrief page's meta tags must be designed to not reveal the simulation.

**Vishing architecture dependency:** Two plausible architectures produce completely different design surfaces: (1) Dune-managed VOIP with an outbound call scheduler and auto-recorded outcomes (requires a calling infrastructure UI alongside the campaign wizard); (2) Manual operator calls with Dune used as an outcome-recording tool (requires an intake form, not a campaign scheduler). Do not begin vishing design without architecture clarity from Eng.

**Closest competitor reference for multi-channel red team:** Before designing the channel selection and multi-channel targeting patterns, run `/competitor-intelligence` on KnowBe4 PhishER/PhishRIP and Proofpoint Threat Simulation. Neither Dune's existing flows nor the Stillsuit DS v2 component library has an established multi-channel targeting pattern.
