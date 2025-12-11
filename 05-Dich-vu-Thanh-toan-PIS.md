# Dịch Vụ Khởi Tạo Thanh Toán (PIS - Payment Initiation Services)

## Tổng Quan

Nhóm API cho phép TPP khởi tạo các giao dịch thanh toán thay mặt khách hàng, tuân thủ ISO 20022 và Thông tư 64/2024/TT-NHNN.

## Kiến Trúc PIS

```mermaid
graph TB
    subgraph "TPP Layer"
        TPP[TPP Application]
    end
    
    subgraph "API Gateway"
        Gateway[API Gateway]
        RateLimit[Rate Limiter]
        JWSVerify[JWS Signature Verification]
    end
    
    subgraph "PIS Service"
        ConsentMgmt[Payment Consent Management]
        Validation[Payment Validation]
        Routing[Smart Routing Engine]
        Idempotency[Idempotency Check]
    end
    
    subgraph "Payment Channels"
        Internal[Internal Transfer]
        Napas[Napas 24/7]
        CITAD[CITAD/IBPS]
        BillPay[Bill Payment]
    end
    
    subgraph "Core Banking"
        CoreAPI[Core Banking API]
        AccountDB[(Account DB)]
        TxnDB[(Transaction DB)]
    end
    
    TPP --> Gateway
    Gateway --> RateLimit
    RateLimit --> JWSVerify
    JWSVerify --> ConsentMgmt
    ConsentMgmt --> Validation
    Validation --> Idempotency
    Idempotency --> Routing
    
    Routing --> Internal
    Routing --> Napas
    Routing --> CITAD
    Routing --> BillPay
    
    Internal --> CoreAPI
    Napas --> CoreAPI
    CITAD --> CoreAPI
    BillPay --> CoreAPI
    
    CoreAPI --> AccountDB
    CoreAPI --> TxnDB
```

## Payment Flow - 2 Bước (Two-Step Process)

```mermaid
sequenceDiagram
    participant User as End User
    participant TPP as TPP App
    participant Gateway as API Gateway
    participant PIS as PIS Service
    participant Auth as Auth Server
    participant Core as Core Banking
    
    Note over TPP,PIS: Step 1: Payment Consent Setup
    TPP->>Gateway: POST /payment-consents<br/>+ JWS Signature
    Gateway->>Gateway: Verify JWS
    Gateway->>PIS: Forward Request
    PIS->>PIS: Validate Payment Details
    PIS->>PIS: Check Limits & Rules
    PIS-->>TPP: 201 Created<br/>ConsentId + Redirect URL
    
    Note over User,Auth: Step 2: User Authorization
    TPP->>User: Redirect to Bank App
    User->>Auth: Login + Biometric Auth
    Auth->>PIS: Fetch Consent Details
    PIS-->>Auth: Payment Info
    Auth->>User: Show Payment Confirmation
    User->>Auth: Approve Payment
    Auth->>Auth: Generate Authorization Code
    Auth-->>TPP: Redirect + auth_code
    
    Note over TPP,Core: Step 3: Execute Payment
    TPP->>Gateway: POST /payments<br/>+ ConsentId + auth_code
    Gateway->>PIS: Forward Request
    PIS->>Auth: Validate auth_code
    Auth-->>PIS: Valid + User Confirmed
    PIS->>Core: Execute Payment
    Core-->>PIS: Payment Status
    PIS-->>TPP: 201 Created<br/>PaymentId + Status
    
    Note over TPP,Core: Step 4: Check Status
    loop Poll Status
        TPP->>Gateway: GET /payments/{PaymentId}
        Gateway->>PIS: Get Status
        PIS->>Core: Query Transaction
        Core-->>PIS: Current Status
        PIS-->>TPP: Status Update
    end
```

## API Endpoints

### 1. Payment Consent Setup

#### POST /v1/payment-consents

```mermaid
graph TB
    Request[Payment Consent Request]
    
    Request --> ValidateJWS{Validate JWS<br/>Signature}
    ValidateJWS -->|Invalid| Error401[401 Unauthorized]
    ValidateJWS -->|Valid| ValidatePayload{Validate Payload}
    
    ValidatePayload -->|Invalid| Error400[400 Bad Request]
    ValidatePayload -->|Valid| CheckLimit{Check Transaction<br/>Limits}
    
    CheckLimit -->|Exceeded| Error403[403 Limit Exceeded]
    CheckLimit -->|OK| CheckAccount{Verify Debtor<br/>Account}
    
    CheckAccount -->|Not Found| Error404[404 Account Not Found]
    CheckAccount -->|OK| CheckBalance{Check Balance}
    
    CheckBalance -->|Insufficient| Error422[422 Insufficient Funds]
    CheckBalance -->|OK| CreateConsent[Create Consent Record]
    
    CreateConsent --> GenerateID[Generate ConsentId]
    GenerateID --> Response[201 Created]
```

