# PRD: Asset Tagging for Relevant Training Assignment

**Document status:** Draft — Ready for Engineering Review
**Author:** Product (Dune Security)
**Date:** 2026-06-01
**Feature slug:** `asset-tagging-relevant-training`

---

## 1. Executive Summary

Currently, when a user fails a phishing simulation asset, the platform assigns a training module at random. This feature replaces random assignment with relevance-based assignment by tagging each simulation asset with the attack technique (Method) and target audience (Persona) it represents, then matching those tags against training content tagged with the same dimensions.

The result is a three-tier matching engine: first attempt an exact Method + Persona match, then fall back to Method-only, then fall back to a curated general pool. This change is entirely backend and internal-dashboard work. End users (employees receiving training) experience no UI change.

---

## 2. Problem Statement

Phishing simulation platforms derive security value only when failed simulations produce learning. Today, the assigned training is randomly selected, which means a user who fell for a fake invoice scam may receive training about MFA bypass — a topic unrelated to the mistake they just made. Irrelevant training reduces engagement, retention, and measurable behavior change.

The core gap is a missing metadata layer: simulation assets are not tagged with what attack they represent, and training content is not tagged with what attack it defends against. Without this shared vocabulary, automated relevance matching is impossible.

---

## 3. Goals & Success Metrics

### Goals

- Tag all simulation assets with a Method and Persona from controlled taxonomies.
- Tag all training content with one or more Methods and Personas from the same taxonomies.
- Replace the random training assignment algorithm with a three-tier relevance-based algorithm.
- Provide internal Product and CS teams with dashboard UI to apply and edit these tags.

### Success Metrics

| Metric | Baseline | Target (90 days post-launch) |
|---|---|---|
| % of simulation failure events resulting in a Tier 1 (exact match) assignment | 0% | ≥ 70% |
| % of simulation failure events resulting in any relevant assignment (Tier 1 or Tier 2) | 0% | ≥ 85% |
| % of assets fully tagged (Method + Persona) | 0% | 100% |
| % of trainings with at least one Method tag | 0% | ≥ 80% |
| Training completion rate (proxy for engagement) | Baseline TBD | +10% relative |

---

## 4. Non-Goals

- This PRD does not change what training content exists. No new training modules are created.
- This PRD does not change the learner-facing training UI or delivery flow.
- End-user-facing admin dashboards (customer organizations) will not expose Method or Persona tags. This is an internal tool.
- This PRD does not introduce weighted scoring or ML-based ranking within matched results.
- This PRD does not add multi-persona support for users. Users have exactly one Persona.
- This PRD does not change existing campaign configuration, scheduling, or targeting logic.

---

## 5. User Stories

### Internal admin (Product / CS team member)

| ID | Story |
|---|---|
| US-01 | As a Product team member, I want to open an asset in the dashboard and assign it a Method and Persona so that the matching engine can use it. |
| US-02 | As a CS team member, I want to open a training record and assign it one or more Methods and Personas so that it surfaces in relevant matches. |
| US-03 | As a Product team member, I want dropdowns for Method and Persona to show only values from the approved taxonomy so that I cannot introduce invalid tags. |
| US-04 | As a Product team member, I want to see which assets are missing Method or Persona tags so that I can prioritize tagging work before go-live. |
| US-10 | As a Product team member, I want to add a new Method or Persona value through the internal dashboard so that new attack techniques or departments can be supported without an engineering deploy. |
| US-11 | As a Product team member, I want to be prevented from deleting a taxonomy value that is still in use by assets or trainings so that I do not accidentally break existing tag mappings. |

### System / automated

