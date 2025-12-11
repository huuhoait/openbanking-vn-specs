# **Business Requirement Document (BRD): Thiết Kế Hệ Thống Open Banking Tuân Thủ Thông Tư 64/2024/TT-NHNN & Tiêu Chuẩn Quốc Tế 2025**

> **Phiên bản:** 3.0  
**Ngày cập nhật:** 11/12/2025  
**Người soạn:** Open Banking Team  
**Tuân thủ:** Thông tư 64/2024/TT-NHNN (Công báo 301+302/2025), Circular 45/2025, Circular 50/2024, OAuth 2.0 (RFC 6749), PKCE (RFC 7636), ISO 27001:2022

---

## **1\. Tổng Quan Dự Án & Bối Cảnh Chiến Lược**

### **1.1. Bối Cảnh Pháp Lý & Thị Trường**

Ngành ngân hàng Việt Nam đang đứng trước bước ngoặt chuyển đổi số toàn diện, được thúc đẩy mạnh mẽ bởi hành lang pháp lý mới từ Ngân hàng Nhà nước (NHNN). Các văn bản quan trọng định hình chiến lược này bao gồm:

#### **Khung Pháp Lý Cốt Lõi 2025**

1. **Thông tư 64/2024/TT-NHNN** (Hiệu lực: 01/03/2025): Quy định về việc triển khai giao diện lập trình ứng dụng mở (Open API) trong ngành Ngân hàng. Đây không chỉ là hướng dẫn kỹ thuật mà là mệnh lệnh bắt buộc, yêu cầu các tổ chức tín dụng phải:
   - Gửi danh sách API và kế hoạch triển khai trước **01/07/2025**
   - Tuân thủ hoàn toàn các quy định trước **01/03/2027**
   - Mở cửa hệ thống để kết nối với các Bên thứ ba (TPP), tạo hệ sinh thái tài chính liên thông

2. **Circular 45/2025/TT-NHNN** (Hiệu lực: 05/01/2026): Bắt buộc xác thực sinh trắc học (biometric verification) cho:
   - Mở tài khoản ngân hàng mới
   - Phát hành thẻ thanh toán
   - Giao dịch giá trị cao (>10 triệu VND)
   - Tích hợp với dữ liệu CCCD gắn chip NFC

3. **Circular 50/2024/TT-NHNN**: Quy định về Strong Customer Authentication (SCA) và Multi-Factor Authentication (MFA) cho các giao dịch thanh toán điện tử, yêu cầu:
   - Xác thực đa yếu tố bắt buộc cho mọi giao dịch thanh toán
   - Hỗ trợ các phương thức xác thực hiện đại (sinh trắc học, OTP, push notification)
   - Tuân thủ tiêu chuẩn FAPI 2.0 về bảo mật

4. **Quyết định 2345/QĐ-NHNN**: Tiêu chuẩn xác thực sinh trắc học cho giao dịch trực tuyến, đặc biệt việc sử dụng dữ liệu từ CCCD gắn chip qua NFC.

5. **Nghị định 13/2023/NĐ-CP**: Bảo vệ dữ liệu cá nhân, yêu cầu quản lý consent nghiêm ngặt.

#### **Xu Hướng Toàn Cầu 2025**

- **PSD3 (EU)**: Mở rộng phạm vi Open Banking, yêu cầu API uptime 99.5%, response time <5s, và enhanced security protocols
- **UK Open Finance**: Thiết lập "Future Entity" làm cơ quan chuẩn hóa API, dự kiến hoàn thành cuối 2025
- **US CFPB**: Triển khai Personal Financial Data Rights rule từ 2025
- **FAPI 2.0**: Chuẩn bảo mật mới thay thế FAPI 1.0, tích hợp Attacker Model và enhanced consent management

### **1.2. Mục Tiêu Dự Án**

Tài liệu này xác định các yêu cầu nghiệp vụ và kỹ thuật để xây dựng hệ thống Open Banking ("Hệ Thống") cho Ngân hàng, nhằm đạt được các mục tiêu cốt lõi sau:

1. **Tuân thủ tuyệt đối quy định pháp luật**: Đảm bảo đáp ứng đầy đủ lộ trình của Thông tư 64/2024/TT-NHNN (gửi kế hoạch trước 01/07/2025 và tuân thủ hoàn toàn trước 01/03/2027) 7 và Quyết định 2345/QĐ-NHNN về an toàn giao dịch.5  
2. **Chuẩn hóa Kiến trúc & An ninh**: Xây dựng nền tảng dựa trên các tiêu chuẩn quốc tế như Open Banking UK (Read/Write API Profile v4.0), FAPI (Financial-grade API), ISO 20022, và ISO 27001\.8  
3. **Tối ưu hóa Vận hành & Kinh doanh**: Thiết lập quy trình quản trị vòng đời API tự động, quản lý đối tác (TPP) hiệu quả từ môi trường thử nghiệm (Sandbox) đến môi trường thực (Production), và xây dựng cơ chế tính phí (Monetization) linh hoạt để biến API thành nguồn doanh thu mới.11  
4. **Nâng cao Trải nghiệm Khách hàng**: Cung cấp các dịch vụ tài chính liền mạch (Seamless) ngay trên ứng dụng của đối tác, từ mở tài khoản, phát hành thẻ, đến thanh toán hóa đơn và chuyển tiền.

### **1.3. Phạm Vi Nghiệp Vụ**

Hệ thống sẽ bao gồm các nhóm chức năng chính:

* **Hạ tầng lõi**: API Gateway, Identity Provider (IdP), Developer Portal.  
* **Quản trị**: Lifecycle Management, Onboarding, Billing & Metering.  
* **Dịch vụ Ngân hàng (Banking Services)**:  
  * Dịch vụ Thông tin Tài khoản (AIS).  
  * Dịch vụ Khởi tạo Thanh toán (PIS \- Chuyển tiền nội bộ, Napas 24/7, CITAD, Bill Pay).  
  * Dịch vụ Thẻ & Tokenization (Card Issuance, Lifecycle, NFC Push Provisioning).  
  * Dịch vụ Định danh & Bảo mật (eKYC, NFC Verification, OTP).  
  * Dịch vụ Onboarding: Mở thẻ tín dụng và tài khoản iBanking.  
  * Dịch vụ tra cứu đối soát:Cung cấp api Reconciliation & Dispute Management.
* **Hậu kiểm & Vận hành**: Portal Tra cứu & Đối soát (Reconciliation & Dispute Management).

## ---

**2\. Phân Tích Yêu Cầu Pháp Lý & Tiêu Chuẩn Kỹ Thuật**

### **2.1. Phân Loại API Theo Thông Tư 64/2024/TT-NHNN**

Hệ thống phải phân loại API theo đúng quy định tại Điều 6 của Thông tư 64 để áp dụng các chính sách quản lý phù hợp:

#### **2.1.1. Open API Cơ Bản (Điều 6 Khoản 1)**

Được tổ chức thành các nhóm sau:

**a) Open API truy vấn thông tin tỷ giá, lãi suất (INF):**
- API Lấy thông tin lãi suất
- API Lấy thông tin tỷ giá

**b) Open API truy vấn thông tin của khách hàng (AIS):**
- API Xác nhận và lấy sự đồng ý của khách hàng
- API Lấy mã truy cập
- API Làm mới mã truy cập
- API Thu hồi mã truy cập
- API Lấy danh sách tài khoản
- API Lấy thông tin tài khoản
- API Lấy lịch sử giao dịch

**c) Open API khởi tạo thanh toán, nạp tiền vào ví điện tử, rút tiền ra khỏi ví điện tử:**

*c.1) Open API khởi tạo thanh toán (PIS):*
- API Khởi tạo thanh toán
- API Xác nhận khách hàng luồng Redirect
- API Lấy mã truy cập luồng Redirect
- API Cập nhật trạng thái xác nhận thanh toán của khách hàng luồng Decoupled
- API Xác nhận thanh toán
- API Lấy trạng thái giao dịch
- API Lấy trạng thái xác nhận thanh toán của khách hàng luồng Decoupled

*c.2) Open API Nạp tiền vào ví điện tử (EWLTS):*
- API Nạp ví điện tử
- API Xác nhận OTP
- API Cập nhật trạng thái xác nhận nạp ví điện tử của khách hàng luồng Decoupled
- API Lấy trạng thái xác nhận nạp ví điện tử của khách hàng luồng Decoupled
- API Xác nhận nạp ví điện tử
- API Lấy trạng thái giao dịch

*c.3) Open API Rút tiền ra khỏi ví điện tử (EWLTS):*
- API Rút ví điện tử (cash-out)

**Lưu ý quan trọng:**
- Ngân hàng chỉ được phép triển khai Open API nhóm c (PIS, EWLTS) cho bên thứ ba là Ngân hàng hoặc tổ chức cung ứng dịch vụ trung gian thanh toán (Điều 5 Khoản 3)
- Các API này phải tuân thủ đầy đủ Phụ lục 01 và Phụ lục 02 của Thông tư

#### **2.1.2. Open API Khác (Premium)**

Các API gia tăng giá trị ngoài danh mục Open API Cơ bản, được phép thương mại hóa và ký kết hợp đồng khai thác riêng với TPP:

| Loại API          | Mô tả & Yêu cầu                                                                                                 | Ví dụ Nghiệp vụ                                                                                                                                            |
| :---------------- | :-------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Open API Khác** | Triển khai theo nhu cầu thực tế và phù hợp quy định pháp luật. Phải tuân thủ Phụ lục 02 về tiêu chuẩn kỹ thuật. | Chấm điểm tín dụng (Credit Scoring); Mở thẻ tín dụng; eKYC as a Service; Card Issuance; NFC Push Provisioning; Bill Payment (mở rộng); Beneficiary Inquiry |

### **2.2. Tiêu Chuẩn Kỹ Thuật Bắt Buộc 2025**

Hệ thống phải tuân thủ nghiêm ngặt các tiêu chuẩn kỹ thuật mới nhất được quy định trong Phụ lục 01 và 02 của Thông tư 64 và các tiêu chuẩn quốc tế 2025:

#### **Kiến Trúc & Giao Thức**
* **Kiến trúc**: RESTful API (Representational State Transfer) với Zero Trust Architecture
* **Định dạng Dữ liệu**: 
  * JSON (JavaScript Object Notation) là bắt buộc
  * Cấu trúc dữ liệu tuân thủ **ISO 20022** (Financial Messages)
  * Hỗ trợ ISO 8583, OFX, ISO 4271, RFC 3339 cho các trường hợp đặc biệt
* **Mã hóa ký tự**: UTF-8 (Unicode Transformation Format)

#### **Bảo Mật Transport Layer**
* **HTTPS** (bắt buộc): Theo quy định Phụ lục 02 Thông tư 64/2024
* **TLS 1.2 trở lên** (bắt buộc): Theo Phụ lục 02, khuyến nghị sử dụng TLS 1.3 để:
  * Faster handshake (1-RTT)
  * Forward Secrecy mặc định
  * Loại bỏ cipher suites yếu
  * Perfect Forward Secrecy (PFS)
* **Mutual TLS (mTLS)**: Khuyến nghị áp dụng theo Phụ lục 02
* **Certificate Pinning**: Khuyến nghị cho mobile applications

#### **Authentication & Authorization**
* **OAuth 2.0 Authorization Framework** (bắt buộc theo RFC 6749, RFC 6750):
  * **PKCE bắt buộc** (RFC 7636) cho authorization code flows
  * Client Credentials Grant (RFC 6749 mục 4.4) cho INF APIs
  * Authorization Code Grant (RFC 6749 mục 4.1) kết hợp PKCE cho AIS, PIS, EWLTS
  * Token Revocation (RFC 7009) cho việc thu hồi token
  * Refresh token rotation khuyến nghị
* **OpenID Connect (OIDC)**: Khuyến nghị kết hợp với OAuth 2.0
* **SAML v2.0**: Khuyến nghị áp dụng cho API khác của Ngân hàng
* **FAPI 2.0** (Financial-grade API): Khuyến nghị cho enhanced security:
  * Pushed Authorization Requests (PAR)
  * Rich Authorization Requests (RAR) cho fine-grained consent
  * JWT-secured Authorization Response Mode (JARM)
  * Proof-of-Possession tokens

