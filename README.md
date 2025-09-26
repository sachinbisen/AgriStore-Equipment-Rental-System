# AgriStore – Smart Equipment Rental & Inventory System

## 📌 Project Overview
AgriStore is a **Salesforce-powered agriculture equipment rental and inventory management system** designedFFFFFF to help farmers access machinery at affordable costs while enabling equipment owners to earn from underutilized assets.  

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
---

### ✅ **Phase 3: Data Modeling & Relationships - COMPLETED**

**Implementation Date:** September 15, 2025  
**Status:** Fully Deployed and Validated ✅

## 🏗️ **Phase 3: Data Modeling & Relationships**

### **Custom Fields Implementation**
Implemented comprehensive field structure across all objects:

#### **Farmer__c Fields:**
- `Farmer_Name__c` (Text, Required) - Primary farmer identification
- `Contact_Number__c` (Phone, Required) - Communication contact
- `Email__c` (Email, Unique) - Digital communication
- `Address__c` (Long Text Area) - Location information

#### **Equipment__c Fields:**
- `Equipment_Name__c` (Text, Required) - Equipment identification
- `Equipment_Type__c` (Picklist: Tractor, Harvester, Irrigation, Other)
- `Availability__c` (Checkbox, Default: True) - Real-time availability
- `Rental_Rate__c` (Currency, Required) - Daily rental pricing

#### **Booking__c Fields:**
- `Name` (Auto Number: BK-{0000}) - Unique booking identifier
- `Equipment__c` (Master-Detail to Equipment__c) - Equipment reference
- `Farmer__c` (Lookup to Farmer__c) - Farmer reference with restrict delete
- `Status__c` (Picklist: Pending, Confirmed, Cancelled, Completed)
- `Start_Date__c` (Date, Required) - Rental start date
- `End_Date__c` (Date, Required) - Rental end date
- `Total_Amount__c` (Currency) - Calculated total cost

#### **Payment__c Fields:**
- `Name` (Auto Number: PAY-{00000}) - Payment transaction ID
- `Booking__c` (Lookup to Booking__c) - Associated booking
- `Amount__c` (Currency, Required) - Payment amount
- `Status__c` (Picklist: Pending, Paid, Failed) - Payment status
- `Payment_Date__c` (Date) - Transaction date
- `Payment_Method__c` (Picklist: UPI, Credit Card, Debit Card, Net Banking, Cash)

#### **Feedback__c Fields:**
- `Booking__c` (Lookup to Booking__c) - Associated booking
- `Rating__c` (Number, 1-5, Required) - Customer satisfaction rating
- `Comments__c` (Long Text Area) - Detailed feedback

#### **Maintenance_Log__c Fields:**
- `Equipment__c` (Lookup to Equipment__c) - Equipment reference
- `Maintenance_Date__c` (Date, Required) - Service date
- `Status__c` (Picklist: Completed, Scheduled, Pending) - Maintenance status
- `Description__c` (Long Text Area) - Service details

### **Object Relationships Implemented:**

| Parent Object | Child Object | Relationship Type | Details |
|---------------|--------------|-------------------|----------|
| Equipment__c | Booking__c | Master-Detail | Equipment controls booking lifecycle |
| Farmer__c | Booking__c | Lookup (Restrict Delete) | Farmer can have multiple bookings |
| Booking__c | Payment__c | Lookup (Restrict Delete) | Bookings can have multiple payments |
| Booking__c | Feedback__c | Lookup (Restrict Delete) | Post-booking feedback collection |
| Equipment__c | Maintenance_Log__c | Lookup (Restrict Delete) | Equipment service history |

### **Record Types Configuration:**

#### **Equipment__c Record Types:**
1. **Heavy Equipment** - For tractors and harvesters
   - Picklist Values: Tractor (default), Harvester
2. **Light Equipment** - For small tools and equipment
   - Picklist Values: Other (default)
3. **Irrigation Equipment** - For irrigation systems
   - Picklist Values: Irrigation (default)

### **Compact Layouts for Mobile Experience:**
- **Farmer Compact Layout**: Farmer Name, Contact Number, Email
- **Equipment Compact Layout**: Equipment Name, Type, Availability, Rental Rate
- **Booking Compact Layout**: Booking ID, Status, Start Date, End Date

### **Junction Object for Future Scalability:**
**Booking_Equipment__c** - Enables many-to-many relationships
- `Name` (Auto Number: BE-{0000})
- `Booking__c` (Master-Detail to Booking__c)
- `Equipment__c` (Master-Detail to Equipment__c)
- Sharing Model: ControlledByParent

