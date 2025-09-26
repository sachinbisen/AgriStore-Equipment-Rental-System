/**
 * @description Queueable Apex class for processing payments and chaining booking updates
 * @author Sachin Bisen
 * @date September 2025
 */
public class PaymentProcessingQueueable implements Queueable, Database.AllowsCallouts {
    
    // Instance variables
    private List<Id> paymentIds;
    private String processType;
    private Map<String, Object> processingOptions;
    
    // Processing types
    public static final String PROCESS_PENDING_PAYMENTS = 'PROCESS_PENDING';
    public static final String PROCESS_FAILED_PAYMENTS = 'PROCESS_FAILED';
    public static final String PROCESS_REFUNDS = 'PROCESS_REFUNDS';
    public static final String SEND_NOTIFICATIONS = 'SEND_NOTIFICATIONS';
    
    /**
     * Constructor for processing payments
     * @param paymentIds List of payment IDs to process
     * @param processType Type of processing to perform
     */
    public PaymentProcessingQueueable(List<Id> paymentIds, String processType) {
        this.paymentIds = paymentIds != null ? paymentIds : new List<Id>();
        this.processType = processType != null ? processType : PROCESS_PENDING_PAYMENTS;
        this.processingOptions = new Map<String, Object>();
    }
    
    /**
     * Constructor with additional options
     * @param paymentIds List of payment IDs to process
     * @param processType Type of processing to perform
     * @param options Additional processing options
     */
    public PaymentProcessingQueueable(List<Id> paymentIds, String processType, Map<String, Object> options) {
        this.paymentIds = paymentIds != null ? paymentIds : new List<Id>();
        this.processType = processType != null ? processType : PROCESS_PENDING_PAYMENTS;
        this.processingOptions = options != null ? options : new Map<String, Object>();
    }
    
    /**
     * Main execution method
     * @param context QueueableContext
     */
    public void execute(QueueableContext context) {
        System.debug('PaymentProcessingQueueable.execute - Processing ' + this.paymentIds.size() + 
                    ' payments with type: ' + this.processType);
        
        try {
            // Process based on type
            switch on this.processType {
                when 'PROCESS_PENDING' {
                    processPendingPayments();
                }
                when 'PROCESS_FAILED' {
                    processFailedPayments();
                }
                when 'PROCESS_REFUNDS' {
                    processRefunds();
                }
                when 'SEND_NOTIFICATIONS' {
                    sendPaymentNotifications();
                }
                when else {
                    System.debug('Unknown process type: ' + this.processType);
                }
            }
            
            // Chain next job if needed
            chainNextJob();
            
        } catch (Exception e) {
            System.debug('Error in PaymentProcessingQueueable: ' + e.getMessage() + ' at line ' + e.getLineNumber());
            
            // Handle errors and potentially retry
            handleProcessingError(e);
        }
    }
    
    /**
     * Process pending payments
     */
    private void processPendingPayments() {
        if (this.paymentIds.isEmpty()) {
            return;
        }
        
        // Query pending payments
        List<Payment__c> pendingPayments = [
            SELECT Id, Booking__c, Amount__c, Payment_Method__c, Status__c, CreatedDate
            FROM Payment__c
            WHERE Id IN :this.paymentIds
            AND Status__c = 'Pending'
            FOR UPDATE
        ];
        
        if (pendingPayments.isEmpty()) {
            System.debug('No pending payments found to process');
            return;
        }
        
        List<Payment__c> paymentsToUpdate = new List<Payment__c>();
        List<Id> successfulPaymentIds = new List<Id>();
        List<Id> failedPaymentIds = new List<Id>();
        
        // Process each payment
        for (Payment__c payment : pendingPayments) {
            try {
                // Simulate payment gateway call (this would be a real callout in production)
                Boolean paymentSuccess = simulatePaymentGatewayCall(payment);
                
                if (paymentSuccess) {
                    payment.Status__c = 'Paid';
                    payment.Payment_Date__c = Date.today();
                    successfulPaymentIds.add(payment.Id);
                } else {
                    payment.Status__c = 'Failed';
                    failedPaymentIds.add(payment.Id);
                }
                
                paymentsToUpdate.add(payment);
                
            } catch (Exception e) {
                System.debug('Error processing payment ' + payment.Id + ': ' + e.getMessage());
                payment.Status__c = 'Failed';
                paymentsToUpdate.add(payment);
                failedPaymentIds.add(payment.Id);
            }
        }
        
        // Update payment records
        if (!paymentsToUpdate.isEmpty()) {
            try {
                update paymentsToUpdate;
                System.debug('Updated ' + paymentsToUpdate.size() + ' payment records');
            } catch (DmlException e) {
                System.debug('Error updating payments: ' + e.getMessage());
            }
        }
        
        // Chain booking updates for successful payments
        if (!successfulPaymentIds.isEmpty()) {
            chainBookingUpdates(successfulPaymentIds, 'CONFIRM_BOOKINGS');
        }
        
        // Chain notification sending for failed payments
        if (!failedPaymentIds.isEmpty()) {
            chainNotificationSending(failedPaymentIds, 'PAYMENT_FAILED');
        }
    }
    
