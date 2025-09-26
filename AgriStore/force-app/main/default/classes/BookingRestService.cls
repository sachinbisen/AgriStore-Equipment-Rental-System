/**
 * @description REST Web Service for AgriStore Booking API
 * @author Sachin Bisen
 * @date September 2025
 */
@RestResource(urlMapping='/api/v1/bookings/*')
global with sharing class BookingRestService {
    
    /**
     * GET: Retrieve booking information
     * URL: /services/apexrest/api/v1/bookings/BOOKING_ID
     * URL: /services/apexrest/api/v1/bookings/?status=Pending&limit=10
     */
    @HttpGet
    global static BookingResponse getBookings() {
        BookingResponse response = new BookingResponse();
        
        try {
            RestRequest req = RestContext.request;
            String bookingId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            
            // If specific booking ID is provided
            if (String.isNotBlank(bookingId) && bookingId != 'bookings') {
                response = getBookingById(bookingId);
            } else {
                // Get bookings with query parameters
                response = getBookingsList(req.params);
            }
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error retrieving bookings: ' + e.getMessage();
            response.errorCode = 'BOOKING_RETRIEVAL_ERROR';
        }
        
        return response;
    }
    
    /**
     * POST: Create new booking
     * URL: /services/apexrest/api/v1/bookings/
     * Body: BookingRequest JSON
     */
    @HttpPost
    global static BookingResponse createBooking(BookingRequest bookingData) {
        BookingResponse response = new BookingResponse();
        
        try {
            // Validate required fields
            if (String.isBlank(bookingData.equipmentId) || 
                String.isBlank(bookingData.farmerId) ||
                bookingData.startDate == null || 
                bookingData.endDate == null) {
                    
                response.success = false;
                response.message = 'Missing required fields: equipmentId, farmerId, startDate, endDate';
                response.errorCode = 'VALIDATION_ERROR';
                return response;
            }
            
            // Create booking record
            Booking__c newBooking = new Booking__c(
                Equipment__c = bookingData.equipmentId,
                Farmer__c = bookingData.farmerId,
                Start_Date__c = bookingData.startDate,
                End_Date__c = bookingData.endDate,
                Status__c = 'Pending'
            );
            
            insert newBooking;
            
            // Return created booking
            response = getBookingById(newBooking.Id);
            response.message = 'Booking created successfully';
            
        } catch (DmlException e) {
            response.success = false;
            response.message = 'Error creating booking: ' + e.getDmlMessage(0);
            response.errorCode = 'BOOKING_CREATION_ERROR';
        } catch (Exception e) {
            response.success = false;
            response.message = 'Unexpected error: ' + e.getMessage();
            response.errorCode = 'UNEXPECTED_ERROR';
        }
        
        return response;
    }
    
    /**
     * PUT: Update existing booking
     * URL: /services/apexrest/api/v1/bookings/BOOKING_ID
     * Body: BookingRequest JSON
     */
    @HttpPut
    global static BookingResponse updateBooking() {
        BookingResponse response = new BookingResponse();
        
        try {
            RestRequest req = RestContext.request;
            String bookingId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            
            if (String.isBlank(bookingId)) {
                response.success = false;
                response.message = 'Booking ID is required for update';
                response.errorCode = 'MISSING_BOOKING_ID';
                return response;
            }
            
            // Parse request body
            String requestBody = req.requestBody.toString();
            BookingRequest updateData = (BookingRequest) JSON.deserialize(requestBody, BookingRequest.class);
            
            // Get existing booking
            Booking__c existingBooking = [
                SELECT Id, Equipment__c, Farmer__c, Start_Date__c, End_Date__c, Status__c
                FROM Booking__c 
                WHERE Id = :bookingId 
                LIMIT 1
            ];
            
            // Update fields if provided
            if (String.isNotBlank(updateData.status)) {
                existingBooking.Status__c = updateData.status;
            }
            if (updateData.startDate != null) {
                existingBooking.Start_Date__c = updateData.startDate;
            }
            if (updateData.endDate != null) {
                existingBooking.End_Date__c = updateData.endDate;
            }
            
            update existingBooking;
            
            // Return updated booking
            response = getBookingById(bookingId);
            response.message = 'Booking updated successfully';
            
        } catch (QueryException e) {
            response.success = false;
            response.message = 'Booking not found';
            response.errorCode = 'BOOKING_NOT_FOUND';
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error updating booking: ' + e.getMessage();
            response.errorCode = 'BOOKING_UPDATE_ERROR';
        }
        
        return response;
    }
    
    /**
     * DELETE: Cancel/delete booking
     * URL: /services/apexrest/api/v1/bookings/BOOKING_ID
     */
    @HttpDelete
    global static BookingResponse deleteBooking() {
        BookingResponse response = new BookingResponse();
        
        try {
            RestRequest req = RestContext.request;
            String bookingId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            
            if (String.isBlank(bookingId)) {
                response.success = false;
                response.message = 'Booking ID is required for deletion';
                response.errorCode = 'MISSING_BOOKING_ID';
                return response;
            }
            
            // Update status to Cancelled instead of deleting
            Booking__c bookingToCancel = new Booking__c(
                Id = bookingId,
                Status__c = 'Cancelled'
            );
            
            update bookingToCancel;
            
            response.success = true;
            response.message = 'Booking cancelled successfully';
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error cancelling booking: ' + e.getMessage();
            response.errorCode = 'BOOKING_CANCELLATION_ERROR';
        }
        
        return response;
    }
    
    /**
     * Helper method to get booking by ID
     */
    private static BookingResponse getBookingById(String bookingId) {
        BookingResponse response = new BookingResponse();
        
        try {
            List<BookingData> bookingData = queryBookings('Id = \'' + bookingId + '\'', 1);
            
            if (!bookingData.isEmpty()) {
                response.success = true;
                response.data = bookingData[0];
                response.message = 'Booking retrieved successfully';
            } else {
                response.success = false;
                response.message = 'Booking not found';
                response.errorCode = 'BOOKING_NOT_FOUND';
            }
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error retrieving booking: ' + e.getMessage();
            response.errorCode = 'BOOKING_RETRIEVAL_ERROR';
        }
        
        return response;
    }
    
    /**
     * Helper method to get bookings list with filters
     */
    private static BookingResponse getBookingsList(Map<String, String> params) {
        BookingResponse response = new BookingResponse();
        
        try {
            String whereClause = '1=1';
            Integer limitCount = 50; // default limit
            
            // Build where clause from parameters
            if (params.containsKey('status')) {
                whereClause += ' AND Status__c = \'' + String.escapeSingleQuotes(params.get('status')) + '\'';
            }
            if (params.containsKey('farmerId')) {
                whereClause += ' AND Farmer__c = \'' + String.escapeSingleQuotes(params.get('farmerId')) + '\'';
            }
            if (params.containsKey('limit')) {
                limitCount = Integer.valueOf(params.get('limit'));
                limitCount = Math.min(limitCount, 200); // max 200
            }
            
            List<BookingData> bookings = queryBookings(whereClause, limitCount);
            
            response.success = true;
            response.dataList = bookings;
            response.message = 'Bookings retrieved successfully';
            response.totalCount = bookings.size();
            
        } catch (Exception e) {
            response.success = false;
            response.message = 'Error retrieving bookings: ' + e.getMessage();
            response.errorCode = 'BOOKINGS_RETRIEVAL_ERROR';
        }
        
        return response;
    }
    
    /**
     * Helper method to query bookings
     */
    private static List<BookingData> queryBookings(String whereClause, Integer limitCount) {
        String query = 'SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Amount__c, ' +
                      'Equipment__c, Equipment__r.Equipment_Name__c, Equipment__r.Equipment_Type__c, ' +
                      'Farmer__c, Farmer__r.Farmer_Name__c, Farmer__r.Email__c, ' +
                      'CreatedDate, LastModifiedDate ' +
                      'FROM Booking__c ' +
                      'WHERE ' + whereClause + ' ' +
                      'ORDER BY CreatedDate DESC ' +
                      'LIMIT ' + limitCount;
        
        List<Booking__c> bookings = Database.query(query);
        
        List<BookingData> bookingDataList = new List<BookingData>();
        for (Booking__c booking : bookings) {
            BookingData data = new BookingData();
            data.id = booking.Id;
            data.name = booking.Name;
            data.status = booking.Status__c;
            data.startDate = booking.Start_Date__c;
            data.endDate = booking.End_Date__c;
            data.totalAmount = booking.Total_Amount__c;
            data.equipmentId = booking.Equipment__c;
            data.equipmentName = booking.Equipment__r?.Equipment_Name__c;
            data.equipmentType = booking.Equipment__r?.Equipment_Type__c;
            data.farmerId = booking.Farmer__c;
            data.farmerName = booking.Farmer__r?.Farmer_Name__c;
            data.farmerEmail = booking.Farmer__r?.Email__c;
            data.createdDate = booking.CreatedDate;
            data.lastModifiedDate = booking.LastModifiedDate;
            
            bookingDataList.add(data);
        }
        
        return bookingDataList;
    }
    
    // Request/Response Classes
    global class BookingRequest {
        public String equipmentId;
        public String farmerId;
        public Date startDate;
        public Date endDate;
        public String status;
    }
    
    global class BookingResponse {
        public Boolean success = true;
        public String message;
        public String errorCode;
        public BookingData data;
        public List<BookingData> dataList;
        public Integer totalCount;
        public DateTime timestamp = DateTime.now();
    }
    
    global class BookingData {
        public String id;
        public String name;
        public String status;
        public Date startDate;
        public Date endDate;
        public Decimal totalAmount;
        public String equipmentId;
        public String equipmentName;
        public String equipmentType;
        public String farmerId;
        public String farmerName;
        public String farmerEmail;
        public DateTime createdDate;
        public DateTime lastModifiedDate;
    }
}