# Dịch Vụ Thẻ & Tokenization (Card Services & Token Provisioning)

> **Tuân thủ:** Thông tư 64/2024/TT-NHNN | ISO/IEC 11568 | EMV Payment Tokenization | PCI DSS 4.0

## Tổng Quan

Nhóm API cho phép TPP phát hành thẻ, quản lý vòng đời thẻ và tokenization cho thanh toán không tiếp xúc (NFC/Mobile Wallet).

### Phạm Vi Dịch Vụ

1. **Card Issuance**: Phát hành thẻ tín dụng/ghi nợ
2. **Card Lifecycle**: Kích hoạt, khóa, mở khóa, hủy thẻ
3. **Card Tokenization**: Chuyển đổi PAN sang Token
4. **NFC Push Provisioning**: Đẩy thẻ lên Apple Pay, Google Pay, Samsung Pay
5. **Card Controls**: Giới hạn giao dịch, khu vực địa lý

## Kiến Trúc Card Services

```mermaid
graph TB
    subgraph "TPP Layer"
        TPP[TPP Application]
    end
    
    subgraph "API Gateway + Security"
        Gateway[API Gateway]
        JWS[JWS Verification]
        mTLS[mTLS Authentication]
    end
    
    subgraph "Card Services"
        Issuance[Card Issuance Service]
        Lifecycle[Lifecycle Management]
        Tokenization[Tokenization Service]
        Provisioning[NFC Provisioning]
    end
    
    subgraph "Token Service Provider"
        TSP[Token Service Provider<br/>Visa/Mastercard]
        HSM[Hardware Security Module]
    end
    
    subgraph "Card System"
        CardCore[Card Management System]
        CardDB[(Card Database)]
    end
    
    subgraph "Mobile Wallets"
        ApplePay[Apple Pay]
        GooglePay[Google Pay]
        SamsungPay[Samsung Pay]
    end
    
    TPP --> Gateway
    Gateway --> JWS
    JWS --> mTLS
    
    mTLS --> Issuance
    mTLS --> Lifecycle
    mTLS --> Tokenization
    mTLS --> Provisioning
    
    Issuance --> CardCore
    Lifecycle --> CardCore
    Tokenization --> TSP
    Tokenization --> HSM
    Provisioning --> TSP
    
    CardCore --> CardDB
    
    Provisioning --> ApplePay
    Provisioning --> GooglePay
    Provisioning --> SamsungPay
    
    style HSM fill:#f44336,stroke:#c62828,color:#fff
    style TSP fill:#ff9800,stroke:#e65100
```

## API Endpoints

### 1. Card Issuance

#### POST /v1/cards/issue

Phát hành thẻ mới cho khách hàng.

```mermaid
sequenceDiagram
    participant TPP
    participant Gateway
    participant CardSvc as Card Service
    participant Consent as Consent Service
    participant CardCore as Card System
    participant TSP as Token Provider
    
    TPP->>Gateway: POST /cards/issue<br/>+ JWS Signature
    Gateway->>Gateway: Verify JWS
    Gateway->>CardSvc: Forward Request
    
    CardSvc->>Consent: Validate Consent<br/>Scope: cards:issue
    Consent-->>CardSvc: Consent Valid
    
    CardSvc->>CardSvc: Validate Customer<br/>Credit Check
    
    alt Approved
        CardSvc->>CardCore: Create Card Record
        CardCore->>TSP: Generate PAN
        TSP-->>CardCore: PAN + CVV
        CardCore->>CardCore: Encrypt PAN
        CardCore-->>CardSvc: Card Created
        CardSvc-->>TPP: 201 Created<br/>CardId (masked)
    else Rejected
        CardSvc-->>TPP: 403 Forbidden<br/>Reason: Credit check failed
    end
```

**Request:**
```json
{
  "CustomerId": "cust-12345",
  "ProductCode": "VISA_CREDIT_PLATINUM",
  "CardType": "Virtual",
  "EmbossName": "NGUYEN VAN A",
  "DeliveryAddress": {
    "AddressLine": "123 Nguyen Hue",
    "City": "Ho Chi Minh",
    "PostalCode": "700000"
  },
  "CreditLimit": {
    "Amount": "50000000",
    "Currency": "VND"
  }
}
```