| ID | Story |
|---|---|
| US-05 | As the assignment engine, when a user fails a simulation, I want to find the most relevant unassigned training by matching the asset's Method and Persona against tagged trainings so that the user receives content directly relevant to the attack they fell for. |
| US-06 | As the assignment engine, when no exact Method + Persona match exists, I want to fall back to Method-only matching so that relevance is preserved even when persona-specific content is unavailable. |
| US-07 | As the assignment engine, when no Method match exists either, I want to randomly assign from the fallback pool (filtered by user Persona where applicable) so that every failure event results in some training assignment. |
| US-08 | As the assignment engine, I want to exclude trainings that are currently assigned and incomplete, or completed within the last 60 days, so that users are not re-assigned content they recently engaged with. |
| US-09 | As the assignment engine, I want to write the assignment atomically so that concurrent simulation events for the same user do not produce duplicate assignments. |

---

## 6. Functional Requirements

### 6.1 Controlled Taxonomy

**FR-01** The system must maintain a single controlled vocabulary for Method values, shared across the asset model, training model, assignment engine, and all dashboard dropdowns.

**FR-02** The system must maintain a single controlled vocabulary for Persona values, shared in the same way.

**FR-03** Taxonomy values must be stored in the database (not hardcoded in application logic) and loaded dynamically by all consumers.

**FR-04** Taxonomy values must be manageable through the internal dashboard. Authorized internal users (Product and CS teams) must be able to add new Method and Persona values without an engineering deploy. Deleting or renaming an existing value that is in use must be blocked until all references are removed or re-tagged.

**FR-05** The Method taxonomy must contain exactly these values (display label → stored slug):

| Display label | Stored slug |
|---|---|
| Account takeover | `account-takeover` |
| App permission abuse | `app-permission-abuse` |
| Disguised link | `disguised-link` |
| Email spoofing | `email-spoofing` |
| Fake payment request | `fake-payment-request` |
| Fake renewal notice | `fake-renewal-notice` |
| Lookalike domain | `lookalike-domain` |
| MFA bypass | `mfa-bypass` |
| Password theft | `password-theft` |
| Payroll redirect scam | `payroll-redirect-scam` |
| Tampered email content | `tampered-email-content` |

**FR-06** The Persona taxonomy must contain exactly these values:

| Display label | Stored slug |
|---|---|
| IT & Security | `it-security` |
| Finance & Accounting | `finance-accounting` |
| Engineering & Product | `engineering-product` |
| Operations & Facilities | `operations-facilities` |
| HR & People Operations | `hr-people-ops` |
| Executive Leadership | `executive-leadership` |
| Sales & Business Development | `sales-biz-dev` |
| Marketing & Communications | `marketing-comms` |
| Research & Development | `research-development` |
| Customer Support & Success | `customer-support-success` |
| Temporary/Miscellaneous & Contract/third-party | `temp-misc-contractor` |

### 6.2 Asset Tagging

**FR-07** Each simulation asset must support a single `method` field (string, nullable, constrained to Method taxonomy slugs).

**FR-08** Each simulation asset must support a single `persona` field (string, nullable, constrained to Persona taxonomy slugs).

**FR-09** An asset with a null `method` or null `persona` must be excluded from the primary and fallback-1 matching tiers. The assignment engine must treat such assets as if they have no curated training list.

**FR-10** The asset edit form must include a Method single-select dropdown and a Persona single-select dropdown. Both must include a blank/unset option. Both must be saveable independently.

### 6.3 Training Tagging

**FR-11** Each training record must support a `methods` array field (string[], nullable/empty, each value constrained to Method taxonomy slugs).

**FR-12** Each training record must support a `personas` array field (string[], nullable/empty, each value constrained to Persona taxonomy slugs).

**FR-13** A training with no Method tags is unreachable via Tier 1 and Tier 2 matching. It may still appear in the fallback pool if flagged accordingly (see FR-16).

**FR-14** The training edit form must include a Methods multi-select dropdown and a Personas multi-select dropdown. Both must include a clear-all option.

### 6.4 Fallback Pool Membership

**FR-15** Each training record must support an `is_fallback` boolean flag (default false).

**FR-16** The fallback pool is defined by `is_fallback = true`. This flag is set during data migration and maintained by internal team. It is not derived from tag logic.

