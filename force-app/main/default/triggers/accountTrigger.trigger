trigger accountTrigger on Account (before update) {
    accountTriggerHandler ach = new accountTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            ach.onBeforeUpdate(Trigger.old, Trigger.new);
        }
    } else {
        
    }
}