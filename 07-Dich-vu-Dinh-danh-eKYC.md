# Dịch Vụ Định Danh Điện Tử (eKYC - Electronic Know Your Customer)

> **Tuân thủ:** Thông tư 64/2024/TT-NHNN | Circular 45/2025 | Quyết định 2345/QĐ-NHNN | ISO 30107 (Liveness Detection)

## Tổng Quan

Dịch vụ eKYC cho phép TPP xác thực danh tính khách hàng từ xa thông qua CCCD gắn chip, sinh trắc học và OCR, tuân thủ Circular 45/2025.

### Phạm Vi Dịch Vụ

1. **NFC Verification**: Đọc thông tin từ CCCD gắn chip qua NFC
2. **OCR Document**: Nhận diện thông tin từ ảnh CCCD
3. **Face Matching**: So khớp khuôn mặt với ảnh CCCD
4. **Liveness Detection**: Phát hiện khuôn mặt thật (chống ảnh, video)
5. **Risk Scoring**: Đánh giá rủi ro gian lận

## Kiến Trúc eKYC

```mermaid
graph TB
    subgraph "TPP Layer"
        TPP[TPP Application]
        Mobile[Mobile SDK]
    end
    
    subgraph "API Gateway"
        Gateway[API Gateway]
        RateLimit[Rate Limiter<br/>10 req/min per IP]
    end
    
    subgraph "eKYC Services"
        NFC[NFC Reader Service]
        OCR[OCR Engine<br/>Tesseract + AI]
        Face[Face Recognition<br/>Deep Learning]
        Liveness[Liveness Detection<br/>Anti-spoofing]
        Risk[Risk Scoring Engine]
    end
    
    subgraph "Data Sources"
        CCCD[(CCCD Database<br/>Ministry)]
        Blacklist[(Blacklist Database)]
        AML[(AML Watch List)]
    end
    
    subgraph "Storage"
        S3[Encrypted Storage<br/>S3/MinIO]
        Vault[Secrets Vault]
    end
    
    TPP --> Gateway
    Mobile --> Gateway
    Gateway --> RateLimit
    
    RateLimit --> NFC
    RateLimit --> OCR
    RateLimit --> Face
    RateLimit --> Liveness
    
    NFC --> CCCD
    OCR --> Risk
    Face --> Risk
    Liveness --> Risk
    
    Risk --> Blacklist
    Risk --> AML
    
    NFC --> S3
    OCR --> S3
    Face --> S3
    
    style NFC fill:#4caf50,stroke:#2e7d32,color:#fff
    style Liveness fill:#ff9800,stroke:#e65100
    style Risk fill:#f44336,stroke:#c62828,color:#fff
```

## API Endpoints

### 1. NFC Verification

#### POST /v1/ekyc/nfc/verify

Đọc và xác thực thông tin từ CCCD gắn chip qua NFC.

```mermaid
sequenceDiagram
    participant User
    participant Mobile
    participant Gateway
    participant eKYC as eKYC Service
    participant CCCD_DB as CCCD Database<br/>(Ministry)
    participant Risk
    
    User->>Mobile: Tap CCCD on Phone
    Mobile->>Mobile: Read NFC Chip<br/>ISO 14443
    Mobile->>Mobile: Extract Data:<br/>• ID Number<br/>• Name, DOB<br/>• Photo<br/>• Digital Signature
    
    Mobile->>Gateway: POST /ekyc/nfc/verify<br/>+ Encrypted NFC Data
    Gateway->>eKYC: Decrypt & Validate
    
    eKYC->>eKYC: Verify Digital Signature<br/>using Public Key
    
    alt Signature Valid
        eKYC->>CCCD_DB: Verify ID Number<br/>Check validity
        CCCD_DB-->>eKYC: Valid + Status
        
        eKYC->>Risk: Calculate Risk Score
        Risk-->>eKYC: Score: 85/100 (Low Risk)
        
        eKYC-->>Gateway: Verification Success
        Gateway-->>Mobile: 200 OK + Verified Data
    else Signature Invalid
        eKYC-->>Gateway: 400 Bad Request<br/>Invalid Signature
        Gateway-->>Mobile: Verification Failed
    end
```

