# Edge Cases — Red Team Platform
Last updated: 2026-05-13 · Initial refinement run.

---

## System states

### Campaign and orchestration
- Attack node fails mid-sequence (e.g., voice call leg fails): does the sequence continue on the next channel node or abort the attack for that employee?
- Campaign is approved but start date has already passed when approval is granted: is there an activation grace window, or does the campaign auto-cancel?
- Campaign is in "pending approval" state and all approvers are inactive or out of office: campaign sits in limbo with no escalation path defined
- Hybrid channel unavailable at send time (e.g., WhatsApp delivery infrastructure down): fallback to SMS? abort this employee's thread? surfaced in which admin view?
- Attack sequence with a loop or unresolvable branch (mis-configured VEP): system must detect and block activation
- Platform-level rate limit on outbound messages mid-campaign: delivery slows; how is status surfaced?
- Orchestration provider outage (SMS gateway, WhatsApp Business API, Viber): partial campaign delivery; status must distinguish "not yet sent" from "send attempted and failed"

### VEP and conversation management
- VEP script reaches a terminal node but employee has not responded (passive non-engagement): is this a data point? what appears in the conversation thread?
- VEP has no matching branch for the employee's actual response text: what does the automated attacker (if automated) do? fallback to a generic next step? flag for human review?
- Conversation thread is orphaned (employee's phone number changes mid-campaign, reply comes from a different number): thread is unmatched; data integrity at risk
- Auto-save failure in node-based editor: unsaved attack sequence nodes; admin navigates away and loses work
- Admin edits a VEP while a live campaign is actively using it: changes apply to future branches? or are live sessions frozen at their current node?

---

## Permission states

- Admin has campaign creation rights but not "request start" permission: can build a campaign but cannot submit it for approval; what is the CTA state and tooltip?
- Admin without red team module access navigates to AEP Library or Attack Library: 403 or feature-gated empty state?
- View-only admin accesses conversation threads: thread content visible (including employee messages, which may contain PII) — what is the PII access boundary?
- Approver role: who can approve a campaign start? Is there a new "Red Team Approver" RBAC role? What happens if the role is not assigned to any user?
- Complicity marking: is this a separate permission? Can any campaign admin mark, or only a designated red team operator?
- Compliance/audit officer needs to view all complicit flags across all campaigns: read-only cross-campaign view — is this a separate permission or a filter in the main view?
- Admin tries to force-cancel a campaign they did not create or submit: is cancel a universal admin action or restricted to the campaign owner?
- People manager receives notification that their direct report was marked complicit: what can the manager see — just the flag, or the full conversation transcript?

---

## Content states

### Library empty / bootstrap states
- AEP library is empty (no VEPs created or seeded): campaign creation cannot proceed to VEP selection — hard block with CTA to create or request a VEP
- Attack library is empty: campaign creation cannot proceed to attack selection — hard block with CTA to create an attack sequence
- Dune-provided AEP library: are there pre-seeded VEPs at tenant creation? If not, the product is unusable at day one

### Attack sequence configuration
- Node-based editor: attack sequence has no terminal node (sequence is open-ended / incomplete): cannot be saved as "Active"; draft state only
- Attack sequence with a single node (SMS-only): is this allowed in the attack library, or is the library exclusively for multi-channel sequences? (See open question)
- Admin builds an attack using a WhatsApp node but the tenant does not have WhatsApp channel access: node should be disabled or gated with a clear "channel not available" callout
- VEP is designed for SMS conversation but admin selects it for a hybrid SMS+WhatsApp attack: mismatch between VEP channel assumption and actual attack channels — warn or block?

### Conversations
- Campaign has zero conversations (attack sent; no employees replied): conversation management section shows empty state — must distinguish from "campaign not yet started" vs. "campaign completed with zero replies"
- Conversation thread with media attachments (employee replies with an image, file, or voice memo): display as attachment thumbnail? block? Dune system may not be set up to receive media replies
- Employee responds in a language other than English: VEP branching and auto-flag logic likely assumes English — NLP/keyword detection may fail silently
- Employee responds with a STOP or opt-out keyword: must be handled identically to smishing STOP flow — immediate removal from send queue, opt-out record, admin notification
- Conversation marked as complicit, then employee contacts IT to report the simulation: does the complicit flag get reconsidered? who owns this escalation?
- Conversation with only a single message exchange (too short to determine complicity): admin may lack sufficient signal to make a fair judgment — guidance needed at the point of marking

---

## Action states

### Campaign lifecycle
- Admin revokes a campaign start request before it is approved: returns to draft; approver notification recalled (or simply no longer actionable)
- Approver rejects a campaign start request: admin notified with rejection reason; campaign returns to draft with rejection note visible
- Admin edits a campaign while it is pending approval: does editing reset the approval request? must the admin re-submit?
- Admin force-cancels an active campaign (conversations in progress): remaining sends must stop; open conversations are frozen; admin must still be able to review and mark existing threads
- Bulk campaign archive under a legal hold: all send queues stop across affected campaigns; conversation threads preserved for audit

### Attack library / VEP management
- Admin deletes an attack sequence that is referenced by a scheduled campaign: hard block — cannot delete until campaign is cancelled or rescheduled with a different attack
- Admin archives a VEP that is in use by an active campaign: same hard block; tooltip shows affected campaign count
- Admin tries to change the channel composition of an attack that is used by an active campaign: hard block — channel changes during a live campaign would invalidate active conversation threads

### Complicity marking
- Admin marks a conversation as complicit: requires a confirmation step (not a single-click action given the HR implications)
- Admin changes a complicit marking to non-complicit: reversal recorded in audit log; risk score adjustment triggered
- Admin marks conversations in bulk (batch selection): requires explicit confirmation listing the count — "You are marking [N] conversations as complicit. This will update their risk scores."
- Admin closes the review without marking all flagged conversations: system must clearly indicate how many remain unreviewed; unreviewed is not the same as non-complicit

---

## Responsive / Accessibility

- Node-based editor on tablet: drag-and-drop canvas interactions are touch-heavy; keyboard-navigable fallback for a11y (add/connect nodes via keyboard) is required
- Node-based editor: attack sequences with 8+ nodes may not fit on a standard viewport — pan/zoom behavior must be defined
- Conversation thread view on mobile: security admins reviewing threads on mobile must be able to read full message content and mark complicity; must meet 44×44px touch targets
- Complicity marking confirmation modal on mobile: modal must not be dismissible by accidental back gesture
- VEP branching diagram (if visualized): complex node graph may not be accessible without a text-representation fallback (e.g., a list view of the branch tree)
- Campaign detail view with many conversation threads: infinite scroll vs. pagination; keyboard-navigable table; screen reader row labels must include employee identifier and complicity status
- Dashboard insights charts: all charts must have a text/table equivalent for screen reader users
