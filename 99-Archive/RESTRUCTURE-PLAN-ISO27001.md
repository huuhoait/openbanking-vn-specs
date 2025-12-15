# Open Banking Documentation - ISO 27001:2022 Restructure Plan

> **Ngày:** 15/12/2025  
> **Mục đích:** Tái cấu trúc tài liệu theo tiêu chuẩn ISO 27001:2022 ISMS  
> **Tuân thủ:** ISO 27001:2022 (93 controls) | Thông tư 64/2024/TT-NHNN

## 📋 Current Structure Analysis

### Hiện Tại (Flat Structure)
```
open-banking-design/
├── 01-Kien-truc-he-thong.md
├── 02-Bao-mat-va-Xac-thuc-new.md
├── 03-Quan-tri-API-va-Onboarding-NEW.md
├── 04-Dich-vu-Tai-khoan-AIS.md
├── 05-Dich-vu-Thanh-toan-PIS.md
├── 06-Dich-vu-The-va-Tokenization.md
├── 07-Dich-vu-Dinh-danh-eKYC.md
├── 08-Doi-soat-va-Tra-soat.md
├── 09-Thuong-mai-hoa-API.md
├── 10-Van-hanh-va-NFR.md
├── 11-Bao-cao-Kinh-doanh.md
├── BRD_OpenBanking.md
├── ISO-27001-2022-Compliance-Assessment.md
├── README.md
└── *-OLD.md files (backup)
```

**Vấn đề:**
- ❌ Không có cấu trúc phân cấp rõ ràng
- ❌ Khó tìm kiếm theo ISO 27001 controls
- ❌ Không phân biệt giữa ISMS documents và technical documents
- ❌ Thiếu các tài liệu bắt buộc theo ISO 27001:2022

## 🎯 Proposed Structure (ISO 27001:2022 Aligned)

