# Dịch Vụ Định Danh & Bảo Mật (eKYC & Identity Services)

## Tổng Quan

Nhóm API cung cấp dịch vụ định danh điện tử (eKYC), xác thực sinh trắc học và xác thực NFC CCCD theo Quyết định 2345/QĐ-NHNN.

## Kiến Trúc eKYC

```mermaid
graph TB
    subgraph "Client Layer"
        Mobile[Mobile App]
        Web[Web App]
    end
    
    subgraph "API Gateway"
        Gateway[API Gateway]
    end
    
    subgraph "eKYC Services"
        OCR[OCR Service<br/>Document Extraction]
        Liveness[Liveness Detection<br/>Anti-Spoofing]
        FaceMatch[Face Matching<br/>AI/ML]
        NFC[NFC Verification<br/>CCCD Chip]
    end
    
    subgraph "External Services"
        MPS[Ministry of Public Security<br/>Certificate Validation]
        Blacklist[Sanction/AML Lists]
    end
    
    subgraph "Data Storage"
        KYCVault[(eKYC Vault<br/>Encrypted Storage)]
        AuditLog[(Audit Logs)]
    end
    
    Mobile --> Gateway
    Web --> Gateway
    Gateway --> OCR
    Gateway --> Liveness
    Gateway --> FaceMatch
    Gateway --> NFC
    
    NFC --> MPS
    FaceMatch --> Blacklist
    
    OCR --> KYCVault
    Liveness --> KYCVault
    FaceMatch --> KYCVault
    NFC --> KYCVault
    
    Gateway --> AuditLog
```

## eKYC Flow - Standard Process

```mermaid
sequenceDiagram
    participant User as End User
    participant App as Mobile App
    participant API as eKYC API
    participant OCR as OCR Engine
    participant Liveness as Liveness Service
    participant FaceMatch as Face Matching
    participant Blacklist as AML/Sanction Check
    participant Vault as KYC Vault
    
    Note over User,App: Step 1: Document Capture
    User->>App: Capture ID Front
    App->>API: POST /ekyc/ocr<br/>+ Front Image
    API->>OCR: Extract Data
    OCR-->>API: Extracted Fields
    
    User->>App: Capture ID Back
    App->>API: POST /ekyc/ocr<br/>+ Back Image
    API->>OCR: Extract Data
    OCR-->>API: Extracted Fields
    
    Note over User,App: Step 2: Liveness Check
    User->>App: Perform Liveness Actions<br/>(Blink, Turn head)
    App->>API: POST /ekyc/liveness<br/>+ Video/Images
    API->>Liveness: Analyze Liveness
    Liveness-->>API: Liveness Score
    
    alt Liveness Failed
        API-->>App: Retry Required
    end
    
    Note over User,App: Step 3: Face Matching
    API->>FaceMatch: Compare Selfie vs ID Photo
    FaceMatch-->>API: Similarity Score (0-100)
    
    alt Score < 80%
        API-->>App: Face Match Failed
    end
    
    Note over API,Blacklist: Step 4: AML/Sanction Check
    API->>Blacklist: Check Name + DOB + ID Number
    Blacklist-->>API: Clear / Hit
    
    alt Sanction Hit
        API-->>App: KYC Rejected
    end
    
    Note over API,Vault: Step 5: Store Results
    API->>Vault: Encrypt & Store KYC Data
    Vault-->>API: eKYC Reference ID
    
    API-->>App: 200 OK<br/>eKYC Reference ID<br/>Verification Status
```

## API Endpoints

### 1. OCR - Document Extraction

#### POST /v1/ekyc/ocr

```mermaid
graph TB
    Image[ID Card Image]
    
    Image --> Preprocess[Image Preprocessing<br/>- Crop<br/>- Rotate<br/>- Enhance]
    Preprocess --> Detect[Detect Document Type<br/>CCCD/CMND/Passport]
    Detect --> Extract[OCR Extraction]
    
    Extract --> Parse[Parse Fields]
    Parse --> Validate[Validate Format<br/>- ID Number<br/>- Date Format<br/>- Checksum]
    
    Validate -->|Valid| Return[Return Structured Data]
    Validate -->|Invalid| Error[Return Error]
```

**Request:**
```json
{
  "DocumentType": "CCCD",
  "Side": "FRONT",
  "Image": "base64_encoded_image_data",
  "ImageFormat": "JPEG"
}
```