#### **Message Integrity & Non-Repudiation**
* **JWS (JSON Web Signature)** theo RFC 7515 (bắt buộc):
  * Bắt buộc cho mọi API có tham số trong Body (theo Phụ lục 01)
  * Dạng Detached JWS
  * Độ dài khóa tối thiểu: 2048 bit (RSA), 256 bit (ECDSA)
  * Algorithm: RS256, ES256 (khuyến nghị ES256 cho hiệu năng)
  * Include jti (JWT ID) và iat (Issued At) để chống replay attack
* **JWE (JSON Web Encryption)** theo RFC 7516 (khuyến nghị):
  * Cho dữ liệu nhạy cảm
  * Sử dụng RSAES-OAEP, độ dài khóa tối thiểu 2048 bit

#### **Advanced Security Standards 2025**
* **Zero Trust Architecture (ZTA)**:
  * Never trust, always verify
  * Micro-segmentation
  * Least privilege access
  * Continuous verification
* **AI-Powered API Security**:
  * Real-time threat detection
  * Anomaly detection using ML
  * Automated response capabilities
  * Behavioral analytics
* **Quantum-Safe Cryptography** (Preparation):
  * Post-quantum cryptographic algorithms
  * Hybrid classical-quantum schemes
  * Migration roadmap to quantum-resistant algorithms

#### **Compliance & Certification**
* **ISO/IEC 27001:2022**: Information Security Management (bắt buộc áp dụng theo Phụ lục 02)
* **TCVN 11930:2017**: Yêu cầu cơ bản về an toàn hệ thống thông tin theo cấp độ (có thể áp dụng thay ISO 27001)
* **PCI DSS 4.0**: Payment Card Industry Data Security Standard
* **ISO 30107**: Liveness Detection (Anti-spoofing)
* **ISO 19794**: Biometric Data Interchange Formats
* **OWASP API Security Top 10 (2023)**: Security best practices
* **Cấp độ an toàn hệ thống**: Tối thiểu cấp độ 3 theo quy định của Chính phủ (Điều 11 Khoản 4)

### **2.3. Yêu Cầu Về Bảo Vệ Dữ Liệu & Sự Đồng Ý Của Khách Hàng**

Theo Điều 11 Thông tư 64/2024 và Nghị định 13/2023/NĐ-CP về bảo vệ dữ liệu cá nhân:

* **Consent Management**: Phải có hệ thống quản lý sự đồng ý của khách hàng. Khách hàng phải thực hiện đồng ý (Consent) rõ ràng cho TPP truy cập dữ liệu.
* **Thời hạn truy cập**: 
  - Thời hạn được thực hiện truy vấn thông tin của khách hàng sau khi được khách hàng đồng ý **không quá 180 ngày** (Điều 11 Khoản 6)
  - Sau thời gian này, TPP phải yêu cầu khách hàng tái xác thực (Re-authentication)
  - Refresh Token chỉ áp dụng cho AIS, thời gian hiệu lực theo quy định đồng ý chia sẻ dữ liệu
* **Quyền rút lại**: 
  - Khách hàng phải có quyền rút lại sự đồng ý (Revoke Consent) bất cứ lúc nào
  - Ngân hàng phải cung cấp công cụ/chức năng cho phép khách hàng:
    + Tra cứu các dữ liệu mà khách hàng đồng ý cho bên thứ ba xử lý
    + Rút lại sự đồng ý theo quy định pháp luật (Điều 11 Khoản 5)
  - TPP cũng phải cung cấp công cụ tương tự trên ứng dụng của mình (Điều 12 Khoản 2)
* **Giới hạn truy vấn**: Ngân hàng phải có giải pháp công nghệ giới hạn số lần truy vấn tự động thông tin của khách hàng từ bên thứ ba (Điều 11 Khoản 9)

## ---

**3\. Kiến Trúc Hệ Thống & Bảo Mật (System Architecture)**

### **3.1. Mô Hình Kiến Trúc Microservices**

Hệ thống sẽ được thiết kế theo mô hình Microservices, với API Gateway đóng vai trò là điểm truy cập duy nhất (Single Entry Point) cho tất cả các TPP.

* **API Gateway Layer**: Chịu trách nhiệm xác thực sơ cấp (Client Auth), giới hạn tốc độ (Rate Limiting), kiểm soát hạn ngạch (Quota), và định tuyến (Routing).  
* **Identity & Access Management (IAM) Server**: Đóng vai trò là Authorization Server trong mô hình OAuth 2.0. Quản lý việc cấp phát, xác thực, và thu hồi Access Token/Refresh Token.  
* **Consent Management Service**: Lưu trữ trạng thái đồng ý của khách hàng, phạm vi dữ liệu (Scope) được chia sẻ, và thời hạn hiệu lực.  
* **Reconciliation & Dispute Service**: Module mới chịu trách nhiệm tổng hợp dữ liệu giao dịch, thực hiện đối soát tự động T+1 và quản lý quy trình tra soát.  
* **Core Banking Adapter (ESB)**: Chuyển đổi các bản tin JSON từ Open API sang các định dạng nội bộ (như ISO 8583, SOAP/XML) để giao tiếp với Core Banking (T24, Flexcube, v.v.).

### **3.2. Cơ Chế Xác Thực OAuth 2.1 & FAPI 2.0**

Hệ thống triển khai **OAuth 2.1** và **FAPI 2.0** - các tiêu chuẩn bảo mật mới nhất cho ngành tài chính năm 2025:

#### **3.2.1. Authorization Code Grant with PKCE (OAuth 2.1)**

**PKCE (Proof Key for Code Exchange) giờ đây là BẮT BUỘC** cho tất cả authorization code flows, không còn là optional.

Áp dụng cho các TPP có ứng dụng Mobile, SPA hoặc Web để truy cập dữ liệu người dùng (AIS) hoặc khởi tạo thanh toán (PIS).

**Luồng xác thực:**

1. **Bước 1 - PAR (Pushed Authorization Request)**:
   - TPP push authorization request trực tiếp đến Authorization Server (backend-to-backend)
   - Nhận request_uri để sử dụng trong bước tiếp theo
   - Tăng cường bảo mật, tránh lộ thông tin qua browser

2. **Bước 2 - Authorization Request**:
   - TPP chuyển hướng người dùng đến trang Ủy quyền của Ngân hàng
   - Gửi kèm: request_uri, code_challenge (SHA256 hash của code_verifier)
   - State parameter để chống CSRF

3. **Bước 3 - User Authentication & Consent**:
   - Người dùng đăng nhập vào Ngân hàng (MFA/Biometric)
   - Xem và phê duyệt quyền truy cập chi tiết (Granular Consent theo RAR)
   - Hệ thống ghi nhận consent với timestamp và scope cụ thể

4. **Bước 4 - Authorization Code**:
   - Ngân hàng trả về authorization_code qua secure redirect
   - Code có thời hạn ngắn (60-120 giây)
   - One-time use only

5. **Bước 5 - Token Exchange**:
   - TPP gửi authorization_code + code_verifier + client authentication
   - Ngân hàng verify code_verifier với code_challenge
   - Trả về: access_token, refresh_token, id_token (OIDC)

6. **Bước 6 - Refresh Token Rotation**:
   - Mỗi lần refresh, hệ thống cấp refresh_token mới
   - Refresh_token cũ bị vô hiệu hóa ngay lập tức
   - Phát hiện token reuse → revoke toàn bộ token family

**Cải tiến OAuth 2.1:**
- ✅ PKCE bắt buộc (không còn optional)
- ✅ Loại bỏ Implicit Grant (không an toàn)
- ✅ Loại bỏ Password Grant (Resource Owner Password Credentials)
- ✅ Refresh Token Rotation bắt buộc
- ✅ Ưu tiên asymmetric authentication (JWT, mTLS)

#### **3.2.2. Client Credentials Grant (Server-to-Server)**

Áp dụng cho giao tiếp Server-to-Server không liên quan đến dữ liệu người dùng cụ thể:

**Use cases:**
- Truy vấn thông tin công khai (Lãi suất, Tỷ giá, ATM locations)
- API health check
- Batch processing
- System integration

**Enhanced Security:**
- Mutual TLS (mTLS) bắt buộc
- Client assertion using JWT (RFC 7523)
- IP whitelisting
- Rate limiting nghiêm ngặt

#### **3.2.3. FAPI 2.0 Security Profile**

**Baseline Security (tương đương FAPI 1.0 Advanced):**

1. **Pushed Authorization Requests (PAR)**:
   - Authorization parameters được push qua backend channel
   - Giảm thiểu attack surface
   - Hỗ trợ large authorization requests

2. **Rich Authorization Requests (RAR)**:
   - Fine-grained consent management
   - Structured authorization details
   - Dynamic scope definition
   ```json
   {
     "authorization_details": [
       {
         "type": "account_information",
         "accounts": ["ACC-123", "ACC-456"],
         "access": ["balance", "transactions"],
         "valid_until": "2025-12-31T23:59:59Z"
       }
     ]
   }
   ```

3. **JWT-secured Authorization Response Mode (JARM)**:
   - Authorization response được ký và mã hóa
   - Chống tampering và eavesdropping

4. **Proof-of-Possession (PoP) Tokens**:
   - Access token được bind với client certificate
   - Chống token theft và replay attacks

5. **Attacker Model Framework**:
   - Định nghĩa rõ ràng các threat scenarios
   - Countermeasures cho từng loại tấn công
   - Continuous security assessment

**Token Management (theo Phụ lục 01 Thông tư 64/2024):**
- **Authorization Code**: Sử dụng một lần, thời gian hiệu lực 180 giây
- **Access Token (client_credentials)**: Tối đa 3600 giây (cho INF APIs)
- **Access Token (authorization_code)**:
  * AIS: Tối đa 3600 giây
  * PIS: Sử dụng một lần, tối đa 300 giây
- **Refresh Token**: Chỉ áp dụng cho AIS, thời gian hiệu lực theo quy định đồng ý chia sẻ dữ liệu (tối đa 180 ngày theo Điều 11 khoản 6)
- **ConsentId** (PIS, EWLTS): 300 giây
- ID Token: Chỉ sử dụng cho authentication, không dùng cho authorization

### **3.3. Chữ Ký Điện Tử (JWS) & Non-Repudiation**

Mọi API liên quan đến giao dịch tài chính (Chuyển tiền, Thanh toán hóa đơn, Thay đổi hạn mức) bắt buộc phải có chữ ký số JWS.9

* **Header JWS**: {"alg":"RS256", "kid":"", "typ":"JOSE"}.  
* **Payload**: Toàn bộ nội dung JSON body của request.  
* **Signature**: Được tạo bởi Private Key của TPP. Ngân hàng sẽ xác thực bằng Public Key của TPP đã được đăng ký trong quá trình Onboarding.  
* **Chống tấn công phát lại (Replay Attack)**: Header phải bao gồm jti (JWT ID) và iat (Issued At). Ngân hàng sẽ từ chối các request có jti trùng lặp hoặc iat quá cũ (ví dụ: \> 5 phút).

## ---

**4\. Quản Trị Vòng Đời API & Quy Trình Onboarding Đối Tác**

### **4.1. Quy Trình Onboarding (Từ UAT đến Production)**

Hệ thống phải hỗ trợ quy trình onboarding tự động hóa để giảm tải vận hành, đồng thời đảm bảo tuân thủ quy trình thẩm định nghiêm ngặt.7

