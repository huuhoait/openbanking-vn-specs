# Dịch Vụ Thông Tin Tài Khoản (AIS - Account Information Services)

## Tổng Quan

Nhóm API cho phép TPP truy cập thông tin tài chính của khách hàng dưới sự đồng ý rõ ràng, tuân thủ Thông tư 64/2024/TT-NHNN.

## Kiến Trúc AIS

```mermaid
graph TB
    subgraph "TPP Layer"
        TPP[TPP Application]
    end
    
    subgraph "API Gateway"
        Gateway[API Gateway<br/>Rate Limiting]
    end
    
    subgraph "AIS Service"
        Consent[Consent Validation]
        Cache[Redis Cache]
        Transform[Data Transformation]
    end
    
    subgraph "Core Banking"
        CoreAPI[Core Banking API]
        AccountDB[(Account Database)]
        TxnDB[(Transaction Database)]
    end
    
    TPP -->|GET /accounts| Gateway
    Gateway --> Consent
    Consent -->|Valid| Cache
    Cache -->|Cache Miss| Transform
    Transform --> CoreAPI
    CoreAPI --> AccountDB
    CoreAPI --> TxnDB
    
    Cache -->|Cache Hit| TPP
    Transform --> Cache
    Transform --> TPP
```

## API Endpoints

### 1. Account Discovery

#### GET /v1/accounts

Lấy danh sách tài khoản mà khách hàng đã đồng ý chia sẻ.

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Gateway as API Gateway
    participant AIS as AIS Service
    participant Consent as Consent Service
    participant Core as Core Banking
    
    TPP->>Gateway: GET /v1/accounts<br/>Authorization: Bearer {token}
    Gateway->>Gateway: Validate Token
    Gateway->>AIS: Forward Request
    AIS->>Consent: Check Consent<br/>+ Scopes
    
    alt Consent Valid
        Consent-->>AIS: Allowed Account IDs
        AIS->>Core: Fetch Accounts
        Core-->>AIS: Account List
        AIS->>AIS: Filter by Consent
        AIS->>AIS: Mask Sensitive Data
        AIS-->>TPP: 200 OK + Accounts
    else Consent Invalid/Expired
        Consent-->>AIS: Consent Expired
        AIS-->>TPP: 403 Forbidden
    end
```

**Response Example:**
```json
{
  "Data": {
    "Account": [
      {
        "AccountId": "acc-12345",
        "Currency": "VND",
        "AccountType": "CurrentAccount",
        "AccountSubType": "Checking",
        "Nickname": "Tài khoản chính",
        "Status": "Active",
        "StatusUpdateDateTime": "2024-12-10T10:30:00+07:00"
      },
      {
        "AccountId": "acc-67890",
        "Currency": "VND",
        "AccountType": "Savings",
        "AccountSubType": "TermDeposit",
        "Nickname": "Tiết kiệm 12 tháng",
        "Status": "Active"
      }
    ]
  },
  "Links": {
    "Self": "https://api.bank.vn/v1/accounts"
  },
  "Meta": {
    "TotalPages": 1
  }
}
```

### 2. Balance Inquiry

#### GET /v1/accounts/{AccountId}/balances

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Cache as Redis Cache
    participant AIS as AIS Service
    participant Core as Core Banking
    
    TPP->>AIS: GET /accounts/acc-12345/balances
    AIS->>Cache: Check Cache
    
    alt Cache Hit (TTL < 60s)
        Cache-->>AIS: Cached Balance
        AIS-->>TPP: 200 OK + Balance
    else Cache Miss
        AIS->>Core: Query Real-time Balance
        Core-->>AIS: Balance Data
        AIS->>Cache: Store (TTL=60s)
        AIS-->>TPP: 200 OK + Balance
    end
```

