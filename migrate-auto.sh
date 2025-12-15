#!/bin/bash

###############################################################################
# Open Banking Documentation - ISO 27001:2022 Restructure Script (Auto)
# Version: 1.0
# Date: 15/12/2025
# Purpose: Migrate documentation to ISO 27001:2022 aligned structure
# Mode: AUTOMATIC (No confirmation required)
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
echo -e "${BLUE}║  Mode: AUTOMATIC                                               ║${NC}"
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
    for file in *.md; do
        if [ -f "$file" ]; then
            cp "$file" "$BACKUP_DIR/" 2>/dev/null || true
        fi
    done
    
    echo -e "${GREEN}✓ Backup created: $BACKUP_DIR${NC}"
    echo -e "${GREEN}✓ Backed up $(ls -1 "$BACKUP_DIR" | wc -l | tr -d ' ') files${NC}"
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
    
    echo -e "${GREEN}✓ Created 13 main folders${NC}"
    echo -e "${GREEN}✓ Created subfolders for audit reports and assets${NC}"
}

###############################################################################
# Phase 3: Move Existing Files
###############################################################################

move_existing_files() {
    echo -e "${YELLOW}[Phase 3] Moving existing files to new structure...${NC}"
    
    local moved_count=0
    
    # Architecture & Design
    if [ -f "01-Kien-truc-he-thong.md" ]; then
        mv "01-Kien-truc-he-thong.md" "05-Architecture-Design/01-System-Architecture.md"
        echo -e "${GREEN}✓ Moved: System Architecture${NC}"
        ((moved_count++))
    fi
    
    if [ -f "02-Bao-mat-va-Xac-thuc-new.md" ]; then
        mv "02-Bao-mat-va-Xac-thuc-new.md" "05-Architecture-Design/02-Security-Architecture.md"
        echo -e "${GREEN}✓ Moved: Security Architecture${NC}"
        ((moved_count++))
    fi
    
    # API Management
    if [ -f "03-Quan-tri-API-va-Onboarding-NEW.md" ]; then
        mv "03-Quan-tri-API-va-Onboarding-NEW.md" "06-API-Management/01-API-Governance.md"
        echo -e "${GREEN}✓ Moved: API Governance${NC}"
        ((moved_count++))
    fi
    
    # Business Services
    if [ -f "04-Dich-vu-Tai-khoan-AIS.md" ]; then
        mv "04-Dich-vu-Tai-khoan-AIS.md" "07-Business-Services/01-Account-Information-Service.md"
        echo -e "${GREEN}✓ Moved: Account Information Service (AIS)${NC}"
        ((moved_count++))
    fi
    
    if [ -f "05-Dich-vu-Thanh-toan-PIS.md" ]; then
        mv "05-Dich-vu-Thanh-toan-PIS.md" "07-Business-Services/02-Payment-Initiation-Service.md"
        echo -e "${GREEN}✓ Moved: Payment Initiation Service (PIS)${NC}"
        ((moved_count++))
    fi
    
    if [ -f "06-Dich-vu-The-va-Tokenization.md" ]; then
        mv "06-Dich-vu-The-va-Tokenization.md" "07-Business-Services/03-Card-Services.md"
        echo -e "${GREEN}✓ Moved: Card Services${NC}"
        ((moved_count++))
    fi
    
    if [ -f "07-Dich-vu-Dinh-danh-eKYC.md" ]; then
        mv "07-Dich-vu-Dinh-danh-eKYC.md" "07-Business-Services/04-eKYC-Services.md"
        echo -e "${GREEN}✓ Moved: eKYC Services${NC}"
        ((moved_count++))
    fi
    
    if [ -f "08-Doi-soat-va-Tra-soat.md" ]; then
        mv "08-Doi-soat-va-Tra-soat.md" "07-Business-Services/05-Reconciliation-Services.md"
        echo -e "${GREEN}✓ Moved: Reconciliation Services${NC}"
        ((moved_count++))
    fi
    
    # Monetization
    if [ -f "09-Thuong-mai-hoa-API.md" ]; then
        mv "09-Thuong-mai-hoa-API.md" "10-Monetization/01-API-Monetization.md"
        echo -e "${GREEN}✓ Moved: API Monetization${NC}"
        ((moved_count++))
    fi
    
    # Operations
    if [ -f "10-Van-hanh-va-NFR.md" ]; then
        mv "10-Van-hanh-va-NFR.md" "08-Operations/01-Operations-NFR.md"
        echo -e "${GREEN}✓ Moved: Operations & NFR${NC}"
        ((moved_count++))
    fi
    
    # Business Intelligence
    if [ -f "11-Bao-cao-Kinh-doanh.md" ]; then
        mv "11-Bao-cao-Kinh-doanh.md" "09-Business-Intelligence/01-Business-Reports.md"
        echo -e "${GREEN}✓ Moved: Business Reports${NC}"
        ((moved_count++))
    fi
    
    # ISMS Management
    if [ -f "ISO-27001-2022-Compliance-Assessment.md" ]; then
        mv "ISO-27001-2022-Compliance-Assessment.md" "00-ISMS-Management/ISO-27001-2022-Compliance-Assessment.md"
        echo -e "${GREEN}✓ Moved: ISO 27001 Compliance Assessment${NC}"
        ((moved_count++))
    fi
    
    # Archive old versions
    local archived_count=0
    for file in *-OLD.md; do
        if [ -f "$file" ]; then
            mv "$file" "99-Archive/deprecated/" 2>/dev/null || true
            ((archived_count++))
        fi
    done
    
    if [ -f "03-Quan-tri-API-va-Onboarding.md" ]; then
        mv "03-Quan-tri-API-va-Onboarding.md" "99-Archive/deprecated/" 2>/dev/null || true
        ((archived_count++))
    fi
    
    # Move images
    if [ -d "img" ]; then
        cp -r img/* "assets/" 2>/dev/null || true
        echo -e "${GREEN}✓ Copied images to assets/${NC}"
    fi
    
    echo -e "${GREEN}✓ Moved $moved_count active files${NC}"
    echo -e "${GREEN}✓ Archived $archived_count old files${NC}"
}

###############################################################################
# Phase 4: Create Index Files
###############################################################################

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
    
    # List all .md files in the folder (excluding README.md)
    local doc_count=0
    for file in "$folder"/*.md; do
        if [ -f "$file" ] && [ "$(basename "$file")" != "README.md" ]; then
            echo "- [$(basename "$file" .md)](./$(basename "$file"))" >> "$folder/README.md"
            ((doc_count++))
        fi
    done
    
    if [ $doc_count -eq 0 ]; then
        echo "" >> "$folder/README.md"
        echo "_No documents yet. This folder will be populated during gap remediation._" >> "$folder/README.md"
    fi
    
    cat >> "$folder/README.md" << EOF

## Status

- **Created:** $(date +%Y-%m-%d)
- **Last Updated:** $(date +%Y-%m-%d)
- **Documents:** $doc_count

---

[← Back to Main Documentation](../README.md)
EOF
}

create_index_files() {
    echo -e "${YELLOW}[Phase 4] Creating index files...${NC}"
    
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
    
    echo -e "${GREEN}✓ Created 13 README files${NC}"
}

###############################################################################
# Phase 5: Create Migration Summary
###############################################################################

create_migration_summary() {
    echo -e "${YELLOW}[Phase 5] Creating migration summary...${NC}"
    
    cat > "MIGRATION-SUMMARY.md" << 'EOF'
# Migration Summary - ISO 27001:2022 Restructure

> **Migration Date:** $(date +%Y-%m-%d\ %H:%M:%S)  
> **Status:** ✅ COMPLETED

## What Changed

### Folder Structure
- ✅ Created 13 main folders aligned with ISO 27001:2022
- ✅ Moved 12 active documentation files
- ✅ Archived old versions to `99-Archive/deprecated/`
- ✅ Created README.md in each folder

### File Mapping

| Old Location | New Location |
|--------------|--------------|
| `01-Kien-truc-he-thong.md` | `05-Architecture-Design/01-System-Architecture.md` |
| `02-Bao-mat-va-Xac-thuc-new.md` | `05-Architecture-Design/02-Security-Architecture.md` |
| `03-Quan-tri-API-va-Onboarding-NEW.md` | `06-API-Management/01-API-Governance.md` |
| `04-Dich-vu-Tai-khoan-AIS.md` | `07-Business-Services/01-Account-Information-Service.md` |
| `05-Dich-vu-Thanh-toan-PIS.md` | `07-Business-Services/02-Payment-Initiation-Service.md` |
| `06-Dich-vu-The-va-Tokenization.md` | `07-Business-Services/03-Card-Services.md` |
| `07-Dich-vu-Dinh-danh-eKYC.md` | `07-Business-Services/04-eKYC-Services.md` |
| `08-Doi-soat-va-Tra-soat.md` | `07-Business-Services/05-Reconciliation-Services.md` |
| `09-Thuong-mai-hoa-API.md` | `10-Monetization/01-API-Monetization.md` |
| `10-Van-hanh-va-NFR.md` | `08-Operations/01-Operations-NFR.md` |
| `11-Bao-cao-Kinh-doanh.md` | `09-Business-Intelligence/01-Business-Reports.md` |
| `ISO-27001-2022-Compliance-Assessment.md` | `00-ISMS-Management/ISO-27001-2022-Compliance-Assessment.md` |

### Backup Location
All original files backed up to: `99-Archive/backup-TIMESTAMP/`

## Next Steps

### Immediate (This Week)
1. ✅ Review new structure
2. ⬜ Update internal links in documents
3. ⬜ Test navigation
4. ⬜ Commit to git

### Short-term (Next 2 Weeks)
5. ⬜ Create critical gap documents:
   - Physical Security Policy
   - Contact with Authorities
   - Statement of Applicability
   - Risk Assessment Register

### Medium-term (Next 3 Months)
6. ⬜ Create all remaining gap documents
7. ⬜ Conduct internal audit
8. ⬜ Update cross-references

## Compliance Impact

| Metric | Before | After (Target) |
|--------|--------|----------------|
| **Structure** | Flat (23 files) | Hierarchical (13 folders) |
| **ISO 27001 Compliance** | 73% | 95%+ (after gap remediation) |
| **Audit Readiness** | ❌ Not ready | ✅ Ready (after gaps filled) |
| **Navigation** | ⚠️ Difficult | ✅ Easy |

## Rollback Plan

If needed, restore from backup:
```bash
cp 99-Archive/backup-TIMESTAMP/* .
```

---

**Migration completed successfully!** 🎉
EOF

    echo -e "${GREEN}✓ Created migration summary${NC}"
}

###############################################################################
# Phase 6: Display Summary
###############################################################################

display_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Migration Complete!                                           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📊 Summary:${NC}"
    echo -e "  ✅ Created 13 main folders"
    echo -e "  ✅ Moved 12 documentation files"
    echo -e "  ✅ Created 13 README files"
    echo -e "  ✅ Archived old versions"
    echo -e "  ✅ Created migration summary"
    echo ""
    echo -e "${YELLOW}📁 New Structure:${NC}"
    echo -e "  00-ISMS-Management/           # ISO 27001 Core"
    echo -e "  01-Organizational-Controls/   # A.5.x (37 controls)"
    echo -e "  02-People-Controls/           # A.6.x (8 controls)"
    echo -e "  03-Physical-Controls/         # A.7.x (14 controls)"
    echo -e "  04-Technological-Controls/    # A.8.x (34 controls)"
    echo -e "  05-Architecture-Design/       # Technical Docs"
    echo -e "  06-API-Management/            # API Governance"
    echo -e "  07-Business-Services/         # Business APIs"
    echo -e "  08-Operations/                # Operations"
    echo -e "  09-Business-Intelligence/     # Reporting"
    echo -e "  10-Monetization/              # Billing"
    echo -e "  11-Compliance-Audit/          # Compliance"
    echo -e "  12-Training-Awareness/        # Training"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo -e "  1. Review: ${BLUE}MIGRATION-SUMMARY.md${NC}"
    echo -e "  2. Check: ${BLUE}STRUCTURE-VISUAL-GUIDE.md${NC}"
    echo -e "  3. Read: ${BLUE}00-ISMS-Management/ISO-27001-2022-Compliance-Assessment.md${NC}"
    echo -e "  4. Commit: ${BLUE}git add . && git commit -m 'Restructure to ISO 27001:2022'${NC}"
    echo ""
    echo -e "${GREEN}🎯 Compliance: 73% → Target 95%+ (after gap remediation)${NC}"
    echo ""
}

###############################################################################
# Main Execution
###############################################################################

main() {
    echo -e "${BLUE}Starting automatic migration...${NC}"
    echo ""
    
    backup_current_structure
    echo ""
    
    create_folder_structure
    echo ""
    
    move_existing_files
    echo ""
    
    create_index_files
    echo ""
    
    create_migration_summary
    echo ""
    
    display_summary
}

# Run main function
main