**FR-17** A training may have both taxonomy tags and `is_fallback = true`. In that case it participates in Tier 1/2 matching normally and also in Tier 3. There is no double-assignment risk because Tier 3 applies the same exclusion filter.

### 6.5 Assignment Engine — Three-Tier Logic

**FR-18** When a simulation failure event is recorded for a user against an asset, the assignment engine must execute the following algorithm synchronously before returning a response to the caller.

**FR-19 — Tier 1 (Primary match):**
From the asset's curated training list (John Notes), find all trainings where:
- `training.methods` contains `asset.method`, AND
- `training.personas` contains `asset.persona`, AND
- The training is eligible for the user (not currently assigned-and-incomplete, and not completed within the last 60 days).

If one or more results exist, assign the first item in the list order. Stop.

**FR-20 — Tier 2 (Method fallback):**
If Tier 1 yields no eligible training: from the asset's curated training list, find all trainings where:
- `training.methods` contains `asset.method`, AND
- The training is eligible for the user.

(Persona is ignored at this tier.) If one or more results exist, assign the first. Stop.

**FR-21 — Tier 3 (Fallback pool):**
If Tier 2 also yields nothing: query the fallback pool. The fallback pool for this user is defined as:
- All trainings where `is_fallback = true` AND persona-specific FST entries match the user's persona (see Section 11), UNION
- All SAT trainings where `is_fallback = true`.

Apply the same eligibility filter (not currently assigned-and-incomplete, not completed within last 60 days). Randomly select one eligible training. If one or more results exist, assign it. Stop.

**FR-22 — Exhaustion handling:**
If Tier 3 also yields no eligible training (all fallback pool items are ineligible for this user), the engine must not error. It must log a structured warning event (`training_assignment_exhausted`) with the user ID, asset ID, and timestamp, and skip assignment for this simulation event. No training is assigned.

**FR-23** The eligibility check is: `completed_at IS NULL OR completed_at < (NOW() - INTERVAL 60 days)`. The boundary is exclusive: a training completed exactly 60 days ago (to the second) is NOT eligible. A training completed 60 days and 1 second ago is eligible.

**FR-24** The curated list for an asset is stored as an ordered list of training IDs sourced from the John Notes column. List order is preserved and used as the selection order for Tier 1 and Tier 2.

**FR-25** If an asset has no curated training list (John Notes is empty or the asset is untagged), the engine must skip Tier 1 and Tier 2 and proceed directly to Tier 3.

**FR-26** The assignment write must be atomic. If a concurrent assignment for the same user is detected (via database-level lock or optimistic concurrency check), the second write must be rejected and the event logged. No duplicate assignments are permitted.

### 6.6 Assignment Record

**FR-27** Each assignment record must store: `user_id`, `training_id`, `asset_id`, `assigned_at` (timestamp), `completed_at` (timestamp, nullable), `assignment_tier` (integer 1, 2, or 3, indicating which tier produced the assignment).

**FR-28** `assignment_tier` must be populated for all new assignments. Existing historical records will have this field null.

---

## 7. Data Model Changes

### 7.1 New table: `taxonomy_methods`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `slug` | varchar(64) | UNIQUE, NOT NULL |
| `display_label` | varchar(128) | NOT NULL |
| `created_at` | timestamptz | NOT NULL, default now() |

Seed with 11 Method values from FR-05.

### 7.2 New table: `taxonomy_personas`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `slug` | varchar(64) | UNIQUE, NOT NULL |
| `display_label` | varchar(128) | NOT NULL |
| `created_at` | timestamptz | NOT NULL, default now() |

Seed with 11 Persona values from FR-06.

### 7.3 Modify table: `assets`

| New column | Type | Constraints | Notes |
|---|---|---|---|
| `method` | varchar(64) | NULLABLE, FK → `taxonomy_methods.slug` | Single value |
| `persona` | varchar(64) | NULLABLE, FK → `taxonomy_personas.slug` | Single value |

Existing rows: both fields null until manually tagged.

### 7.4 Modify table: `trainings`

