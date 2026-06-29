# Edge Cases — Role-Based Access Control (RBAC)

## System states
- Role change API call fails mid-confirmation (network error, 500) — modal must not dismiss silently; admin needs an error state with a retry option
- User invite email fails to deliver — admin should see user in a "Pending" state in User Management with a resend option
- Session token caches the previous role after a downgrade — confirm token refresh cadence with Eng so the enforcement window is known
- Audit log write fails — role change should still succeed, but the failure to log must surface to the admin or be queued for retry

## Permission states
- Scoped user navigates directly to a gated URL — returns a permission-denied empty state (not 404) with "contact your admin" message
- AEP Manager navigates to a Training surface URL they previously had access to (before role change) — permission-denied state with no history-of-access language
- Dashboard Viewer attempts a configuration action on a dashboard widget — hidden or disabled with tooltip: "You have view-only access. Contact your admin to request changes."
- Full Access admin views their own role badge in User Management — can they click to change their own role? PRD allows it unless they're the last Full Access admin
- Scoped manager navigates to User Management via direct URL — permission-denied, not in nav
- Dashboard Viewer attempts a write action via API — must return 403 Forbidden at the API layer, not just a UI block

## Content states
- Organization has only one user (the original Full Access admin) — User Management shows one row; invite CTA is the primary action
- All users in the org are Dashboard Viewers — no functional work is possible; platform should surface an onboarding prompt to invite functional managers
- User Management table with 100+ users — role-based filtering and sorting must be available (not specified in PRD; flag as a gap)
- User has a pending invite (not yet activated) — role badge shows "Pending"; admin can change role before activation
- Dashboard data for AEP Manager with no campaigns yet — dashboard shows an empty state scoped to AEP surface, not org-wide data
- Scoped manager assigned to a surface that currently has no content — empty state must be role-aware (cannot suggest creating content from another surface)

## Action states
- Full Access admin downgrades their own role when not the last Full Access admin — permitted; confirmation modal required
- Last Full Access admin attempts to downgrade their own role — blocked with error: "Assign Full Access to another user first."
- Full Access admin is deactivated — system must require at least one other Full Access admin to exist before deactivation is permitted
- Admin changes role for a user who is currently running an active AEP campaign — campaign continues; admin should see a warning: "This user has an active campaign. Their role will change, but existing campaigns will continue."
- Admin bulk-invites users with mixed roles — each row confirms its own role; submission returns per-row success/failure feedback
- Role change while user has a write-capable surface open — user completes any in-progress action; role enforced on next page load or API call

## Responsive / Accessibility
- Role selector dropdown in multi-row invite table — keyboard navigation through role options must work per row; tab order must be logical across email field → role selector per row
- Role badge in header/account menu — must meet WCAG AA contrast for all four role variants in light and dark themes
- Permission-denied state — must be announced to screen readers as a meaningful page-level error, not a silent render
- Confirmation modal for role change — focus must be trapped in modal; Escape key must cancel; Enter must not confirm destructive actions without explicit button press
- Mobile: User Management table with inline role selectors is complex at narrow viewports — confirm whether mobile is in scope or out of scope for v1
