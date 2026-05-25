# AI_worker — 大專案 Workflow 系統

這個專案資料夾本身就是一套 Claude Code workflow，把整個軟體開發流程拆成 slash commands、專業 agents、共用 skills。

## 對話語言政策

- 跟使用者 (Leo) 的對話一律用**繁體中文**
- 所有 specs、code、commit messages、檔名、識別字一律用**英文**
- 例外：`discussion/notes.md` 可以中文，因為是討論原文

---

## Workflow A — Greenfield (從零打造 v1)
/discuss-project
↓ (討論完成，Leo 說「沒有，繼續」)
/decide-stack
↓ (Leo 確認技術棧 + CONSTITUTION)
/generate-togaf
↓ (Leo 選擇模式) → 自動產出 → 自動 push → ✋ Leo 審核 TOGAF
↓ (Leo 說「確認，繼續」)
/generate-specs
↓ (自動)
/review-specs
↓ (自動，0 BLOCKING 才繼續)
/init-project
↓ (自動)
/implement
↓ (自動，每 Phase 完成自動 push)
/review-code
↓ (自動)
/git-push  ← release commit
## Workflow B — Maintenance (v1 之後)
加新功能:   /feature <描述>    → 自動分流 small/medium/big
修 bug:     /fix <描述>        → 自動分流 tiny/real/big
重做 task:  /reset-task <id>   → done → pending，可選 git revert
推上 GitHub:
├─ 新專案首次 → /git-push    (建 private repo + push main)
├─ feature/fix → /git-pr     (push branch + 開 PR)
└─ 中途看 → /status, /sync-spec
## Workflow C — Refactor (重構)
/refactor
↓ 沒有 togaf/
/reverse-togaf
↓ (Leo 選擇 TOGAF 模式) → 產出 SRS + TOGAF → ✋ Leo 確認差距分析
↓ 有 togaf/ 或完成逆向工程
✋ Leo 選擇重構模式（快速/標準/企業）
✋ Leo 選擇重構範圍（前端/後端/資料庫/全面）
↓ 自動建立 refactor branch + git snapshot
/generate-specs (只針對指定範圍)
↓ (自動)
/review-specs
↓ (自動，0 BLOCKING 才繼續)
/implement (只動 [REFACTOR] 和 [NEW] tasks)
↓ (自動，每 Phase 完成自動 push)
/git-pr ← 開 PR

---

## 自動執行規則

### ⚡ 完全自動，不問 Leo

| 指令完成後 | 下一步 |
|---|---|
| /generate-specs | → /review-specs |
| /review-specs (0 BLOCKING) | → /init-project |
| /init-project | → /implement |
| /implement 每個 Phase | → /git-push → 繼續下一 Phase |
| /implement 全部完成 | → /review-code |
| /review-code 通過 | → /git-push (release) |
| /git-push | → 下一個排定指令 |

### ✋ 必須等 Leo 回覆才繼續

| 時機 | Leo 需要做什麼 |
|---|---|
| /discuss-project 每輪 | 回答需求問題 |
| /decide-stack | 確認技術棧 + CONSTITUTION |
| /generate-togaf 產出後 | 選擇模式；審核 TOGAF 後說「確認，繼續」 |
| /reverse-togaf 產出後 | 選擇 TOGAF 模式；確認差距分析 |
| /refactor 開始 | 選擇重構模式 + 範圍 |
| /review-specs 有 BLOCKING | 決定怎麼修 |
| /implement 有 BLOCKED task | 處理後跑 /resume |
| /review-code 有問題 | 處理後繼續 |

### 🚫 絕對不做

- 不在使用者未要求時擴大 scope
- 不跳過 /review-specs 直接 /implement
- 不在 main branch 直接寫 feature/fix code
- 不把 .env 或任何 secret 推上 git
- 不在 specs 沒產出前建立 src/ 程式碼
- 不在 /git-pr 時 force-push
- 不 reset done task 而不警告下游影響

---

## Git Push 策略

| 時機 | commit 格式 |
|---|---|
| TOGAF 產出後 | `docs: add TOGAF architecture documents` |
| Specs 產出後 | `docs: add all specs and manifest` |
| 每個 implement Phase 完成後 | `feat: complete phase X - <描述>` |
| review-code 通過後 | `release: v1.0.0` |
| 重構每個 Phase 完成後 | `feat: refactor phase X - <描述>` |
| 重構全部完成後 | `feat: refactor complete` + 開 PR |
| 每天工作結束前 | `wip: <進度描述>` |
| BLOCKED 前 | `wip: blocked - <原因>` |