### **Data Schema Architecture:**

```
Farmer__c ──Lookup──► Booking__c ◄──Master-Detail── Equipment__c
                          │                           │
                     ┌────┴────┐                 ┌────┴────┐
                     │         │                 │         │
                  Lookup   Lookup             Lookup       │
                     │         │                 │         │
                     ▼         ▼                 ▼         │
               Payment__c  Feedback__c  Maintenance_Log__c  │
                                                           │
            Junction Object (Future): Booking_Equipment__c ─┘
```

### **Sharing Model Updates:**
- **Booking__c**: Changed from Private to ControlledByParent (due to Master-Detail relationship)
- **All Lookups**: Configured with Restrict Delete for data integrity
- **Junction Object**: ControlledByParent sharing model

### **Deployment Results:**
**Successfully deployed 41 components:**
- ✅ **32 Custom Fields** - Comprehensive field structure
- ✅ **7 Custom Objects** - Complete data model (6 core + 1 junction)
- ✅ **3 Record Types** - Equipment categorization
- ✅ **3 Compact Layouts** - Mobile-optimized views
- ✅ **5 Object Relationships** - Full data connectivity

### **Data Integrity Features:**
- Master-Detail cascading for Equipment → Booking
- Restrict Delete on all Lookup relationships
- Required field validation
- Unique constraints on Email fields
- Auto-numbering for tracking
- Picklist value restrictions

### **Business Process Enablement:**
1. **Equipment Management**: Complete equipment catalog with availability tracking
2. **Booking Workflow**: End-to-end booking lifecycle management
3. **Payment Processing**: Multi-method payment support
4. **Feedback System**: Customer satisfaction tracking
5. **Maintenance Tracking**: Equipment service history
6. **Scalability**: Junction object for future complex relationships

---

### ✅ **Phase 4: Process Automation (Admin) - COMPLETED**

**Implementation Date:** September 26, 2025  
**Status:** Fully Deployed and Validated ✅

## 🏗️ **Phase 4: Process Automation (Admin)**

### **Completed Implementations:**

#### **Task Automation Workflows**
- ✅ **Booking Task Automation** - Auto-create follow-up tasks when bookings are confirmed/cancelled
- ✅ **Equipment Maintenance Tasks** - Auto-create maintenance tasks when status = "Required"
- ✅ **Payment Failure Tasks** - Auto-create tasks for Finance team when payments fail

#### **Custom Notification Types**
- ✅ **Booking Status Change** - Notifications for farmers and managers
- ✅ **Equipment Availability Alert** - Notifications for equipment owners and managers  
- ✅ **Payment Failure Alert** - Notifications for finance team and higher management
- ✅ **Critical Maintenance Alert** - Notifications for inventory managers and equipment owners

#### **Flow Builder Implementations**
- ✅ **Booking_Task_Automation.flow** - Record-triggered flow for booking status changes
- ✅ **Equipment_Maintenance_Task_Automation.flow** - Auto-launch flow for maintenance requirements
- ✅ **Payment_Failure_Task_Automation.flow** - Record-triggered flow for payment failures
- ✅ **Booking_Status_Notification.flow** - Custom notification flow for status changes
- ✅ **Payment_Failure_Notification.flow** - Custom notification flow for payment issues

#### **Previous Phase 4 Items (Already Completed):**
- ✅ Validation Rules: Comprehensive data validation across all objects
- ✅ Workflow Rules: Equipment and Booking automation
- ✅ Email Templates & Alerts: Multi-scenario communication
- ✅ Process Builder → Flow Migration: All automations migrated to Flow Builder
- ✅ Approval Process: Booking approval workflow implemented

## 🚀 **Deployment Results**

**All Phase 4 components successfully implemented:**
- ✅ **7 Task Automation Flows** - Complete workflow automation
- ✅ **4 Custom Notification Types** - Multi-stakeholder communication
- ✅ **5 Notification Flows** - Real-time status updates
- ✅ **Integration with Existing Flows** - Seamless workflow continuation

---

### ✅ **Phase 5: Apex Programming (Developer) - COMPLETED**

**Implementation Date:** September 26, 2025  
**Status:** Fully Implemented with Advanced Features ✅

## 🏗️ **Phase 5: Apex Programming (Developer)**

### **Apex Fundamentals Implementation:**

#### **Classes & Objects (OOP Structure)**
- ✅ **EquipmentManager.cls** - Complete equipment management with encapsulation
  - Private variables, constructors (default + parameterized)
  - Getter/setter methods, business logic methods
  - Static methods for bulk operations
  - Custom exception handling
  - SOQL queries with selective filters

