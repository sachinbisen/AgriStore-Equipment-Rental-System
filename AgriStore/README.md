# AgriStore – Smart Equipment Rental & Inventory System

**A comprehensive Salesforce solution for managing agricultural equipment rentals, inventory, bookings, payments, and feedback.**

## 📋 Project Overview

AgriStore is a Salesforce-based platform that connects farmers with equipment owners, enabling efficient rental management, inventory tracking, and maintenance scheduling. The system provides role-based access control for different user types including farmers, equipment owners, rental managers, inventory managers, and government officers.

## 🎯 Project Status

### ✅ **Phase 2: Org Setup & Configuration - COMPLETED**

**Implementation Date:** September 14, 2025  
**Status:** Fully Deployed and Validated ✅

## 🏗️ **Phase 2: Org Setup & Configuration**

### **Salesforce Edition & Environment**
- **Edition:** Salesforce Developer Edition
- **Org Type:** Developer Org with source tracking
- **API Version:** v64.0
- **Target Org:** sachinbisen664571@agentforce.com

### **Company Profile Setup**
- **Organization Name:** AgriStore
- **Default Locale:** English (US)
- **Time Zone:** Configured for agricultural operations
- **Currency:** Multi-currency ready for regional markets

### **Custom Objects & Data Model**
All objects configured with **Private OWD** for security:

| Object | Purpose | Sharing Model |
|--------|---------|---------------|
| `Equipment__c` | Agricultural equipment listings | Private |
| `Booking__c` | Equipment rental bookings | Private |
| `Payment__c` | Payment transaction records | Private |
| `Feedback__c` | Customer feedback and ratings | Private |
| `Maintenance_Log__c` | Equipment maintenance tracking | Private |
| `Farmer__c` | Farmer profile information | Private |

### **User Setup & Licenses**
- **License Type:** Salesforce (full user licenses)
- **User Capacity:** Scalable for enterprise deployment
- **Authentication:** Standard Salesforce authentication
- **Password Policies:** Enterprise security standards

### **Profiles Implementation**
Five specialized profiles with tailored permissions:

#### 🌾 **AgriStore Farmer**
- Browse and search equipment catalog
- Create and manage rental bookings
- View own payment history
- Submit feedback and ratings
- **Objects:** Read Equipment__c, CRUD Booking__c, Read Payment__c, Create Feedback__c

#### 🚜 **AgriStore Equipment Owner**
- List and manage equipment inventory
- Update equipment availability and pricing
- Track booking requests and earnings
- **Objects:** CRUD Equipment__c, Read Booking__c, Read Payment__c

#### 👨‍💼 **AgriStore Rental Manager**
- Approve/reject booking requests
- Resolve conflicts and disputes
- Monitor all equipment and bookings
- **Objects:** Read Equipment__c, Edit Booking__c, Read Payment__c

#### 🔧 **AgriStore Inventory Manager**
- Maintain equipment health records
- Schedule maintenance activities
- Forecast equipment demand
- **Objects:** Read Equipment__c/Booking__c, CRUD Maintenance_Log__c

#### 🏛️ **AgriStore Higher Manager**
- Full system access for oversight
- Generate reports and analytics
- Government officer capabilities
- **Objects:** Full access to all objects

### **Roles & Hierarchy**
Implemented role hierarchy for data access:

```
AgriStore Higher Manager (Top Level)
├── AgriStore Rental Manager
│   └── AgriStore Equipment Owner
│       └── AgriStore Farmer
└── AgriStore Inventory Manager
    └── Equipment Owner (for maintenance visibility)
```

### **Permission Sets**
Additional granular access control:
- **AgriStore Equipment Management** - Enhanced equipment operations
- **AgriStore Booking Management** - Advanced booking workflows

### **Org-Wide Defaults (OWD)**
Secure by default configuration:
- **All Custom Objects:** Private
- **Standard Objects:** Salesforce defaults
- **External Sharing:** Disabled
- **Secure Guest User Access:** Enabled

### **Sharing Rules**
Role-based sharing for collaboration:

#### Equipment Sharing:
- ✅ Rental Managers → Read access to all equipment
- ✅ Higher Managers → Edit access to all equipment

#### Booking Sharing:
- ✅ Equipment Owners → Read access to related bookings
- ✅ Rental Managers → Edit access to all bookings
- ✅ Higher Managers → Full access to all bookings