**Response Example:**
```json
{
  "Data": {
    "Balance": [
      {
        "AccountId": "acc-12345",
        "CreditDebitIndicator": "Credit",
        "Type": "InterimAvailable",
        "Amount": {
          "Amount": "15750000.00",
          "Currency": "VND"
        },
        "DateTime": "2024-12-10T14:25:30+07:00"
      },
      {
        "AccountId": "acc-12345",
        "CreditDebitIndicator": "Credit",
        "Type": "InterimBooked",
        "Amount": {
          "Amount": "16000000.00",
          "Currency": "VND"
        },
        "DateTime": "2024-12-10T14:25:30+07:00"
      }
    ]
  }
}
```

### 3. Transaction History

#### GET /v1/accounts/{AccountId}/transactions

```mermaid
graph TB
    Request[Request with Filters<br/>fromDate, toDate, page, limit]
    
    Request --> Validate{Validate Date Range}
    Validate -->|> 90 days| Error[400 Bad Request<br/>Max 90 days]
    Validate -->|Valid| CheckConsent{Check Consent}
    
    CheckConsent -->|No Permission| Error403[403 Forbidden]
    CheckConsent -->|Valid| Query[Query Transactions]
    
    Query --> Paginate[Apply Pagination]
    Paginate --> Enrich[Enrich Data<br/>Merchant Info, Category]
    Enrich --> Mask[Mask Sensitive Info]
    Mask --> Response[200 OK + Transactions]
```

**Request Parameters:**
- `fromBookingDateTime`: ISO 8601 format
- `toBookingDateTime`: ISO 8601 format (max 90 days from `fromBookingDateTime`)
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 25, max: 100)

**Response Example:**
```json
{
  "Data": {
    "Transaction": [
      {
        "TransactionId": "txn-001",
        "AccountId": "acc-12345",
        "Amount": {
          "Amount": "250000.00",
          "Currency": "VND"
        },
        "CreditDebitIndicator": "Debit",
        "Status": "Booked",
        "BookingDateTime": "2024-12-09T15:30:00+07:00",
        "ValueDateTime": "2024-12-09T15:30:00+07:00",
        "TransactionInformation": "Chuyển tiền đến NGUYEN VAN A",
        "BankTransactionCode": {
          "Code": "Transfer",
          "SubCode": "InterbankTransfer"
        },
        "ProprietaryBankTransactionCode": {
          "Code": "NAPAS247"
        },
        "Balance": {
          "Amount": {
            "Amount": "15750000.00",
            "Currency": "VND"
          },
          "CreditDebitIndicator": "Credit",
          "Type": "InterimAvailable"
        }
      }
    ]
  },
  "Links": {
    "Self": "https://api.bank.vn/v1/accounts/acc-12345/transactions?page=1",
    "Next": "https://api.bank.vn/v1/accounts/acc-12345/transactions?page=2"
  },
  "Meta": {
    "TotalPages": 5,
    "FirstAvailableDateTime": "2024-09-10T00:00:00+07:00",
    "LastAvailableDateTime": "2024-12-10T23:59:59+07:00"
  }
}
```

### 4. Balance Change Notification (Webhook)

#### POST /v1/event-subscriptions

TPP đăng ký webhook để nhận thông báo khi có biến động số dư.

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant AIS as AIS Service
    participant EventBus as Event Bus
    participant Core as Core Banking
    participant Worker as Webhook Worker
    
    Note over TPP,AIS: Registration Phase
    TPP->>AIS: POST /event-subscriptions<br/>{url, events, accountId}
    AIS->>AIS: Validate Callback URL
    AIS->>AIS: Generate Subscription ID
    AIS-->>TPP: 201 Created + Subscription ID
    
    Note over Core,Worker: Transaction Occurs
    Core->>EventBus: Publish BalanceChanged Event
    EventBus->>Worker: Consume Event
    Worker->>Worker: Check Active Subscriptions
    Worker->>Worker: Prepare Payload + Sign HMAC
    Worker->>TPP: POST {callbackUrl}<br/>X-Signature: HMAC-SHA256
    
    alt Success
        TPP-->>Worker: 200 OK
        Worker->>AIS: Mark Delivered
    else Failure
        TPP-->>Worker: 4xx/5xx or Timeout
        Worker->>Worker: Retry (3 attempts)
        Worker->>AIS: Mark Failed
    end
