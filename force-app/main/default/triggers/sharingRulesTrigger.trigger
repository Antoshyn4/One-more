trigger sharingRulesTrigger on Sharing_rules__c (before insert, before update) {
    sharingRulesTriggerHandler handler = new sharingRulesTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.new, Trigger.old);
        }
        else if (Trigger.isInsert) {
            handler.onUpdate(Trigger.new, Trigger.old);
        }
    }
}