    /**
     * Process failed payments (retry logic)
     */
    private void processFailedPayments() {
        if (this.paymentIds.isEmpty()) {
            return;
        }
        
        Integer retryLimit = (Integer) this.processingOptions.get('retryLimit');
        retryLimit = retryLimit != null ? retryLimit : 3;
        
        // Query failed payments that haven't exceeded retry limit
        List<Payment__c> failedPayments = [
            SELECT Id, Booking__c, Amount__c, Payment_Method__c, Status__c, 
                   Retry_Count__c, CreatedDate, LastModifiedDate
            FROM Payment__c
            WHERE Id IN :this.paymentIds
            AND Status__c = 'Failed'
            AND (Retry_Count__c < :retryLimit OR Retry_Count__c = null)
        ];
        
        List<Payment__c> paymentsToRetry = new List<Payment__c>();
        
        for (Payment__c payment : failedPayments) {
            // Only retry if payment is not too old (e.g., within 24 hours)
            DateTime paymentCreated = payment.CreatedDate;
            DateTime cutoffTime = DateTime.now().addHours(-24);
            
            if (paymentCreated > cutoffTime) {
                Boolean retrySuccess = simulatePaymentGatewayCall(payment);
                
                if (retrySuccess) {
                    payment.Status__c = 'Paid';
                    payment.Payment_Date__c = Date.today();
                } else {
                    Integer retryCount = payment.Retry_Count__c != null ? 
                                        Integer.valueOf(payment.Retry_Count__c) + 1 : 1;
                    // payment.Retry_Count__c = retryCount; // Would need this field in the object
                }
                
                paymentsToRetry.add(payment);
            }
        }
        
        if (!paymentsToRetry.isEmpty()) {
            try {
                update paymentsToRetry;
                System.debug('Processed retry for ' + paymentsToRetry.size() + ' failed payments');
            } catch (DmlException e) {
                System.debug('Error updating retry payments: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Process refunds
     */
    private void processRefunds() {
        if (this.paymentIds.isEmpty()) {
            return;
        }
        
        // Query paid payments that need refunding
        List<Payment__c> paymentsToRefund = [
            SELECT Id, Booking__c, Amount__c, Payment_Method__c, Status__c
            FROM Payment__c
            WHERE Id IN :this.paymentIds
            AND Status__c = 'Paid'
        ];
        
        List<Payment__c> refundedPayments = new List<Payment__c>();
        
        for (Payment__c payment : paymentsToRefund) {
            try {
                // Simulate refund gateway call
                Boolean refundSuccess = simulateRefundGatewayCall(payment);
                
                if (refundSuccess) {
                    // Create refund record or update status
                    // In real implementation, you might create a separate Refund__c record
                    payment.Status__c = 'Refunded';
                    refundedPayments.add(payment);
                }
                
            } catch (Exception e) {
                System.debug('Error processing refund for payment ' + payment.Id + ': ' + e.getMessage());
            }
        }
        
        if (!refundedPayments.isEmpty()) {
            try {
                update refundedPayments;
                System.debug('Processed ' + refundedPayments.size() + ' refunds');
            } catch (DmlException e) {
                System.debug('Error updating refunded payments: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Send payment notifications
     */
    private void sendPaymentNotifications() {
        if (this.paymentIds.isEmpty()) {
            return;
        }
        
        String notificationType = (String) this.processingOptions.get('notificationType');
        notificationType = notificationType != null ? notificationType : 'PAYMENT_SUCCESS';
        
        // Query payments with related data for notifications
        List<Payment__c> payments = [
            SELECT Id, Booking__c, Booking__r.Name, Booking__r.Farmer__c, Booking__r.Farmer__r.Email__c,
                   Amount__c, Status__c, Payment_Method__c, Payment_Date__c
            FROM Payment__c
            WHERE Id IN :this.paymentIds
        ];
        
        for (Payment__c payment : payments) {
            try {
                sendPaymentNotification(payment, notificationType);
            } catch (Exception e) {
                System.debug('Error sending notification for payment ' + payment.Id + ': ' + e.getMessage());
            }
        }
    }
    
    /**
     * Simulate payment gateway call (replace with real gateway integration)
     * @param payment Payment record
     * @return Boolean indicating success
     */
    private Boolean simulatePaymentGatewayCall(Payment__c payment) {
        // In real implementation, this would make an HTTP callout to payment gateway
        // For simulation, return random success/failure
        
        Integer randomNum = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);
        Boolean success = randomNum > 2; // 70% success rate
        
        System.debug('Simulated payment gateway call for ' + payment.Id + ': ' + 
                    (success ? 'SUCCESS' : 'FAILED'));
        
        return success;
    }
    
    /**
     * Simulate refund gateway call
     * @param payment Payment record
     * @return Boolean indicating success
     */
    private Boolean simulateRefundGatewayCall(Payment__c payment) {
        // In real implementation, this would make an HTTP callout to payment gateway
        // For simulation, assume refunds are generally successful
        
        System.debug('Simulated refund gateway call for ' + payment.Id + ': SUCCESS');
        return true;
    }
    
    /**
     * Send individual payment notification
     * @param payment Payment record with related data
     * @param notificationType Type of notification to send
     */
    private void sendPaymentNotification(Payment__c payment, String notificationType) {
        if (payment.Booking__r.Farmer__r.Email__c == null) {
            System.debug('No email address for farmer in payment ' + payment.Id);
            return;
        }
        
        String subject = '';
        String body = '';
        
        switch on notificationType {
            when 'PAYMENT_SUCCESS' {
                subject = 'Payment Successful - Booking ' + payment.Booking__r.Name;
                body = buildPaymentSuccessEmail(payment);
            }
            when 'PAYMENT_FAILED' {
                subject = 'Payment Failed - Booking ' + payment.Booking__r.Name;
                body = buildPaymentFailedEmail(payment);
            }
            when 'REFUND_PROCESSED' {
                subject = 'Refund Processed - Booking ' + payment.Booking__r.Name;
                body = buildRefundEmail(payment);
            }
        }
        
        // In real implementation, send email using Messaging.SingleEmailMessage
        System.debug('Would send email notification:');
        System.debug('To: ' + payment.Booking__r.Farmer__r.Email__c);
        System.debug('Subject: ' + subject);
        System.debug('Body: ' + body.left(100) + '...');
    }
    
    /**
     * Static method to enqueue payment processing
     * @param paymentIds List of payment IDs
     * @param processType Type of processing
     * @return Id of the enqueued job
     */
    public static Id enqueuePaymentProcessing(List<Id> paymentIds, String processType) {
        PaymentProcessingQueueable job = new PaymentProcessingQueueable(paymentIds, processType);
        return System.enqueueJob(job);
    }
    
    /**
     * Static method to enqueue payment processing with options
     * @param paymentIds List of payment IDs
     * @param processType Type of processing
     * @param options Additional processing options
     * @return Id of the enqueued job
     */
    public static Id enqueuePaymentProcessing(List<Id> paymentIds, String processType, Map<String, Object> options) {
        PaymentProcessingQueueable job = new PaymentProcessingQueueable(paymentIds, processType, options);
        return System.enqueueJob(job);
    }
}
</function_results>

I need to create the remaining part of the PaymentProcessingQueueable class. Let me update it with the complete content:

<function_calls>
<invoke name="edit_files">
<parameter name="title">Complete PaymentProcessingQueueable class