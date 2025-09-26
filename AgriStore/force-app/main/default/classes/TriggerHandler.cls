/**
 * @description Base Trigger Handler Class for AgriStore
 * @author Sachin Bisen
 * @date September 2025
 */
public abstract class TriggerHandler {
    
    // Static map to prevent recursion
    private static Map<String, Boolean> bypassedHandlers = new Map<String, Boolean>();
    
    // Instance variables
    private String handlerName;
    
    /**
     * Constructor
     */
    public TriggerHandler() {
        this.handlerName = this.toString().substring(0, this.toString().indexOf(':'));
    }
    
    /**
     * Main execution method called by triggers
     */
    public void execute() {
        // Check if this handler is bypassed
        if (isBypassed()) {
            return;
        }
        
        // Execute appropriate handler method based on trigger context
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                beforeInsert();
            } else if (Trigger.isUpdate) {
                beforeUpdate();
            } else if (Trigger.isDelete) {
                beforeDelete();
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                afterInsert();
            } else if (Trigger.isUpdate) {
                afterUpdate();
            } else if (Trigger.isDelete) {
                afterDelete();
            } else if (Trigger.isUndelete) {
                afterUndelete();
            }
        }
    }
    
    /**
     * Virtual methods that can be overridden in concrete handlers
     */
    public virtual void beforeInsert() {}
    public virtual void beforeUpdate() {}
    public virtual void beforeDelete() {}
    public virtual void afterInsert() {}
    public virtual void afterUpdate() {}
    public virtual void afterDelete() {}
    public virtual void afterUndelete() {}
    
    /**
     * Method to bypass this handler
     */
    public void bypass() {
        bypassedHandlers.put(this.handlerName, true);
    }
    
    /**
     * Method to clear bypass for this handler
     */
    public void clearBypass() {
        bypassedHandlers.put(this.handlerName, false);
    }
    
    /**
     * Method to check if this handler is bypassed
     * @return Boolean indicating if handler is bypassed
     */
    public Boolean isBypassed() {
        return bypassedHandlers.containsKey(this.handlerName) && 
               bypassedHandlers.get(this.handlerName);
    }
    
    /**
     * Static method to bypass a handler by name
     * @param handlerName Name of the handler to bypass
     */
    public static void bypass(String handlerName) {
        bypassedHandlers.put(handlerName, true);
    }
    
    /**
     * Static method to clear bypass for a handler by name
     * @param handlerName Name of the handler to clear bypass
     */
    public static void clearBypass(String handlerName) {
        bypassedHandlers.put(handlerName, false);
    }
    
    /**
     * Static method to clear all bypasses
     */
    public static void clearAllBypasses() {
        bypassedHandlers.clear();
    }
}