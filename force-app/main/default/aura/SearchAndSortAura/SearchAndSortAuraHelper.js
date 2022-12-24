({
    doEvent : function(component) {
        let changeEvent = component.getEvent("changeSort");
        changeEvent.setParams({
            "sortField" : component.get("v.sortField"),
            "isDiscending" : component.get("v.isDiscending")
        });
        changeEvent.fire();
    }
})
