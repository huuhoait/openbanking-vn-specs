# Thương Mại Hóa API (API Monetization & Billing)

> **Tuân thủ:** Thông tư 64/2024/TT-NHNN | ISO 20022 | Revenue Recognition Standards

## Tổng Quan

Hệ thống thương mại hóa API biến Open Banking API thành nguồn doanh thu bền vững cho ngân hàng thông qua các mô hình tính phí linh hoạt và minh bạch.

### Mục Tiêu

1. **Monetization**: Tạo doanh thu từ API
2. **Flexible Pricing**: Nhiều mô hình giá linh hoạt
3. **Usage Metering**: Đo lường chính xác việc sử dụng
4. **Billing Automation**: Tự động hóa thanh toán
5. **Revenue Analytics**: Phân tích doanh thu chi tiết

## Kiến Trúc Billing System

```mermaid
graph TB
    subgraph "API Layer"
        Gateway[API Gateway<br/>Request Interceptor]
    end
    
    subgraph "Metering Engine"
        Counter[Request Counter<br/>Real-time]
        Classifier[API Classifier<br/>Type + Tier]
        Aggregator[Usage Aggregator<br/>Batch Processing]
    end
    
    subgraph "Pricing Engine"
        Rules[Pricing Rules<br/>Rate Cards]
        Calculator[Price Calculator<br/>Multi-model]
        Discounts[Discount Engine<br/>Promotions]
    end
    
    subgraph "Billing Engine"
        Invoice[Invoice Generator]
        Payment[Payment Processor<br/>VNPay + NAPAS]
        Collection[Payment Collection]
    end
    
    subgraph "Storage"
        Metrics[(Time-Series DB<br/>InfluxDB)]
        Billing_DB[(Billing Database<br/>PostgreSQL)]
        Archive[(Archive Storage<br/>S3)]
    end
    
    subgraph "Notification"
        Email[Email Service]
        Portal[TPP Portal]
        Webhook[Webhook Notifications]
    end
    
    Gateway --> Counter
    Counter --> Classifier
    Classifier --> Aggregator
    
    Aggregator --> Metrics
    Aggregator --> Rules
    
    Rules --> Calculator
    Calculator --> Discounts
    Discounts --> Invoice
    
    Invoice --> Billing_DB
    Invoice --> Email
    Invoice --> Portal
    
    Payment --> Billing_DB
    Collection --> Payment
    
    Billing_DB --> Archive
    
    style Calculator fill:#4caf50,stroke:#2e7d32,color:#fff
    style Invoice fill:#ff9800,stroke:#e65100
```

## Pricing Models

### 1. Subscription-Based (Gói Cước)

```mermaid
graph TB
    subgraph "Subscription Tiers"
        Free[Free Tier<br/>---<br/>• 10K calls/month<br/>• Basic APIs only<br/>• Community support<br/>• 0 VND]
        
        Basic[Basic Tier<br/>---<br/>• 100K calls/month<br/>• All Open APIs<br/>• Email support<br/>• 5,000,000 VND/month]
        
        Pro[Professional Tier<br/>---<br/>• 1M calls/month<br/>• All APIs + Premium<br/>• Phone support<br/>• 30,000,000 VND/month]
        
        Enterprise[Enterprise Tier<br/>---<br/>• Unlimited calls<br/>• Custom APIs<br/>• Dedicated support<br/>• Custom pricing]
    end
    
    Free -->|Upgrade| Basic
    Basic -->|Upgrade| Pro
    Pro -->|Upgrade| Enterprise
    
    style Free fill:#90ee90
    style Basic fill:#64b5f6
    style Pro fill:#ffa726
    style Enterprise fill:#ba68c8,color:#fff
```

### 2. Pay-Per-Use (Trả Theo Lượt)

```mermaid
graph TB
    Request[API Request]
    
    Request --> Classify{Classify API}
    
    Classify -->|Query APIs| Query[Account Info<br/>Balance<br/>---<br/>500 VND/call]
    Classify -->|Transaction APIs| Txn[Transaction History<br/>---<br/>1,000 VND/call]
    Classify -->|Payment APIs| Payment[Payment Initiation<br/>---<br/>0.1% of amount<br/>Min: 5,000 VND]
    Classify -->|Premium APIs| Premium[eKYC, Card<br/>---<br/>10,000 VND/call]
    
    Query --> Meter[Usage Metering]
    Txn --> Meter
    Payment --> Meter
    Premium --> Meter
    
    Meter --> Calculate[Calculate Cost]
    Calculate --> Invoice[Monthly Invoice]
    
    style Calculate fill:#4caf50,color:#fff
```