| New column | Type | Constraints | Notes |
|---|---|---|---|
| `methods` | varchar(64)[] | NOT NULL, default `{}` | Array of Method slugs |
| `personas` | varchar(64)[] | NOT NULL, default `{}` | Array of Persona slugs |
| `is_fallback` | boolean | NOT NULL, default false | Fallback pool membership |

Existing rows: `methods = {}`, `personas = {}`, `is_fallback = false` until migrated.

### 7.5 New table: `asset_training_curated_list`

Stores the ordered John Notes curated training list per asset.

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `asset_id` | uuid | NOT NULL, FK → `assets.id` |
| `training_id` | uuid | NOT NULL, FK → `trainings.id` |
| `sort_order` | integer | NOT NULL |
| `created_at` | timestamptz | NOT NULL, default now() |

Unique constraint: `(asset_id, training_id)`. Index on `(asset_id, sort_order)`.

### 7.6 Modify table: `training_assignments`

| New column | Type | Constraints | Notes |
|---|---|---|---|
| `completed_at` | timestamptz | NULLABLE | Backfill from existing completion data |
| `assignment_tier` | smallint | NULLABLE | 1, 2, or 3; null for pre-migration records |

---

## 8. Assignment Logic

### 8.1 Written description

When a user fails a simulation, the engine receives the user ID and the asset ID. It resolves the asset's `method`, `persona`, and curated training list. It resolves the user's `persona` and their assignment history (assigned-and-incomplete training IDs + training IDs completed in the last 60 days). It then attempts the three tiers in order, stopping at the first tier that produces a result.

Tiers 1 and 2 draw exclusively from the asset's curated list (John Notes). This means the curated list is the authoritative scope for relevance-based matching — trainings not on this list are never selected at Tier 1 or 2 regardless of their tags.

Tier 3 draws from the platform-wide fallback pool, filtered to the user's Persona where persona-specific FST entries exist.

### 8.2 Pseudocode

```
function assignTraining(userId, assetId):

  asset = fetchAsset(assetId)
  user  = fetchUser(userId)

  ineligible = getIneligibleTrainingIds(userId)
    # ineligible = assigned-and-incomplete UNION completed within last 60 days

  curatedList = fetchCuratedList(assetId)  # ordered by sort_order

  # --- Tier 1: Method + Persona match ---
  if asset.method IS NOT NULL AND asset.persona IS NOT NULL AND curatedList IS NOT EMPTY:
    tier1Candidates = [
      t for t in curatedList
      if asset.method IN t.methods
      AND asset.persona IN t.personas
      AND t.id NOT IN ineligible
    ]
    if tier1Candidates is not empty:
      return createAssignment(userId, tier1Candidates[0].id, assetId, tier=1)

  # --- Tier 2: Method match only ---
  if asset.method IS NOT NULL AND curatedList IS NOT EMPTY:
    tier2Candidates = [
      t for t in curatedList
      if asset.method IN t.methods
      AND t.id NOT IN ineligible
    ]
    if tier2Candidates is not empty:
      return createAssignment(userId, tier2Candidates[0].id, assetId, tier=2)

  # --- Tier 3: Fallback pool ---
  fallbackPool = fetchFallbackPool(userPersona=user.persona)
    # fallbackPool = (SAT trainings where is_fallback=true)
    #   UNION (FST trainings where is_fallback=true AND persona matches user.persona)
    # apply ineligible exclusion

  eligible = [t for t in fallbackPool if t.id NOT IN ineligible]

  if eligible is not empty:
    selected = randomChoice(eligible)
    return createAssignment(userId, selected.id, assetId, tier=3)

  # --- Exhaustion ---
  logWarning("training_assignment_exhausted", userId, assetId)
  return null  # no assignment created


function createAssignment(userId, trainingId, assetId, tier):
  ATOMICALLY:
    if existsActiveAssignment(userId, trainingId):
      logWarning("duplicate_assignment_prevented", userId, trainingId)
      return null
    insert into training_assignments (
      user_id=userId,
      training_id=trainingId,
      asset_id=assetId,
      assigned_at=NOW(),
      completed_at=NULL,
      assignment_tier=tier
    )
  return assignment
```

