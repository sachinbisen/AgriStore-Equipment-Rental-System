import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getPaymentDashboardData from '@salesforce/apex/PaymentService.getPaymentDashboardData';
import getRecentPayments from '@salesforce/apex/PaymentService.getRecentPayments';
import getFailedPayments from '@salesforce/apex/PaymentService.getFailedPayments';
import processPayment from '@salesforce/apex/PaymentService.processPayment';

export default class PaymentDashboard extends NavigationMixin(LightningElement) {
    @track dashboardData = null;
    @track recentPayments = [];
    @track failedPayments = [];
    @track isLoading = false;
    @track errorMessage = '';
    @track processingPayment = false;
    
    // Modal properties
    @track showFailedModal = false;
    
    // Wire results for refresh
    wiredDashboardResult;
    wiredRecentPaymentsResult;

    // Wire Dashboard Data
    @wire(getPaymentDashboardData)
    wiredDashboardData(result) {
        this.wiredDashboardResult = result;
        const { error, data } = result;
        
        if (data) {
            this.dashboardData = data;
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error loading dashboard data: ' + (error.body?.message || error.message);
            this.dashboardData = null;
        }
    }

    // Wire Recent Payments
    @wire(getRecentPayments, { limitCount: 10 })
    wiredRecentPayments(result) {
        this.wiredRecentPaymentsResult = result;
        this.isLoading = false;
        const { error, data } = result;
        
        if (data) {
            this.recentPayments = this.processPaymentData(data);
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error loading recent payments: ' + (error.body?.message || error.message);
            this.recentPayments = [];
        }
    }

    // Computed Properties
    get paidPaymentsCount() {
        return this.dashboardData?.statusData?.Paid?.count || 0;
    }

    get failedPaymentsCount() {
        return this.dashboardData?.statusData?.Failed?.count || 0;
    }

    get paymentMethodsList() {
        if (!this.dashboardData?.paymentMethods) return [];
        
        return Object.entries(this.dashboardData.paymentMethods).map(([name, count]) => ({
            name: name,
            count: count
        }));
    }

    // Event Handlers
    async refreshData() {
        this.isLoading = true;
        
        try {
            // Refresh both wire adapters
            await Promise.all([
                refreshApex(this.wiredDashboardResult),
                refreshApex(this.wiredRecentPaymentsResult)
            ]);
            
            this.showToast('Success', 'Payment data refreshed successfully', 'success');
        } catch (error) {
            this.showToast('Error', 'Error refreshing data', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async showFailedPayments() {
        try {
            const result = await getFailedPayments();
            this.failedPayments = this.processPaymentData(result);
            this.showFailedModal = true;
        } catch (error) {
            this.showToast('Error', 'Error loading failed payments: ' + error.body.message, 'error');
        }
    }

    closeFailedModal() {
        this.showFailedModal = false;
        this.failedPayments = [];
    }

    navigateToPayment(event) {
        const paymentId = event.target.dataset.paymentId;
        
        // Navigation Service
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: paymentId,
                objectApiName: 'Payment__c',
                actionName: 'view'
            }
        });

        // Dispatch custom event for parent-child communication
        const selectEvent = new CustomEvent('paymentselected', {
            detail: { paymentId: paymentId }
        });
        this.dispatchEvent(selectEvent);
    }

    // Imperative Apex Call for payment retry
    async retryPayment(event) {
        const paymentId = event.target.dataset.paymentId;
        
        if (!paymentId) {
            this.showToast('Error', 'Payment ID not found', 'error');
            return;
        }

        this.processingPayment = true;
        
        try {
            const result = await processPayment({ paymentId: paymentId });
            
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                
                // Refresh data after successful retry
                await this.refreshData();
                
                // Dispatch event to notify parent components
                const retryEvent = new CustomEvent('paymentretried', {
                    detail: { 
                        paymentId: paymentId, 
                        success: true,
                        payment: result.payment 
                    }
                });
                this.dispatchEvent(retryEvent);
                
            } else {
                this.showToast('Warning', result.message, 'warning');
                
                // Dispatch event even for failed retry
                const retryEvent = new CustomEvent('paymentretried', {
                    detail: { 
                        paymentId: paymentId, 
                        success: false 
                    }
                });
                this.dispatchEvent(retryEvent);
            }
            
        } catch (error) {
            this.showToast('Error', 'Error processing payment: ' + error.body.message, 'error');
        } finally {
            this.processingPayment = false;
        }
    }

    // Helper Methods
    processPaymentData(payments) {
        return payments.map(payment => {
            return {
                ...payment,
                formattedDate: this.formatDate(payment.Payment_Date__c),
                statusVariant: this.getStatusVariant(payment.Status__c),
                canRetry: payment.Status__c === 'Failed'
            };
        });
    }

    formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        return date.toLocaleDateString();
    }

    getStatusVariant(status) {
        switch (status) {
            case 'Paid':
                return 'success';
            case 'Pending':
                return 'warning';
            case 'Failed':
                return 'error';
            default:
                return 'base';
        }
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    // Lifecycle Hooks
    connectedCallback() {
        this.isLoading = true;
    }

    disconnectedCallback() {
        // Cleanup if needed
    }

    // Public API Methods
    async refreshDashboard() {
        return this.refreshData();
    }

    getDashboardData() {
        return this.dashboardData;
    }

    getRecentPayments() {
        return this.recentPayments;
    }
}