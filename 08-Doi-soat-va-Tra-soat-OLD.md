# Đối Soát & Tra Soát (Reconciliation & Dispute Management)

## Tổng Quan

Hệ thống đối soát và tra soát đảm bảo tính chính xác của dữ liệu giao dịch giữa TPP và Ngân hàng, hỗ trợ giải quyết khiếu nại và tranh chấp.

## Kiến Trúc Hệ Thống

```mermaid
graph TB
    subgraph "TPP Systems"
        TPP_DB[(TPP Transaction DB)]
        TPP_Portal[TPP Portal]
    end
    
    subgraph "Reconciliation Services"
        API[Reconciliation API]
        Matcher[Auto Matching Engine]
        Reporter[Report Generator]
        Dispute[Dispute Management]
    end
    
    subgraph "Bank Systems"
        Bank_DB[(Bank Transaction DB)]
        Core[Core Banking]
        Admin[Admin Portal]
    end
    
    subgraph "File Exchange"
        SFTP[SFTP Server]
        S3[Cloud Storage]
    end
    
    subgraph "Notification"
        Webhook[Webhook Service]
        Email[Email Service]
    end
    
    TPP_Portal --> API
    TPP_DB -.->|Upload| SFTP
    
    API --> Matcher
    API --> Reporter
    API --> Dispute
    
    Matcher --> Bank_DB
    Reporter --> SFTP
    Reporter --> S3
    
    Dispute --> Admin
    
    API --> Webhook
    API --> Email
    
    Bank_DB --> Matcher
    Core --> Bank_DB
```

## Quy Trình Đối Soát Tự Động

```mermaid
sequenceDiagram
    participant Scheduler as Cron Scheduler
    participant Recon as Reconciliation Service
    participant Bank as Bank Database
    participant TPP as TPP System
    participant SFTP as SFTP Server
    participant Notify as Notification Service
    
    Note over Scheduler: Daily at 9:00 AM (T+1)
    
    Scheduler->>Recon: Trigger Daily Reconciliation
    Recon->>Bank: Extract T-1 Transactions
    Bank-->>Recon: Bank Transaction File
    
    Recon->>SFTP: Fetch TPP Transaction File
    SFTP-->>Recon: TPP Transaction File
    
    Recon->>Recon: Parse Both Files
    Recon->>Recon: Match Transactions<br/>by RequestId + Amount + Date
    
    Recon->>Recon: Identify Discrepancies<br/>- Missing<br/>- Status Mismatch<br/>- Amount Mismatch
    
    Recon->>Recon: Generate Reconciliation Report
    Recon->>SFTP: Upload Report
    
    Recon->>Notify: Send Summary Email
    Notify->>TPP: Email with Report Link
    
    alt Discrepancies Found
        Recon->>Notify: Send Alert
        Notify->>TPP: Alert Email
        Notify->>Bank: Alert to Admin
    end
```

## Matching Logic

```mermaid
graph TB
    Start[Transaction Records]
    
    Start --> Match1{Match by<br/>RequestId}
    Match1 -->|Found| CheckStatus{Status Match?}
    Match1 -->|Not Found| Missing[Missing Transaction]
    
    CheckStatus -->|Yes| CheckAmount{Amount Match?}
    CheckStatus -->|No| StatusMismatch[Status Mismatch]
    
    CheckAmount -->|Yes| Matched[Matched ✓]
    CheckAmount -->|No| AmountMismatch[Amount Mismatch]
    
    Missing --> Report[Add to Exception Report]
    StatusMismatch --> Report
    AmountMismatch --> Report
    Matched --> Success[Add to Success Report]
```

### Matching Rules

| Priority | Matching Key | Description |
|----------|--------------|-------------|
| 1 | `RequestId` | Unique transaction identifier from TPP |
| 2 | `TransactionDate` | Transaction date (YYYY-MM-DD) |
| 3 | `Amount` | Transaction amount (exact match) |
| 4 | `DebtorAccount` | Source account number |
| 5 | `CreditorAccount` | Destination account number |

