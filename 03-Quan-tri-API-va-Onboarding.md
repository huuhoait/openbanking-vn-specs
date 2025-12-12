# Quản Trị API & Onboarding TPP

## Tổng Quan

Quy trình onboarding TPP (Third Party Provider) từ môi trường Sandbox đến Production, bao gồm quản lý vòng đời API và Developer Portal.

## Quy Trình Onboarding TPP

```mermaid
%%{init: {'theme':'base', 'themeVariables': { 'fontSize':'14px'}}}%%
flowchart TB
    subgraph Phase1["🔰 PHASE 1: ĐĂNG KÝ & XÁC THỰC (3-5 ngày làm việc)"]
        direction TB
        Start([⭐ BẮT ĐẦU]) --> Register["📝 TPP Đăng Ký<br/>---<br/>• Thông tin công ty<br/>• Email liên hệ<br/>• Số điện thoại"]
        Register --> Submit["📤 Nộp Hồ Sơ<br/>---<br/>• Giấy ĐKKD<br/>• Giấy phép TGTT<br/>• Giấy ủy quyền"]
        Submit --> Review{"🔍 Xét Duyệt KYB<br/>---<br/>Ngân hàng thẩm định"}
        
        Review -->|"❌ Không đạt"| Reject1["⛔ TỪ CHỐI<br/>---<br/>• Thông báo lý do<br/>• Hướng dẫn bổ sung"]
        Review -->|"✅ Đạt yêu cầu"| Approve1["✅ PHÊ DUYỆT<br/>---<br/>Tạo tài khoản Sandbox"]
    end

    subgraph Phase2["🧪 PHASE 2: KIỂM THỬ SANDBOX (2-4 tuần)"]
        direction TB
        Approve1 --> GetAccess["🔑 Cấp Quyền Truy Cập<br/>---<br/>• Client ID/Secret UAT<br/>• API Documentation<br/>• Mock Data"]
        GetAccess --> DevTest["💻 Phát Triển & Kiểm Thử<br/>---<br/>• Tích hợp API<br/>• Test với Mock Data<br/>• Xử lý lỗi"]
        DevTest --> RunTest["🧪 Chạy Test Suite<br/>---<br/>• Functional Tests<br/>• Security Tests<br/>• Performance Tests"]
        RunTest --> CheckResult{"📊 Đánh Giá Kết Quả<br/>---<br/>Phải đạt 100%"}
        
        CheckResult -->|"❌ Chưa đạt"| FixBug["🔧 Sửa Lỗi & Thử Lại<br/>---<br/>• Xem logs<br/>• Debug<br/>• Retest"]
        FixBug --> RunTest
        CheckResult -->|"✅ Pass 100%"| RequestProd["🚀 Yêu Cầu Go-Live<br/>---<br/>• Submit báo cáo test<br/>• Cam kết SLA"]
    end

    subgraph Phase3["🏭 PHASE 3: TRIỂN KHAI PRODUCTION (1-2 tuần)"]
        direction TB
        RequestProd --> Legal["📋 Ký Kết Hợp Đồng<br/>---<br/>• Hợp đồng dịch vụ<br/>• Điều khoản SLA<br/>• Bảng giá"]
        Legal --> Security["🔐 Cấu Hình Bảo Mật<br/>---<br/>• Upload Public Key<br/>• Cấp mTLS Certificate<br/>• IP Whitelisting"]
        Security --> FinalApproval{"✓ Phê Duyệt Cuối<br/>---<br/>Ban Giám Đốc"}
        
        FinalApproval -->|"❌ Từ chối"| Reject2["⛔ KHÔNG PHÊ DUYỆT<br/>---<br/>Yêu cầu bổ sung"]
        FinalApproval -->|"✅ Chấp thuận"| Deploy["🎯 Kích Hoạt Production<br/>---<br/>• Production Credentials<br/>• Môi trường thật<br/>• Dữ liệu thật"]
    end

    subgraph Phase4["📈 PHASE 4: VẬN HÀNH (Liên tục)"]
        direction TB
        Deploy --> Live["🟢 HOẠT ĐỘNG<br/>---<br/>• Xử lý giao dịch<br/>• Giám sát real-time<br/>• Báo cáo định kỳ"]
        Live --> Monitor{"📊 Giám Sát SLA<br/>---<br/>• Uptime ≥ 99.9%<br/>• Response time<br/>• Error rate"}
        
        Monitor -->|"✅ Đạt SLA"| Live
        Monitor -->|"⚠️ Vi phạm thường xuyên"| Suspend["⏸️ TẠM NGƯNG<br/>---<br/>• Cảnh báo<br/>• Yêu cầu khắc phục<br/>• Thời hạn 30 ngày"]
        Monitor -->|"🚨 Vi phạm nghiêm trọng"| Revoke["🔴 THU HỒI<br/>---<br/>• Ngừng dịch vụ<br/>• Thanh lý hợp đồng"]
        
        Suspend --> Recovery{"🔄 Khắc Phục?"}
        Recovery -->|"✅ Thành công"| Live
        Recovery -->|"❌ Không khắc phục"| Revoke
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

### Giai Đoạn 1: Đăng Ký & KYB

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Portal as Developer Portal
    participant KYB as KYB Service
    participant Admin as Bank Admin
    
    TPP->>Portal: Đăng ký tài khoản
    Portal->>TPP: Email xác thực
    TPP->>Portal: Xác nhận email
    
    TPP->>Portal: Upload hồ sơ doanh nghiệp<br/>- Giấy ĐKKD<br/>- Giấy phép TGTT<br/>- Thông tin đại diện
    Portal->>KYB: Xác thực hồ sơ
    KYB->>KYB: OCR + Validation
    KYB->>Admin: Yêu cầu phê duyệt
    Admin->>Admin: Thẩm định thủ công
    
    alt Approved
        Admin->>Portal: Phê duyệt
        Portal->>TPP: Kích hoạt tài khoản Sandbox
    else Rejected
        Admin->>Portal: Từ chối + Lý do
        Portal->>TPP: Thông báo từ chối
    end
```

