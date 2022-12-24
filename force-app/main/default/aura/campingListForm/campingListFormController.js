({
    clickCreateItem : function(component, event, helper) {
        let validCamping = component.find('campingform').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (validCamping) {
            let newCamping = component.get("v.newItem");
            console.log("Create expense: " + JSON.stringify(newExpense));
            helper.createItem(component, newCamping);
            
        }
    }
})
