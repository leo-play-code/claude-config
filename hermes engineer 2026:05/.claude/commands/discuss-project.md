---
description: Start a structured requirements discussion with Claude. Saves running notes to discussion/notes.md.
argument-hint: [optional initial product idea]
---

You are kicking off a new project discussion with Leo. Conduct a structured product interview in **Traditional Chinese** while writing notes in English to `discussion/notes.md`.

## Initial idea from user

$ARGUMENTS

## Entry checklist

- [ ] `discussion/` directory exists or can be created
- [ ] If `specs/` already has files, ask Leo whether this is a fresh project or continuation

## Steps

1. If `discussion/notes.md` already exists with content, read it first and continue from where you left off — don't restart the interview.
2. If it doesn't exist, create `discussion/` directory and start fresh.
3. Ask Leo a focused round of questions covering one of these dimensions per turn:
   - **What is the product?** (one-sentence pitch, problem solved)
   - **Who uses it?** (primary persona, are there others?)
   - **Must-have features for v1?** (3-5 max — be ruthless)
   - **What's explicitly NOT in v1?** (non-goals)
   - **Constraints?** (deadline, budget, team size, tech preferences)
   - **Success criteria?** (how do we know v1 is working)

   Pick the dimension with LEAST coverage. Skip well-covered ones.

4. After Leo answers, append to `discussion/notes.md`:

   ```markdown
   ## <YYYY-MM-DD HH:MM> — <topic>

   **Q:** <your question(s) translated to English>
   **A:** <Leo's answer translated; preserve key phrases verbatim>

   **Notes / open questions:** <anything to ask next round>
   ```

5. End with one of:
   - "還有其他細節要補充嗎? 我們可以繼續討論 `<下一個 dimension>`。"
   - 或者:"討論已經足夠完整,建議下一步執行 `/decide-stack` 決定技術棧並起草 Constitution。"

## Exit checklist (Definition of Done)

- [ ] `discussion/notes.md` has at least one round per major dimension OR Leo explicitly says "enough, let's move on"
- [ ] Open questions are flagged in notes (not silently dropped)

## Three-tier rules

### ✅ Always do
- Talk to Leo in Chinese; write notes in English
- One round per turn (don't interrogate)
- Translate-paraphrase notes (don't transcribe verbatim)

### ⚠️ Ask first
- Leo gives ambiguous answer → one follow-up before moving on

### 🚫 Never do
- Decide tech stack here (that's `/decide-stack`)
- Write specs (that's `/generate-specs`)
- Multi-question dumps
