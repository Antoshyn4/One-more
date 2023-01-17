trigger roleHierarchyTrigger on Role_hierarchy__c (before insert, before update) {
    roleHierarchyTriggerHandler handler = new roleHierarchyTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.newMap, Trigger.oldMap);
        }
        // else if (Trigger.isInsert) {
        //     handler.onInsert(Trigger.new, Trigger.old);
        // }
    }
}