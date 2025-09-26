/**
 * @description Service class for Booking LWC components
 * @author Sachin Bisen
 * @date September 2025
 */
public with sharing class BookingService {
    
    /**
     * Get bookings for calendar view
     * @param startDate Start date for calendar
     * @param endDate End date for calendar
     * @return List of booking records
     */
    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getBookingsForCalendar(Date startDate, Date endDate) {
        try {
            return [
                SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Amount__c,
                       Equipment__c, Equipment__r.Equipment_Name__c, Equipment__r.Equipment_Type__c,
                       Farmer__c, Farmer__r.Farmer_Name__c
                FROM Booking__c
                WHERE Start_Date__c >= :startDate
                AND End_Date__c <= :endDate
                ORDER BY Start_Date__c ASC
                LIMIT 200
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching bookings: ' + e.getMessage());
        }
    }
    
    /**
     * Get recent bookings
     * @return List of recent booking records
     */
    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getRecentBookings() {
        try {
            return [
                SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Amount__c,
                       Equipment__r.Equipment_Name__c, Farmer__r.Farmer_Name__c
                FROM Booking__c
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching recent bookings: ' + e.getMessage());
        }
    }
    
    /**
     * Create new booking
     * @param equipmentId Equipment ID
     * @param farmerId Farmer ID
     * @param startDate Start date
     * @param endDate End date
     * @return Created booking record
     */
    @AuraEnabled
    public static Booking__c createBooking(String equipmentId, String farmerId, Date startDate, Date endDate) {
        try {
            Booking__c newBooking = new Booking__c(
                Equipment__c = equipmentId,
                Farmer__c = farmerId,
                Start_Date__c = startDate,
                End_Date__c = endDate,
                Status__c = 'Pending'
            );
            
            insert newBooking;
            
            // Return the full record
            return [
                SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Amount__c,
                       Equipment__r.Equipment_Name__c, Farmer__r.Farmer_Name__c
                FROM Booking__c
                WHERE Id = :newBooking.Id
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating booking: ' + e.getMessage());
        }
    }
    
    /**
     * Update booking status
     * @param bookingId Booking ID
     * @param newStatus New status
     * @return Updated booking record
     */
    @AuraEnabled
    public static Booking__c updateBookingStatus(String bookingId, String newStatus) {
        try {
            Booking__c booking = new Booking__c(
                Id = bookingId,
                Status__c = newStatus
            );
            
            update booking;
            
            // Return the full record
            return [
                SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Total_Amount__c,
                       Equipment__r.Equipment_Name__c, Farmer__r.Farmer_Name__c
                FROM Booking__c
                WHERE Id = :bookingId
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error updating booking: ' + e.getMessage());
        }
    }
    
    /**
     * Get booking statistics
     * @return Map with booking statistics
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getBookingStatistics() {
        try {
            Map<String, Object> stats = new Map<String, Object>();
            
            // Total bookings
            Integer totalBookings = [SELECT COUNT() FROM Booking__c];
            stats.put('totalBookings', totalBookings);
            
            // Bookings by status
            List<AggregateResult> statusResults = [
                SELECT Status__c, COUNT(Id) count
                FROM Booking__c
                GROUP BY Status__c
            ];
            
            Map<String, Integer> statusCounts = new Map<String, Integer>();
            for (AggregateResult result : statusResults) {
                statusCounts.put((String) result.get('Status__c'), (Integer) result.get('count'));
            }
            stats.put('statusCounts', statusCounts);
            
            // Monthly bookings (current year)
            List<AggregateResult> monthlyResults = [
                SELECT CALENDAR_MONTH(Start_Date__c) month, COUNT(Id) count
                FROM Booking__c
                WHERE CALENDAR_YEAR(Start_Date__c) = :Date.today().year()
                GROUP BY CALENDAR_MONTH(Start_Date__c)
                ORDER BY CALENDAR_MONTH(Start_Date__c)
            ];
            
            List<Map<String, Object>> monthlyData = new List<Map<String, Object>>();
            for (AggregateResult result : monthlyResults) {
                Map<String, Object> monthData = new Map<String, Object>();
                monthData.put('month', result.get('month'));
                monthData.put('count', result.get('count'));
                monthlyData.add(monthData);
            }
            stats.put('monthlyBookings', monthlyData);
            
            return stats;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching booking statistics: ' + e.getMessage());
        }
    }
}