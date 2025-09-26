/**
 * @description Payment Management Class for AgriStore
 * @author Sachin Bisen
 * @date September 2025
 */
public with sharing class PaymentManager {
    
    // Private variables for encapsulation
    private String paymentId;
    private String bookingId;
    private Decimal amount;
    private String status;
    private Date paymentDate;
    private String paymentMethod;
    
    // Static constants for payment statuses
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_PAID = 'Paid';
    public static final String STATUS_FAILED = 'Failed';
    
    // Static constants for payment methods
    public static final String METHOD_UPI = 'UPI';
    public static final String METHOD_CREDIT_CARD = 'Credit Card';
    public static final String METHOD_DEBIT_CARD = 'Debit Card';
    public static final String METHOD_NET_BANKING = 'Net Banking';
    public static final String METHOD_CASH = 'Cash';
    
    // Static final lists for validation
    private static final List<String> VALID_STATUSES = new List<String>{
        STATUS_PENDING, STATUS_PAID, STATUS_FAILED
    };
    
    private static final List<String> VALID_METHODS = new List<String>{
        METHOD_UPI, METHOD_CREDIT_CARD, METHOD_DEBIT_CARD, METHOD_NET_BANKING, METHOD_CASH
    };
    
    /**
     * Default Constructor
     */
    public PaymentManager() {
        this.status = STATUS_PENDING;
        this.amount = 0.0;
        this.paymentDate = Date.today();
    }
    
    /**
     * Parameterized Constructor
     * @param bookingId ID of the booking for payment
     * @param amount Payment amount
     * @param paymentMethod Payment method
     */
    public PaymentManager(String bookingId, Decimal amount, String paymentMethod) {
        this.bookingId = bookingId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.status = STATUS_PENDING;
        this.paymentDate = Date.today();
    }
    
    /**
     * Constructor with Payment record
     * @param payment Payment__c record
     */
    public PaymentManager(Payment__c payment) {
        if (payment != null) {
            this.paymentId = payment.Id;
            this.bookingId = payment.Booking__c;
            this.amount = payment.Amount__c;
            this.status = payment.Status__c;
            this.paymentDate = payment.Payment_Date__c;
            this.paymentMethod = payment.Payment_Method__c;
        }
    }
    
    // Getter and Setter methods
    public String getPaymentId() {
        return this.paymentId;
    }
    
    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }
    
    public String getBookingId() {
        return this.bookingId;
    }
    
    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }
    
    public Decimal getAmount() {
        return this.amount;
    }
    
    public void setAmount(Decimal amount) {
        if (amount != null && amount > 0) {
            this.amount = amount;
        } else {
            throw new PaymentException('Payment amount must be greater than zero');
        }
    }
    
    public String getStatus() {
        return this.status;
    }
    
    public void setStatus(String status) {
        if (VALID_STATUSES.contains(status)) {
            this.status = status;
        } else {
            throw new PaymentException('Invalid payment status: ' + status);
        }
    }
    
    public Date getPaymentDate() {
        return this.paymentDate;
    }
    
    public void setPaymentDate(Date paymentDate) {
        this.paymentDate = paymentDate;
    }
    
    public String getPaymentMethod() {
        return this.paymentMethod;
    }
    
    public void setPaymentMethod(String paymentMethod) {
        if (VALID_METHODS.contains(paymentMethod)) {
            this.paymentMethod = paymentMethod;
        } else {
            throw new PaymentException('Invalid payment method: ' + paymentMethod);
        }
    }
    
    /**
     * Method to check if payment is successful
     * @return Boolean indicating if payment is paid
     */
    public Boolean isSuccessful() {
        return STATUS_PAID.equals(this.status);
    }
    
    /**
     * Method to check if payment has failed
     * @return Boolean indicating if payment failed
     */
    public Boolean hasFailed() {
        return STATUS_FAILED.equals(this.status);
    }
    
    /**
     * Method to check if payment is still pending
     * @return Boolean indicating if payment is pending
     */
    public Boolean isPending() {
        return STATUS_PENDING.equals(this.status);
    }
    
    /**
     * Method to process payment
     * @return Boolean indicating success
     */
    public Boolean processPayment() {
        if (this.amount == null || this.amount <= 0) {
            throw new PaymentException('Invalid payment amount');
        }
        
        if (String.isBlank(this.paymentMethod)) {
            throw new PaymentException('Payment method is required');
        }
        
        // Simulate payment processing logic
        Boolean paymentSuccess = simulatePaymentGateway();
        
        if (paymentSuccess) {
            this.status = STATUS_PAID;
            this.paymentDate = Date.today();
            
            // Update booking status if payment is successful
            updateBookingAfterPayment(true);
        } else {
            this.status = STATUS_FAILED;
        }
        
        // Update payment record in database
        updatePaymentRecord();
        
        return paymentSuccess;
    }
    
    /**
     * Method to refund payment
     * @param reason Reason for refund
     * @return Boolean indicating refund success
     */
    public Boolean refundPayment(String reason) {
        if (!isSuccessful()) {
            throw new PaymentException('Only successful payments can be refunded');
        }
        
        // Simulate refund processing
        Boolean refundSuccess = simulateRefundGateway();
        
        if (refundSuccess) {
            // Create a refund record or update status
            this.status = STATUS_PENDING; // Reset to pending for refund processing
            updatePaymentRecord();
            
            // Update booking status after refund
            updateBookingAfterPayment(false);
        }
        
        return refundSuccess;
    }
    
    /**
     * Private method to simulate payment gateway
     * @return Boolean indicating payment success
     */
    private Boolean simulatePaymentGateway() {
        // Simulate random payment success/failure
        // In real implementation, this would integrate with actual payment gateways
        Integer randomNum = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);
        return randomNum > 2; // 70% success rate
    }
    
    /**
     * Private method to simulate refund gateway
     * @return Boolean indicating refund success
     */
    private Boolean simulateRefundGateway() {
        // Simulate refund processing
        // In real implementation, this would integrate with actual payment gateways
        return true; // Assume refunds are always successful for simulation
    }
    
    /**
     * Private method to update payment record in database
     */
    private void updatePaymentRecord() {
        if (String.isNotBlank(this.paymentId)) {
            try {
                Payment__c paymentRecord = new Payment__c(
                    Id = this.paymentId,
                    Status__c = this.status,
                    Payment_Date__c = this.paymentDate,
                    Amount__c = this.amount,
                    Payment_Method__c = this.paymentMethod
                );
                update paymentRecord;
            } catch (DmlException e) {
                System.debug('Error updating payment record: ' + e.getMessage());
                throw new PaymentException('Failed to update payment record: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Private method to update booking status after payment
     * @param paymentSuccess Whether payment was successful
     */
    private void updateBookingAfterPayment(Boolean paymentSuccess) {
        if (String.isNotBlank(this.bookingId)) {
            try {
                String bookingStatus = paymentSuccess ? 'Confirmed' : 'Pending';
                Booking__c bookingRecord = new Booking__c(
                    Id = this.bookingId,
                    Status__c = bookingStatus
                );
                update bookingRecord;
            } catch (DmlException e) {
                System.debug('Error updating booking after payment: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Static method to get payments by booking
     * @param bookingId Booking ID
     * @return List of Payment__c records
     */
    public static List<Payment__c> getPaymentsByBooking(String bookingId) {
        if (String.isBlank(bookingId)) {
            return new List<Payment__c>();
        }
        
        try {
            return [
                SELECT Id, Amount__c, Status__c, Payment_Date__c, Payment_Method__c
                FROM Payment__c
                WHERE Booking__c = :bookingId
                ORDER BY Payment_Date__c DESC
                LIMIT 50
            ];
        } catch (QueryException e) {
            System.debug('Error querying payments by booking: ' + e.getMessage());
            return new List<Payment__c>();
        }
    }
    
    /**
     * Static method to get total payments for a date range
     * @param startDate Start date
     * @param endDate End date
     * @return Decimal total amount
     */
    public static Decimal getTotalPayments(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) {
            return 0.0;
        }
        
        try {
            List<AggregateResult> results = [
                SELECT SUM(Amount__c) totalAmount
                FROM Payment__c
                WHERE Status__c = :STATUS_PAID
                AND Payment_Date__c >= :startDate
                AND Payment_Date__c <= :endDate
            ];
            
            if (!results.isEmpty() && results[0].get('totalAmount') != null) {
                return (Decimal) results[0].get('totalAmount');
            }
        } catch (QueryException e) {
            System.debug('Error calculating total payments: ' + e.getMessage());
        }
        
        return 0.0;
    }
    
    /**
     * Static method to get failed payments for follow-up
     * @return List of failed Payment__c records
     */
    public static List<Payment__c> getFailedPayments() {
        try {
            return [
                SELECT Id, Booking__c, Booking__r.Name, Amount__c, Payment_Date__c, Payment_Method__c
                FROM Payment__c
                WHERE Status__c = :STATUS_FAILED
                ORDER BY Payment_Date__c DESC
                LIMIT 100
            ];
        } catch (QueryException e) {
            System.debug('Error querying failed payments: ' + e.getMessage());
            return new List<Payment__c>();
        }
    }
    
    /**
     * Static method to get payment statistics by method
     * @return Map of payment method to count
     */
    public static Map<String, Integer> getPaymentMethodStatistics() {
        Map<String, Integer> methodStats = new Map<String, Integer>();
        
        try {
            List<AggregateResult> results = [
                SELECT Payment_Method__c method, COUNT(Id) count
                FROM Payment__c
                WHERE Status__c = :STATUS_PAID
                GROUP BY Payment_Method__c
            ];
            
            for (AggregateResult result : results) {
                String method = (String) result.get('method');
                Integer count = (Integer) result.get('count');
                methodStats.put(method, count);
            }
        } catch (QueryException e) {
            System.debug('Error querying payment method statistics: ' + e.getMessage());
        }
        
        return methodStats;
    }
    
    /**
     * Static method to bulk process payments
     * @param paymentIds List of payment IDs to process
     * @return Map of payment ID to success status
     */
    public static Map<String, Boolean> bulkProcessPayments(List<String> paymentIds) {
        Map<String, Boolean> results = new Map<String, Boolean>();
        
        if (paymentIds == null || paymentIds.isEmpty()) {
            return results;
        }
        
        List<Payment__c> paymentsToProcess = [
            SELECT Id, Booking__c, Amount__c, Payment_Method__c, Status__c
            FROM Payment__c
            WHERE Id IN :paymentIds
            AND Status__c = :STATUS_PENDING
        ];
        
        List<Payment__c> paymentsToUpdate = new List<Payment__c>();
        
        for (Payment__c payment : paymentsToProcess) {
            PaymentManager paymentManager = new PaymentManager(payment);
            try {
                Boolean success = paymentManager.processPayment();
                results.put(payment.Id, success);
                
                paymentsToUpdate.add(new Payment__c(
                    Id = payment.Id,
                    Status__c = paymentManager.getStatus(),
                    Payment_Date__c = paymentManager.getPaymentDate()
                ));
            } catch (PaymentException e) {
                System.debug('Error processing payment ' + payment.Id + ': ' + e.getMessage());
                results.put(payment.Id, false);
            }
        }
        
        if (!paymentsToUpdate.isEmpty()) {
            try {
                update paymentsToUpdate;
            } catch (DmlException e) {
                System.debug('Error updating bulk payments: ' + e.getMessage());
            }
        }
        
        return results;
    }
    
    /**
     * Method to validate payment data
     * @return Boolean indicating if data is valid
     */
    public Boolean validatePaymentData() {
        List<String> validationErrors = new List<String>();
        
        if (String.isBlank(this.bookingId)) {
            validationErrors.add('Booking is required');
        }
        
        if (this.amount == null || this.amount <= 0) {
            validationErrors.add('Payment amount must be greater than zero');
        }
        
        if (String.isBlank(this.paymentMethod) || !VALID_METHODS.contains(this.paymentMethod)) {
            validationErrors.add('Valid payment method is required');
        }
        
        if (!validationErrors.isEmpty()) {
            String errorMessage = 'Validation failed: ' + String.join(validationErrors, ', ');
            throw new PaymentException(errorMessage);
        }
        
        return true;
    }
    
    /**
     * Custom Exception class for Payment-related errors
     */
    public class PaymentException extends Exception {}
}