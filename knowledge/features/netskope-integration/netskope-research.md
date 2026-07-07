# Netskope — Technical Research Brief

Dune Security · Feature research input · Compiled 2026-07-07

Purpose: ground the Netskope Risk Score Integration PRD in what Netskope's platform actually
exposes via API, how that data maps to an individual user, and what prior art exists for
competitors doing something similar — specifically Living Security, which already ships a live
Netskope integration. This file is a supporting research doc for `prd-creator`, not a PRD itself.

---

## 1. Platform shape: Netskope is user-centric by default — the opposite problem from CrowdStrike

Unlike CrowdStrike (device/identity-centric, requiring a derived join to reach a "user"), Netskope's
core data model is built around the **user identity** from the start. Every Netskope Client
deployment, CASB/SWG policy, and DLP/threat event is tied to a user identity synced from the
customer's IdP via SCIM 2.0 or SAML-driven provisioning (UPN or email as the join key). This is
the same IAM identity key Dune already resolves through SSO/SCIM — so user mapping for Netskope is
structurally simpler and less lossy than the CrowdStrike case (no shared-device or
service-account attribution problem to solve).

Netskope also already computes its own native per-user risk score — the **User Confidence Index
(UCI)** — as part of its Advanced UEBA module. This is the single most important asset for this
integration:

| Data surface | What it returns | User-linkage path |
|---|---|---|
| **User Confidence Index (UCI)** | Per-user behavioral risk score, 1–1000 scale (starts at 1000 for a new user, decreases with each behavioral alert); available via REST API v2 UCI Impact endpoints | Direct — natively keyed to the same user identity as everything else in Netskope |
| **DLP alerts** | Data loss policy violations: sensitive data exfiltration attempts, policy name, severity, destination app/site | Direct per-user (`user` field on every alert) |
| **Malware alerts** | Malware detected in web/cloud traffic tied to the user's session | Direct per-user |
| **Malsite alerts** | Malicious site access attempts | Direct per-user |
| **Compromised Credential alerts (CTEP)** | Credentials found exposed in breach data, tied to the user's identity | Direct per-user |
| **UBA (User Behavior Analytics) alerts** | Anomalous behavior: atypical data movement, unusual app usage patterns, insider-threat indicators — the raw signal feed that composes UCI | Direct per-user |
| **Security Assessment alerts** | Composite scored security events combining multiple signal types | Direct per-user |
| **Policy / Quarantine / Remediation alerts** | Enforcement actions taken (file quarantined, session blocked) in response to a policy violation | Direct per-user |
| **Watchlist alerts** | User flagged on an admin-defined watchlist (e.g. departing employees, high-privilege accounts) | Direct per-user |
| **Cloud app usage / Shadow IT (CCI)** | Unsanctioned app usage, Cloud Confidence Index rating of apps in use | Direct per-user via session logs |

**Implication for the PRD:** because Netskope already ships a composite per-user risk score (UCI),
Dune has two viable integration shapes, not one — (a) ingest UCI directly as a single pre-computed
signal, or (b) ingest the underlying alert categories (DLP, malware, compromised credential, UBA,
watchlist) as separate weighted inputs, mirroring the CrowdStrike category-weight pattern already
built. **Recommendation: support both**, but default to category-level weighting for consistency
with the CrowdStrike integration's admin mental model — UCI can be surfaced as an additional,
optional single-signal category ("Netskope Behavior Confidence") for tenants that have it licensed,
rather than replacing granular weighting. This keeps the admin experience consistent across
integrations rather than introducing a second, differently-shaped weighting UI.

---

## 2. Concrete signal candidates for a Dune risk score input

Grouped by what they would represent behaviorally, with the raw field/endpoint to source them:

### A. Composite behavioral risk (strongest signal — requires Advanced UEBA add-on)
- User Confidence Index (1–1000, inverted so lower = riskier) — pre-blended by Netskope from all
  behavioral alert types below
- Netskope's own severity bands: 651–1000 good, 351–650 moderate, ≤350 poor (defaults; admin-tunable
  in Netskope itself, so Dune should treat these as directional, not hardcoded)