| Giai đoạn                   | Hành động của TPP                                                                                                      | Hành động của Ngân hàng (Hệ thống)                                                                   | Yêu cầu Kỹ thuật/Pháp lý                                                          |
| :-------------------------- | :--------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------- |
| **1\. Đăng ký & Định danh** | Đăng ký tài khoản trên Developer Portal. Cung cấp hồ sơ doanh nghiệp (Giấy ĐKKD, Giấy phép TGTT).                      | Xác thực Email. Thực hiện eKYC doanh nghiệp (KYB) sơ bộ.                                             | Lưu trữ hồ sơ định danh đối tác theo Điều 11.                                     |
| **2\. Sandbox (UAT)**       | Tạo ứng dụng (App) trên Portal. Nhận Client\_ID\_UAT và Client\_Secret\_UAT.                                           | Cấp phát môi trường Sandbox với dữ liệu giả lập (Mock Data).                                         | Môi trường Sandbox phải cách ly hoàn toàn với Core Banking thật (Điều 9).         |
| **3\. Tích hợp & Kiểm thử** | TPP thực hiện tích hợp API. Chạy bộ Test Suite tự động (Postman Collection) để kiểm tra các luồng thành công/thất bại. | Hệ thống tự động ghi log và chấm điểm kết quả kiểm thử (Test Report).                                | Yêu cầu TPP phải vượt qua 100% các test case bắt buộc.                            |
| **4\. Ký Hợp đồng (Legal)** | Gửi yêu cầu "Go-Live". Ký hợp đồng hợp tác Open API.                                                                   | Thẩm định hồ sơ pháp lý. Ký hợp đồng bao gồm các điều khoản theo Điều 8.                             | Hợp đồng phải quy định rõ trách nhiệm khi lộ lọt dữ liệu (Data Breach) (Điều 8).  |
| **5\. Cấp phát Production** | Upload Public Key (để xác thực JWS) và CSR (để tạo chứng chỉ mTLS).                                                    | Phê duyệt yêu cầu. Hệ thống sinh Client\_ID\_Prod và Client\_Secret\_Prod. Cấu hình IP Whitelisting. | Key Production phải được quản lý trong HSM (Hardware Security Module) hoặc Vault. |

### **4.2. Quản Trị Vòng Đời API (Lifecycle Management)**

Hệ thống quản lý API (API Manager) phải hỗ trợ các trạng thái:

* **Draft**: Đang thiết kế, chưa công bố.  
* **Published**: Đã công bố trên Portal, TPP có thể đăng ký.  
* **Deprecated**: Ngưng hỗ trợ phiên bản cũ. Hệ thống phải gửi cảnh báo tự động cho các TPP đang sử dụng phiên bản này (Sunset Policy \- tối thiểu 3-6 tháng).20  
* **Retired**: API ngừng hoạt động hoàn toàn.

### **4.3. Developer Portal & Tài Liệu**

Cung cấp cổng thông tin dành cho lập trình viên với:

* Tài liệu API (Swagger/OpenAPI Specification 3.0) trực quan.  
* Công cụ "Try It Out" để gọi thử API trong môi trường Sandbox.  
* Dashboard thống kê: Số lượng request, tỷ lệ lỗi, thời gian phản hồi trung bình (Latency).

## ---

**5\. Đặc Tả Chi Tiết Các Dịch Vụ Ngân Hàng**

### **5.1. Nhóm Dịch Vụ Tài Khoản (Account Information Services \- AIS)**

Nhóm này cho phép TPP truy cập thông tin tài chính của khách hàng dưới sự đồng ý của họ.

#### **5.1.1. Account Management (Quản lý danh sách tài khoản)**

* **Endpoint**: GET /v1/accounts  
* **Mô tả**: Trả về danh sách các tài khoản thanh toán (Current Account), tiết kiệm (Savings), và thấu chi.  
* **Cam kết chất lượng (SLA)**: Phản hồi \< 500ms.  
* **Dữ liệu trả về**: AccountId, AccountName, Currency, AccountType, Status. Dữ liệu nhạy cảm như số dư không được trả về ở API này.

#### **5.1.2. Balance Inquiry (Truy vấn số dư)**

* **Endpoint**: GET /v1/accounts/{AccountId}/balances  
* **Yêu cầu bảo mật**: Scope accounts.balance.read.  
* **Dữ liệu trả về**:  
  * Amount: Số dư thực tế.  
  * CreditDebitIndicator: Dấu hiệu Nợ/Có/Phong toả  
phong toả  * Type: Loại số dư (Available \- Khả dụng,  \- Số dư sổ sách)

#### **5.1.3. Transaction History (Lịch sử giao dịch)**

* **Endpoint**: GET /v1/accounts/{AccountId}/transactions  
* **Tham số lọc**: fromBookingDateTime, toBookingDateTime. Lưu ý: Giới hạn truy vấn tối đa 90 ngày mỗi lần gọi để đảm bảo hiệu năng.  
* **Phân trang (Pagination)**: Bắt buộc hỗ trợ phân trang (page, limit) để xử lý lượng giao dịch lớn.9

#### **5.1.4. Biến Động Số Dư (Balance Fluctuation Notification)**

* **Cơ chế**: Webhook (Push Notification). Thay vì TPP phải gọi API liên tục (Polling), Ngân hàng sẽ chủ động đẩy thông báo khi có biến động.  
* **Cấu hình**: TPP đăng ký URL Callback (POST /v1/event-subscriptions).  
* **Payload**: Chứa thông tin rút gọn (AccountId, Amount, TransactionId) để bảo vệ quyền riêng tư. TPP cần gọi lại API chi tiết nếu muốn lấy đầy đủ thông tin.

### **5.2. Nhóm Dịch Vụ Khởi Tạo Thanh Toán (Payment Initiation Services - PIS)**

**Lưu ý quan trọng**: Theo Điều 5 Khoản 3 Thông tư 64/2024, Ngân hàng **chỉ được phép triển khai** Open API khởi tạo thanh toán (PIS) cho bên thứ ba là **Ngân hàng hoặc Tổ chức cung ứng dịch vụ trung gian thanh toán**.

Nhóm này bao gồm **7 APIs bắt buộc** theo Phụ lục 01, chỉ áp dụng với các lệnh thanh toán mà khách hàng chủ động thực hiện trên ứng dụng của TPP.

#### **5.2.1. Danh Mục API Khởi Tạo Thanh Toán**

|  STT  | Tên API                                                     | Mô tả                                               |
| :---: | :---------------------------------------------------------- | :-------------------------------------------------- |
|   1   | API Khởi tạo thanh toán                                     | TPP gửi yêu cầu khởi tạo thanh toán, nhận paymentId |
|   2   | API Xác nhận khách hàng luồng Redirect                      | Điều hướng KH đến trang xác nhận của Ngân hàng      |
|   3   | API Lấy mã truy cập luồng Redirect                          | Lấy access_token sau khi KH xác nhận                |
|   4   | API Cập nhật trạng thái xác nhận thanh toán luồng Decoupled | Ngân hàng gọi API của TPP để cập nhật trạng thái    |
|   5   | API Xác nhận thanh toán                                     | TPP xác nhận thực hiện thanh toán                   |
|   6   | API Lấy trạng thái giao dịch                                | Tra cứu trạng thái giao dịch                        |
|   7   | API Lấy trạng thái xác nhận thanh toán luồng Decoupled      | TPP lấy trạng thái xác nhận từ Ngân hàng            |

#### **5.2.2. Quy Trình Khởi Tạo Thanh Toán (Theo Phụ lục 01)**

**Luồng Redirect (Bước 1 → 5.1):**

```
1. Khách hàng yêu cầu thanh toán trên ứng dụng TPP
2. TPP lấy access_token (grant_type: client_credentials)
   → 2.1. Ngân hàng phản hồi access_token
3. TPP gọi API "Khởi tạo thanh toán" (POST /v1/payments)
   → 3.1. Ngân hàng trả về paymentId, consentStatus = "AWAITTING_AUTH"
4. TPP điều hướng KH đến trang xác nhận Ngân hàng
   → 4.1. KH đăng nhập và xác nhận thanh toán
   → 4.1.3. Ngân hàng redirect KH về TPP kèm authorization_code
   → 4.2. TPP lấy access_token (grant_type: authorization_code + PKCE)
5. TPP gọi API "Xác nhận thanh toán" (POST /v1/payments/submit)
   → 5.1. Ngân hàng phản hồi kết quả thanh toán
```