**Response:**
```json
{
  "CardId": "card-abc123",
  "MaskedPAN": "4111********1111",
  "CardType": "Virtual",
  "Status": "Inactive",
  "ExpiryDate": "12/27",
  "CardProduct": "VISA_CREDIT_PLATINUM",
  "CreditLimit": {
    "Amount": "50000000",
    "Currency": "VND"
  },
  "IssuedDate": "2025-12-15T10:30:00+07:00"
}
```

### 2. Card Activation

#### POST /v1/cards/{CardId}/activate

Kích hoạt thẻ sau khi khách hàng nhận được.

```mermaid
stateDiagram-v2
    [*] --> Inactive: Card Issued
    Inactive --> PendingActivation: OTP Sent
    PendingActivation --> Active: OTP Verified
    PendingActivation --> Inactive: OTP Failed (3 times)
    
    Active --> Blocked: Fraud Detection
    Active --> Suspended: User Request
    Suspended --> Active: User Unblock
    
    Active --> Closed: Card Expired
    Blocked --> Closed: Permanent Block
    
    Closed --> [*]
```

**Request:**
```json
{
  "ActivationCode": "123456",
  "CVV": "123",
  "PIN": "encrypted_pin_data"
}
```

### 3. Card Tokenization

#### POST /v1/cards/{CardId}/tokens

Tạo token cho thẻ để sử dụng trong giao dịch không tiếp xúc.

```mermaid
graph TB
    PAN[PAN: 4111-1111-1111-1111]
    
    PAN --> Tokenize[Tokenization Engine]
    Tokenize --> Token[Token: 4900-0000-0000-1234]
    
    Token --> Store[Token Vault<br/>HSM Protected]
    
    subgraph "Token Metadata"
        TokenID[Token ID]
        TokenStatus[Status: Active]
        TokenExpiry[Expiry: 12/27]
        DeviceID[Device: iPhone 12]
    end
    
    Token --> TokenID
    Token --> TokenStatus
    Token --> TokenExpiry
    Token --> DeviceID
    
    style PAN fill:#ff6b6b,stroke:#c62828,color:#fff
    style Token fill:#4caf50,stroke:#2e7d32,color:#fff
    style Store fill:#ffa726,stroke:#e65100
```

**Key Properties:**

| Property | PAN (Original) | Token (Substitute) |
|----------|----------------|---------------------|
| **Format** | 16 digits | 16 digits (same format) |
| **Validity** | Card lifetime | Per-device, time-limited |
| **Storage** | HSM only | Can be stored |
| **Reversible** | N/A | Yes (with TSP key) |
| **Domain** | Universal | Device/merchant specific |

**Response:**
```json
{
  "TokenId": "token-xyz789",
  "TokenizedPAN": "4900000000001234",
  "TokenExpiry": "12/27",
  "TokenType": "DEVICE",
  "DeviceId": "device-iphone12-001",
  "TokenStatus": "Active",
  "TokenRequestorId": "40010030273"
}
```

### 4. NFC Push Provisioning

#### POST /v1/cards/{CardId}/provision

Đẩy thẻ lên ví điện tử (Apple Pay, Google Pay).

```mermaid
sequenceDiagram
    participant User
    participant Wallet as Mobile Wallet
    participant TPP
    participant CardSvc as Card Service
    participant TSP as Token Service Provider
    participant Issuer as Issuer Bank
    
    User->>Wallet: Add Card to Wallet
    Wallet->>TPP: Request Provisioning
    TPP->>CardSvc: POST /cards/{id}/provision
    
    CardSvc->>CardSvc: Validate Card<br/>Check eligibility
    
    CardSvc->>TSP: Request Token<br/>+ Device fingerprint
    TSP->>TSP: Generate Token
    TSP->>TSP: Create DPAN
    
    TSP->>Issuer: Request Authorization<br/>Yellow Path
    Issuer->>User: Send OTP via SMS
    User->>Issuer: Enter OTP
    Issuer->>TSP: Authorization Approved
    
    TSP-->>CardSvc: Token + Cryptogram
    CardSvc-->>TPP: Provisioning Data
    TPP-->>Wallet: Push to Wallet
    Wallet->>Wallet: Store Token securely<br/>in Secure Element
    
    Wallet-->>User: Card Added Successfully
```

**Request:**
```json
{
  "WalletProvider": "APPLE_PAY",
  "DeviceId": "A1B2C3D4E5F6",
  "DeviceType": "iPhone",
  "DeviceName": "iPhone của Tôi",
  "OSVersion": "iOS 17.2",
  "WalletAccountId": "wallet-acc-123"
}
```