### B. Data loss risk (requires DLP module — widely licensed, part of base/SSE tier)
- DLP policy violation count and severity, weighted by data classification (e.g. PII/PCI/PHI
  violations should weight higher than generic policy matches)
- Destination risk — was sensitive data moved to an unsanctioned or low Cloud Confidence Index app

### C. Threat exposure risk (requires CASB/SWG inline — base tier)
- Malware detections in the user's web/cloud traffic
- Malicious site (malsite) access attempts
- Compromised credential (CTEP) flags tied to the user's identity — arguably the single strongest
  "this specific person is a target/victim" signal available, and it's in the base alert set,
  not gated behind Advanced UEBA

### D. Shadow IT / app risk (requires CASB — base tier)
- Volume and risk-tier (Cloud Confidence Index) of unsanctioned app usage attributable to the user
- Local/personal cloud storage upload activity (a classic exfiltration-adjacent behavior)

### E. Enforcement history (requires policy/quarantine module — base tier)
- Frequency of policy-triggered quarantine or remediation actions against the user — a proxy for
  "how often does this person's activity require intervention," distinct from raw alert volume

### F. Admin-flagged risk (requires Watchlist configuration — no extra license, admin-configured in Netskope)
- Whether the user is on an admin-defined Netskope watchlist (e.g. flight-risk employees,
  privileged-access holders) — binary/contextual signal, not a graduated score

**Design implication:** categories B–F are available on Netskope's base SSE tier (SWG + CASB +
inline DLP), which is a materially higher attach rate than CrowdStrike's ITDR/Spotlight/Discover
add-ons. This means the Netskope integration will likely expose *more* weight categories to *more*
clients out of the box than CrowdStrike does — worth naming explicitly in the PRD so admins aren't
surprised by an asymmetric capability set between integrations they've connected.

---

## 3. Module/licensing gating — same discipline as CrowdStrike, different attach-rate shape

Netskope sells in tiers and add-ons on top of a base Netskope One platform license:

- **Netskope One SSE (base tier)** — SWG, CASB (inline), basic DLP. This is the common baseline
  across Dune's client base and already covers categories B, C, D, E, F above.
- **Advanced UEBA** — separate per-user-per-year add-on. Required for UCI and full UBA alert
  detail (category A). Lower attach rate than the base tier, similar dynamic to CrowdStrike's
  Identity Protection module.
- **Advanced Analytics / DSPM / DEM** — separate add-ons, not required for the signal categories
  identified above but may become relevant for future signal categories.

Because Dune sells across verticals and company sizes, the same **capability-detection principle
from the CrowdStrike integration applies here**: at connection time, Dune must probe which
Netskope API scopes/alert types the provided credentials can actually return data for, and only
expose weight controls for categories the tenant's license supports. Given Netskope's base tier
already covers most categories, most clients should see a fuller weighting panel than they would
for CrowdStrike — the gating logic should be shared infrastructure between the two integrations
if Dune builds this as a generalized "external risk signal" framework (see open questions).

---

## 4. Data delivery mechanics

