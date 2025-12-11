# Bảo Mật & Xác Thực

## Tổng Quan

Hệ thống Open Banking tuân thủ các tiêu chuẩn bảo mật cao nhất bao gồm OAuth 2.0, FAPI (Financial-grade API), và các yêu cầu của Thông tư 64/2024/TT-NHNN.

## OAuth 2.0 Authorization Code Flow with PKCE

```mermaid
%%{init: {'theme':'base', 'themeVariables': {
  'actorBkg':'#1e293b',
  'actorBorder':'#3b82f6',
  'actorTextColor':'#e5e7eb',
  'actorLineColor':'#60a5fa',
  'signalColor':'#e5e7eb',
  'signalTextColor':'#e5e7eb',
  'labelBoxBkgColor':'#334155',
  'labelBoxBorderColor':'#475569',
  'labelTextColor':'#e5e7eb',
  'loopTextColor':'#e5e7eb',
  'noteBkgColor':'#1e3a8a',
  'noteBorderColor':'#3b82f6',
  'noteTextColor':'#e5e7eb',
  'activationBkgColor':'#3b82f6',
  'activationBorderColor':'#60a5fa',
  'sequenceNumberColor':'#0f172a'
}}}%%
sequenceDiagram
    participant User as End User
    participant TPP as TPP Application
    participant App as Bank Mobile App
    participant AuthServer as Authorization Server
    participant ResourceServer as Resource Server (API)
    
    Note over TPP: Generate code_verifier<br/>& code_challenge
    
    TPP->>App: Deeplink or Qr scann <br/>+ client_id + code_challenge
    App->>AuthServer: GET /authorize?client_id=xxx<br/>&code_challenge=yyy
    AuthServer->>User: Show Login & Consent Screen
    User->>AuthServer: Login & Choose account & Approve Consent
    AuthServer->>AuthServer: Generate authorization_code
    AuthServer->>App: Redirect to TPP callback<br/>+ authorization_code
    App->>TPP: Return authorization_code
    
    TPP->>AuthServer: POST /token<br/>+ authorization_code<br/>+ code_verifier<br/>+ client_secret
    AuthServer->>AuthServer: Verify code_verifier<br/>matches code_challenge
    AuthServer-->>TPP: access_token + refresh_token
    
    TPP->>ResourceServer: API Request + access_token
    ResourceServer->>AuthServer: Validate Token
    AuthServer-->>ResourceServer: Token Valid + Scopes
    ResourceServer-->>TPP: API Response
```

## Client Credentials Flow (Server-to-Server)

```mermaid
sequenceDiagram
    participant TPP as TPP Backend
    participant AuthServer as Authorization Server
    participant API as API Gateway
    
    TPP->>AuthServer: POST /token<br/>grant_type=client_credentials<br/>client_id + client_secret
    AuthServer->>AuthServer: Validate Client Credentials
    AuthServer-->>TPP: access_token (no refresh_token)
    
    TPP->>API: API Request + access_token
    API->>AuthServer: Introspect Token
    AuthServer-->>API: Token Valid + Scopes
    API-->>TPP: API Response
```

## JWS (JSON Web Signature) cho Non-Repudiation

```mermaid
graph LR
    subgraph "TPP Side"
        Payload[Request Payload<br/>JSON]
        PrivKey[TPP Private Key]
        Sign[Sign with RS256]
        
        Payload --> Sign
        PrivKey --> Sign
        Sign --> JWS[JWS Token]
    end
    
    subgraph "Bank Side"
        JWS --> Verify[Verify Signature]
        PubKey[TPP Public Key<br/>from Onboarding] --> Verify
        Verify --> Valid{Valid?}
        Valid -->|Yes| Process[Process Transaction]
        Valid -->|No| Reject[Reject Request]
    end
```

### Cấu Trúc JWS Header

```json
{
  "alg": "RS256",
  "kid": "tpp-key-2024-001",
  "typ": "JOSE",
  "jti": "unique-request-id-12345",
  "iat": 1702345678
}
```

### Payload Example

```json
{
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
    "Identification": "0987654321",
    "Name": "NGUYEN VAN A"
  }
}
```

## Consent Management - Quản Lý Sự Đồng Ý

### Tổng Quan

