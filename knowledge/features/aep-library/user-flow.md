# User Flow — AEP Builder
Dune Security · User Flow · Last updated: 2026-06-08 (v5 — version control + rollback flows added)

---

## Entry points

1. **Red Teaming > AEP Library** — Security Manager arrives at the library page from the nav
2. **"New AEP" button** — from the AEP Library table/grid
3. **"Clone" action** — from an existing AEP card, pre-fills Step 1 from source

---

## Happy path — Create a new AEP

### Step 1: Setup

1. Manager clicks **"New AEP"** from the AEP Library.
2. Builder opens full-page at **Step 1 of 2: Setup**. Step indicator at top shows ① Setup ② Test.
3. Manager fills mandatory fields:
   - **AEP Title** — free text (e.g., "Meta IT Impersonator")
   - **Adversary Method** — chip selector, pick 1–2 (Authority / Urgency / Reciprocity / Curiosity / Scarcity / Familiarity). Severity shown inline (e.g., "Moderate").
   - **Target Context** — textarea: who the employee targets are (role, business unit, org context). Placeholder: "Who is the target? Describe their role, department, and org context…"
4. Manager optionally uploads **example messages** — real social engineering messages the org has received (.txt, .docx, .jpg, .png with OCR). Drag-and-drop zone + paste inline option. Up to 5 files.
5. Optionally: Manager selects a **template** from the picker (Dune-curated, e.g. "Ransomware") to pre-fill the form fields.
6. Optionally: Manager clicks **"View More"** to expand advanced configuration fields (Attack Scenario, Systems at Risk, Rules & Compliance, Cultural Context, Termination Logic).
7. Manager clicks **"Refine and Test"** (primary CTA).
8. Generation progress screen: labeled stages advancing ("Analyzing scenario" → "Building persona" → "Configuring behavior" → "Ready"). ~15–45 seconds.
9. Builder advances to **Step 2: Test & Refine**.

---

### Step 2: Test & Refine

**Layout: two panels**
- Left panel: AI Refine panel (Quick Actions + Custom Instruction + Recent Changes + Apply and Regenerate CTA)
- Right panel: Live chat conversation with inline per-message feedback controls

**Starting the test**
10. AEP persona sends its opening message automatically.
11. Manager types a reply as the employee (or clicks an archetype quick-start chip to inject a preset reply).

**Archetype quick-starts** ("Reply as:" chips above message input):
- Curious · Skeptical · Hostile · Compliant — each injects a pre-written first response

**Conversation flow**
12. Manager and persona exchange messages. After each AEP response, **feedback controls appear under the message**:
    - 👍 (good) and 👎 (not good) icon buttons
    - Clicking either expands an **inline feedback panel** directly below the message

**Thumbs-up feedback panel (inline)**
- Header: "What worked?"
- Quick-select chips: "Perfect tone" · "Realistic" · "Good adaptation" · "Felt natural"
- Optional free-text note field
- "Save" button — logs the positive signal to the AEP session

**Thumbs-down feedback panel (inline)**
- Header: "What's wrong with this response?"
- Quick-select chips: "Too formal" · "Too aggressive" · "Off-topic" · "Unrealistic" · "Wrong language register"
- Free-text field: "Describe the issue or suggest a better response…"
- "Apply & Regenerate" button — immediately regenerates that specific response using the feedback as context

**AI Refine Panel (left panel)**
13. The left panel is always visible. It contains:
    - **Quick Actions** chips: More casual · Less aggressive · Add urgency · More formal · Shorter · More empathetic. Clicking a chip selects it and updates the CTA to "Apply '[Chip Label]'."
    - **Custom Instruction** textarea: "Describe a change to the AEP's behavior… e.g. 'Don't mention dollar amounts so early'"
    - **Recent Changes** list: chronological history of applied instructions with timestamps
    - **Apply and Regenerate** CTA (or "Apply '[Chip Label]'" when a chip is selected)

**Refinement states**
- *Chip selected:* Chip highlights, CTA updates to name the chip.
- *Applying:* "Applying changes…" shown while the instruction processes (P95 < 20s).
- *Applied / success:* "✦ Regenerated" tag appears on the first message of the new session. Recent Changes appends the instruction with "just now." Toast: "Changes applied — new session started."
- *Error:* "Generation failed" in Recent Changes. Inline: "Something went wrong. Your changes weren't saved." "Try again →" available.

**New chat**
14. Applying a behavior change via the left panel automatically starts a new chat session. The prior session's conversation remains accessible in the right panel.

**Publishing**
15. After at least 1 completed session, **"Publish AEP"** button activates in the page header.
16. Publish confirmation modal:
    - AEP name + immutability notice
    - Warning acknowledgment if fewer than 2 sessions completed
16. Confirm → AEP moves to Active status in the library.

---

## Decision points

| Decision | Condition | Outcome |
|---|---|---|
| Generation succeeds | All sections generate | Advances to Step 2 |
| Generation fails | Full failure | Error state with retry; form inputs preserved |
| Thumbs down + Apply | Manager submits feedback | Regenerates that specific AEP response inline |
| Apply behavior change | Manager submits refinement prompt | AEP updated; new chat session starts automatically |
| New chat | Manager clicks New Chat | Fresh session; prior sessions saved in sidebar |
| Publish eligibility | At least 1 completed session | Less than 1: Publish disabled; 1: Warning acknowledgment required |
| Clone | Manager clones an existing AEP | Step 1 pre-filled from source with "clone of…" banner |

---

## System responses

