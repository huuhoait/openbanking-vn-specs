# Đối Soát & Tra Soát (Reconciliation & Dispute Management)

> **Tuân thủ:** Thông tư 64/2024/TT-NHNN | ISO 20022 | PCI DSS 4.0

## Tổng Quan

Hệ thống đối soát và tra soát đảm bảo tính chính xác, minh bạch của dữ liệu giao dịch giữa TPP và Ngân hàng, hỗ trợ giải quyết tranh chấp và compliance.

### Mục Tiêu

1. **Đối soát tự động**: So khớp giao dịch giữa TPP và Bank
2. **Báo cáo nhanh**: Báo cáo hàng ngày, hàng tháng
3. **Phát hiện lỗi**: Tự động phát hiện giao dịch sai lệch
4. **Giải quyết tranh chấp**: Quy trình tra soát rõ ràng
5. **Audit trail**: Lưu vết đầy đủ cho kiểm toán

## Kiến Trúc Hệ Thống

```mermaid
graph TB
    subgraph "TPP Systems"
        TPP_Portal[TPP Portal]
        TPP_DB[(TPP Transaction DB)]
    end
    
    subgraph "Reconciliation API"
        RecAPI[Reconciliation API<br/>RESTful + Batch]
        Matcher[Auto Matching Engine<br/>ML-based]
        Reporter[Report Generator<br/>PDF + Excel]
    end
    
    subgraph "Dispute Management"
        Dispute[Dispute Service]
        Workflow[Workflow Engine]
        SLA[SLA Monitor]
    end
    
    subgraph "Bank Systems"
        Bank_DB[(Bank Transaction DB)]
        Core[Core Banking]
        Admin[Admin Portal]
    end
    
    subgraph "File Exchange"
        SFTP[SFTP Server<br/>Secure File Transfer]
        S3[Cloud Storage<br/>S3/MinIO]
    end
    
    subgraph "Notification"
        Email[Email Service]
        Webhook[Webhook Service]
        SMS[SMS Gateway]
    end
    
    TPP_Portal --> RecAPI
    TPP_DB -.->|Upload CSV/Excel| SFTP
    
    RecAPI --> Matcher
    RecAPI --> Dispute
    
    Matcher --> Bank_DB
    Matcher --> Reporter
    
    Reporter --> SFTP
    Reporter --> S3
    Reporter --> Email
    
    Dispute --> Workflow
    Dispute --> SLA
    Dispute --> Admin
    
    Workflow --> Email
    Workflow --> Webhook
    Workflow --> SMS
    
    Bank_DB --> Core
    
    style Matcher fill:#4caf50,stroke:#2e7d32,color:#fff
    style Dispute fill:#ff9800,stroke:#e65100
    style SLA fill:#f44336,stroke:#c62828,color:#fff
```

## API Endpoints

### 1. Upload Reconciliation File

#### POST /v1/reconciliation/upload

TPP upload file giao dịch để đối soát.

```mermaid
sequenceDiagram
    participant TPP
    participant API as Recon API
    participant Validator
    participant Storage as File Storage
    participant Queue as Message Queue
    
    TPP->>API: POST /reconciliation/upload<br/>+ CSV/Excel File
    API->>Validator: Validate File Format
    
    alt Invalid Format
        Validator-->>API: Invalid Format
        API-->>TPP: 400: Bad Request<br/>Error Details
    else Valid Format
        Validator-->>API: Valid
        API->>Storage: Store Original File
        Storage-->>API: File ID
        
        API->>Queue: Enqueue Processing Job
        Queue-->>API: Job ID
        
        API-->>TPP: 202 Accepted<br/>ReconciliationId + Status URL
        
        Note over Queue: Background Processing
        Queue->>Queue: Parse File
        Queue->>Queue: Match Transactions
        Queue->>Queue: Generate Report
        Queue->>Webhook: Notify TPP (Complete)
    end
```

**Request:**
```http
POST /v1/reconciliation/upload
Content-Type: multipart/form-data

file: transactions.csv
reconciliationDate: 2025-12-14
```

