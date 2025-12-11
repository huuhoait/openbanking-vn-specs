# Dịch Vụ Thẻ & Tokenization

## Tổng Quan

Nhóm API quản lý vòng đời thẻ (Card Lifecycle) và tích hợp với các ví điện tử (Apple Pay, Google Pay, Samsung Pay) thông qua Push Provisioning.

## Kiến Trúc Card Services

```mermaid
graph TB
    subgraph "TPP/Wallet Layer"
        TPP[TPP Application]
        ApplePay[Apple Wallet]
        GooglePay[Google Pay]
        SamsungPay[Samsung Pay]
    end
    
    subgraph "API Layer"
        CardAPI[Card Management API]
        TokenAPI[Tokenization API]
    end
    
    subgraph "Card Service"
        Issuance[Card Issuance Service]
        Lifecycle[Lifecycle Management]
        TokenMgmt[Token Management]
    end
    
    subgraph "Token Service Providers"
        VTS[Visa Token Service]
        MDES[Mastercard MDES]
    end
    
    subgraph "Core Systems"
        CardCore[Card Management System]
        HSM[Hardware Security Module]
    end
    
    TPP --> CardAPI
    ApplePay --> TokenAPI
    GooglePay --> TokenAPI
    SamsungPay --> TokenAPI
    
    CardAPI --> Issuance
    CardAPI --> Lifecycle
    TokenAPI --> TokenMgmt
    
    TokenMgmt --> VTS
    TokenMgmt --> MDES
    
    Issuance --> CardCore
    Lifecycle --> CardCore
    TokenMgmt --> HSM
    CardCore --> HSM
```

## Card Issuance Flow

```mermaid
sequenceDiagram
    participant User as End User
    participant TPP as TPP App
    participant API as Card API
    participant eKYC as eKYC Service
    participant Credit as Credit Scoring
    participant CardCore as Card Core System
    participant HSM as HSM
    
    User->>TPP: Request New Card
    TPP->>API: POST /cards/issuance<br/>+ eKYC Reference
    
    API->>eKYC: Validate eKYC Status
    eKYC-->>API: eKYC Verified
    
    API->>Credit: Check Credit Score
    Credit-->>API: Score + Approved Limit
    
    alt Credit Approved
        API->>CardCore: Create Card Record
        CardCore->>HSM: Generate Card Number (PAN)
        HSM-->>CardCore: Encrypted PAN
        CardCore->>HSM: Generate CVV
        HSM-->>CardCore: CVV
        CardCore->>CardCore: Set Expiry Date
        CardCore-->>API: Card Details
        
        API->>API: Create Virtual Card
        API-->>TPP: 201 Created<br/>Virtual Card Details
        
        Note over API,CardCore: Physical card production<br/>queued in background
    else Credit Rejected
        API-->>TPP: 403 Forbidden<br/>Credit check failed
    end
```

## Card Lifecycle Management

```mermaid
stateDiagram-v2
    [*] --> Issued: Card created
    Issued --> Active: Activated by user
    Issued --> Expired: Not activated (30 days)
    
    Active --> Locked: User locks card
    Active --> Blocked: Fraud detected
    Active --> Expired: Expiry date reached
    
    Locked --> Active: User unlocks
    Locked --> Blocked: Admin blocks
    
    Blocked --> Active: Admin unblocks
    
    Active --> Closed: User closes account
    Blocked --> Closed: Permanent closure
    Expired --> Closed: Not renewed
    
    Closed --> [*]
```

## API Endpoints

### 1. Card Issuance

#### POST /v1/cards/issuance

**Request:**
```json
{
  "Data": {
    "ProductType": "VISA_PLATINUM",
    "DeliveryAddress": {
      "AddressLine": "123 Nguyen Hue",
      "City": "Ho Chi Minh",
      "PostCode": "700000",
      "Country": "VN"
    },
    "eKYCReferenceId": "ekyc-ref-12345",
    "LinkedAccount": "1234567890"
  }
}
```

**Response:**
```json
{
  "Data": {
    "CardId": "card-abc123",
    "CardType": "Virtual",
    "ProductType": "VISA_PLATINUM",
    "Status": "Active",
    "MaskedPAN": "4532********1234",
    "ExpiryDate": "12/27",
    "CardholderName": "NGUYEN VAN A",
    "IssuedDate": "2024-12-10T18:00:00+07:00",
    "VirtualCardDetails": {
      "PAN": "4532123456781234",
      "CVV": "123",
      "ExpiryMonth": "12",
      "ExpiryYear": "2027"
    }
  },
  "Links": {
    "Self": "https://api.bank.vn/v1/cards/card-abc123"
  }
}
```

### 2. Card Lock/Unlock

#### PUT /v1/cards/{CardId}/lock