```
open-banking-design/
│
├── 📁 00-ISMS-Management/                    # ISO 27001 ISMS Core
│   ├── ISMS-Policy.md                        # Information Security Policy
│   ├── ISMS-Scope.md                         # ISMS Scope Definition
│   ├── Statement-of-Applicability.md         # SoA (93 controls)
│   ├── Risk-Assessment-Register.md           # Risk assessment
│   ├── Risk-Treatment-Plan.md                # Risk treatment
│   ├── ISO-27001-2022-Compliance-Assessment.md  # Current file
│   └── Management-Review-Records.md          # Management review
│
├── 📁 01-Organizational-Controls/            # ISO 27001 A.5.x (37 controls)
│   ├── 01-Information-Security-Policies.md   # A.5.1
│   ├── 02-Roles-and-Responsibilities.md      # A.5.2, A.5.3, A.5.4
│   ├── 03-Contact-with-Authorities.md        # A.5.5, A.5.6 (NEW)
│   ├── 04-Threat-Intelligence.md             # A.5.7 (NEW)
│   ├── 05-Asset-Management.md                # A.5.9, A.5.10
│   ├── 06-Information-Classification.md      # A.5.12, A.5.13
│   ├── 07-Access-Control-Policy.md           # A.5.15-18
│   ├── 08-Supplier-Security.md               # A.5.19-22
│   ├── 09-Cloud-Security-Policy.md           # A.5.23 (NEW)
│   ├── 10-Incident-Management.md             # A.5.24-28
│   ├── 11-Business-Continuity.md             # A.5.29, A.5.30 (NEW)
│   ├── 12-Compliance-Management.md           # A.5.31-36
│   └── 13-Operating-Procedures.md            # A.5.37
│
├── 📁 02-People-Controls/                    # ISO 27001 A.6.x (8 controls)
│   ├── 01-HR-Security-Policy.md              # A.6.1-6.5 (NEW)
│   ├── 02-Security-Awareness-Training.md     # A.6.3 (NEW)
│   ├── 03-Remote-Working-Policy.md           # A.6.7 (NEW)
│   └── 04-Incident-Reporting-Procedure.md    # A.6.8
│
├── 📁 03-Physical-Controls/                  # ISO 27001 A.7.x (14 controls)
│   ├── 01-Physical-Security-Policy.md        # A.7.1-7.3 (NEW)
│   ├── 02-Physical-Monitoring.md             # A.7.4 (NEW)
│   ├── 03-Environmental-Protection.md        # A.7.5
│   ├── 04-Clear-Desk-Screen-Policy.md        # A.7.7 (NEW)
│   ├── 05-Equipment-Security.md              # A.7.8-7.14 (NEW)
│   └── 06-Data-Center-Security.md            # Combined (NEW)
│
├── 📁 04-Technological-Controls/             # ISO 27001 A.8.x (34 controls)
│   ├── 01-Endpoint-Security.md               # A.8.1
│   ├── 02-Access-Control-Technical.md        # A.8.2-8.5
│   ├── 03-Cryptography-Policy.md             # A.8.24
│   ├── 04-Network-Security.md                # A.8.20-8.23
│   ├── 05-Malware-Protection.md              # A.8.7 (NEW)
│   ├── 06-Backup-Recovery.md                 # A.8.13, A.8.14
│   ├── 07-Logging-Monitoring.md              # A.8.15, A.8.16 (NEW)
│   ├── 08-Configuration-Management.md        # A.8.9 (NEW)
│   ├── 09-Data-Protection.md                 # A.8.10-8.12 (NEW)
│   ├── 10-Vulnerability-Management.md        # A.8.8
│   ├── 11-Secure-Development.md              # A.8.25-8.34
│   └── 12-DLP-Policy.md                      # A.8.12 (NEW)
│
├── 📁 05-Architecture-Design/                # Technical Architecture
│   ├── 01-System-Architecture.md             # Current: 01-Kien-truc-he-thong.md
│   ├── 02-Security-Architecture.md           # Current: 02-Bao-mat-va-Xac-thuc-new.md
│   ├── 03-API-Gateway-Design.md              # Extracted from 01
│   ├── 04-Microservices-Design.md            # Extracted from 01
│   ├── 05-Data-Architecture.md               # NEW
│   └── 06-Integration-Architecture.md        # NEW
│
├── 📁 06-API-Management/                     # API Governance
│   ├── 01-API-Governance.md                  # Current: 03-Quan-tri-API
│   ├── 02-TPP-Onboarding.md                  # Extracted from 03
│   ├── 03-API-Lifecycle.md                   # Extracted from 03
│   ├── 04-API-Security-Standards.md          # NEW
│   └── 05-API-Versioning-Strategy.md         # NEW
│
├── 📁 07-Business-Services/                  # Business APIs
│   ├── 01-Account-Information-Service.md     # Current: 04-AIS
│   ├── 02-Payment-Initiation-Service.md      # Current: 05-PIS
│   ├── 03-Card-Services.md                   # Current: 06-The
│   ├── 04-eKYC-Services.md                   # Current: 07-eKYC
│   ├── 05-Reconciliation-Services.md         # Current: 08-Doi-soat
│   └── 06-Value-Added-Services.md            # NEW
│
├── 📁 08-Operations/                         # Operations & Support
│   ├── 01-Operations-NFR.md                  # Current: 10-Van-hanh
│   ├── 02-Monitoring-Alerting.md             # Extracted from 10
│   ├── 03-Incident-Response-Playbooks.md     # Extracted from 10
│   ├── 04-Change-Management.md               # Extracted from 10
│   ├── 05-Capacity-Planning.md               # Extracted from 10
│   └── 06-SLA-Management.md                  # NEW
│
├── 📁 09-Business-Intelligence/              # BI & Reporting
│   ├── 01-Business-Reports.md                # Current: 11-Bao-cao
│   ├── 02-Compliance-Reports.md              # Extracted from 11
│   ├── 03-Revenue-Analytics.md               # Extracted from 11
│   └── 04-Performance-Dashboards.md          # NEW
│
├── 📁 10-Monetization/                       # API Monetization
│   ├── 01-API-Monetization.md                # Current: 09-Thuong-mai-hoa
│   ├── 02-Pricing-Models.md                  # Extracted from 09
│   ├── 03-Billing-System.md                  # Extracted from 09
│   └── 04-Revenue-Optimization.md            # NEW
│
├── 📁 11-Compliance-Audit/                   # Compliance & Audit
│   ├── 01-Regulatory-Compliance.md           # Thông tư 64/2024
│   ├── 02-Audit-Procedures.md                # NEW
│   ├── 03-Internal-Audit-Reports/            # Folder for reports
│   ├── 04-External-Audit-Reports/            # Folder for reports
│   └── 05-Corrective-Actions.md              # NEW
│
├── 📁 12-Training-Awareness/                 # Training Materials
│   ├── 01-Security-Training-Program.md       # NEW
│   ├── 02-Developer-Guidelines.md            # NEW
│   ├── 03-TPP-Integration-Guide.md           # NEW
│   └── 04-End-User-Documentation.md          # NEW
│
├── 📁 99-Archive/                            # Old versions
│   ├── 2024-versions/
│   └── deprecated/
│
├── 📁 templates/                             # Document templates
│   ├── policy-template.md
│   ├── procedure-template.md
│   └── risk-assessment-template.md
│
├── 📁 assets/                                # Images, diagrams
│   ├── architecture/
│   ├── security/
│   └── processes/
│
├── BRD_OpenBanking.md                        # Business Requirements (Root)
├── README.md                                 # Main documentation index
├── CHANGELOG.md                              # Version history
└── CONTRIBUTING.md                           # Contribution guidelines
```