規則：
- TOGAF 產出後**必須** push
- 每個 implement Phase 完成後**必須** push
- 永遠不推 .env 或任何 secrets
- 預設一律 private repo

---

## 權威順序 (Authority Order)

當資訊衝突時，以這個順序為準：

1. `specs/CONSTITUTION.md` — 不可違反的鐵則
2. `specs/*.md` — 各層 spec
3. `CLAUDE.md`（專案根） — 操作手冊
4. `AGENTS.md`（專案根） — 人工踩坑紀錄（只能人類寫）
5. Agent 自己的判斷

衝突時 agent 必須**停下來告訴 Leo**，不能私自決定。

---

## 關鍵檔案位置

| 路徑 | 用途 |
|---|---|
| `discussion/notes.md` | 需求討論筆記 |
| `srs.md` | 逆向工程產出的需求文件（重構用） |
| `togaf/` | TOGAF 架構文件 |
| `specs/CONSTITUTION.md` | 架構憲法 |
| `specs/00-stack.md` ~ `60-devops.md` | 9 份 spec |
| `specs/REVIEW.md` | spec 審查結果 |
| `state/manifest.json` | 進度的單一真相來源 |
| `state/runlog/<ts>.md` | 每次 /implement 的執行記錄 |
| `state/activity/<date>.log` | 每天的檔案修改記錄 |
| `state/code-review.md` | 最終 code review |
| `STATUS.md` | Hermes 監控用的狀態檔 |
| `CLAUDE.md`（專案根） | 由 /init-project 產生 |
| `AGENTS.md`（專案根） | 人工維護的踩坑紀錄 |
| `docs/adr/NNNN-*.md` | Architectural Decision Records |

---

## Task Kind 欄位

| Kind | 產生時機 | commit 格式 |
|---|---|---|
| `initial` | /generate-specs | `[agent] <title>` |
| `feature` | /feature | `[agent] [feat] <title>` |
| `fix` | /fix | `[agent] [fix] <title>` |

---

## STATUS.md 規範（給 Hermes 監控用）

放在**專案根目錄**，格式：
PHASE: <階段名稱>
STATUS: <RUNNING | WAITING_USER | DONE | BLOCKED>
MESSAGE: <給使用者看的中文說明>

| 時機 | STATUS |
|---|---|
| 開始執行某 Phase | RUNNING |
| 需要 Leo 做選擇或確認 | WAITING_USER |
| 整個專案完成 | DONE |
| 遇到無法繼續的問題 | BLOCKED |

規則：
- 同一個 STATUS 不重複更新
- WAITING_USER 時 MESSAGE 必須說清楚 Leo 要做什麼決定
- Hermes 只讀這個檔案，不看 manifest.json

---

## GBrain 整合

GBrain 是開發大腦，儲存架構決策、踩坑經驗、設計模式。

Skills 位置：`~/coding-agent/gbrain/skills/`

每次開始新任務前，讀取 `gbrain/skills/brain-ops/SKILL.md`，先查 brain 有沒有相關經驗。

每次對話中，讀取 `gbrain/skills/signal-detector/SKILL.md`，捕捉值得記住的資訊。

查詢語法：
```bash
gbrain query "你的問題"
gbrain recall "關鍵字"
```

---

## 自學系統

### Layer 1 — Per-session memory（Claude 負責）

每次有意義的對話結束前，把穩定資訊存進 memory：
- 確認了設計決策
- 發現 CLI 工具的非顯而易見行為
- Leo 表達了明確的工作偏好
- 解決了 spec 模糊之處

不存暫態資訊（bug 修法、環境問題、「這次發現」的事）。

格式：每條 ≤4 句，開頭標 `[AI_worker]`

### Layer 2 — Blocked task lessons（Leo 負責）

/implement 把任務標為 blocked 時，自動在 `state/pending-learnings.md` 加一筆。
Leo 審查後把架構層面的教訓升級到 `AGENTS.md`。

| 角色 | 動作 |
|---|---|
| Agent | 寫入 state/pending-learnings.md |
| Leo | 審查、升級到 AGENTS.md、刪除已處理條目 |
| on-stop.sh | 顯示待處理筆數提醒 |