**Request:**
```json
{
  "NFCData": "base64_encrypted_data_from_chip",
  "DeviceInfo": {
    "DeviceId": "device-abc123",
    "OSVersion": "iOS 17.2",
    "AppVersion": "2.1.0"
  },
  "Location": {
    "Latitude": 10.7769,
    "Longitude": 106.7009
  }
}
```

**Response:**
```json
{
  "VerificationId": "verify-nfc-123456",
  "Status": "Verified",
  "PersonalInfo": {
    "IdNumber": "001099001234",
    "FullName": "NGUYEN VAN A",
    "DateOfBirth": "01/01/1990",
    "Gender": "Male",
    "Nationality": "Vietnam",
    "PlaceOfOrigin": "Hanoi",
    "PlaceOfResidence": "123 Nguyen Hue, District 1, HCMC",
    "IssueDate": "01/01/2020",
    "ExpiryDate": "01/01/2035"
  },
  "Photo": "base64_encoded_photo",
  "RiskScore": 85,
  "RiskLevel": "Low",
  "VerifiedAt": "2025-12-15T10:30:00+07:00"
}
```

### 2. OCR Document Recognition

#### POST /v1/ekyc/ocr/document

Nhận diện thông tin từ ảnh chụp CCCD.

```mermaid
graph TB
    Upload[Upload Front + Back Images]
    
    Upload --> Preprocess[Image Preprocessing<br/>• Deskew<br/>• Denoise<br/>• Enhance]
    
    Preprocess --> Detect{Document<br/>Detection}
    Detect -->|Not Found| Error1[400: Invalid Document]
    Detect -->|Found| Extract[Text Extraction<br/>Tesseract + AI Model]
    
    Extract --> Parse[Parse Fields<br/>• ID Number<br/>• Name, DOB<br/>• Address]
    
    Parse --> Validate{Field<br/>Validation}
    Validate -->|Invalid| Error2[400: Incomplete Data]
    Validate -->|Valid| FaceDetect[Face Detection<br/>from Photo]
    
    FaceDetect --> Quality{Image<br/>Quality Check}
    Quality -->|Poor| Error3[400: Low Quality]
    Quality -->|Good| Success[200 OK + Extracted Data]
    
    style Error1 fill:#f44336,color:#fff
    style Error2 fill:#f44336,color:#fff
    style Error3 fill:#f44336,color:#fff
    style Success fill:#4caf50,color:#fff
```

**Request:**
```json
{
  "FrontImage": "base64_encoded_image",
  "BackImage": "base64_encoded_image",
  "DocumentType": "CCCD"
}
```

**Response:**
```json
{
  "OCRId": "ocr-789012",
  "ExtractedData": {
    "IdNumber": "001099001234",
    "FullName": "NGUYEN VAN A",
    "DateOfBirth": "01/01/1990",
    "Gender": "Male",
    "Nationality": "Vietnam",
    "PlaceOfOrigin": "Hanoi",
    "PlaceOfResidence": "123 Nguyen Hue, District 1, HCMC",
    "IssueDate": "01/01/2020",
    "ExpiryDate": "01/01/2035"
  },
  "Confidence": {
    "Overall": 0.95,
    "IdNumber": 0.98,
    "FullName": 0.93,
    "DateOfBirth": 0.96
  },
  "FaceDetected": true,
  "FaceBoundingBox": {
    "x": 120,
    "y": 80,
    "width": 150,
    "height": 180
  },
  "QualityScore": 88,
  "ProcessedAt": "2025-12-15T10:31:00+07:00"
}
```

### 3. Face Matching

#### POST /v1/ekyc/face/match

So khớp khuôn mặt selfie với ảnh trên CCCD.