## 📊 Mapping: Current → New Structure

### Core Documents

| Current File                              | New Location                                                 | ISO Control              |
| ----------------------------------------- | ------------------------------------------------------------ | ------------------------ |
| `01-Kien-truc-he-thong.md`                | `05-Architecture-Design/01-System-Architecture.md`           | A.5.9, A.8.27            |
| `02-Bao-mat-va-Xac-thuc-new.md`           | `05-Architecture-Design/02-Security-Architecture.md`         | A.5.14-18, A.8.5, A.8.24 |
| `03-Quan-tri-API-va-Onboarding-NEW.md`    | `06-API-Management/01-API-Governance.md`                     | A.5.19-22                |
| `04-Dich-vu-Tai-khoan-AIS.md`             | `07-Business-Services/01-Account-Information-Service.md`     | A.5.34                   |
| `05-Dich-vu-Thanh-toan-PIS.md`            | `07-Business-Services/02-Payment-Initiation-Service.md`      | A.5.34                   |
| `06-Dich-vu-The-va-Tokenization.md`       | `07-Business-Services/03-Card-Services.md`                   | A.8.24                   |
| `07-Dich-vu-Dinh-danh-eKYC.md`            | `07-Business-Services/04-eKYC-Services.md`                   | A.6.1                    |
| `08-Doi-soat-va-Tra-soat.md`              | `07-Business-Services/05-Reconciliation-Services.md`         | A.5.33                   |
| `09-Thuong-mai-hoa-API.md`                | `10-Monetization/01-API-Monetization.md`                     | A.5.31                   |
| `10-Van-hanh-va-NFR.md`                   | `08-Operations/01-Operations-NFR.md`                         | A.5.24-30, A.8.6-19      |
| `11-Bao-cao-Kinh-doanh.md`                | `09-Business-Intelligence/01-Business-Reports.md`            | A.5.33                   |
| `ISO-27001-2022-Compliance-Assessment.md` | `00-ISMS-Management/ISO-27001-2022-Compliance-Assessment.md` | All                      |
| `BRD_OpenBanking.md`                      | `BRD_OpenBanking.md` (Root)                                  | A.5.31                   |

### New Documents to Create (Critical Gaps)

| New Document                                                | ISO Control  | Priority   | Deadline |
| ----------------------------------------------------------- | ------------ | ---------- | -------- |
| `03-Physical-Controls/01-Physical-Security-Policy.md`       | A.7.1-7.14   | 🔴 CRITICAL | Week 2   |
| `01-Organizational-Controls/03-Contact-with-Authorities.md` | A.5.5, A.5.6 | 🔴 CRITICAL | Week 1   |
| `04-Technological-Controls/05-Malware-Protection.md`        | A.8.7        | 🔴 CRITICAL | Week 2   |
| `04-Technological-Controls/12-DLP-Policy.md`                | A.8.12       | 🔴 CRITICAL | Month 2  |
| `02-People-Controls/01-HR-Security-Policy.md`               | A.6.1-6.5    | 🟡 HIGH     | Month 1  |
| `02-People-Controls/02-Security-Awareness-Training.md`      | A.6.3        | 🟡 HIGH     | Month 1  |
| `01-Organizational-Controls/04-Threat-Intelligence.md`      | A.5.7        | 🟡 HIGH     | Month 2  |
| `01-Organizational-Controls/09-Cloud-Security-Policy.md`    | A.5.23       | 🟡 HIGH     | Month 2  |
| `00-ISMS-Management/Statement-of-Applicability.md`          | Required     | 🔴 CRITICAL | Week 3   |
| `00-ISMS-Management/Risk-Assessment-Register.md`            | Required     | 🔴 CRITICAL | Week 3   |

## 🚀 Migration Plan

### Phase 1: Setup Structure (Week 1)

```bash
# Create folder structure
mkdir -p 00-ISMS-Management
mkdir -p 01-Organizational-Controls
mkdir -p 02-People-Controls
mkdir -p 03-Physical-Controls
mkdir -p 04-Technological-Controls
mkdir -p 05-Architecture-Design
mkdir -p 06-API-Management
mkdir -p 07-Business-Services
mkdir -p 08-Operations
mkdir -p 09-Business-Intelligence
mkdir -p 10-Monetization
mkdir -p 11-Compliance-Audit
mkdir -p 12-Training-Awareness
mkdir -p 99-Archive
mkdir -p templates
mkdir -p assets/{architecture,security,processes}
```

### Phase 2: Move Existing Files (Week 1)