---

## 9. API Changes

All endpoints are internal and require an authenticated session with an admin or internal role. No public API surface is added.

### 9.1 New endpoints

#### `GET /internal/taxonomy/methods`
Returns the full Method taxonomy.

**Response:**
```json
{
  "methods": [
    { "slug": "account-takeover", "display_label": "Account takeover" },
    ...
  ]
}
```

#### `GET /internal/taxonomy/personas`
Returns the full Persona taxonomy.

**Response:**
```json
{
  "personas": [
    { "slug": "it-security", "display_label": "IT & Security" },
    ...
  ]
}
```

### 9.2 Modified endpoints

#### `GET /internal/assets/:id`
Add to response body:
```json
{
  "method": "fake-renewal-notice" | null,
  "persona": "finance-accounting" | null
}
```

#### `PATCH /internal/assets/:id`
Accept in request body:
```json
{
  "method": "fake-renewal-notice" | null,
  "persona": "finance-accounting" | null
}
```

Validation: if provided, `method` must be a valid Method slug; `persona` must be a valid Persona slug. Return `422` with a descriptive error if invalid.

#### `GET /internal/trainings/:id`
Add to response body:
```json
{
  "methods": ["fake-renewal-notice", "disguised-link"],
  "personas": ["finance-accounting"],
  "is_fallback": false
}
```

#### `PATCH /internal/trainings/:id`
Accept in request body:
```json
{
  "methods": ["fake-renewal-notice"],
  "personas": ["finance-accounting", "executive-leadership"],
  "is_fallback": true
}
```

Validation: each value in `methods` must be a valid Method slug; each value in `personas` must be a valid Persona slug. Return `422` if any value is invalid.

### 9.3 Assignment engine trigger

The existing simulation failure event endpoint that triggers training assignment requires no new external API surface. The assignment engine is called internally when a failure is recorded. The response from that endpoint should include:

```json
{
  "assignment": {
    "training_id": "uuid",
    "assignment_tier": 1,
    "assigned_at": "2026-06-01T12:00:00Z"
  } | null
}
```

`null` when assignment was exhausted and no training was assigned.

---

## 10. Dashboard / UI Changes

### 10.1 Asset edit form

The asset edit form already exists. Add two new fields in a "Simulation Tags" section below existing fields.

| Field | Type | Options source | Behavior |
|---|---|---|---|
| Method | Single-select dropdown | `GET /internal/taxonomy/methods` | Includes blank/unset option. Required for the asset to participate in Tier 1/2 matching but saveable as blank. |
| Persona | Single-select dropdown | `GET /internal/taxonomy/personas` | Same behavior. |

**Validation:** If either field is set, it must be a valid taxonomy value. Saving with an unrecognized value is blocked client-side and server-side.

**Save behavior:** The two new fields save with the existing asset save action. No separate save button.

**Empty state:** Until tagged, both fields show "— Not set —" in the dropdown.

### 10.2 Training edit form

The training edit form already exists. Add two new fields in a "Training Tags" section.

| Field | Type | Options source | Behavior |
|---|---|---|---|
| Methods | Multi-select dropdown | `GET /internal/taxonomy/methods` | Zero or more selections. Includes a "Clear all" option. |
| Personas | Multi-select dropdown | `GET /internal/taxonomy/personas` | Zero or more selections. Same behavior. |

**Save behavior:** Saves with the existing training save action.

**Empty state:** Until tagged, both fields show "— None selected —".

### 10.3 Access control

Both form fields are visible and editable only to users with the `internal_admin` or `internal_cs` role. Customer-facing admin accounts must not see or receive these fields via API.

### 10.4 Tagging progress indicator (nice-to-have, not blocking launch)