**Request Example:**
```json
{
  "Data": {
    "Initiation": {
      "InstructionIdentification": "TXN-20241210-001",
      "EndToEndIdentification": "E2E-12345",
      "InstructedAmount": {
        "Amount": "1000000.00",
        "Currency": "VND"
      },
      "DebtorAccount": {
        "SchemeName": "VN.ACCOUNT",
        "Identification": "1234567890",
        "Name": "NGUYEN VAN A"
      },
      "CreditorAccount": {
        "SchemeName": "VN.ACCOUNT",
        "Identification": "0987654321",
        "Name": "TRAN THI B"
      },
      "RemittanceInformation": {
        "Unstructured": "Chuyen tien tra no"
      }
    }
  },
  "Risk": {
    "PaymentContextCode": "PersonToPerson",
    "MerchantCategoryCode": "0000",
    "DeliveryAddress": {
      "CountryCode": "VN"
    }
  }
}
```

**Response Example:**
```json
{
  "Data": {
    "ConsentId": "consent-pay-12345",
    "Status": "AwaitingAuthorisation",
    "CreationDateTime": "2024-12-10T17:30:00+07:00",
    "StatusUpdateDateTime": "2024-12-10T17:30:00+07:00",
    "Initiation": {
      "InstructionIdentification": "TXN-20241210-001",
      "EndToEndIdentification": "E2E-12345",
      "InstructedAmount": {
        "Amount": "1000000.00",
        "Currency": "VND"
      }
    }
  },
  "Links": {
    "Self": "https://api.bank.vn/v1/payment-consents/consent-pay-12345",
    "Authorise": "https://auth.bank.vn/authorize?consent_id=consent-pay-12345"
  }
}
```

### 2. Execute Payment

#### POST /v1/payments

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant PIS as PIS Service
    participant Idempotency as Idempotency Store
    participant Routing as Smart Router
    participant Napas as Napas 24/7
    participant Core as Core Banking
    
    TPP->>PIS: POST /payments<br/>+ ConsentId<br/>+ Idempotency-Key
    
    PIS->>Idempotency: Check Idempotency Key
    alt Key Exists
        Idempotency-->>PIS: Return Cached Response
        PIS-->>TPP: 200 OK (Cached)
    else New Request
        PIS->>PIS: Validate Consent Status
        PIS->>PIS: Extract Beneficiary Info
        PIS->>Routing: Determine Route
        
        alt Internal Transfer
            Routing->>Core: Execute Internal Transfer
            Core-->>Routing: Success
        else Napas 24/7
            Routing->>Napas: Lookup Beneficiary
            Napas-->>Routing: Beneficiary Name
            Routing->>PIS: Confirm Name Match
            PIS->>Napas: Execute Transfer
            Napas-->>PIS: Transaction ID
        end
        
        PIS->>Idempotency: Cache Response
        PIS-->>TPP: 201 Created + PaymentId
    end