```bash
# Move to new structure
mv 01-Kien-truc-he-thong.md 05-Architecture-Design/01-System-Architecture.md
mv 02-Bao-mat-va-Xac-thuc-new.md 05-Architecture-Design/02-Security-Architecture.md
mv 03-Quan-tri-API-va-Onboarding-NEW.md 06-API-Management/01-API-Governance.md
mv 04-Dich-vu-Tai-khoan-AIS.md 07-Business-Services/01-Account-Information-Service.md
mv 05-Dich-vu-Thanh-toan-PIS.md 07-Business-Services/02-Payment-Initiation-Service.md
mv 06-Dich-vu-The-va-Tokenization.md 07-Business-Services/03-Card-Services.md
mv 07-Dich-vu-Dinh-danh-eKYC.md 07-Business-Services/04-eKYC-Services.md
mv 08-Doi-soat-va-Tra-soat.md 07-Business-Services/05-Reconciliation-Services.md
mv 09-Thuong-mai-hoa-API.md 10-Monetization/01-API-Monetization.md
mv 10-Van-hanh-va-NFR.md 08-Operations/01-Operations-NFR.md
mv 11-Bao-cao-Kinh-doanh.md 09-Business-Intelligence/01-Business-Reports.md
mv ISO-27001-2022-Compliance-Assessment.md 00-ISMS-Management/

# Archive old versions
mv *-OLD.md 99-Archive/
mv 03-Quan-tri-API-va-Onboarding.md 99-Archive/

# Move images
mv img/* assets/
```

### Phase 3: Create Critical Gap Documents (Week 2-4)

Priority order:
1. ✅ Contact with Authorities (Week 1)
2. ✅ Physical Security Policy (Week 2)
3. ✅ Statement of Applicability (Week 3)
4. ✅ Risk Assessment Register (Week 3)
5. ✅ Malware Protection Policy (Week 4)

### Phase 4: Create Remaining Documents (Month 2-3)

All remaining documents from the gap analysis.

### Phase 5: Update Cross-References (Month 3)

Update all internal links to reflect new structure.

## 📝 Document Naming Convention

### Format
```
[Number]-[Descriptive-Name].md
```

### Examples
- ✅ `01-Information-Security-Policies.md`
- ✅ `02-Security-Architecture.md`
- ❌ `security_policy.md` (no number, underscore)
- ❌ `Policy.md` (too generic)

### Numbering
- **00-09**: ISMS Core
- **10-19**: Organizational
- **20-29**: People
- **30-39**: Physical
- **40-49**: Technological
- **50-59**: Architecture
- **60-69**: API Management
- **70-79**: Business Services
- **80-89**: Operations
- **90-99**: Archive

## 🔍 Benefits of New Structure

### 1. ISO 27001:2022 Alignment
- ✅ Tài liệu được tổ chức theo 4 nhóm controls
- ✅ Dễ dàng map với Statement of Applicability
- ✅ Audit trail rõ ràng

### 2. Easier Navigation
- ✅ Phân cấp logic theo chức năng
- ✅ Dễ tìm kiếm theo control number
- ✅ Separation of concerns

### 3. Better Governance
- ✅ Rõ ràng ownership từng folder
- ✅ Version control tốt hơn
- ✅ Change management dễ dàng

### 4. Compliance Ready
- ✅ Đáp ứng yêu cầu ISO 27001 certification
- ✅ Sẵn sàng cho external audit
- ✅ Tuân thủ Thông tư 64/2024

## 📋 Checklist

### Pre-Migration
- [ ] Backup toàn bộ repository
- [ ] Review current structure
- [ ] Communicate to team
- [ ] Create migration branch

### Migration
- [ ] Create folder structure
- [ ] Move existing files
- [ ] Update file headers
- [ ] Update cross-references
- [ ] Update README.md
- [ ] Test all links

### Post-Migration
- [ ] Update CI/CD pipelines
- [ ] Update documentation website
- [ ] Train team on new structure
- [ ] Archive old structure
- [ ] Merge to main branch

## 🎯 Success Criteria

- ✅ All files in correct folders
- ✅ All links working
- ✅ No broken references
- ✅ README.md updated
- ✅ Team trained
- ✅ ISO 27001 compliance improved from 73% → 85%+

## 📅 Timeline

| Phase                  | Duration  | Deliverable              |
| ---------------------- | --------- | ------------------------ |
| Phase 1: Setup         | Week 1    | Folder structure created |
| Phase 2: Migration     | Week 1    | Files moved              |
| Phase 3: Critical Gaps | Week 2-4  | 5 critical documents     |
| Phase 4: Remaining     | Month 2-3 | All gap documents        |
| Phase 5: Finalization  | Month 3   | Links updated, tested    |

**Total Duration:** 3 months  
**Target Completion:** March 2026

---

**Version:** 1.0  
**Date:** 15/12/2025  
**Status:** PROPOSED  
**Approval Required:** Yes
