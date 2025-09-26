trigger PaymentProcessedEventTrigger on PaymentProcessed__e (after insert) {
    List<Payment__c> paymentsToUpdate = new List<Payment__c>();
    List<Booking__c> bookingsToUpdate = new List<Booking__c>();
    List<String> paymentIds = new List<String>();
    List<String> bookingIds = new List<String>();
    
    // Collect IDs from the events
    for (PaymentProcessed__e event : Trigger.new) {
        if (String.isNotBlank(event.PaymentId__c)) {
            paymentIds.add(event.PaymentId__c);
        }
        if (String.isNotBlank(event.BookingId__c)) {
            bookingIds.add(event.BookingId__c);
        }
    }
    
    // Query existing payments by Transaction ID
    Map<String, Payment__c> existingPayments = new Map<String, Payment__c>();
    if (!paymentIds.isEmpty()) {
        for (Payment__c payment : [SELECT Id, Transaction_ID__c, Status__c, Booking__c FROM Payment__c WHERE Transaction_ID__c IN :paymentIds]) {
            existingPayments.put(payment.Transaction_ID__c, payment);
        }
    }
    
    // Query existing bookings
    Map<Id, Booking__c> existingBookings = new Map<Id, Booking__c>();
    if (!bookingIds.isEmpty()) {
        existingBookings = new Map<Id, Booking__c>(
            [SELECT Id, Status__c FROM Booking__c WHERE Id IN :bookingIds]
        );
    }
    
    for (PaymentProcessed__e event : Trigger.new) {
        // Update payment status if payment exists
        if (String.isNotBlank(event.PaymentId__c) && existingPayments.containsKey(event.PaymentId__c)) {
            Payment__c payment = existingPayments.get(event.PaymentId__c);
            payment.Status__c = event.Status__c;
            paymentsToUpdate.add(payment);
            
            // If payment is successful, update the related booking
            if (event.Status__c == 'SUCCESS' && String.isNotBlank(payment.Booking__c)) {
                if (existingBookings.containsKey(payment.Booking__c)) {
                    Booking__c booking = existingBookings.get(payment.Booking__c);
                    booking.Status__c = 'Paid';
                    bookingsToUpdate.add(booking);
                }
            }
        }
        
        System.debug('Payment processed event handled: ' + event.PaymentId__c + ' with status: ' + event.Status__c);
    }
    
    // Update records
    if (!paymentsToUpdate.isEmpty()) {
        try {
            update paymentsToUpdate;
            System.debug('Successfully updated ' + paymentsToUpdate.size() + ' payment(s)');
        } catch (DmlException e) {
            System.debug('Error updating payments: ' + e.getMessage());
        }
    }
    
    if (!bookingsToUpdate.isEmpty()) {
        try {
            update bookingsToUpdate;
            System.debug('Successfully updated ' + bookingsToUpdate.size() + ' booking(s) to Paid status');
        } catch (DmlException e) {
            System.debug('Error updating booking status: ' + e.getMessage());
        }
    }
}