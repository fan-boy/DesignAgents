# Open Questions — CrowdStrike Risk Score Integration

## Unresolved
- [ ] [Eng] What is the exact scoring/escalation math for the No Endpoint Visibility weight (how much should having zero CrowdStrike coverage move a user's score by default)?
- [ ] [Eng] Is device-login-history-based user attribution (for tenants without Identity Protection licensed) accurate enough to trust for a score that affects training assignment, given it resolves through the same IAM identity but via an indirect join (device's last login account) rather than a direct identity record?
- [ ] [PM] Does this feature require updating employee-facing risk score transparency messaging to disclose the new data source?
- [ ] [PM] Can a Dune organization connect more than one CrowdStrike tenant (multi-CID enterprises)?
- [ ] [Eng] Is a bulk resolution path needed for user mapping at scale, or is one-at-a-time linking acceptable for v1?
- [ ] [Eng] Does capability detection automatically re-run when a client's CrowdStrike license changes, or is it a manual admin action?
- [ ] [PM] Is there any defined success signal for this feature (adoption, score accuracy, support ticket volume) that should shape build priority?
- [ ] [Eng] Does Dune need a generalized external risk signal ingestion framework, or is this a CrowdStrike-specific build? (carried from technical research)
- [ ] [Both] What is Dune's security posture for storing customer-provided CrowdStrike API credentials (secrets management, rotation, scoping)? (carried from technical research)
- [ ] [Both] Should real-time streaming (vs. scheduled polling) be in scope for v1? (carried from technical research)

## Resolved
- [x] [PM] Should device-posture signals (ZTA, unpatched vulnerabilities) count toward individual user risk score, or a separate environment-level concept distinct from human risk? — **Answer:** Blend into one overall risk score; all categories (including device/environment signals) are weighted equally as part of a single score, not split into separate human vs. environment scores.
- [x] [PM] For a user with no CrowdStrike data, is the missing contribution excluded from the weighted calculation or treated as neutral/zero? — **Answer:** Neither. Lack of coverage is itself a risk-relevant signal, not a neutral non-event. Introduced a sixth, always-present "No Endpoint Visibility" weight, defaulting to a moderate non-zero value, so a user with zero CrowdStrike presence is flagged distinctly rather than silently excluded or treated as clean. Exact escalation math is still open (see Unresolved).
- [x] [PM] Should an admin role narrower than Full Access be able to able to own this integration, given CrowdStrike ownership commonly sits with IT/SecOps rather than the training program owner? — **Answer:** No, for v1. Assume Full Access only; do not design a new scoped permission as part of this feature. Revisit if/when RBAC resolves its own open question about a Super Admin concept distinct from Full Access.
- [x] [Eng] How is a CrowdStrike device/identity tied to a specific person? — **Answer:** Through the same IAM identity (email/UPN) Dune already resolves via SSO/SCIM provisioning, matched against CrowdStrike's identity record email (Identity Protection) or a device's most recent login account UPN (core Falcon Insight). This is now stated explicitly in prd.md rather than referring to a generic "email in Dune."
