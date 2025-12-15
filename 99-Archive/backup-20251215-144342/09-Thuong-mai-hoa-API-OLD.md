# Thương Mại Hóa API (Monetization & Billing)

## Tổng Quan

Hệ thống tính phí và thương mại hóa API, biến Open Banking API thành nguồn doanh thu mới cho ngân hàng.

## Kiến Trúc Billing System

```mermaid
graph TB
    subgraph "API Layer"
        Gateway[API Gateway]
    end
    
    subgraph "Metering"
        Counter[Request Counter]
        Classifier[API Classifier]
        Aggregator[Usage Aggregator]
    end
    
    subgraph "Billing Engine"
        Calculator[Price Calculator]
        Invoice[Invoice Generator]
        Payment[Payment Processor]
    end
    
    subgraph "Storage"
        Metrics[(Time-Series DB<br/>InfluxDB)]
        Billing_DB[(Billing Database)]
    end
    
    subgraph "Notification"
        Email[Email Service]
        Portal[TPP Portal]
    end
    
    Gateway --> Counter
    Counter --> Classifier
    Classifier --> Aggregator
    
    Aggregator --> Metrics
    Aggregator --> Calculator
    
    Calculator --> Invoice
    Invoice --> Billing_DB
    Invoice --> Email
    
    Payment --> Billing_DB
    
    Portal --> Billing_DB
```

## Pricing Models

### 1. Pay-As-You-Go

```mermaid
graph LR
    subgraph "Usage-Based Pricing"
        API[API Call]
        Meter[Meter Usage]
        Calculate[Calculate Cost]
        Charge[Charge TPP]
    end
    
    API --> Meter
    Meter --> Calculate
    Calculate --> Charge
    
    style API fill:#4ecdc4
    style Charge fill:#ff6b6b
```

**Ví dụ:**
- eKYC API: 5,000 VND/request
- Face Matching: 3,000 VND/request
- NFC Verification: 10,000 VND/request

### 2. Subscription (Thuê Bao)

```mermaid
graph TB
    subgraph "Subscription Tiers"
        Free[Free Tier<br/>10,000 calls/month<br/>0 VND]
        Basic[Basic Tier<br/>100,000 calls/month<br/>5,000,000 VND]
        Pro[Professional Tier<br/>1,000,000 calls/month<br/>30,000,000 VND]
        Enterprise[Enterprise Tier<br/>Unlimited<br/>Custom Pricing]
    end
    
    Free --> Basic
    Basic --> Pro
    Pro --> Enterprise
```

### 3. Revenue Share

```mermaid
sequenceDiagram
    participant Customer as End Customer
    participant TPP as TPP
    participant Bank as Bank
    
    Customer->>TPP: Use Service (e.g., Loan)
    TPP->>Bank: API Call (Credit Scoring)
    Bank-->>TPP: Credit Score
    TPP->>Customer: Approve Loan
    
    Note over Customer,TPP: Customer pays fee to TPP
    
    TPP->>TPP: Calculate Revenue Share<br/>10% of transaction value
    TPP->>Bank: Pay Revenue Share
```

**Ví dụ:**
- Loan Origination: 10% của phí giao dịch
- Bill Payment: 0.5% của giá trị thanh toán
- Card Issuance: 50,000 VND/thẻ phát hành

### 4. Tiered Pricing

```mermaid
graph TB
    Usage[Monthly Usage]
    
    Usage --> Tier1{0 - 10K calls}
    Usage --> Tier2{10K - 100K calls}
    Usage --> Tier3{100K - 1M calls}
    Usage --> Tier4{> 1M calls}
    
    Tier1 -->|1,000 VND/call| Price1[Cost Tier 1]
    Tier2 -->|800 VND/call| Price2[Cost Tier 2]
    Tier3 -->|600 VND/call| Price3[Cost Tier 3]
    Tier4 -->|500 VND/call| Price4[Cost Tier 4]
```

## Fee Schedule

### API Pricing Matrix