## API Endpoints

### 1. Transaction Inquiry

#### GET /v1/reconciliation/transactions/{TransactionId}

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant API as Recon API
    participant Cache as Redis Cache
    participant DB as Transaction DB
    
    TPP->>API: GET /transactions/{id}
    API->>Cache: Check Cache
    
    alt Cache Hit
        Cache-->>API: Transaction Data
    else Cache Miss
        API->>DB: Query Transaction
        DB-->>API: Transaction + Trace Logs
        API->>Cache: Store (TTL: 5 min)
    end
    
    API->>API: Mask Sensitive Data
    API-->>TPP: 200 OK + Transaction Details
```

**Response:**
```json
{
  "Data": {
    "TransactionId": "txn-12345",
    "RequestId": "req-tpp-67890",
    "TransactionType": "FUND_TRANSFER",
    "Status": "COMPLETED",
    "Amount": {
      "Amount": "1000000.00",
      "Currency": "VND"
    },
    "DebtorAccount": "1234****7890",
    "CreditorAccount": "0987****4321",
    "TransactionDate": "2024-12-10",
    "CompletionTime": "2024-12-10T10:30:45+07:00",
    "Channel": "NAPAS_247",
    "BankReference": "BANK-REF-001",
    "TraceLog": [
      {
        "Timestamp": "2024-12-10T10:30:00+07:00",
        "Stage": "RECEIVED",
        "Status": "SUCCESS"
      },
      {
        "Timestamp": "2024-12-10T10:30:30+07:00",
        "Stage": "VALIDATED",
        "Status": "SUCCESS"
      },
      {
        "Timestamp": "2024-12-10T10:30:45+07:00",
        "Stage": "COMPLETED",
        "Status": "SUCCESS"
      }
    ]
  }
}
```

#### GET /v1/reconciliation/transactions

Query transactions with filters.

**Query Parameters:**
- `fromDate`: Start date (YYYY-MM-DD)
- `toDate`: End date (YYYY-MM-DD)
- `status`: Transaction status
- `type`: Transaction type
- `page`: Page number
- `limit`: Items per page (max 100)

### 2. Reconciliation Reports

#### POST /v1/reconciliation/reports

```mermaid
graph TB
    Request[Create Report Request]
    
    Request --> Validate{Validate Parameters}
    Validate -->|Invalid| Error[400 Bad Request]
    Validate -->|Valid| CheckRange{Date Range}
    
    CheckRange -->|> 31 days| Error2[400 Range too large]
    CheckRange -->|Valid| Queue[Add to Processing Queue]
    
    Queue --> Process[Background Processing]
    Process --> Extract[Extract Bank Data]
    Process --> Fetch[Fetch TPP Data]
    
    Extract --> Match[Run Matching]
    Fetch --> Match
    
    Match --> Generate[Generate Report File]
    Generate --> Format{Output Format}
    
    Format -->|ISO 20022| XML[camt.053 XML]
    Format -->|CSV| CSV_File[CSV File]
    Format -->|Excel| XLSX[Excel File]
    Format -->|JSON| JSON_File[JSON File]
    
    XML --> Upload[Upload to SFTP/S3]
    CSV_File --> Upload
    XLSX --> Upload
    JSON_File --> Upload
    
    Upload --> Notify[Send Notification]
    Notify --> Complete[Report Ready]
