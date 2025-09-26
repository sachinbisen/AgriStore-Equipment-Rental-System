/**
 * @description Equipment Management Class for AgriStore
 * @author Sachin Bisen
 * @date September 2025
 */
public with sharing class EquipmentManager {
    
    // Private variables for encapsulation
    private String equipmentId;
    private String equipmentName;
    private String equipmentType;
    private Boolean isAvailable;
    private Decimal rentalRate;
    
    // Static variables for class-level operations
    public static final String TRACTOR_TYPE = 'Tractor';
    public static final String HARVESTER_TYPE = 'Harvester';
    public static final String IRRIGATION_TYPE = 'Irrigation';
    private static final String UNAVAILABLE_STATUS = 'Unavailable';
    
    /**
     * Default Constructor
     */
    public EquipmentManager() {
        this.isAvailable = true;
        this.rentalRate = 0.0;
    }
    
    /**
     * Parameterized Constructor
     * @param name Equipment name
     * @param type Equipment type
     * @param rate Rental rate per day
     */
    public EquipmentManager(String name, String type, Decimal rate) {
        this.equipmentName = name;
        this.equipmentType = type;
        this.rentalRate = rate;
        this.isAvailable = true;
    }
    
    /**
     * Constructor with Equipment record
     * @param equipment Equipment__c record
     */
    public EquipmentManager(Equipment__c equipment) {
        if (equipment != null) {
            this.equipmentId = equipment.Id;
            this.equipmentName = equipment.Equipment_Name__c;
            this.equipmentType = equipment.Equipment_Type__c;
            this.isAvailable = equipment.Availability__c;
            this.rentalRate = equipment.Rental_Rate__c;
        }
    }
    
    // Getter and Setter methods
    public String getEquipmentId() {
        return this.equipmentId;
    }
    
    public void setEquipmentId(String equipmentId) {
        this.equipmentId = equipmentId;
    }
    
    public String getEquipmentName() {
        return this.equipmentName;
    }
    
    public void setEquipmentName(String equipmentName) {
        this.equipmentName = equipmentName;
    }
    
    public String getEquipmentType() {
        return this.equipmentType;
    }
    
    public void setEquipmentType(String equipmentType) {
        this.equipmentType = equipmentType;
    }
    
    public Boolean getAvailability() {
        return this.isAvailable;
    }
    
    public void setAvailability(Boolean isAvailable) {
        this.isAvailable = isAvailable;
    }
    
    public Decimal getRentalRate() {
        return this.rentalRate;
    }
    
    public void setRentalRate(Decimal rentalRate) {
        this.rentalRate = rentalRate;
    }
    
    /**
     * Method to check if equipment is available for booking
     * @return Boolean indicating availability
     */
    public Boolean isAvailableForBooking() {
        return this.isAvailable != null && this.isAvailable;
    }
    
    /**
     * Method to update equipment availability
     * @param available New availability status
     */
    public void updateAvailability(Boolean available) {
        this.isAvailable = available;
        
        // Update the database record if equipment ID exists
        if (String.isNotBlank(this.equipmentId)) {
            try {
                Equipment__c equipmentRecord = new Equipment__c(
                    Id = this.equipmentId,
                    Availability__c = available
                );
                update equipmentRecord;
            } catch (DmlException e) {
                System.debug('Error updating equipment availability: ' + e.getMessage());
                throw new EquipmentException('Failed to update equipment availability: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Method to calculate total rental cost
     * @param startDate Start date of rental
     * @param endDate End date of rental
     * @return Decimal total cost
     */
    public Decimal calculateRentalCost(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) {
            throw new EquipmentException('Start date and end date are required');
        }
        
        if (startDate > endDate) {
            throw new EquipmentException('Start date cannot be after end date');
        }
        
        Integer numberOfDays = startDate.daysBetween(endDate) + 1; // Include both start and end dates
        return this.rentalRate * numberOfDays;
    }
    
    /**
     * Static method to get available equipment by type
     * @param equipmentType Type of equipment to search
     * @return List of available Equipment__c records
     */
    public static List<Equipment__c> getAvailableEquipmentByType(String equipmentType) {
        if (String.isBlank(equipmentType)) {
            return new List<Equipment__c>();
        }
        
        try {
            return [
                SELECT Id, Equipment_Name__c, Equipment_Type__c, Availability__c, Rental_Rate__c
                FROM Equipment__c
                WHERE Equipment_Type__c = :equipmentType
                AND Availability__c = true
                ORDER BY Equipment_Name__c ASC
                LIMIT 200
            ];
        } catch (QueryException e) {
            System.debug('Error querying available equipment: ' + e.getMessage());
            throw new EquipmentException('Failed to retrieve available equipment: ' + e.getMessage());
        }
    }
    
    /**
     * Static method to get all equipment types
     * @return Set of equipment types
     */
    public static Set<String> getAllEquipmentTypes() {
        Set<String> equipmentTypes = new Set<String>();
        
        try {
            List<Equipment__c> equipmentList = [
                SELECT Equipment_Type__c
                FROM Equipment__c
                WHERE Equipment_Type__c != null
                GROUP BY Equipment_Type__c
                LIMIT 100
            ];
            
            for (Equipment__c equipment : equipmentList) {
                equipmentTypes.add(equipment.Equipment_Type__c);
            }
        } catch (QueryException e) {
            System.debug('Error querying equipment types: ' + e.getMessage());
        }
        
        return equipmentTypes;
    }
    
    /**
     * Static method to bulk update equipment availability
     * @param equipmentIds List of equipment IDs to update
     * @param isAvailable New availability status
     */
    public static void bulkUpdateAvailability(List<String> equipmentIds, Boolean isAvailable) {
        if (equipmentIds == null || equipmentIds.isEmpty()) {
            return;
        }
        
        List<Equipment__c> equipmentToUpdate = new List<Equipment__c>();
        
        for (String equipmentId : equipmentIds) {
            if (String.isNotBlank(equipmentId)) {
                equipmentToUpdate.add(new Equipment__c(
                    Id = equipmentId,
                    Availability__c = isAvailable
                ));
            }
        }
        
        if (!equipmentToUpdate.isEmpty()) {
            try {
                update equipmentToUpdate;
            } catch (DmlException e) {
                System.debug('Error in bulk update: ' + e.getMessage());
                throw new EquipmentException('Failed to bulk update equipment availability: ' + e.getMessage());
            }
        }
    }
    
    /**
     * Method to validate equipment data before saving
     * @return Boolean indicating if data is valid
     */
    public Boolean validateEquipmentData() {
        List<String> validationErrors = new List<String>();
        
        if (String.isBlank(this.equipmentName)) {
            validationErrors.add('Equipment name is required');
        }
        
        if (String.isBlank(this.equipmentType)) {
            validationErrors.add('Equipment type is required');
        }
        
        if (this.rentalRate == null || this.rentalRate < 0) {
            validationErrors.add('Rental rate must be a positive number');
        }
        
        if (!validationErrors.isEmpty()) {
            String errorMessage = 'Validation failed: ' + String.join(validationErrors, ', ');
            throw new EquipmentException(errorMessage);
        }
        
        return true;
    }
    
    /**
     * Custom Exception class for Equipment-related errors
     */
    public class EquipmentException extends Exception {}
}