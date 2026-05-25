---
description: Reverse engineer existing codebase to produce SRS and TOGAF architecture documents. Used before refactoring a project that has no TOGAF docs.
---

逆向工程現有程式碼，產出 SRS 和 TOGAF 文件。與 Leo 的對話用**繁體中文**，文件內容用英文。

## Entry checklist

- [ ] 專案目錄有程式碼（src/ 或相關目錄存在）
- [ ] 如果有 README.md，先讀它

如果沒有程式碼，停下來告訴 Leo。

## Steps

### Step 1 — 掃描現有程式碼結構

```bash
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) \
  | grep -v node_modules | grep -v .git | head -50
```

掃描：
- 目錄結構（前端/後端/資料庫）
- package.json / requirements.txt（依賴推導技術棧）
- 資料庫 schema（migration 檔案）
- API routes
- 環境變數（.env.example）

### Step 2 — 產出 SRS

使用模板 `.claude/togaf/templates/srs.md`，從程式碼推導填入：

- 功能需求：從 routes、components、API endpoints 推導
- 非功能需求：從現有設定推導
- 差距分析：現狀 vs 理想狀態
- 重構建議：根據差距分析

儲存到 `srs.md`（專案根目錄）。

### Step 3 — 從 SRS 產出 TOGAF

根據 SRS 內容，選擇模式：

詢問 Leo：
已完成逆向工程，產出 srs.md。
根據現有程式碼規模，建議：

輕量模式（Phase A+B）— 適合小型專案
標準模式（Phase A-E）— 適合中型專案

你要用哪個模式產出 TOGAF？
等待 Leo 回覆，然後使用 `.claude/togaf/templates/` 模板產出對應 Phase 文件到 `togaf/` 目錄。

### Step 4 — 差距摘要

告訴 Leo：
✅ 逆向工程完成：

srs.md — 現有系統需求文件
togaf/phase-a.md — 架構願景
togaf/phase-b.md — 業務架構
(依模式列出)

發現以下差距需要重構：

<差距 1>
<差距 2>

下一步：/refactor 開始規劃重構。
### Step 5 — 更新 STATUS.md
PHASE: REVERSE-TOGAF
STATUS: WAITING_USER
MESSAGE: 逆向工程完成，請確認 SRS 和 TOGAF 文件後繼續 /refactor

## Three-tier rules

### Always do
- 從程式碼推導，不要憑空發明
- 標記不確定的部分為 TODO
- 差距分析要誠實，不美化現狀

### Ask first
- 看不懂某段程式碼的用途 → 問 Leo

### Never do
- 修改現有程式碼
- 捏造不存在的功能
