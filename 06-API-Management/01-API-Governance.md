# Quản Trị API & Onboarding TPP

> **Tuân thủ:** Thông tư 64/2024/TT-NHNN - Điều 8, 9, 10 | Open Banking UK Standards | FAPI 2.0 | ISO 27001:2022

## Tổng Quan

Quy trình onboarding TPP (Third Party Provider) từ môi trường Sandbox đến Production, bao gồm quản lý vòng đời API và Developer Portal, tuân thủ đầy đủ Thông tư 64/2024/TT-NHNN.

### Mục Tiêu

1. **Tuân thủ pháp lý**: Đáp ứng yêu cầu Điều 8, 9, 10 của Thông tư 64/2024/TT-NHNN
2. **Quản lý TPP hiệu quả**: Từ đăng ký, KYB, testing đến production deployment
3. **API Lifecycle Management**: Quản lý vòng đời API theo chuẩn quốc tế
4. **Developer Experience**: Cung cấp Developer Portal hiện đại với đầy đủ tài liệu và công cụ

## Quy Trình Onboarding TPP

### Tổng Quan Quy Trình (4 Giai Đoạn)

```mermaid
%%{init: {'theme':'base', 'themeVariables': { 'fontSize':'14px'}}}%%
flowchart TB
    subgraph Phase1["🔰 GIAI ĐOẠN 1: ĐĂNG KÝ & XÁC THỰC (3-5 ngày)"]
        direction TB
        Start([⭐ BẮT ĐẦU]) --> Register["📝 TPP Đăng Ký<br/>---<br/>• Thông tin doanh nghiệp<br/>• Giấy ĐKKD<br/>• Giấy phép TGTT"]
        Register --> Submit["📤 Nộp Hồ Sơ KYB<br/>---<br/>• Giấy ủy quyền<br/>• Thông tin đại diện<br/>• Chứng chỉ kỹ thuật"]
        Submit --> Review{"🔍 Thẩm Định KYB<br/>---<br/>Ngân hàng xét duyệt"}
        
        Review -->|"❌ Không đạt"| Reject1["⛔ TỪ CHỐI<br/>---<br/>• Thông báo lý do<br/>• Hướng dẫn bổ sung"]
        Review -->|"✅ Đạt yêu cầu"| Approve1["✅ PHÊ DUYỆT<br/>---<br/>Cấp tài khoản Sandbox"]
    end

    subgraph Phase2["🧪 GIAI ĐOẠN 2: KIỂM THỬ SANDBOX (2-4 tuần)"]
        direction TB
        Approve1 --> GetAccess["🔑 Cấp Quyền Truy Cập<br/>---<br/>• Client ID/Secret UAT<br/>• API Documentation<br/>• Mock Data & Test Suite"]
        GetAccess --> DevTest["💻 Phát Triển & Kiểm Thử<br/>---<br/>• Tích hợp API<br/>• Functional Tests<br/>• Security Tests"]
        DevTest --> RunTest["🧪 Chạy Test Suite<br/>---<br/>• 100+ test cases<br/>• Security validation<br/>• Performance tests"]
        RunTest --> CheckResult{"📊 Đánh Giá Kết Quả<br/>---<br/>Phải đạt 100%"}
        
        CheckResult -->|"❌ Chưa đạt"| FixBug["🔧 Sửa Lỗi<br/>---<br/>• Xem test reports<br/>• Debug & fix<br/>• Retest"]
        FixBug --> RunTest
        CheckResult -->|"✅ Pass 100%"| RequestProd["🚀 Yêu Cầu Go-Live<br/>---<br/>• Báo cáo test đầy đủ<br/>• Cam kết SLA"]
    end

    subgraph Phase3["🏭 GIAI ĐOẠN 3: TRIỂN KHAI PRODUCTION (1-2 tuần)"]
        direction TB
        RequestProd --> Legal["📋 Ký Kết Hợp Đồng<br/>---<br/>• Hợp đồng dịch vụ<br/>• SLA Agreement<br/>• Pricing model"]
        Legal --> Security["🔐 Cấu Hình Bảo Mật<br/>---<br/>• Public Key (JWS)<br/>• mTLS Certificate<br/>• IP Whitelisting"]
        Security --> FinalApproval{"✓ Phê Duyệt Cuối<br/>---<br/>Ban Giám Đốc"}
        
        FinalApproval -->|"❌ Từ chối"| Reject2["⛔ KHÔNG PHÊ DUYỆT<br/>---<br/>Yêu cầu bổ sung"]
        FinalApproval -->|"✅ Chấp thuận"| Deploy["🎯 Kích Hoạt Production<br/>---<br/>• Production Credentials<br/>• Real environment<br/>• Go Live"]
    end

    subgraph Phase4["📈 GIAI ĐOẠN 4: VẬN HÀNH (Liên tục)"]
        direction TB
        Deploy --> Live["🟢 HOẠT ĐỘNG<br/>---<br/>• Xử lý giao dịch<br/>• Real-time monitoring<br/>• Reporting"]
        Live --> Monitor{"📊 Giám Sát SLA<br/>---<br/>• Uptime ≥ 99.9%<br/>• Response < 1s<br/>• Error rate < 1%"}
        
        Monitor -->|"✅ Đạt SLA"| Live
        Monitor -->|"⚠️ Vi phạm"| Suspend["⏸️ TẠM NGƯNG<br/>---<br/>• Warning<br/>• Yêu cầu khắc phục<br/>• Deadline 30 ngày"]
        Monitor -->|"🚨 Nghiêm trọng"| Revoke["🔴 THU HỒI<br/>---<br/>• Ngừng dịch vụ<br/>• Thanh lý hợp đồng"]
        
        Suspend --> Recovery{"🔄 Khắc Phục?"}
        Recovery -->|"✅ Thành công"| Live
        Recovery -->|"❌ Thất bại"| Revoke
    end

    Reject1 -.->|"Có thể đăng ký lại"| Start
    Reject2 -.->|"Bổ sung hồ sơ"| Legal

    classDef startStyle fill:#90EE90,stroke:#2E7D32,stroke-width:3px,color:#000
    classDef successStyle fill:#4CAF50,stroke:#1B5E20,stroke-width:2px,color:#fff
    classDef warningStyle fill:#FFD54F,stroke:#F57F17,stroke-width:2px,color:#000
    classDef errorStyle fill:#EF5350,stroke:#C62828,stroke-width:2px,color:#fff
    classDef processStyle fill:#64B5F6,stroke:#1565C0,stroke-width:2px,color:#000
    classDef decisionStyle fill:#FFB74D,stroke:#E65100,stroke-width:2px,color:#000
    classDef infoStyle fill:#81C784,stroke:#2E7D32,stroke-width:2px,color:#000

    class Start startStyle
    class Live successStyle
    class Suspend warningStyle
    class Reject1,Reject2,Revoke errorStyle
    class Register,Submit,GetAccess,DevTest,Legal,Security,Deploy processStyle
    class Review,CheckResult,FinalApproval,Monitor,Recovery decisionStyle
    class Approve1,RequestProd infoStyle
```

