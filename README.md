# Thiết Kế Hệ Thống Open Banking - Chi Tiết Kỹ Thuật

## Giới Thiệu

Đây là tài liệu chi tiết kỹ thuật cho hệ thống Open Banking tuân thủ **Thông tư 64/2024/TT-NHNN** và **Quyết định 2345/QĐ-NHNN**. Tài liệu được chia thành 10 module chính, mỗi module bao gồm:

- ✅ Biểu đồ Mermaid chi tiết
- ✅ Mô tả kiến trúc và luồng xử lý
- ✅ API specifications và examples
- ✅ Security controls và best practices
- ✅ Compliance checklist

## Cấu Trúc Thư Mục

```
open-banking-design/
│
├── README.md                                    # Tổng quan dự án
│
├── 01-Kien-truc-he-thong.md                    # Kiến trúc Microservices tổng thể
├── 02-Bao-mat-va-Xac-thuc.md                   # OAuth 2.0, FAPI, JWS, NFC
├── 03-Quan-tri-API-va-Onboarding.md            # API Lifecycle, TPP Onboarding
├── 04-Dich-vu-Tai-khoan-AIS.md                 # Account Information Services
├── 05-Dich-vu-Thanh-toan-PIS.md                # Payment Initiation Services
├── 06-Dich-vu-The-va-Tokenization.md           # Card Services & Push Provisioning
├── 07-Dich-vu-Dinh-danh-eKYC.md                # eKYC & NFC CCCD Verification
├── 08-Doi-soat-va-Tra-soat.md                  # Reconciliation & Disputes
├── 09-Thuong-mai-hoa-API.md                    # Monetization & Billing
└── 10-Van-hanh-va-NFR.md                       # Operations & Non-Functional Requirements
```

## Tổng Quan Các Module

### 🏗️ [01. Kiến Trúc Hệ Thống](./01-Kien-truc-he-thong.md)

**Nội dung chính:**
- Kiến trúc Microservices tổng thể
- API Gateway và Security Layer
- Integration với Core Banking
- Data Layer và Caching Strategy
- High Availability Architecture

**Công nghệ:**
- API Gateway: Kong / AWS API Gateway
- Service Mesh: Istio
- Message Queue: Kafka / RabbitMQ
- Database: PostgreSQL / Oracle
- Cache: Redis

---

### 🔐 [02. Bảo Mật & Xác Thực](./02-Bao-mat-va-Xac-thuc.md)

**Nội dung chính:**
- OAuth 2.0 Authorization Code Flow with PKCE
- Client Credentials Flow
- JWS (JSON Web Signature) cho Non-Repudiation
- Consent Management Lifecycle
- NFC CCCD Verification (QĐ 2345)
- 4 Cấp độ xác thực

**Tiêu chuẩn:**
- OAuth 2.0 (RFC 6749)
- PKCE (RFC 7636)
- JWS (RFC 7515)
- FAPI Security Profile
- Quyết định 2345/QĐ-NHNN

---

### 🎯 [03. Quản Trị API & Onboarding](./03-Quan-tri-API-va-Onboarding.md)

**Nội dung chính:**
- Quy trình Onboarding TPP (5 giai đoạn)
- API Lifecycle Management
- Developer Portal Features
- Rate Limiting & Quota Management
- SLA Monitoring
- Security Controls

**Giai đoạn Onboarding:**
1. Đăng ký & KYB
2. Sandbox Testing
3. Tích hợp & Kiểm thử
4. Ký hợp đồng
5. Production Deployment

---

### 💰 [04. Dịch Vụ Tài Khoản (AIS)](./04-Dich-vu-Tai-khoan-AIS.md)

**API Endpoints:**
- `GET /v1/accounts` - Danh sách tài khoản
- `GET /v1/accounts/{id}/balances` - Số dư
- `GET /v1/accounts/{id}/transactions` - Lịch sử giao dịch
- `POST /v1/event-subscriptions` - Webhook đăng ký

**Features:**
- Consent-based access
- Real-time balance inquiry
- Transaction history với pagination
- Webhook notifications
- Data masking & security

---

### 💸 [05. Dịch Vụ Thanh Toán (PIS)](./05-Dich-vu-Thanh-toan-PIS.md)

**API Endpoints:**
- `POST /v1/payment-consents` - Tạo consent
- `POST /v1/payments` - Thực hiện thanh toán
- `POST /v1/beneficiary-lookup` - Tra cứu thụ hưởng
- `POST /v1/bill-payments` - Thanh toán hóa đơn

**Payment Channels:**
- Internal Transfer (Real-time)
- Napas 24/7 (< 10 giây)
- CITAD/IBPS (T+1)
- Bill Payment (Payoo, VNPay)