#### Maintenance Log Sharing:
- ✅ Inventory Managers → Edit access to all maintenance logs
- ✅ Rental Managers → Read access to maintenance status
- ✅ Higher Managers → Full access to maintenance records

### **Login Access Policies**
- **Login Hours:** 24/7 access for agricultural operations
- **IP Restrictions:** Configurable by profile
- **Session Security:** Standard timeout policies
- **Two-Factor Authentication:** Ready for implementation

### **Development Environment**
- **Dev Org:** Configured with source tracking
- **Version Control:** Git integration enabled
- **CI/CD Ready:** Metadata deployment optimized
- **Scratch Orgs:** Available for feature development

### **Deployment & Sandbox**
- **Metadata API:** v64.0 compatibility
- **Deployment Scripts:** Automated validation included
- **Sandbox Strategy:** Ready for UAT and production
- **Change Sets:** Alternative deployment method available

## 🚀 **Deployment Results**

**All metadata successfully deployed:**
- ✅ **6 Custom Objects** - Equipment, Booking, Payment, Feedback, Maintenance Log, Farmer
- ✅ **5 User Roles** - Complete hierarchy implemented
- ✅ **5 User Profiles** - Tailored permissions for each user type
- ✅ **2 Permission Sets** - Additional granular access control
- ✅ **8 Sharing Rules** - Role-based record access

## 🔧 **Validation & Testing**

### Automated Validation
```bash
# Run validation script
./scripts/validate-phase2-deployment.sh
```

### Manual Verification
- ✅ All profiles accessible in Setup → Profiles
- ✅ Role hierarchy visible in Setup → Roles
- ✅ Permission sets available for assignment
- ✅ Sharing rules active and functional
- ✅ Custom objects queryable and accessible

## 📁 **Project Structure**

```
force-app/main/default/
├── objects/                    # Custom Objects
│   ├── Equipment__c/
│   ├── Booking__c/
│   ├── Payment__c/
│   ├── Feedback__c/
│   ├── Maintenance_Log__c/
│   └── Farmer__c/
├── profiles/                   # User Profiles
│   ├── AgriStore Farmer.profile-meta.xml
│   ├── AgriStore Equipment Owner.profile-meta.xml
│   ├── AgriStore Rental Manager.profile-meta.xml
│   ├── AgriStore Inventory Manager.profile-meta.xml
│   └── AgriStore Higher Manager.profile-meta.xml
├── roles/                      # User Roles
│   ├── AgriStore_Farmer.role-meta.xml
│   ├── AgriStore_Equipment_Owner.role-meta.xml
│   ├── AgriStore_Rental_Manager.role-meta.xml
│   ├── AgriStore_Inventory_Manager.role-meta.xml
│   └── AgriStore_Higher_Manager.role-meta.xml
├── permissionsets/             # Permission Sets
│   ├── AgriStore_Equipment_Management.permissionset-meta.xml
│   └── AgriStore_Booking_Management.permissionset-meta.xml
└── sharingRules/               # Sharing Rules
    ├── Equipment__c.sharingRules-meta.xml
    ├── Booking__c.sharingRules-meta.xml
    └── Maintenance_Log__c.sharingRules-meta.xml
```

## 📝 **Next Steps - Phase 3: UI/UX Development**

1. **User Assignment**
   - Create test users for each profile
   - Assign appropriate roles and permission sets
   - Validate access permissions

2. **Data Model Enhancement**
   - Add custom fields to objects
   - Create validation rules
   - Implement workflow automation

3. **User Interface Development**
   - Lightning App Builder
   - Custom Lightning Components
   - Mobile-responsive design

## 🛠️ **Development Commands**

```bash
# Deploy all metadata
sf project deploy start --target-org AgriStore

# Deploy specific components
sf project deploy start --source-dir force-app/main/default/profiles --target-org AgriStore

# Validate deployment
./scripts/validate-phase2-deployment.sh

# Open org
sf org open --target-org AgriStore
```

## 📚 **Documentation**

- [Phase 2 Implementation Summary](./PHASE-2-IMPLEMENTATION-SUMMARY.md)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

---

**Project:** AgriStore Smart Equipment Rental & Inventory System  
**Phase 2 Status:** ✅ COMPLETED  
**Last Updated:** September 14, 2025