**Rate Card:**

| API Category | Pricing | Example |
|--------------|---------|---------|
| **Account Information** | 500 VND/call | GET /accounts |
| **Balance Inquiry** | 800 VND/call | GET /balances |
| **Transaction History** | 1,000 VND/call | GET /transactions |
| **Payment Initiation** | 0.1% of amount (min 5,000 VND) | POST /payments |
| **Card Issuance** | 50,000 VND/card | POST /cards/issue |
| **eKYC Verification** | 10,000 VND/verification | POST /ekyc/verify |
| **Face Matching** | 5,000 VND/match | POST /face/match |

### 3. Revenue Share (Chia Sẻ Doanh Thu)

```mermaid
graph LR
    Transaction[Transaction<br/>Value: 1,000,000 VND]
    
    Transaction --> Split{Revenue Split}
    
    Split -->|70%| Bank[Bank Revenue<br/>700,000 VND]
    Split -->|25%| TPP[TPP Revenue<br/>250,000 VND]
    Split -->|5%| Platform[Platform Fee<br/>50,000 VND]
    
    Bank --> BankAccount[Bank Account]
    TPP --> TPPAccount[TPP Account]
    Platform --> PlatformFee[Platform Revenue]
    
    style Bank fill:#4caf50,color:#fff
    style TPP fill:#2196f3,color:#fff
    style Platform fill:#ff9800
```

### 4. Hybrid Model (Kết Hợp)

**Base Subscription + Overage:**
- Base: 5,000,000 VND/month (100K calls included)
- Overage: 60 VND/call above quota

**Example Calculation:**
```
Monthly Usage: 150,000 calls
Base Fee: 5,000,000 VND (covers 100,000 calls)
Overage: 50,000 calls × 60 VND = 3,000,000 VND
Total: 8,000,000 VND
```

## Usage Metering

### Real-time Metering

```mermaid
sequenceDiagram
    participant TPP
    participant Gateway
    participant Meter as Metering Service
    participant Redis
    participant InfluxDB
    
    TPP->>Gateway: API Request
    Gateway->>Gateway: Authenticate
    
    Gateway->>Meter: Record Usage<br/>• TPP ID<br/>• API Endpoint<br/>• Timestamp
    
    Meter->>Redis: Increment Counter<br/>Key: tpp:{id}:api:{endpoint}:date
    Redis-->>Meter: Current Count
    
    Meter->>Meter: Check Quota<br/>Remaining: 1,245/100,000
    
    alt Quota OK
        Meter-->>Gateway: Allow + Usage Headers
        Gateway->>TPP: 200 OK<br/>X-RateLimit-Remaining: 1245
        
        Meter->>InfluxDB: Write Usage Metrics<br/>(Async)
    else Quota Exceeded
        Meter-->>Gateway: Deny
        Gateway->>TPP: 429 Too Many Requests<br/>Upgrade Required
    end
```

### Usage Analytics

```mermaid
graph TB
    subgraph "Data Collection"
        Raw[Raw API Logs]
        Parsed[Parsed Metrics]
    end
    
    subgraph "Aggregation"
        Hourly[Hourly Aggregation]
        Daily[Daily Aggregation]
        Monthly[Monthly Aggregation]
    end
    
    subgraph "Analytics"
        TPP_Usage[TPP Usage Report]
        API_Stats[API Statistics]
        Revenue[Revenue Analytics]
        Forecast[Usage Forecast<br/>ML-based]
    end
    
    Raw --> Parsed
    Parsed --> Hourly
    Hourly --> Daily
    Daily --> Monthly
    
    Hourly --> TPP_Usage
    Daily --> API_Stats
    Monthly --> Revenue
    Monthly --> Forecast
    
    style Forecast fill:#ba68c8,color:#fff
```

## Billing Cycle

### Monthly Billing Process