**Security:**
- 2-step consent flow
- JWS signature bắt buộc
- Idempotency support
- Transaction limits enforcement

---

### 💳 [06. Dịch Vụ Thẻ](./06-Dich-vu-The-va-Tokenization.md)

**API Endpoints:**
- `POST /v1/cards/issuance` - Phát hành thẻ
- `PUT /v1/cards/{id}/lock` - Khóa thẻ
- `PUT /v1/cards/{id}/pin` - Đổi PIN
- `POST /v1/tokenization/provision` - Push Provisioning

**Features:**
- Instant Virtual Card
- Card Lifecycle Management
- Apple Pay / Google Pay / Samsung Pay
- Token Service Provider Integration (VTS, MDES)
- 3D Secure 2.0
- Spending Controls

**Compliance:**
- PCI DSS Level 1
- EMV 3DS 2.0
- ISO 9564 (PIN Management)

---

### 🆔 [07. Dịch Vụ Định Danh (eKYC)](./07-Dich-vu-Dinh-danh-eKYC.md)

**API Endpoints:**
- `POST /v1/ekyc/ocr` - OCR giấy tờ
- `POST /v1/ekyc/liveness` - Liveness detection
- `POST /v1/ekyc/face-match` - So khớp khuôn mặt
- `POST /v1/ekyc/nfc-verify` - Xác thực NFC CCCD
- `POST /v1/auth/otp/generate` - Tạo OTP
- `POST /v1/auth/otp/validate` - Xác thực OTP

**eKYC Flow:**
1. Document Capture (Front + Back)
2. OCR Extraction
3. Liveness Detection
4. Face Matching
5. AML/Sanction Check
6. NFC Verification (Level 4)

**Standards:**
- ISO 30107 (Liveness Detection)
- ISO 19794 (Biometric Data)
- ICAO Doc 9303 (Machine Readable Documents)
- Quyết định 2345/QĐ-NHNN

---

### 🔍 [08. Đối Soát & Tra Soát](./08-Doi-soat-va-Tra-soat.md)

**API Endpoints:**
- `GET /v1/reconciliation/transactions/{id}` - Tra cứu giao dịch
- `POST /v1/reconciliation/reports` - Tạo báo cáo đối soát
- `POST /v1/reconciliation/match` - Auto matching
- `POST /v1/reconciliation/disputes` - Tạo tra soát
- `GET /v1/reconciliation/disputes/{id}` - Theo dõi tra soát

**Features:**
- Daily auto-reconciliation (T+1)
- ISO 20022 camt.053 format
- Auto matching engine
- Dispute management workflow
- Webhook notifications
- SFTP file exchange

**SLA:**
- Dispute resolution: 5-7 business days
- Report generation: < 5 minutes

---

### 💵 [09. Thương Mại Hóa](./09-Thuong-mai-hoa-API.md)

**Pricing Models:**
1. **Pay-As-You-Go**: Tính phí theo request
2. **Subscription**: Gói thuê bao hàng tháng
3. **Revenue Share**: Chia sẻ doanh thu
4. **Tiered Pricing**: Giá theo volume

**API Endpoints:**
- `GET /v1/billing/usage/current-month` - Usage hiện tại
- `GET /v1/billing/invoices` - Danh sách hóa đơn
- `POST /v1/billing/payments` - Thanh toán
- `POST /v1/billing/balance/topup` - Nạp tiền

**Features:**
- Real-time metering
- Auto invoice generation
- Multiple payment methods
- Usage analytics
- Cost optimization recommendations

---

### ⚙️ [10. Vận Hành & NFR](./10-Van-hanh-va-NFR.md)

**Performance:**
- Query APIs: < 200ms (P95)
- Transaction APIs: < 1s (P95)
- Throughput: 1,000 - 10,000 TPS

**Availability:**
- SLA: 99.99% uptime
- Multi-AZ deployment
- Active-Active configuration

**Disaster Recovery:**
- RPO: < 15 minutes
- RTO: < 1 hour
- Daily backups (30 days retention)

**Monitoring:**
- Prometheus + Grafana
- ELK Stack (Logs)
- Jaeger (Distributed Tracing)
- PagerDuty (Alerting)

**Security:**
- Quarterly penetration testing
- Monthly security audits
- SIEM integration
- Incident response procedures

---

## Lộ Trình Triển Khai

### 📅 Giai Đoạn 1: Nền Tảng (Q2 2025)

**Mục tiêu:** Hoàn thành trước 01/07/2025

