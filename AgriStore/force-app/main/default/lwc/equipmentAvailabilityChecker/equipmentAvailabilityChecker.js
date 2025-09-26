import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableEquipment from '@salesforce/apex/EquipmentService.getAvailableEquipment';
import getAllEquipment from '@salesforce/apex/EquipmentService.getAllEquipment';
import getEquipmentTypes from '@salesforce/apex/EquipmentService.getEquipmentTypes';
import checkAvailability from '@salesforce/apex/EquipmentService.checkAvailability';

export default class EquipmentAvailabilityChecker extends NavigationMixin(LightningElement) {
    @track equipment = [];
    @track equipmentTypeOptions = [{ label: 'All Types', value: '' }];
    @track selectedEquipmentType = '';
    @track isLoading = false;
    @track errorMessage = '';
    
    // Modal properties
    @track showAvailabilityModal = false;
    @track selectedEquipmentDetails = null;
    @track checkStartDate = '';
    @track checkEndDate = '';
    @track availabilityResult = null;
    @track checkingAvailability = false;

    // Wire Equipment Types
    @wire(getEquipmentTypes)
    wiredEquipmentTypes({ error, data }) {
        if (data) {
            this.equipmentTypeOptions = [
                { label: 'All Types', value: '' },
                ...data.map(type => ({ label: type, value: type }))
            ];
        } else if (error) {
            console.error('Error loading equipment types:', error);
        }
    }

    // Wire Equipment Data
    @wire(getAllEquipment)
    wiredEquipment({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.equipment = this.processEquipmentData(data);
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage = 'Error loading equipment: ' + (error.body?.message || error.message);
            this.equipment = [];
        }
    }

    // Computed Properties
    get hasEquipment() {
        return this.equipment && this.equipment.length > 0;
    }

    get filteredEquipment() {
        if (!this.selectedEquipmentType) {
            return this.equipment;
        }
        return this.equipment.filter(item => 
            item.Equipment_Type__c === this.selectedEquipmentType
        );
    }

    // Event Handlers
    handleEquipmentTypeChange(event) {
        this.selectedEquipmentType = event.detail.value;
    }

    navigateToEquipment(event) {
        const equipmentId = event.target.dataset.equipmentId;
        
        // Navigation Service
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: equipmentId,
                objectApiName: 'Equipment__c',
                actionName: 'view'
            }
        });

        // Dispatch event for parent components
        const selectEvent = new CustomEvent('equipmentselected', {
            detail: { equipmentId: equipmentId }
        });
        this.dispatchEvent(selectEvent);
    }

    checkDetailedAvailability(event) {
        const equipmentId = event.target.dataset.equipmentId;
        const selectedEquipment = this.equipment.find(item => item.Id === equipmentId);
        
        if (selectedEquipment) {
            this.selectedEquipmentDetails = selectedEquipment;
            this.showAvailabilityModal = true;
            
            // Set default dates (today to 7 days from now)
            const today = new Date();
            const nextWeek = new Date();
            nextWeek.setDate(today.getDate() + 7);
            
            this.checkStartDate = today.toISOString().split('T')[0];
            this.checkEndDate = nextWeek.toISOString().split('T')[0];
            this.availabilityResult = null;
        }
    }

    closeModal() {
        this.showAvailabilityModal = false;
        this.selectedEquipmentDetails = null;
        this.availabilityResult = null;
    }

    handleCheckStartDateChange(event) {
        this.checkStartDate = event.target.value;
    }

    handleCheckEndDateChange(event) {
        this.checkEndDate = event.target.value;
    }

    // Imperative Apex Call
    async performAvailabilityCheck() {
        if (!this.checkStartDate || !this.checkEndDate) {
            this.showToast('Error', 'Please select both start and end dates', 'error');
            return;
        }

        if (new Date(this.checkStartDate) > new Date(this.checkEndDate)) {
            this.showToast('Error', 'Start date cannot be after end date', 'error');
            return;
        }

        this.checkingAvailability = true;
        
        try {
            const result = await checkAvailability({
                equipmentId: this.selectedEquipmentDetails.Id,
                startDate: this.checkStartDate,
                endDate: this.checkEndDate
            });

            // Process conflicts data
            if (result.conflicts) {
                result.conflicts = result.conflicts.map(conflict => ({
                    ...conflict,
                    formattedStartDate: this.formatDate(conflict.Start_Date__c),
                    formattedEndDate: this.formatDate(conflict.End_Date__c)
                }));
            }

            this.availabilityResult = result;
            
            // Show success toast
            if (!result.hasConflicts) {
                this.showToast('Success', 'Equipment is available for selected dates', 'success');
            }
            
        } catch (error) {
            this.errorMessage = 'Error checking availability: ' + error.body.message;
            this.showToast('Error', this.errorMessage, 'error');
        } finally {
            this.checkingAvailability = false;
        }
    }

    // Helper Methods
    processEquipmentData(equipmentList) {
        return equipmentList.map(item => {
            const isAvailable = item.Availability__c === true;
            return {
                ...item,
                availabilityLabel: isAvailable ? 'Available' : 'Unavailable',
                availabilityVariant: isAvailable ? 'success' : 'error',
                isUnavailable: !isAvailable
            };
        });
    }

    formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        return date.toLocaleDateString();
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

    // Public API methods
    refreshData() {
        this.isLoading = true;
        // Wire adapters will automatically refresh
    }

    filterByType(equipmentType) {
        this.selectedEquipmentType = equipmentType;
    }
}