```

**Request Headers:**
```
Authorization: Bearer {access_token}
x-idempotency-key: unique-key-12345
x-jws-signature: eyJhbGc...
Content-Type: application/json
```

**Request Body:**
```json
{
  "Data": {
    "ConsentId": "consent-pay-12345",
    "Initiation": {
      "InstructionIdentification": "TXN-20241210-001",
      "EndToEndIdentification": "E2E-12345",
      "InstructedAmount": {
        "Amount": "1000000.00",
        "Currency": "VND"
      },
      "DebtorAccount": {
        "Identification": "1234567890"
      },
      "CreditorAccount": {
        "Identification": "0987654321"
      }
    }
  }
}
```

**Response:**
```json
{
  "Data": {
    "PaymentId": "pay-67890",
    "ConsentId": "consent-pay-12345",
    "Status": "Pending",
    "CreationDateTime": "2024-12-10T17:35:00+07:00",
    "StatusUpdateDateTime": "2024-12-10T17:35:00+07:00",
    "Initiation": {
      "InstructionIdentification": "TXN-20241210-001",
      "EndToEndIdentification": "E2E-12345",
      "InstructedAmount": {
        "Amount": "1000000.00",
        "Currency": "VND"
      }
    }
  },
  "Links": {
    "Self": "https://api.bank.vn/v1/payments/pay-67890"
  }
}
```

## Smart Routing Engine

```mermaid
graph TB
    Start[Payment Request]
    
    Start --> CheckBenef{Check Beneficiary<br/>Account}
    
    CheckBenef -->|Same Bank| Internal[Internal Transfer<br/>Real-time]
    CheckBenef -->|Other Bank| CheckAmount{Check Amount}
    
    CheckAmount -->|< 500M VND| CheckTime{Check Time}
    CheckAmount -->|≥ 500M VND| CITAD[CITAD Transfer<br/>High Value]
    
    CheckTime -->|Business Hours<br/>5:00-23:00| Napas[Napas 24/7<br/>Fast Transfer]
    CheckTime -->|Outside Hours| Queue[Queue for Next Day<br/>or Napas]
    
    Internal --> Execute[Execute Transaction]
    Napas --> Lookup[Beneficiary Lookup]
    Lookup --> Execute
    CITAD --> Execute
    Queue --> Execute
    
    Execute --> Status{Status}
    Status -->|Success| Complete[Complete]
    Status -->|Pending| Wait[Wait for Settlement]
    Status -->|Failed| Rollback[Rollback + Notify]
```

### Routing Rules

| Điều Kiện | Kênh | Thời Gian Xử Lý | Phí |
|-----------|------|------------------|-----|
| Cùng ngân hàng | Internal | Real-time | Miễn phí |
| Khác ngân hàng, < 500M, 5h-23h | Napas 24/7 | < 10 giây | 1,100 - 5,500 VND |
| Khác ngân hàng, ≥ 500M | CITAD | T+1 | Theo thỏa thuận |
| Ngoài giờ | Napas hoặc Queue | T+1 | Theo kênh |

## Napas 24/7 Integration

### Beneficiary Lookup

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant PIS as PIS Service
    participant Napas as Napas Gateway
    participant BenefBank as Beneficiary Bank
    
    TPP->>PIS: POST /beneficiary-lookup
    Note over TPP,PIS: Request Body:<br/>{bankCode, accountNumber}
    
    PIS->>Napas: Lookup Request (ISO 8583)
    Napas->>BenefBank: Route to Bank
    BenefBank->>BenefBank: Validate Account
    BenefBank-->>Napas: Account Name
    Napas-->>PIS: Lookup Response
    PIS-->>TPP: 200 OK<br/>{accountName, accountNumber}
    
    Note over TPP: Display name for<br/>user confirmation
```

**API Endpoint:** `POST /v1/beneficiary-lookup`

**Request:**
```json
{
  "BeneficiaryBankCode": "970422",
  "AccountNumber": "0987654321"
}
```

**Response:**
```json
{
  "Data": {
    "BeneficiaryBankCode": "970422",
    "BeneficiaryBankName": "MB Bank",
    "AccountNumber": "0987654321",
    "AccountName": "TRAN THI B",
    "Status": "Active"
  }
}
```

### Transfer Execution

```mermaid
stateDiagram-v2
    [*] --> Initiated: TPP submits payment
    Initiated --> Validating: Check account & balance
    Validating --> Pending: Validation passed
    Validating --> Rejected: Validation failed
    
    Pending --> Processing: Send to Napas
    Processing --> Completed: Napas confirms
    Processing --> Failed: Napas rejects
    Processing --> Timeout: No response (30s)
    
    Timeout --> Investigating: Manual check
    Investigating --> Completed: Found successful
    Investigating --> Failed: Confirmed failed
    
    Completed --> [*]
    Rejected --> [*]
    Failed --> [*]
```

## Bill Payment Integration

```mermaid
graph TB
    subgraph "Bill Payment Flow"
        Start[User Initiates Bill Payment]
        
        Start --> Inquiry[Bill Inquiry API]
        Inquiry --> Display[Display Bill Details<br/>Amount, Due Date]
        Display --> Confirm{User Confirms}
        
        Confirm -->|No| Cancel[Cancel]
        Confirm -->|Yes| Payment[Create Payment Consent]
        
        Payment --> Auth[User Authorization]
        Auth --> Execute[Execute Payment]
        Execute --> Aggregator[Bill Aggregator<br/>Payoo/VNPay]
        Aggregator --> Biller[Service Provider<br/>EVN/VNPT/etc]
        
        Biller --> Callback[Callback Notification]
        Callback --> Update[Update Payment Status]
        Update --> Complete[Complete]
    end
```