### Giai Đoạn 2: Sandbox Testing

```mermaid
graph TB
    subgraph "Developer Portal"
        CreateApp[Tạo Application]
        GetCreds[Nhận Client ID/Secret UAT]
        ViewDocs[Xem API Documentation]
        TryAPI[Try It Out]
    end
    
    subgraph "Testing Environment"
        MockData[Mock Data Generator]
        TestSuite[Automated Test Suite]
        Postman[Postman Collection]
    end
    
    subgraph "Validation"
        AutoTest[Auto Test Execution]
        Report[Test Report Generation]
        Score[Compliance Score]
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
    
    Score -->|Pass 100%| GoLive[Request Go-Live]
    Score -->|Fail| TryAPI
```

### Giai Đoạn 3: Production Deployment

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Portal as Portal
    participant Legal as Legal Team
    participant Security as Security Team
    participant Admin as Admin
    
    TPP->>Portal: Submit Go-Live Request
    Portal->>Legal: Tạo hợp đồng
    Legal->>TPP: Gửi hợp đồng điện tử
    TPP->>Legal: Ký hợp đồng (eSign)
    
    Legal->>Security: Yêu cầu cấp Production
    TPP->>Security: Upload Public Key (JWS)<br/>+ CSR (mTLS)
    Security->>Security: Validate Keys
    Security->>Security: Generate Client Credentials
    Security->>Security: Configure IP Whitelist
    
    Security->>Admin: Yêu cầu phê duyệt cuối
    Admin->>Admin: Review & Approve
    
    Admin->>Portal: Activate Production
    Portal->>TPP: Production Credentials<br/>+ mTLS Certificate
    
    TPP->>Portal: Test Production Connectivity
    Portal-->>TPP: Health Check OK