**Response:**
```json
{
  "ReconciliationId": "recon-20251214-001",
  "Status": "Processing",
  "UploadedAt": "2025-12-15T10:00:00+07:00",
  "RecordCount": 1250,
  "StatusUrl": "/v1/reconciliation/recon-20251214-001/status",
  "EstimatedCompletionTime": "2025-12-15T10:15:00+07:00"
}
```

### 2. Get Reconciliation Status

#### GET /v1/reconciliation/{ReconciliationId}/status

Kiểm tra trạng thái đối soát.

```mermaid
stateDiagram-v2
    [*] --> Uploaded: File Uploaded
    Uploaded --> Validating: Start Validation
    Validating --> Processing: Valid
    Validating --> Failed: Invalid
    
    Processing --> Matching: Parse Complete
    Matching --> Completed: All Matched
    Matching --> PartialMatch: Some Mismatches
    
    PartialMatch --> UnderReview: Manual Review
    UnderReview --> Resolved: Disputes Resolved
    
    Failed --> [*]
    Completed --> [*]
    Resolved --> [*]
```

**Response:**
```json
{
  "ReconciliationId": "recon-20251214-001",
  "Status": "Completed",
  "Summary": {
    "TotalRecords": 1250,
    "Matched": 1245,
    "Unmatched": 5,
    "Amount": {
      "Total": "5250000000",
      "Matched": "5248500000",
      "Variance": "1500000",
      "Currency": "VND"
    }
  },
  "ProcessedAt": "2025-12-15T10:12:35+07:00",
  "ReportUrl": "/v1/reconciliation/recon-20251214-001/report",
  "MismatchDetailsUrl": "/v1/reconciliation/recon-20251214-001/mismatches"
}
```

### 3. Get Reconciliation Report

#### GET /v1/reconciliation/{ReconciliationId}/report

Tải báo cáo đối soát chi tiết.

**Response Formats:**
- `application/json` - JSON data
- `application/pdf` - PDF report
- `application/vnd.ms-excel` - Excel file
- `text/csv` - CSV file

**JSON Response Example:**
```json
{
  "ReconciliationId": "recon-20251214-001",
  "ReconciliationDate": "2025-12-14",
  "GeneratedAt": "2025-12-15T10:12:35+07:00",
  "TPP": {
    "TPPId": "tpp-12345",
    "TPPName": "FinTech Solutions Ltd"
  },
  "Summary": {
    "TotalTransactions": 1250,
    "MatchedTransactions": 1245,
    "UnmatchedTransactions": 5,
    "TotalAmount": "5250000000 VND",
    "MatchedAmount": "5248500000 VND",
    "VarianceAmount": "1500000 VND",
    "VariancePercentage": 0.03
  },
  "MatchBreakdown": {
    "PerfectMatch": 1200,
    "FuzzyMatch": 45,
    "NoMatch": 5
  },
  "Mismatches": [
    {
      "TransactionId": "txn-001",
      "TPPAmount": "500000",
      "BankAmount": "500000",
      "TPPDate": "2025-12-14T14:30:00",
      "BankDate": "2025-12-14T14:31:00",
      "Issue": "Timestamp Mismatch",
      "Severity": "Low"
    }
  ]
}
```

### 4. Create Dispute

#### POST /v1/disputes

Tạo yêu cầu tra soát cho giao dịch có vấn đề.