```mermaid
gantt
    title Monthly Billing Timeline
    dateFormat YYYY-MM-DD
    axisFormat %d/%m
    
    section Usage Period
    Usage Collection :usage, 2025-12-01, 30d
    
    section Billing
    Calculate Usage :calc, 2026-01-01, 1d
    Apply Discounts :discount, 2026-01-02, 1d
    Generate Invoices :invoice, 2026-01-03, 1d
    Send Invoices :send, 2026-01-04, 1d
    
    section Payment
    Payment Period :pay, 2026-01-04, 15d
    Send Reminders :crit, reminder, 2026-01-14, 5d
    Payment Deadline :milestone, deadline, 2026-01-19, 0d
    
    section Collection
    Collect Payments :collect, 2026-01-04, 20d
    Handle Overdue :crit, overdue, 2026-01-19, 5d
```

### Invoice Generation

```mermaid
sequenceDiagram
    participant Scheduler
    participant Billing as Billing Engine
    participant Usage as Usage DB
    participant Pricing as Pricing Engine
    participant Invoice as Invoice Service
    participant Email
    participant TPP
    
    Note over Scheduler: End of Month (1st day)
    Scheduler->>Billing: Trigger Monthly Billing
    
    Billing->>Usage: Get All TPP Usage<br/>Last Month
    Usage-->>Billing: Usage Data (All TPPs)
    
    loop For Each TPP
        Billing->>Pricing: Calculate Charges<br/>TPP ID + Usage
        Pricing->>Pricing: Apply Rate Card
        Pricing->>Pricing: Apply Discounts/Promos
        Pricing-->>Billing: Total Amount
        
        Billing->>Invoice: Generate Invoice<br/>TPP + Amount + Details
        Invoice->>Invoice: Create PDF
        Invoice->>Invoice: Store in DB
        Invoice-->>Billing: Invoice ID
        
        Billing->>Email: Send Invoice Email
        Email->>TPP: Invoice Email + PDF
        
        Billing->>TPP: Update Portal<br/>New Invoice Available
    end
    
    Billing->>Billing: Generate Summary Report
```

## Invoice Structure

**Invoice Example:**

```json
{
  "InvoiceId": "INV-202512-12345",
  "InvoiceNumber": "OB-2025-12-001",
  "TPP": {
    "TPPId": "tpp-12345",
    "TPPName": "FinTech Solutions Ltd",
    "TaxId": "0123456789",
    "BillingAddress": {
      "Street": "123 Nguyen Hue",
      "City": "Ho Chi Minh",
      "Country": "Vietnam"
    }
  },
  "BillingPeriod": {
    "Start": "2025-12-01",
    "End": "2025-12-31"
  },
  "IssuedDate": "2026-01-03",
  "DueDate": "2026-01-19",
  "Currency": "VND",
  "LineItems": [
    {
      "Description": "Professional Subscription",
      "Category": "Subscription",
      "Quantity": 1,
      "UnitPrice": "30000000",
      "Amount": "30000000"
    },
    {
      "Description": "API Calls - Account Information",
      "Category": "Usage",
      "Quantity": 125000,
      "UnitPrice": "500",
      "Amount": "62500000"
    },
    {
      "Description": "API Calls - Payment Initiation",
      "Category": "Usage",
      "Quantity": 5000,
      "TransactionValue": "5000000000",
      "Rate": "0.1%",
      "Amount": "5000000"
    },
    {
      "Description": "Volume Discount (>100K calls)",
      "Category": "Discount",
      "Amount": "-9750000"
    }
  ],
  "Summary": {
    "Subtotal": "97500000",
    "Discount": "-9750000",
    "TaxableAmount": "87750000",
    "VAT": "8775000",
    "Total": "96525000"
  },
  "PaymentInfo": {
    "BankName": "ABC Bank",
    "AccountNumber": "1234567890",
    "AccountName": "Open Banking Platform",
    "SwiftCode": "ABCVVNVX"
  },
  "Status": "Pending",
  "PdfUrl": "/invoices/INV-202512-12345.pdf"
}
```

## Payment Processing

### Payment Methods

