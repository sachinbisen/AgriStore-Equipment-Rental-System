# AgriStore – Smart Equipment Rental & Inventory System

## 📌 Project Overview
AgriStore is a **Salesforce-powered agriculture equipment rental and inventory management system** designed to help farmers access machinery at affordable costs while enabling equipment owners to earn from underutilized assets.  

The system streamlines equipment bookings, payments, and inventory monitoring while providing dashboards for managers to track usage, demand, and revenue.  

---

## 🚀 Features

### 👨‍🌾 Farmer Module
- Browse available equipment (Tractor, Harvester, Irrigation tools, etc.)  
- View rental rates, location, and availability calendar  
- Book equipment for specific dates  
- Make payments digitally  
- Provide ratings and feedback after use  

### 🛠️ Equipment Owner Module
- Add/list equipment with rental rates and details  
- Update availability and booking status  
- Track earnings from rentals  

### 🏢 Rental Manager Module
- Approve/reject farmer bookings (if required)  
- Track ongoing and upcoming rentals  
- Resolve conflicts or scheduling overlaps  

### 📦 Inventory Manager Module
- Maintain equipment health and maintenance logs  
- Forecast demand during peak agricultural seasons  
- Get alerts for servicing and repairs  

### 📊 Higher Manager / Government Officer
- Region-wise equipment demand and usage analytics  
- Reports on farmer adoption of rentals  
- Subsidy usage and support analysis  

---

## 🛠️ Salesforce Mapping (Phases)

# Phase 1: Problem Understanding & Industry Analysis  

## 📌 Requirement Gathering  
The goal of **AgriStore** is to provide a Salesforce-powered platform that digitizes agricultural equipment rentals.  

**Key requirements include:**  
- **Equipment Booking:** Farmers can browse, check availability, and book machinery.  
- **Rental Management:** Owners can list equipment, set rates, and track income.  
- **Inventory Management:** Managers can log maintenance and forecast demand.  
- **Reporting & Dashboards:** Insights into demand, revenue, and usage trends.  
- **Communication & Notifications:** SMS/Email confirmations, reminders, and feedback collection.  

---

## 👥 Stakeholder Analysis  
- **Farmers (End Users):** Book equipment, make payments, and provide feedback.  
- **Equipment Owners:** List equipment, manage availability, and track earnings.  
- **Rental/Inventory Managers:** Monitor bookings, update maintenance logs, and resolve conflicts.  
- **Government Officers / Higher Managers:** Analyze region-wise adoption, utilization, and support agricultural schemes.  

---

## 🔄 Business Process Mapping  
1. Farmer searches for available equipment.  
2. Booking request created → system checks availability.  
3. Owner approves booking (if required).  
4. System auto-updates equipment status to *Not Available*.  
5. Farmer makes payment → booking confirmed.  
6. Equipment is used → usage recorded.  
7. After return, status resets to *Available*.  
8. Maintenance logs updated if needed.  
9. Feedback survey collected.  
10. Reports & dashboards generated for stakeholders.  

---

## 🌾 Industry-Specific Use Case Analysis  
- **Challenges:** High equipment costs, underutilization of machinery, disputes in rentals, lack of centralized data.  
- **AgriStore Solution:**  
  - Centralized Salesforce platform for all rentals.  
  - Transparency in booking, pricing, and payments.  
  - Better utilization for owners and affordable access for farmers.  
  - Data-driven insights for managers and government policy-makers.  
- **Benefits:**  
  - Farmers: Cost-effective farming.  
  - Owners: Additional income.  
  - Managers: Efficient operations.  
  - Government: Real-time analytics for planning.  

---

## 🛒 AppExchange Exploration  
Relevant Salesforce AppExchange apps that inspire AgriStore:  
- **Field Service Lightning** – for scheduling and dispatch management.  
- **Conga Composer** – to generate invoices and agreements.  
- **SMS Magic / Twilio** – for SMS/WhatsApp notifications.  
- **Stripe/FinancialForce Integration** – for secure online payments.  

These apps show how Salesforce can handle rentals, scheduling, communication, and payments — which AgriStore adapts for agriculture.  

---

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

### **Phase 3: Data Modeling & Relationships**
- Objects: Farmer, Equipment, Booking, Payment, Feedback, Maintenance Log  
- Relationships:  
  - Equipment ↔ Booking (Master-Detail)  
  - Booking ↔ Payment (Lookup)  

### **Phase 4: Process Automation**
- Validation Rules: Prevent double booking for same time slot  
- Flows: Auto-update availability after booking  
- Approval Process: For high-value rentals  

### **Phase 5: Apex Programming**
- Triggers: Auto-calculate rental charges  
- Batch Apex: Generate monthly income and demand reports  
- Queueable Apex: Bulk SMS notifications for bookings  

### **Phase 6: User Interface Development**
- LWC Components:  
  - Farmer Dashboard (Search & Book)  
  - Owner Dashboard (Earnings & Listings)  
  - Manager Dashboard (Bookings & Conflicts)  
  - Inventory Dashboard (Maintenance Logs)  

### **Phase 7: Integration & External Access**
- Payment Gateway Integration (UPI/PayPal/Stripe)  
- SMS/WhatsApp Alerts for booking confirmations  

### **Phase 8: Data Management & Deployment**
- Data Loader for bulk equipment data upload  
- Change Sets for deployment  
- Backup & Export of booking/payment history  

### **Phase 9: Reporting & Dashboards**
- Reports:  
  - Most rented equipment types  
  - Seasonal booking peaks  
  - Farmer adoption rate  
- Dashboards: Revenue trends, inventory utilization, regional insights  

### **Phase 10: Final Presentation & Demo Day**
- Live demo: Farmer books equipment → Owner confirms → Payment processed → Manager dashboard updated  
- Pitch presentation with problem, solution, benefits  
- Documentation & Portfolio showcase  

---

## ⚙️ Tech Stack
- Salesforce CRM (Admin + Developer)  
- Apex (Triggers, Batch Apex)  
- Lightning Web Components (LWC)  
- SOQL & SOSL  
- REST API (for payments and notifications)  
- GitHub (Version Control)  

---

## 📊 Benefits
- Affordable access to equipment for farmers  
- Extra revenue stream for equipment owners  
- Transparency and accountability in rentals  
- Insights for managers and policymakers  

---

## 📜 License
This project is licensed under the **MIT License** – free to use and modify.  

---

## 👨‍💻 Author
- **Sachin Bisen**  
- Final Year Computer Engineering Student  
- GitHub: [sachinbisen](https://github.com/sachinbisen)
- LinkedIn: [sachinbisen](www.linkedin.com/in/sachin-bisen)
- LeetCode: [sachinbisen](https://leetcode.com/u/SACHIN_BISEN/)
- CodeChef: [sachinbisen](https://www.codechef.com/users/sachinbisen664)
