({
    myAction : function(component, event, helper) {

    },
    packItem : function(component, event, helper) {
        component.set("v.item.Packed__c", true);
        let btn = event.getSource();
        btn.set("v.disabled", true);
    }
})