## Chi Tiết Các Giai Đoạn Onboarding

### Giai Đoạn 1: Đăng Ký & KYB (Know Your Business)

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Portal as Developer Portal
    participant KYB as KYB Service
    participant Admin as Bank Admin
    participant NHNN as NHNN Database
    
    TPP->>Portal: 1. Đăng ký tài khoản
    Portal->>TPP: 2. Email xác thực
    TPP->>Portal: 3. Xác nhận email
    
    Note over TPP,Portal: KYB Documentation
    TPP->>Portal: 4. Upload hồ sơ KYB<br/>• Giấy ĐKKD<br/>• Giấy phép TGTT<br/>• Giấy ủy quyền<br/>• Chứng chỉ bảo mật
    
    Portal->>KYB: 5. Khởi tạo xác thực
    KYB->>KYB: 6. OCR + Document Validation
    KYB->>NHNN: 7. Tra cứu thông tin doanh nghiệp
    NHNN-->>KYB: 8. Xác nhận doanh nghiệp hợp lệ
    
    KYB->>Admin: 9. Yêu cầu phê duyệt
    Admin->>Admin: 10. Thẩm định thủ công<br/>• Kiểm tra giấy tờ<br/>• Đánh giá năng lực<br/>• Background check
    
    alt Approved
        Admin->>Portal: 11a. Phê duyệt KYB
        Portal->>TPP: 12a. Kích hoạt Sandbox<br/>• Sandbox URL<br/>• Documentation<br/>• Support contact
    else Rejected
        Admin->>Portal: 11b. Từ chối + Lý do chi tiết
        Portal->>TPP: 12b. Thông báo từ chối<br/>+ Hướng dẫn khắc phục
    end