**Response:**
```json
{
  "Data": {
    "DocumentType": "CCCD",
    "IDNumber": "001234567890",
    "FullName": "NGUYEN VAN A",
    "DateOfBirth": "01/01/1990",
    "Gender": "Nam",
    "Nationality": "Việt Nam",
    "PlaceOfOrigin": "Hà Nội",
    "PlaceOfResidence": "123 Nguyễn Huệ, Q.1, TP.HCM",
    "ExpiryDate": "01/01/2035",
    "Confidence": {
      "Overall": 0.95,
      "IDNumber": 0.98,
      "FullName": 0.96,
      "DateOfBirth": 0.97
    },
    "FaceImage": "base64_encoded_face_crop"
  }
}
```

### 2. Liveness Detection

#### POST /v1/ekyc/liveness

```mermaid
graph TB
    Input[Video/Image Sequence]
    
    Input --> DetectFace[Detect Face in Frames]
    DetectFace --> CheckActions{Check Actions}
    
    CheckActions --> Blink[Blink Detection]
    CheckActions --> Turn[Head Turn Detection]
    CheckActions --> Smile[Smile Detection]
    
    Blink --> AntiSpoof[Anti-Spoofing Analysis<br/>- Texture Analysis<br/>- 3D Depth<br/>- Motion Patterns]
    Turn --> AntiSpoof
    Smile --> AntiSpoof
    
    AntiSpoof --> Score{Liveness Score}
    Score -->|> 90%| Pass[Pass]
    Score -->|< 90%| Fail[Fail]
```

**Liveness Methods:**

| Method | Mô Tả | Độ An Toàn | Trải Nghiệm |
|--------|-------|------------|-------------|
| **Passive** | Phân tích ảnh tĩnh | Thấp | Tốt nhất |
| **Active** | Yêu cầu hành động (chớp mắt, quay đầu) | Trung bình | Tốt |
| **Hybrid** | Kết hợp Passive + Active | Cao | Chấp nhận được |

**Request:**
```json
{
  "LivenessMethod": "ACTIVE",
  "VideoData": "base64_encoded_video",
  "VideoFormat": "MP4",
  "RequiredActions": ["BLINK", "TURN_LEFT", "TURN_RIGHT"]
}
```

**Response:**
```json
{
  "Data": {
    "LivenessScore": 0.95,
    "Status": "PASS",
    "DetectedActions": {
      "BLINK": true,
      "TURN_LEFT": true,
      "TURN_RIGHT": true
    },
    "SpoofingIndicators": {
      "PrintedPhoto": 0.02,
      "DigitalScreen": 0.01,
      "Mask": 0.00
    },
    "BestFrameImage": "base64_encoded_best_frame"
  }
}
```

### 3. Face Matching

#### POST /v1/ekyc/face-match

```mermaid
sequenceDiagram
    participant API as eKYC API
    participant FaceDetect as Face Detection
    participant FeatureExtract as Feature Extraction
    participant Compare as Similarity Comparison
    participant Threshold as Threshold Check
    
    API->>FaceDetect: Detect Face in Image 1
    API->>FaceDetect: Detect Face in Image 2
    
    FaceDetect-->>FeatureExtract: Face Bounding Boxes
    FeatureExtract->>FeatureExtract: Extract 128D Embeddings
    
    FeatureExtract-->>Compare: Embedding Vector 1
    FeatureExtract-->>Compare: Embedding Vector 2
    
    Compare->>Compare: Calculate Cosine Similarity
    Compare-->>Threshold: Similarity Score
    
    Threshold->>Threshold: Check Threshold (0.8)
    Threshold-->>API: Match Result + Score
```

**Request:**
```json
{
  "SourceImage": "base64_encoded_id_photo",
  "TargetImage": "base64_encoded_selfie",
  "Threshold": 0.80
}
```

**Response:**
```json
{
  "Data": {
    "SimilarityScore": 0.92,
    "IsMatch": true,
    "Confidence": "HIGH",
    "FaceQuality": {
      "SourceImage": {
        "Brightness": 0.85,
        "Sharpness": 0.90,
        "FaceSize": "ADEQUATE"
      },
      "TargetImage": {
        "Brightness": 0.88,
        "Sharpness": 0.92,
        "FaceSize": "ADEQUATE"
      }
    }
  }
}
```

## NFC CCCD Verification (QĐ 2345)

### NFC Chip Reading Flow