A summary view showing counts of tagged vs. untagged assets and trainings would support the migration effort. This can be a simple table or counter on the internal dashboard home. Not required for v1.

### 10.5 Taxonomy management (internal dashboard)

Internal admins must be able to manage the Method and Persona taxonomies directly from the internal dashboard without an engineering deploy.

**Location:** Internal Dashboard → Settings → Taxonomy (new page)

| Action | Behavior |
|---|---|
| View all Method values | Paginated list of all Method slugs and display labels, with usage count (how many assets/trainings reference each). |
| View all Persona values | Same for Persona. |
| Add new Method value | Form: display label (required, unique), slug (auto-generated from label, editable, unique). On save, value becomes immediately available in all dropdowns. |
| Add new Persona value | Same. |
| Edit display label | Allowed at any time. Slug is immutable after creation to preserve FK integrity. |
| Delete a value | Blocked if any asset or training currently references the value. Error message must list the count of blocking references. Allowed only when usage count is zero. |

**Access control:** Restricted to `internal_admin` role only. CS team (`internal_cs`) may view but not create or delete taxonomy values.

**API endpoints to add:**
- `GET /internal/taxonomy/methods` — list (already specified in Section 9)
- `GET /internal/taxonomy/personas` — list (already specified)
- `POST /internal/taxonomy/methods` — create new Method value
- `POST /internal/taxonomy/personas` — create new Persona value
- `PATCH /internal/taxonomy/methods/:slug` — update display label
- `PATCH /internal/taxonomy/personas/:slug` — update display label
- `DELETE /internal/taxonomy/methods/:slug` — delete (blocked if in use)
- `DELETE /internal/taxonomy/personas/:slug` — delete (blocked if in use)

---

## 11. Fallback Pool Full Specification

### 11.1 SAT fallback pool (all personas)

The following SAT training IDs have `is_fallback = true`. These are eligible for any user regardless of Persona when Tier 3 is reached.

```
SAT-002, SAT-003, SAT-004, SAT-009, SAT-012, SAT-022, SAT-026, SAT-028,
SAT-031, SAT-032, SAT-033, SAT-042, SAT-043, SAT-044, SAT-045, SAT-049,
SAT-052, SAT-054, SAT-055, SAT-056, SAT-057, SAT-060, SAT-062, SAT-063,
SAT-064, SAT-065, SAT-068, SAT-070, SAT-076, SAT-077, SAT-079, SAT-080,
SAT-082, SAT-083, SAT-084, SAT-087
```

Total: 36 SAT fallback entries.

### 11.2 Persona-specific FST fallback pool

These FST training IDs have `is_fallback = true` AND are matched against the user's Persona at query time. They supplement the SAT pool for covered personas.

| Persona slug | FST training IDs |
|---|---|
| `hr-people-ops` | FST-105, FST-106, FST-109, FST-112 |
| `finance-accounting` | FST-118, FST-119, FST-120, FST-121 |
| `executive-leadership` | FST-127, FST-128, FST-129, FST-130, FST-131, FST-132 |
| `it-security` | FST-139, FST-140, FST-141, FST-142 |
| `engineering-product` | FST-147, FST-152, FST-153, FST-157, FST-160, FST-161, FST-162, FST-163, FST-164, FST-165, FST-166 |
| `operations-facilities` | *(SAT fallback pool only)* |
| `sales-biz-dev` | *(SAT fallback pool only)* |
| `marketing-comms` | *(SAT fallback pool only)* |
| `research-development` | *(SAT fallback pool only)* |
| `customer-support-success` | *(SAT fallback pool only)* |
| `temp-misc-contractor` | *(SAT fallback pool only)* |

**Note:** 6 of 11 personas receive only SAT fallback content. See Open Questions §15 for the decision on whether to create persona-specific FST fallbacks for these groups.

### 11.3 Fallback pool query