Consent (Sự đồng ý) là cơ chế bảo vệ quyền riêng tư của khách hàng, đảm bảo TPP chỉ được truy cập dữ liệu khi có sự cho phép rõ ràng từ người dùng. Tuân thủ Thông tư 64/2024 và Nghị định 13/2023 về bảo vệ dữ liệu cá nhân.

### Quy Trình Tạo Consent

```mermaid
sequenceDiagram
    participant User as End User
    participant TPP as TPP Application
    participant BankApp as Bank Mobile App
    participant ConsentAPI as Consent API
    participant ConsentDB as Consent Database
    participant AuthServer as Authorization Server
    
    Note over TPP,ConsentAPI: Bước 1: TPP Tạo Consent Request
    
    TPP->>ConsentAPI: POST /consents<br/>+ Scopes + Purpose + Duration
    ConsentAPI->>ConsentAPI: Validate Request<br/>- Check TPP credentials<br/>- Validate scopes<br/>- Check duration (max 180 days)
    ConsentAPI->>ConsentDB: Create Consent Record<br/>Status: AWAITING_AUTHORISATION
    ConsentDB-->>ConsentAPI: Consent ID
    ConsentAPI-->>TPP: 201 Created<br/>ConsentId + Authorization URL
    
    Note over User,BankApp: Bước 2: User Authorization
    
    TPP->>BankApp: Redirect/Deeplink<br/>+ ConsentId
    BankApp->>ConsentAPI: GET /consents/{ConsentId}
    ConsentAPI-->>BankApp: Consent Details<br/>(Scopes, Purpose, TPP Info)
    
    BankApp->>User: Show Consent Screen<br/>- TPP name & logo<br/>- Requested permissions<br/>- Data to be shared<br/>- Duration
    
    alt User Approves
        User->>BankApp: Approve Consent<br/>+ Select Accounts
        BankApp->>BankApp: Biometric Authentication
        BankApp->>ConsentAPI: PUT /consents/{ConsentId}/authorise<br/>+ Selected Accounts<br/>+ User ID
        
        ConsentAPI->>ConsentDB: Update Consent<br/>Status: AUTHORISED<br/>+ Linked Accounts<br/>+ Approval Timestamp
        ConsentAPI->>AuthServer: Generate Authorization Code
        AuthServer-->>ConsentAPI: Authorization Code
        ConsentAPI-->>BankApp: Authorization Code
        BankApp->>TPP: Redirect with auth_code
        
    else User Denies
        User->>BankApp: Deny Consent
        BankApp->>ConsentAPI: PUT /consents/{ConsentId}/reject
        ConsentAPI->>ConsentDB: Update Status: REJECTED
        ConsentAPI-->>BankApp: Rejected
        BankApp->>TPP: Redirect with error
    end
    
    Note over TPP,AuthServer: Bước 3: Exchange Token
    
    TPP->>AuthServer: POST /token<br/>+ auth_code + client_secret
    AuthServer->>ConsentDB: Verify Consent Status
    ConsentDB-->>AuthServer: AUTHORISED + Scopes
    AuthServer->>AuthServer: Generate Access Token<br/>+ Refresh Token
    AuthServer->>ConsentDB: Update Status: ACTIVE<br/>+ Token Reference
    AuthServer-->>TPP: access_token + refresh_token
```

### Cấu Trúc Consent Record