| API Category | API Endpoint | Pricing Model | Price |
|--------------|--------------|---------------|-------|
| **Basic APIs** | | | |
| Account Info | GET /accounts | Free | 0 VND |
| Balance Inquiry | GET /accounts/{id}/balances | Free | 0 VND |
| Transaction History | GET /accounts/{id}/transactions | Subscription | Included |
| **Premium APIs** | | | |
| eKYC | POST /ekyc/ocr | Pay-per-use | 5,000 VND |
| Face Matching | POST /ekyc/face-match | Pay-per-use | 3,000 VND |
| Liveness Detection | POST /ekyc/liveness | Pay-per-use | 4,000 VND |
| NFC Verification | POST /ekyc/nfc-verify | Pay-per-use | 10,000 VND |
| **Transaction APIs** | | | |
| Fund Transfer | POST /payments | Transaction fee | 1,100 - 5,500 VND |
| Bill Payment | POST /bill-payments | Revenue share | 0.5% of amount |
| **Card APIs** | | | |
| Card Issuance | POST /cards/issuance | Per card | 50,000 VND |
| Tokenization | POST /tokenization/provision | Per token | 10,000 VND |
| **Value-Added** | | | |
| Credit Scoring | POST /credit-score | Pay-per-use | 20,000 VND |
| Fraud Check | POST /fraud-check | Pay-per-use | 15,000 VND |

## Metering & Usage Tracking

### Real-time Metering

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Gateway as API Gateway
    participant Meter as Metering Service
    participant TS_DB as Time-Series DB
    participant Quota as Quota Service
    
    TPP->>Gateway: API Request
    Gateway->>Meter: Record API Call
    Meter->>TS_DB: Store Metrics<br/>(timestamp, client_id, api, status)
    
    Meter->>Quota: Check Quota
    Quota-->>Meter: Quota Status
    
    alt Quota Exceeded
        Meter-->>Gateway: 429 Quota Exceeded
        Gateway-->>TPP: 429 Too Many Requests
    else Within Quota
        Gateway->>Gateway: Process Request
        Gateway-->>TPP: 200 OK
    end
```

### Metrics Collected

```json
{
  "timestamp": "2024-12-10T18:00:00+07:00",
  "client_id": "tpp-12345",
  "api_endpoint": "/v1/ekyc/ocr",
  "http_method": "POST",
  "response_code": 200,
  "response_time_ms": 250,
  "request_size_bytes": 1024,
  "response_size_bytes": 512,
  "pricing_tier": "PREMIUM",
  "unit_price": 5000,
  "currency": "VND"
}
```

## Billing Cycle

```mermaid
gantt
    title Monthly Billing Cycle
    dateFormat YYYY-MM-DD
    section Usage Period
    Usage Collection           :2024-12-01, 30d
    section Processing
    Usage Aggregation         :2024-12-31, 1d
    Price Calculation         :2024-12-31, 1d
    Invoice Generation        :2025-01-01, 1d
    section Payment
    Invoice Sent              :2025-01-01, 1d
    Payment Due               :2025-01-15, 1d
    section Collections
    Payment Reminder          :2025-01-10, 1d
    Late Fee Applied          :2025-01-16, 1d
```

### Billing Process

```mermaid
sequenceDiagram
    participant Scheduler as Cron Scheduler
    participant Billing as Billing Engine
    participant Metrics as Metrics DB
    participant Calculator as Price Calculator
    participant Invoice as Invoice Generator
    participant Email as Email Service
    participant TPP as TPP
    
    Note over Scheduler: End of month (Day 31)
    
    Scheduler->>Billing: Trigger Monthly Billing
    Billing->>Metrics: Fetch Usage Data<br/>(Month M)
    Metrics-->>Billing: Usage Records
    
    Billing->>Calculator: Calculate Charges
    Calculator->>Calculator: Apply Pricing Rules<br/>- Tiered pricing<br/>- Discounts<br/>- Credits
    Calculator-->>Billing: Total Amount
    
    Billing->>Invoice: Generate Invoice
    Invoice->>Invoice: Create PDF Invoice
    Invoice-->>Billing: Invoice PDF + ID
    
    Billing->>Email: Send Invoice
    Email->>TPP: Email with Invoice PDF
    
    Note over TPP: Payment Due: Day 15 of M+1
