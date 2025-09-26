@isTest
global class PaymentGatewayMockCallout implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        String endpoint = request.getEndpoint();
        String method = request.getMethod();
        
        // Mock payment processing
        if (endpoint.contains('/payments') && method == 'POST') {
            Map<String, Object> responseBody = new Map<String, Object>{
                'transaction_id' => 'TXN_' + String.valueOf(Math.random()).substring(0, 8),
                'status' => 'SUCCESS',
                'message' => 'Payment processed successfully',
                'amount' => 500.00,
                'currency' => 'USD',
                'processed_at' => DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            };
            
            response.setStatusCode(201);
            response.setBody(JSON.serialize(responseBody));
            
        } 
        // Mock refund processing
        else if (endpoint.contains('/refunds') && method == 'POST') {
            Map<String, Object> responseBody = new Map<String, Object>{
                'refund_id' => 'REF_' + String.valueOf(Math.random()).substring(0, 8),
                'status' => 'REFUNDED',
                'message' => 'Refund processed successfully',
                'refund_amount' => 250.00,
                'currency' => 'USD',
                'processed_at' => DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
            };
            
            response.setStatusCode(200);
            response.setBody(JSON.serialize(responseBody));
            
        } 
        // Default error response
        else {
            Map<String, Object> errorResponse = new Map<String, Object>{
                'error' => 'Invalid request',
                'message' => 'The requested endpoint or method is not supported'
            };
            
            response.setStatusCode(400);
            response.setBody(JSON.serialize(errorResponse));
        }
        
        return response;
    }
    
    // Mock for successful payment
    global class SuccessPaymentMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> responseBody = new Map<String, Object>{
                'transaction_id' => 'TXN_SUCCESS_12345',
                'status' => 'SUCCESS',
                'message' => 'Payment processed successfully',
                'amount' => 750.00,
                'currency' => 'USD'
            };
            
            response.setStatusCode(201);
            response.setBody(JSON.serialize(responseBody));
            return response;
        }
    }
    
    // Mock for failed payment
    global class FailedPaymentMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> errorResponse = new Map<String, Object>{
                'error' => 'PAYMENT_FAILED',
                'message' => 'Insufficient funds or invalid card details'
            };
            
            response.setStatusCode(400);
            response.setBody(JSON.serialize(errorResponse));
            return response;
        }
    }
}