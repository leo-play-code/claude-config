# Requirements Management

> 貫穿所有 Phase 的需求管理文件。

---

## 1. 功能需求 (Functional Requirements)

| FR-ID | 需求描述 | 優先級 | 來源 | 對應 Phase |
|---|---|---|---|---|
| FR-001 | <!-- e.g. 用戶可以用 email 註冊 --> | Must Have | 業務需求 | Phase B/C |
| FR-002 | <!-- --> | Should Have | <!-- --> | <!-- --> |
| FR-003 | <!-- --> | Nice to Have | <!-- --> | <!-- --> |

---

## 2. 非功能需求 (Non-Functional Requirements)

| NFR-ID | 類型 | 需求描述 | 衡量標準 | 對應 Phase |
|---|---|---|---|---|
| NFR-001 | 效能 | API 回應時間 | P95 < 200ms | Phase D |
| NFR-002 | 可用性 | 系統可用性 | 99.9% uptime | Phase D |
| NFR-003 | 安全性 | 資料加密 | TLS 1.3+ | Phase D |
| NFR-004 | 擴展性 | 並發用戶數 | <!-- 支援 1000 並發 --> | Phase D |
| NFR-005 | 維護性 | 測試覆蓋率 | > 80% | Phase G |

---

## 3. 約束條件 (Constraints)

| 類型 | 描述 | 來源 |
|---|---|---|
| 技術 | <!-- e.g. 必須使用公司現有 AWS 帳號 --> | 業務決策 |
| 時間 | <!-- e.g. 3 個月內上線 --> | 業務需求 |
| 預算 | <!-- e.g. 每月雲端費用 < $500 --> | 財務限制 |
| 法規 | <!-- e.g. GDPR 合規 --> | 法律要求 |

---

## 4. 需求追溯矩陣 (Traceability Matrix)

| FR/NFR ID | 對應 TOGAF Phase | 對應 Spec 檔案 | 對應 Task ID | 實作狀態 |
|---|---|---|---|---|
| FR-001 | Phase B, C | specs/30-backend.md | task-005 | ⬜ 未開始 |
| NFR-001 | Phase D | specs/60-devops.md | task-012 | ⬜ 未開始 |

---

## 5. 需求變更記錄

| 日期 | 需求 ID | 變更描述 | 影響評估 | 核准人 |
|---|---|---|---|---|
| <!-- --> | <!-- --> | <!-- --> | <!-- --> | <!-- --> |
