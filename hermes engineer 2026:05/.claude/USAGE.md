# AI_worker Workflow 使用手冊

15 個指令的完整速查表,搭配常見情境直接抄。

---

## 🚀 一頁速查表

```
═══ Greenfield (從零做 v1) ═══
/discuss-project [想法]   ─→ 開始討論需求
/decide-stack             ─→ 決定 stack + 起草 CONSTITUTION
/generate-specs           ─→ 派 8 個 agent 寫 9 份 specs + manifest
/review-specs             ─→ 審 specs(改 spec 比改 code 便宜 100×)
/init-project             ─→ scaffold CLAUDE.md / .gitignore / .env.example
/implement                ─→ DAG 並行派 agent + worktree + retry + commit
/review-code              ─→ 最終 review + smoke test + 產 README
/git-push                 ─→ 第一次:建 private repo + push main

═══ Maintenance (v1 之後) ═══
/feature <描述>           ─→ 加新功能,自動分流 small/medium/big
/fix <描述>               ─→ 修 bug,自動分流 tiny/real/big
/reset-task <id>          ─→ done task 重做(可 git revert)
/git-pr                   ─→ feature/fix 分支 push + 開 PR

═══ 中途任何時候 ═══
/status                   ─→ 進度 / blocked / 下一步建議
/resume                   ─→ 把 blocked 拉回 pending
/sync-spec                ─→ 抓 spec ↔ code drift
```

---

## 📋 20 個常見情境 → 直接抄

### 🌱 開新專案

| 情境 | 你輸入 |
|---|---|
| 1. 完全空白資料夾,想做新專案 | `/discuss-project 我想做 <什麼>` |
| 2. 討論完了想看選什麼技術 | `/decide-stack` |
| 3. Stack 定了想開始寫 specs | `/generate-specs` |
| 4. Specs 寫完想審查 | `/review-specs` |
| 5. Specs 沒問題要建專案結構 | `/init-project` |
| 6. 想開始實作 | `/implement` |
| 7. 全部 task 完成想最終審查 | `/review-code` |
| 8. 全綠想推上 GitHub | `/git-push` |

### ✨ 已有專案,加功能

| 情境 | 你輸入 |
|---|---|
| 9. 想加按鈕 / 小改動 | `/feature 加 mark all done 按鈕` → 自動判定 🟢 Small |
| 10. 加新模組(像 tags 系統) | `/feature 給 todos 加 tags` → 自動判定 🟡 Medium |
| 11. 加大 vertical(像團隊協作) | `/feature 加團隊協作` → 自動判定 🔴 Big |
| 12. feature 寫完開 PR | `/git-pr` |

### 🐛 修 bug

| 情境 | 你輸入 |
|---|---|
| 13. typo / log 訊息錯 | `/fix tdos 應該是 todos` → 🟢 Tiny,直接修 commit |
| 14. 邏輯 bug / 漏 validation | `/fix 大寫 email 沒辦法登入` → 🟡 Real |
| 15. 架構錯誤 | `/fix 應該用 JWT 不是 session` → 🔴 Big |

### 🔄 出狀況

| 情境 | 你輸入 |
|---|---|
| 16. 看現在進度 | `/status` |
| 17. 有 task blocked,我修好了 | `/resume`(會問你 re-run 還是接受 worktree) |
| 18. 改了 schema 但 spec 沒同步 | `/sync-spec` |

### ↩️ 重做 / 反轉

| 情境 | 你輸入 |
|---|---|
| 19. 某個 done task 寫錯了要重做 | `/reset-task <task-id> --revert` |
| 20. 最新 commit 想直接刪掉(沒 push) | `/reset-task <task-id> --hard` |

---

## 🌳 完整決策樹

```
你現在想做什麼?
│
├─ 開新專案 (空白資料夾)
│   └─→ /discuss-project
│
├─ 已有專案
│   │
│   ├─ 想加功能
│   │   └─→ /feature <描述>
│   │       └─→ 完工後 → /git-pr
│   │
│   ├─ 修 bug
│   │   └─→ /fix <描述>
│   │       ├─ Tiny → 直接 commit (不開分支)
│   │       └─ Real/Big 完工後 → /git-pr
│   │
│   ├─ 想看現在哪裡 → /status
│   │
│   ├─ 上次某 task blocked,修好了 → /resume
│   │
│   ├─ 改了 code 但 spec 沒跟上 → /sync-spec
│   │
│   └─ 某個 done task 要重做 → /reset-task <id>
```

