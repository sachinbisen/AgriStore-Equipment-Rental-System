/**
 * @description Trigger on Booking__c object for AgriStore
 * @author Sachin Bisen
 * @date September 2025
 */
trigger BookingTrigger on Booking__c (before insert, before update, before delete,
                                      after insert, after update, after delete, after undelete) {
    
    // Trigger Handler Pattern - delegate to handler class
    BookingTriggerHandler handler = new BookingTriggerHandler();
    
    // Before Events
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.new, Trigger.old, Trigger.oldMap);
        }
        else if (Trigger.isDelete) {
            handler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
    }
    
    // After Events
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.new, Trigger.newMap);
        }
        else if (Trigger.isUpdate) {
            handler.afterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
        else if (Trigger.isDelete) {
            handler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        else if (Trigger.isUndelete) {
            handler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
}