```mermaid
sequenceDiagram
    participant User as User
    participant App as Mobile App
    participant NFC_SDK as NFC SDK
    participant API as Bank API
    participant MPS as Ministry of Public Security
    
    Note over User,App: Step 1: Prepare
    User->>App: Initiate NFC Scan
    App->>User: Request CCCD Info<br/>(ID Number + DOB + Expiry)
    User->>App: Enter Info (for BAC)
    
    Note over User,NFC_SDK: Step 2: NFC Reading
    App->>NFC_SDK: Initialize NFC Session
    User->>NFC_SDK: Tap CCCD to Phone
    
    NFC_SDK->>NFC_SDK: Basic Access Control (BAC)<br/>using ID + DOB + Expiry
    NFC_SDK->>NFC_SDK: Read DG1 (MRZ Data)
    NFC_SDK->>NFC_SDK: Read DG2 (Face Image)
    NFC_SDK->>NFC_SDK: Read SOD (Security Object)
    
    Note over NFC_SDK: Step 3: Active Authentication
    NFC_SDK->>NFC_SDK: Challenge Chip
    NFC_SDK->>NFC_SDK: Verify Chip Signature
    
    NFC_SDK-->>App: Chip Data + Signature
    
    Note over App,MPS: Step 4: Verify with MPS
    App->>API: POST /ekyc/nfc-verify<br/>+ Chip Data + SOD
    API->>API: Verify SOD Signature
    API->>MPS: Validate Certificate Chain
    MPS-->>API: Certificate Valid
    
    API->>API: Extract Personal Info from DG1
    API->>API: Extract Face from DG2
    API->>API: Compare with Existing Data
    
    API-->>App: Verification Result<br/>+ Personal Info
```

### NFC Data Groups

```mermaid
graph TB
    subgraph "CCCD Chip Data"
        DG1[DG1: MRZ Data<br/>- ID Number<br/>- Name<br/>- DOB<br/>- Nationality]
        
        DG2[DG2: Face Image<br/>- JPEG format<br/>- High quality]
        
        DG13[DG13: Optional Data<br/>- Additional info]
        
        SOD[SOD: Security Object<br/>- Digital Signature<br/>- Hash of all DGs]
        
        COM[COM: Common Data<br/>- Available DGs list]
    end
    
    subgraph "Security"
        BAC[Basic Access Control<br/>Key derived from:<br/>ID + DOB + Expiry]
        
        AA[Active Authentication<br/>Chip proves it's genuine]
        
        PA[Passive Authentication<br/>Verify SOD signature]
    end
    
    BAC --> DG1
    BAC --> DG2
    BAC --> DG13
    BAC --> SOD
    
    SOD --> PA
    DG1 --> AA
```

### API Endpoint: NFC Verification

#### POST /v1/ekyc/nfc-verify

**Request:**
```json
{
  "ChipData": {
    "DG1": "base64_encoded_mrz_data",
    "DG2": "base64_encoded_face_image",
    "SOD": "base64_encoded_security_object",
    "ActiveAuthSignature": "base64_encoded_aa_signature"
  },
  "DeviceInfo": {
    "DeviceModel": "iPhone 15 Pro",
    "OSVersion": "iOS 17.2",
    "NFCCapability": true
  }
}
```

**Response:**
```json
{
  "Data": {
    "VerificationStatus": "VERIFIED",
    "ChipAuthenticity": "GENUINE",
    "CertificateValidation": {
      "Status": "VALID",
      "IssuerCountry": "VN",
      "IssuerOrganization": "Ministry of Public Security"
    },
    "PersonalInfo": {
      "IDNumber": "001234567890",
      "FullName": "NGUYEN VAN A",
      "DateOfBirth": "01/01/1990",
      "Gender": "M",
      "Nationality": "VNM",
      "DocumentNumber": "A12345678",
      "ExpiryDate": "01/01/2035"
    },
    "BiometricData": {
      "FaceImage": "base64_encoded_face_from_chip",
      "FaceQuality": 0.95
    },
    "VerificationTimestamp": "2024-12-10T18:45:00+07:00",
    "eKYCReferenceId": "ekyc-nfc-12345"
  }
}
```

## Complete eKYC Journey