```json
{
  "consentId": "consent-abc123xyz",
  "status": "ACTIVE",
  "createdDateTime": "2024-12-11T09:00:00+07:00",
  "statusUpdateDateTime": "2024-12-11T09:05:00+07:00",
  "expirationDateTime": "2025-06-09T09:05:00+07:00",
  
  "tppInfo": {
    "clientId": "tpp-12345",
    "clientName": "Example Fintech",
    "logoUrl": "https://example.com/logo.png"
  },
  
  "permissions": [
    "accounts.read",
    "accounts.balance.read",
    "transactions.read"
  ],
  
  "purpose": "Cung cấp dịch vụ quản lý tài chính cá nhân",
  
  "authorisation": {
    "userId": "user-67890",
    "authorisedDateTime": "2024-12-11T09:05:00+07:00",
    "authenticationMethod": "BIOMETRIC",
    "selectedAccounts": [
      {
        "accountId": "acc-111",
        "accountType": "CURRENT",
        "permissions": ["balance.read", "transactions.read"]
      },
      {
        "accountId": "acc-222",
        "accountType": "SAVINGS",
        "permissions": ["balance.read"]
      }
    ]
  },
  
  "tokenInfo": {
    "accessTokenHash": "sha256_hash_of_token",
    "refreshTokenHash": "sha256_hash_of_refresh_token",
    "tokenIssuedAt": "2024-12-11T09:05:30+07:00",
    "tokenExpiresAt": "2024-12-11T09:20:30+07:00"
  },
  
  "auditTrail": [
    {
      "timestamp": "2024-12-11T09:00:00+07:00",
      "action": "CONSENT_CREATED",
      "actor": "TPP",
      "details": "Consent request initiated"
    },
    {
      "timestamp": "2024-12-11T09:05:00+07:00",
      "action": "CONSENT_AUTHORISED",
      "actor": "USER",
      "details": "User approved via biometric"
    },
    {
      "timestamp": "2024-12-11T09:05:30+07:00",
      "action": "TOKEN_ISSUED",
      "actor": "SYSTEM",
      "details": "Access token generated"
    }
  ]
}
```

### Consent Lifecycle States

```mermaid
stateDiagram-v2
    [*] --> AWAITING_AUTHORISATION: TPP creates consent
    
    AWAITING_AUTHORISATION --> AUTHORISED: User approves
    AWAITING_AUTHORISATION --> REJECTED: User denies
    AWAITING_AUTHORISATION --> EXPIRED: Timeout (5 mins)
    
    AUTHORISED --> ACTIVE: Token issued
    
    ACTIVE --> EXPIRED: Duration exceeded (180 days)
    ACTIVE --> REVOKED_BY_USER: User revokes
    ACTIVE --> REVOKED_BY_TPP: TPP revokes
    ACTIVE --> SUSPENDED: Suspicious activity
    
    SUSPENDED --> ACTIVE: Investigation cleared
    SUSPENDED --> REVOKED_BY_BANK: Confirmed fraud
    
    REJECTED --> [*]
    EXPIRED --> [*]
    REVOKED_BY_USER --> [*]
    REVOKED_BY_TPP --> [*]
    REVOKED_BY_BANK --> [*]
    
    note right of ACTIVE
        Max duration: 180 days
        Token refresh allowed
        User can view/manage
    end note
```

### Consent Storage & Security

**Database Schema:**

```sql
CREATE TABLE consents (
    consent_id VARCHAR(50) PRIMARY KEY,
    tpp_client_id VARCHAR(50) NOT NULL,
    user_id VARCHAR(50),
    status VARCHAR(30) NOT NULL,
    
    -- Permissions
    permissions JSON NOT NULL,
    purpose TEXT NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL,
    authorised_at TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    revoked_at TIMESTAMP,
    
    -- Linked accounts (encrypted)
    selected_accounts JSON,
    
    -- Token references (hashed)
    access_token_hash VARCHAR(64),
    refresh_token_hash VARCHAR(64),
    
    -- Audit
    audit_trail JSON,
    
    INDEX idx_user_id (user_id),
    INDEX idx_tpp_client_id (tpp_client_id),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at)
);
```

**Security Measures:**
- Consent ID: Cryptographically random (UUID v4)
- Account data: Encrypted at rest (AES-256)
- Token hashes: SHA-256 (không lưu token gốc)
- Audit trail: Immutable log
- Access control: Row-level security

### User Consent Management Portal

```mermaid
graph TB
    subgraph "User Portal Features"
        View[View Active Consents]
        Details[View Consent Details<br/>- TPP info<br/>- Permissions<br/>- Linked accounts<br/>- Usage history]
        Revoke[Revoke Consent]
        History[Consent History<br/>- Approved<br/>- Rejected<br/>- Revoked]
    end
    
    subgraph "Notifications"
        NewConsent[New consent request]
        Expiring[Consent expiring soon<br/>30 days before]
        Expired[Consent expired]
        Suspicious[Suspicious activity]
    end
    
    View --> Details
    Details --> Revoke
    View --> History
```

### API Endpoints

#### 1. Create Consent (TPP)

**POST /v1/consents**