```

## API Lifecycle Management

```mermaid
stateDiagram-v2
    [*] --> Draft: API Design
    Draft --> Review: Submit for Review
    Review --> Draft: Revision Required
    Review --> Published: Approved
    
    Published --> Deprecated: New Version Available
    Deprecated --> Retired: Sunset Period Ended
    
    Published --> Emergency_Patch: Critical Bug
    Emergency_Patch --> Published: Hotfix Applied
    
    Retired --> [*]
    
    note right of Deprecated
        Sunset Policy:
        - 3-6 months notice
        - Email notifications
        - Portal banners
    end note
```

### Versioning Strategy

```mermaid
graph LR
    V1[API v1.0<br/>PUBLISHED] --> V1_1[API v1.1<br/>PUBLISHED]
    V1_1 --> V2[API v2.0<br/>PUBLISHED]
    
    V1 -.->|6 months| V1_D[API v1.0<br/>DEPRECATED]
    V1_D -.->|3 months| V1_R[API v1.0<br/>RETIRED]
    
    style V1_D fill:#ffd43b
    style V1_R fill:#ff6b6b
```

## Developer Portal Features

### Dashboard Overview

```mermaid
graph TB
    subgraph "TPP Dashboard"
        Stats[API Statistics<br/>- Total Calls<br/>- Success Rate<br/>- Avg Latency]
        
        Quota[Quota Usage<br/>- Daily Limit<br/>- Monthly Limit<br/>- Overage Alerts]
        
        Apps[My Applications<br/>- Sandbox Apps<br/>- Production Apps<br/>- Credentials]
        
        Billing[Billing Info<br/>- Current Usage<br/>- Invoice History<br/>- Payment Methods]
    end
    
    subgraph "API Catalog"
        Browse[Browse APIs]
        Docs[Documentation]
        Try[Try It Out]
        Download[Download SDK/Postman]
    end
    
    subgraph "Support"
        Tickets[Support Tickets]
        FAQ[FAQ & Guides]
        Status[System Status]
        Contact[Contact Support]
    end
```

### API Documentation Structure

```mermaid
graph LR
    subgraph "API Spec"
        OAS[OpenAPI 3.0 Spec]
        Swagger[Swagger UI]
        Redoc[ReDoc]
    end
    
    subgraph "Code Examples"
        Curl[cURL Examples]
        JS[JavaScript/Node.js]
        Python[Python]
        Java[Java]
    end
    
    subgraph "Guides"
        QuickStart[Quick Start Guide]
        Auth[Authentication Guide]
        Errors[Error Handling]
        Best[Best Practices]
    end
    
    OAS --> Swagger
    OAS --> Redoc
    
    Swagger --> Curl
    Swagger --> JS
    Swagger --> Python
    Swagger --> Java
```

## Monitoring & Analytics

### Real-time Metrics

```mermaid
graph TB
    subgraph "API Gateway Metrics"
        RPS[Requests per Second]
        Latency[Response Latency<br/>P50, P95, P99]
        Errors[Error Rate<br/>4xx, 5xx]
    end
    
    subgraph "Business Metrics"
        TXN[Transaction Volume]
        Revenue[Revenue Generated]
        TPP_Active[Active TPPs]
    end
    
    subgraph "Alerting"
        Threshold[Threshold Monitoring]
        Anomaly[Anomaly Detection]
        Incident[Incident Management]
    end
    
    RPS --> Threshold
    Latency --> Threshold
    Errors --> Anomaly
    
    Threshold --> Incident
    Anomaly --> Incident
```

### SLA Monitoring

```mermaid
graph LR
    subgraph "SLA Targets"
        Uptime[Uptime: 99.99%]
        Response[Response Time: <200ms]
        Success[Success Rate: >99%]
    end
    
    subgraph "Measurement"
        Monitor[Real-time Monitoring]
        Report[Daily/Monthly Reports]
        Breach[SLA Breach Detection]
    end
    
    subgraph "Actions"
        Alert[Alert Stakeholders]
        Compensate[SLA Credits]
        RCA[Root Cause Analysis]
    end
    
    Uptime --> Monitor
    Response --> Monitor
    Success --> Monitor
    
    Monitor --> Report
    Monitor --> Breach
    
    Breach --> Alert
    Breach --> Compensate
    Breach --> RCA
