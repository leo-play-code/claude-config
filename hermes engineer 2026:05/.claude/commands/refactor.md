---
description: Refactor an existing project. Auto-runs reverse-togaf if no TOGAF docs exist. Supports full or partial refactor (frontend/backend/all).
---

重構現有專案。與 Leo 的對話用**繁體中文**，文件內容用英文。

## Entry checklist

- [ ] 專案目錄有程式碼
- [ ] git 已初始化（重構前要有 snapshot）

## Steps

### Step 0 — 確認 Git Remote

檢查現有 remote：
```bash
git remote -v
```

詢問 Leo：
```
目前 remote origin 指向：<URL>

重構完成後要：
1. Push 到現有 repo（<URL>）開 PR（推薦）
2. 建立全新的 private repo
```

等待 Leo 選擇後繼續。


### Step 1 — 檢查 TOGAF 文件

```bash
ls togaf/ 2>/dev/null || echo "NO_TOGAF"
```

- **有 togaf/** → 跳到 Step 3
- **沒有 togaf/** → 執行 Step 2

### Step 2 — 逆向工程（無 TOGAF 時）

自動執行 `/reverse-togaf`，產出 SRS + TOGAF 後繼續。

### Step 3 — 選擇重構模式

詢問 Leo：
```
重構模式：

1. 快速模式 — 只改最關鍵問題，最小改動
2. 標準模式 — 完整重構指定範圍
3. 企業模式 — 完整重構 + 更新所有 TOGAF 文件 + ADR 記錄每個決策
```
等待 Leo 回覆。

### Step 4 — 確認重構範圍

詢問 Leo：
準備開始重構。請選擇範圍：

前端重構 — 只動 frontend 相關程式碼
後端重構 — 只動 backend/API 相關程式碼
資料庫重構 — 只動 schema/migration
全面重構 — 前端 + 後端 + 資料庫全部重做
指定範圍 — 我自己說

目前發現的主要問題：
<列出 srs.md 差距分析的重構建議>
等待 Leo 回覆。

### Step 4 — 建立重構 branch

```bash
git add -A
git commit -m "chore: pre-refactor snapshot"
git checkout -b refactor/$(date +%Y%m%d)
```

### Step 5 — 產出新 specs

根據重構範圍，只產出需要的 specs：

| 範圍 | 產出的 specs |
|---|---|
| 前端 | specs/40-frontend.md（重新產出） |
| 後端 | specs/20-api.md + specs/30-backend.md |
| 資料庫 | specs/10-database.md |
| 全面 | 全部 9 份 specs |

每份 spec 標記：
- `[KEEP]` — 保留現有實作
- `[REFACTOR]` — 需要重構
- `[NEW]` — 新增功能

### Step 6 — 自動進入審查

產出 specs 後自動執行 `/review-specs`。

### Step 7 — 實施重構

審查通過後自動執行 `/implement`，只處理標記 `[REFACTOR]` 和 `[NEW]` 的 tasks。

### Step 8 — 更新 STATUS.md
PHASE: REFACTOR
STATUS: RUNNING
MESSAGE: 重構進行中
## Three-tier rules

### Always do
- 重構前先 git commit snapshot
- 在 branch 上重構，不動 main
- 只動指定範圍的程式碼

### Ask first
- 重構範圍不確定 → 問 Leo
- 發現預期外的問題 → 停下來報告

### Never do
- 在 main branch 直接重構
- 刪除現有程式碼前沒有 git backup
- 擴大 scope 超過 Leo 指定的範圍