```mermaid
sequenceDiagram
    participant User as User
    participant TPP as TPP App
    participant API as Card API
    participant CardCore as Card Core
    participant Switch as Card Switch
    
    User->>TPP: Lock Card (Lost/Stolen)
    TPP->>API: PUT /cards/{id}/lock<br/>Reason: LOST
    
    API->>CardCore: Update Card Status
    CardCore->>Switch: Block Card on Network
    Switch-->>CardCore: Blocked
    CardCore-->>API: Status Updated
    
    API->>API: Send Push Notification
    API-->>TPP: 200 OK
    TPP-->>User: Card Locked Successfully
    
    Note over Switch: All transactions<br/>will be declined
```

**Request:**
```json
{
  "Reason": "LOST",
  "Comment": "Card lost at shopping mall"
}
```

**Response:**
```json
{
  "Data": {
    "CardId": "card-abc123",
    "Status": "Locked",
    "LockReason": "LOST",
    "StatusUpdateDateTime": "2024-12-10T18:30:00+07:00"
  }
}
```

### 3. PIN Management

#### PUT /v1/cards/{CardId}/pin

```mermaid
graph TB
    Request[PIN Change Request]
    
    Request --> Validate{Validate Current PIN}
    Validate -->|Invalid| Error[401 Invalid PIN]
    Validate -->|Valid| CheckNew{Validate New PIN}
    
    CheckNew -->|Weak| Error2[400 PIN too weak]
    CheckNew -->|Same as old| Error3[400 PIN must be different]
    CheckNew -->|Valid| Encrypt[Encrypt PIN Block<br/>ISO 9564 Format]
    
    Encrypt --> HSM[Store in HSM]
    HSM --> Success[200 OK]
```

**PIN Block Format (ISO 9564-1):**
```
Format 0: PIN + PAN
Clear PIN: 1234
PAN: 4532123456781234
PIN Block: 0412FFFFFFFF (XOR with PAN)
Encrypted with HSM key
```

**Request:**
```json
{
  "CurrentPIN": "encrypted_current_pin",
  "NewPIN": "encrypted_new_pin",
  "EncryptionMethod": "RSA_OAEP"
}
```

## Push Provisioning (Tokenization)

### Architecture

```mermaid
graph TB
    subgraph "User Device"
        Wallet[Digital Wallet<br/>Apple/Google/Samsung]
    end
    
    subgraph "Bank Systems"
        API[Push Provisioning API]
        TokenVault[Token Vault]
        CardCore[Card Core]
    end
    
    subgraph "Token Service Provider"
        TSP[Visa VTS / MC MDES]
    end
    
    subgraph "Payment Network"
        Network[Visa/Mastercard Network]
    end
    
    Wallet -->|1. Request Provisioning| API
    API -->|2. Validate Card| CardCore
    CardCore -->|3. Card Valid| API
    API -->|4. Request Token| TSP
    TSP -->|5. Generate DPAN| TSP
    TSP -->|6. Return Token| API
    API -->|7. Encrypt Token| TokenVault
    TokenVault -->|8. Return OPC| API
    API -->|9. Push to Wallet| Wallet
    
    Wallet -.->|Transaction| Network
    Network -.->|Route via DPAN| TSP
    TSP -.->|Detokenize to PAN| Network
```

### Push Provisioning Flow

```mermaid
sequenceDiagram
    participant User as User
    participant Wallet as Digital Wallet
    participant Bank as Bank API
    participant TSP as Token Service Provider
    participant CardCore as Card Core
    
    User->>Wallet: Add Card to Wallet
    Wallet->>Bank: POST /tokenization/provision<br/>+ Card Reference
    
    Bank->>CardCore: Validate Card Status
    CardCore-->>Bank: Card Active
    
    Bank->>Bank: Generate Activation Code
    Bank->>User: Send OTP via SMS
    User->>Wallet: Enter OTP
    Wallet->>Bank: Verify OTP
    
    Bank->>TSP: Request Token Provisioning<br/>+ Card Details
    TSP->>TSP: Generate DPAN (Token)
    TSP->>TSP: Create Token Cryptogram
    TSP-->>Bank: Token + Cryptogram
    
    Bank->>Bank: Encrypt Token (OPC)
    Bank-->>Wallet: Push OPC to Wallet
    Wallet->>Wallet: Store Token Securely
    Wallet-->>User: Card Added Successfully
    
    Note over Wallet,TSP: Card ready for<br/>contactless payments
```

### API Endpoint: Push Provisioning

#### POST /v1/tokenization/provision