```

## Rate Limiting & Quota Management

### Rate Limiting Strategy

```mermaid
graph TB
    Request[Incoming Request]
    
    Request --> Check1{Global Limit<br/>1000 req/s?}
    Check1 -->|Exceeded| Reject1[429 Too Many Requests]
    Check1 -->|OK| Check2{Per-Client Limit<br/>100 req/min?}
    
    Check2 -->|Exceeded| Reject2[429 Too Many Requests<br/>+ Retry-After header]
    Check2 -->|OK| Check3{Per-API Limit?}
    
    Check3 -->|Exceeded| Reject3[429 Too Many Requests]
    Check3 -->|OK| Process[Process Request]
    
    Process --> Success[200 OK<br/>+ X-RateLimit headers]
```

### Quota Tiers

| Tier | Monthly Quota | Rate Limit | Price |
|------|---------------|------------|-------|
| Free | 10,000 calls | 10 req/min | 0 VND |
| Basic | 100,000 calls | 50 req/min | 5,000,000 VND |
| Professional | 1,000,000 calls | 100 req/min | 30,000,000 VND |
| Enterprise | Unlimited | Custom | Custom |

## Security Controls

### Access Control Matrix

```mermaid
graph TB
    subgraph "Sandbox Environment"
        S_Public[Public APIs<br/>No Auth Required]
        S_Protected[Protected APIs<br/>OAuth Required]
        S_Mock[Mock Data Only]
    end
    
    subgraph "Production Environment"
        P_IP[IP Whitelisting]
        P_mTLS[Mutual TLS]
        P_OAuth[OAuth 2.0 + JWS]
        P_Real[Real Data]
    end
    
    S_Public -.->|Promote| P_IP
    S_Protected -.->|Promote| P_mTLS
    S_Mock -.->|Promote| P_Real
    
    P_IP --> P_OAuth
    P_mTLS --> P_OAuth
```

### Key Management

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Portal as Portal
    participant HSM as HSM
    participant Vault as Secrets Vault
    
    Note over TPP: Generate Key Pair
    TPP->>Portal: Upload Public Key
    Portal->>Portal: Validate Key Format
    Portal->>Vault: Store Public Key
    
    Note over TPP: Generate CSR
    TPP->>Portal: Upload CSR
    Portal->>HSM: Sign Certificate
    HSM-->>Portal: Signed Certificate
    Portal-->>TPP: Return Certificate
    
    Note over Portal: Rotate Secrets
    Portal->>Vault: Generate New Client Secret
    Vault-->>Portal: New Secret
    Portal->>TPP: Email Notification
    TPP->>Portal: Acknowledge & Update
```

## Compliance & Audit

### Audit Trail

```mermaid
graph LR
    subgraph "Events to Log"
        Login[Login/Logout]
        API[API Calls]
        Config[Config Changes]
        Key[Key Rotation]
    end
    
    subgraph "Log Storage"
        Hot[Hot Storage<br/>3 months]
        Cold[Cold Storage<br/>1 year]
        Archive[Archive<br/>5 years]
    end
    
    subgraph "Analysis"
        SIEM[SIEM Integration]
        Forensics[Forensic Analysis]
        Compliance[Compliance Reports]
    end
    
    Login --> Hot
    API --> Hot
    Config --> Hot
    Key --> Hot
    
    Hot --> Cold
    Cold --> Archive
    
    Hot --> SIEM
    Cold --> Forensics
    Archive --> Compliance
```

## Tài Liệu Tham Khảo
- Thông tư 64/2024/TT-NHNN - Điều 8, 9, 10 (Onboarding)
- Open Banking UK - TPP Onboarding Guidelines
- ISO/IEC 27001 - Access Control
- OWASP API Security Top 10
