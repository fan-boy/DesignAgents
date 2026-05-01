# Open Questions — SMS Phishing (Smishing) Simulation
Last updated: 2026-05-01 · PRD added, 6 questions resolved, 10 new PRD questions added.

---

## Unresolved

- [ ] [PM/Eng] Where do customer phone numbers live today in Dune, and what permissions exist around them? Do customers expect smishing to use personal phone numbers, work-issued numbers, or both? (PRD §16.1–16.2)
- [ ] [Eng] What SMS sending provider should Dune use, and which countries should v1 support? (PRD §16.3)
- [ ] [PM] How should opt-out and employee consent be handled by customer, region, and campaign type? (PRD §16.4)
- [ ] [PM/Eng] What is the exact risk-weighting difference between email-phishing failures and smishing failures? PRD confirms separate weighting is required but leaves the values undefined. (PRD §16.5)
- [ ] [PM] Should reporting (user forwarding suspicious SMS) be in scope for v1, or should v1 track only click/submission behavior? PRD lists it as a tracking metric but Phase 0 interviews should validate demand. (PRD §16.6)
- [ ] [PM] Do we need approval workflows for high-sensitivity templates (e.g., credential-harvest, executive impersonation)? If yes, this adds an "Awaiting Approval" campaign state to the detail view. (PRD §16.7)
- [ ] [PM] Should smishing templates be customer-editable in v1, or approved-library only during beta? This changes the message editor scope (full custom vs. token-substitution only). (PRD §16.8)
- [ ] [PM] How will Dune prevent customers from sending messages that look like real emergencies, legal notices, or harmful impersonations? Guardrails design required. (PRD §16.9)
- [ ] [PM] How should Dune price/package this capability — included simulation channel, add-on, or advanced user-risk module? (PRD §16.10)
- [ ] [Eng] How will link scanner false positives (MDM and security tools auto-following tracking URLs) be detected and excluded from click metrics and risk scores? Not addressed in PRD.
- [ ] [PM] When an employee replies STOP, is the exclusion permanent across all future campaigns, or scoped to the current campaign only? Not addressed in PRD.
- [ ] [Both] What sender identity is in scope for v1 — short code, toll-free, 10DLC long code? PRD lists "sender-number pools or branded sender profiles where available" as Should priority, but the specific approach is not decided.
- [ ] [PM] What is the threshold for launching when a significant portion of the target group has no phone number on file — warn and proceed, or block below a minimum?

---

## Resolved

- [x] [PM] Has legal reviewed TCPA compliance? — **Answer:** Customer-responsibility model. Per PRD §12, the customer must confirm they have a lawful basis and employee-notice process before sending simulations. Dune's design responsibility is an admin acknowledgment step at campaign creation (checkbox confirming customer has the legal basis). Dune does not own the underlying compliance — the customer does.

- [x] [PM] What is the defined success metric for this feature at launch? — **Answer:** (1) Admin can create and launch a campaign in under 10 minutes. (2) 95%+ of test sends complete successfully in supported regions. (3) User events appear on risk profile within 60 seconds of click/submission. (4) Remediation triggers fire within 60 seconds. (5) 50% of pilot customers launch a second campaign within 60 days. (6) Zero collection of real credentials, OTPs, or sensitive data. (PRD §14)

- [x] [Both] Is AI-personalized smishing in scope for v1, or is v1 template-based only? — **Answer:** Template-based for v1. PRD §7 specifies approved templates plus "light customization." AI-generated personalization is not in scope for the first launch. Use "Smart Templates" framing. (PRD §7.1)

- [x] [Both] How does an SMS link click map to the existing risk scoring model? — **Answer:** Graduated signal model with separate weighting from email phishing. Delivered only = no negative impact. Clicked link = moderate negative. Submitted simulated credentials/MFA = high negative. Reported without clicking = positive. Completed remediation training = positive recovery. Repeated failure = escalating negative. Weighting values are still an open question (see Unresolved above). (PRD §11)

- [x] [PM] Is multi-channel data modeling in scope for v1? — **Answer:** Yes — architecture must anticipate WhatsApp, Signal, Telegram, QR-code lures, and vishing-adjacent channels. The data model should be designed for multi-channel even though v1 ships SMS-only. The campaign `type = smishing` field makes this extensible. (PRD §1, §10)

- [x] [Both] Is the mobile debrief a new mobile-first design surface? — **Answer:** Yes, confirmed. PRD §7.3 and §13 specify mobile-first, short, behavior-oriented coaching pages. The content structure is: (1) Hook — "This was a simulation." (2) Red flags from the specific message. (3) Correct behavior. (4) Micro-commitment. (PRD §13)
