# AgriStore Data Model Schema

## Entity Relationship Diagram

```
┌─────────────────┐    ┌──────────────────────────────┐    ┌──────────────────┐
│   Farmer__c     │    │        Booking__c            │    │   Equipment__c   │
│                 │    │                              │    │                  │
│ • Name          │◄──┤• Name (BK-0001)              │──────►• Name            │
│ • Farmer_Name__c│    │• Equipment__c (Master-Detail)│    │ • Equipment_Name_c│
│ • Contact_Number│    │• Farmer__c (Lookup)         │    │ • Equipment_Type__c│
│ • Email__c      │    │• Status__c                  │    │ • Availability__c│
│ • Address__c    │    │• Start_Date__c              │    │ • Rental_Rate__c │
│                 │    │• End_Date__c                │    │                  │
└─────────────────┘    │• Total_Amount__c            │    └──────────────────┘
                       └──────────────┬───────────────┘
                                     │
                    ┌────────────────┴───────────────┐
                    │                               │
            ┌───────▼──────────┐        ┌──────────▼─────────┐
            │   Payment__c     │        │   Feedback__c      │
            │                  │        │                    │
            │ • Name (PAY-0001)│        │ • Name             │
            │ • Booking__c     │        │ • Booking__c       │
            │ • Amount__c      │        │ • Rating__c (1-5)  │
            │ • Status__c      │        │ • Comments__c      │
            │ • Payment_Date__c│        │                    │
            │ • Payment_Method_c│       │                    │
            └──────────────────┘        └────────────────────┘

                                    ┌─────────────────────────┐
                                    │  Maintenance_Log__c     │
                                    │                         │
                                    │ • Name                  │
                                    │ • Equipment__c (Lookup)│◄───┐
                                    │ • Maintenance_Date__c   │    │
                                    │ • Status__c             │    │
                                    │ • Description__c        │    │
                                    └─────────────────────────┘    │
                                                                   │
                                                         ┌─────────┘
                                                         │
                                                    Equipment__c

┌──────────────────────────────┐
│ Booking_Equipment__c         │  (Junction Object - Future Use)
│                              │
│ • Name (BE-0001)             │
│ • Booking__c (Master-Detail) │◄────┐
│ • Equipment__c (Master-Detail)│◄───┐│
└──────────────────────────────┘    ││
                                    ││
                            ┌───────┘│
                            │        │
                       Booking__c  Equipment__c

┌────────────────────────────────────┐
│ External_Payment_Transaction__x    │  (External Object)
│                                    │
│ • Transaction_ID__c (External ID)  │
│ • External_Payment_ID__c           │
│ • Amount__c                        │
│ • Gateway_Name__c                  │
└────────────────────────────────────┘
```

## Object Details

### Core Objects

#### 1. Farmer__c
- **Purpose**: Store farmer profile information
- **Key Fields**:
  - `Farmer_Name__c` (Text, Required)
  - `Contact_Number__c` (Phone, Required)  
  - `Email__c` (Email, Unique)
  - `Address__c` (Long Text Area)

#### 2. Equipment__c  
- **Purpose**: Agricultural equipment catalog
- **Key Fields**:
  - `Equipment_Name__c` (Text, Required)
  - `Equipment_Type__c` (Picklist: Tractor, Harvester, Irrigation, Other)
  - `Availability__c` (Checkbox, Default: True)
  - `Rental_Rate__c` (Currency, Required)
- **Record Types**: Heavy Equipment, Light Equipment, Irrigation Equipment

#### 3. Booking__c
- **Purpose**: Equipment rental bookings
- **Key Fields**:
  - `Name` (Auto Number: BK-{0000})
  - `Equipment__c` (Master-Detail to Equipment__c)
  - `Farmer__c` (Lookup to Farmer__c)
  - `Status__c` (Picklist: Pending, Confirmed, Cancelled, Completed)
  - `Start_Date__c` (Date, Required)
  - `End_Date__c` (Date, Required)
  - `Total_Amount__c` (Currency)

#### 4. Payment__c
- **Purpose**: Payment transaction records
- **Key Fields**:
  - `Name` (Auto Number: PAY-{00000})
  - `Booking__c` (Lookup to Booking__c)
  - `Amount__c` (Currency, Required)
  - `Status__c` (Picklist: Pending, Paid, Failed)
  - `Payment_Date__c` (Date)
  - `Payment_Method__c` (Picklist: UPI, Credit Card, Debit Card, Net Banking, Cash)

#### 5. Feedback__c
- **Purpose**: Customer feedback and ratings
- **Key Fields**:
  - `Booking__c` (Lookup to Booking__c)
  - `Rating__c` (Number, 1-5, Required)
  - `Comments__c` (Long Text Area)

#### 6. Maintenance_Log__c
- **Purpose**: Equipment maintenance tracking
- **Key Fields**:
  - `Equipment__c` (Lookup to Equipment__c)
  - `Maintenance_Date__c` (Date, Required)
  - `Status__c` (Picklist: Completed, Scheduled, Pending)
  - `Description__c` (Long Text Area)

### Junction Object

#### 7. Booking_Equipment__c
- **Purpose**: Future many-to-many relationship support
- **Key Fields**:
  - `Name` (Auto Number: BE-{0000})
  - `Booking__c` (Master-Detail to Booking__c)
  - `Equipment__c` (Master-Detail to Equipment__c)

### External Object

#### 8. External_Payment_Transaction__x
- **Purpose**: Payment gateway integration
- **Key Fields**:
  - `Transaction_ID__c` (Text, External ID, Name Field)
  - `External_Payment_ID__c` (Text)
  - `Amount__c` (Currency)
  - `Gateway_Name__c` (Text)

## Relationships Summary

| Relationship Type | Parent Object | Child Object | Details |
|------------------|---------------|--------------|---------|
| Master-Detail | Equipment__c | Booking__c | Equipment controls booking access |
| Lookup | Farmer__c | Booking__c | Farmers can have multiple bookings |
| Lookup | Booking__c | Payment__c | Bookings can have multiple payments |
| Lookup | Booking__c | Feedback__c | Each booking can have feedback |
| Lookup | Equipment__c | Maintenance_Log__c | Equipment maintenance history |
| Master-Detail | Booking__c | Booking_Equipment__c | Junction relationship |
| Master-Detail | Equipment__c | Booking_Equipment__c | Junction relationship |

## Record Types

### Equipment__c Record Types
1. **Heavy Equipment**: For tractors and harvesters
2. **Light Equipment**: For small tools and equipment  
3. **Irrigation Equipment**: For irrigation systems

## Sharing Model
- **All Custom Objects**: Private OWD
- **Junction Object**: ControlledByParent
- **External Object**: ReadWrite access

## Key Business Rules
1. A booking must have both equipment and farmer
2. Equipment availability updates based on booking status
3. Payments are linked to specific bookings
4. Feedback is collected post-booking completion
5. Maintenance logs track equipment service history

## Future Enhancements
- Junction object enables many-to-many bookings
- External object supports real-time payment gateway integration
- Record types allow specialized business processes
- Compact layouts optimize mobile experience