```

**Webhook Payload Example:**
```json
{
  "EventType": "BalanceChanged",
  "EventId": "evt-12345",
  "Timestamp": "2024-12-10T16:45:00+07:00",
  "Data": {
    "AccountId": "acc-12345",
    "NewBalance": {
      "Amount": "15500000.00",
      "Currency": "VND"
    },
    "ChangeAmount": {
      "Amount": "250000.00",
      "Currency": "VND"
    },
    "CreditDebitIndicator": "Debit",
    "TransactionId": "txn-002"
  }
}
```

**HMAC Signature Verification:**
```javascript
const crypto = require('crypto');

function verifySignature(payload, signature, secret) {
  const hmac = crypto.createHmac('sha256', secret);
  hmac.update(JSON.stringify(payload));
  const expectedSignature = hmac.digest('hex');
  return signature === expectedSignature;
}
```

## Data Model

### Account Object

```mermaid
classDiagram
    class Account {
        +String AccountId
        +String Currency
        +String AccountType
        +String AccountSubType
        +String Nickname
        +String Status
        +DateTime StatusUpdateDateTime
        +Servicer Servicer
    }
    
    class Servicer {
        +String SchemeName
        +String Identification
    }
    
    class Balance {
        +String AccountId
        +String CreditDebitIndicator
        +String Type
        +Amount Amount
        +DateTime DateTime
    }
    
    class Transaction {
        +String TransactionId
        +String AccountId
        +Amount Amount
        +String CreditDebitIndicator
        +String Status
        +DateTime BookingDateTime
        +String TransactionInformation
        +BankTransactionCode BankTransactionCode
        +Balance Balance
    }
    
    Account "1" --> "1..*" Balance
    Account "1" --> "0..*" Transaction
    Account "1" --> "1" Servicer
```

## Consent Management

### Consent Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Requested: TPP creates consent
    Requested --> AwaitingAuthorisation: Consent ID issued
    
    AwaitingAuthorisation --> Authorised: User approves
    AwaitingAuthorisation --> Rejected: User denies
    AwaitingAuthorisation --> Expired: Timeout (5 mins)
    
    Authorised --> Active: Token issued
    Active --> Expired: 180 days passed
    Active --> Revoked: User/TPP revokes
    
    Rejected --> [*]
    Expired --> [*]
    Revoked --> [*]
```

### Consent Scopes

| Scope | Quyền Truy Cập | Thời Hạn Tối Đa |
|-------|----------------|------------------|
| `accounts.read` | Danh sách tài khoản | 180 ngày |
| `accounts.balance.read` | Số dư tài khoản | 180 ngày |
| `accounts.transactions.read` | Lịch sử giao dịch | 180 ngày |
| `accounts.details.read` | Chi tiết tài khoản (số TK đầy đủ) | 180 ngày |

## Performance Optimization

### Caching Strategy

```mermaid
graph LR
    subgraph "Cache Layers"
        L1[L1: In-Memory<br/>API Gateway<br/>TTL: 10s]
        L2[L2: Redis<br/>Shared Cache<br/>TTL: 60s]
        L3[L3: Core Banking<br/>Source of Truth]
    end
    
    Request[API Request] --> L1
    L1 -->|Miss| L2
    L2 -->|Miss| L3
    
    L3 -->|Update| L2
    L2 -->|Update| L1
```

**Cache TTL by Data Type:**
- Account List: 300s (5 minutes)
- Balance: 60s (1 minute)
- Transactions: 3600s (1 hour) - immutable data
- Account Details: 600s (10 minutes)

### Rate Limiting

