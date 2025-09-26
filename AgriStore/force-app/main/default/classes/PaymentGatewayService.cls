public with sharing class PaymentGatewayService {
    
    public class PaymentRequest {
        public String bookingId { get; set; }
        public Decimal amount { get; set; }
        public String currency { get; set; }
        public String paymentMethod { get; set; }
        public String description { get; set; }
        
        public PaymentRequest(String bookingId, Decimal amount, String currency, String paymentMethod, String description) {
            this.bookingId = bookingId;
            this.amount = amount;
            this.currency = currency;
            this.paymentMethod = paymentMethod;
            this.description = description;
        }
    }
    
    public class PaymentResponse {
        public String transactionId { get; set; }
        public String status { get; set; }
        public String message { get; set; }
        public Decimal amount { get; set; }
        public String currency { get; set; }
        public Datetime processedAt { get; set; }
        
        public PaymentResponse() {}
        
        public PaymentResponse(String transactionId, String status, String message, Decimal amount, String currency) {
            this.transactionId = transactionId;
            this.status = status;
            this.message = message;
            this.amount = amount;
            this.currency = currency;
            this.processedAt = System.now();
        }
    }
    
    @AuraEnabled
    public static PaymentResponse processPayment(PaymentRequest paymentRequest) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            // Set the endpoint from Named Credential
            request.setEndpoint('callout:Payment_Gateway_API/payments');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000); // 2 minutes timeout
            
            // Prepare request body
            Map<String, Object> requestBody = new Map<String, Object>{
                'booking_id' => paymentRequest.bookingId,
                'amount' => paymentRequest.amount,
                'currency' => paymentRequest.currency,
                'payment_method' => paymentRequest.paymentMethod,
                'description' => paymentRequest.description
            };
            
            request.setBody(JSON.serialize(requestBody));
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                PaymentResponse paymentResponse = new PaymentResponse(
                    (String) responseBody.get('transaction_id'),
                    (String) responseBody.get('status'),
                    (String) responseBody.get('message'),
                    (Decimal) responseBody.get('amount'),
                    (String) responseBody.get('currency')
                );
                
                // Create payment record in Salesforce
                createPaymentRecord(paymentRequest, paymentResponse);
                
                // Publish platform event
                publishPaymentProcessedEvent(paymentResponse);
                
                return paymentResponse;
            } else {
                throw new CalloutException('Payment gateway error: ' + response.getBody());
            }
            
        } catch (Exception e) {
            System.debug('Payment processing error: ' + e.getMessage());
            throw new AuraHandledException('Payment processing failed: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static PaymentResponse refundPayment(String transactionId, Decimal refundAmount) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            request.setEndpoint('callout:Payment_Gateway_API/refunds');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);
            
            Map<String, Object> requestBody = new Map<String, Object>{
                'transaction_id' => transactionId,
                'refund_amount' => refundAmount
            };
            
            request.setBody(JSON.serialize(requestBody));
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                PaymentResponse refundResponse = new PaymentResponse(
                    (String) responseBody.get('refund_id'),
                    (String) responseBody.get('status'),
                    (String) responseBody.get('message'),
                    (Decimal) responseBody.get('refund_amount'),
                    (String) responseBody.get('currency')
                );
                
                return refundResponse;
            } else {
                throw new CalloutException('Refund error: ' + response.getBody());
            }
            
        } catch (Exception e) {
            System.debug('Refund processing error: ' + e.getMessage());
            throw new AuraHandledException('Refund processing failed: ' + e.getMessage());
        }
    }
    
    private static void createPaymentRecord(PaymentRequest paymentRequest, PaymentResponse paymentResponse) {
        try {
            Payment__c payment = new Payment__c(
                Booking__c = paymentRequest.bookingId,
                Amount__c = paymentResponse.amount,
                Payment_Method__c = paymentRequest.paymentMethod,
                Transaction_ID__c = paymentResponse.transactionId,
                Status__c = paymentResponse.status,
                Payment_Date__c = Date.today()
            );
            
            insert payment;
        } catch (DmlException e) {
            System.debug('Error creating payment record: ' + e.getMessage());
        }
    }
    
    private static void publishPaymentProcessedEvent(PaymentResponse paymentResponse) {
        try {
            PaymentProcessed__e event = new PaymentProcessed__e(
                PaymentId__c = paymentResponse.transactionId,
                Status__c = paymentResponse.status,
                Amount__c = paymentResponse.amount
            );
            
            EventBus.publish(event);
        } catch (Exception e) {
            System.debug('Error publishing payment event: ' + e.getMessage());
        }
    }
}