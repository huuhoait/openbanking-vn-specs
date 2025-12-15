#!/bin/bash

###############################################################################
# Open Banking Documentation - ISO 27001:2022 Restructure Script
# Version: 1.0
# Date: 15/12/2025
# Purpose: Migrate documentation to ISO 27001:2022 aligned structure
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Open Banking - ISO 27001:2022 Documentation Restructure      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

###############################################################################
# Phase 1: Backup
###############################################################################

backup_current_structure() {
    echo -e "${YELLOW}[Phase 1] Creating backup...${NC}"
    
    BACKUP_DIR="99-Archive/backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup all .md files
    cp *.md "$BACKUP_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}✓ Backup created: $BACKUP_DIR${NC}"
}

###############################################################################
# Phase 2: Create Folder Structure
###############################################################################

create_folder_structure() {
    echo -e "${YELLOW}[Phase 2] Creating ISO 27001:2022 folder structure...${NC}"
    
    # ISMS Management
    mkdir -p "00-ISMS-Management"
    
    # Organizational Controls (A.5.x)
    mkdir -p "01-Organizational-Controls"
    
    # People Controls (A.6.x)
    mkdir -p "02-People-Controls"
    
    # Physical Controls (A.7.x)
    mkdir -p "03-Physical-Controls"
    
    # Technological Controls (A.8.x)
    mkdir -p "04-Technological-Controls"
    
    # Architecture & Design
    mkdir -p "05-Architecture-Design"
    
    # API Management
    mkdir -p "06-API-Management"
    
    # Business Services
    mkdir -p "07-Business-Services"
    
    # Operations
    mkdir -p "08-Operations"
    
    # Business Intelligence
    mkdir -p "09-Business-Intelligence"
    
    # Monetization
    mkdir -p "10-Monetization"
    
    # Compliance & Audit
    mkdir -p "11-Compliance-Audit"
    mkdir -p "11-Compliance-Audit/03-Internal-Audit-Reports"
    mkdir -p "11-Compliance-Audit/04-External-Audit-Reports"
    
    # Training & Awareness
    mkdir -p "12-Training-Awareness"
    
    # Archive
    mkdir -p "99-Archive/deprecated"
    mkdir -p "99-Archive/2024-versions"
    
    # Templates
    mkdir -p "templates"
    
    # Assets
    mkdir -p "assets/architecture"
    mkdir -p "assets/security"
    mkdir -p "assets/processes"
    
    echo -e "${GREEN}✓ Folder structure created${NC}"
}

###############################################################################
# Phase 3: Move Existing Files
###############################################################################

