trigger userJunctionTrigger on User_Junction__c (before update, after insert) {
    userJunctionTriggerHandler handler = new userJunctionTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onInsert(Trigger.newMap);
        }
    }
}