```mermaid
sequenceDiagram
    participant User
    participant App
    participant eKYC
    participant FaceAI as Face Recognition AI
    participant Liveness
    
    User->>App: Take Selfie
    App->>App: Capture Multiple Frames
    
    App->>eKYC: POST /face/match<br/>+ Selfie Image<br/>+ CCCD Photo
    
    eKYC->>Liveness: Check Liveness<br/>(Anti-spoofing)
    Liveness->>Liveness: Analyze:<br/>• Eye blinking<br/>• Head movement<br/>• Skin texture
    
    alt Not Live
        Liveness-->>eKYC: Spoofing Detected
        eKYC-->>App: 400: Liveness Check Failed
    else Live Person
        Liveness-->>eKYC: Live Person Confirmed
        
        eKYC->>FaceAI: Compare Faces<br/>Deep Learning Model
        FaceAI->>FaceAI: Extract Features<br/>512-dim Vectors
        FaceAI->>FaceAI: Calculate Similarity<br/>Cosine Distance
        
        alt Match (Similarity > 0.85)
            FaceAI-->>eKYC: Match: 92%
            eKYC-->>App: 200 OK: Face Matched
        else No Match
            FaceAI-->>eKYC: No Match: 65%
            eKYC-->>App: 400: Face Mismatch
        end
    end
```

**Request:**
```json
{
  "SelfieImage": "base64_encoded_selfie",
  "ReferenceImage": "base64_encoded_cccd_photo",
  "LivenessCheck": true,
  "LivenessFrames": [
    "base64_frame1",
    "base64_frame2",
    "base64_frame3"
  ]
}
```

**Response:**
```json
{
  "MatchId": "match-345678",
  "IsMatch": true,
  "Similarity": 0.92,
  "Threshold": 0.85,
  "LivenessScore": 0.96,
  "LivenessPassed": true,
  "Confidence": "High",
  "MatchedAt": "2025-12-15T10:32:00+07:00"
}
```

### 4. Liveness Detection

#### POST /v1/ekyc/liveness/check

Phát hiện khuôn mặt thật (chống giả mạo bằng ảnh/video).

```mermaid
graph TB
    subgraph "Liveness Detection Methods"
        Passive[Passive Liveness<br/>• Texture analysis<br/>• Light reflection<br/>• Depth estimation]
        
        Active[Active Liveness<br/>• Head turn<br/>• Eye blink<br/>• Smile detection]
        
        Challenge[Challenge-Response<br/>• Random number display<br/>• Follow moving dot<br/>• Read random text]
    end
    
    subgraph "Anti-Spoofing Checks"
        Photo[Photo Attack<br/>Detection]
        Video[Video Replay<br/>Detection]
        Mask[3D Mask<br/>Detection]
        Screen[Screen Display<br/>Detection]
    end
    
    Passive --> Photo
    Passive --> Screen
    Active --> Video
    Challenge --> Mask
    
    Photo --> Score[Liveness Score<br/>0.0 - 1.0]
    Video --> Score
    Mask --> Score
    Screen --> Score
    
    Score -->|> 0.9| Pass[✓ Live Person]
    Score -->|< 0.9| Fail[✗ Spoofing Detected]
    
    style Pass fill:#4caf50,color:#fff
    style Fail fill:#f44336,color:#fff
```

**Liveness Techniques:**

| Technique | Description | Spoofing Prevention |
|-----------|-------------|---------------------|
| **Texture Analysis** | Analyze skin texture, pores | Photo attacks |
| **Light Reflection** | Detect screen reflection | Screen display |
| **Depth Estimation** | 3D face structure | 2D photos |
| **Eye Blinking** | Detect natural blinks | Static photos |
| **Head Movement** | Track head rotation | Photo/Video |
| **Moiré Pattern** | Screen pixel pattern | Screen attacks |

### 5. Risk Scoring

#### POST /v1/ekyc/risk/score

Đánh giá tổng hợp rủi ro dựa trên nhiều yếu tố.

