# AI_worker — 大專案 Workflow 系統

這個專案資料夾本身就是一套 Claude Code workflow,把整個軟體開發流程拆成 10 個 slash commands、11 個專業 agents、6 個共用 skills。

## 對話語言政策

- 跟使用者(Leo)的對話一律用**繁體中文**
- 所有 specs、code、commit messages、檔名、識別字一律用**英文**
- 例外:`discussion/notes.md` 可以中文,因為是討論原文

## 兩種 Workflow

### A. v1 從零打造 (Greenfield)

```
/discuss-project  →  /decide-stack  →  /generate-specs  →  /review-specs
                                                                  ↓
            /git-push  ←  /review-code  ←  /implement  ←  /init-project
                                                ↑
                                    /status  /resume  /sync-spec (隨時)
```

### B. Maintenance (v1 之後加 feature / 修 bug)

```
加新功能:    /feature <描述>     ─→ 自動分流 small/medium/big
修 bug:      /fix <描述>          ─→ 自動分流 tiny/real/big
重做某 task:  /reset-task <id>     ─→ done → pending,可選 git revert
推上 GitHub:
  ├─ 新專案首次 → /git-push       (建 private repo + push main)
  ├─ feature/fix 分支 → /git-pr   (push branch + 開 PR)
  └─ 中途看 → /status, /sync-spec
```

每一步都要等使用者確認再進下一步,不要自己一路跑下去。每個指令結尾必須印出**下一步建議指令**。

## 權威順序 (Authority order)

當資訊衝突時,以這個順序為準:

1. **`specs/CONSTITUTION.md`** — 不可違反的鐵則(架構憲法)
2. **`specs/*.md`** — 各層 spec(stack / overview / architecture / db / api / backend / frontend / tests / devops)
3. **`CLAUDE.md`(專案根)** — 操作手冊
4. **`AGENTS.md`(專案根)** — 人工累積的踩坑紀錄(只能人類寫,agent 不能)
5. Agent 自己的判斷

衝突時 agent 必須**停下來告訴使用者**,不能私自決定。

## 關鍵檔案 / 狀態位置

| 路徑 | 用途 |
|---|---|
| `discussion/notes.md` | 需求討論的累積筆記 |
| `specs/CONSTITUTION.md` | **架構憲法** — 不可違反的鐵則 |
| `specs/00-stack.md` ~ `60-devops.md` | 9 份 spec |
| `specs/REVIEW.md` | spec 審查結果 |
| `state/manifest.json` | 進度的單一真相來源 |
| `state/runlog/<ts>.md` | 每次 `/implement` 的執行記錄 |
| `state/activity/<date>.log` | 每天的檔案修改記錄(由 PostToolUse hook 寫) |
| `state/code-review.md` | 最終 code review |
| `CLAUDE.md`(專案根目錄) | 由 `/init-project` 產生,描述當前正在做的產品 |
| `AGENTS.md`(專案根目錄) | **人工維護**的踩坑、patterns、ADR 索引 |
| `docs/adr/NNNN-*.md` | Architectural Decision Records,由 system-architect 產 |

## 寫 specs / code 的鐵律

- 只在 `## Tasks` checklist 的範圍內動工,不擴大 scope
- 每個 spec 結尾都要有 `## Tasks` 區段,每個 task 是一個 checkbox + 對應的 manifest task id
- agent 不要互相覆蓋對方的檔案;每個 agent 只動自己負責的目錄
- manifest.json 用原子寫入(寫到 `.tmp` 再 `mv`),避免 race condition

## 不要做的事

- 不要在使用者沒講要 push 之前 push
- 不要在沒跑 `/review-specs` 之前跑 `/implement` (Greenfield)
- 不要在 `/git-push` 時用 `--public`,預設一律 private
- 不要把 `.env` 或任何 secret 檔放進 git(`.gitignore` 必須包含)
- 不要在 specs 還沒生出來時建立 src/ 程式碼
- **Maintenance 模式時**:不要在 main 分支直接寫 feature/fix code(`/feature` 和 `/fix` 都會自動 branch off)
- **Maintenance 模式時**:不要 regenerate 整個 manifest(`/feature` / `/fix` 是 append-only)
- 不要 reset done task 而不警告使用者下游影響
- 不要在 `/git-pr` 時 force-push

## Task `kind` 欄位

manifest task 有三種 `kind`:
- `initial` — 由 `/generate-specs` 產生(v1 的 task)
- `feature` — 由 `/feature` 加上(後續新功能)
- `fix` — 由 `/fix` 加上(bug 修復)

`/status` 會分類顯示。`kind: "fix"` 的 commit 訊息格式 `[<agent>] [fix] <title>`,`feature` 是 `[<agent>] [feat] <title>`。

## 自學系統 (Self-Learning Layers)

### Layer 1 — Per-session memory（Claude 負責）

每次有意義的對話結束前，Claude 必須主動把值得跨 session 記憶的資訊存進 memory：

```
~/.claude/projects/-Users-leo-Desktop-github-AI-startup-AI-worker/memory/
```

