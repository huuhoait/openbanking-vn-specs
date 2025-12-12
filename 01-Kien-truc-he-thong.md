# Kiến Trúc Hệ Thống Open Banking

## Tổng Quan

Hệ thống Open Banking được thiết kế theo mô hình **Microservices** với API Gateway làm điểm truy cập duy nhất (Single Entry Point) cho tất cả các Third Party Providers (TPP).

## Sơ Đồ Kiến Trúc Tổng Thể


```mermaid
flowchart TB
    %% Define Styles
    classDef external fill:#fcfcfc,stroke:#666,stroke-width:2px,color:#333
    classDef gateway fill:#e3f2fd,stroke:#1565c0,stroke-width:2px,color:#0d47a1
    classDef security fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#4a148c
    classDef service fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#1b5e20
    classDef integration fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#bf360c
    classDef business fill:#f5f5f5,stroke:#455a64,stroke-width:2px,color:#263238
    classDef data fill:#dae8fc,stroke:#6c8ebf,stroke-width:2px,color:#000
    classDef management fill:#e0f2f1,stroke:#00695c,stroke-width:2px,color:#004d40

    %% --- External Layer (Top) ---
    subgraph External [External Layer]
        direction LR
        TPP[Third Party Providers]:::external
        Mobile[Mobile Apps]:::external
        Web[Web Applications]:::external
    end
    
    %% --- Gateway Layer ---
    subgraph Gateway [API Gateway Layer]
        WAF[Web Application Firewall]:::gateway
        APIGW[API Gateway<br/>Rate Limiting / Routing]:::gateway
    end

    %% --- Main Processing Block (Middle) ---
    %% Using invisible links to force columns: Security | Services | Management
    
    subgraph Security [Security Layer]
        IAM[IAM / OAuth 2.0]:::security
        Consent[Consent Mgmt]:::security
    end
    
    subgraph Services [Bank Service Layer]
        AIS[Account Information]:::service
        PIS[Payment Service]:::service
        CardSvc[Card Services]:::service
        eKYC[eKYC Service]:::service
        Recon[Reconciliation]:::service
        OtherSvc[Others ...]:::service
    end
    
    subgraph Management [Management Layer]
        DevPortal[Developer Portal]:::management
        TPPMgmt[TPP Management]:::management
        Monitor[Monitoring & Analytics]:::management
        Audit[Audit & Logging]:::management
        AdminPortal[Admin Portal]:::management
    end

    %% --- Integration Layer ---
    subgraph Integration [Integration Layer]
        ESB[Enterprise Service Bus]:::integration
    end
    
    %% --- Backend Layer (Bottom) ---
    subgraph Backend [Business Records & Data]
        direction LR
        CoreBank[Core Banking]:::business
        CardSystem[Card System]:::business
        CIC[Credit Info]:::business
        Napas[Napas 24/7]:::business
        BillingSvc[Billing]:::business
        DB[(Transaction DB)]:::data
    end

    %% --- Relationships ---
    
    %% 1. Ingress
    TPP & Mobile & Web --> WAF --> APIGW
    
    %% 2. Gateway Routing
    APIGW --> IAM
    APIGW --> AIS & PIS & CardSvc & eKYC & Recon & OtherSvc
    
    %% 3. Security Flow
    IAM --> Consent
    
    %% 4. Integration Flow
    AIS & PIS & CardSvc & eKYC & Recon & OtherSvc --> ESB
    
    %% 5. Backend Flow
    ESB --> CoreBank & CardSystem & Napas & BillingSvc & CIC
    
    %% 6. Data & Logging
    AIS & PIS & Recon --> DB
    Audit -.-> DB
    TPPMgmt -.-> DB
    
    %% 7. Management & Cross-Cutting
    APIGW -.-> Monitor
    TPP -.-> DevPortal & TPPMgmt
    DevPortal -.-> APIGW
    TPPMgmt -.-> IAM

    %% --- Layout Hints (Invisible Links) ---
    %% Force horizontal alignment: Security <-> Services <-> Management
    Security ~~~ Services ~~~ Management
```

## Các Thành Phần Chính

### 1. API Gateway Layer
- **Chức năng**: 
  - Điểm truy cập duy nhất cho tất cả API requests
  - Rate limiting và quota management
  - Request/Response transformation
  - Load balancing và routing
- **Công nghệ**: Kong, AWS API Gateway, hoặc Apigee

### 2. Security Layer
- **IAM Server**: Quản lý OAuth 2.0/OIDC flows
- **Consent Management**: Lưu trữ và quản lý sự đồng ý của khách hàng

### 3. Service Layer
- **AIS**: Dịch vụ thông tin tài khoản
- **PIS**: Dịch vụ khởi tạo thanh toán
- **Card Services**: Quản lý thẻ và tokenization
- **eKYC**: Định danh điện tử
- **Reconciliation**: Đối soát và tra soát

### 4. Integration Layer
- **ESB**: Chuyển đổi message format (JSON ↔ ISO 8583/SOAP)

### 5. Data Layer
- **Transaction DB**: PostgreSQL/Oracle cho dữ liệu giao dịch và audit logs

### 6. Management Layer
- **Developer Portal**:
  - Cung cấp tài liệu API (API Documentation) và SDKs
  - Môi trường Sandbox để TPP thử nghiệm tích hợp
  - Quản lý ứng dụng (Application Management) và cung cấp Client ID/Secret
  - Support ticket system cho developer
- **TPP Management**:
  - Quy trình đăng ký và phê duyệt (Onboarding & Vetting) đối tác TPP
  - Quản lý vòng đời và trạng thái hoạt động của TPP
  - Quản lý chứng chỉ số (Digital Certificates) và xác thực eIDAS (nếu có)
  - Giám sát tuân thủ (Compliance Monitoring) và báo cáo định kỳ
  - Dispute management và xử lý khiếu nại
- **Monitoring & Analytics**:
  - Giám sát hiệu năng hệ thống real-time (API latency, throughput, error rates)
  - Dashboard phân tích xu hướng sử dụng API
  - Alert và notification khi có sự cố
  - Capacity planning và resource optimization
- **Audit & Logging**:
  - Ghi nhận toàn bộ API calls và transactions
  - Compliance audit trails theo yêu cầu NHNN
  - Forensic analysis và investigation support
  - Retention policy management cho log data

## Sơ Đồ Luồng Dữ Liệu


```mermaid
sequenceDiagram
    participant TPP as Third Party Provider
    participant APIGW as API Gateway
    participant IAM as Secure Auth Server
    participant Service as Bank Service 
    participant ESB as Integration Layer ESB
    participant Core as Core Banking
    
    TPP->>APIGW: API Request + Access Token
    APIGW->>APIGW: Rate Limiting Check
    APIGW->>IAM: Validate Token
    IAM-->>APIGW: Token Valid + Scopes
    APIGW->>Service: Forward Request
    Service->>Service: Business Logic
    Service->>ESB: Transform to Core Format
    ESB->>Core: Execute Transaction
    Core-->>ESB: Response
    ESB-->>Service: Transform to JSON
    Service-->>APIGW: API Response
    APIGW-->>TPP: HTTP 200 + Response Body
```


## Tài Liệu Tham Khảo
- Thông tư 64/2024/TT-NHNN
- ISO 20022 Message Standards