```mermaid
stateDiagram-v2
    [*] --> DocumentCapture: Start eKYC
    DocumentCapture --> OCRProcessing: Images captured
    OCRProcessing --> LivenessCheck: OCR success
    OCRProcessing --> DocumentCapture: OCR failed (retry)
    
    LivenessCheck --> FaceMatching: Liveness passed
    LivenessCheck --> LivenessCheck: Liveness failed (retry)
    
    FaceMatching --> AMLCheck: Face matched
    FaceMatching --> Failed: Face not matched
    
    AMLCheck --> NFCVerification: AML clear
    AMLCheck --> Failed: Sanction hit
    
    NFCVerification --> Completed: NFC verified (Level 4)
    NFCVerification --> Completed: Skip NFC (Level 3)
    NFCVerification --> NFCVerification: NFC failed (retry)
    
    Completed --> [*]
    Failed --> [*]
    
    note right of NFCVerification
        NFC required for:
        - Credit card issuance
        - High-value transactions
        - Account opening
    end note
```

## Authentication Levels (QĐ 2345)

```mermaid
graph TB
    subgraph "Level 1: Basic"
        L1_User[Username]
        L1_Pass[Password]
        L1_User --> L1_Pass
    end
    
    subgraph "Level 2: Two-Factor"
        L2_Pass[Password]
        L2_OTP[SMS/Email OTP]
        L2_Pass --> L2_OTP
    end
    
    subgraph "Level 3: Biometric"
        L3_Bio[Fingerprint/FaceID]
        L3_Device[Trusted Device]
        L3_Bio --> L3_Device
    end
    
    subgraph "Level 4: Enhanced"
        L4_NFC[NFC CCCD Verification]
        L4_Face[Face Match with Chip]
        L4_Liveness[Liveness Detection]
        L4_NFC --> L4_Face
        L4_Face --> L4_Liveness
    end
    
    L1_Pass --> L2_Pass
    L2_OTP --> L3_Bio
    L3_Device --> L4_NFC
    
    style L4_NFC fill:#ff6b6b
    style L4_Face fill:#ff6b6b
    style L4_Liveness fill:#ff6b6b
```

### Use Cases by Level

| Giao Dịch | Giá Trị | Level Yêu Cầu |
|-----------|---------|---------------|
| Tra cứu số dư | N/A | Level 2 |
| Chuyển tiền nội bộ | < 2M VND | Level 2 |
| Chuyển tiền nội bộ | 2M - 10M VND | Level 3 |
| Chuyển tiền liên ngân hàng | < 10M VND | Level 3 |
| Chuyển tiền liên ngân hàng | ≥ 10M VND | Level 4 |
| Mở tài khoản | N/A | Level 4 |
| Phát hành thẻ tín dụng | N/A | Level 4 |
| Thay đổi hạn mức thẻ | N/A | Level 4 |

## OTP Service

### OTP Generation & Validation

```mermaid
sequenceDiagram
    participant User as User
    participant App as App
    participant API as OTP API
    participant Generator as OTP Generator
    participant SMS as SMS Gateway
    participant Cache as Redis Cache
    
    User->>App: Request OTP
    App->>API: POST /auth/otp/generate<br/>+ Phone Number
    
    API->>Generator: Generate 6-digit OTP
    Generator->>Generator: Random + Timestamp
    Generator-->>API: OTP Code
    
    API->>Cache: Store OTP<br/>Key: phone + purpose<br/>TTL: 5 minutes
    API->>SMS: Send OTP via SMS
    SMS-->>User: SMS with OTP
    
    API-->>App: 200 OK<br/>OTP Sent
    
    Note over User,App: User enters OTP
    
    User->>App: Enter OTP
    App->>API: POST /auth/otp/validate<br/>+ Phone + OTP
    
    API->>Cache: Retrieve stored OTP
    Cache-->>API: Stored OTP + Attempts
    
    alt OTP Match
        API->>Cache: Delete OTP
        API-->>App: 200 OK<br/>OTP Valid
    else OTP Mismatch
        API->>Cache: Increment Attempts
        alt Attempts < 3
            API-->>App: 400 Invalid OTP<br/>Retry
        else Attempts >= 3
            API->>Cache: Block Phone (15 mins)
            API-->>App: 429 Too Many Attempts
        end
    end
```

### Smart OTP (Push Notification)