**Response:**
```json
{
  "ProvisioningId": "prov-abc123",
  "Status": "Pending",
  "OTPRequired": true,
  "OTPDelivery": "SMS",
  "ActivationData": "encrypted_activation_data",
  "OpaquePaymentCard": "encrypted_token_data"
}
```

### 5. Card Lifecycle Management

#### PATCH /v1/cards/{CardId}/status

Quản lý trạng thái thẻ (khóa, mở khóa, hủy).

**Request:**
```json
{
  "Action": "BLOCK",
  "Reason": "LOST",
  "TemporaryBlock": false,
  "ReasonCode": "01"
}
```

**Actions:**
- `ACTIVATE`: Kích hoạt thẻ
- `BLOCK`: Khóa thẻ (tạm thời hoặc vĩnh viễn)
- `UNBLOCK`: Mở khóa thẻ
- `CLOSE`: Đóng thẻ (không thể hoàn tác)

### 6. Card Controls

#### PUT /v1/cards/{CardId}/controls

Thiết lập giới hạn và kiểm soát sử dụng thẻ.

```mermaid
graph TB
    subgraph "Card Controls"
        Limit[Transaction Limits<br/>• Daily limit<br/>• Per-transaction limit<br/>• Monthly limit]
        
        Geo[Geographic Controls<br/>• Allowed countries<br/>• Blocked regions<br/>• Domestic only]
        
        MCC[Merchant Controls<br/>• Allowed MCCs<br/>• Blocked categories<br/>• ATM only]
        
        Channel[Channel Controls<br/>• E-commerce: ON/OFF<br/>• ATM: ON/OFF<br/>• POS: ON/OFF<br/>• Contactless: ON/OFF]
    end
    
    Card[Card: 4111-****-1111] --> Limit
    Card --> Geo
    Card --> MCC
    Card --> Channel
    
    style Card fill:#64b5f6,stroke:#1565c0
```

**Request:**
```json
{
  "DailyLimit": {
    "Amount": "10000000",
    "Currency": "VND"
  },
  "PerTransactionLimit": {
    "Amount": "5000000",
    "Currency": "VND"
  },
  "AllowedCountries": ["VN"],
  "AllowedMCC": ["5411", "5812", "5999"],
  "ChannelControls": {
    "Ecommerce": true,
    "ATM": true,
    "POS": true,
    "Contactless": true
  }
}
```

## Security Architecture

### EMV Tokenization

```mermaid
graph LR
    subgraph "Card Data"
        PAN[Primary Account Number<br/>16 digits]
        CVV[CVV: 3 digits]
        Expiry[Expiry: MM/YY]
    end
    
    subgraph "Tokenization"
        TSP[Token Service Provider]
        HSM[Hardware Security Module]
        Vault[Token Vault]
    end
    
    subgraph "Token Output"
        DPAN[Device PAN<br/>Token: 16 digits]
        TokenCVV[Token CVV]
        Cryptogram[Dynamic Cryptogram<br/>Changes per transaction]
    end
    
    PAN --> TSP
    CVV --> TSP
    Expiry --> TSP
    
    TSP --> HSM
    HSM --> Vault
    
    Vault --> DPAN
    Vault --> TokenCVV
    HSM --> Cryptogram
    
    style PAN fill:#f44336,color:#fff
    style DPAN fill:#4caf50,color:#fff
    style HSM fill:#ff9800
```

### Key Management

**Encryption Keys:**

| Key Type | Purpose | Storage | Rotation |
|----------|---------|---------|----------|
| **KEK** (Key Encryption Key) | Encrypt other keys | HSM | 1 year |
| **DEK** (Data Encryption Key) | Encrypt PAN | HSM | 90 days |
| **TMK** (Token Master Key) | Generate tokens | HSM | 2 years |
| **CVK** (Card Verification Key) | Generate CVV | HSM | Never (fixed) |

### PCI DSS Compliance

```mermaid
graph TB
    subgraph "PCI DSS Requirements"
        R1[Requirement 3<br/>Protect Stored Cardholder Data]
        R2[Requirement 4<br/>Encrypt Transmission]
        R3[Requirement 8<br/>Strong Access Control]
        R4[Requirement 10<br/>Log All Access]
    end
    
    subgraph "Implementation"
        I1[HSM for PAN Storage]
        I2[TLS 1.3 + mTLS]
        I3[MFA + RBAC]
        I4[Audit Logs 7 years]
    end
    
    R1 --> I1
    R2 --> I2
    R3 --> I3
    R4 --> I4
    
    style R1 fill:#f44336,color:#fff
    style R2 fill:#ff9800
    style R3 fill:#ffc107
    style R4 fill:#4caf50,color:#fff
```

