# User Flow — AEP Library (Custom AEP Builder)
Dune Security · User Flow · Last updated: 2026-05-20

---

## Entry points

1. **Agentic Simulation > Red Teaming > AEP Library** — admin arrives at the library page
2. **Campaign builder — AEP selection step** — campaign manager needs an AEP for a new campaign; taps through to AEP Library to browse
3. **Notification or prompt** (future) — admin is notified that the Dune library has a new AEP relevant to their org

---

## Happy path — Create a new custom AEP with AI assist

1. Admin navigates to **AEP Library** via Red Teaming nav.
2. Page loads with two sections: **Dune Library** (3–4 seeded AEPs) and **Your AEPs** (custom section, may be empty).
3. Admin scans the Dune Library for relevant inspiration. Optionally clicks "View details" to open a detail drawer for any seeded AEP.
4. Admin clicks **"New AEP"** button in the Your AEPs section header.
5. Builder opens at **Step 1: Define**.
   - Admin types an AEP name (e.g., "Finance Director Impersonation")
   - Selects Adversary Method from dropdown (e.g., "Authority")
   - Writes a plain-language scenario description (e.g., "A finance director following up on an urgent wire transfer approval that was flagged as delayed. Escalates with increasing urgency if the target hesitates.")
   - Optionally expands Behavior Parameters: sets Escalation Tendency to High, Tone to Formal
6. Admin clicks **"Generate AEP"**.
7. System generates: loading skeleton appears on Workflow Steps, Branching Logic, and Outcome Criteria fields.
8. Generation completes. Builder advances to **Step 2: Configure** with all fields pre-populated.
9. Admin reads through generated Workflow Steps — reviews the bullet list, edits one step for accuracy.
10. Admin reads Branching Logic — edits the description to reflect a specific escalation phrase their org uses.
11. Admin clicks into Outcome Criteria tabs. Reviews **Complicit** criteria, edits to match their org's definition of what counts as providing sensitive information.
12. Admin reviews **Non Complicit** criteria — accepts the generated version.
13. Admin reviews **Undetermined** and **No Response** criteria — accepts both.
14. Admin is satisfied with the configuration. Clicks **"Continue to Test"**.
15. Builder advances to **Step 3: Test**. Left panel shows AEP summary (Name, Method, key Workflow Steps). Right panel shows simulator chat, empty.
16. Admin types an opening message in the simulator as if they are the target employee: "Hi, who is this?"
17. AEP responds as the persona (typing indicator visible for ~2s). Response displays in chat thread.
18. Admin exchanges 3–4 more messages, testing how the AEP handles hesitation and pushback.
19. Admin observes the outcome preview strip updating: "Based on this conversation: Non Complicit."
20. Admin is satisfied with behavior. Clicks **"Publish AEP"**.
21. **Publish confirmation modal** appears: "Publishing [AEP Name] will make it available in the campaign builder. Once it's referenced in an active campaign, it cannot be edited until that campaign concludes."
22. Admin clicks **"Publish AEP"** in the modal.
23. Builder closes. Returns to AEP Library. New AEP card is visible in Your AEPs section with **Published** badge and **Tested** chip. Counter updates: "3 of 5 custom AEPs."

---

## Happy path — Duplicate from Dune-seeded AEP

1. Admin arrives at AEP Library.
2. Finds a Dune-seeded AEP close to their intended scenario (e.g., "Impersonated IT Support").
3. Clicks **"Duplicate"** on the seeded card.
4. Builder opens at **Step 1: Define** with all fields pre-filled from the seeded AEP. AEP Name field is cleared and focused with placeholder "Give this AEP a new name."
5. Admin types a new name, optionally changes Adversary Method or edits the scenario description.
6. Admin clicks **"Generate AEP"** to regenerate from the edited description, OR clicks **"Skip generation — keep as-is"** to go directly to Step 2 with the seeded content as the starting point.
7. Continues from Step 2: Configure (same as happy path above, steps 9–14).
8. Continues through Step 3: Test and Publish (same as above, steps 15–23).

---

## Decision points

| Decision | Condition | Outcome |
|---|---|---|
| New AEP vs. Duplicate | Admin clicks "New AEP" vs. "Duplicate" on a card | New: blank Step 1 / Duplicate: pre-filled Step 1 |
| AI Generate vs. Manual | Admin clicks "Generate AEP" vs. "Skip generation" | Generate: loading → Step 2 pre-filled / Skip: Step 2 with empty fields |
| Step 2 → Step 3 | Admin clicks "Continue to Test" | Advances to simulator; all Step 2 state is preserved |
| Simulate → Reconfigure | Admin clicks "Back to Configure" in simulator | Returns to Step 2; simulator conversation state is preserved or cleared (TBD) |
| Publish eligibility | Has admin received at least one AEP response in simulator? | No: Publish button disabled with tooltip "Test the AEP before publishing" / Yes: Publish enabled |
| Edit published AEP | Is the AEP referenced in an active campaign? | Yes: edit blocked, banner shown / No: edit allowed, AEP returns to Draft status |
| Delete AEP | Is the AEP referenced in an active campaign? | Yes: delete blocked, explanation shown / No: delete confirmation modal |
| Custom limit reached | Has tenant reached limit (4 or 5 Published AEPs)? | Yes: "New AEP" button disabled with tooltip "Delete one to create a new AEP" |

