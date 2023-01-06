trigger shareObjectTrigger on Share_object__c (before insert, before update) {
    shareObjectTriggerHandler handler = new shareObjectTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.new, Trigger.old);
        }
        else if (Trigger.isInsert) {
            handler.onUpdate(Trigger.new, Trigger.old);
        }
    }
}