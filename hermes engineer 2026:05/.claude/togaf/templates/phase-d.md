# Phase D — Technology Architecture

> 目的：定義支撐應用與資料架構所需的技術基礎設施。

---

## 1. 技術棧總覽 (Technology Stack)

| 層次 | 技術選擇 | 版本 | 理由 |
|---|---|---|---|
| 前端框架 | <!-- e.g. Next.js --> | <!-- 15.x --> | <!-- --> |
| 後端框架 | <!-- e.g. FastAPI --> | <!-- 0.115.x --> | <!-- --> |
| 資料庫 | <!-- e.g. PostgreSQL --> | <!-- 16.x --> | <!-- --> |
| 快取 | <!-- e.g. Redis --> | <!-- 7.x --> | <!-- --> |
| 認證 | <!-- e.g. JWT + OAuth2 --> | <!-- --> | <!-- --> |
| 容器化 | <!-- e.g. Docker --> | <!-- 26.x --> | <!-- --> |
| 編排 | <!-- e.g. Kubernetes / Docker Compose --> | <!-- --> | <!-- --> |
| CI/CD | <!-- e.g. GitHub Actions --> | <!-- --> | <!-- --> |
| 雲端平台 | <!-- e.g. AWS / GCP / Azure --> | <!-- --> | <!-- --> |
| 監控 | <!-- e.g. Datadog / Grafana --> | <!-- --> | <!-- --> |

---

## 2. 基礎設施架構 (Infrastructure Architecture)

### 2.1 環境定義

| 環境 | 用途 | 規格 | 部署頻率 |
|---|---|---|---|
| Development | 本地開發 | 本機 Docker | 隨時 |
| Staging | 測試/QA | <!-- e.g. 1x t3.medium --> | 每次 PR merge |
| Production | 正式上線 | <!-- e.g. 2x t3.large --> | 每次 release |

### 2.2 網路架構

```
Internet
    │
[CloudFlare / CDN]
    │
[Load Balancer]
    │
    ├── [App Server 1]
    ├── [App Server 2]
    │
    └── [Private Subnet]
            ├── [Database Primary]
            ├── [Database Replica]
            └── [Redis Cluster]
```

### 2.3 部署架構

| 服務 | 部署方式 | 擴展策略 | 最小實例 | 最大實例 |
|---|---|---|---|---|
| <!-- Web App --> | <!-- Container --> | <!-- HPA CPU > 70% --> | 1 | 5 |
| <!-- API Server --> | <!-- Container --> | <!-- HPA RPS --> | 2 | 10 |
| <!-- Database --> | <!-- Managed RDS --> | <!-- 垂直擴展 --> | 1 | 1 |

---

## 3. 安全架構 (Security Architecture)

### 3.1 安全控制矩陣

| 層次 | 威脅 | 控制措施 |
|---|---|---|
| 網路 | DDoS | CloudFlare WAF、Rate Limiting |
| 應用 | XSS/CSRF | CSP Headers、CSRF Token |
| 應用 | SQL Injection | ORM Parameterized Query |
| 資料 | 資料外洩 | 欄位加密、TLS in transit |
| 認證 | 未授權存取 | JWT + Refresh Token、MFA |

### 3.2 Secrets 管理

| Secret 類型 | 儲存位置 | 輪換週期 |
|---|---|---|
| DB 密碼 | <!-- e.g. AWS Secrets Manager --> | 90 天 |
| API Keys | <!-- e.g. 環境變數 / Vault --> | 依供應商 |
| JWT Secret | <!-- e.g. AWS Secrets Manager --> | 180 天 |

---

## 4. 可觀測性 (Observability)

| 類型 | 工具 | 保留期 | 告警條件 |
|---|---|---|---|
| Logs | <!-- e.g. CloudWatch --> | 30 天 | Error rate > 1% |
| Metrics | <!-- e.g. Datadog --> | 13 個月 | CPU > 80% |
| Traces | <!-- e.g. Jaeger --> | 7 天 | P99 > 500ms |
| Uptime | <!-- e.g. Pingdom --> | 永久 | Downtime > 1min |

---

## 5. 災難復原 (Disaster Recovery)

| 指標 | 目標值 |
|---|---|
| RTO (Recovery Time Objective) | <!-- e.g. < 1 小時 --> |
| RPO (Recovery Point Objective) | <!-- e.g. < 15 分鐘 --> |
| 備份頻率 | <!-- e.g. 每日全量 + 每小時增量 --> |
| 備份保留 | <!-- e.g. 30 天 --> |
| 復原測試頻率 | <!-- e.g. 每季一次 --> |

---

## 6. 技術債務與限制

| 項目 | 描述 | 影響 | 計劃解決時間 |
|---|---|---|---|
| <!-- --> | <!-- --> | 高/中/低 | <!-- --> |

---

## 7. 技術架構結論

> 總結關鍵技術決策，對 Phase E（機會與解決方案）的影響。

<!-- 填入結論 -->