---

## ⛓️ 依賴關係(哪個指令要先跑哪個)

```
必須順序(Greenfield):
  /discuss-project → /decide-stack → /generate-specs
       ↓
  /review-specs → /init-project → /implement
       ↓
  /review-code → /git-push
```

```
無依賴(隨時可跑):
  /status     ─→ 任何時候
  /sync-spec  ─→ 有 manifest 後任何時候
```

```
Maintenance 鏈:
  /feature 或 /fix    →  自動內部呼叫 /implement → /review-code
                       →  完工後你手動 /git-pr
  /reset-task         →  自動 git revert 之後可跑 /implement 重做
```

---

## 🚦 紅綠燈:能不能跑這個指令?

| 想跑的指令 | 必須有的 | 不能有的 |
|---|---|---|
| `/decide-stack` | discussion/notes.md | — |
| `/generate-specs` | 00-stack.md + CONSTITUTION.md | — |
| `/review-specs` | 全部 9 specs | — |
| `/init-project` | REVIEW.md(0 BLOCKING) | — |
| `/implement` | manifest + CLAUDE.md + REVIEW.md | running 卡住的 task |
| `/review-code` | 所有非 doc-* tasks 都 done | blocked tasks |
| `/git-push` | code-review.md PASS | staged `.env` |
| `/feature` | manifest 已存在 | running 卡住的 task |
| `/fix` | manifest 已存在 | running 卡住的 task |
| `/git-pr` | 不在 main 分支 + origin 已存在 | staged secrets |
| `/reset-task <id>` | task 在 manifest 裡 | task 不是 done |

如果不滿足,Claude 會擋你並告訴你要先跑哪個。

---

## 💡 黃金原則

1. **第一次推 GitHub 用 `/git-push`,之後每次都 `/git-pr`**
2. **改 code 之前先想:這要動 spec 嗎?** 動 spec 走 `/feature` 或 `/fix`,不動 spec 才用對話直接修
3. **每個指令結尾 Claude 都會建議下一步**,跟著走就對了
4. **看不出該用哪個指令時 → `/status`**(它會告訴你建議)
5. **CONSTITUTION 改了會牽動全部** — 沒事不要動,要動就認真審
6. **AGENTS.md 只能你寫,agent 不能寫** — 把每次踩坑的教訓記在那裡

---

## 🎯 80% 場景只會用到 5 個

實務上 maintenance 階段最常用:

```
1. /status          ← 沒事就看一下現在哪裡
2. /feature <描述>   ← 加功能
3. /fix <描述>       ← 修 bug
4. /git-pr           ← 推 PR
5. /resume           ← blocked 修好繼續
```

剩下 10 個是「特殊情況才用」的。

---

## 📚 重要檔案位置

| 檔案 | 用途 |
|---|---|
| `discussion/notes.md` | 需求討論累積 |
| `specs/CONSTITUTION.md` | 專案憲法(不可違反鐵則) |
| `specs/00-stack.md` ~ `60-devops.md` | 9 份 specs |
| `specs/REVIEW.md` | spec 審查結果 |
| `state/manifest.json` | task 進度真相 |
| `state/runlog/<時間戳>.md` | 每次 /implement 紀錄 |
| `state/code-review.md` | /review-code 結果 |
| `state/activity/<日期>.log` | 每天 file 修改記錄(hook 自動寫) |
| `CLAUDE.md`(專案根) | 專案說明,自動載入每個 session |
| `AGENTS.md`(專案根) | **人工累積**踩坑 + ADR 索引 |
| `docs/adr/NNNN-*.md` | Architectural Decision Records |

---

## 🆘 緊急救援

| 症狀 | 解法 |
|---|---|
| `/implement` 跑到一半當機,manifest 有 `running` task 卡住 | 手動編輯 `state/manifest.json` 把該 task 改回 `pending` 或 `done` |
| 不小心 push 了 .env | `git rm --cached .env` + 確認 .gitignore + push 新 commit + **去 GitHub 撤銷該 secret** |
| Claude 一直擋我說 entry checklist 沒過 | 跑 `/status` 看缺什麼,或在指令後加 `--force`(部分指令支援) |
| 想完全砍掉重做 | 刪除 `specs/`、`state/`、`CLAUDE.md`、`AGENTS.md`,從 `/discuss-project` 重來(`.claude/` 設定保留) |
| 不確定該用哪個指令 | 用 `/status`,它會告訴你建議下一步 |