### Bill Inquiry API

**Endpoint:** `GET /v1/bills/inquiry`

**Request:**
```json
{
  "ServiceCode": "EVN_HCMC",
  "CustomerCode": "PE12345678"
}
```

**Response:**
```json
{
  "Data": {
    "ServiceCode": "EVN_HCMC",
    "ServiceName": "Điện lực TP.HCM",
    "CustomerCode": "PE12345678",
    "CustomerName": "NGUYEN VAN A",
    "BillPeriod": "11/2024",
    "DueDate": "2024-12-15",
    "Amount": {
      "Amount": "450000.00",
      "Currency": "VND"
    },
    "Status": "Unpaid"
  }
}
```

### Bill Payment API

**Endpoint:** `POST /v1/bill-payments`

```json
{
  "Data": {
    "ServiceCode": "EVN_HCMC",
    "CustomerCode": "PE12345678",
    "Amount": {
      "Amount": "450000.00",
      "Currency": "VND"
    },
    "DebtorAccount": {
      "Identification": "1234567890"
    }
  }
}
```

## Beneficiary Management

```mermaid
graph LR
    subgraph "Trusted Beneficiaries"
        Add[Add Beneficiary]
        Verify[Verify via Napas Lookup]
        Save[Save to Trusted List]
    end
    
    subgraph "Benefits"
        FastPay[Faster Payments<br/>Skip confirmation]
        NoOTP[No OTP for small amounts<br/>< 2M VND]
        History[Payment History]
    end
    
    Add --> Verify
    Verify --> Save
    Save --> FastPay
    Save --> NoOTP
    Save --> History
```

**Endpoint:** `POST /v1/beneficiaries`

```json
{
  "Data": {
    "BeneficiaryName": "TRAN THI B",
    "BeneficiaryAccount": {
      "SchemeName": "VN.ACCOUNT",
      "Identification": "0987654321",
      "BankCode": "970422"
    },
    "Nickname": "Chi B - Em gai"
  }
}
```

## Payment Status Lifecycle

```mermaid
stateDiagram-v2
    [*] --> AwaitingAuthorisation: Consent created
    AwaitingAuthorisation --> Authorised: User approved
    AwaitingAuthorisation --> Rejected: User denied
    AwaitingAuthorisation --> Expired: Timeout (5 mins)
    
    Authorised --> Pending: Payment initiated
    Pending --> AcceptedSettlementInProcess: Sent to channel
    AcceptedSettlementInProcess --> AcceptedSettlementCompleted: Settlement done
    AcceptedSettlementInProcess --> Rejected: Channel rejected
    
    AcceptedSettlementCompleted --> [*]
    Rejected --> [*]
    Expired --> [*]
```

## Transaction Limits & Controls

### Daily Limits

```mermaid
graph TB
    Request[Payment Request]
    
    Request --> CheckDaily{Daily Limit<br/>50M VND}
    CheckDaily -->|Exceeded| Block1[Reject: Daily limit exceeded]
    CheckDaily -->|OK| CheckPerTxn{Per Transaction<br/>10M VND}
    
    CheckPerTxn -->|Exceeded| RequireNFC[Require NFC CCCD<br/>Level 4 Auth]
    CheckPerTxn -->|OK| RequireBio[Require Biometric<br/>Level 3 Auth]
    
    RequireNFC --> Proceed[Proceed]
    RequireBio --> Proceed
```

### Limit Configuration

| Loại Giao Dịch | Hạn Mức/Giao Dịch | Hạn Mức/Ngày | Xác Thực |
|----------------|-------------------|--------------|----------|
| Chuyển tiền nội bộ | 50M VND | 200M VND | Level 3 |
| Napas 24/7 | 10M VND | 50M VND | Level 3 (< 10M)<br/>Level 4 (≥ 10M) |
| CITAD | 500M VND | 2B VND | Level 4 |
| Bill Payment | 5M VND | 20M VND | Level 2 |

## Idempotency

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Gateway as API Gateway
    participant Cache as Idempotency Cache
    participant PIS as PIS Service
    
    Note over TPP: Network error, retry request
    
    TPP->>Gateway: POST /payments<br/>Idempotency-Key: key-123
    Gateway->>Cache: Check key-123
    
    alt First Request
        Cache-->>Gateway: Not Found
        Gateway->>PIS: Process Payment
        PIS-->>Gateway: 201 Created
        Gateway->>Cache: Store key-123 + Response (TTL: 24h)
        Gateway-->>TPP: 201 Created
    else Duplicate Request
        Cache-->>Gateway: Found (Response cached)
        Gateway-->>TPP: 200 OK (Idempotent)
    end
