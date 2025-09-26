trigger BookingConfirmedEventTrigger on BookingConfirmed__e (after insert) {
    List<Booking__c> bookingsToUpdate = new List<Booking__c>();
    List<String> bookingIds = new List<String>();
    
    // Collect booking IDs from the events
    for (BookingConfirmed__e event : Trigger.new) {
        if (String.isNotBlank(event.BookingId__c)) {
            bookingIds.add(event.BookingId__c);
        }
    }
    
    if (!bookingIds.isEmpty()) {
        // Query existing bookings
        Map<Id, Booking__c> existingBookings = new Map<Id, Booking__c>(
            [SELECT Id, Status__c, Equipment__c FROM Booking__c WHERE Id IN :bookingIds]
        );
        
        for (BookingConfirmed__e event : Trigger.new) {
            if (String.isNotBlank(event.BookingId__c) && existingBookings.containsKey(event.BookingId__c)) {
                Booking__c booking = existingBookings.get(event.BookingId__c);
                booking.Status__c = 'Confirmed';
                bookingsToUpdate.add(booking);
                
                System.debug('Booking confirmed event processed for booking: ' + event.BookingId__c);
            }
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            try {
                update bookingsToUpdate;
                System.debug('Successfully updated ' + bookingsToUpdate.size() + ' booking(s) status to Confirmed');
            } catch (DmlException e) {
                System.debug('Error updating booking status: ' + e.getMessage());
            }
        }
    }
}