| Mode | Latency | Notes |
|---|---|---|
| REST API v2 polling (token-based auth via `Netskope-API-Token` header) | Minutes–hours depending on poll interval | Simplest to build; matches Dune's existing snapshot-diff pattern and the CrowdStrike integration's v1 approach |
| Log streaming / SIEM connectors (Netskope's native integrations with Splunk, Panther, Chronicle, Exabeam, Cribl, Edge Delta) | Near real-time | Built for SIEM ingestion, not a natural fit for Dune to consume directly in v1 |
| Netskope Cloud Exchange — Risk Exchange module | Near real-time, purpose-built for cross-vendor risk score aggregation | See section 5 — this is the more strategically interesting delivery path long-term |

**Recommendation surfaced to PRD:** v1 should use REST API v2 polling on a scheduled cadence,
consistent with the CrowdStrike integration's v1 architecture. Netskope's API token model
(a single static API token per tenant, sent via the `Netskope-API-Token` header) is simpler than
CrowdStrike's OAuth2 client-credentials flow — the credential-entry step in the Connect flow will
have fewer fields (tenant URL + API token, no region dropdown, no client secret) than the
CrowdStrike equivalent. This should be reflected in the PRD's connect flow rather than reusing the
CrowdStrike step structure unchanged.

---

## 5. Prior art — Living Security already ships a live, bi-directional Netskope integration

This is the most important competitive finding in this research and should anchor
`competitor-intelligence`:

- **Living Security × Netskope (announced November 2025):** Living Security's Unify platform has a
  named, bi-directional partnership with Netskope. Living Security's human risk signals — phishing
  susceptibility, credential hygiene, DLP policy violations — feed directly into Netskope's UCI,
  and Netskope's enforcement engine uses the resulting score to dynamically adjust access controls
  (adaptive, risk-informed access restrictions rather than binary block/allow policies). This is
  materially different from what Dune is being asked to build: Living Security both **consumes**
  Netskope signals into its own risk score AND **writes back** into Netskope's UCI to drive
  Netskope-side enforcement. Dune's current scope (per the PRD ask) is consume-only — pull Netskope
  data to affect Dune's risk score, with no write-back. This is a real capability gap worth naming
  as a v2 opportunity rather than silently matching Living Security's scope in v1.
- Living Security also ships a **generalized ingestion architecture**: Unify already has prebuilt
  integrations across Endpoint, Email, Web, IAM, SIEM, UEBA/DLP, and Training/LMS categories
  (including CrowdStrike, Netskope, Okta, Sophos, Tenable, Zscaler, and others), plus a push API for
  custom sources. This directly informs the open question below about whether Dune should build a
  generalized "external risk signal" framework now rather than a second bespoke integration —
  Living Security's product shape suggests the market expects a platform, not a series of one-off
  integrations.
- Living Security's Human Risk Index (HRI) methodology (per Cyentia Institute research cited in
  Living Security's own materials) emphasizes that a small fraction of users (~10%) drive the
  majority (~73%) of risky behavior — this is a useful framing reference for how Dune surfaces
  Netskope-driven risk score changes (e.g. highlighting outlier users rather than only showing
  aggregate score movement), worth carrying into `design-strategist`.
- **Egress × Netskope** is a second, smaller-scale precedent (human risk / email security signals
  feeding Netskope enforcement) — reinforces that "human risk platform feeds SSE/CASB" is becoming
  a recognized integration pattern in the category, not a one-off.

---

## 6. Open technical questions this research could not resolve (carry into open-questions.md)

- Same generalized-framework question raised in the CrowdStrike research: should Dune build a
  shared "external risk signal ingestion" architecture (capability detection, category weighting,
  user mapping review, score-breakdown surfacing) that both CrowdStrike and Netskope plug into, or
  should Netskope be built as a second bespoke integration? This research strengthens the case for
  a shared framework — the category-weighting shape (composite score option + granular category
  options) is functionally identical between the two vendors.
- Should Dune ingest Netskope's pre-computed UCI as a single signal, or decompose it into the
  underlying alert categories (or both, as recommended in Section 1)? This is a product decision,
  not just a technical one — UCI is a black box scoring model Dune doesn't control, while
  category-level ingestion gives Dune's own weighting model more transparency and consistency with
  the CrowdStrike pattern.
- Is bi-directional write-back (Dune's risk score informing Netskope's UCI/enforcement, matching
  Living Security's shipped capability) in scope for any near-term version, or explicitly out of
  scope for v1 with a documented rationale? This changes the RBAC and security review surface
  significantly if in scope.
- What is Dune's contractual/security posture on storing a customer-provided Netskope API token
  (single static token, broad scope) versus CrowdStrike's OAuth2 client-credential model — does
  Dune's existing credential storage handle both patterns without new engineering work?
- For clients without Advanced UEBA, is the category-level signal set (DLP, malware, compromised
  credential, watchlist) rich enough to be a meaningful risk input on its own, or does it need a
  "Limited Netskope Coverage" equivalent to CrowdStrike's "No Endpoint Visibility" concept for
  tenants on base-tier-only licensing?
