/**
 * @description Service class for Equipment LWC components
 * @author Sachin Bisen
 * @date September 2025
 */
public with sharing class EquipmentService {
    
    /**
     * Get available equipment
     * @param equipmentType Optional filter by equipment type
     * @return List of available equipment
     */
    @AuraEnabled(cacheable=true)
    public static List<Equipment__c> getAvailableEquipment(String equipmentType) {
        try {
            String query = 'SELECT Id, Equipment_Name__c, Equipment_Type__c, Availability__c, Rental_Rate__c ' +
                          'FROM Equipment__c ' +
                          'WHERE Availability__c = true';
            
            if (String.isNotBlank(equipmentType)) {
                query += ' AND Equipment_Type__c = :equipmentType';
            }
            
            query += ' ORDER BY Equipment_Name__c ASC LIMIT 200';
            
            return Database.query(query);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching available equipment: ' + e.getMessage());
        }
    }
    
    /**
     * Get all equipment with availability status
     * @return List of all equipment
     */
    @AuraEnabled(cacheable=true)
    public static List<Equipment__c> getAllEquipment() {
        try {
            return [
                SELECT Id, Equipment_Name__c, Equipment_Type__c, Availability__c, Rental_Rate__c
                FROM Equipment__c
                ORDER BY Equipment_Name__c ASC
                LIMIT 200
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching equipment: ' + e.getMessage());
        }
    }
    
    /**
     * Check equipment availability for date range
     * @param equipmentId Equipment ID
     * @param startDate Start date
     * @param endDate End date
     * @return Availability check result
     */
    @AuraEnabled
    public static Map<String, Object> checkAvailability(String equipmentId, Date startDate, Date endDate) {
        try {
            Map<String, Object> result = new Map<String, Object>();
            
            // Get equipment details
            Equipment__c equipment = [
                SELECT Id, Equipment_Name__c, Equipment_Type__c, Availability__c, Rental_Rate__c
                FROM Equipment__c
                WHERE Id = :equipmentId
            ];
            
            result.put('equipment', equipment);
            
            // Check for conflicts
            List<Booking__c> conflicts = [
                SELECT Id, Name, Start_Date__c, End_Date__c, Status__c
                FROM Booking__c
                WHERE Equipment__c = :equipmentId
                AND Status__c IN ('Pending', 'Confirmed')
                AND ((Start_Date__c <= :startDate AND End_Date__c >= :startDate)
                    OR (Start_Date__c <= :endDate AND End_Date__c >= :endDate)
                    OR (Start_Date__c >= :startDate AND End_Date__c <= :endDate))
            ];
            
            result.put('hasConflicts', !conflicts.isEmpty());
            result.put('conflicts', conflicts);
            
            // Calculate cost if available
            if (conflicts.isEmpty()) {
                Integer days = startDate.daysBetween(endDate) + 1;
                Decimal totalCost = equipment.Rental_Rate__c * days;
                result.put('totalCost', totalCost);
                result.put('days', days);
            }
            
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error checking availability: ' + e.getMessage());
        }
    }
    
    /**
     * Get equipment types for filter
     * @return List of equipment types
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getEquipmentTypes() {
        try {
            List<String> types = new List<String>();
            
            List<AggregateResult> results = [
                SELECT Equipment_Type__c
                FROM Equipment__c
                WHERE Equipment_Type__c != null
                GROUP BY Equipment_Type__c
                ORDER BY Equipment_Type__c
            ];
            
            for (AggregateResult result : results) {
                types.add((String) result.get('Equipment_Type__c'));
            }
            
            return types;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching equipment types: ' + e.getMessage());
        }
    }
    
    /**
     * Get equipment utilization statistics
     * @return Map with utilization data
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEquipmentUtilization() {
        try {
            Map<String, Object> stats = new Map<String, Object>();
            
            // Total equipment count
            Integer totalEquipment = [SELECT COUNT() FROM Equipment__c];
            stats.put('totalEquipment', totalEquipment);
            
            // Available equipment count
            Integer availableEquipment = [SELECT COUNT() FROM Equipment__c WHERE Availability__c = true];
            stats.put('availableEquipment', availableEquipment);
            
            // Equipment by type
            List<AggregateResult> typeResults = [
                SELECT Equipment_Type__c, COUNT(Id) count, 
                       COUNT_DISTINCT(CASE WHEN Availability__c = true THEN Id END) available
                FROM Equipment__c
                GROUP BY Equipment_Type__c
            ];
            
            List<Map<String, Object>> typeData = new List<Map<String, Object>>();
            for (AggregateResult result : typeResults) {
                Map<String, Object> type = new Map<String, Object>();
                type.put('type', result.get('Equipment_Type__c'));
                type.put('total', result.get('count'));
                type.put('available', result.get('available'));
                typeData.add(type);
            }
            stats.put('equipmentByType', typeData);
            
            return stats;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching equipment utilization: ' + e.getMessage());
        }
    }
}