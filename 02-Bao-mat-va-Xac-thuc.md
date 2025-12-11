# Bảo Mật & Xác Thực

## Tổng Quan

Tài liệu này mô tả cơ chế bảo mật và xác thực trong hệ thống Open Banking, tuân thủ Thông tư 64/2024/TT-NHNN và các tiêu chuẩn quốc tế.

### Khung Pháp Lý & Tiêu Chuẩn

**Quy định Việt Nam:**
- Thông tư 64/2024/TT-NHNN: Quy định Open API, bảo mật và quản lý consent.
- Circular 45/2025/TT-NHNN: Xác thực sinh trắc học bắt buộc.
- Circular 50/2024/TT-NHNN: Strong Customer Authentication (SCA) và Multi-Factor Authentication (MFA).
- Nghị định 13/2023/NĐ-CP: Bảo vệ dữ liệu cá nhân.

**Tiêu chuẩn quốc tế:**
- OAuth 2.1: Cải tiến OAuth 2.0 với PKCE bắt buộc.
- FAPI 2.0: Bảo mật cấp tài chính.
- OpenID Connect (OIDC): Xác thực danh tính.
- ISO/IEC 27001:2022: Quản lý bảo mật thông tin.
- PCI DSS 4.0: Bảo mật dữ liệu thẻ.

### Mục Tiêu Bảo Mật

1. Tuân thủ pháp luật đầy đủ.
2. Bảo vệ dữ liệu khách hàng (tính bảo mật, toàn vẹn, khả dụng).
3. Ngăn chối bỏ giao dịch bằng chữ ký số JWS.
4. Áp dụng kiến trúc Zero Trust.
5. Đảm bảo khả năng phục hồi trước tấn công.

## OAuth 2.1 Authorization Code Flow với PKCE & FAPI 2.0

### Tổng Quan

Hệ thống sử dụng OAuth 2.1 kết hợp FAPI 2.0 để bảo mật cấp tài chính. Các cải tiến chính:
- PKCE bắt buộc.
- Loại bỏ Implicit Grant và Password Grant.
- Refresh Token Rotation bắt buộc.
- Ưu tiên xác thực bất đối xứng (JWT, mTLS).

### Luồng Xác Thực với PAR (Pushed Authorization Request)

```mermaid
sequenceDiagram
    participant User as Người dùng
    participant TPP as Ứng dụng TPP
    participant App as App Ngân hàng
    participant AuthServer as Máy chủ Xác thực
    participant ConsentAPI as API Quản lý Đồng ý
    participant ResourceServer as Máy chủ Tài nguyên
    
    TPP->>AuthServer: POST /par (Đẩy yêu cầu ủy quyền)
    AuthServer->>TPP: request_uri (hết hạn 60s)
    
    TPP->>App: Deeplink với request_uri
    App->>AuthServer: GET /authorize
    AuthServer->>User: Màn hình đăng nhập
    User->>AuthServer: Xác thực (sinh trắc học/OTP)
    
    AuthServer->>ConsentAPI: Tạo yêu cầu đồng ý
    ConsentAPI->>AuthServer: ID Đồng ý
    
    AuthServer->>User: Màn hình đồng ý (quyền truy cập, tài khoản, thời hạn tối đa 180 ngày)
    
    alt Người dùng Đồng ý
        User->>AuthServer: Đồng ý + Chọn tài khoản
        AuthServer->>ConsentAPI: Cập nhật trạng thái: ĐÃ ĐỒNG Ý
        AuthServer->>AuthServer: Tạo authorization_code (hết hạn 180s)
        AuthServer->>App: Chuyển hướng với authorization_code
        App->>TPP: Trả về authorization_code
        
        TPP->>AuthServer: POST /token (đổi token)
        AuthServer->>AuthServer: Xác thực code_verifier khớp code_challenge
        AuthServer->>ConsentAPI: Xác thực đồng ý
        ConsentAPI->>AuthServer: ĐÃ ĐỒNG Ý + Quyền + Tài khoản
        
        AuthServer->>AuthServer: Tạo token: access_token (3600s cho AIS), refresh_token (tối đa 180 ngày), id_token
        AuthServer->>ConsentAPI: Cập nhật trạng thái: HOẠT ĐỘNG
        AuthServer->>TPP: access_token + refresh_token + id_token
        
        TPP->>TPP: Tạo DPoP Proof JWT
        TPP->>ResourceServer: Yêu cầu API với DPoP
        ResourceServer->>AuthServer: Kiểm tra token
        AuthServer->>ResourceServer: Token hợp lệ + Quyền + Đồng ý
        ResourceServer->>ConsentAPI: Xác thực đồng ý hoạt động
        ConsentAPI->>ResourceServer: Đồng ý hợp lệ
        ResourceServer->>TPP: Phản hồi API
        
        TPP->>AuthServer: POST /token (làm mới token)
        AuthServer->>AuthServer: Xác thực refresh_token
        AuthServer->>ConsentAPI: Xác thực đồng ý còn hoạt động
        ConsentAPI->>AuthServer: HOẠT ĐỘNG
        
        AuthServer->>AuthServer: Tạo token mới (thu hồi token cũ)
        AuthServer->>TPP: Token mới
        
    else Người dùng Từ chối
        User->>AuthServer: Từ chối
        AuthServer->>ConsentAPI: Cập nhật trạng thái: BỊ TỪ CHỐI
        AuthServer->>App: Chuyển hướng với lỗi
        App->>TPP: Trả về lỗi
    end
```