**Key Controls:**

1. ✅ PAN never stored in clear text
2. ✅ PAN truncated in logs (first 6 + last 4)
3. ✅ CVV never stored after authorization
4. ✅ Strong cryptography (AES-256)
5. ✅ Regular penetration testing
6. ✅ Network segmentation (card data isolated)

## Token Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Requested: Provisioning Request
    Requested --> Pending: OTP Sent
    Pending --> Active: OTP Verified
    Pending --> Declined: OTP Failed
    
    Active --> Suspended: Suspicious Activity
    Active --> Inactive: Device Lost
    Suspended --> Active: Resumed
    
    Inactive --> Deleted: 90 Days Passed
    Active --> Deleted: User Removed Card
    
    Declined --> [*]
    Deleted --> [*]
    
    note right of Active
        Token valid for transactions
        Cryptogram generated per txn
    end note
```

## Transaction Flow with Token

```mermaid
sequenceDiagram
    participant User
    participant Device as Mobile Device<br/>(Secure Element)
    participant POS as POS Terminal
    participant Acquirer
    participant Network as Card Network
    participant TSP as Token Service
    participant Issuer
    
    User->>Device: Tap to Pay (NFC)
    Device->>Device: Generate Cryptogram<br/>Using Token
    Device->>POS: Token + Cryptogram
    
    POS->>Acquirer: Authorization Request<br/>Token-based
    Acquirer->>Network: Forward Request
    Network->>TSP: De-tokenize Request
    
    TSP->>TSP: Validate Cryptogram
    TSP->>TSP: Retrieve Real PAN
    TSP->>Network: Return PAN
    
    Network->>Issuer: Authorization with PAN
    Issuer->>Issuer: Validate + Check Funds
    Issuer-->>Network: Approved
    
    Network-->>Acquirer: Approved
    Acquirer-->>POS: Approved
    POS-->>Device: Transaction Success
    Device-->>User: ✓ Payment Successful
```

## Error Handling

| Error Code | Mô Tả | Hành Động |
|------------|-------|-----------|
| `CARD_NOT_ELIGIBLE` | Thẻ không đủ điều kiện tokenization | Kiểm tra loại thẻ |
| `DEVICE_NOT_SUPPORTED` | Thiết bị không hỗ trợ | Nâng cấp OS |
| `OTP_EXPIRED` | OTP hết hạn | Gửi OTP mới |
| `PROVISIONING_LIMIT_EXCEEDED` | Vượt quá số lượng thiết bị | Xóa thiết bị cũ |
| `TOKEN_SUSPENDED` | Token bị tạm ngưng | Liên hệ ngân hàng |
| `CRYPTOGRAM_INVALID` | Cryptogram không hợp lệ | Reprovision token |

## Performance & Scalability

**SLA Targets:**

| Operation | Response Time | Throughput |
|-----------|---------------|------------|
| Card Issuance | < 3s | 100 TPS |
| Tokenization | < 500ms | 500 TPS |
| Provisioning | < 2s | 200 TPS |
| Transaction Auth | < 200ms | 5000 TPS |

## Compliance Checklist

- [ ] PCI DSS 4.0 certified
- [ ] EMV tokenization compliant
- [ ] HSM for all PAN operations
- [ ] No PAN in logs (truncated only)
- [ ] TLS 1.3 + mTLS for all communications
- [ ] Strong Customer Authentication (SCA)
- [ ] Fraud detection system integrated
- [ ] Audit logs retained 7 years
- [ ] Regular security assessments
- [ ] Incident response plan documented

## Tài Liệu Tham Khảo

- **Thông tư 64/2024/TT-NHNN** - Open API Regulations
- **PCI DSS 4.0** - Payment Card Industry Data Security Standard
- **EMV Payment Tokenisation Specification** - EMVCo
- **ISO/IEC 11568** - Key Management
- **Apple Pay Integration Guide** - Apple Developer
- **Google Pay Integration Guide** - Google Developer
- **Samsung Pay Integration Guide** - Samsung Developer

---

**Phiên bản:** 1.0  
**Ngày cập nhật:** 15/12/2025  
**Trạng thái:** Production Ready
