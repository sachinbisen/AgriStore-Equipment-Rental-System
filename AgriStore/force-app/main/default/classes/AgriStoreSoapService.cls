/**
 * @description SOAP Web Service for AgriStore Legacy Integration
 * @author Sachin Bisen
 * @date September 2025
 */
global class AgriStoreSoapService {
    
    webservice class EquipmentInfo {
        webservice String id;
        webservice String name;
        webservice String type;
        webservice Boolean available;
        webservice Decimal rentalRate;
    }
    
    webservice class BookingInfo {
        webservice String id;
        webservice String bookingNumber;
        webservice String status;
        webservice String startDate;
        webservice String endDate;
        webservice Decimal totalAmount;
        webservice String equipmentId;
        webservice String equipmentName;
        webservice String farmerId;
        webservice String farmerName;
    }
    
    webservice class ServiceResponse {
        webservice Boolean success;
        webservice String message;
        webservice String errorCode;
    }
    
    webservice class EquipmentResponse extends ServiceResponse {
        webservice List<EquipmentInfo> equipment;
    }
    
    webservice class BookingResponse extends ServiceResponse {
        webservice BookingInfo booking;
        webservice List<BookingInfo> bookings;
    }
    
    /**
     * Get available equipment
     * @param equipmentType Optional filter by equipment type
     * @return EquipmentResponse with available equipment list
     */
    webservice static EquipmentResponse getAvailableEquipment(String equipmentType) {
        EquipmentResponse response = new EquipmentResponse();
        
        try {
            String query = 'SELECT Id, Equipment_Name__c, Equipment_Type__c, Availability__c, Rental_Rate__c ' +
                          'FROM Equipment__c WHERE Availability__c = true';
            
            if (String.isNotBlank(equipmentType)) {
                query += ' AND Equipment_Type__c = :equipmentType';
            }
            
            query += ' ORDER BY Equipment_Name__c LIMIT 100';
            
            List<Equipment__c> equipmentList = Database.query(query);
            
            response.equipment = new List<EquipmentInfo>();
            for (Equipment__c eq : equipmentList) {
                EquipmentInfo info = new EquipmentInfo();
                info.id = eq.Id;
                info.name = eq.Equipment_Name__c;
                info.type = eq.Equipment_Type__c;
                info.available = eq.Availability__c;
                info.rentalRate = eq.Rental_Rate__c;
                response.equipment.add(info);
            }
            
            response.success = true;
            response.message = 'Equipment retrieved successfully';
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error retrieving equipment: ' + e.getMessage();
            response.errorCode = 'EQUIPMENT_RETRIEVAL_ERROR';
        }
        
        return response;
    }
    
    /**
     * Create new booking
     * @param equipmentId Equipment ID
     * @param farmerId Farmer ID
     * @param startDate Start date (YYYY-MM-DD format)
     * @param endDate End date (YYYY-MM-DD format)
     * @return BookingResponse with created booking details
     */
    webservice static BookingResponse createBooking(String equipmentId, String farmerId, String startDate, String endDate) {
        BookingResponse response = new BookingResponse();
        
        try {
            // Validate inputs
            if (String.isBlank(equipmentId) || String.isBlank(farmerId) || 
                String.isBlank(startDate) || String.isBlank(endDate)) {
                response.success = false;
                response.message = 'All parameters are required: equipmentId, farmerId, startDate, endDate';
                response.errorCode = 'MISSING_PARAMETERS';
                return response;
            }
            
            // Parse dates
            Date parsedStartDate = Date.valueOf(startDate);
            Date parsedEndDate = Date.valueOf(endDate);
            
            // Create booking
            Booking__c newBooking = new Booking__c(
                Equipment__c = equipmentId,
                Farmer__c = farmerId,
                Start_Date__c = parsedStartDate,
                End_Date__c = parsedEndDate,
                Status__c = 'Pending'
            );
            
            insert newBooking;
            
            // Return created booking info
            response.booking = getBookingInfo(newBooking.Id);
            response.success = true;
            response.message = 'Booking created successfully';
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error creating booking: ' + e.getMessage();
            response.errorCode = 'BOOKING_CREATION_ERROR';
        }
        
        return response;
    }
    
    /**
     * Update booking status
     * @param bookingId Booking ID
     * @param newStatus New status (Pending, Confirmed, Cancelled, Completed)
     * @return BookingResponse with updated booking details
     */
    webservice static BookingResponse updateBookingStatus(String bookingId, String newStatus) {
        BookingResponse response = new BookingResponse();
        
        try {
            if (String.isBlank(bookingId) || String.isBlank(newStatus)) {
                response.success = false;
                response.message = 'Booking ID and new status are required';
                response.errorCode = 'MISSING_PARAMETERS';
                return response;
            }
            
            // Validate status
            List<String> validStatuses = new List<String>{'Pending', 'Confirmed', 'Cancelled', 'Completed'};
            if (!validStatuses.contains(newStatus)) {
                response.success = false;
                response.message = 'Invalid status. Valid values: ' + String.join(validStatuses, ', ');
                response.errorCode = 'INVALID_STATUS';
                return response;
            }
            
            // Update booking
            Booking__c booking = new Booking__c(
                Id = bookingId,
                Status__c = newStatus
            );
            
            update booking;
            
            // Return updated booking info
            response.booking = getBookingInfo(bookingId);
            response.success = true;
            response.message = 'Booking status updated successfully';
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error updating booking: ' + e.getMessage();
            response.errorCode = 'BOOKING_UPDATE_ERROR';
        }
        
        return response;
    }
    
    /**
     * Get booking details
     * @param bookingId Booking ID
     * @return BookingResponse with booking details
     */
    webservice static BookingResponse getBookingDetails(String bookingId) {
        BookingResponse response = new BookingResponse();
        
        try {
            if (String.isBlank(bookingId)) {
                response.success = false;
                response.message = 'Booking ID is required';
                response.errorCode = 'MISSING_BOOKING_ID';
                return response;
            }
            
            response.booking = getBookingInfo(bookingId);
            response.success = true;
            response.message = 'Booking retrieved successfully';
            
        } catch (QueryException e) {
            response.success = false;
            response.message = 'Booking not found';
            response.errorCode = 'BOOKING_NOT_FOUND';
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error retrieving booking: ' + e.getMessage();
            response.errorCode = 'BOOKING_RETRIEVAL_ERROR';
        }
        
        return response;
    }
    
    /**
     * Get bookings by farmer
     * @param farmerId Farmer ID
     * @param status Optional status filter
     * @return BookingResponse with bookings list
     */
    webservice static BookingResponse getBookingsByFarmer(String farmerId, String status) {
        BookingResponse response = new BookingResponse();
        
        try {
            if (String.isBlank(farmerId)) {
                response.success = false;
                response.message = 'Farmer ID is required';
                response.errorCode = 'MISSING_FARMER_ID';
                return response;
            }
            
            String query = 'SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Amount__c, ' +
                          'Equipment__c, Equipment__r.Equipment_Name__c, ' +
                          'Farmer__c, Farmer__r.Farmer_Name__c ' +
                          'FROM Booking__c WHERE Farmer__c = :farmerId';
            
            if (String.isNotBlank(status)) {
                query += ' AND Status__c = :status';
            }
            
            query += ' ORDER BY CreatedDate DESC LIMIT 50';
            
            List<Booking__c> bookings = Database.query(query);
            
            response.bookings = new List<BookingInfo>();
            for (Booking__c booking : bookings) {
                BookingInfo info = new BookingInfo();
                info.id = booking.Id;
                info.bookingNumber = booking.Name;
                info.status = booking.Status__c;
                info.startDate = booking.Start_Date__c?.format();
                info.endDate = booking.End_Date__c?.format();
                info.totalAmount = booking.Total_Amount__c;
                info.equipmentId = booking.Equipment__c;
                info.equipmentName = booking.Equipment__r?.Equipment_Name__c;
                info.farmerId = booking.Farmer__c;
                info.farmerName = booking.Farmer__r?.Farmer_Name__c;
                response.bookings.add(info);
            }
            
            response.success = true;
            response.message = 'Bookings retrieved successfully';
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error retrieving bookings: ' + e.getMessage();
            response.errorCode = 'BOOKINGS_RETRIEVAL_ERROR';
        }
        
        return response;
    }
    
    /**
     * Helper method to get booking info
     */
    private static BookingInfo getBookingInfo(String bookingId) {
        Booking__c booking = [
            SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Amount__c,
                   Equipment__c, Equipment__r.Equipment_Name__c,
                   Farmer__c, Farmer__r.Farmer_Name__c
            FROM Booking__c
            WHERE Id = :bookingId
        ];
        
        BookingInfo info = new BookingInfo();
        info.id = booking.Id;
        info.bookingNumber = booking.Name;
        info.status = booking.Status__c;
        info.startDate = booking.Start_Date__c?.format();
        info.endDate = booking.End_Date__c?.format();
        info.totalAmount = booking.Total_Amount__c;
        info.equipmentId = booking.Equipment__c;
        info.equipmentName = booking.Equipment__r?.Equipment_Name__c;
        info.farmerId = booking.Farmer__c;
        info.farmerName = booking.Farmer__r?.Farmer_Name__c;
        
        return info;
    }
}