/**
 * @description Batch Apex class for generating monthly booking and revenue reports
 * @author Sachin Bisen
 * @date September 2025
 */
public class BookingReportBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // Instance variables to maintain state across batches
    private Integer totalBookingsProcessed = 0;
    private Decimal totalRevenue = 0.0;
    private Integer totalCompletedBookings = 0;
    private String reportMonth;
    private Date startDate;
    private Date endDate;
    
    // Exception handling
    private List<String> errorMessages = new List<String>();
    
    /**
     * Constructor with date range
     * @param reportMonth Month for the report (YYYY-MM format)
     */
    public BookingReportBatch(String reportMonth) {
        this.reportMonth = reportMonth;
        
        // Parse month and create date range
        if (String.isNotBlank(reportMonth) && reportMonth.contains('-')) {
            List<String> dateParts = reportMonth.split('-');
            if (dateParts.size() == 2) {
                Integer year = Integer.valueOf(dateParts[0]);
                Integer month = Integer.valueOf(dateParts[1]);
                this.startDate = Date.newInstance(year, month, 1);
                this.endDate = Date.newInstance(year, month, Date.daysInMonth(year, month));
            }
        }
        
        // Default to current month if no valid date provided
        if (this.startDate == null) {
            Date today = Date.today();
            this.startDate = Date.newInstance(today.year(), today.month(), 1);
            this.endDate = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
            this.reportMonth = today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0');
        }
    }
    
    /**
     * Start method - defines the scope of records to process
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('BookingReportBatch.start - Processing bookings for: ' + this.reportMonth);
        System.debug('Date range: ' + this.startDate + ' to ' + this.endDate);
        
        // Query all bookings in the specified date range
        return Database.getQueryLocator([
            SELECT Id, Status__c, Start_Date__c, End_Date__c, Total_Amount__c,
                   Equipment__c, Equipment__r.Equipment_Name__c, Equipment__r.Equipment_Type__c,
                   Farmer__c, Farmer__r.Farmer_Name__c,
                   CreatedDate, LastModifiedDate
            FROM Booking__c
            WHERE Start_Date__c >= :startDate
            AND Start_Date__c <= :endDate
            ORDER BY Start_Date__c ASC
        ]);
    }
    
    /**
     * Execute method - processes each batch of records
     * @param bc Database.BatchableContext
     * @param bookings List of Booking__c records to process
     */
    public void execute(Database.BatchableContext bc, List<Booking__c> bookings) {
        System.debug('BookingReportBatch.execute - Processing ' + bookings.size() + ' bookings');
        
        try {
            // Process each booking in the batch
            for (Booking__c booking : bookings) {
                processBooking(booking);
            }
            
            // Update counters
            this.totalBookingsProcessed += bookings.size();
            
            System.debug('Batch processed successfully. Total processed so far: ' + this.totalBookingsProcessed);
            
        } catch (Exception e) {
            String errorMsg = 'Error processing batch: ' + e.getMessage() + ' at line ' + e.getLineNumber();
            System.debug(errorMsg);
            this.errorMessages.add(errorMsg);
            
            // Continue processing other batches even if one fails
        }
    }
    
    /**
     * Finish method - performs cleanup and sends final report
     * @param bc Database.BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('BookingReportBatch.finish - Job completed');
        System.debug('Total bookings processed: ' + this.totalBookingsProcessed);
        System.debug('Total completed bookings: ' + this.totalCompletedBookings);
        System.debug('Total revenue: ' + this.totalRevenue);
        
        try {
            // Generate and save the monthly report
            createMonthlyReport();
            
            // Send email notification to management
            sendReportNotification();
            
            // Chain another job if needed (for quarterly reports, etc.)
            chainNextJob();
            
        } catch (Exception e) {
            String errorMsg = 'Error in finish method: ' + e.getMessage();
            System.debug(errorMsg);
            this.errorMessages.add(errorMsg);
        }
        
        // Log any errors that occurred during processing
        if (!this.errorMessages.isEmpty()) {
            System.debug('Errors encountered during batch processing:');
            for (String error : this.errorMessages) {
                System.debug('- ' + error);
            }
        }
    }
    
    /**
     * Process individual booking record
     * @param booking Booking record to process
     */
    private void processBooking(Booking__c booking) {
        try {
            // Count completed bookings and calculate revenue
            if (booking.Status__c == 'Completed') {
                this.totalCompletedBookings++;
                
                if (booking.Total_Amount__c != null) {
                    this.totalRevenue += booking.Total_Amount__c;
                }
            }
            
            // Additional processing logic can be added here
            // For example: update booking analytics, create summary records, etc.
            
        } catch (Exception e) {
            String errorMsg = 'Error processing booking ' + booking.Id + ': ' + e.getMessage();
            this.errorMessages.add(errorMsg);
        }
    }
    
    /**
     * Create monthly report record
     */
    private void createMonthlyReport() {
        try {
            // Create a custom object record for the monthly report
            // This would require a custom object like Monthly_Report__c
            
            System.debug('Creating monthly report for: ' + this.reportMonth);
            System.debug('Report data - Bookings: ' + this.totalBookingsProcessed + 
                        ', Completed: ' + this.totalCompletedBookings + 
                        ', Revenue: ' + this.totalRevenue);
            
            // In a real implementation, you would insert a report record here
            // Monthly_Report__c report = new Monthly_Report__c(
            //     Report_Month__c = this.reportMonth,
            //     Total_Bookings__c = this.totalBookingsProcessed,
            //     Completed_Bookings__c = this.totalCompletedBookings,
            //     Total_Revenue__c = this.totalRevenue,
            //     Report_Date__c = Date.today()
            // );
            // insert report;
            
        } catch (Exception e) {
            this.errorMessages.add('Error creating monthly report: ' + e.getMessage());
        }
    }
    
    /**
     * Send email notification with report summary
     */
    private void sendReportNotification() {
        try {
            // Send email to managers with report summary
            List<String> managerEmails = getManagerEmails();
            
            if (!managerEmails.isEmpty()) {
                String subject = 'Monthly Booking Report - ' + this.reportMonth;
                String body = buildReportEmailBody();
                
                // In real implementation, use Messaging.SingleEmailMessage
                System.debug('Would send email to: ' + String.join(managerEmails, ', '));
                System.debug('Subject: ' + subject);
                System.debug('Body: ' + body);
            }
            
        } catch (Exception e) {
            this.errorMessages.add('Error sending report notification: ' + e.getMessage());
        }
    }
    
    /**
     * Get manager email addresses
     * @return List of email addresses
     */
    private List<String> getManagerEmails() {
        List<String> emails = new List<String>();
        
        try {
            // Query users with manager profiles
            List<User> managers = [
                SELECT Email
                FROM User
                WHERE Profile.Name IN ('AgriStore Higher Manager', 'AgriStore Rental Manager')
                AND IsActive = true
                AND Email != null
                LIMIT 10
            ];
            
            for (User manager : managers) {
                emails.add(manager.Email);
            }
            
        } catch (Exception e) {
            System.debug('Error querying manager emails: ' + e.getMessage());
        }
        
        return emails;
    }
    
    /**
     * Build email body with report details
     * @return String email body
     */
    private String buildReportEmailBody() {
        String body = 'Dear AgriStore Management Team,\n\n';
        body += 'Please find below the monthly booking report for ' + this.reportMonth + ':\n\n';
        body += 'Total Bookings Processed: ' + this.totalBookingsProcessed + '\n';
        body += 'Completed Bookings: ' + this.totalCompletedBookings + '\n';
        body += 'Total Revenue Generated: $' + this.totalRevenue.setScale(2) + '\n';
        
        if (this.totalBookingsProcessed > 0) {
            Decimal completionRate = (this.totalCompletedBookings * 100.0) / this.totalBookingsProcessed;
            body += 'Completion Rate: ' + completionRate.setScale(1) + '%\n';
        }
        
        body += '\nReport generated on: ' + DateTime.now().format('MMM dd, yyyy \'at\' HH:mm') + '\n\n';
        body += 'Best regards,\nAgriStore Automated Reporting System';
        
        return body;
    }
    
    /**
     * Chain another batch job if needed
     */
    private void chainNextJob() {
        // Example: Chain a quarterly report batch if this is the last month of quarter
        Date currentMonth = this.startDate;
        Integer month = currentMonth.month();
        
        if (Math.mod(month, 3) == 0) { // March, June, September, December
            System.debug('End of quarter detected. Could chain quarterly report batch here.');
            
            // In real implementation:
            // Database.executeBatch(new QuarterlyReportBatch(currentMonth.year(), (month / 3)), 200);
        }
    }
    
    /**
     * Static method to execute the batch with default parameters
     */
    public static void executeMonthlyReport() {
        executeMonthlyReport(null);
    }
    
    /**
     * Static method to execute the batch for a specific month
     * @param reportMonth Month in YYYY-MM format
     */
    public static void executeMonthlyReport(String reportMonth) {
        BookingReportBatch batchJob = new BookingReportBatch(reportMonth);
        Database.executeBatch(batchJob, 200); // Process 200 records per batch
    }
}