### Quản Lý Token theo Thông tư 64/2024

| Loại Token             | Thời Hạn            | Sử Dụng                     | Áp Dụng                       |
| ---------------------- | ------------------- | --------------------------- | ----------------------------- |
| Authorization Code     | 180 giây            | Một lần                     | Tất cả flows                  |
| Access Token (INF)     | 3600 giây (1 giờ)   | Nhiều lần                   | Client Credentials Grant      |
| Access Token (AIS)     | 3600 giây (1 giờ)   | Nhiều lần                   | Authorization Code Grant      |
| Access Token (PIS)     | 300 giây (5 phút)   | Một lần                     | Authorization Code Grant      |
| Refresh Token          | Tối đa 180 ngày     | Nhiều lần (với rotation)    | Chỉ AIS                       |
| ConsentId (PIS)        | 300 giây            | Một lần                     | Payment flows                 |
| request_uri (PAR)      | 60 giây             | Một lần                     | PAR flow                      |

**Lưu ý:** Refresh Token không áp dụng cho PIS. Thời hạn đồng ý tối đa 180 ngày.

## Transport Layer Security (TLS)

### TLS 1.3 - Bắt Buộc theo Phụ lục 02

Theo **Phụ lục 02** Thông tư 64/2024, hệ thống **BẮT BUỘC** sử dụng:
- **TLS 1.2 trở lên** (minimum requirement)
- **TLS 1.3** (strongly recommended)

**Lợi ích TLS 1.3:**
- ⚡ **Faster Handshake**: 1-RTT (Round Trip Time) thay vì 2-RTT
- 🔒 **Forward Secrecy**: Mặc định cho tất cả cipher suites
- 🚫 **Loại bỏ cipher suites yếu**: RC4, 3DES, MD5, SHA-1
- 🔐 **Perfect Forward Secrecy (PFS)**: Ephemeral key exchange
- 🛡️ **Encrypted Handshake**: Bảo vệ metadata



### Mutual TLS (mTLS) - Khuyến Nghị

**Áp dụng cho:**
- ✅ Client Credentials Flow (Server-to-Server)
- ✅ Internal microservices communication
- ✅ High-value transactions (optional for Authorization Code Flow)

```mermaid
sequenceDiagram
    participant TPP as TPP Server
    participant Gateway as API Gateway
    participant CA as Certificate Authority
    
    Note over TPP,Gateway: mTLS Handshake
    
    TPP->>Gateway: ClientHello<br/>+ Supported Cipher Suites
    Gateway->>TPP: ServerHello<br/>+ Selected Cipher Suite<br/>+ Server Certificate
    
    TPP->>TPP: Verify Server Certificate:<br/>- Issued by trusted CA<br/>- Not expired<br/>- Hostname matches
    
    Gateway->>TPP: CertificateRequest
    TPP->>Gateway: Client Certificate<br/>+ Certificate Chain
    
    Gateway->>CA: Verify Client Certificate:<br/>- Valid signature<br/>- Not revoked (OCSP/CRL)<br/>- In whitelist
    CA-->>Gateway: Certificate Valid
    
    Gateway->>Gateway: Verify:<br/>- Client DN matches registered TPP<br/>- Certificate not expired<br/>- Key usage correct
    
    TPP->>Gateway: Finished (encrypted)
    Gateway->>TPP: Finished (encrypted)
    
    Note over TPP,Gateway: Secure Channel Established
    
    TPP->>Gateway: Application Data (encrypted)
    Gateway-->>TPP: Application Data (encrypted)
```

## Client Credentials Flow (Server-to-Server)

### Tổng Quan

