# PRD Research Summary — Netskope Risk Score Integration

## Feature summary
A Full Access admin connects their organization's Netskope tenant so that Netskope-sourced
behavioral, data-loss, threat, and app-usage signals become additional weighted inputs into each
user's Dune risk score, alongside training/simulation performance and the existing CrowdStrike
integration. Success is not measured anywhere in the source material — same gap flagged for
CrowdStrike and still unresolved. Netskope's user-centric data model makes mapping structurally
easier than CrowdStrike's device-centric model, but this PRD's architecture (blended score,
IAM-identity mapping, Full Access-only RBAC, always-present no-visibility weight) was **carried
over from the CrowdStrike PRD by assumption, not re-confirmed with a stakeholder for this
feature** — that distinction matters because two of the four carried-over decisions have a
plausible reason to differ for Netskope (see Gaps #1 and #2).

## Gaps and ambiguities

1. **Carried-over architecture decisions were not freshly confirmed.** The CrowdStrike PRD states
   explicitly that single-blended-score, no-visibility-as-signal, and Full-Access-only RBAC were
   "confirmed with stakeholder." The Netskope PRD's own `prd.json` confidence notes admit these were
   reused for consistency, not re-validated. Two are worth specifically re-checking rather than
   assuming: (a) Full Access-only RBAC — Netskope ownership at a client commonly sits with
   networking/SSE teams, a different persona than CrowdStrike's SecOps owner, so the argument for a
   narrower admin role may land differently even though the prior answer was "no" for CrowdStrike;
   (b) single blended score — now that a *second* vendor is being blended into the same score,
   this is the first real test of whether the "one score, many weighted inputs" model holds up when
   two independent security vendors can report correlated signals about the same real-world event
   (see Gap #3).
2. **Behavior Confidence vs. granular category overlap is soft-warned, not resolved.** The PRD
   explicitly declines to hard-block setting both Behavior Confidence (UCI) and the five granular
   categories at meaningful weights, instead showing an inline notice. This is a genuine product
   decision, not a UI detail — it determines whether double-counting the same underlying behavior
   is a supported configuration or a mistake Dune tolerates. `[PM]`
3. **Cross-vendor signal correlation is not addressed.** With both CrowdStrike and Netskope now
   feeding one blended score, the same real-world security event can be reported by both vendors
   (e.g. a compromised credential detected by both CrowdStrike Identity Protection and Netskope's
   CTEP alerts, or a malware detection surfaced by both EDR and inline web protection). Nothing in
   either PRD addresses whether correlated signals from two vendors should be dampened, deduplicated,
   or allowed to compound the same underlying incident into a larger score movement than either
   vendor alone would produce. This did not exist as a question when CrowdStrike was the only
   integration; it exists now. `[Both]`
4. **Bi-directional write-back scope is unresolved and competitively material.** Living Security
   ships a live, named Netskope partnership today where human risk signals write back into
   Netskope's UCI to drive Netskope-side access enforcement. The current PRD is consume-only. This
   is flagged as an open question in the PRD already, but it is high-leverage enough to resolve
   before design-strategist proceeds, since a write-back capability would change the RBAC surface,
   the security review scope, and likely the Connect flow's credential/scope requirements
   (read-only token vs. a token with write scope). `[PM]`
5. **No definition of how Netskope's contribution mathematically combines with training/simulation
   AND CrowdStrike contributions together.** This gap existed for CrowdStrike alone; it compounds
   with a second source. There's still no normalization scheme across UCI's native 1–1000 scale, DLP
   severity, and CrowdStrike's various category scores into one common sub-score basis. `[Eng]`

## Missing states

**System states**
- Netskope sync and CrowdStrike sync both fail in the same window — is there a combined "integrations degraded" banner, or does each integration surface its error independently with no aggregate view?
- First activation full sync of a potentially large user base, same unaddressed gap as CrowdStrike, now recurring for a second integration — worth solving once, generically, rather than twice.

**Permission states**
- Same open gap as CrowdStrike: no admin role narrower than Full Access exists, and this PRD does not re-litigate whether Netskope specifically (given SSE/network team ownership patterns) should be the forcing function to finally resolve it.

**Content states**
- A user matched in both CrowdStrike and Netskope but flagged as "no visibility" in one and fully covered in the other — the risk score detail view's two "no visibility" flags (No Endpoint Visibility, No Netskope Visibility) appearing simultaneously on one user is not described.
- Behavior Confidence enabled but the underlying UBA data hasn't populated yet (new tenant, first sync cycle) — same "weight set before data exists" gap flagged for CrowdStrike, recurring here.

**Action states**
- Admin disables Behavior Confidence after having it enabled for a period — does historical score contribution from UCI freeze (matching the disconnect behavior) or immediately zero out?
- Correcting a mismatched user mapping (re-linking) is described for CrowdStrike's edge cases doc but not restated here — confirm the same behavior applies, don't assume silently.

**Responsive / Accessibility**
- No new considerations beyond what's already flagged for CrowdStrike's Integrations settings surface; likely resolved once, generically, when that surface is designed.

## Questions for PM / Eng

1. `[PM]` Should Full Access-only RBAC be reconsidered specifically for Netskope, given SSE/network teams — not SecOps — are the more common real-world owner of this credential at a client?
2. `[PM]` Should Behavior Confidence (UCI) and the five granular categories be mutually exclusive (hard constraint), or is a soft warning the final answer?
3. `[Both]` Is bi-directional write-back to Netskope's UCI in scope for any near-term version, given Living Security already ships this? If explicitly out of scope for v1, should the PRD state the rationale so it isn't mistaken for an oversight?
4. `[Both]` When both CrowdStrike and Netskope report signals traceable to the same real-world security event for one user, should the blended score dampen, deduplicate, or allow compounding?
5. `[Eng]` What is the combined normalization method across UCI's native scale, Netskope category severities, and CrowdStrike's category scores, now that a common sub-score basis must support two vendors, not one?
6. `[PM]` Is there a defined success signal for this feature (same unresolved question carried from CrowdStrike, now overdue given two integrations share the same open gap)?
7. `[Eng]` Does capability re-detection (license changes) and multi-tenant support need to be solved generically across both integrations, or independently per vendor? This is the same generalized-framework question raised in both technical research docs, now surfaced a second time in PRD research.

## Design risks

- **Silent architecture inheritance.** Reusing CrowdStrike's decisions without fresh confirmation is efficient but risks shipping RBAC or scoring-model choices that were right for one vendor's ownership pattern and wrong for another's, discovered only after launch.
- **Score opacity compounds with a second vendor.** The CrowdStrike research already flagged "why is my score high because IT didn't patch my laptop" as a trust risk. A second vendor doubles the number of external systems a user can't see or control that affect their score, and doubles the chance of two vendors independently penalizing the same incident — this is a bigger version of a risk already named, not a new one, and should be weighed accordingly before adding a third integration later.
- **Soft-warning the UCI/granular overlap normalizes double-counting.** If most admins ignore the inline notice, Dune's own scoring model becomes harder to explain and defend than either vendor's native score — undermining the differentiation (admin-visible, non-black-box weighting) named as Dune's competitive edge in the technical research.
- **Falling behind Living Security's shipped bi-directional capability without a stated reason reads as a gap, not a choice.** If write-back stays unresolved through design-strategist without an explicit "not now, because X" rationale, it will surface again at handoff or in competitive positioning conversations as an unaddressed weakness rather than a deliberate scope decision.

## Teaching notes

- This is the **second** instance of the risk-signal-integration pattern established by CrowdStrike. Before design-strategist proceeds, treat `knowledge/features/crowdstrike-integration/design-strategy.md` as the primary reference for how that pattern was expressed in Stillsuit DS v2 (settings page structure, category weight sliders, score breakdown section) — reuse directly rather than reinventing, but flag any place Netskope's simpler credential model (single token vs. OAuth2) or richer base-tier category set (7 rows vs. 6) meaningfully changes the layout.
- `knowledge/features/rbac/prd.json` still has the open Super Admin question flagged by the CrowdStrike research; this feature is now the *second* forcing function for that decision, which raises its priority rather than introducing a new consideration.
- Netskope's User Confidence Index scoring direction (1–1000, lower = riskier) is inverted relative to how Dune's own risk score badges typically read (higher = riskier, per `knowledge/design-system-rules.md`) — flag this explicitly in design-strategist so the UI never surfaces a raw UCI number without translating its direction to match Dune's convention.
- Reuse the "who will this affect" live preview pattern already called for in the CrowdStrike design work; do not design a second, differently-shaped preview for Netskope.