```

**Yêu Cầu Hồ Sơ KYB:**

| Loại Hồ Sơ | Nội Dung | Định Dạng | Yêu Cầu |
|-------------|----------|-----------|---------|
| **Giấy ĐKKD** | Giấy đăng ký kinh doanh | PDF, JPG | Còn hiệu lực, rõ ràng |
| **Giấy phép TGTT** | Giấy phép cung cấp dịch vụ TGTT | PDF | Theo NĐ 101/2012/NĐ-CP |
| **Giấy ủy quyền** | Ủy quyền cho người đại diện | PDF | Có chữ ký, con dấu |
| **Chứng chỉ bảo mật** | ISO 27001 hoặc tương đương | PDF | Khuyến nghị |
| **Thông tin kỹ thuật** | Team size, experience, infrastructure | JSON/PDF | Bắt buộc |

### Giai Đoạn 2: Sandbox Testing

```mermaid
flowchart TB
    subgraph "Developer Portal"
        CreateApp[1. Tạo Application]
        GetCreds[2. Nhận Credentials<br/>• Client ID<br/>• Client Secret<br/>• Public Key Upload]
        ViewDocs[3. Xem Documentation<br/>• API Reference<br/>• Code Examples<br/>• Postman Collection]
        TryAPI[4. Try It Out<br/>• Interactive API Console<br/>• Mock responses]
    end
    
    subgraph "Testing Environment"
        MockData[Mock Data Generator<br/>• 100+ test accounts<br/>• Various scenarios]
        TestSuite[Automated Test Suite<br/>• 100+ test cases<br/>• Security tests<br/>• Performance tests]
        Postman[Postman Collection<br/>• Pre-built requests<br/>• Environment variables<br/>• Test scripts]
    end
    
    subgraph "Validation & Certification"
        AutoTest[Auto Test Execution<br/>• Functional tests<br/>• Security scan<br/>• Load tests]
        Report[Test Report Generation<br/>• Pass/Fail status<br/>• Detailed logs<br/>• Screenshots]
        Score[Compliance Score<br/>• Must reach 100%<br/>• No critical issues]
        Certificate[Certification<br/>• Sandbox certificate<br/>• Ready for production]
    end
    
    CreateApp --> GetCreds
    GetCreds --> ViewDocs
    ViewDocs --> TryAPI
    
    TryAPI --> MockData
    MockData --> TestSuite
    TestSuite --> Postman
    
    Postman --> AutoTest
    AutoTest --> Report
    Report --> Score
    
    Score -->|Pass 100%| Certificate
    Score -->|Fail| TryAPI
    Certificate --> GoLive[Request Go-Live]
    
    style Certificate fill:#4CAF50,stroke:#1B5E20,color:#fff
    style Score fill:#FFB74D,stroke:#E65100
```

**Test Suite Coverage:**

| Test Category | Test Cases | Pass Criteria |
|---------------|-----------|---------------|
| **Authentication** | OAuth 2.1 + PKCE flow | 100% |
| **Authorization** | Consent management | 100% |
| **Account APIs** | GET /accounts, /balances | 100% |
| **Transaction APIs** | GET /transactions | 100% |
| **Payment APIs** | POST /payments | 100% |
| **Security** | JWS, mTLS, encryption | 100% |
| **Error Handling** | All error scenarios | 100% |
| **Performance** | Response time < SLA | 100% |
| **Idempotency** | Duplicate requests | 100% |
| **Rate Limiting** | Throttling behavior | 100% |

### Giai Đoạn 3: Production Deployment

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Portal as Portal
    participant Legal as Legal Team
    participant Security as Security Team
    participant HSM as HSM
    participant Admin as Admin
    
    Note over TPP,Admin: Production Request
    TPP->>Portal: 1. Submit Go-Live Request<br/>+ Test Report (100% pass)
    Portal->>Portal: 2. Validate test results
    
    Note over Portal,Legal: Contract Signing
    Portal->>Legal: 3. Tạo hợp đồng dịch vụ
    Legal->>TPP: 4. Gửi hợp đồng điện tử<br/>• Service Agreement<br/>• SLA Terms<br/>• Pricing
    TPP->>Legal: 5. Ký hợp đồng (eSign)<br/>+ Upload giấy tờ pháp lý
    
    Note over Legal,Security: Security Setup
    Legal->>Security: 6. Yêu cầu cấp Production
    TPP->>Security: 7. Upload Security Materials<br/>• Public Key (JWS)<br/>• CSR cho mTLS<br/>• IP Whitelist
    
    Security->>Security: 8. Validate Public Key<br/>• Key strength (2048+ bits)<br/>• Key algorithm (RSA/EC)<br/>• Expiry date
    
    Security->>HSM: 9. Generate mTLS Certificate
    HSM-->>Security: 10. Signed Certificate
    
    Security->>Security: 11. Generate Production Credentials<br/>• Client ID<br/>• Client Secret<br/>• API Keys
    
    Security->>Security: 12. Configure Infrastructure<br/>• IP Whitelist<br/>• Rate limits<br/>• Firewall rules
    
    Note over Security,Admin: Final Approval
    Security->>Admin: 13. Yêu cầu phê duyệt cuối
    Admin->>Admin: 14. Review toàn bộ<br/>• Test results<br/>• Contract<br/>• Security setup
    
    alt Approved
        Admin->>Portal: 15a. Activate Production
        Portal->>TPP: 16a. Production Credentials<br/>• Client ID/Secret<br/>• mTLS Certificate<br/>• Production URLs<br/>• API Keys
        
        Note over TPP,Portal: Health Check
        TPP->>Portal: 17. Test Production Connectivity
        Portal-->>TPP: 18. Health Check OK
        Portal->>TPP: 19. Go-Live Confirmation
    else Rejected
        Admin->>Portal: 15b. Reject + Reason
        Portal->>TPP: 16b. Request additional info
    end
```

**Production Checklist:**

