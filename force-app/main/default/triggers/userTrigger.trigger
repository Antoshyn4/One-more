trigger userTrigger on User (after insert, before update, before delete) {
    userTriggerHandler handler = new userTriggerHandler();
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            handler.onUpdate(Trigger.new, Trigger.old);
        }
        else if (Trigger.isDelete) {
            handler.onDelete(Trigger.new, Trigger.old);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onInsert(Trigger.new, Trigger.old);
        }
    }
}