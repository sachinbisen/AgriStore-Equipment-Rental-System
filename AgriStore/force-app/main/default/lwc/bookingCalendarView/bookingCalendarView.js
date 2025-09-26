import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBookingsForCalendar from '@salesforce/apex/BookingService.getBookingsForCalendar';

export default class BookingCalendarView extends NavigationMixin(LightningElement) {
    @track bookings = [];
    @track isLoading = false;
    @track errorMessage = '';
    
    // Default to current month
    startDate = this.getFirstDayOfMonth();
    endDate = this.getLastDayOfMonth();

    // Wire Adapter with reactive properties
    @wire(getBookingsForCalendar, { 
        startDate: '$startDate', 
        endDate: '$endDate' 
    })
    wiredBookings({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.bookings = this.processBookingData(data);
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error loading bookings: ' + (error.body?.message || error.message);
            this.bookings = [];
        }
    }

    // Computed Properties
    get hasBookings() {
        return this.bookings && this.bookings.length > 0;
    }

    // Event Handlers
    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.isLoading = true;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.isLoading = true;
    }

    navigateToBooking(event) {
        const bookingId = event.target.dataset.bookingId;
        
        // Navigation Service - Navigate to record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: bookingId,
                objectApiName: 'Booking__c',
                actionName: 'view'
            }
        });

        // Dispatch custom event for parent-child communication
        const selectEvent = new CustomEvent('bookingselected', {
            detail: { bookingId: bookingId }
        });
        this.dispatchEvent(selectEvent);
    }

    // Helper Methods
    getFirstDayOfMonth() {
        const now = new Date();
        const firstDay = new Date(now.getFullYear(), now.getMonth(), 1);
        return firstDay.toISOString().split('T')[0];
    }

    getLastDayOfMonth() {
        const now = new Date();
        const lastDay = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        return lastDay.toISOString().split('T')[0];
    }

    processBookingData(bookings) {
        return bookings.map(booking => {
            return {
                ...booking,
                formattedStartDate: this.formatDate(booking.Start_Date__c),
                formattedEndDate: this.formatDate(booking.End_Date__c),
                statusVariant: this.getStatusVariant(booking.Status__c)
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
            case 'Confirmed':
                return 'success';
            case 'Pending':
                return 'warning';
            case 'Cancelled':
                return 'error';
            case 'Completed':
                return 'success';
            default:
                return 'base';
        }
    }

    // Lifecycle Hooks
    connectedCallback() {
        this.isLoading = true;
    }

    // Public Methods (can be called from parent components)
    refreshData() {
        this.isLoading = true;
        // The wire adapter will automatically refresh when loading state changes
        return refreshApex(this.wiredBookingsResult);
    }
}