```

**Request:**
```json
{
  "ReportType": "DAILY_RECONCILIATION",
  "FromDate": "2024-12-09",
  "ToDate": "2024-12-09",
  "OutputFormat": "ISO20022_CAMT053",
  "DeliveryMethod": "SFTP",
  "IncludeDetails": true
}
```

**Response:**
```json
{
  "Data": {
    "ReportId": "report-20241210-001",
    "Status": "PROCESSING",
    "EstimatedCompletionTime": "2024-12-10T11:00:00+07:00",
    "CreatedAt": "2024-12-10T10:45:00+07:00"
  },
  "Links": {
    "Self": "https://api.bank.vn/v1/reconciliation/reports/report-20241210-001",
    "Status": "https://api.bank.vn/v1/reconciliation/reports/report-20241210-001/status"
  }
}
```

#### GET /v1/reconciliation/reports/{ReportId}

Check report status and download.

**Response:**
```json
{
  "Data": {
    "ReportId": "report-20241210-001",
    "Status": "COMPLETED",
    "ReportType": "DAILY_RECONCILIATION",
    "Period": {
      "FromDate": "2024-12-09",
      "ToDate": "2024-12-09"
    },
    "Summary": {
      "TotalTransactions": 1250,
      "MatchedTransactions": 1245,
      "MissingInBank": 2,
      "MissingInTPP": 1,
      "StatusMismatch": 2,
      "AmountMismatch": 0
    },
    "FileInfo": {
      "FileName": "reconciliation_20241209.xml",
      "FileSize": 2048576,
      "Format": "ISO20022_CAMT053",
      "GeneratedAt": "2024-12-10T10:55:00+07:00"
    }
  },
  "Links": {
    "Download": "https://api.bank.vn/v1/reconciliation/reports/report-20241210-001/download"
  }
}
```

### 3. Auto Matching

#### POST /v1/reconciliation/match

TPP gửi danh sách giao dịch để hệ thống tự động so khớp.

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant API as Recon API
    participant Matcher as Matching Engine
    participant DB as Bank DB
    
    TPP->>API: POST /reconciliation/match<br/>+ Transaction List
    API->>API: Validate Payload
    API->>Matcher: Start Matching Process
    
    loop For each TPP transaction
        Matcher->>DB: Find matching Bank transaction
        alt Match Found
            Matcher->>Matcher: Compare Status & Amount
            alt Exact Match
                Matcher->>Matcher: Mark as MATCHED
            else Mismatch
                Matcher->>Matcher: Mark as DISCREPANCY
            end
        else Not Found
            Matcher->>Matcher: Mark as MISSING_IN_BANK
        end
    end
    
    Matcher-->>API: Matching Results
    API-->>TPP: 200 OK + Results
```

**Request:**
```json
{
  "Transactions": [
    {
      "RequestId": "req-tpp-001",
      "TransactionDate": "2024-12-09",
      "Amount": "1000000.00",
      "Currency": "VND",
      "Status": "SUCCESS",
      "DebtorAccount": "1234567890",
      "CreditorAccount": "0987654321"
    },
    {
      "RequestId": "req-tpp-002",
      "TransactionDate": "2024-12-09",
      "Amount": "500000.00",
      "Currency": "VND",
      "Status": "SUCCESS",
      "DebtorAccount": "1234567890",
      "CreditorAccount": "1111222233"
    }
  ]
}
```

**Response:**
```json
{
  "Data": {
    "MatchingResults": [
      {
        "RequestId": "req-tpp-001",
        "MatchStatus": "MATCHED",
        "BankTransactionId": "txn-bank-12345",
        "BankStatus": "COMPLETED",
        "MatchConfidence": 1.0
      },
      {
        "RequestId": "req-tpp-002",
        "MatchStatus": "STATUS_MISMATCH",
        "BankTransactionId": "txn-bank-12346",
        "BankStatus": "PENDING",
        "TPPStatus": "SUCCESS",
        "MatchConfidence": 0.8,
        "Discrepancy": "Status mismatch: TPP=SUCCESS, Bank=PENDING"
      }
    ],
    "Summary": {
      "Total": 2,
      "Matched": 1,
      "Discrepancies": 1,
      "Missing": 0
    }
  }
}
```

## Dispute Management

### Dispute Lifecycle