```sql
SELECT t.*
FROM trainings t
WHERE t.is_fallback = true
  AND (
    t.type = 'SAT'
    OR (t.type = 'FST' AND :user_persona = ANY(t.personas))
  )
  AND t.id NOT IN (
    SELECT training_id FROM training_assignments
    WHERE user_id = :user_id
      AND (completed_at IS NULL OR completed_at > NOW() - INTERVAL '60 days')
  )
ORDER BY RANDOM()
LIMIT 1
```

---

## 12. Edge Cases & Error Handling

| ID | Scenario | Expected behavior |
|---|---|---|
| EC-01 | Asset has no `method` or `persona` tag | Skip Tier 1 and Tier 2. Proceed directly to Tier 3. Do not error. |
| EC-02 | Asset curated list (John Notes) is empty | Skip Tier 1 and Tier 2. Proceed directly to Tier 3. |
| EC-03 | Training has no Method or Persona tags | Training is unreachable in Tier 1 and Tier 2. It is only accessible via Tier 3 if `is_fallback = true`. No error. |
| EC-04 | User has no Persona assigned | Tier 1 and Tier 2 attempt normally (using asset's Persona only). Tier 3 falls back to SAT-only pool (no persona-specific FST). Log a warning that persona is unset on the user record. |
| EC-05 | All three tiers exhausted | Log `training_assignment_exhausted` event with `user_id`, `asset_id`, `timestamp`. Return null assignment. Do not error the simulation failure event. |
| EC-06 | Training completed exactly 60 days ago | The training IS eligible (boundary is exclusive: `completed_at < NOW() - INTERVAL '60 days'`). |
| EC-07 | Concurrent simulation events for the same user | Atomic write with row-level lock or optimistic concurrency. Second concurrent write is rejected. Log `duplicate_assignment_prevented`. |
| EC-08 | Training appears in both a curated list and the fallback pool | No conflict. Tier 1 and Tier 2 use the curated list; Tier 3 uses the fallback pool. The training may be selected at either tier depending on match quality and eligibility. |
| EC-09 | Invalid taxonomy slug submitted via API | Return `422 Unprocessable Entity` with body `{ "error": "Invalid method slug: <value>" }`. Do not save. |
| EC-10 | Asset in curated list references a deleted training | Skip the deleted training ID in list evaluation. Do not error the engine. Clean up orphaned curated list entries in migration. |
| EC-11 | Fallback pool has FST entries but user has Persona `temp-misc-contractor` | FST entries are not included in the Tier 3 query for this persona. User receives SAT fallback only. |
| EC-12 | `completed_at` is null on an old assignment record (pre-migration, not yet backfilled) | Treat the record as assigned-and-incomplete (exclude the training from eligibility). This is the conservative default. |

---

## 13. Data Migration Plan

### 13.1 Pre-migration (before deploy)

1. **Taxonomy seed:** Insert all 11 Method slugs into `taxonomy_methods` and all 11 Persona slugs into `taxonomy_personas` via a deploy-time seed script. After launch, additional values can be added at any time through the internal dashboard (Settings → Taxonomy) without a deploy.

2. **Schema migration:** Apply database migrations to add all new columns and tables described in Section 7. New columns are nullable or have safe defaults. This migration is non-destructive and backward-compatible with the pre-deploy codebase.

### 13.2 Post-deploy, pre-traffic (manual tagging phase)

3. **Asset tagging:** The Product team manually opens each of the approximately 200 existing assets in the updated dashboard and assigns a Method and Persona. Assets without tags will fall through to Tier 3 only until tagged. This is acceptable behavior during the tagging window.

4. **Training tagging:** The Product and CS teams manually open each training record and assign applicable Methods and Personas. Trainings with no tags are unreachable at Tier 1 and Tier 2 but remain accessible via Tier 3 if `is_fallback = true`.

5. **Fallback pool seeding:** A one-time migration script sets `is_fallback = true` on all SAT and FST training IDs listed in Section 11. This script is idempotent and can be re-run safely.

6. **Curated list import:** A one-time migration script parses the John Notes column for each asset and inserts rows into `asset_training_curated_list` with `sort_order` preserved from the source. The Training Videos column is ignored. Engineering must confirm the source data format for John Notes before writing this script.

7. **Assignment record backfill:** Add `completed_at` to historical `training_assignments` records by joining against the existing completion tracking table (or event log). Records with no available completion data should have `completed_at` left null (treated as assigned-and-incomplete per EC-12).

8. **`assignment_tier` backfill:** Set `assignment_tier = NULL` on all pre-migration assignment records. This is the default column value and requires no active migration step.

### 13.3 Post-tagging validation

9. **Coverage audit:** After the tagging phase, run a query to count assets where `method IS NULL OR persona IS NULL` and trainings where `methods = {}`. Surface these counts to the Product team. Resolve gaps before enabling the new assignment engine in production traffic.

10. **Slug normalization check:** Confirm that the Persona slug `temp-misc-contractor` is used consistently across all records and that no records contain the raw display label string.

11. **Enable new engine:** Feature-flag the new three-tier assignment engine. Enable it in staging for a full test cycle, then enable in production.

---

## 14. Out of Scope

- Multi-persona users: the current data model is single-persona per user. This feature does not extend it.
- Customer-facing tag editing: external admin users cannot view or edit Method/Persona tags.
- Taxonomy governance for customer-facing orgs: customers cannot define or modify Method/Persona values. This is an internal-only capability.
- Automatic tagging via ML/NLP: all tagging in v1 is manual.
- Training content creation or editing.
- Learner-facing UI changes.
- Reporting or analytics dashboards showing Tier distribution or match quality (these are post-v1 candidates).
- Campaign-level assignment overrides.
- Weighted scoring or ranking within a tier's candidate list.
- Re-assignment or reassignment flows triggered by admin action (existing behavior is unchanged).
- Support for assets with more than one Method or Persona (assets are single-tagged by design).

---

## 15. Open Questions

| ID | Question | Owner | Impact if unresolved |
|---|---|---|---|
| OQ-01 | Should "2 months" be defined as 60 days (current spec) or calendar months? Engineering has implemented 60 days. If calendar months are preferred this requires a change before deploy. | Product / Engineering | Assignment eligibility boundary |
| OQ-02 | What is the required behavior when the fallback pool is fully exhausted for a user — skip assignment (current spec), notify an admin, or re-assign the least-recently-completed training? | Product | Blocking: exhaustion handling path |
| OQ-03 | Can a user have more than one Persona in any customer's directory? If yes, the matching logic and user data model need a tiebreaker or union strategy before launch. | Engineering / Product | Blocks correctness for multi-role users |
| OQ-04 | Should the ordering within a matched tier be randomized to increase variety, or is stable list order (current spec) preferred? | Product | Assignment variety |
| OQ-05 | When a new Method or Persona value is added via the dashboard, is there a process for retroactively tagging existing untagged assets and trainings against it? Should the dashboard surface a "newly added, 0 references" warning to prompt action? | Product | Long-term data quality |
| OQ-06 | Are there any trainings in the Training Videos column that are intentionally excluded from John Notes and must never be assigned? | Product / CS | Curated list import accuracy |
| OQ-07 | Should persona-specific FST fallback entries be created for the 6 currently uncovered personas (Operations, Sales, Marketing, R&D, Customer Support, Temp/Contractor), or is SAT-only fallback acceptable for those groups? | Product / Content | Fallback relevance for 6 personas |
| OQ-08 | Is the internal-only access scope for Method and Persona tags firm for v1? Will external admins (customer org admins) ever need to see or configure these tags? | Product | API and permission scope |
| OQ-09 | What is the exact source format of the John Notes column — is it a comma-separated list of training IDs, a free-text field, or structured data? Engineering needs this confirmed before writing the curated list import script. | Engineering / Product | Blocks migration step 6 |
| OQ-10 | Is there an existing row-level locking mechanism on the `training_assignments` table, or does the concurrent assignment prevention need to be implemented from scratch? | Engineering | Blocks FR-26 implementation |
