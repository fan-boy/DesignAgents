# PRD Research — CrowdStrike Risk Score Integration

**Derived slug:** `crowdstrike-integration`
**Output path:** `knowledge/features/crowdstrike-integration/`

**Last updated:** 2026-07-07 — three framing decisions were confirmed directly with the stakeholder
during this research pass and have been folded into `prd.md`. See **Resolved during this research**
below; the rest of this document reflects the critique as originally performed, with resolved items
also mirrored into `open-questions.md`.

---

### Resolved during this research

1. **Score framing:** CrowdStrike categories blend into one overall risk score. Device/environment
   signals (Device Posture, Unpatched Vulnerabilities) are not split into a separate score from
   behavioral signals (Identity Risk, Detected Threats, Account Hygiene) — all are weighted
   categories within a single score. The fairness/trust risk this creates (flagged below in
   **Design risks**) is an accepted trade-off to design around with clear labeling, not something
   to re-litigate in design-strategist.
2. **Missing coverage:** a user with zero CrowdStrike presence is not treated as neutral or
   excluded. A new always-present **No Endpoint Visibility** weight was added to the category set —
   having no managed device or identity record is itself a risk-relevant signal. The exact
   escalation math for this weight remains open for Eng.
3. **Mapping mechanism:** CrowdStrike data resolves to a Dune user through the same IAM identity
   (email/UPN) Dune already uses via SSO/SCIM provisioning — not a separately maintained email
   field. This is now stated explicitly in `prd.md`.
4. **RBAC scope:** Full Access admin only for v1. No narrower "integrations owner" permission is
   in scope for this feature; revisit only if RBAC's own open Super Admin question resolves first.

---

### Feature summary

A Full Access admin connects their organization's CrowdStrike Falcon tenant, and CrowdStrike-sourced
signals (identity risk, device posture, detections, vulnerabilities, account hygiene, and endpoint
visibility) become additional weighted inputs into a user's existing Dune risk score, blended
alongside training completion and simulation performance into one overall score. Success criteria
are not stated anywhere in the source material — no target adoption rate, accuracy bar, or "done"
definition exists yet. The PRD is now well-specified on the connect/weight/mapping mechanics and on
the score-framing and coverage-gap decisions above; it remains silent on the precise math for
combining CrowdStrike's contribution with existing risk inputs and on employee-facing transparency
about the new data source.

---

### Gaps and ambiguities