```mermaid
stateDiagram-v2
    [*] --> SUBMITTED: TPP creates dispute
    SUBMITTED --> ACKNOWLEDGED: Bank acknowledges
    ACKNOWLEDGED --> INVESTIGATING: Investigation started
    
    INVESTIGATING --> PENDING_INFO: Need more info
    PENDING_INFO --> INVESTIGATING: Info provided
    
    INVESTIGATING --> RESOLVED: Issue resolved
    INVESTIGATING --> REJECTED: Dispute rejected
    
    RESOLVED --> REFUNDED: Refund processed
    RESOLVED --> COMPLETED: No refund needed
    RESOLVED --> PENDING_CUSTOMER: Customer action required
    
    REJECTED --> [*]
    REFUNDED --> [*]
    COMPLETED --> [*]
    PENDING_CUSTOMER --> COMPLETED: Customer confirms
```

### Create Dispute

#### POST /v1/reconciliation/disputes

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant API as Dispute API
    participant Workflow as Workflow Engine
    participant Admin as Bank Admin
    participant Email as Email Service
    
    TPP->>API: POST /disputes<br/>+ Transaction Details + Evidence
    API->>API: Validate Dispute
    API->>API: Generate Dispute ID
    API->>Workflow: Create Dispute Case
    
    Workflow->>Admin: Assign to Agent
    Workflow->>Email: Send Notification
    Email->>TPP: Dispute Received Email
    Email->>Admin: New Dispute Alert
    
    API-->>TPP: 201 Created<br/>Dispute ID + Case Number
