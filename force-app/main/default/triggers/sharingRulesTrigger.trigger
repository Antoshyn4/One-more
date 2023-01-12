trigger sharingRulesTrigger on Sharing_rules__c (after insert, after update) {
    sharingRulesTriggerHandler handler = new sharingRulesTriggerHandler();
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onINsert(Trigger.newMap);
        }
    }
}