---

## System responses

| Trigger | System behavior |
|---|---|
| "Generate AEP" clicked | POST request to generation API; skeleton loading state on all Step 2 fields; estimated duration: 3–8s |
| Generation completes | Step 2 fields populate with generated content; toast: "AEP generated — review and edit before testing" |
| Generation fails | Error inline in Step 1: "Generation failed — check your description and try again, or fill in the fields manually" with retry and skip CTAs |
| Admin sends message in simulator | Typing indicator (3 animated dots) appears in AEP side of chat; response appears within ~2–5s |
| Simulator times out (>15s response) | Error state in chat: "AEP is taking too long to respond. Try resetting or check back shortly." Reset and Back to Configure CTAs |
| Simulator unavailable | Full simulator pane error: "Simulator is temporarily unavailable. Your progress is saved. Try again shortly." |
| AEP published | Return to library; new card visible with Published badge; toast: "AEP published and available in the campaign builder" |
| Draft auto-saved | Silent background save on each field blur in Steps 1–2; no toast (avoid noise) |
| Edit triggers Draft status | When admin starts editing a Published AEP, immediate banner: "This AEP has returned to Draft status. Republish when you're done editing." |

---

## Edge cases from edge-cases.md

| Edge case | Handling |
|---|---|
| Custom AEP limit reached | "New AEP" button disabled; tooltip: "You've reached the limit of [N] custom AEPs. Delete a Draft or Published AEP to create a new one." Duplicate from Dune AEPs also blocked at the limit. |
| Deleting AEP in active campaign | Delete action blocked on card. Tooltip on delete: "This AEP is used in an active campaign and cannot be deleted until the campaign concludes." |
| Deleting AEP in completed campaign | Confirmation modal: "This AEP was used in [N] past campaign(s). Deleting it will not affect historical records, but it will no longer appear in those campaign details. Delete anyway?" |
| Editing AEP mid-campaign | Edit button blocked; banner on card: "Used in active campaign. Editing is locked." |
| AEP name collision | Inline validation on Step 1 Name field on blur: "An AEP with this name already exists. Choose a unique name." Submit blocked until resolved. |
| Simulator unavailable | Step 3 error state with retry action and "Back to Configure" — Publish remains locked until simulator completes at least one exchange |
| Simulator timeout (slow response) | After 15s: in-chat error message with retry. After 30s: suggest resetting conversation. |
| Admin without prompt engineering experience | Guided generation + AI-generated content reduces blank canvas risk. Simulator surfacing unexpected behavior is the main safety net. Generated content quality warnings ("This AEP may produce unpredictable responses — test thoroughly") flagged for PM — may require backend content moderation |
| First-time empty state (Your AEPs) | Empty state: illustration + "No custom AEPs yet" + two CTAs: "Duplicate a Dune AEP" and "Create from scratch" |
| Dune-seeded library fails to load | Skeleton cards in Dune Library section persist → replace with error state: "Couldn't load Dune Library AEPs. Refresh to try again." Your AEPs section loads independently. |
| Campaign manager views AEP Library | Page loads normally. "New AEP" button absent. "Edit" and "Delete" actions absent from cards. Cards show "Use in Campaign" CTA instead. Detail drawer shows "Use in Campaign" button in footer. |
| Very long prompt approaching token limit | Character counter below scenario description textarea. Warning at 80% of limit: "Approaching maximum length." At 100%: typing blocked, save blocked. Counter label: "[X] / [max] characters" |
| AEP used in completed campaign — deleted | Allowed with confirmation. Historical campaign record preserves the AEP name and ID as a snapshot; the live AEP object is removed. |
| Admin loses admin role mid-draft | Draft is auto-saved. When admin returns with campaign manager role, draft is visible in Your AEPs with "Draft" badge but Edit and Publish buttons are absent. Banner: "You no longer have access to edit this AEP. Contact your org admin." |

---

## Exit states

| State | How reached | What happens |
|---|---|---|
| **Published** | Admin completes Test step and confirms publish | AEP card visible in Your AEPs with Published badge; available in campaign builder |
| **Draft** | Admin exits builder before Step 3 or before publishing | AEP saved as Draft; visible in Your AEPs with Draft badge; not available in campaign builder |
| **Draft** (from Published) | Admin edits a Published AEP | AEP returns to Draft status during editing; removed from campaign builder until re-published |
| **Cancelled** | Admin closes browser or navigates away before saving | Draft is auto-saved (Step 1 or Step 2 content); if no content entered, nothing is saved |
| **Deleted** | Admin confirms delete from library card | AEP removed; custom limit counter decrements; confirmation toast |
| **Blocked (limit reached)** | Admin attempts to create when limit is full | Creation blocked at "New AEP" CTA; clear message with recovery path |
