# Phase G — Implementation Governance

> 目的：確保實施符合架構規範，建立治理機制。

---

## 1. 架構合規檢查 (Architecture Compliance)

| 檢查項目 | 標準來源 | 檢查方式 | 頻率 |
|---|---|---|---|
| Code style | CONSTITUTION.md | CI lint check | 每次 PR |
| API 契約 | specs/20-api.md | Contract test | 每次 PR |
| DB schema | specs/10-database.md | Migration review | 每次 schema 變更 |
| 安全規範 | CONSTITUTION.md | Security scan | 每次 PR |
| 測試覆蓋率 | specs/50-tests.md | Coverage report | 每次 PR |

---

## 2. 架構決策記錄 (ADR Log)

| ADR-ID | 決策 | 日期 | 狀態 |
|---|---|---|---|
| ADR-001 | <!-- e.g. 使用 PostgreSQL 而非 MySQL --> | <!-- --> | 已採納 |
| ADR-002 | <!-- --> | <!-- --> | <!-- --> |

---

## 3. 變更控制 (Change Control)

| 變更類型 | 審批流程 | 審批人 |
|---|---|---|
| 小型變更（Bug fix） | PR Review | 任一 reviewer |
| 中型變更（新功能） | PR Review + Tech Lead 確認 | Tech Lead |
| 大型變更（架構調整） | ADR 撰寫 + 團隊討論 | 全團隊 |
| 緊急修復 | 事後補 PR + ADR | Tech Lead |

---

## 4. 品質關卡 (Quality Gates)

| 關卡 | 條件 | 不通過時 |
|---|---|---|
| PR Merge | 所有 CI 通過、至少 1 個 review | 禁止 merge |
| Staging 部署 | E2E 測試通過 | 阻止部署 |
| Production 部署 | Staging 驗證 + Tech Lead 核准 | 阻止部署 |