```mermaid
sequenceDiagram
    participant TPP
    participant API as Dispute API
    participant Workflow
    participant Investigator as Bank Investigator
    participant Core as Core Banking
    participant Notification
    
    TPP->>API: POST /disputes<br/>Transaction Details + Reason
    API->>API: Validate Request
    API->>Workflow: Create Dispute Case
    Workflow->>Workflow: Assign Case Number<br/>Set SLA (3 days)
    
    Workflow->>Investigator: Notify via Email
    Workflow->>Notification: Send to TPP<br/>Case Created
    Notification-->>TPP: Email: Case #12345 Created
    
    Investigator->>Core: Investigate Transaction
    Core-->>Investigator: Transaction Details
    
    Investigator->>Workflow: Update Status<br/>Add Comments
    Workflow->>Notification: Notify TPP<br/>Status Update
    
    alt Resolved - TPP Correct
        Investigator->>Workflow: Resolve: TPP Correct<br/>Bank will adjust
        Workflow->>Core: Create Adjustment
        Workflow->>Notification: Notify TPP<br/>Resolved in favor
    else Resolved - Bank Correct
        Investigator->>Workflow: Resolve: Bank Correct<br/>No adjustment needed
        Workflow->>Notification: Notify TPP<br/>Evidence provided
    else Escalated
        Investigator->>Workflow: Escalate to Manager
        Workflow->>Notification: Notify TPP<br/>Escalated
    end
```

**Request:**
```json
{
  "TransactionId": "txn-12345",
  "DisputeType": "AmountMismatch",
  "Description": "Transaction amount in our system is 500,000 VND but bank record shows 450,000 VND",
  "ExpectedAmount": {
    "Amount": "500000",
    "Currency": "VND"
  },
  "ActualAmount": {
    "Amount": "450000",
    "Currency": "VND"
  },
  "Evidence": [
    {
      "Type": "Screenshot",
      "Url": "https://storage.com/evidence1.png"
    },
    {
      "Type": "Receipt",
      "Url": "https://storage.com/receipt.pdf"
    }
  ],
  "ContactPerson": {
    "Name": "Nguyen Van A",
    "Email": "nguyenvana@fintech.com",
    "Phone": "+84901234567"
  }
}
```

**Response:**
```json
{
  "DisputeId": "dispute-12345",
  "Status": "Open",
  "Priority": "Normal",
  "SLA": {
    "ResolutionDeadline": "2025-12-18T17:00:00+07:00",
    "BusinessDaysRemaining": 3
  },
  "AssignedTo": "Bank Investigation Team",
  "CreatedAt": "2025-12-15T10:30:00+07:00",
  "TrackingUrl": "/v1/disputes/dispute-12345"
}
```

### 5. Get Dispute Status

#### GET /v1/disputes/{DisputeId}

Theo dõi tiến độ giải quyết tranh chấp.

```mermaid
stateDiagram-v2
    [*] --> Open: Dispute Created
    Open --> UnderInvestigation: Assigned
    
    UnderInvestigation --> PendingEvidence: Need More Info
    PendingEvidence --> UnderInvestigation: Evidence Provided
    
    UnderInvestigation --> Escalated: Complex Case
    Escalated --> UnderInvestigation: Assigned to Senior
    
    UnderInvestigation --> Resolved: Investigation Complete
    
    Resolved --> Closed: Both Parties Agree
    Resolved --> Reopened: TPP Objects
    
    Reopened --> UnderInvestigation
    
    Closed --> [*]
    
    note right of Resolved
        Resolution Types:
        - TPP Correct
        - Bank Correct
        - Partial Adjustment
        - Mutual Agreement
    end note
```

**Response:**
```json
{
  "DisputeId": "dispute-12345",
  "Status": "UnderInvestigation",
  "TransactionId": "txn-12345",
  "DisputeType": "AmountMismatch",
  "Priority": "Normal",
  "Timeline": [
    {
      "Status": "Open",
      "Timestamp": "2025-12-15T10:30:00+07:00",
      "Actor": "TPP User",
      "Comment": "Dispute created"
    },
    {
      "Status": "UnderInvestigation",
      "Timestamp": "2025-12-15T11:00:00+07:00",
      "Actor": "Bank Investigator",
      "Comment": "Case assigned to John Doe"
    },
    {
      "Status": "UnderInvestigation",
      "Timestamp": "2025-12-15T14:30:00+07:00",
      "Actor": "Bank Investigator",
      "Comment": "Transaction logs reviewed. Discrepancy confirmed."
    }
  ],
  "SLA": {
    "ResolutionDeadline": "2025-12-18T17:00:00+07:00",
    "ElapsedHours": 4,
    "RemainingHours": 68,
    "Status": "OnTrack"
  },
  "Resolution": null,
  "UpdatedAt": "2025-12-15T14:30:00+07:00"
}
```