Áp dụng cho giao tiếp **Server-to-Server** không liên quan đến dữ liệu người dùng cụ thể. Theo **Phụ lục 01** Thông tư 64/2024, flow này được sử dụng cho:

**Use Cases:**
- ✅ Truy vấn thông tin công khai (INF APIs): Lãi suất, Tỷ giá, ATM locations
- ✅ API health check và monitoring
- ✅ Batch processing và system integration
- ✅ Khởi tạo payment request (PIS) - bước đầu tiên

**Enhanced Security Requirements:**
- 🔒 **Mutual TLS (mTLS)** - Bắt buộc theo Phụ lục 02
- 🔒 **Client Assertion using JWT** (RFC 7523) - Khuyến nghị
- 🔒 **IP Whitelisting** - Bắt buộc cho Production
- 🔒 **Rate Limiting** - Nghiêm ngặt (100 req/min per client)

```mermaid
sequenceDiagram
    participant TPP as TPP Backend Server
    participant AuthServer as Authorization Server
    participant API as API Gateway
    participant ResourceAPI as Resource API
    
    Note over TPP,AuthServer: mTLS Handshake
    TPP->>AuthServer: TLS ClientHello<br/>+ Client Certificate
    AuthServer->>AuthServer: Verify Client Certificate:<br/>- Valid signature<br/>- Not expired<br/>- In whitelist
    AuthServer-->>TPP: TLS ServerHello<br/>+ Server Certificate
    
    Note over TPP: Bước 1: Request Access Token
    
    TPP->>TPP: Create Client Assertion JWT:<br/>iss=client_id<br/>sub=client_id<br/>aud=token_endpoint<br/>jti=unique_id<br/>exp=now+60s
    
    TPP->>AuthServer: POST /token<br/>grant_type=client_credentials<br/>scope=INF<br/>client_assertion_type=<br/>  urn:ietf:params:oauth:client-assertion-type:jwt-bearer<br/>client_assertion={signed_jwt}
    
    AuthServer->>AuthServer: Validate:<br/>- mTLS certificate binding<br/>- Client assertion signature<br/>- JWT claims (iss, sub, aud, exp)<br/>- Scope permissions
    
    AuthServer->>AuthServer: Generate access_token:<br/>- Expires in 3600s<br/>- Scopes: INF<br/>- No refresh_token
    
    AuthServer-->>TPP: HTTP 200<br/>access_token<br/>token_type=Bearer<br/>expires_in=3600<br/>scope=INF
    
    Note over TPP: Bước 2: Call API
    
    TPP->>API: GET /v1/exchange-rates<br/>Authorization: Bearer {access_token}<br/>Request-ID: {uuid}<br/>Provider-ID: {bank_code}
    
    API->>API: Rate Limiting Check<br/>(100 req/min)
    
    API->>AuthServer: POST /introspect<br/>token={access_token}
    AuthServer->>AuthServer: Validate token:<br/>- Not expired<br/>- Not revoked<br/>- Valid signature
    AuthServer-->>API: HTTP 200<br/>active=true<br/>scope=INF<br/>client_id={tpp_id}<br/>exp={timestamp}
    
    API->>ResourceAPI: Forward Request
    ResourceAPI-->>API: Exchange Rate Data
    API-->>TPP: HTTP 200<br/>Response Body (JSON)
```



| Control                    | Requirement                    | Enforcement            |
| -------------------------- | ------------------------------ | ---------------------- |
| **mTLS**                   | Bắt buộc                       | API Gateway            |
| **Certificate Validation** | X.509 v3, RSA 2048-bit minimum | Authorization Server   |
| **IP Whitelisting**        | Bắt buộc Production            | Firewall + API Gateway |
| **Rate Limiting**          | 100 req/min per client_id      | API Gateway            |
| **Token Expiry**           | 3600s (1 hour)                 | Authorization Server   |
| **Scope Validation**       | Chỉ INF scope                  | Authorization Server   |
| **Audit Logging**          | 100% requests                  | SIEM System            |

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
- [ ] Token expiry enforcement (180 days max)
- [ ] Audit logging (3 months + 1 year backup)
- [ ] mTLS cho internal services
- [ ] Penetration testing quarterly

## Tài Liệu Tham Khảo
- RFC 6749: OAuth 2.0 Authorization Framework
- RFC 7636: PKCE for OAuth 2.0
- RFC 7515: JSON Web Signature (JWS)
- FAPI Security Profile 1.0
- Quyết định 2345/QĐ-NHNN
- Thông tư 64/2024/TT-NHNN