```mermaid
graph TB
    subgraph "Risk Factors"
        F1[Document Authenticity<br/>Weight: 30%]
        F2[Face Match Quality<br/>Weight: 25%]
        F3[Liveness Score<br/>Weight: 20%]
        F4[Blacklist Check<br/>Weight: 15%]
        F5[Behavioral Analysis<br/>Weight: 10%]
    end
    
    subgraph "Risk Calculation"
        Calc[Weighted Score<br/>Calculation]
    end
    
    subgraph "Risk Levels"
        Low[Low Risk<br/>80-100<br/>Auto Approve]
        Medium[Medium Risk<br/>50-79<br/>Manual Review]
        High[High Risk<br/>0-49<br/>Reject]
    end
    
    F1 --> Calc
    F2 --> Calc
    F3 --> Calc
    F4 --> Calc
    F5 --> Calc
    
    Calc --> Low
    Calc --> Medium
    Calc --> High
    
    style Low fill:#4caf50,color:#fff
    style Medium fill:#ff9800
    style High fill:#f44336,color:#fff
```

**Risk Score Breakdown:**

```json
{
  "RiskId": "risk-901234",
  "OverallScore": 85,
  "RiskLevel": "Low",
  "Factors": {
    "DocumentAuthenticity": {
      "Score": 95,
      "Weight": 0.30,
      "Checks": {
        "NFCSignature": "Valid",
        "HologramPresent": true,
        "MicroPrint": "Verified"
      }
    },
    "FaceMatchQuality": {
      "Score": 92,
      "Weight": 0.25,
      "Similarity": 0.92
    },
    "LivenessScore": {
      "Score": 96,
      "Weight": 0.20,
      "Method": "Passive + Active"
    },
    "BlacklistCheck": {
      "Score": 100,
      "Weight": 0.15,
      "Found": false
    },
    "BehavioralAnalysis": {
      "Score": 70,
      "Weight": 0.10,
      "Factors": {
        "DeviceReputation": "Good",
        "LocationConsistency": "High",
        "TimePattern": "Normal"
      }
    }
  },
  "Recommendation": "Approve",
  "ReviewRequired": false,
  "ComputedAt": "2025-12-15T10:33:00+07:00"
}
```

## Data Flow

### Complete eKYC Journey

```mermaid
sequenceDiagram
    participant User
    participant App
    participant Gateway
    participant NFC as NFC Service
    participant OCR as OCR Service
    participant Face as Face Service
    participant Risk as Risk Engine
    participant Result
    
    Note over User,Result: Step 1: NFC Verification
    User->>App: Tap CCCD
    App->>Gateway: NFC Data
    Gateway->>NFC: Verify Chip
    NFC-->>Gateway: NFC Result (Score: 95)
    
    Note over User,Result: Step 2: OCR Backup
    User->>App: Take Photos
    App->>Gateway: Front + Back Images
    Gateway->>OCR: Process Images
    OCR-->>Gateway: OCR Result (Score: 88)
    
    Note over User,Result: Step 3: Face Matching
    User->>App: Take Selfie + Liveness
    App->>Gateway: Selfie + Frames
    Gateway->>Face: Match & Check Liveness
    Face-->>Gateway: Face Result (Score: 92)
    
    Note over User,Result: Step 4: Risk Assessment
    Gateway->>Risk: Calculate Final Risk
    Risk->>Risk: Blacklist Check
    Risk->>Risk: Behavioral Analysis
    Risk-->>Gateway: Risk Score: 85/100
    
    Gateway->>Result: Store Results
    Result-->>App: eKYC Complete<br/>Status: Approved
    App-->>User: ✓ Verification Successful
```

## Security & Privacy

### Data Protection

```mermaid
graph TB
    subgraph "Data Collection"
        Collect[User submits:<br/>• CCCD images<br/>• Selfie<br/>• NFC data]
    end
    
    subgraph "Encryption in Transit"
        TLS[TLS 1.3<br/>End-to-end Encryption]
    end
    
    subgraph "Processing"
        Process[Server-side Processing<br/>• OCR<br/>• Face recognition<br/>• Risk scoring]
    end
    
    subgraph "Encryption at Rest"
        Storage[AES-256 Encryption<br/>S3 Server-side Encryption]
    end
    
    subgraph "Data Retention"
        Retention[Retention Policy<br/>• Active: 90 days<br/>• Archive: 7 years<br/>• Auto-delete after]
    end
    
    subgraph "Access Control"
        Access[Strict Access Control<br/>• RBAC<br/>• Audit logs<br/>• MFA required]
    end
    
    Collect --> TLS
    TLS --> Process
    Process --> Storage
    Storage --> Retention
    Storage --> Access
    
    style TLS fill:#4caf50,color:#fff
    style Storage fill:#ff9800
    style Access fill:#f44336,color:#fff
```