- [ ] Test Report: 100% pass all test cases
- [ ] Security Audit: Passed security scan
- [ ] Contract: Signed service agreement
- [ ] Public Key: Uploaded and validated (≥2048 bits)
- [ ] mTLS CSR: Certificate signing request submitted
- [ ] IP Whitelist: Production IPs provided
- [ ] SLA Commitment: Agreed to 99.9% uptime
- [ ] Support Contact: 24/7 contact details
- [ ] Incident Response: Procedures documented
- [ ] Data Protection: GDPR/PDPA compliance confirmed

### Giai Đoạn 4: Vận Hành & Monitoring

```mermaid
flowchart TB
    subgraph "Real-time Monitoring"
        APIGateway[API Gateway]
        Metrics[Metrics Collection<br/>• Request count<br/>• Response time<br/>• Error rate]
        Alerts[Alert Manager<br/>• SLA breach<br/>• High error rate<br/>• Rate limit hit]
    end
    
    subgraph "SLA Monitoring"
        Uptime[Uptime Monitoring<br/>Target: ≥ 99.9%]
        Response[Response Time<br/>Target: < 1s]
        ErrorRate[Error Rate<br/>Target: < 1%]
        Availability[API Availability<br/>Target: 24/7]
    end
    
    subgraph "Compliance & Audit"
        AuditLog[Audit Logging<br/>• All API calls<br/>• Admin actions<br/>• Config changes]
        Report[Monthly Reports<br/>• Usage statistics<br/>• SLA compliance<br/>• Incidents]
        Review[Quarterly Review<br/>• Performance review<br/>• Contract renewal]
    end
    
    subgraph "Actions"
        Warning[⚠️ Warning<br/>• Email alert<br/>• Portal notification]
        Suspension[⏸️ Suspension<br/>• Temporary disable<br/>• 30-day remedy]
        Revocation[🔴 Revocation<br/>• Permanent disable<br/>• Contract termination]
    end
    
    APIGateway --> Metrics
    Metrics --> Uptime
    Metrics --> Response
    Metrics --> ErrorRate
    Metrics --> Availability
    
    Uptime --> AuditLog
    Response --> AuditLog
    ErrorRate --> AuditLog
    
    AuditLog --> Report
    Report --> Review
    
    Metrics --> Alerts
    Alerts -->|Minor violation| Warning
    Alerts -->|Repeated violation| Suspension
    Alerts -->|Critical violation| Revocation
    
    style Warning fill:#FFD54F,stroke:#F57F17
    style Suspension fill:#FF9800,stroke:#E65100
    style Revocation fill:#F44336,stroke:#C62828,color:#fff
```

**SLA Metrics:**

| Metric | Target | Measurement | Action if Breach |
|--------|--------|-------------|------------------|
| **Uptime** | ≥ 99.9% | Monthly | Warning after 2 breaches |
| **Response Time** | < 1s (P95) | Per API call | Investigation if > 1.5s |
| **Error Rate** | < 1% | Per hour | Alert if > 5% |
| **Availability** | 24/7 | Continuous | Immediate alert |
| **Data Accuracy** | 100% | Per transaction | Immediate investigation |
| **Security Incidents** | 0 | Per month | Immediate suspension |

## API Lifecycle Management

### Vòng Đời API

```mermaid
stateDiagram-v2
    [*] --> Draft: API Design
    
    Draft --> Review: Submit for Review
    Review --> Draft: Revision Required
    Review --> Testing: Approved
    
    Testing --> Draft: Failed Testing
    Testing --> Published: Testing Passed
    
    Published --> Deprecated: New Version Released
    Published --> Emergency_Patch: Critical Bug Found
    
    Emergency_Patch --> Published: Hotfix Deployed
    
    Deprecated --> Retired: Sunset Period Ended<br/>(6 months minimum)
    
    Retired --> [*]
    
    note right of Draft
        • API Specification (OpenAPI 3.0)
        • Security review
        • Documentation
    end note
    
    note right of Published
        • Production ready
        • Monitored 24/7
        • Changelog maintained
    end note
    
    note right of Deprecated
        • 6 months notice minimum
        • Email to all TPPs
        • Portal banners
        • Migration guide provided
    end note
```

### API Versioning Strategy

```mermaid
graph TB
    subgraph "Version Timeline"
        V1_0["v1.0<br/>PUBLISHED<br/>Jan 2025"]
        V1_1["v1.1<br/>PUBLISHED<br/>Apr 2025"]
        V2_0["v2.0<br/>PUBLISHED<br/>Jul 2025"]
        V1_0_DEP["v1.0<br/>DEPRECATED<br/>Aug 2025"]
        V1_0_RET["v1.0<br/>RETIRED<br/>Feb 2026"]
    end
    
    V1_0 -->|Minor update| V1_1
    V1_1 -->|Breaking change| V2_0
    V2_0 -.->|Deprecate old| V1_0_DEP
    V1_0_DEP -.->|6 months later| V1_0_RET
    
    style V1_0_DEP fill:#ffd43b,stroke:#F57F17
    style V1_0_RET fill:#ff6b6b,stroke:#C62828
    style V2_0 fill:#4CAF50,stroke:#1B5E20,color:#fff
```

**Versioning Rules:**