**存的時機（穩定資訊）：**
- 確認了某個設計決策（e.g. Redis key 格式、HTTP 狀態碼選擇）
- 發現 CLI 工具的非顯而易見 flag 或行為（ruff、mypy、alembic 等）
- Leo 表達了明確的工作偏好（e.g. batch 上限、commit 格式）
- 解決了 spec 模糊之處

**絕對不存（不穩定資訊，存了會導致用舊方式 debug）：**
- 具體的 debug 步驟或 bug 修法（bug 修掉了，記憶就過時了）
- 「某函式/模組目前有 X 行為」（code 會變）
- 因環境問題觸發的 FAIL（網路、版本衝突、CI 不穩定）
- 任何用「這次」、「剛才」、「今天發現」描述的暫態狀況

**格式：** 每條 ≤4 句，開頭標 `[AI_worker]`

### Layer 2 — Blocked task lessons（Leo 負責）

`/implement` 把任務標為 `blocked` 時，自動在 `state/pending-learnings.md` 加一筆。
`on-stop.sh` 在 session 結束時顯示待處理筆數。
Leo 審查後把值得的內容升級到 `AGENTS.md`，再從 pending 檔刪除該條目。
升級原則：只升級**架構層面的教訓**（設計選擇、API 契約、邊界條件）；不升級具體 bug 修法或環境問題。

| 角色 | 動作 |
|---|---|
| Agent | 寫入 `state/pending-learnings.md` |
| Leo | 審查、升級到 `AGENTS.md`、刪除已處理條目 |
| `on-stop.sh` | 顯示待處理筆數提醒 |

## STATUS.md 規範（給 Hermes 監控用）

每個重要節點都要更新 `STATUS.md`（放在專案根目錄）。

### 格式
PHASE: <階段名稱>
STATUS: <RUNNING | WAITING_USER | DONE | BLOCKED>
MESSAGE: <給使用者看的中文說明>
### 什麼時候更新
| 時機 | STATUS | 說明 |
|---|---|---|
| 開始執行某 Phase | RUNNING | 讓 Hermes 知道在跑 |
| 需要使用者做選擇 | WAITING_USER | Hermes 會通知你 |
| 整個專案完成 | DONE | 全部結束 |
| 遇到無法繼續的問題 | BLOCKED | 需要人介入 |

### 重要規則
- 同一個 STATUS 不重複更新（只有真正變化才寫）
- WAITING_USER 時必須在 MESSAGE 說清楚要使用者做什麼決定
- Hermes 只讀這個檔案，不看 manifest.json

## GBrain 整合

GBrain 是開發大腦，儲存架構決策、踩坑經驗、設計模式。

Skills 位置：~/coding-agent/gbrain/skills/

### 每次開始新任務前
讀取 gbrain/skills/brain-ops/SKILL.md，先查 brain 有沒有相關經驗。

### 每次對話中
讀取 gbrain/skills/signal-detector/SKILL.md，捕捉值得記住的資訊。

### 查詢語法
```bash
gbrain query "你的問題"
gbrain recall "關鍵字"
```

## Git Push 策略

### 自動推送時機（每個關鍵節點都要 push）

| 時機 | 指令 | commit 訊息格式 |
|---|---|---|
| TOGAF 文件產出後 | /git-push | docs: add TOGAF architecture documents |
| Specs 全部產出後 | /git-push | docs: add all specs and manifest |
| 每個 Phase implement 完成後 | /git-push | feat: complete phase X - <描述> |
| Code review 通過後 | /git-push | chore: post-review snapshot |
| 正式上線前 | /git-push | release: v1.0.0 |

### 推薦額外 push 時機

- 討論筆記累積超過 3 輪後（備份需求討論）
- 任何重大架構決策確認後
- 每天工作結束前（WIP commit）
- 遇到 BLOCKED 狀態前（保留現場）

### WIP Commit 格式
wip: <當前進度描述>
狀態: <RUNNING|WAITING_USER|BLOCKED>
下一步: <待完成的事>
### 規則
- TOGAF 產出後**必須** push，這是架構決策的永久記錄
- 每個 implement Phase 完成後**必須** push
- 永遠不推 .env 或任何 secrets

## 自動流程推進規則

每個指令完成後，**自動執行下一個指令**，不需要 Leo 手動輸入。

### Greenfield 自動流程
/discuss-project → (討論完成後自動) → /decide-stack
/decide-stack    → (確認後自動)     → /generate-togaf
/generate-togaf  → (產出後自動)     → /git-push (TOGAF commit)
/git-push        → (push後自動)     → /generate-specs
/generate-specs  → (產出後自動)     → /review-specs
/review-specs    → (審查通過後自動) → /init-project
/init-project    → (scaffold後自動) → /implement
/implement       → (每Phase完成後自動) → /git-push → 繼續下一Phase
/implement       → (全部完成後自動) → /review-code
/review-code     → (通過後自動)     → /git-push
### 規則
- 每個指令的 Exit checklist 全部通過才推進
- WAITING_USER 時停下來等 Leo 回覆，回覆後繼續
- BLOCKED 時停下來，不自動推進，等 Leo 處理
- 每次推進前告訴 Leo：「✅ XXX 完成，自動進入 YYY...」