```

## Invoice Structure

### Invoice Example

```json
{
  "InvoiceId": "INV-2024-12-001",
  "InvoiceDate": "2025-01-01",
  "DueDate": "2025-01-15",
  "BillingPeriod": {
    "From": "2024-12-01",
    "To": "2024-12-31"
  },
  "BillTo": {
    "ClientId": "tpp-12345",
    "CompanyName": "Example Fintech Co., Ltd",
    "TaxId": "0123456789",
    "Address": "123 Nguyen Hue, Q.1, TP.HCM",
    "Email": "billing@example.com"
  },
  "LineItems": [
    {
      "Description": "eKYC OCR Service",
      "Quantity": 1250,
      "UnitPrice": 5000,
      "Amount": 6250000,
      "Currency": "VND"
    },
    {
      "Description": "Face Matching Service",
      "Quantity": 1250,
      "UnitPrice": 3000,
      "Amount": 3750000,
      "Currency": "VND"
    },
    {
      "Description": "NFC Verification Service",
      "Quantity": 500,
      "UnitPrice": 10000,
      "Amount": 5000000,
      "Currency": "VND"
    },
    {
      "Description": "Professional Subscription",
      "Quantity": 1,
      "UnitPrice": 30000000,
      "Amount": 30000000,
      "Currency": "VND"
    }
  ],
  "Subtotal": 45000000,
  "Discount": 2250000,
  "DiscountReason": "Volume discount (5%)",
  "Tax": 4275000,
  "TaxRate": 0.10,
  "Total": 47025000,
  "Currency": "VND",
  "PaymentTerms": "Net 15",
  "PaymentMethods": ["Bank Transfer", "Credit Card"]
}
```

## Payment Processing

### Payment Flow

```mermaid
sequenceDiagram
    participant TPP as TPP
    participant Portal as TPP Portal
    participant Payment as Payment Gateway
    participant Bank as Bank Account
    participant Billing as Billing System
    
    TPP->>Portal: View Invoice
    Portal-->>TPP: Invoice Details
    
    TPP->>Portal: Initiate Payment
    Portal->>Payment: Process Payment<br/>(Bank Transfer / Card)
    
    alt Bank Transfer
        Payment->>Bank: Verify Transfer
        Bank-->>Payment: Transfer Confirmed
    else Credit Card
        Payment->>Payment: Process Card Payment
        Payment-->>Payment: Payment Approved
    end
    
    Payment-->>Portal: Payment Success
    Portal->>Billing: Update Invoice Status
    Billing->>Billing: Mark as PAID
    Billing->>TPP: Send Receipt
```

### Payment Methods

| Method | Processing Time | Fee | Auto-reconciliation |
|--------|-----------------|-----|---------------------|
| Bank Transfer | 1-2 business days | Free | Manual |
| Credit Card | Instant | 2.5% | Automatic |
| E-Wallet | Instant | 1.5% | Automatic |
| Direct Debit | 1 business day | Free | Automatic |

## Quota Management

### Quota Enforcement

```mermaid
graph TB
    Request[API Request]
    
    Request --> CheckSub{Check Subscription}
    CheckSub -->|No Subscription| CheckPrepaid{Prepaid Balance?}
    CheckSub -->|Active| CheckQuota{Within Quota?}
    
    CheckQuota -->|Yes| Allow[Allow Request]
    CheckQuota -->|No| Overage{Allow Overage?}
    
    Overage -->|Yes| Charge[Charge Overage Fee]
    Overage -->|No| Block[429 Quota Exceeded]
    
    CheckPrepaid -->|Balance > 0| Deduct[Deduct from Balance]
    CheckPrepaid -->|Balance = 0| Block
    
    Charge --> Allow
    Deduct --> Allow
```

### Quota Types

| Quota Type | Description | Enforcement |
|------------|-------------|-------------|
| **Hard Quota** | Strict limit, requests blocked when exceeded | Immediate |
| **Soft Quota** | Warning issued, overage charges apply | Billing cycle end |
| **Burst Quota** | Short-term spike allowance | 1-minute window |
| **Daily Quota** | Resets every 24 hours | Daily |
| **Monthly Quota** | Resets every month | Monthly |

## Discounts & Promotions

### Discount Types

```mermaid
graph LR
    subgraph "Discount Strategies"
        Volume[Volume Discount<br/>5% for > 100K calls]
        Commitment[Commitment Discount<br/>10% for 1-year contract]
        EarlyPay[Early Payment<br/>2% if paid within 7 days]
        Bundle[Bundle Discount<br/>15% for multiple APIs]
    end
    
    subgraph "Application"
        Auto[Auto-applied]
        Coupon[Coupon Code]
        Negotiated[Negotiated Contract]
    end
    
    Volume --> Auto
    Commitment --> Negotiated
    EarlyPay --> Auto
    Bundle --> Coupon
