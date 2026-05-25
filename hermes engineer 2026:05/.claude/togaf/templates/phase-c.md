# Phase C — Information Systems Architecture

> 目的：定義資料架構與應用架構，說明系統如何儲存、處理與呈現資訊。

---

## Part 1: 資料架構 (Data Architecture)

### 1.1 核心實體 (Core Entities)

| 實體 | 說明 | 關鍵屬性 |
|---|---|---|
| <!-- e.g. User --> | <!-- 系統用戶 --> | <!-- id, email, role --> |
| <!-- e.g. Order --> | <!-- 訂單 --> | <!-- id, user_id, status, total --> |
| <!-- --> | <!-- --> | <!-- --> |

### 1.2 實體關係圖 (ERD Overview)

```
User ──(1:N)──> Order ──(1:N)──> OrderItem
                                      │
                                   (N:1)
                                      ▼
                                   Product
```

### 1.3 資料流 (Data Flow)

| 資料 | 來源 | 目的地 | 格式 | 頻率 |
|---|---|---|---|---|
| <!-- e.g. 用戶輸入 --> | <!-- 前端 --> | <!-- API --> | JSON | 即時 |
| <!-- e.g. 交易記錄 --> | <!-- API --> | <!-- DB --> | SQL | 即時 |

### 1.4 資料治理 (Data Governance)

| 項目 | 規範 |
|---|---|
| 敏感資料分類 | <!-- PII: email, phone; Financial: card_number --> |
| 資料保留政策 | <!-- e.g. 用戶資料保留 7 年 --> |
| 加密要求 | <!-- e.g. PII 欄位 AES-256 加密 --> |
| 存取控制 | <!-- e.g. RBAC，依角色限制 --> |
| 備份策略 | <!-- e.g. 每日全量備份，保留 30 天 --> |

---

## Part 2: 應用架構 (Application Architecture)

### 2.1 應用元件 (Application Components)

| 元件 | 類型 | 職責 | 技術 |
|---|---|---|---|
| <!-- e.g. Web App --> | 前端 | <!-- 用戶介面 --> | <!-- Next.js --> |
| <!-- e.g. API Server --> | 後端 | <!-- 業務邏輯 --> | <!-- FastAPI --> |
| <!-- e.g. Auth Service --> | 服務 | <!-- 認證授權 --> | <!-- JWT --> |
| <!-- e.g. Database --> | 儲存 | <!-- 資料持久化 --> | <!-- PostgreSQL --> |
| <!-- e.g. Cache --> | 儲存 | <!-- 快取 --> | <!-- Redis --> |

### 2.2 系統架構圖

```
[用戶瀏覽器]
     │ HTTPS
     ▼
[CDN / Load Balancer]
     │
     ▼
[Web App (Next.js)]  ──API calls──>  [API Server (FastAPI)]
                                              │
                              ┌───────────────┼───────────────┐
                              ▼               ▼               ▼
                        [PostgreSQL]       [Redis]      [外部服務]
```

### 2.3 API 邊界 (API Boundaries)

| API | 提供者 | 消費者 | 協議 | 認證方式 |
|---|---|---|---|---|
| <!-- e.g. REST API --> | <!-- API Server --> | <!-- Web App --> | HTTPS/JSON | JWT |
| <!-- e.g. Webhook --> | <!-- 外部支付 --> | <!-- API Server --> | HTTPS | HMAC |

### 2.4 整合點 (Integration Points)

| 外部系統 | 整合方式 | 資料方向 | 重要性 |
|---|---|---|---|
| <!-- e.g. Stripe --> | REST API | 雙向 | 關鍵 |
| <!-- e.g. SendGrid --> | REST API | 單向（推送） | 重要 |
| <!-- e.g. S3 --> | SDK | 雙向 | 重要 |

---

## 3. 差距分析 (Gap Analysis)

| 能力 | 現狀 | 目標 | 需要的工作 |
|---|---|---|---|
| <!-- --> | <!-- --> | <!-- --> | <!-- --> |

---

## 4. 資訊系統架構結論

> 總結關鍵決策，對 Phase D（技術架構）的影響。

<!-- 填入結論 -->