**Luồng Decoupled (Bước 1 → 5.1'):**

```
1-3.1: Giống luồng Redirect
4'. Ngân hàng gửi thông báo cho KH (tùy thiết kế)
   → 4.1'. KH mở ứng dụng Ngân hàng và xác nhận
   → 4.2'. Ngân hàng gọi API "Cập nhật trạng thái" của TPP (POST /v1/update-consent)
   → 4.3'. (Fallback) TPP gọi API "Lấy trạng thái xác nhận" (POST /v1/get-consent)
5'. TPP gọi API "Xác nhận thanh toán" kèm consentId
   → 5.1'. Ngân hàng phản hồi kết quả
6. (Timeout) TPP gọi API "Lấy trạng thái giao dịch" (POST /v1/payments/status)
7. TPP hiển thị kết quả cho KH
```

#### **5.2.3. Đặc Tả API Chi Tiết**

##### **API 1: Khởi Tạo Thanh Toán**

| Thuộc tính        | Giá trị                                    |
| :---------------- | :----------------------------------------- |
| **Endpoint**      | `/v1/payments`                             |
| **Method**        | `POST`                                     |
| **Scope**         | `PIS`                                      |
| **Authorization** | Bearer {access_token} (client_credentials) |

**Request Body:**

| Trường                    | Loại        | Bắt buộc | Mô tả                                                           |
| :------------------------ | :---------- | :------: | :-------------------------------------------------------------- |
| instructionIdentification | String[50]  |    M     | Mã giao dịch do TPP khởi tạo                                    |
| debtor                    | Object      |    C     | Thông tin người thanh toán (không bắt buộc với Cổng thanh toán) |
| debtor.name               | String[70]  |    C     | Tên tài khoản người thanh toán                                  |
| debtor.accountId          | String[34]  |    C     | Số tài khoản người thanh toán                                   |
| debtor.bankCode           | String[8]   |    C     | Mã ngân hàng (Provider-ID)                                      |
| remittanceInformation     | String[255] |    M     | Nội dung giao dịch                                              |
| instructedAmount          | Object      |    M     | Thông tin số tiền                                               |
| instructedAmount.value    | Number      |    M     | Số tiền giao dịch                                               |
| instructedAmount.currency | String[3]   |    M     | Loại tiền (ISO 4217)                                            |
| requestedExecutionDate    | DateTime    |    M     | Ngày thực hiện (RFC 3339)                                       |
| additionalInfo            | Object      |    O     | Thông tin bổ sung                                               |

**Response Body (HTTP 200):**

| Trường         | Loại       | Bắt buộc | Mô tả                                  |
| :------------- | :--------- | :------: | :------------------------------------- |
| paymentId      | String[35] |    M     | Mã giao dịch duy nhất do Ngân hàng cấp |
| status         | String[4]  |    M     | Mã trạng thái (ISO 20022)              |
| statusDateTime | DateTime   |    M     | Thời điểm cập nhật trạng thái          |
| consentStatus  | String[20] |    M     | Mặc định: "AWAITTING_AUTH"             |

##### **API 2: Xác Nhận Khách Hàng Luồng Redirect**

| Thuộc tính       | Giá trị                             |
| :--------------- | :---------------------------------- |
| **Endpoint**     | `/authorize`                        |
| **Method**       | `GET`                               |
| **Content-Type** | `application/x-www-form-urlencoded` |

**Query Parameters:**

| Trường                | Loại   | Bắt buộc | Mô tả                            |
| :-------------------- | :----- | :------: | :------------------------------- |
| response_type         | String |    M     | Mặc định: "code id_token"        |
| client_id             | String |    M     | Client ID của TPP                |
| scope                 | String |    M     | "PIS"                            |
| redirect_uri          | String |    M     | URL callback của TPP             |
| state                 | String |    M     | Chống CSRF attack                |
| code_challenge        | String |    M     | SHA256(code_verifier) - RFC 7636 |
| code_challenge_method | String |    O     | Mặc định: "S256"                 |
| request               | String |    M     | JWT chứa paymentId trong payload |

**Response (Redirect về TPP):**

| Trường   | Loại   | Bắt buộc | Mô tả                          |
| :------- | :----- | :------: | :----------------------------- |
| code     | String |    M     | Mã đồng ý (authorization_code) |
| state    | String |    M     | Giá trị state từ request       |
| id_token | String |    O     | JWT chứa paymentId             |

##### **API 3: Lấy Mã Truy Cập Luồng Redirect**

| Thuộc tính        | Giá trị                               |
| :---------------- | :------------------------------------ |
| **Endpoint**      | `/token`                              |
| **Method**        | `POST`                                |
| **Authorization** | Basic BASE64(client_id:client_secret) |

**Request Body:**

| Trường        | Loại   | Bắt buộc | Mô tả                               |
| :------------ | :----- | :------: | :---------------------------------- |
| grant_type    | String |    M     | "authorization_code"                |
| code          | String |    M     | Mã đồng ý từ bước redirect          |
| redirect_uri  | String |    M     | Phải khớp với API authorize         |
| code_verifier | String |    M     | Giá trị gốc dùng tạo code_challenge |

**Response Body:**

| Trường       | Loại   | Bắt buộc | Mô tả                                          |
| :----------- | :----- | :------: | :--------------------------------------------- |
| access_token | String |    M     | Mã truy cập (hiệu lực tối đa 300s, dùng 1 lần) |
| token_type   | String |    M     | "Bearer"                                       |
| expires_in   | Number |    M     | Thời gian hiệu lực (giây)                      |
| scope        | String |    M     | "PIS"                                          |

##### **API 4: Cập Nhật Trạng Thái Luồng Decoupled**

**Lưu ý**: API này được **Ngân hàng gọi đến TPP** (không phải TPP gọi Ngân hàng).

| Thuộc tính   | Giá trị                             |
| :----------- | :---------------------------------- |
| **Endpoint** | `/v1/update-consent` (TPP endpoint) |
| **Method**   | `POST`                              |

**Request Body (Ngân hàng gửi đến TPP):**

| Trường        | Loại       | Bắt buộc | Mô tả                                |
| :------------ | :--------- | :------: | :----------------------------------- |
| paymentId     | String[35] |    M     | Mã giao dịch từ API Khởi tạo         |
| consentId     | String[36] |    M     | Giá trị do Ngân hàng sinh ra         |
| consentStatus | String[20] |    M     | "AUTHORISED" / "REJECTED" / "CANCEL" |
| expireIn      | Number     |    M     | Thời gian hiệu lực consentId (300s)  |

##### **API 5: Xác Nhận Thanh Toán**

| Thuộc tính        | Giá trị               |
| :---------------- | :-------------------- |
| **Endpoint**      | `/v1/payments/submit` |
| **Method**        | `POST`                |
| **Scope**         | `PIS`                 |
| **Authorization** | Bearer {access_token} |

**Lưu ý về Authorization:**
- **Redirect Flow**: access_token từ Authorization Code Grant
- **Decoupled Flow**: access_token từ Client Credentials Grant

**Request Body:**

| Trường    | Loại       | Bắt buộc | Mô tả                        |
| :-------- | :--------- | :------: | :--------------------------- |
| paymentId | String[35] |    M     | Mã giao dịch từ API Khởi tạo |
| consentId | String[36] |    C     | Bắt buộc với luồng Decoupled |

**Response Body:**

| Trường         | Loại       | Bắt buộc | Mô tả                   |
| :------------- | :--------- | :------: | :---------------------- |
| paymentId      | String[35] |    M     | Mã giao dịch            |
| status         | String[4]  |    M     | Mã trạng thái ISO 20022 |
| statusDateTime | DateTime   |    M     | Thời điểm cập nhật      |

##### **API 6: Lấy Trạng Thái Giao Dịch**

| Thuộc tính        | Giá trị                                    |
| :---------------- | :----------------------------------------- |
| **Endpoint**      | `/v1/payments/status`                      |
| **Method**        | `POST`                                     |
| **Scope**         | `PIS`                                      |
| **Authorization** | Bearer {access_token} (client_credentials) |

**Request Body:**

| Trường    | Loại       | Bắt buộc | Mô tả                    |
| :-------- | :--------- | :------: | :----------------------- |
| paymentId | String[35] |    M     | Mã giao dịch cần tra cứu |

**Response Body:**

| Trường         | Loại       | Bắt buộc | Mô tả                   |
| :------------- | :--------- | :------: | :---------------------- |
| paymentId      | String[35] |    M     | Mã giao dịch            |
| status         | String[4]  |    M     | Mã trạng thái ISO 20022 |
| statusDateTime | DateTime   |    M     | Thời điểm cập nhật      |

##### **API 7: Lấy Trạng Thái Xác Nhận Luồng Decoupled**

| Thuộc tính        | Giá trị                                    |
| :---------------- | :----------------------------------------- |
| **Endpoint**      | `/v1/get-consent`                          |
| **Method**        | `POST`                                     |
| **Scope**         | `PIS`                                      |
| **Authorization** | Bearer {access_token} (client_credentials) |

**Request Body:**

| Trường    | Loại       | Bắt buộc | Mô tả                    |
| :-------- | :--------- | :------: | :----------------------- |
| paymentId | String[35] |    M     | Mã giao dịch cần tra cứu |

**Response Body:**

| Trường        | Loại       | Bắt buộc | Mô tả                                |
| :------------ | :--------- | :------: | :----------------------------------- |
| paymentId     | String[35] |    M     | Mã giao dịch                         |
| consentId     | String[36] |    M     | Giá trị do Ngân hàng sinh            |
| consentStatus | String[20] |    M     | "AUTHORISED" / "REJECTED" / "CANCEL" |
| expireIn      | Number     |    M     | Thời gian hiệu lực (300s)            |

#### **5.2.4. Yêu Cầu Kỹ Thuật Chung (Theo Phụ lục 01)**

**Request Headers bắt buộc:**

| Header           | Loại        | Bắt buộc | Mô tả                     |
| :--------------- | :---------- | :------: | :------------------------ |
| Content-Type     | String      |    M     | "application/json"        |
| Authorization    | String      |    M     | Bearer {access_token}     |
| Request-DateTime | DateTime    |    M     | RFC 3339 format           |
| Request-ID       | String[60]  |    M     | UUID định danh request    |
| Provider-ID      | String[8]   |    M     | Mã ngân hàng NHNN cấp     |
| TPP-ID           | String[15]  |    M     | Mã số thuế TPP            |
| JWS-Signature    | String      |    M     | Chữ ký JWS (RFC 7515)     |
| PSU-IP-Address   | String[50]  |    O     | IP khách hàng (IPv4/IPv6) |
| PSU-User-Agent   | String[200] |    O     | User Agent trình duyệt    |
| PSU-Device-OS    | String[100] |    O     | Hệ điều hành thiết bị     |
| Client-ID        | String[50]  |    O     | Mã định danh ứng dụng     |

**Response Headers bắt buộc:**

| Header           | Loại   | Bắt buộc | Mô tả               |
| :--------------- | :----- | :------: | :------------------ |
| Content-Type     | String |    M     | "application/json"  |
| Request-ID       | String |    M     | Echo từ request     |
| Request-DateTime | String |    M     | Echo từ request     |
| JWS-Signature    | String |    M     | Chữ ký JWS response |

**Thời hạn Token (Phụ lục 01 Mục 1):**

| Loại Token         | Thời hạn | Ghi chú             |
| :----------------- | :------- | :------------------ |
| Authorization Code | 180 giây | Sử dụng một lần     |
| Access Token (PIS) | 300 giây | Sử dụng một lần     |
| ConsentId          | 300 giây | Cho luồng Decoupled |

#### **5.2.5. Mã Trạng Thái Giao Dịch (ISO 20022)**

Các mã trạng thái thanh toán tuân thủ ISO 20022:

| Mã   | Mô tả                                               |
| :--- | :-------------------------------------------------- |
| PDNG | Pending - Đang chờ xử lý                            |
| ACTC | AcceptedTechnicalValidation - Đã chấp nhận kỹ thuật |
| ACCP | AcceptedCustomerProfile - Đã chấp nhận hồ sơ KH     |
| ACSC | AcceptedSettlementCompleted - Hoàn thành thanh toán |
| RJCT | Rejected - Từ chối                                  |
| CANC | Cancelled - Đã hủy                                  |

#### **5.2.6. Mã Lỗi (Theo Phụ lục 01 Mục 7.2)**

| HTTP Code | Error Code                          | Mô tả                         |
| :-------: | :---------------------------------- | :---------------------------- |
|    400    | INSTRUCTION_IDENTIFICATION_REQUIRED | Thiếu mã giao dịch TPP        |
|    400    | DEBTOR_ACCOUNTID_NOT_EXISTED        | Tài khoản nguồn không tồn tại |
|    400    | PAYMENTID_NOT_EXISTED               | PaymentId không tồn tại       |
|    400    | CONSENTID_NOT_EXISTED               | ConsentId không tồn tại       |
|    400    | EXPIRE_CONSENTID                    | ConsentId đã hết hạn          |
|    401    | EXPIRED_TOKEN                       | Token đã hết hạn              |
|    401    | JWS_SIGNATURE_UNVERIFIED            | Xác thực JWS thất bại         |
|    403    | FORBIDDEN                           | Quyền truy cập bị từ chối     |
|    500    | INTERNAL_ERROR                      | Lỗi hệ thống                  |
|    504    | GATEWAY_TIMEOUT                     | Timeout kết nối               |

#### **5.2.7. Webhook Phản Hồi Kết Quả Payment (Payment Result Callback)**

Để giảm tải việc polling từ phía TPP và đảm bảo TPP nhận được kết quả giao dịch kịp thời, Ngân hàng hỗ trợ cơ chế **Webhook** để chủ động thông báo kết quả thanh toán về cho TPP.

##### **Đăng Ký Webhook**

| Thuộc tính   | Giá trị                      |
| :----------- | :--------------------------- |
| **Endpoint** | `POST /v1/payments/webhooks` |
| **Method**   | `POST`                       |
| **Scope**    | `PIS`                        |

**Request Body:**

| Trường      | Loại        | Bắt buộc | Mô tả                                                                         |
| :---------- | :---------- | :------: | :---------------------------------------------------------------------------- |
| callbackUrl | String[255] |    M     | URL endpoint của TPP để nhận webhook                                          |
| events      | Array       |    M     | Danh sách event đăng ký (PAYMENT_COMPLETED, PAYMENT_FAILED, PAYMENT_REVERSED) |
| secretKey   | String[64]  |    M     | Secret key để ký HMAC-SHA256 payload                                          |
| isActive    | Boolean     |    O     | Trạng thái active/inactive. Mặc định: true                                    |

**Response Body:**

| Trường    | Loại       | Bắt buộc | Mô tả                  |
| :-------- | :--------- | :------: | :--------------------- |
| webhookId | String[36] |    M     | UUID định danh webhook |
| status    | String     |    M     | "ACTIVE" / "INACTIVE"  |
| createdAt | DateTime   |    M     | Thời điểm tạo          |

##### **Callback từ Ngân Hàng đến TPP (Payment Result Notification)**

Ngân hàng sẽ gọi đến `callbackUrl` của TPP khi có sự kiện thay đổi trạng thái giao dịch.

| Thuộc tính   | Giá trị             |
| :----------- | :------------------ |
| **Endpoint** | `{TPP callbackUrl}` |
| **Method**   | `POST`              |
| **Caller**   | Ngân hàng → TPP     |

**Request Headers (Ngân hàng gửi):**

| Header        | Loại   | Bắt buộc | Mô tả                                                            |
| :------------ | :----- | :------: | :--------------------------------------------------------------- |
| Content-Type  | String |    M     | "application/json"                                               |
| X-Webhook-ID  | String |    M     | UUID của webhook đã đăng ký                                      |
| X-Event-Type  | String |    M     | Loại event (PAYMENT_COMPLETED, PAYMENT_FAILED, PAYMENT_REVERSED) |
| X-Timestamp   | String |    M     | Thời điểm gửi webhook (RFC 3339)                                 |
| X-Signature   | String |    M     | HMAC-SHA256(payload, secretKey)                                  |
| X-Retry-Count | Number |    O     | Số lần retry (0 = lần đầu)                                       |

**Callback Payload (Ngân hàng gửi đến TPP):**

| Trường                    | Loại       | Bắt buộc | Mô tả                                                       |
| :------------------------ | :--------- | :------: | :---------------------------------------------------------- |
| eventId                   | String[36] |    M     | UUID định danh event                                        |
| eventType                 | String     |    M     | "PAYMENT_COMPLETED" / "PAYMENT_FAILED" / "PAYMENT_REVERSED" |
| eventTime                 | DateTime   |    M     | Thời điểm xảy ra event (RFC 3339)                           |
| paymentId                 | String[35] |    M     | Mã giao dịch của Ngân hàng                                  |
| instructionIdentification | String[50] |    M     | Mã giao dịch do TPP khởi tạo (để TPP mapping)               |
| status                    | String[4]  |    M     | Mã trạng thái ISO 20022 (ACSC, RJCT, CANC, ...)             |
| statusDateTime            | DateTime   |    M     | Thời điểm cập nhật trạng thái                               |
| statusReason              | String     |    O     | Lý do (nếu RJCT hoặc CANC)                                  |
| instructedAmount          | Object     |    M     | Thông tin số tiền giao dịch                                 |
| instructedAmount.value    | Number     |    M     | Số tiền                                                     |
| instructedAmount.currency | String[3]  |    M     | Loại tiền (ISO 4217)                                        |
| bankReference             | String[35] |    O     | Mã tham chiếu nội bộ Ngân hàng                              |
| napasTraceNumber          | String[12] |    O     | Số trace Napas (nếu là giao dịch Napas)                     |

**Ví dụ Callback Payload:**

```json
{
  "eventId": "evt-550e8400-e29b-41d4-a716-446655440000",
  "eventType": "PAYMENT_COMPLETED",
  "eventTime": "2025-12-11T13:45:00+07:00",
  "paymentId": "PAY-123456789012345",
  "instructionIdentification": "TPP-ORDER-20251211-001",
  "status": "ACSC",
  "statusDateTime": "2025-12-11T13:44:58+07:00",
  "instructedAmount": {
    "value": 1500000,
    "currency": "VND"
  },
  "bankReference": "BNK-REF-001234",
  "napasTraceNumber": "123456789012"
}
```

**Response từ TPP (Xác nhận nhận webhook):**

TPP phải phản hồi HTTP 200 OK trong vòng **5 giây** để xác nhận đã nhận webhook.

| HTTP Status | Ý nghĩa                            |
| :---------: | :--------------------------------- |
|     200     | Đã nhận và xử lý thành công        |
|     202     | Đã nhận, đang xử lý (acknowledged) |
|   4xx/5xx   | Lỗi - Ngân hàng sẽ retry           |

##### **Retry Policy**

Nếu TPP không phản hồi 200/202 hoặc timeout, Ngân hàng sẽ retry theo exponential backoff:

| Retry | Thời gian chờ | Ghi chú         |
| :---: | :------------ | :-------------- |
|   1   | 30 giây       | Retry lần 1     |
|   2   | 2 phút        | Retry lần 2     |
|   3   | 10 phút       | Retry lần 3     |
|   4   | 1 giờ         | Retry lần 4     |
|   5   | 6 giờ         | Retry cuối cùng |

Sau 5 lần retry thất bại, webhook sẽ được đánh dấu là **FAILED** và TPP cần sử dụng API "Lấy trạng thái giao dịch" để tra cứu.

##### **Xác Thực Webhook (Signature Verification)**

TPP **bắt buộc** phải xác thực chữ ký webhook để đảm bảo request đến từ Ngân hàng:

```
Signature = HMAC-SHA256(payload_body, secretKey)
```

**Quy trình xác thực:**
1. Lấy giá trị `X-Signature` từ header
2. Tính HMAC-SHA256 của request body với `secretKey` đã đăng ký
3. So sánh 2 giá trị (constant-time comparison để chống timing attack)
4. Nếu không khớp → từ chối request

##### **Quản Lý Webhook**

| Endpoint                              | Method | Mô tả                               |
| :------------------------------------ | :----- | :---------------------------------- |
| `GET /v1/payments/webhooks`           | GET    | Danh sách webhook đã đăng ký        |
| `GET /v1/payments/webhooks/{id}`      | GET    | Chi tiết webhook                    |
| `PUT /v1/payments/webhooks/{id}`      | PUT    | Cập nhật webhook (URL, events, ...) |
| `DELETE /v1/payments/webhooks/{id}`   | DELETE | Xóa webhook                         |
| `GET /v1/payments/webhooks/{id}/logs` | GET    | Lịch sử gọi webhook (debug)         |

##### **Events Hỗ Trợ**

| Event Type         | Mô tả                                               | Trigger                       |
| :----------------- | :-------------------------------------------------- | :---------------------------- |
| PAYMENT_COMPLETED  | Giao dịch hoàn thành thành công                     | status = ACSC                 |
| PAYMENT_FAILED     | Giao dịch thất bại                                  | status = RJCT                 |
| PAYMENT_REVERSED   | Giao dịch bị đảo/hoàn tiền                          | Có lệnh hoàn tiền từ hệ thống |
| PAYMENT_PENDING    | Giao dịch đang chờ xử lý (dùng cho batch payment)   | status = PDNG                 |
| CONSENT_AUTHORIZED | Khách hàng đã xác nhận thanh toán (luồng Decoupled) | consentStatus = AUTHORISED    |
| CONSENT_REJECTED   | Khách hàng từ chối thanh toán                       | consentStatus = REJECTED      |

### **5.3. Nhóm Dịch Vụ Thẻ & Quản Lý Vòng Đời (Card Services)**

#### **5.3.1. Phát hành & Quản lý Thẻ**

* **Card Issuance (POST /cards/issuance)**: Cho phép phát hành thẻ phi vật lý (Virtual Card) ngay lập tức. Yêu cầu đầu vào phải có Reference ID của quá trình eKYC thành công.27  
* **Card Lifecycle**:  
  * PUT /cards/{cardId}/lock: Khóa thẻ tạm thời.  
  * PUT /cards/{cardId}/unlock: Mở khóa thẻ.  
  * PUT /cards/{cardId}/pin: Đổi mã PIN (yêu cầu mã hóa PIN Block theo chuẩn ISO 9564).

#### **5.3.2. NFC & Tokenization (Push Provisioning)**

Để hỗ trợ Apple Pay/Google Pay/Samsung Pay theo xu hướng thị trường 28:

* **Push Provisioning API**: Cho phép người dùng "đẩy" thông tin thẻ từ App TPP vào ví điện tử (Wallet) trên thiết bị.  
* **Cơ chế**: Ngân hàng đóng vai trò Issuer, giao tiếp với Token Service Provider (TSP) của Visa (VTS) hoặc Mastercard (MDES) để sinh ra Opaque Payment Card (OPC). Dữ liệu này được mã hóa và gửi về thiết bị để add vào Wallet mà không lộ số thẻ thật (PAN).30

### **5.4. Nhóm Dịch Vụ Onboarding & Khởi Tạo Tài Khoản (New Services)**

#### **5.4.1. Quy Trình Onboarding Thẻ Tín Dụng (Credit Card Onboarding)**

Đây là quy trình phức tạp yêu cầu kết hợp eKYC, chấm điểm tín dụng (Credit Scoring) và phê duyệt hạn mức tự động.

* **Endpoint**: POST /v1/onboarding/credit-card  
* **Quy trình nghiệp vụ (Flow)**:  
  1. **Initiation**: TPP gửi yêu cầu mở thẻ kèm thông tin định danh cơ bản (Họ tên, SĐT, Email, Số CCCD) và ConsentId (khách hàng đồng ý chia sẻ dữ liệu để chấm điểm tín dụng).  
  2. **eKYC & AML Check**: Hệ thống Ngân hàng thực hiện eKYC (nếu chưa có CIF) hoặc xác thực lại (nếu đã có). Đồng thời, kiểm tra danh sách đen (Sanction List/AML) và lịch sử tín dụng (CIC).  
  3. **Credit Scoring**: Gọi API nội bộ hoặc đối tác thứ 3 để chấm điểm tín dụng dựa trên dữ liệu TPP cung cấp (như lịch sử giao dịch TMĐT) kết hợp dữ liệu CIC.  
  4. **Approval**: Hệ thống trả về hạn mức thẻ được phê duyệt (Pre-approved Limit) hoặc từ chối.  
  5. **Issuance**: Nếu khách hàng chấp nhận hạn mức, hệ thống phát hành thẻ ảo (Virtual Card) ngay lập tức để sử dụng và gửi yêu cầu in thẻ vật lý.  
* **Dữ liệu đầu vào (Payload)**:  
  * CustomerInfo: (Tên, DOB, ID Number, Address).  
  * FinancialData: (Thu nhập kê khai, Hợp đồng lao động \- nếu cần).  
  * ProductType: (Loại thẻ đăng ký: Visa Platinum, Mastercard Gold...).  
  * eKYC\_ReferenceId: Mã tham chiếu của phiên eKYC đã hoàn thành trước đó.  
* **Bảo mật**: Bắt buộc xác thực cấp độ cao nhất (Level 4 theo QĐ 2345/QĐ-NHNN) bằng sinh trắc học khớp với CCCD gắn chip.5

#### **5.4.2. Quy Trình Onboarding Tài Khoản iBanking (iBanking Registration)**

Cho phép người dùng chưa có tài khoản ngân hàng thực hiện mở tài khoản thanh toán và kích hoạt dịch vụ ngân hàng điện tử ngay trên ứng dụng TPP.

* **Endpoint**: POST /v1/onboarding/ibanking  
* **Quy trình nghiệp vụ**:  
  1. **Verify Identity**: TPP gọi API eKYC (hoặc sử dụng kết quả eKYC của TPP nếu Ngân hàng chấp nhận kết quả đó theo cơ chế Relying Party).  
  2. **Create CIF & Account**: Hệ thống tạo mã khách hàng (CIF) và số tài khoản thanh toán (Account Number). Hỗ trợ chọn số đẹp nếu có cấu hình.  
  3. **Register Credentials**: Tạo tên đăng nhập (Username \- thường là SĐT) và mật khẩu tạm thời (gửi qua SMS/Email).  
  4. **Activate**: Khách hàng nhập OTP để kích hoạt tài khoản và đổi mật khẩu lần đầu.  
* **Dữ liệu đầu ra**:  
  * CIF: Mã khách hàng.  
  * AccountNumber: Số tài khoản vừa tạo.  
  * Username: Tên đăng nhập dịch vụ iBanking.  
  * ServiceStatus: Trạng thái kích hoạt (Active/Pending).

### **5.5. Dịch Vụ Định Danh & An Ninh (Identity & Security Services)**

#### **5.5.1. eKYC & Onboarding User**

* **Quy trình**:  
  1. **OCR**: Trích xuất thông tin từ ảnh chụp giấy tờ tùy thân.  
  2. **Liveness Detection**: Kiểm tra thực thể sống (Chớp mắt, quay trái/phải) để chống giả mạo (Spoofing).32  
  3. **Face Matching**: So khớp khuôn mặt selfie với ảnh trên giấy tờ.  
* **Onboarding**: Sau khi eKYC thành công, gọi API POST /users/onboarding để tạo CIF (Customer Information File) và tài khoản iBanking.

#### **5.5.2. Quản lý NFC & Xác thực Chip CCCD (Decision 2345\)**

Đây là yêu cầu quan trọng nhất để tuân thủ Quyết định 2345/QĐ-NHNN cho giao dịch \> 10 triệu VND.

* **Cơ chế**: Ứng dụng TPP phải tích hợp SDK để đọc chip NFC trên CCCD.  
* **API NFC Verify**: POST /ekyc/nfc-verify.  
  * **Input**: Dữ liệu đọc được từ chip (DG1, DG2, SOD), Chữ ký số của chip (Active Authentication).  
  * **Xử lý**: Hệ thống Ngân hàng sẽ xác thực chữ ký này với chứng thư số của Bộ Công an (RAR-C06) để đảm bảo thẻ thật, không bị clone.6  
  * **Output**: Kết quả xác thực (Pass/Fail) và thông tin nhân thân từ chip.

#### **5.5.3. OTP Service**

* **Generate OTP**: POST /auth/otp/generate. Hỗ trợ SMS OTP và Smart OTP.  
* **Validate OTP**: POST /auth/otp/validate.

### **5.6. Nhóm Dịch Vụ Tra Soát & Đối Soát (Reconciliation & Investigation Services)**

Nhóm API hỗ trợ TPP và Ngân hàng trong việc tra cứu, đối soát và tra soát giao dịch theo yêu cầu của Thông tư 64/2024/TT-NHNN.

#### **5.6.1. Tra Cứu Giao Dịch (Transaction Inquiry)**

* **Endpoint**: GET /v1/reconciliation/transactions/{TransactionId}  
* **Mô tả**: Tra cứu chi tiết giao dịch theo ID, bao gồm trạng thái, số tiền, thông tin thụ hưởng và trace log.  
* **Endpoint**: GET /v1/reconciliation/transactions  
* **Mô tả**: Tra cứu danh sách giao dịch theo tiêu chí (ngày, số tiền, trạng thái, loại giao dịch). Hỗ trợ phân trang.  
* **Endpoint**: GET /v1/reconciliation/transactions/{TransactionId}/status  
* **Mô tả**: Kiểm tra trạng thái giao dịch real-time, đặc biệt hữu ích cho các giao dịch PENDING hoặc TIMEOUT.

#### **5.6.2. Đối Soát Tự Động (Automated Reconciliation)**

* **Endpoint**: POST /v1/reconciliation/reports  
* **Mô tả**: Tạo yêu cầu xuất báo cáo đối soát cho khoảng thời gian cụ thể.  
* **Định dạng hỗ trợ**: ISO 20022 camt.053 (Bank to Customer Statement), CSV, Excel, JSON.  
* **Phương thức giao**: SFTP, API Download, Email.  
* **Endpoint**: GET /v1/reconciliation/reports/{ReportId}  
* **Mô tả**: Kiểm tra trạng thái báo cáo đối soát (PROCESSING, COMPLETED, FAILED).  
* **Endpoint**: GET /v1/reconciliation/reports/{ReportId}/download  
* **Mô tả**: Tải xuống file báo cáo đối soát đã hoàn thành.  
* **Endpoint**: POST /v1/reconciliation/match  
* **Mô tả**: TPP gửi danh sách giao dịch để hệ thống tự động so khớp với dữ liệu ngân hàng và phát hiện sai lệch (STATUS_MISMATCH, MISSING_IN_BANK, MISSING_IN_TPP, AMOUNT_MISMATCH).

#### **5.6.3. Tra Soát & Khiếu Nại (Dispute Management)**

* **Endpoint**: POST /v1/reconciliation/disputes  
* **Mô tả**: Tạo yêu cầu tra soát cho giao dịch có vấn đề. Bao gồm loại tra soát, lý do, thông tin khách hàng và bằng chứng đính kèm.  
* **Loại tra soát**: TRANSACTION_NOT_COMPLETED, WRONG_AMOUNT, DUPLICATE_CHARGE, UNAUTHORIZED_TRANSACTION.  
* **Endpoint**: GET /v1/reconciliation/disputes/{DisputeId}  
* **Mô tả**: Theo dõi trạng thái tra soát (SUBMITTED, ACKNOWLEDGED, INVESTIGATING, RESOLVED, REJECTED) và timeline xử lý.  
* **Endpoint**: PUT /v1/reconciliation/disputes/{DisputeId}  
* **Mô tả**: Cập nhật thông tin hoặc bổ sung bằng chứng cho yêu cầu tra soát.  
* **Endpoint**: GET /v1/reconciliation/disputes/{DisputeId}/resolution  
* **Mô tả**: Xem kết quả tra soát chi tiết (REFUND, COMPLETED, REJECTED, PENDING_CUSTOMER).  
* **Endpoint**: GET /v1/reconciliation/disputes  
* **Mô tả**: Danh sách tất cả yêu cầu tra soát với khả năng lọc theo trạng thái, ngày, loại tra soát.

#### **5.6.4. Webhook cho Tra Soát & Đối Soát**

* **Endpoint**: POST /v1/reconciliation/webhooks  
* **Mô tả**: Đăng ký webhook để nhận thông báo chủ động khi có sự kiện xảy ra, giảm tải polling.  
* **Events hỗ trợ**: DISPUTE_STATUS_CHANGED, REPORT_COMPLETED, MATCHING_DISCREPANCY_FOUND, TRANSACTION_REVERSED.  
* **Bảo mật**: Webhook payload được ký bằng HMAC-SHA256 với Secret key do TPP cung cấp.

#### **5.6.5. Yêu Cầu Bảo Mật & Tuân Thủ**

* **Rate Limiting**: Tra cứu giao dịch (100 requests/phút), Tạo báo cáo đối soát (10 requests/giờ), Tạo tra soát (50 requests/giờ).  
* **Data Retention**: Dữ liệu tra soát và đối soát phải lưu trữ tối thiểu 5 năm theo quy định NHNN.  
* **Audit Log**: Mọi thao tác tra cứu, đối soát, tra soát phải được ghi log đầy đủ (Who, What, When, Result).  
* **Access Control**: Phân quyền dựa trên RBAC (Role-Based Access Control). Chỉ nhân viên có quyền của TPP mới được truy cập.  
* **Data Masking**: Thông tin nhạy cảm (số thẻ, số tài khoản) phải được che một phần trong response (ví dụ: 123456\*\*\*\*7890).

## ---

**6\. Portal Tra Cứu & Đối Soát Giao Dịch (Reconciliation & Dispute Management)**

Đây là phân hệ quan trọng giúp TPP và Ngân hàng quản lý, tra soát và đối chiếu dữ liệu giao dịch, đảm bảo tính chính xác về mặt kế toán và giải quyết khiếu nại của khách hàng (Dispute Resolution).

### **6.1. Chức Năng Tra Cứu Giao Dịch (Transaction Lookup Portal)**

Portal này cung cấp giao diện Web cho nhân viên vận hành của TPP và Ngân hàng.

* **Khả năng tìm kiếm nâng cao (Search Capability)**:  
  * Tìm kiếm theo TransactionID (Mã giao dịch của TPP), BankReference (Mã tham chiếu ngân hàng), TraceNumber (Số trace Napas).  
  * Lọc theo trạng thái (Success, Pending, Failed, Timeout), khoảng thời gian, loại giao dịch (PIS, Bill Pay).  
* **Chi tiết giao dịch (Transaction Detail View)**:  
  * Hiển thị đầy đủ luồng đi của giao dịch: TPP \-\> API Gateway \-\> Core Banking \-\> Napas/Biller \-\> Kết quả.  
  * **Trace Log**: Cho phép xem log Request/Response của từng bước (được che mờ các thông tin nhạy cảm như PAN, PIN) để hỗ trợ debug lỗi kỹ thuật.  
* **Phân quyền (RBAC)**: TPP chỉ nhìn thấy giao dịch của chính mình. Admin Ngân hàng nhìn thấy toàn bộ.

### **6.2. Quy Trình Đối Soát Tự Động (Automated Reconciliation Process)**

Để đảm bảo khớp đúng số liệu giữa TPP và Ngân hàng, hệ thống hỗ trợ quy trình đối soát định kỳ (thường là T+1).

* **Chu kỳ đối soát**:  
  * **Daily Reconciliation (T+1)**: Đối soát toàn bộ giao dịch ngày T vào 9:00 AM ngày T+1.  
* **Cơ chế trao đổi file**:  
  * **Ngân hàng cung cấp**: Hệ thống tự động xuất file đối soát (Master File) chứa toàn bộ giao dịch thành công/đảo giao dịch trong ngày và đẩy lên SFTP Server của TPP hoặc cho phép tải về từ Portal.  
  * **Định dạng file (Standard Format)**:  
    * Ưu tiên sử dụng chuẩn **ISO 20022 camt.053** (Bank to Customer Statement) để đảm bảo tính chuẩn hóa quốc tế.  
    * Hỗ trợ định dạng CSV/Excel cho các TPP nhỏ chưa hỗ trợ XML phức tạp.  
* **Logic Đối soát (Matching Logic)**:  
  * Hệ thống so khớp dựa trên khóa chính: RequestId \+ TransactionDate \+ Amount.  
  * **Phát hiện sai lệch (Discrepancy Detection)**:  
    * *Lệch trạng thái*: TPP ghi nhận Timeout nhưng Ngân hàng ghi nhận Success.  
    * *Lệch số tiền*: Số tiền yêu cầu khác số tiền hạch toán.  
    * *Giao dịch thừa/thiếu*: Có ở bên này nhưng không có ở bên kia.

### **6.3. Quản Lý Tra Soát & Khiếu Nại (Dispute Management System \- DMS)**

Khi phát hiện sai lệch hoặc khách hàng khiếu nại, TPP sử dụng module này để gửi yêu cầu tra soát.

* **Quy trình Tra soát (Workflow)**:  
  1. **Tạo yêu cầu (Create Ticket)**: TPP tạo ticket trên Portal, đính kèm bằng chứng (Log, Ảnh chụp màn hình). Hệ thống sinh CaseID.  
  2. **Tiếp nhận & Xử lý (Investigation)**:  
     * Nếu giao dịch nội bộ: Nhân viên vận hành Ngân hàng kiểm tra Core Banking.  
     * Nếu giao dịch Napas 24/7: Hệ thống hỗ trợ tạo điện tra soát tự động gửi sang Napas/Ngân hàng thụ hưởng.  
  3. **Phản hồi kết quả (Resolution)**:  
     * Ngân hàng cập nhật kết quả: "Giao dịch thành công", "Giao dịch thất bại \- Đã hoàn tiền", "Chờ xử lý".  
  4. **Hoàn tiền (Refund/Adjustment)**: Nếu giao dịch lỗi tiền đã trừ nhưng chưa đến đích, hệ thống kích hoạt quy trình hoàn tiền tự động hoặc thủ công (Credit Adjustment).  
* **SLA Management**: Hệ thống đếm ngược thời gian xử lý theo quy định (ví dụ: tối đa 45 ngày với thẻ quốc tế, 5-7 ngày với Napas) và gửi cảnh báo nếu sắp quá hạn.

### **6.4. Báo Cáo & Xuất Dữ Liệu (Reporting)**

* **Báo cáo Tổng hợp (Summary Report)**: Tổng số lượng giao dịch, tổng giá trị, tỷ lệ thành công/thất bại theo ngày/tháng.  
* **Báo cáo Phí (Fee Report)**: Chi tiết phí dịch vụ TPP phải trả (nếu có) để phục vụ đối chiếu công nợ cuối tháng.  
* **Báo cáo Sai lệch (Exception Report)**: Danh sách các giao dịch bị lệch chưa được xử lý.

## ---

**7\. Mô Hình Thương Mại & Tính Phí (Monetization & Billing)**

Hệ thống phải tích hợp module tính phí (Billing Engine) để hiện thực hóa chiến lược kinh doanh API.11

### **7.1. Phương Pháp Tính Phí**

Dựa trên mô hình của OpenAI và các Big Tech, hệ thống hỗ trợ các phương pháp tính phí linh hoạt 12:

1. **Pay-As-You-Go**: Tính tiền trên từng API request thành công (Ví dụ: 500 VNĐ/lần tra cứu eKYC).  
2. **Subscription (Thuê bao)**: Gói trả trước (Ví dụ: 10 triệu VNĐ/tháng cho 50.000 requests).  
3. **Revenue Share**: Chia sẻ % giá trị giao dịch (Áp dụng cho Bill Payment hoặc vay tiêu dùng).

### **7.2. Cấu Trúc Biểu Phí (Fee Schedule)**

Cần cấu hình linh động cho từng TPP:

* **Basic APIs**: Miễn phí (hoặc phí tượng trưng để chống spam) để khuyến khích kết nối hệ sinh thái.  
* **Premium APIs (eKYC, Credit Scoring)**: Tính phí cao.  
* **Tiered Pricing**:  
  * Tier 1 (0 \- 10k requests): 1.000 VNĐ/req.  
  * Tier 2 (10k \- 100k requests): 800 VNĐ/req.  
  * Tier 3 (\> 100k requests): 500 VNĐ/req.

### **7.3. Hệ Thống Metering & Billing**

* **Metering Service**: Ghi nhận số lượng API call theo thời gian thực vào cơ sở dữ liệu Time-series (như InfluxDB hoặc Prometheus).  
* **Billing Cycle**: Chốt số liệu hàng tháng, xuất hóa đơn tự động và gửi cho TPP.  
* **Quota Enforcement**: Tự động chặn (Block) hoặc bóp băng thông (Throttling) nếu TPP vượt quá hạn mức tín dụng hoặc số dư trả trước.

## ---

**8\. Yêu Cầu Phi Chức Năng (Non-Functional Requirements)**

### **8.1. Hiệu Năng (Performance)**

* **Latency**: Thời gian phản hồi trung bình \< 200ms cho các API truy vấn, \< 1s cho API giao dịch (không tính thời gian chờ Core Banking).  
* **Throughput**: Hỗ trợ tối thiểu 1.000 TPS (Transactions Per Second) để đáp ứng các chiến dịch flash-sale của TPP thương mại điện tử.  
* **Scalability**: Hệ thống phải có khả năng tự động mở rộng (Auto-scaling) trên nền tảng Container (Kubernetes).

### **8.2. Tính Sẵn Sàng (Availability) & DR**

* **Uptime**: 99.99%.  
* **Disaster Recovery (DR)**: Phải có hệ thống DR site với RPO (Recovery Point Objective) \< 15 phút và RTO (Recovery Time Objective) \< 1 giờ.

### **8.3. Ghi Nhật Ký & Kiểm Toán (Logging & Auditing)**

Tuân thủ Điều 11 Khoản 11 Thông tư 64/2024:

* **Ghi nhật ký toàn bộ việc sử dụng Open API từ bên thứ ba**:
  - Lưu trữ log truy cập (Access Log) và log giao dịch (Transaction Log)
  - **Thời gian lưu trữ**: Tối thiểu **03 tháng** trực tuyến (Online) và **01 năm** sao lưu (Offline)
  - **Nội dung Log**: Phải bao gồm RequestId, Timestamp, Source IP, ClientID, Endpoint, ResponseCode
  - **Bảo mật**: Tuyệt đối không log dữ liệu nhạy cảm (PIN, CVV, Password) dưới dạng clear-text
* **Giám sát hoạt động truy cập** (Điều 11 Khoản 10):
  - Có hệ thống giám sát để phát hiện và ngăn chặn các hành vi truy cập bất thường hoặc trái phép từ bên thứ ba
  - Ghi nhật ký toàn bộ việc sử dụng Open API từ bên thứ ba để phục vụ kiểm tra khi cần thiết
* **Quản lý quyền truy cập** (Điều 11 Khoản 12):
  - Thực hiện cập nhật hoặc thu hồi quyền truy cập dữ liệu của bên thứ ba khi có thay đổi theo hợp đồng
  - Thông báo cho bên thứ ba khi có thay đổi quyền truy cập

## ---

**9\. Lộ Trình Triển Khai (Implementation Roadmap)**

Để đảm bảo tuân thủ mốc thời gian của NHNN theo Điều 14 và 15 Thông tư 64/2024, dự án được chia thành 3 giai đoạn:

### **Giai đoạn 1: Nền tảng & Tuân thủ Cơ bản (Q1-Q2 2025 - Hoàn thành trước 01/07/2025)**

**Mục tiêu:** Thiết lập hạ tầng cốt lõi và tuân thủ yêu cầu báo cáo NHNN theo **Điều 15 Khoản 1**

**Deliverables:**
* ✅ Triển khai API Gateway với Zero Trust Architecture
* ✅ Xây dựng IAM Server hỗ trợ OAuth 2.0 (RFC 6749, RFC 6750) và PKCE (RFC 7636)
* ✅ Developer Portal với sandbox environment và API documentation
* ✅ Hệ thống thử nghiệm Open API (Điều 9) cách ly hoàn toàn với Core Banking
* ✅ Phát triển **Open API Cơ bản** theo Phụ lục 01:
  - **INF**: Thông tin lãi suất, tỷ giá
  - **AIS**: Danh sách tài khoản, thông tin tài khoản, lịch sử giao dịch
  - OAuth 2.0 flows: Authorization Code + PKCE, Client Credentials
* ✅ Triển khai AI-powered API Security (Phase 1):
  - Real-time threat detection
  - Rate limiting & DDoS protection
  - Anomaly detection baseline
* ✅ **Lập danh mục API và kế hoạch triển khai** gửi Ngân hàng Nhà nước (qua Cục Công nghệ thông tin) **trước 01/07/2025** (Điều 15 Khoản 1)

**Compliance:**
- Thông tư 64/2024/TT-NHNN: Gửi kế hoạch trước deadline
- ISO 27001:2022 hoặc TCVN 11930:2017: Bắt đầu certification process
- Cấp độ an toàn hệ thống: Tối thiểu cấp độ 3

### **Giai đoạn 2: Tích hợp Sâu & An ninh (Q3-Q4 2025 - Hoàn thành trước 01/01/2026)**

**Mục tiêu:** Triển khai các API nghiệp vụ cốt lõi và tăng cường bảo mật

**Deliverables:**
* ✅ **PIS APIs (Payment Initiation Services)** theo Phụ lục 01:
  - Khởi tạo thanh toán (luồng Redirect và Decoupled)
  - Internal transfer
  - Napas 24/7 integration
  - CITAD/IBPS integration
  - Xác thực và lấy sự đồng ý của khách hàng
* ✅ **EWLTS APIs (E-wallet Services)** theo Phụ lục 01:
  - Nạp tiền vào ví điện tử (luồng OTP và Decoupled)
  - Rút tiền ra khỏi ví điện tử
  - **Lưu ý**: Chỉ cung cấp cho Ngân hàng hoặc TCTT (Điều 5 Khoản 3)
* ✅ **eKYC & Biometric Authentication** (Circular 45/2025):
  - OCR document extraction
  - Liveness detection (ISO 30107)
  - Face matching (ISO 19794)
  - NFC CCCD verification (Decision 2345)
  - Integration với database Bộ Công an
* ✅ **Strong Customer Authentication** (Circular 50/2024):
  - Multi-factor authentication (MFA)
  - Biometric authentication (Face ID, Touch ID)
  - Smart OTP & Push notification
  - Risk-based authentication
* ✅ **Portal Đối soát & Tra soát**:
  - Transaction inquiry & tracking
  - Automated reconciliation (T+1)
  - Dispute management system
  - ISO 20022 camt.053 reporting
* ✅ Hoàn thiện quy trình TPP Onboarding theo Điều 8:
  - KYB (Know Your Business)
  - Hợp đồng theo Điều 8 (bảo mật, phí dịch vụ, SLA)
  - Sandbox testing & certification
  - Production deployment
* ✅ Công khai thông tin Open API theo Điều 9:
  - Thông tin Hệ thống thử nghiệm
  - Danh mục các Open API triển khai

**Security Enhancements:**
- Mutual TLS (mTLS) khuyến nghị cho Production
- JWS (RFC 7515) bắt buộc cho API có Body
- Quantum-safe cryptography preparation
- SIEM integration
- Penetration testing & security audit

### **Giai đoạn 3: Hệ sinh thái Toàn diện & Kinh doanh (Q1 2026 - Q1 2027 - Hoàn thành trước 01/03/2027)**

**Mục tiêu:** Mở rộng hệ sinh thái và thương mại hóa API, **tuân thủ hoàn toàn Thông tư 64/2024 trước 01/03/2027** (Điều 15 Khoản 2)

**Deliverables:**
* ✅ **Open API Khác (Premium)** theo Điều 5 Khoản 2:
  - Card Services & Tokenization:
    + Virtual card issuance (instant)
    + Card lifecycle management
    + Push provisioning (Apple Pay, Google Pay, Samsung Pay)
    + Token Service Provider integration (VTS, MDES)
    + 3D Secure 2.0
  - Credit & Lending APIs:
    + Credit scoring as a Service
    + Loan application & approval
    + Credit card onboarding
    + BNPL (Buy Now Pay Later) integration
  - Bill Payment (mở rộng):
    + Payoo, VNPay integration
    + Merchant management
    + Beneficiary inquiry
* ✅ **Advanced Services**:
  - Investment products API
  - Insurance API
  - Wealth management API
  - Open Finance data sharing
* ✅ **Billing & Monetization Platform**:
  - Real-time metering
  - Flexible pricing models (Pay-as-you-go, Subscription, Revenue share)
  - Automated invoicing
  - Usage analytics & optimization
* ✅ **Ecosystem Expansion**:
  - Kết nối ví điện tử (MoMo, ZaloPay, VNPay)
  - Tích hợp sàn TMĐT (Shopee, Lazada, Tiki)
  - ERP integration (SAP, Oracle)
  - Fintech partnerships
* ✅ **Advanced AI & Analytics**:
  - Fraud detection using ML
  - Predictive analytics
  - Customer behavior analysis
  - API performance optimization

**Compliance & Certification:**
- ✅ **Đạt chứng nhận tuân thủ toàn diện Thông tư 64/2024/TT-NHNN trước 01/03/2027**
- ✅ PCI DSS 4.0 certification
- ✅ ISO 27001:2022 hoặc TCVN 11930:2017 certified
- ✅ FAPI 2.0 conformance testing (khuyến nghị)
- ✅ Quarterly penetration testing
- ✅ Annual security audit

**Performance Targets:**
- API Uptime: 99.99%
- Response time: <200ms (P95) for query APIs
- Throughput: 10,000+ TPS
- Zero-downtime deployment

## ---

**10\. Kết Luận**

Bản Tài liệu Yêu cầu Nghiệp vụ (BRD) này thiết lập một khuôn khổ toàn diện cho việc xây dựng hệ thống Open Banking của Ngân hàng. Bằng cách tuân thủ nghiêm ngặt **Thông tư 64/2024/TT-NHNN** (được công bố trong Công báo số 301+302 ngày 08/02/2025) và các quy định liên quan, hệ thống không chỉ đảm bảo tính pháp lý mà còn tạo ra lợi thế cạnh tranh thông qua công nghệ bảo mật tiên tiến và mô hình kinh doanh hiện đại.

### **Các Điểm Nổi Bật:**

1. **Tuân thủ đầy đủ Phụ lục 01 và 02**: Triển khai chính xác các Open API cơ bản (INF, AIS, PIS, EWLTS) theo đặc tả kỹ thuật và tiêu chuẩn bảo mật quy định

2. **Đáp ứng mốc thời gian bắt buộc**:
   - **01/07/2025**: Gửi danh mục API và kế hoạch triển khai cho NHNN (Điều 15 Khoản 1)
   - **01/03/2027**: Tuân thủ hoàn toàn các quy định tại Thông tư (Điều 15 Khoản 2)

3. **Tiêu chuẩn kỹ thuật quốc tế kết hợp quy định nội địa**:
   - OAuth 2.0 (RFC 6749, RFC 6750) với PKCE bắt buộc (RFC 7636)
   - JWS (RFC 7515) cho tính toàn vẹn dữ liệu
   - TLS 1.2+ với khuyến nghị mTLS
   - ISO 27001:2022 hoặc TCVN 11930:2017 cho quản lý an ninh thông tin

4. **Bảo vệ quyền lợi khách hàng**:
   - Quản lý consent chặt chẽ với thời hạn tối đa 180 ngày
   - Quyền rút lại sự đồng ý bất cứ lúc nào
   - Giới hạn truy vấn tự động và giám sát truy cập bất thường

5. **Ghi nhật ký và kiểm toán**: Lưu trữ tối thiểu 3 tháng online và 1 năm offline, đảm bảo truy vết và kiểm tra khi cần thiết

Việc đầu tư vào kiến trúc chuẩn quốc tế ngay từ đầu sẽ giúp Ngân hàng giảm thiểu rủi ro kỹ thuật, tối ưu hóa chi phí vận hành và sẵn sàng cho sự bùng nổ của nền kinh tế số tại Việt Nam. Hệ thống Open Banking không chỉ là yêu cầu tuân thủ pháp luật mà còn là nền tảng để xây dựng hệ sinh thái tài chính mở, tạo giá trị cho khách hàng và đối tác.

#### **Works cited**

1. Thông tư số 64/2024/TT-NHNN của Ngân hàng Nhà nước Việt Nam \- Hệ thống văn bản, accessed December 10, 2025, [https://vanban.chinhphu.vn/?pageid=27160\&docid=212621\&classid=1](https://vanban.chinhphu.vn/?pageid=27160&docid=212621&classid=1)  
2. Từ 01/3/2025, triển khai Open API trong ngành Ngân hàng \- LuatVietnam, accessed December 10, 2025, [https://luatvietnam.vn/tin-van-ban-moi/tu-01-3-2025-trien-khai-open-api-trong-nganh-ngan-hang-186-100851-article.html](https://luatvietnam.vn/tin-van-ban-moi/tu-01-3-2025-trien-khai-open-api-trong-nganh-ngan-hang-186-100851-article.html)  
3. Innovation, Inclusion, and Interoperability \- Vietnam's Leap into ..., accessed December 10, 2025, [https://wso2.com/library/blogs/innovation-inclusion-interoperability-vietnams-leap-into-open-banking/](https://wso2.com/library/blogs/innovation-inclusion-interoperability-vietnams-leap-into-open-banking/)  
4. How Open Banking is Evolving in Vietnam with The New Circular 64 \- Brankas Blog, accessed December 10, 2025, [https://blog.brankas.com/How-Open-Banking-is-Evolving-in-Vietnam-with-The-New-Circular-64](https://blog.brankas.com/How-Open-Banking-is-Evolving-in-Vietnam-with-The-New-Circular-64)  
5. Decision 2345/QD-NHNN 2023 methods to ensure secure online payments and bank card payments \- LuatVietnam.vn \- Legal documents of Vietnamese laws, accessed December 10, 2025, [https://english.luatvietnam.vn/tai-chinh/decision-2345-qd-nhnn-2023-methods-to-ensure-secure-online-payments-bank-card-payments-285123-d1.html](https://english.luatvietnam.vn/tai-chinh/decision-2345-qd-nhnn-2023-methods-to-ensure-secure-online-payments-bank-card-payments-285123-d1.html)  
6. Enhancing Confidentiality and Security for Digital Bank Customers \- DIV, accessed December 10, 2025, [https://www.div.gov.vn/enhancing-confidentiality-and-security-for-digital-bank-customers1](https://www.div.gov.vn/enhancing-confidentiality-and-security-for-digital-bank-customers1)  
7. Bản in \- Ngân hàng Nhà nước Việt Nam, accessed December 10, 2025, [https://vbpl.vn/nganhangnhanuoc/Pages/vbpq-toanvan.aspx?ItemID=174547\&dvid=326](https://vbpl.vn/nganhangnhanuoc/Pages/vbpq-toanvan.aspx?ItemID=174547&dvid=326)  
8. The Essential guide to Open Banking Read-Write API Profile \- v4.0, accessed December 10, 2025, [https://info.ozoneapi.com/hubfs/The%20Essential%20guide%20to%20Open%20Banking%20Read-Write%20API%20Profile%20-%20v4.0.pdf?hsLang=en](https://info.ozoneapi.com/hubfs/The%20Essential%20guide%20to%20Open%20Banking%20Read-Write%20API%20Profile%20-%20v4.0.pdf?hsLang=en)  
9. Open Banking Read-Write API Profile \- v4.0 \- GitHub Pages, accessed December 10, 2025, [https://openbankinguk.github.io/read-write-api-site3/v4.0/profiles/read-write-data-api-profile.html](https://openbankinguk.github.io/read-write-api-site3/v4.0/profiles/read-write-data-api-profile.html)  
10. Vietnam Open Banking and API Standards Gap Assessment \- Brankas, accessed December 10, 2025, [https://www.brankas.com/vietnam-open-banking-api-gap-assessment](https://www.brankas.com/vietnam-open-banking-api-gap-assessment)  
11. Vietnam Open Banking Market Size and Forecasts 2031 \- Mobility Foresights, accessed December 10, 2025, [https://mobilityforesights.com/product/vietnam-open-banking-market](https://mobilityforesights.com/product/vietnam-open-banking-market)  
12. Azure OpenAI Service \- Pricing, accessed December 10, 2025, [https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/openai-service/)  
13. Circular 64/2024/TT-NHNN deployment of open application programming interfaces in the banking sector \- LuatVietnam.vn \- Legal documents of Vietnamese laws, accessed December 10, 2025, [https://english.luatvietnam.vn/tai-chinh/circular-64-2024-tt-nhnn-deployment-of-open-application-programming-interfaces-in-the-banking-sector-387124-d1.html](https://english.luatvietnam.vn/tai-chinh/circular-64-2024-tt-nhnn-deployment-of-open-application-programming-interfaces-in-the-banking-sector-387124-d1.html)  
14. NGÂN HÀNG NHÀ NƯỚC VIỆT NAM \- Công Báo, accessed December 10, 2025, [https://congbao.chinhphu.vn/tai-ve-van-ban-so-64-2024-tt-nhnn-44057-54671?format=pdf](https://congbao.chinhphu.vn/tai-ve-van-ban-so-64-2024-tt-nhnn-44057-54671?format=pdf)  
15. OAuth 2.0 | Swagger Docs, accessed December 10, 2025, [https://swagger.io/docs/specification/v3\_0/authentication/oauth2/](https://swagger.io/docs/specification/v3_0/authentication/oauth2/)  
16. Implementing OAuth 2.0 in REST APIs: Complete Guide, accessed December 10, 2025, [https://blog.dreamfactory.com/implementing-oauth-2.0-in-rest-apis-complete-guide](https://blog.dreamfactory.com/implementing-oauth-2.0-in-rest-apis-complete-guide)  
17. Create a Token \- SVB Developer Portal \- Silicon Valley Bank, accessed December 10, 2025, [https://developer.svb.com/apis/commercial-banking-apis/authorization-api/1.0/authorization-api?path=/v1/security/oauth/token\&method=post](https://developer.svb.com/apis/commercial-banking-apis/authorization-api/1.0/authorization-api?path=/v1/security/oauth/token&method=post)  
18. Giải pháp Open Finance tuân thủ Thông tư 64 – Sự hợp tác giữa Gimasys và Brankas, accessed December 10, 2025, [https://gimasys.com/giai-phap-open-finance-tuan-thu-thong-tu-64/](https://gimasys.com/giai-phap-open-finance-tuan-thu-thong-tu-64/)  
19. Thông tư 64/2024/TT-NHNN quy định về triển khai giao diện lập trình ứng dụng mở trong ngành Ngân hàng \- LuatVietnam, accessed December 10, 2025, [https://luatvietnam.vn/tai-chinh/thong-tu-64-2024-tt-nhnn-cua-ngan-hang-nha-nuoc-viet-nam-quy-dinh-ve-trien-khai-giao-dien-lap-trinh-ung-dung-mo-trong-nganh-ngan-hang-387124-d1.html](https://luatvietnam.vn/tai-chinh/thong-tu-64-2024-tt-nhnn-cua-ngan-hang-nha-nuoc-viet-nam-quy-dinh-ve-trien-khai-giao-dien-lap-trinh-ung-dung-mo-trong-nganh-ngan-hang-387124-d1.html)  
20. Open Banking v4.0 Released: Key Updates Explained \- Macro Global, accessed December 10, 2025, [https://www.macroglobal.co.uk/blog/regulatory-technology/open-banking-version-4-updation-explained/](https://www.macroglobal.co.uk/blog/regulatory-technology/open-banking-version-4-updation-explained/)  
21. Account and Transaction API Profile \- v4.0 \- GitHub Pages, accessed December 10, 2025, [https://openbankinguk.github.io/read-write-api-site3/v4.0/profiles/account-and-transaction-api-profile](https://openbankinguk.github.io/read-write-api-site3/v4.0/profiles/account-and-transaction-api-profile)  
22. Interbank Transfer Napas (SA) \- API PORTAL, accessed December 10, 2025, [https://develop.ncb-bank.vn/api-overview/interbank-transfer-napas-mb-overview](https://develop.ncb-bank.vn/api-overview/interbank-transfer-napas-mb-overview)  
23. Interbank Transfer Napas (SA) \- API PORTAL, accessed December 10, 2025, [https://develop.ncb-bank.vn/api-overview/interbank-transfer-napas-mb-use-cases](https://develop.ncb-bank.vn/api-overview/interbank-transfer-napas-mb-use-cases)  
24. List of citad codes | AppotaPay, accessed December 10, 2025, [https://docs.appotapay.com/en/firm-banking/citad/codes](https://docs.appotapay.com/en/firm-banking/citad/codes)  
25. CITAD Fund Transfer (SA) \- API PORTAL, accessed December 10, 2025, [https://develop.ncb-bank.vn/api-overview/citad-fund-transfer-overview](https://develop.ncb-bank.vn/api-overview/citad-fund-transfer-overview)  
26. Bill Payment API \- UfitPay.com, accessed December 10, 2025, [https://ufitpay.com/bill-payment-api](https://ufitpay.com/bill-payment-api)  
27. Card Lifecycle | Nium Documentation, accessed December 10, 2025, [https://docs.nium.com/docs/card-life-cycle](https://docs.nium.com/docs/card-life-cycle)  
28. Overview | Device Tokenization Developer Site, accessed December 10, 2025, [https://developers.google.com/pay/issuers/tsp-integration/overview](https://developers.google.com/pay/issuers/tsp-integration/overview)  
29. Push Provisioning APIs & Issuer Console \- Google Help, accessed December 10, 2025, [https://support.google.com/console/answer/15157842?hl=en](https://support.google.com/console/answer/15157842?hl=en)  
30. API Reference | MDES Token Connect \- Mastercard Developers, accessed December 10, 2025, [https://developer.mastercard.com/mdes-token-connect/documentation/api-reference/](https://developer.mastercard.com/mdes-token-connect/documentation/api-reference/)  
31. Push provisioning to card schemes & Click to Pay, accessed December 10, 2025, [https://developer.dbp.thalescloud.io/docs/tsh-token-push-and-control/624ed656f504d-push-provisioning-to-card-schemes-and-click-to-pay](https://developer.dbp.thalescloud.io/docs/tsh-token-push-and-control/624ed656f504d-push-provisioning-to-card-schemes-and-click-to-pay)  
32. Electronic know your customer \- VNPT AI, accessed December 10, 2025, [https://vnptai.io/img/update/ekyc/VNPT%20eKYC\_Sale%20kit%20\[EN\].pdf](https://vnptai.io/img/update/ekyc/VNPT%20eKYC_Sale%20kit%20[EN].pdf)  
33. Comparison of Liveness Detection Methods \- FPT AI Vision Documentation, accessed December 10, 2025, [https://docs-vision.fpt.ai/en/ekyc/IV-guides/comparing%20liveness%20methods/](https://docs-vision.fpt.ai/en/ekyc/IV-guides/comparing%20liveness%20methods/)  
34. Giải pháp | VNPT eKYC IDCheck \- VNPT AI, accessed December 10, 2025, [https://vnptai.io/ekyc/en/solution-idcheck](https://vnptai.io/ekyc/en/solution-idcheck)  
35. Pricing | OpenAI API, accessed December 10, 2025, [https://platform.openai.com/docs/pricing](https://platform.openai.com/docs/pricing)