```mermaid
graph TB
    Request[Incoming Request]
    
    Request --> Global{Global Limit<br/>1000 req/s}
    Global -->|Exceeded| Reject1[429 Too Many Requests]
    
    Global -->|OK| PerClient{Per Client<br/>100 req/min}
    PerClient -->|Exceeded| Reject2[429 + Retry-After]
    
    PerClient -->|OK| PerEndpoint{Per Endpoint}
    PerEndpoint -->|/balances: 60/min| CheckBalance
    PerEndpoint -->|/transactions: 30/min| CheckTxn
    PerEndpoint -->|/accounts: 20/min| CheckAccounts
    
    CheckBalance -->|OK| Process[Process Request]
    CheckTxn -->|OK| Process
    CheckAccounts -->|OK| Process
```

## Security Controls

### Data Masking

```mermaid
graph LR
    subgraph "Raw Data"
        Raw[Account Number:<br/>1234567890123456]
    end
    
    subgraph "Masking Rules"
        Rule1[Show First 4 + Last 4]
        Rule2[Mask Middle Digits]
    end
    
    subgraph "Masked Data"
        Masked[Account Number:<br/>1234********3456]
    end
    
    Raw --> Rule1
    Raw --> Rule2
    Rule1 --> Masked
    Rule2 --> Masked
```

**Masking Rules:**
- **Account Number**: Show first 4 + last 4 digits
- **Card Number**: Show last 4 digits only
- **Phone Number**: Show last 4 digits only
- **Email**: Mask username (show first 2 chars)

### Audit Logging

```json
{
  "timestamp": "2024-12-10T16:45:00+07:00",
  "eventType": "AccountAccess",
  "tppId": "tpp-12345",
  "userId": "user-67890",
  "accountId": "acc-***3456",
  "endpoint": "/v1/accounts/acc-12345/balances",
  "method": "GET",
  "statusCode": 200,
  "responseTime": 125,
  "ipAddress": "203.162.xxx.xxx",
  "userAgent": "TPP-App/1.0",
  "consentId": "consent-abc123"
}
```

## Error Handling

### Common Error Codes

| HTTP Code | Error Code | Mô Tả | Hành Động |
|-----------|------------|-------|-----------|
| 400 | `INVALID_DATE_RANGE` | Khoảng thời gian > 90 ngày | Giảm khoảng thời gian |
| 401 | `INVALID_TOKEN` | Access token không hợp lệ | Refresh token |
| 403 | `CONSENT_EXPIRED` | Consent đã hết hạn | Yêu cầu consent mới |
| 403 | `INSUFFICIENT_SCOPE` | Thiếu scope cần thiết | Yêu cầu scope đúng |
| 404 | `ACCOUNT_NOT_FOUND` | Tài khoản không tồn tại | Kiểm tra AccountId |
| 429 | `RATE_LIMIT_EXCEEDED` | Vượt quá giới hạn | Retry sau `Retry-After` |
| 500 | `CORE_BANKING_ERROR` | Lỗi hệ thống Core Banking | Retry hoặc liên hệ support |

**Error Response Format:**
```json
{
  "Code": "CONSENT_EXPIRED",
  "Message": "The consent has expired. Please request a new consent from the user.",
  "Errors": [
    {
      "ErrorCode": "CONSENT_EXPIRED",
      "Message": "Consent ID 'consent-abc123' expired on 2024-12-01",
      "Path": "ConsentId"
    }
  ]
}
```

## Compliance Checklist

- [ ] Consent validation trước mỗi API call
- [ ] Token expiry enforcement (max 180 days)
- [ ] Data masking cho sensitive fields
- [ ] Audit logging đầy đủ (3 months + 1 year backup)
- [ ] Rate limiting theo quy định
- [ ] Cache invalidation khi có thay đổi
- [ ] Webhook retry mechanism (3 attempts)
- [ ] HMAC signature cho webhooks
- [ ] TLS 1.3 cho tất cả connections
- [ ] PII data không xuất hiện trong logs

## Tài Liệu Tham Khảo
- Thông tư 64/2024/TT-NHNN - Phụ lục 01
- Open Banking UK - Account and Transaction API v4.0
- ISO 20022 - Account Management Messages
- GDPR/Nghị định 13/2023 - Data Protection
