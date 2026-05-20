# Open Questions — Red Team Campaign Launcher

## Unresolved

- [ ] [Both] Is red team a separate campaign type with its own nav section, data model, and reporting surface — or an extension of existing simulation types with additional channel and targeting options? Every downstream design decision branches on this.
- [ ] [PM] Do red team campaign results feed the same risk score pipeline as simulations, or are they isolated to a separate red team reporting surface? Integrated results change user risk scores based on admin targeting choices; isolated results require a separate reporting dashboard.
- [ ] [PM] Is the existing SMS phishing compliance acknowledgment (customer confirms lawful basis via checkbox) sufficient for red team campaigns, or do red team campaigns require a higher-level approval step given higher deception and WhatsApp Business Policy constraints?
- [ ] [Eng] Can Dune send arbitrary custom red team messages via WhatsApp Business API, or are bulk sends restricted to pre-registered message templates requiring WhatsApp approval? If restricted, v1 WhatsApp scope may be limited to template-only lures.
- [ ] [PM] When WhatsApp delivery fails for a specific target: fall back to SMS (if number available), surface a per-user error in campaign detail, or silently exclude? This decision drives the multi-channel delivery status model.
- [ ] [PM] Should red team campaigns suppress remediation automation (training assignment, manager notification) by default, to avoid alerting the target that they were tested before the debrief?
- [ ] [PM] What does "individual user" targeting mean — a single named user, an ad-hoc list of named users, or any subset not organized as a formal group? Does individual targeting require a second admin to approve given its adversarial nature?
- [ ] [Both] If a user appears in both the individual target list and a targeted group in the same campaign, are they contacted once or twice? Does the system deduplicate automatically, or does the admin resolve it at the audience step?
- [ ] [PM] Do sub-admin roles (department managers, compliance viewers) get read-only visibility into red team campaign results? Red team results reveal specific adversarial vulnerabilities for named individuals and may warrant stricter visibility than simulations.
- [ ] [Eng] What is the vishing architecture — Dune-managed outbound VOIP with auto-recorded outcomes, or manual operator calls with Dune used as an outcome-recording tool? These produce completely different design surfaces.
- [ ] [PM] What multi-channel targeting model is intended: campaign-level default (all targets same channel), group-level override (group A gets SMS, group B gets WhatsApp), or user-level override (admin specifies per target)?
- [ ] [PM] Are red team templates shared with the simulation template library, or does red team have a separate template library with higher-deception lures?
- [ ] [PM] What are the success metrics for this feature? None defined in the brief.

## Resolved

_(No resolved questions yet.)_
