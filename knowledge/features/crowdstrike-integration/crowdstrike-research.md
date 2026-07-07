# CrowdStrike Falcon — Technical Research Brief

Dune Security · Feature research input · Compiled 2026-07-07

Purpose: ground the CrowdStrike Risk Score Integration PRD in what CrowdStrike's Falcon platform
actually exposes via API, how that data maps to an individual user (not just a device), and what
prior art exists for competitors doing something similar. This file is a supporting research doc
for `prd-creator` — not a PRD itself.

---

## 1. Platform shape: CrowdStrike is device/identity-centric, not user-centric

Falcon's core data model is built around the **host (endpoint)** and, in the Identity Protection
module, the **identity (AD/Entra account)**. There is no single "user profile" object equivalent to
a HRIS record. Any "per-user" view Dune builds is a derived join across host, identity, and login
history data — this is the central architectural fact that should shape the PRD.

Available data surfaces (API "service collections"), each requiring its own OAuth2 scope:

| Data surface | What it returns | User-linkage path |
|---|---|---|
| **Hosts** | Device inventory: hostname, OS, sensor version, agent ID (AID), last seen, policy assignment, sensor health/tamper status | `last_login_uid` field + `QueryDeviceLoginHistory(V2)` — recent interactive login sessions per device |
| **Zero Trust Assessment (ZTA)** | Per-device security posture score (`overall` field, 0–100) covering OS patching, sensor config, security posture | Via device AID → login history → user |
| **Detections** | Endpoint alerts: severity, MITRE ATT&CK tactic/technique, process context, device info, status, first/last occurrence | Via device AID → login history → user |
| **Incidents / CrowdScore** | Cross-host correlated incidents (grouped detections/behaviors); CrowdScore is an environment-wide (not per-user) composite risk score | Incident → constituent hosts → users |
| **Spotlight (vulnerabilities)** | Per-host CVE exposure, ExPRT.AI priority rating, CISA KEV flag, remediation status | Via device AID → login history → user |
| **Discover** | Asset/application inventory, **local account usage**, shadow IT application discovery | Direct account-level records (closest thing to a "user" object) |
| **Identity Protection (ITDR)** | Per-**identity** risk score (not per-device) — built from authentication behavior, anomalous access patterns, lateral movement indicators, stale/privileged account flags | Direct — this module is natively identity-keyed (AD/Entra account, email) |
| **Event Streams / Falcon Data Replicator (FDR)** | Real-time or near-real-time firehose of the above event types | Same joins as source data, but push-based instead of polled |

**Implication for the PRD:** if the client has the Identity Protection (ITDR) module licensed,
Dune gets a clean per-identity risk score for free — the best-fit signal. If they only have core
Falcon Insight (EDR), Dune must construct the user mapping itself via device login history, which
is lossier (shared devices, service accounts, contractors using personal devices are not covered).

---

## 2. Concrete signal candidates for a Dune risk score input

Grouped by what they would represent behaviorally, with the raw field/endpoint to source them:

### A. Identity risk (strongest signal — requires Falcon Identity Protection add-on)
- Identity Protection risk score per account (continuous value; CrowdStrike publishes a documented
  conversion: `|1 − risk_score| × 1000` used in some partner integrations — treat as directional,
  not a fixed spec until confirmed against the live tenant's API version)
- Anomalous authentication patterns (impossible travel, atypical time-of-day access, MFA bypass attempts)
- Stale, dormant, or privileged account flags tied to the identity

### B. Device posture risk (requires core Falcon Insight/EDR)
- ZTA overall score for the user's primary device(s) — degraded posture (unpatched OS, sensor
  tampering, misconfigured sensor) is a proxy for user risk exposure, not user behavior
- Sensor health / tamper-protection status on the user's device

### C. Behavioral/detection risk (requires core Falcon Insight/EDR)
- Detections attributed to the user's device, weighted by severity and MITRE tactic (e.g.
  credential access, defense evasion should weight higher than benign/informational detections)
- Incident membership — was the user's device part of a correlated multi-host incident

### D. Exposure risk (requires Spotlight add-on)
- Count/severity of unpatched CVEs on the user's device, weighted by CISA KEV status and
  ExPRT.AI priority — this is closer to "device debt" than user behavior, worth flagging as a
  distinct weight category from behavioral signals

### E. Shadow IT / account hygiene (requires Discover add-on)
- Local admin account usage patterns, unsanctioned application usage on the user's device