- ✅ **BookingManager.cls** - Comprehensive booking lifecycle management
  - Multiple constructors, validation methods
  - Date conflict checking, amount calculations
  - Status management with control statements
  - Static methods for farmer/equipment queries
  - Bulk update operations

- ✅ **PaymentManager.cls** - Advanced payment processing
  - Payment gateway simulation
  - Multiple payment method support
  - Refund processing capabilities
  - Statistical analysis methods
  - Exception handling throughout

#### **Control Statements & Collections**
- ✅ **if/else statements** - Comprehensive conditional logic
- ✅ **for/while loops** - Efficient data processing
- ✅ **switch statements** - Clean multi-condition handling
- ✅ **List, Set, Map collections** - Optimal data structure usage
- ✅ **Enhanced for loops** - Modern iteration patterns

### **Triggers & Design Patterns:**

#### **Trigger Implementation**
- ✅ **BookingTrigger.trigger** - Complete trigger for all DML operations
  - before insert, update, delete
  - after insert, update, delete, undelete
  - Proper event handling

#### **Trigger Handler Pattern**
- ✅ **TriggerHandler.cls** - Abstract base class
  - Recursion prevention
  - Handler bypass functionality
  - Virtual method structure

- ✅ **BookingTriggerHandler.cls** - Concrete implementation
  - 435+ lines of business logic
  - Comprehensive validation
  - Conflict detection algorithms
  - Equipment availability management
  - Payment record automation
  - Error handling throughout

#### **SOQL & SOSL Implementation**
- ✅ **Selective SOQL queries** - Governor limit optimized
- ✅ **Dynamic SOQL** - Flexible query construction
- ✅ **Aggregate queries** - Statistical calculations
- ✅ **Relationship queries** - Cross-object data retrieval
- ✅ **LIMIT clauses** - Performance optimization

### **Asynchronous Apex:**

#### **Batch Apex**
- ✅ **BookingReportBatch.cls** - Monthly report generation
  - Database.Batchable<sObject> implementation
  - Database.Stateful for data persistence
  - 288+ lines with comprehensive logic
  - Error handling and email notifications
  - Job chaining capabilities

#### **Queueable Apex**
- ✅ **PaymentProcessingQueueable.cls** - Advanced payment processing
  - Database.AllowsCallouts for gateway integration
  - Multiple processing types (pending, failed, refunds)
  - Job chaining for booking updates
  - Notification sending capabilities
  - 369+ lines of robust implementation

#### **Future Methods & Scheduled Apex**
- ✅ **Payment gateway callouts** - Asynchronous external integration
- ✅ **Notification services** - Non-blocking communication
- ✅ **Batch job scheduling** - Automated recurring processes

### **Exception Handling:**
- ✅ **Custom Exception Classes** - Domain-specific error handling
- ✅ **Try-catch blocks** - Graceful error recovery
- ✅ **DML Exception handling** - Database operation safety
- ✅ **Callout Exception handling** - External service reliability
- ✅ **Logging & debugging** - Comprehensive error tracking

## 🚀 **Phase 5 Deliverables**

**Successfully implemented comprehensive Apex solution:**
- ✅ **6 Apex Classes** - Complete business logic implementation
- ✅ **1 Apex Trigger** - Full DML event coverage
- ✅ **1 Trigger Handler** - Design pattern implementation
- ✅ **1 Batch Apex** - Large dataset processing
- ✅ **1 Queueable Apex** - Asynchronous job chaining
- ✅ **SOQL Optimization** - Governor limit compliant
- ✅ **Exception Handling** - Robust error management
- ✅ **Code Documentation** - Comprehensive JavaDoc style

### **Code Quality Metrics:**
- **Total Lines of Code:** 2000+ lines
- **Code Coverage Target:** 75%+ (Test classes pending)
- **Governor Limit Compliance:** ✅ All queries optimized
- **Design Patterns:** ✅ Trigger Handler, Factory, Strategy
- **Security:** ✅ with sharing keywords implemented
- **Performance:** ✅ Bulk operations, selective queries

### **Business Logic Implementation:**
1. ✅ **Equipment Availability Management** - Real-time status updates
2. ✅ **Booking Conflict Detection** - Advanced date overlap algorithms
3. ✅ **Payment Processing** - Multi-method gateway simulation
4. ✅ **Automated Task Creation** - Workflow-driven task management
5. ✅ **Notification Systems** - Multi-stakeholder communication
6. ✅ **Report Generation** - Automated monthly analytics
7. ✅ **Data Validation** - Comprehensive business rule enforcement

---

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