```mermaid
sequenceDiagram
    participant User as User
    participant BankApp as Bank App
    participant API as API
    participant Push as Push Service
    
    Note over User,API: Transaction initiated
    
    API->>Push: Send Push Notification<br/>+ Transaction Details
    Push->>BankApp: Push to User's Device
    
    BankApp->>User: Show Notification<br/>"Approve transaction?"
    
    alt User Approves
        User->>BankApp: Tap Approve
        BankApp->>BankApp: Biometric Auth
        BankApp->>API: POST /auth/smart-otp/approve<br/>+ Session ID
        API-->>BankApp: Approved
    else User Denies
        User->>BankApp: Tap Deny
        BankApp->>API: POST /auth/smart-otp/deny
        API-->>BankApp: Denied
    end
```

## Data Security & Privacy

### PII Encryption

```mermaid
graph TB
    subgraph "Data at Rest"
        PII[Personal Identifiable Information]
        Encrypt[AES-256 Encryption]
        KMS[Key Management Service]
        Vault[(Encrypted Vault)]
        
        PII --> Encrypt
        KMS --> Encrypt
        Encrypt --> Vault
    end
    
    subgraph "Data in Transit"
        API[API Request]
        TLS[TLS 1.3]
        Server[Server]
        
        API --> TLS
        TLS --> Server
    end
    
    subgraph "Data in Use"
        Memory[In-Memory Processing]
        Mask[Data Masking]
        Log[Audit Logs]
        
        Memory --> Mask
        Mask --> Log
    end
```

### Data Retention

| Data Type | Retention Period | Storage |
|-----------|------------------|---------|
| ID Card Images | 5 years | Encrypted vault |
| Face Images | 5 years | Encrypted vault |
| eKYC Results | 5 years | Database (encrypted) |
| Audit Logs | 3 months (hot) + 1 year (cold) | Log storage |
| Biometric Templates | Until account closure | HSM |
| NFC Chip Data | 5 years | Encrypted vault |

## Compliance & Standards

### GDPR/Nghị định 13/2023 Compliance

```mermaid
graph LR
    subgraph "User Rights"
        Access[Right to Access]
        Rectify[Right to Rectify]
        Erase[Right to Erasure]
        Port[Right to Portability]
    end
    
    subgraph "Implementation"
        API_Access[GET /users/me/kyc-data]
        API_Update[PUT /users/me/kyc-data]
        API_Delete[DELETE /users/me/kyc-data]
        API_Export[GET /users/me/data-export]
    end
    
    Access --> API_Access
    Rectify --> API_Update
    Erase --> API_Delete
    Port --> API_Export
```

### ISO 30107 (Liveness Detection)

- **Part 1**: Framework
- **Part 2**: Data formats
- **Part 3**: Testing and reporting

### ISO 19794 (Biometric Data)

- **Part 5**: Face image data
- **Part 6**: Iris image data

## Error Handling

| Error Code | Mô Tả | HTTP Code | Retry? |
|------------|-------|-----------|--------|
| `OCR_FAILED` | Không đọc được thông tin | 422 | Yes |
| `LIVENESS_FAILED` | Phát hiện giả mạo | 422 | Yes (max 3) |
| `FACE_NOT_MATCHED` | Khuôn mặt không khớp | 422 | No |
| `NFC_READ_ERROR` | Lỗi đọc chip NFC | 422 | Yes |
| `CERTIFICATE_INVALID` | Chứng thư không hợp lệ | 422 | No |
| `SANCTION_HIT` | Trong danh sách đen | 403 | No |
| `DOCUMENT_EXPIRED` | Giấy tờ hết hạn | 422 | No |
| `POOR_IMAGE_QUALITY` | Chất lượng ảnh kém | 400 | Yes |

## Best Practices

### Image Quality Requirements

```json
{
  "MinimumResolution": "1280x720",
  "MaxFileSize": "5MB",
  "AcceptedFormats": ["JPEG", "PNG"],
  "MinBrightness": 0.3,
  "MaxBrightness": 0.9,
  "MinSharpness": 0.5,
  "FaceMinSize": "200x200 pixels"
}
```

### Anti-Fraud Measures

- Device fingerprinting
- IP geolocation check
- Velocity checks (max 3 attempts/hour)
- Behavioral biometrics
- Document forensics (detect photoshop)

## Tài Liệu Tham Khảo
- Quyết định 2345/QĐ-NHNN
- Nghị định 13/2023/NĐ-CP (Data Protection)
- ISO 30107 (Liveness Detection)
- ISO 19794 (Biometric Data Formats)
- ICAO Doc 9303 (Machine Readable Travel Documents)
- NIST SP 800-63B (Digital Identity Guidelines)