## Matching Algorithm

### Auto-Matching Rules

```mermaid
graph TB
    Input[TPP Transaction vs Bank Transaction]
    
    Input --> Rule1{Exact Match?<br/>ID + Amount + Date}
    Rule1 -->|Yes| Match1[Perfect Match<br/>100% Confidence]
    Rule1 -->|No| Rule2{Fuzzy Match?<br/>ID + Amount<br/>Date ±2 min}
    
    Rule2 -->|Yes| Match2[Fuzzy Match<br/>95% Confidence]
    Rule2 -->|No| Rule3{Amount Match?<br/>Same Amount<br/>Date ±1 hour}
    
    Rule3 -->|Yes| Match3[Possible Match<br/>70% Confidence<br/>Manual Review]
    Rule3 -->|No| NoMatch[No Match<br/>0% Confidence<br/>Requires Investigation]
    
    Match1 --> Auto[Auto Reconciled]
    Match2 --> Auto
    Match3 --> Manual[Manual Review Queue]
    NoMatch --> Manual
    
    style Match1 fill:#4caf50,color:#fff
    style Match2 fill:#8bc34a
    style Match3 fill:#ffc107
    style NoMatch fill:#f44336,color:#fff
```

**Matching Criteria:**

| Match Type | ID | Amount | Timestamp | Confidence | Action |
|------------|-----|--------|-----------|------------|--------|
| **Perfect** | Exact | Exact | ±10s | 100% | Auto reconcile |
| **Fuzzy** | Exact | Exact | ±2min | 95% | Auto reconcile |
| **Possible** | Exact | Exact | ±1hr | 70% | Manual review |
| **Amount Only** | Different | Exact | ±1hr | 50% | Manual review |
| **No Match** | - | - | - | 0% | Investigation |

## Reporting

### Daily Reconciliation Report

```mermaid
gantt
    title Daily Reconciliation Timeline
    dateFormat HH:mm
    axisFormat %H:%M
    
    section Data Collection
    TPP Upload Files :done, upload, 00:00, 1h
    Bank Extract Transactions :done, extract, 01:00, 1h
    
    section Processing
    Auto Matching :active, match, 02:00, 2h
    Manual Review :crit, review, 04:00, 3h
    
    section Reporting
    Generate Reports :report, 07:00, 1h
    Distribute Reports :distribute, 08:00, 30m
    
    section Follow-up
    Investigate Mismatches :investigate, 08:30, 4h
```

**Report Types:**

1. **Summary Report**: Tổng quan đối soát
2. **Detailed Report**: Chi tiết từng giao dịch
3. **Exception Report**: Chỉ giao dịch sai lệch
4. **Trend Report**: Xu hướng theo thời gian
5. **SLA Report**: Đánh giá thời gian xử lý

### Report Distribution

```mermaid
graph LR
    Report[Generated Report]
    
    Report --> Email[Email<br/>• TPP users<br/>• Bank admins]
    Report --> Portal[TPP Portal<br/>Download section]
    Report --> SFTP[SFTP Server<br/>Batch download]
    Report --> API[API Endpoint<br/>Real-time access]
    Report --> Archive[Archive Storage<br/>7 years retention]
    
    style Report fill:#4caf50,color:#fff
```

## SLA Management

### Dispute Resolution SLA

| Priority | Initial Response | Resolution Time | Escalation |
|----------|------------------|-----------------|------------|
| **Critical** | 1 hour | 24 hours | After 12 hours |
| **High** | 4 hours | 3 days | After 2 days |
| **Normal** | 8 hours | 5 days | After 4 days |
| **Low** | 24 hours | 10 days | After 8 days |