```

**Idempotency Rules:**
- Header: `x-idempotency-key: {unique-key}`
- TTL: 24 giờ
- Scope: Per client + per endpoint
- Response: 201 (first) → 200 (subsequent)

## Error Handling

### Common Errors

| HTTP Code | Error Code | Mô Tả | Retry? |
|-----------|------------|-------|--------|
| 400 | `INVALID_AMOUNT` | Số tiền không hợp lệ | No |
| 400 | `INVALID_ACCOUNT` | Số tài khoản sai format | No |
| 401 | `INVALID_SIGNATURE` | JWS signature không hợp lệ | No |
| 403 | `DAILY_LIMIT_EXCEEDED` | Vượt hạn mức ngày | No |
| 403 | `CONSENT_NOT_AUTHORISED` | Consent chưa được duyệt | No |
| 422 | `INSUFFICIENT_FUNDS` | Số dư không đủ | No |
| 422 | `ACCOUNT_BLOCKED` | Tài khoản bị khóa | No |
| 500 | `NAPAS_TIMEOUT` | Napas timeout | Yes (max 3) |
| 503 | `SERVICE_UNAVAILABLE` | Hệ thống bảo trì | Yes (after delay) |

**Error Response:**
```json
{
  "Code": "INSUFFICIENT_FUNDS",
  "Message": "The debtor account does not have sufficient funds to complete this payment",
  "Errors": [
    {
      "ErrorCode": "INSUFFICIENT_FUNDS",
      "Message": "Available balance: 500,000 VND, Required: 1,000,000 VND",
      "Path": "Data.Initiation.InstructedAmount"
    }
  ]
}
```

## Security Controls

### JWS Signature Verification

```javascript
// Verify JWS signature
const jose = require('node-jose');

async function verifyJWS(jwsToken, publicKey) {
  try {
    const keystore = jose.JWK.createKeyStore();
    await keystore.add(publicKey, 'pem');
    
    const result = await jose.JWS.createVerify(keystore)
      .verify(jwsToken);
    
    const payload = JSON.parse(result.payload.toString());
    
    // Check jti (prevent replay)
    if (await isJtiUsed(payload.jti)) {
      throw new Error('JTI already used');
    }
    
    // Check iat (issued at time)
    const now = Date.now() / 1000;
    if (now - payload.iat > 300) { // 5 minutes
      throw new Error('Token too old');
    }
    
    return payload;
  } catch (err) {
    throw new Error('Invalid JWS signature');
  }
}
```

### Fraud Detection

```mermaid
graph TB
    Payment[Payment Request]
    
    Payment --> VelocityCheck{Velocity Check<br/>5 txns in 1 min?}
    VelocityCheck -->|Yes| Block[Block + Alert]
    VelocityCheck -->|No| AmountCheck{Unusual Amount?<br/>vs. History}
    
    AmountCheck -->|Yes| StepUp[Step-up Auth]
    AmountCheck -->|No| LocationCheck{Location Check<br/>IP/Device}
    
    LocationCheck -->|Suspicious| StepUp
    LocationCheck -->|OK| BenefCheck{New Beneficiary?}
    
    BenefCheck -->|Yes| Confirm[Extra Confirmation]
    BenefCheck -->|No| Allow[Allow Transaction]
    
    StepUp --> Allow
    Confirm --> Allow
```

## Compliance Checklist

- [ ] JWS signature bắt buộc cho tất cả payment requests
- [ ] Idempotency key support
- [ ] Two-step consent flow (setup → authorize → execute)
- [ ] Transaction limits enforcement
- [ ] NFC CCCD verification cho giao dịch ≥ 10M VND
- [ ] Beneficiary name lookup (Napas)
- [ ] Audit logging đầy đủ
- [ ] Fraud detection rules
- [ ] Timeout handling (30s max)
- [ ] Retry mechanism với exponential backoff
- [ ] ISO 20022 message format
- [ ] Real-time status updates

## Tài Liệu Tham Khảo
- Thông tư 64/2024/TT-NHNN - Phụ lục 02
- Open Banking UK - Payment Initiation API v4.0
- ISO 20022 - Payment Messages (pacs.008, pain.001)
- Napas 24/7 Technical Specifications
- Quyết định 2345/QĐ-NHNN - Authentication Requirements
