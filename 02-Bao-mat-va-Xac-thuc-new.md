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

### TLS 1.3 - Bắt Buộc

Theo Phụ lục 02, bắt buộc sử dụng TLS 1.2 trở lên, khuyến nghị TLS 1.3.

**Lợi ích TLS 1.3:**
- Handshake nhanh hơn.
- Forward Secrecy mặc định.
- Loại bỏ cipher suites yếu.
- Handshake được mã hóa.

### Cipher Suites Được Phép

**TLS 1.3 (Khuyến nghị):**
- TLS_AES_256_GCM_SHA384
- TLS_AES_128_GCM_SHA256
- TLS_CHACHA20_POLY1305_SHA256

**TLS 1.2 (Dự phòng):**
- TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
- TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256

**Cấm:** Cipher suites sử dụng RC4, 3DES, MD5, SHA-1, hoặc không có Forward Secrecy.

### Mutual TLS (mTLS) - Khuyến Nghị

Áp dụng cho Client Credentials Flow và giao tiếp nội bộ.

### Quản Lý Chứng Chỉ

**Yêu cầu:**
- Thuật toán: RSA 2048-bit tối thiểu.
- Chữ ký: SHA-256 tối thiểu.
- Thời hạn: Tối đa 398 ngày.
- Key Usage: Digital Signature, Key Encipherment.

**Vòng đời chứng chỉ:**
- Tạo CSR → Nộp → Xác thực → Phát hành → Hoạt động → Gia hạn (30 ngày trước hết hạn) → Thu hồi nếu cần.

**Certificate Pinning cho Mobile Apps:** Khuyến nghị để ngăn chặn tấn công man-in-the-middle.

### HSTS (HTTP Strict Transport Security)

Bắt buộc cho tất cả endpoints:
```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

## Client Credentials Flow (Server-to-Server)

Áp dụng cho truy vấn thông tin công khai (INF APIs), health check, batch processing.

**Yêu cầu bảo mật:**
- mTLS bắt buộc.
- Client Assertion JWT khuyến nghị.
- IP Whitelisting bắt buộc cho Production.
- Rate Limiting: 100 req/min per client.

```mermaid
sequenceDiagram
    participant TPP as Máy chủ TPP
    participant AuthServer as Máy chủ Xác thực
    participant API as API Gateway
    participant ResourceAPI as API Tài nguyên
    
    TPP->>AuthServer: POST /token (grant_type=client_credentials, scope=INF, client_assertion)
    AuthServer->>AuthServer: Xác thực mTLS, client assertion, scope
    AuthServer->>TPP: access_token (hết hạn 3600s)
    
    TPP->>API: GET /v1/exchange-rates (Authorization: Bearer {access_token})
    API->>AuthServer: POST /introspect (token)
    AuthServer->>API: active=true, scope=INF
    API->>ResourceAPI: Chuyển tiếp yêu cầu
    ResourceAPI->>API: Dữ liệu tỷ giá
    API->>TPP: Phản hồi JSON
```

## JWS (JSON Web Signature) cho Non-Repudiation

Sử dụng JWS để ký yêu cầu, ngăn chối bỏ.

**Cấu trúc:**
- Header: alg=RS256, kid, typ=JOSE, jti, iat
- Payload: Dữ liệu giao dịch
- Signature: Ký bằng private key TPP

## Consent Management - Quản Lý Sự Đồng Ý

Consent bảo vệ quyền riêng tư, yêu cầu đồng ý rõ ràng từ người dùng.

### Quy Trình Tạo Consent

```mermaid
sequenceDiagram
    participant User as Người dùng
    participant TPP as TPP
    participant BankApp as App Ngân hàng
    participant ConsentAPI as API Đồng ý
    participant ConsentDB as Cơ sở dữ liệu Đồng ý
    participant AuthServer as Máy chủ Xác thực
    
    TPP->>ConsentAPI: POST /consents (quyền, mục đích, thời hạn)
    ConsentAPI->>ConsentDB: Tạo bản ghi, trạng thái: AWAITING_AUTHORISATION
    ConsentAPI->>TPP: consentId + URL ủy quyền
    
    TPP->>BankApp: Chuyển hướng với consentId
    BankApp->>ConsentAPI: GET /consents/{consentId}
    ConsentAPI->>BankApp: Chi tiết đồng ý
    
    BankApp->>User: Màn hình đồng ý
    
    alt Đồng ý
        User->>BankApp: Đồng ý + Chọn tài khoản
        BankApp->>ConsentAPI: PUT /consents/{consentId}/authorise
        ConsentAPI->>ConsentDB: Cập nhật: AUTHORISED
        ConsentAPI->>AuthServer: Tạo authorization_code
        AuthServer->>ConsentAPI: authorization_code
        ConsentAPI->>BankApp: authorization_code
        BankApp->>TPP: Chuyển hướng với auth_code
        
        TPP->>AuthServer: POST /token
        AuthServer->>ConsentDB: Xác thực trạng thái
        AuthServer->>AuthServer: Tạo access_token + refresh_token
        AuthServer->>ConsentDB: Cập nhật: ACTIVE
        AuthServer->>TPP: token
        
    else Từ chối
        User->>BankApp: Từ chối
        BankApp->>ConsentAPI: PUT /consents/{consentId}/reject
        ConsentAPI->>ConsentDB: REJECTED
        ConsentAPI->>BankApp: Từ chối
        BankApp->>TPP: Chuyển hướng với lỗi
    end