1. **Major Version** (v1 → v2): Breaking changes
   - URL changes from `/v1/` to `/v2/`
   - Backward incompatible
   - Minimum 6-month deprecation period for old version

2. **Minor Version** (v1.0 → v1.1): New features, backward compatible
   - No URL change
   - Old clients continue to work
   - New optional parameters

3. **Patch Version** (v1.0.1): Bug fixes
   - No impact on clients
   - Security patches applied immediately

**Sunset Policy:**

| Phase | Duration | Actions |
|-------|----------|---------|
| **Announcement** | T-6 months | Email to all TPPs, Portal banner |
| **Warning** | T-3 months | Weekly emails, API response headers |
| **Final Notice** | T-1 month | Daily emails, Dashboard warnings |
| **Retirement** | T-day | API returns 410 Gone |

## Developer Portal

### Portal Architecture

```mermaid
graph TB
    subgraph "Frontend"
        Landing[Landing Page]
        Docs[API Documentation]
        Console[Interactive Console]
        Dashboard[TPP Dashboard]
    end
    
    subgraph "Authentication"
        Login[Login Service]
        SSO[Single Sign-On]
        MFA[Multi-Factor Auth]
    end
    
    subgraph "Features"
        APIExplorer[API Explorer<br/>• Swagger UI<br/>• Try It Out]
        SDKs[SDK Downloads<br/>• Java<br/>• Python<br/>• Node.js]
        Samples[Code Samples<br/>• curl<br/>• Postman<br/>• Examples]
        Testing[Testing Tools<br/>• Mock Server<br/>• Validators]
    end
    
    subgraph "Management"
        AppMgmt[Application Mgmt<br/>• Create/Edit Apps<br/>• Credentials]
        TeamMgmt[Team Management<br/>• Invite members<br/>• Role assignment]
        Billing[Billing & Usage<br/>• Current usage<br/>• Invoices]
        Support[Support<br/>• Tickets<br/>• FAQ<br/>• Chat]
    end
    
    Landing --> Login
    Login --> SSO
    SSO --> MFA
    MFA --> Docs
    MFA --> Console
    MFA --> Dashboard
    
    Dashboard --> APIExplorer
    Dashboard --> SDKs
    Dashboard --> Samples
    Dashboard --> Testing
    Dashboard --> AppMgmt
    Dashboard --> TeamMgmt
    Dashboard --> Billing
    Dashboard --> Support
```

### TPP Dashboard Features

```mermaid
graph TB
    subgraph "Overview"
        Stats["📊 Statistics<br/>---<br/>• Total API Calls<br/>• Success Rate<br/>• Avg Response Time<br/>• Error Count"]
        
        Health["🏥 Health Status<br/>---<br/>• API Availability<br/>• Incident Alerts<br/>• Maintenance Schedule"]
    end
    
    subgraph "API Management"
        Apps["📱 My Applications<br/>---<br/>• Sandbox Apps<br/>• Production Apps<br/>• Credentials Management"]
        
        Keys["🔑 API Keys<br/>---<br/>• Generate Keys<br/>• Rotate Keys<br/>• Key Permissions"]
        
        Certs["🔐 Certificates<br/>---<br/>• mTLS Certificates<br/>• JWS Public Keys<br/>• Expiry Notifications"]
    end
    
    subgraph "Usage & Billing"
        Usage["📈 Usage Metrics<br/>---<br/>• Daily/Monthly Charts<br/>• By API Endpoint<br/>• By Response Code"]
        
        Quota["⚖️ Quota Management<br/>---<br/>• Current Usage<br/>• Limit Alerts<br/>• Upgrade Options"]
        
        Invoice["💳 Billing<br/>---<br/>• Current Bill<br/>• Invoice History<br/>• Payment Methods"]
    end
    
    subgraph "Support & Docs"
        Docs["📚 Documentation<br/>---<br/>• API Reference<br/>• Guides & Tutorials<br/>• Changelog"]
        
        Tickets["🎫 Support Tickets<br/>---<br/>• Create Ticket<br/>• Track Status<br/>• History"]
        
        Status["🔔 System Status<br/>---<br/>• Uptime Monitor<br/>• Incidents<br/>• Scheduled Maintenance"]
    end
```

### API Documentation Structure

**OpenAPI 3.0 Specification** được cung cấp đầy đủ cho tất cả API:

```yaml
# Example OpenAPI Structure
openapi: 3.0.0
info:
  title: Open Banking API
  version: 1.0.0
  description: |
    Tuân thủ Thông tư 64/2024/TT-NHNN
    
servers:
  - url: https://api.sandbox.bank.vn/v1
    description: Sandbox Environment
  - url: https://api.bank.vn/v1
    description: Production Environment

security:
  - OAuth2:
      - accounts:read
      - payments:write
  - mTLS: []

paths:
  /accounts:
    get:
      summary: Get account list
      security:
        - OAuth2: [accounts:read]
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AccountList'
```

**Documentation Includes:**