```mermaid
graph TB
    Invoice[Invoice Generated]
    
    Invoice --> Method{Payment Method}
    
    Method -->|Bank Transfer| Manual[Manual Transfer<br/>---<br/>• Upload proof<br/>• Manual verification<br/>• 1-2 days]
    
    Method -->|VNPay| VNPay[VNPay Gateway<br/>---<br/>• Credit/Debit card<br/>• QR Payment<br/>• Instant]
    
    Method -->|NAPAS| NAPAS[NAPAS Direct Debit<br/>---<br/>• Account linking<br/>• Auto deduction<br/>• Instant]
    
    Method -->|Wallet| Wallet[E-Wallet<br/>---<br/>• MoMo, ZaloPay<br/>• QR Payment<br/>• Instant]
    
    Manual --> Verify{Verification}
    VNPay --> Auto[Auto Verification]
    NAPAS --> Auto
    Wallet --> Auto
    
    Verify -->|Matched| Paid[Mark as Paid]
    Verify -->|No Match| Pending[Pending Review]
    Auto --> Paid
    
    Paid --> Receipt[Send Receipt]
    Paid --> Update[Update Portal]
    
    style Paid fill:#4caf50,color:#fff
    style Pending fill:#ff9800
```

### Auto-Debit Flow

```mermaid
sequenceDiagram
    participant Billing
    participant Payment as Payment Service
    participant NAPAS
    participant TPP_Bank as TPP's Bank
    participant Bank as Our Bank
    participant TPP
    
    Note over Billing: Payment Due Date
    Billing->>Payment: Auto-Debit Request<br/>Invoice + Amount
    
    Payment->>NAPAS: Initiate Direct Debit
    NAPAS->>TPP_Bank: Debit Request
    
    alt Sufficient Balance
        TPP_Bank->>TPP_Bank: Debit Account
        TPP_Bank->>NAPAS: Debit Success
        NAPAS->>Bank: Credit Request
        Bank->>Bank: Credit Account
        Bank->>NAPAS: Credit Success
        NAPAS-->>Payment: Transaction Complete
        
        Payment->>Billing: Update Status: Paid
        Billing->>TPP: Send Receipt + Thank You
    else Insufficient Balance
        TPP_Bank->>NAPAS: Debit Failed
        NAPAS-->>Payment: Transaction Failed
        
        Payment->>Billing: Update Status: Failed
        Billing->>TPP: Payment Failed Notice<br/>+ Alternative Methods
    end
```

## Discount & Promotion Engine

### Discount Types

```mermaid
graph TB
    subgraph "Discount Types"
        Volume[Volume Discount<br/>---<br/>• >100K calls: 10% off<br/>• >500K calls: 15% off<br/>• >1M calls: 20% off]
        
        Commit[Commitment Discount<br/>---<br/>• 6 months prepay: 5% off<br/>• 12 months prepay: 10% off<br/>• 24 months prepay: 15% off]
        
        Early[Early Adopter<br/>---<br/>• First 100 TPPs: 50% off<br/>• First year only<br/>• Non-renewable]
        
        Bundle[Bundle Discount<br/>---<br/>• AIS + PIS: 5% off<br/>• All services: 15% off<br/>• Annual contract]
    end
    
    subgraph "Promo Codes"
        Launch[LAUNCH2025<br/>30% off first month]
        Referral[REFER-FRIEND<br/>20% off for both]
        Season[NEWYEAR2026<br/>25% off]
    end
    
    style Volume fill:#4caf50,color:#fff
    style Commit fill:#2196f3,color:#fff
    style Early fill:#ff9800
    style Bundle fill:#9c27b0,color:#fff
```

### Promo Code Application

```mermaid
sequenceDiagram
    participant TPP
    participant Portal
    participant Promo as Promo Engine
    participant Billing
    
    TPP->>Portal: Enter Promo Code<br/>"LAUNCH2025"
    Portal->>Promo: Validate Code
    
    Promo->>Promo: Check:<br/>• Code exists?<br/>• Not expired?<br/>• Eligibility?<br/>• Usage limit?
    
    alt Valid
        Promo-->>Portal: Valid: 30% off first month
        Portal-->>TPP: Discount Applied ✓
        Portal->>Billing: Store Discount
    else Invalid
        Promo-->>Portal: Invalid: Code expired
        Portal-->>TPP: Invalid Code ✗
    end
```

## Revenue Analytics

### Revenue Dashboard

