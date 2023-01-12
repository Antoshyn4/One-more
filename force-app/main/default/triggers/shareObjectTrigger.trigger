trigger shareObjectTrigger on Share_object__c (after insert, after update) {
    shareObjectTriggerHandler handler = new shareObjectTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onInsert(Trigger.newMap);
        }
    }
}