- 📖 **API Reference**: Complete endpoint documentation
- 💡 **Getting Started Guide**: Step-by-step tutorial
- 🔐 **Authentication Guide**: OAuth 2.1 + PKCE setup
- 📝 **Code Examples**: curl, JavaScript, Python, Java
- 🧪 **Testing Guide**: How to use Sandbox
- ⚠️ **Error Handling**: Error codes and solutions
- 📊 **Best Practices**: Performance, security tips
- 🔄 **Changelog**: Version history
- 📞 **Support**: Contact information

## Security Controls

### Access Control Matrix

```mermaid
graph TB
    subgraph "Sandbox Environment"
        S_Public["Public APIs<br/>---<br/>• Rate info<br/>• Exchange rate<br/>• Branch locator"]
        S_Protected["Protected APIs<br/>---<br/>• OAuth 2.1 required<br/>• PKCE mandatory<br/>• Mock data only"]
        S_Features["Features<br/>---<br/>• Relaxed rate limits<br/>• Detailed error messages<br/>• Test data reset"]
    end
    
    subgraph "Production Environment"
        P_Security["Security Layers<br/>---<br/>• IP Whitelisting<br/>• mTLS required<br/>• JWS signature"]
        P_OAuth["OAuth 2.1 + FAPI 2.0<br/>---<br/>• PAR (Pushed Authorization)<br/>• DPoP (Proof of Possession)<br/>• Refresh Token Rotation"]
        P_Data["Real Data<br/>---<br/>• Customer accounts<br/>• Live transactions<br/>• Audit logging"]
    end
    
    subgraph "Promotion Process"
        Test[100% Test Pass]
        Contract[Signed Contract]
        Security[Security Review]
        GoLive[Go-Live Approval]
    end
    
    S_Public --> Test
    S_Protected --> Test
    Test --> Contract
    Contract --> Security
    Security --> GoLive
    
    GoLive --> P_Security
    P_Security --> P_OAuth
    P_OAuth --> P_Data
    
    style GoLive fill:#4CAF50,stroke:#1B5E20,color:#fff
```

### Authentication Methods

**Sandbox:**
- OAuth 2.1 với PKCE
- Client credentials flow cho machine-to-machine
- Test certificates provided
- Mock mTLS (không bắt buộc)

**Production:**
- OAuth 2.1 + PKCE (bắt buộc)
- mTLS (mutual TLS) - bắt buộc
- JWS (JSON Web Signature) - bắt buộc cho PIS
- DPoP (Demonstrating Proof of Possession)
- IP Whitelisting

### Key Management

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Portal as Portal
    participant HSM as Hardware Security Module
    participant Vault as Secrets Vault
    
    Note over TPP,Portal: Initial Key Setup
    TPP->>TPP: 1. Generate RSA Key Pair (2048+ bits)
    TPP->>Portal: 2. Upload Public Key (JWS)
    Portal->>Portal: 3. Validate Key<br/>• Key strength<br/>• Algorithm<br/>• Format
    Portal->>Vault: 4. Store Public Key + Metadata
    
    Note over TPP,Portal: mTLS Certificate
    TPP->>TPP: 5. Generate CSR (Certificate Signing Request)
    TPP->>Portal: 6. Upload CSR
    Portal->>HSM: 7. Sign Certificate
    HSM-->>Portal: 8. Signed Certificate
    Portal-->>TPP: 9. Return mTLS Certificate
    
    Note over Portal,Vault: Periodic Key Rotation (Every 90 days)
    Portal->>Vault: 10. Generate New Client Secret
    Vault-->>Portal: 11. New Secret
    Portal->>TPP: 12. Email: Key Rotation Notice
    TPP->>Portal: 13. Acknowledge & Update
    Portal->>Vault: 14. Mark Old Key for Deprecation (30-day grace period)
    
    Note over Portal: After 30 days
    Portal->>Vault: 15. Delete Old Key
```

**Key Requirements:**

| Key Type | Algorithm | Min Strength | Max Age | Rotation |
|----------|-----------|--------------|---------|----------|
| **JWS Signing** | RSA, EC | 2048 bits | 2 years | Manual |
| **mTLS Client Cert** | RSA | 2048 bits | 1 year | Manual before expiry |
| **Client Secret** | Random | 256 bits | 90 days | Automatic |
| **API Keys** | Random | 256 bits | No limit | On demand |

## Rate Limiting & Quota Management

### Rate Limiting Strategy

```mermaid
flowchart TB
    Request["Incoming API Request"]
    
    Request --> Check1{"Global Limit<br/>1000 req/s?"}
    Check1 -->|Exceeded| Reject1["429 Too Many Requests<br/>Retry-After: 1"]
    Check1 -->|OK| Check2{"Per-TPP Limit<br/>100 req/min?"}
    
    Check2 -->|Exceeded| Reject2["429 Too Many Requests<br/>Retry-After: 60<br/>X-RateLimit-Reset: timestamp"]
    Check2 -->|OK| Check3{"Per-API Limit<br/>Varies by endpoint?"}
    
    Check3 -->|Exceeded| Reject3["429 Too Many Requests<br/>Upgrade to higher tier"]
    Check3 -->|OK| Process["Process Request"]
    
    Process --> Success["200 OK<br/>X-RateLimit-Limit: 100<br/>X-RateLimit-Remaining: 87<br/>X-RateLimit-Reset: 1640000000"]
    
    style Reject1 fill:#F44336,color:#fff
    style Reject2 fill:#F44336,color:#fff
    style Reject3 fill:#F44336,color:#fff
    style Success fill:#4CAF50,color:#fff
