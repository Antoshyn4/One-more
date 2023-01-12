trigger roleHierarchyTrigger on Role_hierarchy__c (before insert, after update) {
    roleHierarchyTriggerHandler handler = new roleHierarchyTriggerHandler();
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.newMap, Trigger.oldMap);
        }
        // else if (Trigger.isInsert) {
        //     handler.onInsert(Trigger.new, Trigger.old);
        // }
    }
}