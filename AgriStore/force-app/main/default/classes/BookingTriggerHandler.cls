/**
 * @description Trigger Handler for Booking__c object
 * @author Sachin Bisen
 * @date September 2025
 */
public with sharing class BookingTriggerHandler extends TriggerHandler {
    
    // Prevent recursion
    private static Boolean preventRecursion = false;
    
    /**
     * Before Insert Handler
     * @param newBookings List of new Booking records
     */
    public void beforeInsert(List<Booking__c> newBookings) {
        System.debug('BookingTriggerHandler.beforeInsert - Processing ' + newBookings.size() + ' records');
        
        // Validate booking data and check for conflicts
        validateBookingDates(newBookings);
        checkBookingConflicts(newBookings);
        calculateTotalAmounts(newBookings);
    }
    
    /**
     * Before Update Handler
     * @param newBookings List of new Booking records
     * @param oldBookings List of old Booking records
     * @param oldBookingMap Map of old Booking records
     */
    public void beforeUpdate(List<Booking__c> newBookings, List<Booking__c> oldBookings, Map<Id, Booking__c> oldBookingMap) {
        System.debug('BookingTriggerHandler.beforeUpdate - Processing ' + newBookings.size() + ' records');
        
        // Validate only if dates have changed
        List<Booking__c> bookingsWithChangedDates = new List<Booking__c>();
        
        for (Booking__c newBooking : newBookings) {
            Booking__c oldBooking = oldBookingMap.get(newBooking.Id);
            
            if (newBooking.Start_Date__c != oldBooking.Start_Date__c || 
                newBooking.End_Date__c != oldBooking.End_Date__c ||
                newBooking.Equipment__c != oldBooking.Equipment__c) {
                bookingsWithChangedDates.add(newBooking);
            }
        }
        
        if (!bookingsWithChangedDates.isEmpty()) {
            validateBookingDates(bookingsWithChangedDates);
            checkBookingConflicts(bookingsWithChangedDates);
            calculateTotalAmounts(bookingsWithChangedDates);
        }
        
        // Handle status changes
        handleStatusChanges(newBookings, oldBookingMap);
    }
    
    /**
     * Before Delete Handler
     * @param oldBookings List of old Booking records
     * @param oldBookingMap Map of old Booking records
     */
    public void beforeDelete(List<Booking__c> oldBookings, Map<Id, Booking__c> oldBookingMap) {
        System.debug('BookingTriggerHandler.beforeDelete - Processing ' + oldBookings.size() + ' records');
        
        // Prevent deletion of bookings with payments
        preventDeletionWithPayments(oldBookings);
    }
    
    /**
     * After Insert Handler
     * @param newBookings List of new Booking records
     * @param newBookingMap Map of new Booking records
     */
    public void afterInsert(List<Booking__c> newBookings, Map<Id, Booking__c> newBookingMap) {
        System.debug('BookingTriggerHandler.afterInsert - Processing ' + newBookings.size() + ' records');
        
        // Update equipment availability for confirmed bookings
        updateEquipmentAvailability(newBookings, null);
        
        // Create payment records for confirmed bookings
        createPaymentRecords(newBookings);
    }
    
    /**
     * After Update Handler
     * @param newBookings List of new Booking records
     * @param oldBookings List of old Booking records
     * @param newBookingMap Map of new Booking records
     * @param oldBookingMap Map of old Booking records
     */
    public void afterUpdate(List<Booking__c> newBookings, List<Booking__c> oldBookings, 
                           Map<Id, Booking__c> newBookingMap, Map<Id, Booking__c> oldBookingMap) {
        System.debug('BookingTriggerHandler.afterUpdate - Processing ' + newBookings.size() + ' records');
        
        // Handle equipment availability changes
        updateEquipmentAvailability(newBookings, oldBookingMap);
        
        // Handle payment record updates
        handlePaymentStatusUpdates(newBookings, oldBookingMap);
        
        // Send notifications for status changes
        sendStatusChangeNotifications(newBookings, oldBookingMap);
    }
    
    /**
     * After Delete Handler
     * @param oldBookings List of old Booking records
     * @param oldBookingMap Map of old Booking records
     */
    public void afterDelete(List<Booking__c> oldBookings, Map<Id, Booking__c> oldBookingMap) {
        System.debug('BookingTriggerHandler.afterDelete - Processing ' + oldBookings.size() + ' records');
        
        // Update equipment availability when bookings are deleted
        makeEquipmentAvailable(oldBookings);
    }
    
    /**
     * After Undelete Handler
     * @param newBookings List of restored Booking records
     * @param newBookingMap Map of restored Booking records
     */
    public void afterUndelete(List<Booking__c> newBookings, Map<Id, Booking__c> newBookingMap) {
        System.debug('BookingTriggerHandler.afterUndelete - Processing ' + newBookings.size() + ' records');
        
        // Re-validate conflicts for restored bookings
        checkBookingConflicts(newBookings);
        updateEquipmentAvailability(newBookings, null);
    }
    
    /**
     * Validate booking dates
     * @param bookings List of bookings to validate
     */
    private void validateBookingDates(List<Booking__c> bookings) {
        for (Booking__c booking : bookings) {
            // Check if start date is not in the past
            if (booking.Start_Date__c != null && booking.Start_Date__c < Date.today()) {
                booking.Start_Date__c.addError('Start date cannot be in the past');
            }
            
            // Check if end date is not before start date
            if (booking.Start_Date__c != null && booking.End_Date__c != null && 
                booking.End_Date__c < booking.Start_Date__c) {
                booking.End_Date__c.addError('End date cannot be before start date');
            }
            
            // Check for maximum booking duration (e.g., 30 days)
            if (booking.Start_Date__c != null && booking.End_Date__c != null) {
                Integer duration = booking.Start_Date__c.daysBetween(booking.End_Date__c);
                if (duration > 30) {
                    booking.End_Date__c.addError('Booking duration cannot exceed 30 days');
                }
            }
        }
    }
    
    /**
     * Check for booking conflicts
     * @param bookings List of bookings to check
     */
    private void checkBookingConflicts(List<Booking__c> bookings) {
        Set<Id> equipmentIds = new Set<Id>();
        
        // Collect all equipment IDs
        for (Booking__c booking : bookings) {
            if (booking.Equipment__c != null) {
                equipmentIds.add(booking.Equipment__c);
            }
        }
        
        if (equipmentIds.isEmpty()) {
            return;
        }
        
        // Query existing bookings for these equipment
        Map<Id, List<Booking__c>> existingBookingsByEquipment = new Map<Id, List<Booking__c>>();
        
        List<Booking__c> existingBookings = [
            SELECT Id, Equipment__c, Start_Date__c, End_Date__c, Status__c
            FROM Booking__c
            WHERE Equipment__c IN :equipmentIds
            AND Status__c IN ('Pending', 'Confirmed')
            AND Id NOT IN :bookings
        ];
        
        // Group existing bookings by equipment
        for (Booking__c existingBooking : existingBookings) {
            if (!existingBookingsByEquipment.containsKey(existingBooking.Equipment__c)) {
                existingBookingsByEquipment.put(existingBooking.Equipment__c, new List<Booking__c>());
            }
            existingBookingsByEquipment.get(existingBooking.Equipment__c).add(existingBooking);
        }
        
        // Check for conflicts
        for (Booking__c newBooking : bookings) {
            if (existingBookingsByEquipment.containsKey(newBooking.Equipment__c)) {
                for (Booking__c existingBooking : existingBookingsByEquipment.get(newBooking.Equipment__c)) {
                    if (hasDateOverlap(newBooking, existingBooking)) {
                        newBooking.addError('Equipment is already booked for overlapping dates');
                        break;
                    }
                }
            }
        }
    }
    
    /**
     * Check if two bookings have overlapping dates
     * @param booking1 First booking
     * @param booking2 Second booking
     * @return Boolean indicating overlap
     */
    private Boolean hasDateOverlap(Booking__c booking1, Booking__c booking2) {
        return (booking1.Start_Date__c <= booking2.End_Date__c && 
                booking1.End_Date__c >= booking2.Start_Date__c);
    }
    
    /**
     * Calculate total amounts for bookings
     * @param bookings List of bookings
     */
    private void calculateTotalAmounts(List<Booking__c> bookings) {
        Set<Id> equipmentIds = new Set<Id>();
        
        for (Booking__c booking : bookings) {
            if (booking.Equipment__c != null) {
                equipmentIds.add(booking.Equipment__c);
            }
        }
        
        if (equipmentIds.isEmpty()) {
            return;
        }
        
        // Get equipment rental rates
        Map<Id, Equipment__c> equipmentMap = new Map<Id, Equipment__c>([
            SELECT Id, Rental_Rate__c
            FROM Equipment__c
            WHERE Id IN :equipmentIds
        ]);
        
        for (Booking__c booking : bookings) {
            if (booking.Equipment__c != null && equipmentMap.containsKey(booking.Equipment__c)) {
                Equipment__c equipment = equipmentMap.get(booking.Equipment__c);
                
                if (booking.Start_Date__c != null && booking.End_Date__c != null && 
                    equipment.Rental_Rate__c != null) {
                    Integer duration = booking.Start_Date__c.daysBetween(booking.End_Date__c) + 1;
                    booking.Total_Amount__c = equipment.Rental_Rate__c * duration;
                }
            }
        }
    }
    
    /**
     * Handle status changes
     * @param newBookings List of new booking records
     * @param oldBookingMap Map of old booking records
     */
    private void handleStatusChanges(List<Booking__c> newBookings, Map<Id, Booking__c> oldBookingMap) {
        for (Booking__c newBooking : newBookings) {
            Booking__c oldBooking = oldBookingMap.get(newBooking.Id);
            
            // Prevent changing from Completed status
            if (oldBooking.Status__c == 'Completed' && newBooking.Status__c != 'Completed') {
                newBooking.Status__c.addError('Cannot change status of completed bookings');
            }
            
            // Prevent changing to Confirmed if dates are invalid
            if (newBooking.Status__c == 'Confirmed' && oldBooking.Status__c != 'Confirmed') {
                if (newBooking.Start_Date__c == null || newBooking.End_Date__c == null) {
                    newBooking.Status__c.addError('Cannot confirm booking without valid dates');
                }
            }
        }
    }
    
    /**
     * Update equipment availability based on booking status
     * @param bookings List of booking records
     * @param oldBookingMap Map of old booking records (null for insert)
     */
    private void updateEquipmentAvailability(List<Booking__c> bookings, Map<Id, Booking__c> oldBookingMap) {
        if (preventRecursion) {
            return;
        }
        
        Set<Id> equipmentToMakeUnavailable = new Set<Id>();
        Set<Id> equipmentToMakeAvailable = new Set<Id>();
        
        for (Booking__c booking : bookings) {
            Booking__c oldBooking = oldBookingMap?.get(booking.Id);
            
            // Make equipment unavailable for confirmed bookings
            if (booking.Status__c == 'Confirmed' && 
                (oldBooking == null || oldBooking.Status__c != 'Confirmed')) {
                equipmentToMakeUnavailable.add(booking.Equipment__c);
            }
            
            // Make equipment available for cancelled or completed bookings
            if ((booking.Status__c == 'Cancelled' || booking.Status__c == 'Completed') &&
                oldBooking != null && oldBooking.Status__c == 'Confirmed') {
                equipmentToMakeAvailable.add(booking.Equipment__c);
            }
        }
        
        // Update equipment availability
        List<Equipment__c> equipmentToUpdate = new List<Equipment__c>();
        
        for (Id equipmentId : equipmentToMakeUnavailable) {
            equipmentToUpdate.add(new Equipment__c(Id = equipmentId, Availability__c = false));
        }
        
        for (Id equipmentId : equipmentToMakeAvailable) {
            equipmentToUpdate.add(new Equipment__c(Id = equipmentId, Availability__c = true));
        }
        
        if (!equipmentToUpdate.isEmpty()) {
            preventRecursion = true;
            try {
                update equipmentToUpdate;
            } catch (Exception e) {
                System.debug('Error updating equipment availability: ' + e.getMessage());
            } finally {
                preventRecursion = false;
            }
        }
    }
    
    /**
     * Create payment records for confirmed bookings
     * @param bookings List of booking records
     */
    private void createPaymentRecords(List<Booking__c> bookings) {
        List<Payment__c> paymentsToCreate = new List<Payment__c>();
        
        for (Booking__c booking : bookings) {
            if (booking.Status__c == 'Confirmed' && booking.Total_Amount__c != null && booking.Total_Amount__c > 0) {
                paymentsToCreate.add(new Payment__c(
                    Booking__c = booking.Id,
                    Amount__c = booking.Total_Amount__c,
                    Status__c = 'Pending',
                    Payment_Date__c = Date.today()
                ));
            }
        }
        
        if (!paymentsToCreate.isEmpty()) {
            try {
                insert paymentsToCreate;
            } catch (Exception e) {
                System.debug('Error creating payment records: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Handle payment status updates
     * @param newBookings List of new booking records
     * @param oldBookingMap Map of old booking records
     */
    private void handlePaymentStatusUpdates(List<Booking__c> newBookings, Map<Id, Booking__c> oldBookingMap) {
        // Implementation would handle updating payment statuses based on booking changes
        // This is a placeholder for complex payment logic
    }
    
    /**
     * Send notifications for status changes
     * @param newBookings List of new booking records
     * @param oldBookingMap Map of old booking records
     */
    private void sendStatusChangeNotifications(List<Booking__c> newBookings, Map<Id, Booking__c> oldBookingMap) {
        // Implementation would send notifications
        // This could integrate with Flow Builder or custom notification logic
    }
    
    /**
     * Make equipment available when bookings are deleted
     * @param deletedBookings List of deleted booking records
     */
    private void makeEquipmentAvailable(List<Booking__c> deletedBookings) {
        Set<Id> equipmentIds = new Set<Id>();
        
        for (Booking__c booking : deletedBookings) {
            if (booking.Status__c == 'Confirmed' && booking.Equipment__c != null) {
                equipmentIds.add(booking.Equipment__c);
            }
        }
        
        if (!equipmentIds.isEmpty()) {
            List<Equipment__c> equipmentToUpdate = new List<Equipment__c>();
            
            for (Id equipmentId : equipmentIds) {
                equipmentToUpdate.add(new Equipment__c(Id = equipmentId, Availability__c = true));
            }
            
            try {
                update equipmentToUpdate;
            } catch (Exception e) {
                System.debug('Error updating equipment availability after deletion: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Prevent deletion of bookings with payments
     * @param bookingsToDelete List of bookings being deleted
     */
    private void preventDeletionWithPayments(List<Booking__c> bookingsToDelete) {
        Set<Id> bookingIds = new Set<Id>();
        
        for (Booking__c booking : bookingsToDelete) {
            bookingIds.add(booking.Id);
        }
        
        // Check if any booking has associated payments
        List<Payment__c> existingPayments = [
            SELECT Booking__c
            FROM Payment__c
            WHERE Booking__c IN :bookingIds
            AND Status__c = 'Paid'
        ];
        
        Set<Id> bookingsWithPayments = new Set<Id>();
        for (Payment__c payment : existingPayments) {
            bookingsWithPayments.add(payment.Booking__c);
        }
        
        // Prevent deletion of bookings with payments
        for (Booking__c booking : bookingsToDelete) {
            if (bookingsWithPayments.contains(booking.Id)) {
                booking.addError('Cannot delete booking with associated payments');
            }
        }
    }
}