- [ ] API Gateway & IAM
- [ ] Developer Portal
- [ ] Sandbox Environment
- [ ] Basic APIs (Account Info, Balance)
- [ ] Gửi kế hoạch cho NHNN

### 📅 Giai Đoạn 2: Tích Hợp Sâu (Q4 2025)

**Mục tiêu:** Hoàn thành trước 01/01/2026

- [ ] AIS APIs (Full)
- [ ] PIS APIs (Fund Transfer, Bill Payment)
- [ ] eKYC & NFC Verification
- [ ] Reconciliation Portal
- [ ] TPP Onboarding Process

### 📅 Giai Đoạn 3: Hệ Sinh Thái (Q1 2027)

**Mục tiêu:** Hoàn thành trước 01/03/2027

- [ ] Card Services & Tokenization
- [ ] Credit Scoring APIs
- [ ] Billing & Monetization
- [ ] Full Compliance Certification
- [ ] Ecosystem Expansion

---

## Tuân Thủ & Tiêu Chuẩn

### 📜 Quy Định Pháp Lý

- ✅ **Thông tư 64/2024/TT-NHNN** - Open API trong ngành Ngân hàng
- ✅ **Quyết định 2345/QĐ-NHNN** - Xác thực sinh trắc học
- ✅ **Nghị định 13/2023/NĐ-CP** - Bảo vệ dữ liệu cá nhân

### 🌐 Tiêu Chuẩn Quốc Tế

- ✅ **Open Banking UK** - Read/Write API Profile v4.0
- ✅ **ISO 20022** - Financial Messages
- ✅ **ISO 27001** - Information Security Management
- ✅ **PCI DSS** - Payment Card Industry Data Security
- ✅ **FAPI** - Financial-grade API Security Profile

### 🔒 Security Standards

- ✅ **OAuth 2.0** (RFC 6749)
- ✅ **PKCE** (RFC 7636)
- ✅ **JWS** (RFC 7515)
- ✅ **TLS 1.3**
- ✅ **OWASP Top 10**

---

## Công Nghệ Stack

### Backend
- **Language**: Java 17 / Node.js 18
- **Framework**: Spring Boot / NestJS
- **API Gateway**: Kong / AWS API Gateway
- **Service Mesh**: Istio

### Database
- **RDBMS**: PostgreSQL 15 / Oracle 19c
- **NoSQL**: MongoDB (Document Store)
- **Cache**: Redis 7
- **Time-Series**: InfluxDB (Metrics)

### Message Queue
- **Event Streaming**: Apache Kafka
- **Message Broker**: RabbitMQ

### Security
- **IAM**: Keycloak / Auth0
- **HSM**: Thales / AWS CloudHSM
- **Secrets**: HashiCorp Vault

### Monitoring & Logging
- **Metrics**: Prometheus + Grafana
- **Logs**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Tracing**: Jaeger
- **APM**: New Relic / Datadog

### DevOps
- **Container**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: GitLab CI / GitHub Actions
- **IaC**: Terraform

---

## Tài Liệu Tham Khảo

### Văn Bản Pháp Lý
1. [Thông tư 64/2024/TT-NHNN](https://vanban.chinhphu.vn/?pageid=27160&docid=212621)
2. [Quyết định 2345/QĐ-NHNN](https://english.luatvietnam.vn/tai-chinh/decision-2345-qd-nhnn-2023-methods-to-ensure-secure-online-payments-bank-card-payments-285123-d1.html)
3. [Nghị định 13/2023/NĐ-CP](https://vanban.chinhphu.vn/)

### Tiêu Chuẩn Kỹ Thuật
1. [Open Banking UK - API Specifications](https://openbankinguk.github.io/)
2. [ISO 20022 - Financial Messages](https://www.iso20022.org/)
3. [FAPI Security Profile](https://openid.net/wg/fapi/)
4. [OAuth 2.0 Framework](https://oauth.net/2/)

### Best Practices
1. [Google SRE Book](https://sre.google/books/)
2. [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
3. [The Twelve-Factor App](https://12factor.net/)
4. [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)

---

## Liên Hệ & Hỗ Trợ

### Technical Support
- **Email**: api-support@bank.vn
- **Hotline**: 1900-xxxx
- **Portal**: https://developer.bank.vn

### Business Inquiries
- **Email**: openbanking@bank.vn
- **Phone**: (028) 1234-5678

---

## License

© 2024 Bank. All rights reserved.

Tài liệu này là tài sản trí tuệ của Ngân hàng và chỉ được sử dụng cho mục đích nội bộ và đối tác được ủy quyền.

---

**Phiên bản:** 1.0  
**Ngày cập nhật:** 10/12/2024  
**Người soạn:** Open Banking Team