```

**Request:**
```json
{
  "TransactionId": "txn-12345",
  "DisputeType": "TRANSACTION_NOT_COMPLETED",
  "DisputeReason": "Transaction shows success on TPP side but customer did not receive funds",
  "Evidence": {
    "Screenshots": [
      "base64_encoded_screenshot_1",
      "base64_encoded_screenshot_2"
    ],
    "CustomerStatement": "I initiated a transfer of 1,000,000 VND on 2024-12-09 but the beneficiary has not received the money.",
    "TPPTransactionLog": {
      "RequestId": "req-tpp-001",
      "Status": "SUCCESS",
      "Timestamp": "2024-12-09T15:30:00+07:00"
    }
  },
  "CustomerInfo": {
    "Name": "NGUYEN VAN A",
    "Phone": "0901234567",
    "Email": "nguyenvana@example.com"
  },
  "Priority": "HIGH"
}
```

**Response:**
```json
{
  "Data": {
    "DisputeId": "dispute-12345",
    "CaseNumber": "CASE-2024-001234",
    "Status": "SUBMITTED",
    "CreatedAt": "2024-12-10T11:00:00+07:00",
    "EstimatedResolutionTime": "2024-12-15T11:00:00+07:00",
    "SLA": {
      "ResponseTime": "24 hours",
      "ResolutionTime": "5 business days"
    }
  },
  "Links": {
    "Self": "https://api.bank.vn/v1/reconciliation/disputes/dispute-12345",
    "Updates": "https://api.bank.vn/v1/reconciliation/disputes/dispute-12345/updates"
  }
}
```

### Dispute Types

| Type | Mô Tả | SLA |
|------|-------|-----|
| `TRANSACTION_NOT_COMPLETED` | Giao dịch không hoàn thành | 5 ngày |
| `WRONG_AMOUNT` | Số tiền sai | 3 ngày |
| `DUPLICATE_CHARGE` | Trừ tiền trùng lặp | 5 ngày |
| `UNAUTHORIZED_TRANSACTION` | Giao dịch không được ủy quyền | 7 ngày |
| `BENEFICIARY_NOT_RECEIVED` | Người nhận chưa nhận tiền | 7 ngày |
| `TECHNICAL_ERROR` | Lỗi kỹ thuật | 3 ngày |

### Track Dispute

#### GET /v1/reconciliation/disputes/{DisputeId}

**Response:**
```json
{
  "Data": {
    "DisputeId": "dispute-12345",
    "CaseNumber": "CASE-2024-001234",
    "Status": "INVESTIGATING",
    "TransactionId": "txn-12345",
    "DisputeType": "TRANSACTION_NOT_COMPLETED",
    "CreatedAt": "2024-12-10T11:00:00+07:00",
    "UpdatedAt": "2024-12-10T14:30:00+07:00",
    "Timeline": [
      {
        "Timestamp": "2024-12-10T11:00:00+07:00",
        "Status": "SUBMITTED",
        "Actor": "TPP",
        "Note": "Dispute created"
      },
      {
        "Timestamp": "2024-12-10T11:15:00+07:00",
        "Status": "ACKNOWLEDGED",
        "Actor": "Bank Admin",
        "Note": "Case assigned to Agent #123"
      },
      {
        "Timestamp": "2024-12-10T14:30:00+07:00",
        "Status": "INVESTIGATING",
        "Actor": "Bank Agent",
        "Note": "Checking with Napas for transaction status"
      }
    ],
    "AssignedAgent": {
      "Name": "Tran Van B",
      "Email": "tranvanb@bank.vn",
      "Phone": "0281234567"
    }
  }
}
```

### Dispute Resolution

#### GET /v1/reconciliation/disputes/{DisputeId}/resolution

**Response:**
```json
{
  "Data": {
    "DisputeId": "dispute-12345",
    "ResolutionStatus": "RESOLVED",
    "ResolutionType": "REFUND",
    "ResolutionDetails": {
      "Finding": "Transaction was sent to Napas but failed at beneficiary bank. Funds were not debited from customer account.",
      "Action": "No refund needed. Transaction already reversed.",
      "RefundAmount": null,
      "RefundTransactionId": null
    },
    "ResolvedAt": "2024-12-12T10:00:00+07:00",
    "ResolvedBy": {
      "Name": "Tran Van B",
      "Role": "Dispute Resolution Agent"
    },
    "CustomerNotified": true
  }
}
```

## Webhook Notifications

### Subscribe to Events

#### POST /v1/reconciliation/webhooks

```json
{
  "CallbackUrl": "https://tpp.example.com/webhooks/reconciliation",
  "Events": [
    "DISPUTE_STATUS_CHANGED",
    "REPORT_COMPLETED",
    "MATCHING_DISCREPANCY_FOUND",
    "TRANSACTION_REVERSED"
  ],
  "Secret": "webhook_secret_key_12345"
}
```

### Webhook Payload

```json
{
  "EventId": "evt-12345",
  "EventType": "DISPUTE_STATUS_CHANGED",
  "Timestamp": "2024-12-10T15:00:00+07:00",
  "Data": {
    "DisputeId": "dispute-12345",
    "OldStatus": "INVESTIGATING",
    "NewStatus": "RESOLVED",
    "ResolutionType": "REFUND"
  }
}
```

**Signature Verification:**
```javascript
const crypto = require('crypto');

