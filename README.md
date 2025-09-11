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

### **Phase 1: Problem Understanding & Industry Analysis**
- Requirement Gathering: Equipment booking, rental, inventory, reporting  
- Stakeholders: Farmers, Owners, Managers, Government Officers  
- Industry Use Case: Agriculture Equipment Rental  

### **Phase 2: Org Setup & Configuration**
- Profiles: Farmer, Equipment Owner, Rental Manager, Inventory Manager, Higher Manager  
- Roles & Permission Sets for data access control  

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