```json
{
  "permissions": [
    "accounts.read",
    "accounts.balance.read",
    "transactions.read"
  ],
  "expirationDateTime": "2025-06-09T09:00:00+07:00",
  "purpose": "Cung cấp dịch vụ quản lý tài chính cá nhân"
}
```

**Response:**
```json
{
  "consentId": "consent-abc123xyz",
  "status": "AWAITING_AUTHORISATION",
  "createdDateTime": "2024-12-11T09:00:00+07:00",
  "expirationDateTime": "2025-06-09T09:00:00+07:00",
  "authorisationUrl": "https://bank.vn/authorize?consent_id=consent-abc123xyz"
}
```

#### 2. Get Consent Details

**GET /v1/consents/{consentId}**

```json
{
  "consentId": "consent-abc123xyz",
  "status": "ACTIVE",
  "permissions": ["accounts.read", "accounts.balance.read"],
  "tppInfo": {
    "clientId": "tpp-12345",
    "clientName": "Example Fintech"
  },
  "authorisation": {
    "authorisedDateTime": "2024-12-11T09:05:00+07:00",
    "accountsCount": 2
  },
  "expirationDateTime": "2025-06-09T09:05:00+07:00"
}
```

#### 3. Revoke Consent (User or TPP)

**DELETE /v1/consents/{consentId}**

```json
{
  "revocationReason": "USER_REQUESTED",
  "revokedBy": "user-67890",
  "revokedAt": "2024-12-11T10:00:00+07:00"
}
```

### Consent Validation Flow

```mermaid
graph TB
    APIRequest[API Request + Access Token]
    
    APIRequest --> ValidateToken{Validate Token}
    ValidateToken -->|Invalid| Error401[401 Unauthorized]
    ValidateToken -->|Valid| ExtractConsent[Extract Consent ID<br/>from Token]
    
    ExtractConsent --> CheckConsent{Check Consent<br/>in Database}
    CheckConsent -->|Not Found| Error403[403 Forbidden]
    CheckConsent -->|Found| CheckStatus{Status = ACTIVE?}
    
    CheckStatus -->|No| Error403
    CheckStatus -->|Yes| CheckExpiry{Expired?}
    
    CheckExpiry -->|Yes| Error403_Expired[403 Consent Expired]
    CheckExpiry -->|No| CheckScope{Has Required<br/>Scope?}
    
    CheckScope -->|No| Error403_Scope[403 Insufficient Scope]
    CheckScope -->|Yes| CheckAccount{Accessing<br/>Allowed Account?}
    
    CheckAccount -->|No| Error403_Account[403 Account Not Consented]
    CheckAccount -->|Yes| Allow[Allow Request]
```

### Compliance & Best Practices

**Thông tư 64/2024 Requirements:**
- ✅ Thời hạn tối đa: 180 ngày
- ✅ Sự đồng ý rõ ràng (Explicit consent)
- ✅ Quyền rút lại bất cứ lúc nào
- ✅ Thông báo khi consent sắp hết hạn

**Nghị định 13/2023 (GDPR-like):**
- ✅ Purpose limitation (Mục đích cụ thể)
- ✅ Data minimization (Chỉ thu thập dữ liệu cần thiết)
- ✅ Transparency (Minh bạch về việc sử dụng dữ liệu)
- ✅ Right to withdraw (Quyền rút lại đồng ý)

**Security Best Practices:**
- Consent ID phải random và không đoán được
- Lưu audit trail đầy đủ
- Encrypt sensitive data
- Rate limiting cho consent creation
- Monitor suspicious patterns


## Các Cấp Độ Xác Thực theo QĐ 2345

```mermaid
graph TB
    subgraph "Level 1: Basic"
        L1[Username + Password]
    end
    
    subgraph "Level 2: Two-Factor"
        L2[Password + SMS OTP]
    end
    
    subgraph "Level 3: Biometric"
        L3[Fingerprint / Face ID]
    end
    
    subgraph "Level 4: Enhanced Biometric"
        L4[NFC CCCD Chip Verification<br/>+ Face Matching]
    end
    
    L1 --> L2
    L2 --> L3
    L3 --> L4
    
    style L4 fill:#ff6b6b,stroke:#c92a2a,color:#fff
```

### Quy Định Áp Dụng

