---
description: Read discussion notes and stack decisions, then generate TOGAF architecture documents based on selected mode. Outputs to togaf/ directory.
---

根據需求討論與技術棧決策，產出 TOGAF 架構文件。與 Leo 的對話用**繁體中文**，文件內容用英文。

## Entry checklist

- [ ] `discussion/notes.md` 存在且有內容
- [ ] `specs/00-stack.md` 存在
- [ ] `specs/CONSTITUTION.md` 存在

如果缺少，停下來告訴 Leo 先跑哪個指令。

## Steps

### Step 1 — 選擇模式

詢問 Leo：

```
TOGAF 文件有三種模式，請選擇：

1. 輕量模式 — Phase A+B，適合 MVP 或快速驗證（約 30 分鐘）
2. 標準模式 — Phase A-E，適合一般商業專案（約 1-2 小時）
3. 企業模式 — Phase A-H 完整文件，適合大型/企業專案（約半天）

請問要用哪個模式？
```

等待 Leo 回覆。

### Step 2 — 讀取輸入

讀取以下檔案作為輸入：
- `discussion/notes.md` — 需求討論內容
- `specs/00-stack.md` — 技術棧決策
- `specs/CONSTITUTION.md` — 架構原則

### Step 3 — 建立目錄

```
togaf/
├── requirements.md
├── phase-a.md
├── phase-b.md
├── phase-c.md  (標準/企業模式)
├── phase-d.md  (標準/企業模式)
├── phase-e.md  (標準/企業模式)
├── phase-f.md  (企業模式)
├── phase-g.md  (企業模式)
└── phase-h.md  (企業模式)
```

### Step 4 — 依模式產出文件

使用 `.claude/togaf/templates/` 裡的模板，根據討論內容填入：

**所有模式都要產出：**

**Requirements.md**
- 從 `discussion/notes.md` 提取功能需求（FR）
- 從 `specs/CONSTITUTION.md` 提取非功能需求（NFR）
- 識別約束條件

**Phase A（架構願景）**
- 問題陳述：從討論筆記提取
- 架構願景：從需求提取
- 利害關係人：從討論提取
- 範圍：In scope / Out of scope
- 架構原則：從 CONSTITUTION 提取
- 成功標準：從討論提取

**Phase B（業務架構）**
- 業務能力：從功能需求推導
- 核心業務流程：逐一描述
- 用戶角色：從討論提取
- 業務規則：從需求提取

**標準/企業模式額外產出：**

**Phase C（資訊系統架構）**
- 核心實體：從需求推導
- ERD 概覽
- 應用元件：從技術棧推導
- 系統架構圖

**Phase D（技術架構）**
- 技術棧（直接從 specs/00-stack.md 提取）
- 基礎設施架構
- 安全架構
- 可觀測性計劃

**Phase E（機會與解決方案）**
- 工作包定義（對應後續的 manifest tasks）
- 實施策略
- 依賴關係

**企業模式額外產出：**

**Phase F（遷移計劃）**
- 實施路線圖（週次）
- 上線計劃

**Phase G（實施治理）**
- 架構合規檢查清單
- 變更控制流程

**Phase H（架構變更管理）**
- 變更觸發條件
- 技術債務追蹤

### Step 5 — 更新 CLAUDE.md 流程說明

在專案根目錄的 CLAUDE.md 加入 togaf/ 目錄說明：

```markdown
| `togaf/` | TOGAF 架構文件，/generate-specs 的輸入依據 |
```

### Step 6 — 更新 generate-specs 輸入

告知 Leo：
```
TOGAF 文件產出完成！generate-specs 現在會以 togaf/ 作為額外輸入依據。
```

### Step 7 — 產出摘要

```
✅ TOGAF 文件產出完成 (<模式>模式):
- togaf/requirements.md — <N> 個 FR, <M> 個 NFR
- togaf/phase-a.md — 架構願景
- togaf/phase-b.md — 業務架構
(依模式列出)

下一步: /generate-specs 產出技術 specs。
```

並更新 STATUS.md：
```
PHASE: TOGAF
STATUS: WAITING_USER
MESSAGE: TOGAF 文件產出完成，請確認後繼續 /generate-specs
```

## Exit checklist

- [ ] 選擇的模式對應的所有 Phase 文件都已產出
- [ ] requirements.md 包含 FR + NFR
- [ ] 所有文件從討論內容推導，沒有捏造資訊
- [ ] STATUS.md 已更新

## Three-tier rules

### Always do
- 從 discussion/notes.md 推導，不要自己發明需求
- 每個 Phase 文件用對應模板填入，保留未知欄位為 TODO
- 產出後告訴 Leo 哪些欄位需要他補充

### Ask first
- 需求不明確時，停下來問 Leo，不要猜

### Never do
- 跳過 Phase A 和 Phase B
- 捏造技術細節
- 在沒有討論筆記的情況下產出文件