```

### Trạng Thái Consent

- AWAITING_AUTHORISATION → AUTHORISED → ACTIVE → EXPIRED/REVOKED

### API Endpoints Chính

- POST /v1/consents: Tạo consent
- GET /v1/consents/{consentId}: Lấy chi tiết
- DELETE /v1/consents/{consentId}: Thu hồi

### Bảo Mật Consent

- Mã hóa dữ liệu nhạy cảm.
- Lưu hash token, không lưu token gốc.
- Audit trail đầy đủ.

## Các Cấp Độ Xác Thực theo QĐ 2345

- Level 1: Username + Password
- Level 2: Password + SMS OTP
- Level 3: Sinh trắc học (Fingerprint/Face ID)
- Level 4: Sinh trắc học nâng cao (NFC CCCD + Face Matching)

**Áp dụng:**
- Truy vấn thông tin: Level 2
- Chuyển tiền < 10 triệu: Level 3
- Chuyển tiền ≥ 10 triệu: Level 4

## NFC CCCD Verification Flow

Sử dụng chip NFC trên CCCD để xác thực danh tính cho giao dịch giá trị cao.

```mermaid
sequenceDiagram
    participant User as Người dùng
    participant App as App TPP
    participant SDK as NFC SDK
    participant API as API Ngân hàng
    participant MPS as Bộ Công an
    
    User->>App: Khởi tạo giao dịch giá trị cao
    App->>User: Yêu cầu quét NFC
    User->>SDK: Chạm CCCD vào điện thoại
    SDK->>SDK: Đọc dữ liệu chip + Xác thực chủ động
    SDK->>App: Dữ liệu chip + Chữ ký
    
    App->>API: POST /ekyc/nfc-verify
    API->>API: Xác thực chữ ký với chứng chỉ gốc MPS
    API->>MPS: Xác thực chuỗi chứng chỉ
    MPS->>API: Hợp lệ
    API->>API: Trích xuất thông tin cá nhân + Ảnh khuôn mặt
    API->>API: So sánh với CIF hiện có
    API->>App: Kết quả xác thực
    
    alt Thành công
        App->>API: Tiếp tục giao dịch
    else Thất bại
        App->>User: Lỗi + Thử lại
    end
```

## Token Management

### Vòng Đời Access Token

Phát hành → Hoạt động (15 phút) → Hết hạn hoặc Thu hồi

### Token Scopes

- accounts.read: Đọc tài khoản (180 ngày)
- accounts.balance.read: Đọc số dư (180 ngày)
- transactions.read: Đọc giao dịch (180 ngày)
- payments.write: Khởi tạo thanh toán (1 lần)
- cards.read: Đọc thẻ (180 ngày)
- cards.write: Quản lý thẻ (90 ngày)

## Security Best Practices

### Transport Security
- TLS 1.3 bắt buộc.
- Certificate Pinning cho mobile.
- HSTS enabled.

### API Security
- Rate Limiting: 100 req/min.
- IP Whitelisting.
- Request Signing (JWS) cho mutation.

### Data Protection
- Mã hóa dữ liệu nghỉ: AES-256.
- Mã hóa truyền tải: TLS 1.3.
- Che PII trong logs.
- Lưu trữ dữ liệu: Logs giao dịch 5 năm, access logs 3 tháng online + 1 năm offline.

### Incident Response
- Giám sát thời gian thực.
- Cảnh báo tự động.
- Thông báo vi phạm trong 72 giờ.

## Compliance Checklist

- [ ] OAuth 2.0 + PKCE
- [ ] FAPI Security Profile
- [ ] JWS signing
- [ ] Consent management
- [ ] NFC CCCD verification
- [ ] Token expiry (180 ngày max)
- [ ] Audit logging
- [ ] mTLS
- [ ] Penetration testing hàng quý

## Tài Liệu Tham Khảo
- RFC 6749: OAuth 2.0
- RFC 7636: PKCE
- RFC 7515: JWS
- FAPI Security Profile 1.0
- QĐ 2345/QĐ-NHNN
- TT 64/2024/TT-NHNN