```

### Promotional Campaigns

```json
{
  "CampaignId": "PROMO-2024-Q4",
  "Name": "Year-End Promotion",
  "Description": "50% off eKYC services",
  "ValidFrom": "2024-12-01",
  "ValidTo": "2024-12-31",
  "DiscountType": "PERCENTAGE",
  "DiscountValue": 50,
  "ApplicableAPIs": [
    "/v1/ekyc/ocr",
    "/v1/ekyc/face-match",
    "/v1/ekyc/liveness"
  ],
  "EligibleClients": ["tpp-12345", "tpp-67890"],
  "MaxDiscount": 10000000,
  "Currency": "VND"
}
```

## TPP Portal - Billing Dashboard

### Dashboard Features

```mermaid
graph TB
    subgraph "Usage Analytics"
        Current[Current Month Usage]
        Trend[Usage Trends]
        Forecast[Cost Forecast]
    end
    
    subgraph "Billing"
        Invoices[Invoice History]
        Payments[Payment History]
        Balance[Prepaid Balance]
    end
    
    subgraph "Cost Optimization"
        Recommend[Recommendations]
        Compare[Plan Comparison]
        Upgrade[Upgrade Options]
    end
    
    subgraph "Alerts"
        Quota_Alert[Quota Alerts]
        Payment_Alert[Payment Reminders]
        Cost_Alert[Cost Anomaly Alerts]
    end
```

### Usage Dashboard API

#### GET /v1/billing/usage/current-month

**Response:**
```json
{
  "Data": {
    "BillingPeriod": {
      "From": "2024-12-01",
      "To": "2024-12-31"
    },
    "UsageSummary": {
      "TotalAPICalls": 125000,
      "ByCategory": {
        "eKYC": 50000,
        "Payments": 60000,
        "Cards": 10000,
        "Accounts": 5000
      }
    },
    "CostSummary": {
      "Subtotal": 45000000,
      "Discounts": -2250000,
      "Tax": 4275000,
      "EstimatedTotal": 47025000,
      "Currency": "VND"
    },
    "QuotaStatus": {
      "MonthlyQuota": 1000000,
      "Used": 125000,
      "Remaining": 875000,
      "PercentageUsed": 12.5
    },
    "TopAPIs": [
      {
        "Endpoint": "/v1/payments",
        "Calls": 60000,
        "Cost": 15000000
      },
      {
        "Endpoint": "/v1/ekyc/ocr",
        "Calls": 30000,
        "Cost": 15000000
      }
    ]
  }
}
```

## Cost Optimization Recommendations

```mermaid
graph TB
    Analyze[Analyze Usage Patterns]
    
    Analyze --> Check1{High Volume<br/>Pay-per-use?}
    Analyze --> Check2{Unused<br/>Subscription?}
    Analyze --> Check3{Eligible for<br/>Volume Discount?}
    
    Check1 -->|Yes| Rec1[Recommend:<br/>Switch to Subscription]
    Check2 -->|Yes| Rec2[Recommend:<br/>Downgrade Plan]
    Check3 -->|Yes| Rec3[Recommend:<br/>Apply for Discount]
    
    Rec1 --> Savings[Potential Savings:<br/>30%]
    Rec2 --> Savings
    Rec3 --> Savings
```

## Compliance & Taxation

### Tax Handling

```mermaid
graph LR
    subgraph "Tax Calculation"
        Subtotal[Subtotal]
        VAT[VAT 10%]
        Total[Total Amount]
    end
    
    Subtotal --> VAT
    VAT --> Total
    
    subgraph "Tax Invoice"
        Red[Red Invoice<br/>Hóa đơn đỏ]
        Digital[E-Invoice<br/>Hóa đơn điện tử]
    end
    
    Total --> Red
    Total --> Digital
```

### Regulatory Compliance

- **Thông tư 64/2024**: Phí dịch vụ phải minh bạch và công khai
- **Luật Thuế GTGT**: VAT 10% áp dụng cho dịch vụ tài chính
- **Nghị định 123/2020**: Hóa đơn điện tử bắt buộc

## API Endpoints

### Billing APIs

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/billing/usage/current-month` | GET | Current month usage |
| `/v1/billing/usage/history` | GET | Historical usage data |
| `/v1/billing/invoices` | GET | List invoices |
| `/v1/billing/invoices/{id}` | GET | Invoice details |
| `/v1/billing/invoices/{id}/download` | GET | Download invoice PDF |
| `/v1/billing/payments` | POST | Submit payment |
| `/v1/billing/payments/{id}` | GET | Payment status |
| `/v1/billing/balance` | GET | Prepaid balance |
| `/v1/billing/balance/topup` | POST | Top-up prepaid balance |
| `/v1/billing/subscriptions` | GET | Current subscription |
| `/v1/billing/subscriptions/upgrade` | POST | Upgrade subscription |

## Tài Liệu Tham Khảo
- Thông tư 64/2024/TT-NHNN - Điều 14 (Phí dịch vụ)
- Stripe Billing Documentation
- AWS Pricing Models
- OpenAI API Pricing
- Azure API Management - Monetization
