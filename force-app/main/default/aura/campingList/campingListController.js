({
    handleAddItem  : function(component, event, helper) {
        let newItem = event.getParam("item");
        let item = JSON.parse(JSON.stringify(newItem));
        let action = component.get("c.saveItem");
        action.setParams({
            "item": item
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let theCampings = component.get("v.items");
                theCampings.push(newCamping);
                component.set("v.items", theCampings);
            }
        });
        $A.enqueueAction(action);
    },
    doInit : function(component, event, helper){
        let action = component.get("c.getItems");
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.items", response.getReturnValue());
            }
            else {
                console.log('Error');
            }
        })
        $A.enqueueAction(action);
    }
})