| Loại Giao Dịch     | Giá Trị        | Cấp Độ Bắt Buộc |
| ------------------ | -------------- | --------------- |
| Truy vấn thông tin | Bất kỳ         | Level 2         |
| Chuyển tiền        | < 10 triệu VND | Level 3         |
| Chuyển tiền        | ≥ 10 triệu VND | Level 4         |
| Mở thẻ tín dụng    | Bất kỳ         | Level 4         |
| Thay đổi hạn mức   | Bất kỳ         | Level 4         |

## NFC CCCD Verification Flow

```mermaid
sequenceDiagram
    participant User as User
    participant App as TPP App
    participant SDK as NFC SDK
    participant API as Bank API
    participant MPS as Ministry of Public Security
    
    User->>App: Initiate High-Value Transaction
    App->>User: Request NFC Scan
    User->>SDK: Tap CCCD to Phone
    SDK->>SDK: Read Chip Data<br/>(DG1, DG2, SOD)
    SDK->>SDK: Perform Active Authentication
    SDK-->>App: Chip Data + Signature
    
    App->>API: POST /ekyc/nfc-verify<br/>+ Chip Data
    API->>API: Verify Signature with<br/>MPS Root Certificate
    API->>MPS: Validate Certificate Chain
    MPS-->>API: Certificate Valid
    API->>API: Extract Personal Info<br/>+ Face Image
    API->>API: Compare with Existing CIF
    API-->>App: Verification Result
    
    alt Verification Success
        App->>API: Proceed with Transaction
    else Verification Failed
        App->>User: Show Error & Retry
    end
```

## Token Management

### Access Token Lifecycle

```mermaid
graph LR
    Issue[Token Issued] --> Active[Active<br/>15 mins]
    Active --> Expired[Expired]
    Active --> Revoked[Revoked]
    Expired --> Refresh[Refresh Token Used]
    Refresh --> Issue
    Revoked --> End[End]
    Expired --> End
```

### Token Scopes

| Scope                   | Mô Tả                   | Thời Hạn Tối Đa |
| ----------------------- | ----------------------- | --------------- |
| `accounts.read`         | Đọc danh sách tài khoản | 180 ngày        |
| `accounts.balance.read` | Đọc số dư               | 180 ngày        |
| `transactions.read`     | Đọc lịch sử giao dịch   | 180 ngày        |
| `payments.write`        | Khởi tạo thanh toán     | 1 lần sử dụng   |
| `cards.read`            | Đọc thông tin thẻ       | 180 ngày        |
| `cards.write`           | Quản lý thẻ             | 90 ngày         |

## Security Best Practices

### 1. Transport Security
- **TLS 1.3** bắt buộc cho tất cả connections
- **Certificate Pinning** cho mobile apps
- **HSTS** (HTTP Strict Transport Security) enabled

### 2. API Security
- **Rate Limiting**: 100 req/min per client
- **IP Whitelisting** cho production environment
- **Request Signing** (JWS) cho tất cả mutation operations

### 3. Data Protection
- **Encryption at Rest**: AES-256
- **Encryption in Transit**: TLS 1.3
- **PII Masking** trong logs và responses
- **Data Retention**: 
  - Transaction logs: 5 năm
  - Access logs: 3 tháng online, 1 năm offline

### 4. Incident Response
- **Real-time Monitoring** cho suspicious activities
- **Automated Alerts** cho failed authentication attempts
- **Breach Notification** trong vòng 72 giờ

## Compliance Checklist

- [ ] OAuth 2.0 + PKCE implementation
- [ ] FAPI Security Profile compliance
- [ ] JWS signing cho financial transactions
- [ ] Consent management system
- [ ] NFC CCCD verification (QĐ 2345)
- [ ] Token expiry enforcement (180 days max)
- [ ] Audit logging (3 months + 1 year backup)
- [ ] HSM integration cho key management
- [ ] mTLS cho internal services
- [ ] Penetration testing quarterly

## Tài Liệu Tham Khảo
- RFC 6749: OAuth 2.0 Authorization Framework
- RFC 7636: PKCE for OAuth 2.0
- RFC 7515: JSON Web Signature (JWS)
- FAPI Security Profile 1.0
- Quyết định 2345/QĐ-NHNN
- Thông tư 64/2024/TT-NHNN