1. **No definition of how the CrowdStrike contribution combines with the existing risk score.** The PRD specifies independent 0–100% weights per CrowdStrike category but never states whether the overall risk score is `(existing training/simulation score) + (CrowdStrike categories × weights)`, a re-normalized blend, or something else. This is the single most consequential undefined mechanic in the PRD — it determines whether CrowdStrike can ever dominate a score, and whether existing risk score math needs to change at all. `[Both]`
2. **No score normalization scheme across categories.** ZTA is a 0–100 posture score; detections are discrete severity-weighted events; vulnerabilities are counts with CVSS/ExPRT priority; account hygiene is behavioral flags. The PRD treats these as directly comparable "categories" with a single weight slider each, but doesn't say how each raw signal becomes a normalized 0–100 sub-score before weighting is applied. Without this, admins are weighting incomparable units. `[Eng]`
3. ~~No stated treatment for users with zero CrowdStrike coverage.~~ **Resolved** — see Resolved during this research: added as an always-present "No Endpoint Visibility" weight rather than neutral/excluded. Exact escalation math is still open. `[PM]`
4. **No employee-facing disclosure described.** Dune's own trust principle requires transparency in what's tracked and why when it comes to risk scores and behavior history. This PRD introduces a new data source (their device's security posture, detections on their machine, an identity risk score) into something the employee already sees a summary of, with no mention of updating that disclosure. `[PM]`
5. **Single-tenant assumption unconfirmed.** The Connect flow assumes one CrowdStrike Client ID/Secret per Dune organization. Clients "across all verticals" plausibly include multi-subsidiary enterprises with multiple CrowdStrike CIDs (common after M&A). The PRD doesn't say whether Dune supports connecting more than one CrowdStrike tenant per organization. `[PM]`
6. **Bulk resolution for user mapping isn't addressed.** The User Mapping table describes linking one unmatched identity to one Dune user at a time. For a large client, unmatched counts could run into the hundreds. No bulk-match, suggested-match, or CSV-based resolution is described. `[Eng]`
7. **Capability re-detection over time is unspecified.** If a client purchases Identity Protection or Spotlight after the integration is already connected, does Dune automatically pick up the newly available category, or does the admin have to manually re-run capability detection? `[Eng]`
8. **No success metric or rollout signal defined anywhere in the source material.** There's no way to know if this feature is working once shipped — not even informally. Worth raising even though the PRD template intentionally omits metrics unless given; this one has none to omit. `[PM]`

---

### Missing states

**System states**
- First activation: initial full sync of a potentially large user base — no progress indicator, size estimate, or "this may take a while" messaging described.
- Partial sync failure: some categories in a single sync succeed (e.g. Hosts) while others fail (e.g. Identity Protection scope revoked) — PRD's binary "Connection error" / "Sync delayed" states don't cover a partial per-category failure.
- Capability set shrinks after initial connection (e.g. client downgrades their CrowdStrike license, revokes a scope) — no described behavior for a previously-available category becoming unavailable while historical data and weights for it still exist.

**Permission states**
- No admin persona narrower than "Full Access" is available for this integration. Given `rbac/prd.json` already flags an open question about the absence of a Super Admin distinct from Full Access, this feature inherits that same gap: a client's IT/security team who owns the CrowdStrike relationship cannot be granted access to configure this integration without full write access to the entire training platform.
- Scoped admin roles (AEP Manager, Training & Simulations Manager, Dashboard Viewer) — PRD says they don't see the Integrations surface at all, but doesn't say whether Dashboard Viewer should at least see a read-only "CrowdStrike connected" indicator on the risk score breakdown, since they can view risk scores today.

**Content states**
- Zero unmatched identities (clean mapping) — should the User Mapping table still be visible, or does it collapse/hide when there's nothing to review?
- Very large unmatched list (hundreds/thousands of rows for a large enterprise) — no pagination, search, or filter behavior described.
- A category weight is set to a non-zero value but zero users currently have data for that category (e.g. Spotlight enabled but no vulnerability data has synced yet) — the live preview panel's behavior in this state is undefined.

**Action states**
- Disconnecting the integration is described (freezes historical contribution) but with no confirmation step described, despite being a change that stops future risk score inputs for the entire organization.
- Setting all weights to 0% is functionally similar to disconnecting but the PRD treats it as a normal configuration state with no equivalent confirmation or warning — worth deciding if these two paths should feel consistent.
- Manually re-linking a mapped identity to a different Dune user (correcting a mismatch) isn't described — only initial linking of unmatched identities is.

**Responsive / Accessibility**
- Weight sliders (0–100%) need a keyboard-accessible numeric input alternative, not just drag — not specified.
- No mention of mobile/tablet behavior for the Integrations settings surface; likely out of scope but should be confirmed rather than assumed, consistent with admin-tool conventions elsewhere in the platform.

---

### Questions for PM / Eng

1. `[Both]` How does the weighted CrowdStrike contribution mathematically combine with the existing training/simulation risk score? Is there a cap on how much CrowdStrike-sourced signal can move a score in one sync cycle?
2. `[Eng]` What is the normalization method for turning ZTA scores, detection severity, CVE counts, and account hygiene flags into a common 0–100 sub-score before weights are applied?
3. `[Eng]` What is the exact scoring/escalation math for the new No Endpoint Visibility weight — how much should zero CrowdStrike coverage move a user's score by default?
4. `[PM]` Does this feature require an update to the existing employee-facing risk score transparency messaging to disclose that device/security telemetry now factors in?
5. `[PM]` Can a Dune organization connect more than one CrowdStrike tenant (multi-CID enterprises), or is this strictly one-to-one?
6. `[Eng]` Is there a bulk resolution path for user mapping (suggested matches, CSV import) for clients with large unmatched counts, or is one-at-a-time linking acceptable for v1?
7. `[Eng]` When a client's CrowdStrike license changes (module added or removed) after initial connection, does capability detection automatically re-run, or is it a manual admin action?
8. `[PM]` Is there any defined success signal for this feature (adoption, score accuracy, support ticket volume) that should shape what gets built first?

**Resolved this pass** (see Resolved during this research above): score framing (single blended score), missing-coverage treatment (No Endpoint Visibility weight), mapping mechanism (via IAM identity), and RBAC scope (Full Access only for v1).

---

### Design risks

- **Score volatility undermines calm-authority trust.** If CrowdStrike-driven changes to a user's risk score are large, frequent, or poorly explained, it directly conflicts with Dune's "calm authority, not alarm" tone principle and the requirement that risk score surfacing happen in context of action, not as raw data. Risk: an employee's score jumps because their laptop missed a patch cycle, with no framing that explains why.
- **Penalizing users for infrastructure they don't control.** Device Posture and Unpatched Vulnerabilities reflect IT/security operations, not individual behavior. Folding them into a "human risk" score without a clear distinction risks feeling arbitrary or unfair to the end user and undermines the product's premise that risk score reflects behavior, not environment. This was flagged in the technical research and is significant enough to resurface here as a design-level risk, not just a technical footnote.
- **Coverage bias.** Users without full CrowdStrike coverage (BYOD, contractors, exempted executives) will systematically score differently from fully-instrumented employees for reasons unrelated to actual risk. Left undesigned, this could produce a skewed org-wide risk picture that admins trust as ground truth.
- **Weighting-UI misconfiguration risk.** Five independent, unconstrained sliders with no recommended defaults or guardrails make it easy for an admin to produce a nonsensical score composition (e.g. 100% device posture, 0% everything else) without realizing the downstream effect on Smart Groups and Adaptive Workflows that key off risk score thresholds.
- **RBAC mismatch with real-world ownership.** Requiring Full Access to configure a security-tooling integration may force clients to either over-grant training-platform admin rights to their SecOps team or route every CrowdStrike configuration change through a training admin who doesn't own the relationship — friction that could stall adoption in exactly the enterprise segment most likely to have CrowdStrike deployed.
- **Silent cascading effects on automation.** The PRD correctly notes that Smart Groups and Adaptive Workflows are affected once CrowdStrike weights go live, but doesn't describe any admin-facing warning at the moment weights are saved (e.g. "12 users will newly enter the High Risk group and may trigger automated training assignment"). Without this, admins could unknowingly fire bulk automation.

---

### Teaching notes

- **Closest existing reference for the weighting UI:** the risk score badge and scale defined in `knowledge/design-system-rules.md` (Critical/High/Medium/Low, semantic risk color tokens, always paired with a label). Any new "CrowdStrike contribution" breakdown view must reuse this scale rather than inventing a new one, and must never show a raw sub-score number without the badge treatment.
- **Settings page, not a modal or drawer:** per `design-system-rules.md`, modals aren't for forms longer than 3 fields and drawers aren't meant for multi-section configuration. The Connect flow (3 fields) fits a modal or drawer; the 5-category weight configuration does not and should be a full settings page, consistent with how other multi-section admin configuration lives in the product.
- **RBAC precedent:** `knowledge/features/rbac/prd.json` already carries an open, unresolved question about whether a Super Admin concept distinct from Full Access exists. This feature is a concrete forcing function for that decision — don't design a one-off permission model for CrowdStrike without checking whether RBAC's resolution changes the answer.
- **Snapshot/sync precedent:** the scheduled-polling sync model proposed here mirrors the snapshot-diff pattern used elsewhere for risk-score-triggered automation (referenced in the CrowdStrike technical research brief). Reuse that mental model rather than designing a bespoke sync UX.
- **Adaptive Workflows cascade precedent:** any UI that changes risk score composition should consider the same "who will this affect" preview pattern used for group-targeted automation elsewhere in the product, extended here to include a call-out when saving weights would shift Smart Group membership or trigger Adaptive Workflows.
