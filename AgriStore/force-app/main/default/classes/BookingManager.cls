/**
 * @description Booking Management Class for AgriStore
 * @author Sachin Bisen
 * @date September 2025
 */
public with sharing class BookingManager {
    
    // Private variables for encapsulation
    private String bookingId;
    private String equipmentId;
    private String farmerId;
    private String status;
    private Date startDate;
    private Date endDate;
    private Decimal totalAmount;
    
    // Static constants for booking statuses
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_CONFIRMED = 'Confirmed';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String STATUS_COMPLETED = 'Completed';
    
    // Static final list of valid statuses
    private static final List<String> VALID_STATUSES = new List<String>{
        STATUS_PENDING, STATUS_CONFIRMED, STATUS_CANCELLED, STATUS_COMPLETED
    };
    
    /**
     * Default Constructor
     */
    public BookingManager() {
        this.status = STATUS_PENDING;
        this.totalAmount = 0.0;
    }
    
    /**
     * Parameterized Constructor
     * @param equipmentId ID of the equipment to book
     * @param farmerId ID of the farmer making the booking
     * @param startDate Start date of the booking
     * @param endDate End date of the booking
     */
    public BookingManager(String equipmentId, String farmerId, Date startDate, Date endDate) {
        this.equipmentId = equipmentId;
        this.farmerId = farmerId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = STATUS_PENDING;
        this.totalAmount = 0.0;
    }
    
    /**
     * Constructor with Booking record
     * @param booking Booking__c record
     */
    public BookingManager(Booking__c booking) {
        if (booking != null) {
            this.bookingId = booking.Id;
            this.equipmentId = booking.Equipment__c;
            this.farmerId = booking.Farmer__c;
            this.status = booking.Status__c;
            this.startDate = booking.Start_Date__c;
            this.endDate = booking.End_Date__c;
            this.totalAmount = booking.Total_Amount__c;
        }
    }
    
    // Getter and Setter methods
    public String getBookingId() {
        return this.bookingId;
    }
    
    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }
    
    public String getEquipmentId() {
        return this.equipmentId;
    }
    
    public void setEquipmentId(String equipmentId) {
        this.equipmentId = equipmentId;
    }
    
    public String getFarmerId() {
        return this.farmerId;
    }
    
    public void setFarmerId(String farmerId) {
        this.farmerId = farmerId;
    }
    
    public String getStatus() {
        return this.status;
    }
    
    public void setStatus(String status) {
        if (VALID_STATUSES.contains(status)) {
            this.status = status;
        } else {
            throw new BookingException('Invalid status: ' + status);
        }
    }
    
    public Date getStartDate() {
        return this.startDate;
    }
    
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }
    
    public Date getEndDate() {
        return this.endDate;
    }
    
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
    
    public Decimal getTotalAmount() {
        return this.totalAmount;
    }
    
    public void setTotalAmount(Decimal totalAmount) {
        this.totalAmount = totalAmount;
    }
    
    /**
     * Method to calculate booking duration in days
     * @return Integer number of days
     */
    public Integer calculateBookingDuration() {
        if (this.startDate == null || this.endDate == null) {
            return 0;
        }
        return this.startDate.daysBetween(this.endDate) + 1;
    }
    
    /**
     * Method to check if booking dates are valid
     * @return Boolean indicating if dates are valid
     */
    public Boolean areDatesValid() {
        if (this.startDate == null || this.endDate == null) {
            return false;
        }
        
        if (this.startDate < Date.today()) {
            return false; // Cannot book for past dates
        }
        
        if (this.startDate > this.endDate) {
            return false; // Start date cannot be after end date
        }
        
        return true;
    }
    
    /**
     * Method to calculate total booking amount
     * @param dailyRate Daily rental rate of the equipment
     * @return Decimal total amount
     */
    public Decimal calculateTotalAmount(Decimal dailyRate) {
        if (dailyRate == null || dailyRate <= 0) {
            throw new BookingException('Daily rate must be a positive number');
        }
        
        Integer duration = calculateBookingDuration();
        this.totalAmount = dailyRate * duration;
        return this.totalAmount;
    }
    
    /**
     * Method to confirm booking
     */
    public void confirmBooking() {
        if (!areDatesValid()) {
            throw new BookingException('Invalid booking dates');
        }
        
        if (this.status != STATUS_PENDING) {
            throw new BookingException('Only pending bookings can be confirmed');
        }
        
        this.status = STATUS_CONFIRMED;
        
        // Update database if booking ID exists
        updateBookingStatus();
        
        // Update equipment availability
        updateEquipmentAvailability(false);
    }
    
    /**
     * Method to cancel booking
     * @param reason Reason for cancellation
     */
    public void cancelBooking(String reason) {
        if (this.status == STATUS_COMPLETED) {
            throw new BookingException('Cannot cancel completed bookings');
        }
        
        this.status = STATUS_CANCELLED;
        
        // Update database if booking ID exists
        updateBookingStatus();
        
        // Make equipment available again if it was confirmed
        updateEquipmentAvailability(true);
    }
    
    /**
     * Method to complete booking
     */
    public void completeBooking() {
        if (this.status != STATUS_CONFIRMED) {
            throw new BookingException('Only confirmed bookings can be completed');
        }
        
        if (Date.today() < this.endDate) {
            throw new BookingException('Cannot complete booking before end date');
        }
        
        this.status = STATUS_COMPLETED;
        updateBookingStatus();
        
        // Make equipment available again
        updateEquipmentAvailability(true);
    }
    
    /**
     * Private method to update booking status in database
     */
    private void updateBookingStatus() {
        if (String.isNotBlank(this.bookingId)) {
            try {
                Booking__c bookingRecord = new Booking__c(
                    Id = this.bookingId,
                    Status__c = this.status,
                    Total_Amount__c = this.totalAmount
                );
                update bookingRecord;
            } catch (DmlException e) {
                System.debug('Error updating booking status: ' + e.getMessage());
                throw new BookingException('Failed to update booking status: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Private method to update equipment availability
     * @param isAvailable New availability status
     */
    private void updateEquipmentAvailability(Boolean isAvailable) {
        if (String.isNotBlank(this.equipmentId)) {
            try {
                Equipment__c equipmentRecord = new Equipment__c(
                    Id = this.equipmentId,
                    Availability__c = isAvailable
                );
                update equipmentRecord;
            } catch (DmlException e) {
                System.debug('Error updating equipment availability: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Static method to check for booking conflicts
     * @param equipmentId Equipment ID to check
     * @param startDate Start date of new booking
     * @param endDate End date of new booking
     * @param excludeBookingId Booking ID to exclude from check (for updates)
     * @return Boolean indicating if there are conflicts
     */
    public static Boolean hasBookingConflict(String equipmentId, Date startDate, Date endDate, String excludeBookingId) {
        if (String.isBlank(equipmentId) || startDate == null || endDate == null) {
            return false;
        }
        
        String query = 'SELECT Id FROM Booking__c WHERE Equipment__c = :equipmentId ' +
                      'AND Status__c IN (\'' + STATUS_PENDING + '\', \'' + STATUS_CONFIRMED + '\') ' +
                      'AND ((Start_Date__c <= :startDate AND End_Date__c >= :startDate) ' +
                      'OR (Start_Date__c <= :endDate AND End_Date__c >= :endDate) ' +
                      'OR (Start_Date__c >= :startDate AND End_Date__c <= :endDate))';
        
        if (String.isNotBlank(excludeBookingId)) {
            query += ' AND Id != :excludeBookingId';
        }
        
        query += ' LIMIT 1';
        
        try {
            List<Booking__c> conflictingBookings = Database.query(query);
            return !conflictingBookings.isEmpty();
        } catch (QueryException e) {
            System.debug('Error checking booking conflicts: ' + e.getMessage());
            return true; // Return true to be safe in case of query error
        }
    }
    
    /**
     * Static method to get bookings by farmer
     * @param farmerId Farmer ID
     * @param status Optional status filter
     * @return List of Booking__c records
     */
    public static List<Booking__c> getBookingsByFarmer(String farmerId, String status) {
        if (String.isBlank(farmerId)) {
            return new List<Booking__c>();
        }
        
        String query = 'SELECT Id, Equipment__c, Equipment__r.Equipment_Name__c, Status__c, ' +
                      'Start_Date__c, End_Date__c, Total_Amount__c FROM Booking__c ' +
                      'WHERE Farmer__c = :farmerId';
        
        if (String.isNotBlank(status)) {
            query += ' AND Status__c = :status';
        }
        
        query += ' ORDER BY Start_Date__c DESC LIMIT 200';
        
        try {
            return Database.query(query);
        } catch (QueryException e) {
            System.debug('Error querying farmer bookings: ' + e.getMessage());
            return new List<Booking__c>();
        }
    }
    
    /**
     * Static method to get bookings by equipment
     * @param equipmentId Equipment ID
     * @return List of Booking__c records
     */
    public static List<Booking__c> getBookingsByEquipment(String equipmentId) {
        if (String.isBlank(equipmentId)) {
            return new List<Booking__c>();
        }
        
        try {
            return [
                SELECT Id, Farmer__c, Farmer__r.Farmer_Name__c, Status__c, 
                       Start_Date__c, End_Date__c, Total_Amount__c
                FROM Booking__c
                WHERE Equipment__c = :equipmentId
                ORDER BY Start_Date__c DESC
                LIMIT 200
            ];
        } catch (QueryException e) {
            System.debug('Error querying equipment bookings: ' + e.getMessage());
            return new List<Booking__c>();
        }
    }
    
    /**
     * Static method to bulk update booking statuses
     * @param bookingIds List of booking IDs to update
     * @param newStatus New status to set
     */
    public static void bulkUpdateBookingStatus(List<String> bookingIds, String newStatus) {
        if (bookingIds == null || bookingIds.isEmpty() || !VALID_STATUSES.contains(newStatus)) {
            return;
        }
        
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        
        for (String bookingId : bookingIds) {
            if (String.isNotBlank(bookingId)) {
                bookingsToUpdate.add(new Booking__c(
                    Id = bookingId,
                    Status__c = newStatus
                ));
            }
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            try {
                update bookingsToUpdate;
            } catch (DmlException e) {
                System.debug('Error in bulk update: ' + e.getMessage());
                throw new BookingException('Failed to bulk update booking statuses: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Method to validate booking data
     * @return Boolean indicating if data is valid
     */
    public Boolean validateBookingData() {
        List<String> validationErrors = new List<String>();
        
        if (String.isBlank(this.equipmentId)) {
            validationErrors.add('Equipment is required');
        }
        
        if (String.isBlank(this.farmerId)) {
            validationErrors.add('Farmer is required');
        }
        
        if (!areDatesValid()) {
            validationErrors.add('Invalid booking dates');
        }
        
        if (hasBookingConflict(this.equipmentId, this.startDate, this.endDate, this.bookingId)) {
            validationErrors.add('Equipment is already booked for the selected dates');
        }
        
        if (!validationErrors.isEmpty()) {
            String errorMessage = 'Validation failed: ' + String.join(validationErrors, ', ');
            throw new BookingException(errorMessage);
        }
        
        return true;
    }
    
    /**
     * Custom Exception class for Booking-related errors
     */
    public class BookingException extends Exception {}
}