({
    createItem  : function(component, Camping) {
        let event = component.getEvent("addItem");
        event.setParams({"item": Camping});
        event.fire();
        component.set("v.newItem", { 
            'sObjectType': 'Camping_Item__c',
            'Quantity__c': 0,
            'Price__c': 0,
            'Packed__c': false });
    }
})