```

### Quota Tiers

| Tier | Monthly Quota | Rate Limit (req/min) | Price (VND/month) | Support |
|------|---------------|----------------------|-------------------|---------|
| **Sandbox** | Unlimited | 10 | Free | Community |
| **Basic** | 100,000 | 50 | 5,000,000 | Email |
| **Professional** | 1,000,000 | 100 | 30,000,000 | Email + Phone |
| **Enterprise** | Unlimited | Custom | Custom | 24/7 Dedicated |

**Rate Limit Headers:**

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1640000000
X-RateLimit-Tier: Professional
Retry-After: 60
```

## Monitoring & Analytics

### Real-time Metrics Dashboard

```mermaid
graph TB
    subgraph "API Gateway Metrics"
        RPS["📊 Requests/Second<br/>---<br/>• Current: 450<br/>• Peak: 890<br/>• Avg: 320"]
        
        Latency["⏱️ Response Latency<br/>---<br/>• P50: 120ms<br/>• P95: 450ms<br/>• P99: 890ms"]
        
        Errors["❌ Error Rates<br/>---<br/>• 4xx: 2.1%<br/>• 5xx: 0.05%<br/>• Timeout: 0.01%"]
    end
    
    subgraph "Business Metrics"
        TPPs["👥 Active TPPs<br/>---<br/>• Sandbox: 45<br/>• Production: 12<br/>• Total: 57"]
        
        Volume["💰 Transaction Volume<br/>---<br/>• Today: 125K<br/>• This month: 3.2M<br/>• Growth: +15%"]
        
        Revenue["💵 Revenue<br/>---<br/>• This month: 85M VND<br/>• Projected: 102M VND<br/>• YoY: +42%"]
    end
    
    subgraph "Alerts & Actions"
        Threshold["🚨 Threshold Alerts<br/>---<br/>• High error rate<br/>• Slow response<br/>• Quota exceeded"]
        
        Anomaly["🔍 Anomaly Detection<br/>---<br/>• ML-based<br/>• Pattern analysis<br/>• Auto-alert"]
        
        Incident["📞 Incident Mgmt<br/>---<br/>• Create ticket<br/>• Assign team<br/>• Track resolution"]
    end
    
    RPS --> Threshold
    Latency --> Threshold
    Errors --> Anomaly
    
    Threshold --> Incident
    Anomaly --> Incident
```

### SLA Monitoring & Reporting

```mermaid
gantt
    title API Uptime & SLA Tracking (Monthly)
    dateFormat YYYY-MM-DD
    section Uptime
    Target 99.9% :done, target, 2025-01-01, 30d
    Actual 99.95% :active, actual, 2025-01-01, 30d
    
    section Incidents
    Minor Issue :crit, incident1, 2025-01-05, 2h
    Scheduled Maintenance :milestone, maint, 2025-01-15, 4h
    Critical Incident :crit, incident2, 2025-01-22, 1h
    
    section Performance
    Response Time < 1s :done, perf, 2025-01-01, 30d
```

**SLA Reports Include:**

- ✅ Uptime percentage
- ⏱️ Average response time (P50, P95, P99)
- ❌ Error rate breakdown
- 📊 API call volume
- 🔧 Incident summary
- 💰 SLA credits (if applicable)
- 📈 Trend analysis

## Compliance & Audit

### Audit Logging

**Tuân thủ ISO 27001:2022 và Thông tư 64/2024/TT-NHNN**

```mermaid
graph TB
    subgraph "Events to Log"
        Auth["Authentication<br/>---<br/>• Login/Logout<br/>• MFA events<br/>• Failed attempts"]
        
        API["API Calls<br/>---<br/>• Request/Response<br/>• Headers (redacted)<br/>• Payload hash"]
        
        Admin["Admin Actions<br/>---<br/>• Config changes<br/>• User management<br/>• Permission changes"]
        
        Security["Security Events<br/>---<br/>• Key rotation<br/>• Certificate changes<br/>• IP whitelist updates"]
    end
    
    subgraph "Log Storage (Retention Policy)"
        Hot["Hot Storage<br/>---<br/>• Last 90 days<br/>• Fast query<br/>• SSD storage"]
        
        Warm["Warm Storage<br/>---<br/>• 90 days - 1 year<br/>• Slower query<br/>• Cost-effective"]
        
        Cold["Cold Storage<br/>---<br/>• 1-7 years<br/>• Archive<br/>• S3 Glacier"]
    end
    
    subgraph "Analysis"
        SIEM["SIEM Integration<br/>---<br/>• Real-time monitoring<br/>• Threat detection<br/>• Correlation"]
        
        Forensics["Forensic Analysis<br/>---<br/>• Incident investigation<br/>• Root cause<br/>• Evidence preservation"]
        
        Compliance["Compliance Reports<br/>---<br/>• Regulatory audit<br/>• Internal audit<br/>• Third-party audit"]
    end
    
    Auth --> Hot
    API --> Hot
    Admin --> Hot
    Security --> Hot
    
    Hot --> Warm
    Warm --> Cold
    
    Hot --> SIEM
    Warm --> Forensics
    Cold --> Compliance
    
    style Hot fill:#ff6b6b,stroke:#C62828
    style Warm fill:#ffd43b,stroke:#F57F17
    style Cold fill:#64b5f6,stroke:#1565C0
```