**Request:**
```json
{
  "CardId": "card-abc123",
  "WalletProvider": "APPLE_PAY",
  "DeviceInfo": {
    "DeviceId": "device-xyz789",
    "DeviceName": "iPhone 15 Pro",
    "OSVersion": "iOS 17.2",
    "WalletAccountId": "wallet-acc-456"
  },
  "Certificates": {
    "LeafCertificate": "-----BEGIN CERTIFICATE-----...",
    "SubCACertificate": "-----BEGIN CERTIFICATE-----..."
  },
  "Nonce": "random-nonce-12345",
  "NonceSignature": "signature-of-nonce"
}
```

**Response:**
```json
{
  "Data": {
    "TokenReferenceId": "token-ref-12345",
    "ActivationData": {
      "EncryptedPassData": "encrypted_opaque_payment_card",
      "EphemeralPublicKey": "BFz...public_key",
      "ActivationMethod": "SMS_OTP"
    },
    "TokenStatus": "ACTIVE",
    "DPAN": "4900********5678",
    "ExpiryDate": "12/27"
  }
}
```

## Token Lifecycle Management

```mermaid
stateDiagram-v2
    [*] --> Requested: Provision request
    Requested --> Active: OTP verified
    Requested --> Declined: Verification failed
    
    Active --> Suspended: Card locked
    Active --> Deleted: User removes from wallet
    Active --> Expired: Token expired
    
    Suspended --> Active: Card unlocked
    Suspended --> Deleted: Permanent removal
    
    Deleted --> [*]
    Declined --> [*]
    Expired --> [*]
```

## Token Transaction Flow

```mermaid
sequenceDiagram
    participant Merchant as Merchant Terminal
    participant Network as Payment Network
    participant TSP as Token Service Provider
    participant Bank as Issuer Bank
    participant CardCore as Card Core
    
    Merchant->>Network: Authorization Request<br/>DPAN: 4900****5678
    Network->>TSP: Route to TSP
    TSP->>TSP: Detokenize DPAN → PAN
    TSP->>Bank: Authorization<br/>PAN: 4532****1234
    
    Bank->>CardCore: Check Balance & Limits
    CardCore-->>Bank: Approved
    Bank-->>TSP: Authorization Approved
    TSP-->>Network: Approved
    Network-->>Merchant: Approved
    
    Note over Merchant: Transaction Complete<br/>PAN never exposed
```

## Card Controls & Limits

### Spending Controls

```mermaid
graph TB
    Transaction[Card Transaction]
    
    Transaction --> CheckStatus{Card Status}
    CheckStatus -->|Locked/Blocked| Decline1[Decline: Card not active]
    CheckStatus -->|Active| CheckLimit{Daily Limit}
    
    CheckLimit -->|Exceeded| Decline2[Decline: Limit exceeded]
    CheckLimit -->|OK| CheckMCC{Merchant Category}
    
    CheckMCC -->|Blocked MCC| Decline3[Decline: Merchant blocked]
    CheckMCC -->|Allowed| CheckLocation{Location Check}
    
    CheckLocation -->|Suspicious| StepUp[Require 3DS]
    CheckLocation -->|OK| CheckBalance{Available Balance}
    
    CheckBalance -->|Insufficient| Decline4[Decline: Insufficient funds]
    CheckBalance -->|OK| Approve[Approve Transaction]
    
    StepUp -->|Verified| Approve
    StepUp -->|Failed| Decline5[Decline: 3DS failed]
```

### Control Settings API

#### PUT /v1/cards/{CardId}/controls

```json
{
  "SpendingLimits": {
    "DailyLimit": {
      "Amount": "10000000",
      "Currency": "VND"
    },
    "MonthlyLimit": {
      "Amount": "50000000",
      "Currency": "VND"
    },
    "PerTransactionLimit": {
      "Amount": "5000000",
      "Currency": "VND"
    }
  },
  "AllowedMerchantCategories": [
    "5411",
    "5812",
    "5999"
  ],
  "BlockedMerchantCategories": [
    "7995",
    "9754"
  ],
  "AllowedCountries": ["VN", "TH", "SG"],
  "OnlineTransactions": true,
  "ContactlessTransactions": true,
  "ATMWithdrawals": true
}
```

## 3D Secure Integration

```mermaid
sequenceDiagram
    participant User as Cardholder
    participant Merchant as Merchant
    participant ACS as Bank ACS
    participant Bank as Issuer Bank
    
    User->>Merchant: Enter Card Details
    Merchant->>ACS: 3DS Authentication Request
    
    ACS->>Bank: Verify Card & Risk
    Bank-->>ACS: Risk Score
    
    alt Low Risk (Frictionless)
        ACS-->>Merchant: Authentication Success
    else High Risk (Challenge)
        ACS->>User: Challenge (OTP/Biometric)
        User->>ACS: Submit Challenge Response
        ACS->>Bank: Verify Response
        Bank-->>ACS: Verified
        ACS-->>Merchant: Authentication Success
    end
    
    Merchant->>Bank: Authorization Request<br/>+ 3DS Cryptogram
    Bank-->>Merchant: Approved
```

