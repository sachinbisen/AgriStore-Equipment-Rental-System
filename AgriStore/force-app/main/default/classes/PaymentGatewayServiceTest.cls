@isTest
private class PaymentGatewayServiceTest {
    
    @TestSetup
    static void makeData() {
        // Create test farmer
        Farmer__c farmer = new Farmer__c(
            Name = 'Test Farmer',
            Email__c = 'test@farmer.com',
            Phone__c = '1234567890',
            Address__c = '123 Farm Road'
        );
        insert farmer;
        
        // Create test equipment
        Equipment__c equipment = new Equipment__c(
            Name = 'Test Tractor',
            Category__c = 'Tractor',
            Rental_Rate__c = 500.00,
            Status__c = 'Available'
        );
        insert equipment;
        
        // Create test booking
        Booking__c booking = new Booking__c(
            Equipment__c = equipment.Id,
            Farmer__c = farmer.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(1),
            Status__c = 'Confirmed',
            Total_Amount__c = 500.00
        );
        insert booking;
    }
    
    @isTest
    static void testSuccessfulPaymentProcessing() {
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new PaymentGatewayMockCallout.SuccessPaymentMock());
        
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        
        PaymentGatewayService.PaymentRequest paymentRequest = new PaymentGatewayService.PaymentRequest(
            booking.Id,
            750.00,
            'USD',
            'Credit Card',
            'Equipment rental payment'
        );
        
        Test.startTest();
        PaymentGatewayService.PaymentResponse response = PaymentGatewayService.processPayment(paymentRequest);
        Test.stopTest();
        
        // Verify response
        System.assertEquals('SUCCESS', response.status);
        System.assertEquals('TXN_SUCCESS_12345', response.transactionId);
        System.assertEquals(750.00, response.amount);
        
        // Verify payment record was created
        List<Payment__c> payments = [SELECT Id, Status__c, Amount__c, Transaction_ID__c FROM Payment__c];
        System.assertEquals(1, payments.size());
        System.assertEquals('SUCCESS', payments[0].Status__c);
        System.assertEquals(750.00, payments[0].Amount__c);
        System.assertEquals('TXN_SUCCESS_12345', payments[0].Transaction_ID__c);
    }
    
    @isTest
    static void testFailedPaymentProcessing() {
        // Set up mock callout for failure
        Test.setMock(HttpCalloutMock.class, new PaymentGatewayMockCallout.FailedPaymentMock());
        
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        
        PaymentGatewayService.PaymentRequest paymentRequest = new PaymentGatewayService.PaymentRequest(
            booking.Id,
            500.00,
            'USD',
            'Credit Card',
            'Equipment rental payment'
        );
        
        Test.startTest();
        try {
            PaymentGatewayService.processPayment(paymentRequest);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Payment processing failed'));
        }
        Test.stopTest();
        
        // Verify no payment record was created
        List<Payment__c> payments = [SELECT Id FROM Payment__c];
        System.assertEquals(0, payments.size());
    }
    
    @isTest
    static void testSuccessfulRefund() {
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new PaymentGatewayMockCallout());
        
        Test.startTest();
        PaymentGatewayService.PaymentResponse response = PaymentGatewayService.refundPayment('TXN_12345', 250.00);
        Test.stopTest();
        
        // Verify response
        System.assertEquals('REFUNDED', response.status);
        System.assertEquals(250.00, response.amount);
        System.assertNotEquals(null, response.transactionId);
    }
    
    @isTest
    static void testPaymentRequestCreation() {
        PaymentGatewayService.PaymentRequest request = new PaymentGatewayService.PaymentRequest(
            'BOOKING123',
            100.00,
            'USD',
            'Credit Card',
            'Test payment'
        );
        
        System.assertEquals('BOOKING123', request.bookingId);
        System.assertEquals(100.00, request.amount);
        System.assertEquals('USD', request.currency);
        System.assertEquals('Credit Card', request.paymentMethod);
        System.assertEquals('Test payment', request.description);
    }
    
    @isTest
    static void testPaymentResponseCreation() {
        PaymentGatewayService.PaymentResponse response = new PaymentGatewayService.PaymentResponse(
            'TXN_12345',
            'SUCCESS',
            'Payment successful',
            100.00,
            'USD'
        );
        
        System.assertEquals('TXN_12345', response.transactionId);
        System.assertEquals('SUCCESS', response.status);
        System.assertEquals('Payment successful', response.message);
        System.assertEquals(100.00, response.amount);
        System.assertEquals('USD', response.currency);
        System.assertNotEquals(null, response.processedAt);
    }
}