**Privacy Compliance:**

- ✅ Nghị định 13/2023 (PDPA Vietnam)
- ✅ GDPR principles applied
- ✅ Explicit consent required
- ✅ Right to erasure supported
- ✅ Data minimization practiced
- ✅ Purpose limitation enforced

### Audit Logging

```json
{
  "EventId": "ekyc-evt-123456",
  "EventType": "eKYC.Verification",
  "Timestamp": "2025-12-15T10:30:00+07:00",
  "UserId": "user-abc123",
  "TPPId": "tpp-xyz789",
  "Actions": [
    {
      "Action": "NFC.Verify",
      "Status": "Success",
      "Duration": 1250,
      "RiskScore": 95
    },
    {
      "Action": "OCR.Process",
      "Status": "Success",
      "Duration": 2100,
      "Confidence": 88
    },
    {
      "Action": "Face.Match",
      "Status": "Success",
      "Duration": 850,
      "Similarity": 92
    },
    {
      "Action": "Risk.Calculate",
      "Status": "Success",
      "FinalScore": 85,
      "Decision": "Approved"
    }
  ],
  "DeviceInfo": {
    "DeviceId": "device-001",
    "Platform": "iOS",
    "Location": "10.7769,106.7009"
  },
  "DataRetention": {
    "ImagesStored": true,
    "RetentionPeriod": "90 days",
    "AutoDeleteDate": "2026-03-15"
  }
}
```

## Performance & SLA

**Target Metrics:**

| Service | Response Time (P95) | Accuracy | Uptime |
|---------|---------------------|----------|--------|
| NFC Verification | < 2s | 99.5% | 99.9% |
| OCR Document | < 3s | 95%+ | 99.9% |
| Face Matching | < 1s | 98%+ | 99.9% |
| Liveness Detection | < 1.5s | 97%+ | 99.9% |
| Risk Scoring | < 500ms | N/A | 99.9% |

## Error Handling

| Error Code | Mô Tả | Action |
|------------|-------|--------|
| `NFC_READ_FAILED` | Không đọc được chip | Thử lại hoặc dùng OCR |
| `DOCUMENT_INVALID` | CCCD không hợp lệ | Kiểm tra ảnh chụp |
| `FACE_NOT_DETECTED` | Không phát hiện khuôn mặt | Chụp lại trong điều kiện sáng tốt |
| `LIVENESS_FAILED` | Phát hiện giả mạo | Yêu cầu xác thực trực tiếp |
| `SIMILARITY_LOW` | Khuôn mặt không khớp | Kiểm tra lại danh tính |
| `BLACKLIST_FOUND` | Tìm thấy trong blacklist | Từ chối giao dịch |
| `RATE_LIMIT_EXCEEDED` | Vượt giới hạn yêu cầu | Chờ và thử lại |

## Compliance Checklist

- [ ] Circular 45/2025 compliance (biometric auth)
- [ ] Quyết định 2345/QĐ-NHNN (CCCD chip standards)
- [ ] ISO 30107 liveness detection
- [ ] Nghị định 13/2023 data protection
- [ ] AES-256 encryption at rest
- [ ] TLS 1.3 for data in transit
- [ ] Audit logs retained 7 years
- [ ] Consent management implemented
- [ ] Right to erasure supported
- [ ] Regular security audits conducted

## Tài Liệu Tham Khảo

- **Thông tư 64/2024/TT-NHNN** - Open API
- **Circular 45/2025/TT-NHNN** - Biometric Authentication
- **Quyết định 2345/QĐ-NHNN** - CCCD Standards
- **Nghị định 13/2023/NĐ-CP** - Data Protection
- **ISO 30107** - Liveness Detection Standards
- **ISO 19794** - Biometric Data Formats

---

**Phiên bản:** 1.0  
**Ngày cập nhật:** 15/12/2025  
**Trạng thái:** Production Ready