function verifyWebhookSignature(payload, signature, secret) {
  const hmac = crypto.createHmac('sha256', secret);
  hmac.update(JSON.stringify(payload));
  const expectedSignature = hmac.digest('hex');
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  );
}
```

## File Formats

### ISO 20022 camt.053 (Bank Statement)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.053.001.08">
  <BkToCstmrStmt>
    <GrpHdr>
      <MsgId>STMT-20241209-001</MsgId>
      <CreDtTm>2024-12-10T09:00:00+07:00</CreDtTm>
    </GrpHdr>
    <Stmt>
      <Id>20241209</Id>
      <CreDtTm>2024-12-10T09:00:00+07:00</CreDtTm>
      <FrToDt>
        <FrDtTm>2024-12-09T00:00:00+07:00</FrDtTm>
        <ToDtTm>2024-12-09T23:59:59+07:00</ToDtTm>
      </FrToDt>
      <Acct>
        <Id>
          <Othr>
            <Id>1234567890</Id>
          </Othr>
        </Id>
        <Ccy>VND</Ccy>
      </Acct>
      <Bal>
        <Tp>
          <CdOrPrtry>
            <Cd>OPBD</Cd>
          </CdOrPrtry>
        </Tp>
        <Amt Ccy="VND">10000000.00</Amt>
        <CdtDbtInd>CRDT</CdtDbtInd>
        <Dt>
          <Dt>2024-12-09</Dt>
        </Dt>
      </Bal>
      <Ntry>
        <Amt Ccy="VND">1000000.00</Amt>
        <CdtDbtInd>DBIT</CdtDbtInd>
        <Sts>BOOK</Sts>
        <BookgDt>
          <Dt>2024-12-09</Dt>
        </BookgDt>
        <ValDt>
          <Dt>2024-12-09</Dt>
        </ValDt>
        <BkTxCd>
          <Domn>
            <Cd>PMNT</Cd>
            <Fmly>
              <Cd>ICDT</Cd>
              <SubFmlyCd>ESCT</SubFmlyCd>
            </Fmly>
          </Domn>
        </BkTxCd>
        <NtryDtls>
          <TxDtls>
            <Refs>
              <EndToEndId>req-tpp-001</EndToEndId>
              <TxId>txn-bank-12345</TxId>
            </Refs>
            <AmtDtls>
              <TxAmt>
                <Amt Ccy="VND">1000000.00</Amt>
              </TxAmt>
            </AmtDtls>
          </TxDtls>
        </NtryDtls>
      </Ntry>
    </Stmt>
  </BkToCstmrStmt>
</Document>
```

### CSV Format

```csv
TransactionDate,RequestId,BankTransactionId,Type,Status,Amount,Currency,DebtorAccount,CreditorAccount,Channel,CompletionTime
2024-12-09,req-tpp-001,txn-bank-12345,FUND_TRANSFER,COMPLETED,1000000.00,VND,1234567890,0987654321,NAPAS_247,2024-12-09T15:30:45+07:00
2024-12-09,req-tpp-002,txn-bank-12346,FUND_TRANSFER,PENDING,500000.00,VND,1234567890,1111222233,NAPAS_247,
```

## Performance & SLA

### Processing Time

| Operation | Target | Max |
|-----------|--------|-----|
| Transaction Inquiry | < 200ms | 500ms |
| Report Generation (1 day) | < 5 min | 10 min |
| Report Generation (1 month) | < 30 min | 1 hour |
| Dispute Creation | < 1s | 2s |
| Webhook Delivery | < 5s | 10s |

### SLA Commitments

| Service | Availability | Response Time |
|---------|--------------|---------------|
| Inquiry APIs | 99.9% | < 500ms |
| Report Generation | 99.5% | As per schedule |
| Dispute Resolution | N/A | 5-7 business days |
| Webhook Delivery | 99% | 3 retries |

## Security & Compliance

### Access Control

```mermaid
graph LR
    subgraph "TPP Access"
        TPP_Read[Read Own Transactions]
        TPP_Dispute[Create Disputes]
        TPP_Report[Request Reports]
    end
    
    subgraph "Bank Admin Access"
        Admin_All[View All Transactions]
        Admin_Dispute[Manage Disputes]
        Admin_Report[Generate Reports]
    end
    
    subgraph "Auditor Access"
        Audit_Read[Read-Only Access]
        Audit_Export[Export Data]
    end
```

### Data Retention

- **Transaction Data**: 5 years
- **Reconciliation Reports**: 5 years
- **Dispute Records**: 7 years
- **Audit Logs**: 3 months (hot) + 1 year (cold)

## Tài Liệu Tham Khảo
- Thông tư 64/2024/TT-NHNN - Điều 12 (Đối soát)
- ISO 20022 - camt.053 (Bank to Customer Statement)
- ISO 20022 - camt.054 (Bank to Customer Debit/Credit Notification)
- PCI DSS - Dispute Management Requirements