move_existing_files() {
    echo -e "${YELLOW}[Phase 3] Moving existing files to new structure...${NC}"
    
    # Architecture & Design
    if [ -f "01-Kien-truc-he-thong.md" ]; then
        mv "01-Kien-truc-he-thong.md" "05-Architecture-Design/01-System-Architecture.md"
        echo -e "${GREEN}✓ Moved: System Architecture${NC}"
    fi
    
    if [ -f "02-Bao-mat-va-Xac-thuc-new.md" ]; then
        mv "02-Bao-mat-va-Xac-thuc-new.md" "05-Architecture-Design/02-Security-Architecture.md"
        echo -e "${GREEN}✓ Moved: Security Architecture${NC}"
    fi
    
    # API Management
    if [ -f "03-Quan-tri-API-va-Onboarding-NEW.md" ]; then
        mv "03-Quan-tri-API-va-Onboarding-NEW.md" "06-API-Management/01-API-Governance.md"
        echo -e "${GREEN}✓ Moved: API Governance${NC}"
    fi
    
    # Business Services
    if [ -f "04-Dich-vu-Tai-khoan-AIS.md" ]; then
        mv "04-Dich-vu-Tai-khoan-AIS.md" "07-Business-Services/01-Account-Information-Service.md"
        echo -e "${GREEN}✓ Moved: AIS${NC}"
    fi
    
    if [ -f "05-Dich-vu-Thanh-toan-PIS.md" ]; then
        mv "05-Dich-vu-Thanh-toan-PIS.md" "07-Business-Services/02-Payment-Initiation-Service.md"
        echo -e "${GREEN}✓ Moved: PIS${NC}"
    fi
    
    if [ -f "06-Dich-vu-The-va-Tokenization.md" ]; then
        mv "06-Dich-vu-The-va-Tokenization.md" "07-Business-Services/03-Card-Services.md"
        echo -e "${GREEN}✓ Moved: Card Services${NC}"
    fi
    
    if [ -f "07-Dich-vu-Dinh-danh-eKYC.md" ]; then
        mv "07-Dich-vu-Dinh-danh-eKYC.md" "07-Business-Services/04-eKYC-Services.md"
        echo -e "${GREEN}✓ Moved: eKYC Services${NC}"
    fi
    
    if [ -f "08-Doi-soat-va-Tra-soat.md" ]; then
        mv "08-Doi-soat-va-Tra-soat.md" "07-Business-Services/05-Reconciliation-Services.md"
        echo -e "${GREEN}✓ Moved: Reconciliation${NC}"
    fi
    
    # Monetization
    if [ -f "09-Thuong-mai-hoa-API.md" ]; then
        mv "09-Thuong-mai-hoa-API.md" "10-Monetization/01-API-Monetization.md"
        echo -e "${GREEN}✓ Moved: API Monetization${NC}"
    fi
    
    # Operations
    if [ -f "10-Van-hanh-va-NFR.md" ]; then
        mv "10-Van-hanh-va-NFR.md" "08-Operations/01-Operations-NFR.md"
        echo -e "${GREEN}✓ Moved: Operations & NFR${NC}"
    fi
    
    # Business Intelligence
    if [ -f "11-Bao-cao-Kinh-doanh.md" ]; then
        mv "11-Bao-cao-Kinh-doanh.md" "09-Business-Intelligence/01-Business-Reports.md"
        echo -e "${GREEN}✓ Moved: Business Reports${NC}"
    fi
    
    # ISMS Management
    if [ -f "ISO-27001-2022-Compliance-Assessment.md" ]; then
        mv "ISO-27001-2022-Compliance-Assessment.md" "00-ISMS-Management/ISO-27001-2022-Compliance-Assessment.md"
        echo -e "${GREEN}✓ Moved: ISO 27001 Assessment${NC}"
    fi
    
    # Archive old versions
    mv *-OLD.md "99-Archive/deprecated/" 2>/dev/null || true
    mv "03-Quan-tri-API-va-Onboarding.md" "99-Archive/deprecated/" 2>/dev/null || true
    
    # Move images
    if [ -d "img" ]; then
        cp -r img/* "assets/" 2>/dev/null || true
        echo -e "${GREEN}✓ Moved: Images to assets${NC}"
    fi
    
    echo -e "${GREEN}✓ File migration completed${NC}"
}

###############################################################################
# Phase 4: Create Index Files
###############################################################################

create_index_files() {
    echo -e "${YELLOW}[Phase 4] Creating index files...${NC}"
    
    # Create README for each folder
    create_folder_readme "00-ISMS-Management" "ISMS Management Documents" "Core ISO 27001:2022 ISMS documentation"
    create_folder_readme "01-Organizational-Controls" "Organizational Controls (A.5.x)" "37 organizational security controls"
    create_folder_readme "02-People-Controls" "People Controls (A.6.x)" "8 people-related security controls"
    create_folder_readme "03-Physical-Controls" "Physical Controls (A.7.x)" "14 physical security controls"
    create_folder_readme "04-Technological-Controls" "Technological Controls (A.8.x)" "34 technological security controls"
    create_folder_readme "05-Architecture-Design" "Architecture & Design" "System and security architecture"
    create_folder_readme "06-API-Management" "API Management" "API governance and lifecycle"
    create_folder_readme "07-Business-Services" "Business Services" "Open Banking business services"
    create_folder_readme "08-Operations" "Operations" "Operational procedures and NFRs"
    create_folder_readme "09-Business-Intelligence" "Business Intelligence" "Reporting and analytics"
    create_folder_readme "10-Monetization" "Monetization" "API monetization and billing"
    create_folder_readme "11-Compliance-Audit" "Compliance & Audit" "Compliance and audit documentation"
    create_folder_readme "12-Training-Awareness" "Training & Awareness" "Security training materials"
    
    echo -e "${GREEN}✓ Index files created${NC}"
}

create_folder_readme() {
    local folder=$1
    local title=$2
    local description=$3
    
    cat > "$folder/README.md" << EOF
# $title

> $description

## ISO 27001:2022 Mapping

This folder contains documentation related to ISO 27001:2022 controls.

## Documents

EOF
    
    # List all .md files in the folder
    for file in "$folder"/*.md; do
        if [ -f "$file" ] && [ "$(basename "$file")" != "README.md" ]; then
            echo "- [$(basename "$file" .md)](./$( basename "$file"))" >> "$folder/README.md"
        fi
    done
    
    echo -e "${GREEN}✓ Created README for $folder${NC}"
}

###############################################################################
# Phase 5: Update Main README
###############################################################################

update_main_readme() {
    echo -e "${YELLOW}[Phase 5] Updating main README.md...${NC}"
    
    cat > "README-NEW.md" << 'EOF'
# Open Banking Platform Documentation

> **Tuân thủ:** ISO 27001:2022 | Thông tư 64/2024/TT-NHNN | FAPI 2.0 | OAuth 2.1

## 📚 Documentation Structure

This documentation is organized according to **ISO 27001:2022** Information Security Management System (ISMS) structure.

### 🔐 ISO 27001:2022 Controls

```
├── 00-ISMS-Management/              # ISMS Core Documents
├── 01-Organizational-Controls/      # A.5.x (37 controls)
├── 02-People-Controls/              # A.6.x (8 controls)
├── 03-Physical-Controls/            # A.7.x (14 controls)
└── 04-Technological-Controls/       # A.8.x (34 controls)
```

### 🏗️ Technical Documentation

```
├── 05-Architecture-Design/          # System & Security Architecture
├── 06-API-Management/               # API Governance & Lifecycle
├── 07-Business-Services/            # Open Banking Services (AIS, PIS, etc.)
├── 08-Operations/                   # Operations & NFR
├── 09-Business-Intelligence/        # Reporting & Analytics
└── 10-Monetization/                 # API Monetization & Billing
```

### 📋 Compliance & Training

```
├── 11-Compliance-Audit/             # Compliance & Audit
└── 12-Training-Awareness/           # Security Training
```

## 🚀 Quick Start

### For Business Stakeholders
- [Business Requirements Document (BRD)](./BRD_OpenBanking.md)
- [System Architecture](./05-Architecture-Design/01-System-Architecture.md)
- [Business Services Overview](./07-Business-Services/README.md)

### For Developers
- [API Governance](./06-API-Management/01-API-Governance.md)
- [Security Architecture](./05-Architecture-Design/02-Security-Architecture.md)
- [API Services](./07-Business-Services/README.md)

### For Security Team
- [ISO 27001:2022 Compliance Assessment](./00-ISMS-Management/ISO-27001-2022-Compliance-Assessment.md)
- [Security Architecture](./05-Architecture-Design/02-Security-Architecture.md)
- [Security Controls](./04-Technological-Controls/README.md)

### For Auditors
- [ISMS Management](./00-ISMS-Management/README.md)
- [Compliance Documentation](./11-Compliance-Audit/README.md)
- [ISO 27001 Assessment](./00-ISMS-Management/ISO-27001-2022-Compliance-Assessment.md)

## 📊 Compliance Status

| Standard | Status | Coverage |
|----------|--------|----------|
| **ISO 27001:2022** | 🟡 In Progress | 73% |
| **Thông tư 64/2024** | ✅ Compliant | 100% |
| **FAPI 2.0** | ✅ Compliant | 95% |
| **OAuth 2.1** | ✅ Compliant | 100% |

**Target:** ISO 27001:2022 Certification by Q3 2026

## 🎯 Key Documents

### Business
- [BRD - Open Banking](./BRD_OpenBanking.md)
- [Business Reports](./09-Business-Intelligence/01-Business-Reports.md)
- [API Monetization](./10-Monetization/01-API-Monetization.md)

### Architecture
- [System Architecture](./05-Architecture-Design/01-System-Architecture.md)
- [Security Architecture](./05-Architecture-Design/02-Security-Architecture.md)

### Services
- [Account Information Service (AIS)](./07-Business-Services/01-Account-Information-Service.md)
- [Payment Initiation Service (PIS)](./07-Business-Services/02-Payment-Initiation-Service.md)
- [Card Services](./07-Business-Services/03-Card-Services.md)
- [eKYC Services](./07-Business-Services/04-eKYC-Services.md)

### Operations
- [Operations & NFR](./08-Operations/01-Operations-NFR.md)
- [API Governance](./06-API-Management/01-API-Governance.md)

### Compliance
- [ISO 27001:2022 Assessment](./00-ISMS-Management/ISO-27001-2022-Compliance-Assessment.md)
- [Restructure Plan](./RESTRUCTURE-PLAN-ISO27001.md)

## 📖 Documentation Standards

### Naming Convention
- Format: `[Number]-[Descriptive-Name].md`
- Example: `01-System-Architecture.md`

### Document Structure
All documents should include:
- Title and metadata
- ISO 27001 control mapping (if applicable)
- Regulatory compliance references
- Version history

### Cross-References
Use relative paths for internal links:
```markdown
[Security Architecture](../05-Architecture-Design/02-Security-Architecture.md)
```

## 🔄 Version Control

- **Current Version:** 2.0 (ISO 27001:2022 Aligned)
- **Previous Version:** 1.0 (Flat structure) - See `99-Archive/`
- **Migration Date:** 15/12/2025

## 👥 Contribution

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## 📝 License

Internal use only - [Bank Name] Proprietary

---

**Last Updated:** 15/12/2025  
**Maintained by:** Information Security Team  
**Contact:** security@bank.vn
EOF

    echo -e "${GREEN}✓ Main README updated (saved as README-NEW.md)${NC}"
    echo -e "${YELLOW}  Review README-NEW.md and rename to README.md when ready${NC}"
}

###############################################################################
# Phase 6: Create Git Commit
###############################################################################

create_git_commit() {
    echo -e "${YELLOW}[Phase 6] Creating git commit...${NC}"
    
    git add .
    git status
    
    echo -e "${YELLOW}Ready to commit. Run:${NC}"
    echo -e "${BLUE}git commit -m 'Restructure documentation to ISO 27001:2022 aligned structure'${NC}"
}

###############################################################################
# Main Execution
###############################################################################

main() {
    echo -e "${BLUE}Starting migration...${NC}"
    echo ""
    
    # Confirm before proceeding
    read -p "This will reorganize all documentation files. Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Migration cancelled${NC}"
        exit 1
    fi
    
    backup_current_structure
    create_folder_structure
    move_existing_files
    create_index_files
    update_main_readme
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Migration Complete!                                           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Review the new structure"
    echo -e "2. Check README-NEW.md and rename to README.md"
    echo -e "3. Test all links"
    echo -e "4. Commit changes: ${BLUE}git commit -m 'Restructure to ISO 27001:2022'${NC}"
    echo ""
    echo -e "${YELLOW}Backup location:${NC} 99-Archive/backup-*"
}

# Run main function
main