**Design implication:** these five categories map naturally to distinct admin-configurable weight
sliders, not one opaque "CrowdStrike score." Categories B and D reflect device/environment
posture the user doesn't fully control — mixing them with genuinely behavioral signals (C, and
identity risk in A) without labeling the distinction risks feeling unfair to end users ("why is my
risk score high because IT didn't patch my laptop"). This is a design risk to carry into
`prd-research`.

---

## 3. Module/licensing gating — critical for a "wide variety of clients across all verticals"

CrowdStrike Falcon is sold in modular add-ons on top of the core Falcon Insight (EDR) SKU. Not
every Dune client will have every module:

- **Falcon Insight (EDR)** — Hosts, Detections, Incidents, ZTA. Reasonably common baseline.
- **Falcon Identity Protection (ITDR)** — separate paid module. Best per-user signal, but
  meaningfully lower attach rate, especially in mid-market.
- **Falcon Spotlight** — separate paid module for vulnerability management.
- **Falcon Discover** — separate paid module for asset/account/app inventory.

Because Dune sells across verticals and company sizes, **the integration must degrade gracefully
per client based on which modules their CrowdStrike tenant actually has enabled** — this cannot be
assumed uniform. The PRD needs an explicit "capability detection" step at connection time (query
which scopes/endpoints the provided API credentials can actually access) and the weighting UI must
only expose sliders for signal categories the client's tenant can supply. An admin should never see
a weight control for data their org doesn't have.

---

## 4. Data delivery mechanics (architecture-relevant, not just UI)

| Mode | Latency | Notes |
|---|---|---|
| REST API polling (OAuth2, ~30 min token expiry) | Minutes–hours depending on poll interval | Simplest to build; matches Dune's existing snapshot-diff pattern used elsewhere (agent triggers) |
| Event Streams | Near real-time, persistent connection | Needed only if a "real-time coaching" style trigger is in scope |
| Falcon Data Replicator (FDR via S3) | Near real-time, high volume | Enterprise-tier data firehose; likely overkill for v1 |

**Recommendation surfaced to PRD:** v1 should use REST API polling on a scheduled cadence,
consistent with Dune's existing snapshot-diff architecture for other risk-affecting triggers
(referenced in the remediation agent pattern). Real-time streaming is a plausible v2 if
"instant" risk score updates or real-time coaching nudges become a requirement — flag as an
explicit open question rather than scoping it into v1 silently.

Auth model: CrowdStrike uses OAuth2 client credentials (API client ID/secret created per-tenant
in the CrowdStrike console, scoped to specific read permissions). This is a per-client, per-tenant
credential — the admin setup flow needs a place to input and validate these credentials, similar
to any other customer-managed API key integration.

---

## 5. Prior art — how competitors already do this

- **KnowBe4 × CrowdStrike (SecurityCoach):** Uses CrowdStrike security telemetry to detect a
  security event on a user's device, then triggers real-time micro-coaching content to that user.
  This is a "trigger training from a signal" pattern, not primarily a "feed a score" pattern —
  worth distinguishing from what Dune is being asked to build (weighted score input), though a
  future agent-trigger extension is a natural adjacent feature.
- **Right-Hand Cybersecurity (CrowdStrike Marketplace app):** A human risk management platform
  built explicitly on top of Falcon data — correlates "employee behavior-generated alerts" from
  CrowdStrike to prioritize risk and target training. Public marketing material does not disclose
  the actual weighting model or which specific Falcon fields are used — this is a competitive
  transparency gap. Dune has an opening to differentiate by making the weighting model
  admin-visible and admin-configurable (which the PRD already calls for) rather than a black box.
- No competitor in Dune's registry (`knowledge/competitor-list.md`) publicly documents a
  granular, admin-tunable weighting UI for third-party EDR signals feeding a human risk score —
  this appears to be a genuine differentiation opportunity worth naming in `design-strategy.md`,
  not just a parity feature.

---

## 6. Open technical questions this research could not resolve (carry into open-questions.md)

- Does Dune already have (or need to build) a generic "external risk signal" ingestion
  architecture, or would CrowdStrike be a bespoke one-off integration? This materially changes
  scope and whether the weighting UI should be CrowdStrike-specific or a generalized framework
  for future integrations (e.g. a future Microsoft Defender or SentinelOS integration).
- What is Dune's contractual/security posture on storing customer-provided CrowdStrike API
  credentials (secrets management, rotation, scoping)?
- For clients without Falcon Identity Protection, is device-login-history-based user attribution
  accurate enough to trust for a score that affects training assignment? Shared workstations,
  VDI/VDI-like environments, and service accounts all break this mapping.
- Should device-posture signals (ZTA, unpatched CVEs) count toward the *user's* risk score at
  all, given the user often doesn't control patch cadence or sensor health? Or should these be
  scoped to a separate "environment risk" concept, distinct from human risk?