| Trigger | System behavior |
|---|---|
| "Refine and Test" clicked | POST to generation API; labeled progress screen; P95 45s |
| Generation completes | Advances to Step 2; AEP persona sends opening message |
| Generation fails | Error state with retry; form state preserved |
| AEP sends response | Typing indicator 1–2s; response appears; 👍👎 controls visible below message |
| 👎 + "Apply & Regenerate" | New response generated for that turn only; replaces the flagged response inline |
| "Apply and Regenerate" (behavior change) | AEP updated; new chat session auto-starts; "Changes applied — new session started" toast; Recent Changes updated |
| Quick Action chip + Apply | Same as behavior change; chip label used as instruction |
| Behavior change error | "Generation failed" in Recent Changes; "Try again →" available; instruction text preserved |
| "Publish AEP" confirmed | Validation; AEP status → Active; toast: "AEP published and available in campaign builder" |

---

## Edge cases

| Edge case | Handling |
|---|---|
| Generation fails | Retry CTA; form inputs preserved; error describes which component failed |
| Thumbs-down with no comment | Chips alone are sufficient; free text is optional |
| Apply behavior change mid-conversation | Confirmation: "This will start a new chat. Current conversation will be saved." |
| 0 test sessions at publish | Publish button disabled with tooltip: "Complete at least one test session before publishing" |
| 1 test session at publish | Warning acknowledgment checkbox required |
| Opening message exceeds 280 chars + SMS channel | Validation warning: "May be truncated on SMS channels" |
| Clone from Active AEP | Step 1 pre-filled; banner: "Based on [Source AEP]. Regenerate to apply your changes." |

---

## Exit states

| State | How reached |
|---|---|
| **Draft** | Manager saves or exits before publishing |
| **Active** | Manager completes Step 2 and publishes |
| **Pending Review** | Manager publishes with Reviewer configured on account |
| **Abandoned** | Manager closes without saving |

---

## Version control flows

### Flow A — Revert to builder checkpoint (within Draft)

**Trigger:** Manager is in Step 2 and wants to undo recent refinements and return the AEP to an earlier behavioral state.

1. Manager locates a previous session in the **Session History** list in the left panel.
2. Manager opens the "..." menu on a session row → clicks **"Revert to here"**.
3. Confirmation modal appears:
   - *"Reset to Session [N]?"*
   - Body: *"The AEP's behavior will reset to what it was after Session [N] — [archetype], [date]. Sessions after this will stay in your history. A new session starts automatically."*
   - Actions: **Cancel** (left) | **Reset and restart** (right, primary)
4. On confirm:
   - AEP behavioral state resets to the selected checkpoint
   - All sessions after the checkpoint remain in history as read-only (greyed, labelled "Before reset")
   - A new session auto-starts immediately in the chat panel
   - Left panel Recent Changes appends: *"Reverted to Session [N] — just now"*
5. Manager continues testing from the restored behavioral state.

**When to use:** Applied several changes and the AEP got worse; wants to try a different direction from an earlier state.

---

### Flow B — Restore from version history (from AEP Library, post-publish)

**Trigger:** Manager has published v2 (or later) and decides a previous version was better. They want to create a new version based on an older one.

**Entry points:**
- AEP Library table → row "..." menu → **"Version history"**
- AEP Detail page → **"Version History"** tab

**Steps:**
1. Manager opens the Version History tab on the AEP Detail page.
2. Version history list shows all versions:
   - Each row: version number (v1, v2…), published date, sessions count, status (Active / Archived), campaigns using this version
   - Current Active version is labeled "Current"
3. Manager identifies the version to restore and clicks **"Restore"** on that row.
4. Restore confirmation modal appears:
   - *"Restore v[N] as a new draft?"*
   - Body: *"A new Draft (v[N+1]) will be created from v[N] — published [date]. Your current v[current] stays Active. Campaigns using v[current] are not affected."*
   - Actions: **Cancel** (left) | **Create Draft from v[N]** (right, primary)
5. On confirm:
   - New Draft (next version number) is created, cloned from the selected version
   - Manager is taken to **Step 1** of the builder with a banner: *"Restored from v[N] — published [date]. Review the details below and regenerate when ready."*
6. Manager reviews Step 1 fields (may edit or leave as-is), clicks **"Refine and Test"**.
7. Normal generation + Step 2 test flow proceeds.
8. Manager publishes the restored Draft as the new Active version.
9. Campaigns using the old version remain pinned to it; new campaigns can now select the restored version.

---

## Decision points (updated — version control)

| Decision | Condition | Outcome |
|---|---|---|
| Generation succeeds | All sections generate | Advances to Step 2 |
| Generation fails | Full failure | Error state with retry; form inputs preserved |
| Thumbs down + Apply | Manager submits feedback | Regenerates that specific AEP response inline |
| Apply behavior change | Manager submits refinement prompt | AEP updated; new chat session starts automatically |
| Revert to checkpoint | Manager selects "Revert to here" on a session | Confirmation modal → AEP resets to that behavioral state; new session starts |
| Publish eligibility | At least 1 completed session | Less than 1: Publish disabled; 1: Warning acknowledgment required |
| Clone | Manager clones an existing AEP | Step 1 pre-filled; clone banner; next version number assigned |
| Restore from version history | Manager clicks "Restore" on a past version | Confirmation modal → new Draft created from that version; builder opens at Step 1 with restore banner |
| Campaign pinned to older version | Manager publishes new version | Campaigns remain pinned to their original version; must be updated manually |

---

## System responses (updated — version control)

| Trigger | System behavior |
|---|---|
| "Revert to here" confirmed | AEP behavioral state resets to checkpoint; new session auto-starts; Recent Changes appended; post-checkpoint sessions marked read-only |
| "Create Draft from v[N]" confirmed | New Draft created from selected version; builder opens at Step 1 with restore banner |
| "Refine and Test" on restored Draft | Normal generation flow; produces new behavioral state from the restored form inputs |
| Publish restored Draft | AEP status → Active as new version; previous versions remain Archived; campaigns unaffected |
