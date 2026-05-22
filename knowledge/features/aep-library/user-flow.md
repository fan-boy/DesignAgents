# User Flow — AEP Builder
Dune Security · User Flow · Last updated: 2026-05-22 (v3 — 2-step builder)

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
   - **AEP Name** — free text (e.g., "Concentrix — UA Refund Fraud")
   - **Attack Type** — dropdown (Refund Fraud / Credential Theft / SIM Swap / Account Action / Data Exfiltration / Other)
   - **Adversary Method** — chip selector, pick 1–2 (Authority / Urgency / Reciprocity / Curiosity / Scarcity / Familiarity)
   - **Target Context** — textarea: who the employee targets are (role, business unit, org context)
   - **Opening Message** — textarea: the first message the AEP sends to the employee
4. Manager optionally uploads **example messages** — real social engineering messages the org has received (.txt, .docx, .jpg, .png). Drag-and-drop zone + paste text inline option. Up to 5 files.
5. Manager selects **target channels** (WhatsApp, Telegram, SMS, Teams, etc.) — chips multi-select.
6. Manager clicks **"Generate & Test →"**.
7. Generation progress screen: labeled stages advancing ("Analyzing scenario" → "Building persona" → "Configuring behavior" → "Ready"). ~15–45 seconds.
8. Builder advances to **Step 2: Chat Test**.

---

### Step 2: Chat Test

**Layout: three areas**
- Left sidebar: Behavior refinement panel + session history
- Main area: Live chat conversation
- Each AEP message has inline feedback controls

**Starting the test**
9. AEP persona sends its opening message automatically.
10. Manager types a reply as the employee (or clicks an archetype quick-start chip to inject a preset reply).

**Archetype quick-starts** (chips above message input):
- Curious · Skeptical · Hostile · Compliant — each injects a pre-written first response

**Conversation flow**
11. Manager and persona exchange messages. After each AEP response, **feedback controls appear under the message**:
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

**Behavior refinement (left sidebar)**
12. Left sidebar always shows a **Refine behavior** input:
    - Textarea: "What should the AEP do differently?"
    - Example hints rotate in placeholder: "Make the opening more casual", "Use more Tagalog phrases", "Be less pushy on first refusal"
    - "Apply changes" button — applies to the AEP and starts a new chat session automatically

**New chat**
13. "New Chat" button at top of main area (and in sidebar session list) — starts a fresh conversation, preserves all previous sessions in the sidebar history list.

**Session history (left sidebar)**
- List of past sessions: timestamp + archetype used + session outcome (terminal state reached / abandoned)
- Click any session to view it read-only

**Publishing**
14. After at least 1 completed session, **"Publish AEP"** button activates in the page header.
15. Publish confirmation modal:
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
| "Generate & Test →" clicked | POST to generation API; labeled progress screen; P95 45s |
| Generation completes | Advances to Step 2; AEP persona sends opening message |
| Generation fails | Error state with retry; form state preserved |
| AEP sends response | Typing indicator 1–2s; response appears; 👍👎 controls visible below message |
| 👎 + "Apply & Regenerate" | New response generated for that turn only; replaces the flagged response inline |
| "Apply changes" (behavior) | AEP updated; new chat session auto-starts; prior session logged in sidebar |
| "New Chat" clicked | Fresh chat starts; session logged in sidebar list |
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