```mermaid
graph TB
    subgraph "Key Metrics"
        MRR[Monthly Recurring Revenue<br/>---<br/>• Subscriptions<br/>• Predictable income<br/>• Growth rate]
        
        ARR[Annual Recurring Revenue<br/>---<br/>• Total contracts<br/>• Forecast<br/>• Churn rate]
        
        ARPU[Average Revenue Per User<br/>---<br/>• Total revenue / TPPs<br/>• Segmented by tier<br/>• Trend analysis]
    end
    
    subgraph "Growth Metrics"
        New[New TPPs<br/>Acquisition rate]
        Churn[Churn Rate<br/>Lost TPPs]
        Expansion[Expansion Revenue<br/>Upsells]
    end
    
    subgraph "API Metrics"
        Volume[Call Volume<br/>by API type]
        Revenue[Revenue by API<br/>Most profitable]
        Usage[Usage Patterns<br/>Peak times]
    end
    
    MRR --> Forecast[Revenue Forecast<br/>ML-based]
    ARR --> Forecast
    ARPU --> Forecast
    
    New --> Growth[Growth Rate]
    Churn --> Growth
    Expansion --> Growth
    
    style Forecast fill:#ba68c8,color:#fff
```

### Revenue Breakdown

```mermaid
pie title Revenue by API Category (Monthly)
    "Account Information" : 35
    "Payment Initiation" : 30
    "Card Services" : 20
    "eKYC Services" : 10
    "Premium APIs" : 5
```

## Compliance & Tax

### VAT Handling

```mermaid
graph LR
    Subtotal[Subtotal<br/>87,750,000 VND]
    
    Subtotal --> VAT{VAT<br/>Applicable?}
    
    VAT -->|B2B Domestic| VAT10[Add VAT 10%<br/>8,775,000 VND]
    VAT -->|B2B Export| VAT0[VAT 0%<br/>Invoice note]
    VAT -->|B2C| VAT10B[VAT 10%<br/>Included]
    
    VAT10 --> Total[Total<br/>96,525,000 VND]
    VAT0 --> Total2[Total<br/>87,750,000 VND]
    VAT10B --> Total3[Total<br/>96,525,000 VND]
    
    style Total fill:#4caf50,color:#fff
```

### Invoice Requirements (Vietnam)

**Red Invoice (Hóa Đơn Đỏ):**
- ✅ Tax code (Mã số thuế)
- ✅ Invoice number (Số hóa đơn)
- ✅ Invoice form (Ký hiệu mẫu số)
- ✅ Seller info (Thông tin người bán)
- ✅ Buyer info (Thông tin người mua)
- ✅ Item details (Chi tiết hàng hóa/dịch vụ)
- ✅ VAT breakdown (Thuế GTGT chi tiết)
- ✅ Digital signature (Chữ ký số)

## API Endpoints

### 1. Get Current Usage

#### GET /v1/billing/usage/current

```json
{
  "TPPId": "tpp-12345",
  "BillingPeriod": {
    "Start": "2025-12-01",
    "End": "2025-12-31"
  },
  "Subscription": {
    "Tier": "Professional",
    "IncludedCalls": 1000000,
    "Price": "30000000 VND"
  },
  "Usage": {
    "TotalCalls": 125000,
    "RemainingCalls": 875000,
    "OverageCallsUsage": 0,
    "PercentageUsed": 12.5
  },
  "EstimatedCost": {
    "Subscription": "30000000",
    "Usage": "0",
    "Discount": "0",
    "EstimatedTotal": "30000000",
    "Currency": "VND"
  }
}
```

### 2. Get Invoice List

#### GET /v1/billing/invoices

### 3. Download Invoice

#### GET /v1/billing/invoices/{InvoiceId}/pdf

### 4. Submit Payment Proof

#### POST /v1/billing/invoices/{InvoiceId}/payment

## Tài Liệu Tham Khảo

- **Thông tư 64/2024/TT-NHNN** - Open API Regulations
- **Luật Thuế GTGT 2008** - VAT Law
- **Nghị định 123/2020/NĐ-CP** - E-Invoice Regulations
- **ISO 20022** - Payment Messages

---

**Phiên bản:** 1.0  
**Ngày cập nhật:** 15/12/2025  
**Trạng thái:** Production Ready