## Virtual Card Management

### Instant Virtual Card

```mermaid
graph LR
    subgraph "Use Cases"
        Online[Online Shopping]
        Subscription[Subscription Services]
        Trial[Free Trials]
        Temp[Temporary Merchants]
    end
    
    subgraph "Features"
        Instant[Instant Issuance<br/>< 1 second]
        Disposable[Single-use or<br/>Time-limited]
        Limit[Custom Limits]
        Control[Full Control via API]
    end
    
    Online --> Instant
    Subscription --> Disposable
    Trial --> Limit
    Temp --> Control
```

#### POST /v1/cards/virtual

**Request:**
```json
{
  "CardType": "SINGLE_USE",
  "LinkedAccount": "1234567890",
  "SpendingLimit": {
    "Amount": "1000000",
    "Currency": "VND"
  },
  "ValidUntil": "2024-12-31T23:59:59+07:00",
  "Purpose": "Online shopping at Shopee"
}
```

**Response:**
```json
{
  "Data": {
    "CardId": "vcard-temp-123",
    "PAN": "4532123456789999",
    "CVV": "999",
    "ExpiryDate": "12/24",
    "Status": "Active",
    "CardType": "SINGLE_USE",
    "RemainingLimit": {
      "Amount": "1000000",
      "Currency": "VND"
    }
  }
}
```

## Security Best Practices

### PCI DSS Compliance

```mermaid
graph TB
    subgraph "Data Protection"
        Encrypt[Encrypt PAN at Rest<br/>AES-256]
        Tokenize[Tokenize for Storage<br/>Never store CVV]
        HSM_Key[Keys in HSM Only]
    end
    
    subgraph "Access Control"
        RBAC[Role-Based Access]
        MFA[Multi-Factor Auth]
        Audit[Comprehensive Logging]
    end
    
    subgraph "Network Security"
        Segment[Network Segmentation]
        Firewall[Firewall Rules]
        IDS[Intrusion Detection]
    end
    
    subgraph "Compliance"
        PCI[PCI DSS Level 1]
        Penetration[Quarterly Pen Tests]
        Scan[Vulnerability Scans]
    end
```

### Sensitive Data Handling

**Never Log:**
- Full PAN (Primary Account Number)
- CVV/CVC
- PIN or PIN Block (unencrypted)
- Magnetic stripe data
- CAV/CID/CVV2

**Always Mask:**
```javascript
function maskPAN(pan) {
  return pan.substring(0, 6) + '*'.repeat(pan.length - 10) + pan.substring(pan.length - 4);
}
// 4532123456781234 → 453212******1234
```

## Monitoring & Alerts

### Real-time Fraud Detection

```mermaid
graph TB
    Transaction[Card Transaction]
    
    Transaction --> Rules{Fraud Rules}
    
    Rules --> Velocity{Velocity Check<br/>5 txns/5 mins}
    Rules --> Amount{Unusual Amount<br/>vs. History}
    Rules --> Location{Location Jump<br/>Impossible travel}
    Rules --> MCC{High-Risk MCC}
    
    Velocity -->|Triggered| Alert[Send Alert]
    Amount -->|Triggered| Alert
    Location -->|Triggered| Alert
    MCC -->|Triggered| Alert
    
    Alert --> Block{Auto Block?}
    Block -->|Yes| LockCard[Lock Card]
    Block -->|No| Notify[Notify User]
    
    Notify --> UserConfirm{User Confirms}
    UserConfirm -->|Fraud| LockCard
    UserConfirm -->|Legitimate| Whitelist[Add to Whitelist]
```

## Compliance Checklist

- [ ] PCI DSS Level 1 certification
- [ ] HSM for key management
- [ ] PAN encryption at rest (AES-256)
- [ ] TLS 1.3 for data in transit
- [ ] No CVV storage (ever)
- [ ] 3D Secure 2.0 implementation
- [ ] Token lifecycle management
- [ ] Fraud detection rules
- [ ] Real-time transaction monitoring
- [ ] Audit logging (all card operations)
- [ ] Quarterly penetration testing
- [ ] Vulnerability scanning
- [ ] Incident response plan
- [ ] Data breach notification procedures

## Tài Liệu Tham Khảo
- PCI DSS v4.0 Requirements
- EMV 3D Secure 2.0 Specification
- Visa Token Service (VTS) Integration Guide
- Mastercard MDES API Reference
- Apple Pay Push Provisioning Guide
- Google Pay API Documentation
- ISO 9564 - PIN Management
- ISO 8583 - Card Transaction Messages