### SLA Monitoring

```mermaid
graph TB
    Dispute[New Dispute]
    
    Dispute --> Assign[Auto Assign<br/>Set SLA Timer]
    
    Assign --> Monitor{Monitor SLA}
    Monitor -->|80% Time Used| Warning[⚠️ Warning Alert<br/>Email to Handler]
    Monitor -->|95% Time Used| Critical[🚨 Critical Alert<br/>Email to Manager]
    Monitor -->|100% Time Used| Breach[❌ SLA Breach<br/>Auto Escalate]
    
    Warning --> Resolved{Resolved?}
    Critical --> Resolved
    Breach --> Resolved
    
    Resolved -->|Yes| Close[Close Dispute<br/>Calculate Metrics]
    Resolved -->|No| Escalate[Escalate to<br/>Higher Level]
    
    style Breach fill:#f44336,color:#fff
    style Critical fill:#ff9800
    style Warning fill:#ffc107
```

## Data Retention

```mermaid
gantt
    title Data Retention Timeline
    dateFormat YYYY-MM-DD
    axisFormat %b %Y
    
    section Hot Storage
    Active Data :active, hot, 2025-01-01, 90d
    
    section Warm Storage
    Recent History :warm, 2025-04-01, 365d
    
    section Cold Storage
    Archive 1-3 years :cold1, 2026-01-01, 730d
    Archive 3-7 years :cold2, 2028-01-01, 1460d
    
    section Deletion
    Secure Deletion :crit, delete, 2033-01-01, 30d
```

**Retention Policy:**

| Data Type | Hot | Warm | Cold | Total | Deletion |
|-----------|-----|------|------|-------|----------|
| **Transaction Records** | 90 days | 1 year | 7 years | 7 years | Secure erase |
| **Reconciliation Reports** | 90 days | 1 year | 7 years | 7 years | Secure erase |
| **Dispute Cases** | 90 days | 2 years | 7 years | 7 years | Secure erase |
| **Evidence Files** | 90 days | 2 years | 7 years | 7 years | Secure erase |
| **Audit Logs** | 90 days | 1 year | 7 years | 7 years | Permanent |

## Security & Compliance

### Audit Trail

```json
{
  "EventId": "recon-evt-123456",
  "EventType": "Reconciliation.Completed",
  "Timestamp": "2025-12-15T10:12:35+07:00",
  "Actor": {
    "TPPId": "tpp-12345",
    "UserId": "user-abc123",
    "IP": "203.162.4.190"
  },
  "Action": {
    "Type": "ReconciliationUpload",
    "ReconciliationId": "recon-20251214-001",
    "RecordCount": 1250,
    "FileHash": "sha256:a1b2c3d4e5f6...",
    "Status": "Completed"
  },
  "Result": {
    "Matched": 1245,
    "Unmatched": 5,
    "VarianceAmount": "1500000 VND"
  },
  "Compliance": {
    "DataRetention": "7 years",
    "EncryptionUsed": "AES-256",
    "AuditLogRetained": true
  }
}
```

## Performance Metrics

**Target KPIs:**

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| **Auto Match Rate** | ≥ 95% | 97.2% | ✅ |
| **Report Generation** | < 15 min | 12 min | ✅ |
| **Dispute Response** | < 4 hours | 3.5 hours | ✅ |
| **Dispute Resolution** | < 3 days | 2.8 days | ✅ |
| **SLA Compliance** | ≥ 98% | 98.5% | ✅ |
| **API Availability** | ≥ 99.9% | 99.95% | ✅ |

## Tài Liệu Tham Khảo

- **Thông tư 64/2024/TT-NHNN** - Open API Regulations
- **ISO 20022** - Financial Message Standards
- **PCI DSS 4.0** - Requirement 10 (Audit Logging)
- **NIST SP 800-92** - Guide to Computer Security Log Management

---

**Phiên bản:** 1.0  
**Ngày cập nhật:** 15/12/2025  
**Trạng thái:** Production Ready