**Audit Log Fields:**

```json
{
  "event_id": "evt_20251215_103045_abc123",
  "timestamp": "2025-12-15T10:30:45.123Z",
  "event_type": "api.call",
  "actor": {
    "tpp_id": "TPP-12345",
    "tpp_name": "FinTech Solutions Ltd",
    "ip": "203.162.4.190"
  },
  "action": "GET /v1/accounts",
  "resource": {
    "type": "account",
    "id": "acc_xyz789"
  },
  "result": "success",
  "status_code": 200,
  "response_time_ms": 245,
  "request_id": "req-uuid-1234-5678"
}
```

## Incident Management

### Incident Response Process

```mermaid
flowchart TB
    Detect["🔍 Detection<br/>---<br/>• Automated monitoring<br/>• User reports<br/>• Security alerts"]
    
    Classify{"📋 Classification<br/>---<br/>Severity?"}
    
    P0["🔴 P0 - Critical<br/>---<br/>• System down<br/>• Data breach<br/>• Response: Immediate"]
    
    P1["🟠 P1 - High<br/>---<br/>• Major degradation<br/>• Security vulnerability<br/>• Response: < 1 hour"]
    
    P2["🟡 P2 - Medium<br/>---<br/>• Minor issues<br/>• Feature not working<br/>• Response: < 4 hours"]
    
    P3["🟢 P3 - Low<br/>---<br/>• Cosmetic issues<br/>• Enhancement requests<br/>• Response: < 24 hours"]
    
    Response["🚨 Incident Response<br/>---<br/>• Assemble team<br/>• Investigate root cause<br/>• Deploy fix"]
    
    Communicate["📢 Communication<br/>---<br/>• Status page update<br/>• Email to affected TPPs<br/>• Post-mortem report"]
    
    Resolve["✅ Resolution<br/>---<br/>• Deploy fix<br/>• Verify solution<br/>• Monitor for recurrence"]
    
    PostMortem["📝 Post-Mortem<br/>---<br/>• Root cause analysis<br/>• Lessons learned<br/>• Action items"]
    
    Detect --> Classify
    Classify --> P0
    Classify --> P1
    Classify --> P2
    Classify --> P3
    
    P0 --> Response
    P1 --> Response
    P2 --> Response
    P3 --> Response
    
    Response --> Communicate
    Communicate --> Resolve
    Resolve --> PostMortem
    
    style P0 fill:#F44336,color:#fff
    style P1 fill:#FF9800,color:#fff
    style P2 fill:#FFC107
    style P3 fill:#8BC34A
```

### Status Page

**Public Status Page** (https://status.bank.vn):

- 🟢 All Systems Operational
- 🟡 Partial Outage
- 🔴 Major Outage
- 🔵 Scheduled Maintenance

**Components Monitored:**

- API Gateway
- OAuth Server
- Account Information APIs
- Payment Initiation APIs
- Developer Portal
- Sandbox Environment

**90-Day Uptime History** displayed with incidents.

## Tài Liệu Tham Khảo

### Quy Định Việt Nam
- **Thông tư 64/2024/TT-NHNN** - Quy định Open API trong hoạt động ngân hàng
  - Điều 8: Quản lý cấp quyền truy cập
  - Điều 9: Quy trình onboarding TPP
  - Điều 10: Quản lý vòng đời API
- **Nghị định 13/2023/NĐ-CP** - Bảo vệ dữ liệu cá nhân
- **Circular 45/2025/TT-NHNN** - Xác thực sinh trắc học
- **Circular 50/2024/TT-NHNN** - Strong Customer Authentication

### Tiêu Chuẩn Quốc Tế
- **Open Banking UK** - TPP Onboarding Guidelines v4.0
- **FAPI 2.0** - Financial-grade API Security Profile
- **OAuth 2.1** - Authorization Framework
- **ISO/IEC 27001:2022** - Information Security Management
- **PCI DSS 4.0** - Payment Card Industry Data Security
- **OWASP API Security Top 10 (2023)**

---

**Phiên bản:** 1.0  
**Ngày cập nhật:** 15/12/2025  
**Trạng thái:** Final Draft
