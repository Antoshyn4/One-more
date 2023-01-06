trigger roleHierarchyTrigger on Role_hierarchy__c (before insert, before update) {
    roleHierarchyTriggerHandler handler = new roleHierarchyTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.new, Trigger.old);
        }
        else if (Trigger.isInsert) {
            handler.onUpdate(Trigger.new, Trigger.old);
        }
    }
}