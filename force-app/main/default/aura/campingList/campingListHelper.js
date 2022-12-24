({
    createItem : function(component, Camping) {
        let action = component.get("c.saveItem");
        action.setParams({
            "item": Camping
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
    }
})
