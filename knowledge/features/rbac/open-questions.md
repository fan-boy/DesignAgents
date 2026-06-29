# Open Questions — Role-Based Access Control (RBAC)

## Unresolved

- [ ] [PM] Is the Dashboard Viewer's access to "all dashboard views" intentional — meaning they see cross-surface data that functional managers (AEP Manager, Training & Simulations Manager) cannot? Or should Dashboard Viewer also be scoped to specific surfaces?
- [ ] [PM] Can Dashboard Viewers export reports and data? Export is a read action, not a write action — is it permitted?
- [ ] [PM] Does "manage" within AEP Manager and Training & Simulations Manager roles include delete, or only create/edit/assign?
- [ ] [Both] Is SCIM/IdP provisioning in scope for v1? If yes, what is the role attribute mapping schema for Okta/Azure AD?
- [ ] [PM] Is the bundling of Training and Simulations into one role intentional, or should simulation-only access be possible without granting training access?
- [ ] [Eng] When a Full Access user is downgraded mid-session, must their session be invalidated immediately (forced re-auth), or is enforcement on next page load/API call acceptable from a security standpoint?
- [ ] [PM] Where does the audit log surface in the UI — dedicated admin surface, sub-tab in User Management, or another location? Which roles can access it?
- [ ] [Both] Is bulk role-change (e.g., reassigning 50 users at once) in scope for v1?
- [ ] [PM] Is there a plan for an in-product access request flow, or should scoped users use out-of-band methods (email, Slack) to request elevated access?
- [ ] [PM] What is the UX for a pending invite — can the admin change a user's role before they activate their account?
- [ ] [PM] Are role names ("Full Access", "AEP Manager", etc.) final, or should we evaluate more conventional enterprise naming (e.g., "Administrator", "Campaign Manager")?

## Resolved

_(none yet)_
