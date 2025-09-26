/**
 * @description Service class for Payment LWC components
 * @author Sachin Bisen
 * @date September 2025
 */
public with sharing class PaymentService {
    
    /**
     * Get payment dashboard data
     * @return Map with payment statistics
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPaymentDashboardData() {
        try {
            Map<String, Object> dashboardData = new Map<String, Object>();
            
            // Total payments
            Integer totalPayments = [SELECT COUNT() FROM Payment__c];
            dashboardData.put('totalPayments', totalPayments);
            
            // Payments by status
            List<AggregateResult> statusResults = [
                SELECT Status__c, COUNT(Id) count, SUM(Amount__c) amount
                FROM Payment__c
                GROUP BY Status__c
            ];
            
            Map<String, Object> statusData = new Map<String, Object>();
            Decimal totalRevenue = 0;
            for (AggregateResult result : statusResults) {
                Map<String, Object> status = new Map<String, Object>();
                status.put('count', result.get('count'));
                status.put('amount', result.get('amount'));
                statusData.put((String) result.get('Status__c'), status);
                
                if ('Paid'.equals(result.get('Status__c'))) {
                    totalRevenue = (Decimal) result.get('amount');
                }
            }
            dashboardData.put('statusData', statusData);
            dashboardData.put('totalRevenue', totalRevenue != null ? totalRevenue : 0);
            
            // Monthly revenue (current year)
            List<AggregateResult> monthlyResults = [
                SELECT CALENDAR_MONTH(Payment_Date__c) month, SUM(Amount__c) revenue
                FROM Payment__c
                WHERE Status__c = 'Paid'
                AND CALENDAR_YEAR(Payment_Date__c) = :Date.today().year()
                GROUP BY CALENDAR_MONTH(Payment_Date__c)
                ORDER BY CALENDAR_MONTH(Payment_Date__c)
            ];
            
            List<Map<String, Object>> monthlyRevenue = new List<Map<String, Object>>();
            for (AggregateResult result : monthlyResults) {
                Map<String, Object> monthData = new Map<String, Object>();
                monthData.put('month', result.get('month'));
                monthData.put('revenue', result.get('revenue'));
                monthlyRevenue.add(monthData);
            }
            dashboardData.put('monthlyRevenue', monthlyRevenue);
            
            // Payment methods
            List<AggregateResult> methodResults = [
                SELECT Payment_Method__c, COUNT(Id) count
                FROM Payment__c
                WHERE Status__c = 'Paid'
                GROUP BY Payment_Method__c
            ];
            
            Map<String, Integer> methodCounts = new Map<String, Integer>();
            for (AggregateResult result : methodResults) {
                methodCounts.put((String) result.get('Payment_Method__c'), (Integer) result.get('count'));
            }
            dashboardData.put('paymentMethods', methodCounts);
            
            return dashboardData;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching payment dashboard data: ' + e.getMessage());
        }
    }
    
    /**
     * Get recent payments
     * @param limitCount Number of records to return
     * @return List of recent payments
     */
    @AuraEnabled(cacheable=true)
    public static List<Payment__c> getRecentPayments(Integer limitCount) {
        try {
            Integer recordLimit = limitCount != null ? limitCount : 20;
            
            return [
                SELECT Id, Name, Amount__c, Status__c, Payment_Date__c, Payment_Method__c,
                       Booking__c, Booking__r.Name, Booking__r.Farmer__r.Farmer_Name__c
                FROM Payment__c
                ORDER BY CreatedDate DESC
                LIMIT :recordLimit
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching recent payments: ' + e.getMessage());
        }
    }
    
    /**
     * Get failed payments for retry
     * @return List of failed payments
     */
    @AuraEnabled(cacheable=true)
    public static List<Payment__c> getFailedPayments() {
        try {
            return [
                SELECT Id, Name, Amount__c, Status__c, Payment_Date__c, Payment_Method__c,
                       Booking__c, Booking__r.Name, Booking__r.Farmer__r.Farmer_Name__c
                FROM Payment__c
                WHERE Status__c = 'Failed'
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching failed payments: ' + e.getMessage());
        }
    }
    
    /**
     * Process payment
     * @param paymentId Payment ID to process
     * @return Processing result
     */
    @AuraEnabled
    public static Map<String, Object> processPayment(String paymentId) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            
            // Get payment record
            Payment__c payment = [
                SELECT Id, Amount__c, Payment_Method__c, Status__c, Booking__c
                FROM Payment__c
                WHERE Id = :paymentId
                FOR UPDATE
            ];
            
            // Simulate payment processing
            Boolean success = simulatePaymentProcessing();
            
            if (success) {
                payment.Status__c = 'Paid';
                payment.Payment_Date__c = Date.today();
                result.put('success', true);
                result.put('message', 'Payment processed successfully');
            } else {
                payment.Status__c = 'Failed';
                result.put('success', false);
                result.put('message', 'Payment processing failed');
            }
            
            update payment;
            result.put('payment', payment);
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error processing payment: ' + e.getMessage());
        }
    }
    
    /**
     * Get payment trends
     * @param months Number of months to analyze
     * @return Payment trend data
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPaymentTrends(Integer months) {
        try {
            Integer monthsToAnalyze = months != null ? months : 6;
            Date startDate = Date.today().addMonths(-monthsToAnalyze);
            
            Map<String, Object> trends = new Map<String, Object>();
            
            // Monthly trends
            List<AggregateResult> monthlyTrends = [
                SELECT CALENDAR_MONTH(Payment_Date__c) month, 
                       CALENDAR_YEAR(Payment_Date__c) year,
                       COUNT(Id) count, SUM(Amount__c) amount
                FROM Payment__c
                WHERE Status__c = 'Paid'
                AND Payment_Date__c >= :startDate
                GROUP BY CALENDAR_MONTH(Payment_Date__c), CALENDAR_YEAR(Payment_Date__c)
                ORDER BY CALENDAR_YEAR(Payment_Date__c), CALENDAR_MONTH(Payment_Date__c)
            ];
            
            List<Map<String, Object>> trendData = new List<Map<String, Object>>();
            for (AggregateResult result : monthlyTrends) {
                Map<String, Object> trend = new Map<String, Object>();
                trend.put('month', result.get('month'));
                trend.put('year', result.get('year'));
                trend.put('count', result.get('count'));
                trend.put('amount', result.get('amount'));
                trendData.add(trend);
            }
            trends.put('monthlyTrends', trendData);
            
            return trends;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching payment trends: ' + e.getMessage());
        }
    }
    
    /**
     * Simulate payment processing (for demo purposes)
     * @return Boolean indicating success
     */
    private static Boolean simulatePaymentProcessing() {
        // Simulate 80% success rate
        Integer randomNum = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);
        return randomNum < 8;
    }
}