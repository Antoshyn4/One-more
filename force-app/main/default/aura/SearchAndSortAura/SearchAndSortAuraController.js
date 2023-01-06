({
    handleComboboxChange : function(component, event, helper) {
        let combobox = event.getSource();
        let value = combobox.get("v.value");
        component.set("v.sortField",value);
        helper.doEvent(component);
    },
    handleAsc : function(component, event, helper) {
        component.set("v.isDiscending",false);
        helper.doEvent(component);
    },
    handleDesc : function(component, event, helper) {
        component.set("v.isDiscending",true);
        helper.doEvent(component);
    },
    doSearchFun : function(component, event, helper) {
        let input = event.getSource();
        let search = input.get("v.value");
        if (search.length >= 2) {
            component.set("v.searchText", search);
            let searchEvent = component.getEvent("doSearch");
            searchEvent.setParams({
                "Search" : search
            });
            searchEvent.fire();
        }
        else if (search.length == 0){
            let searchEvent = component.getEvent("doSearch");
            searchEvent.setParams({
                "Search" : ""
            });
            searchEvent.fire();
        }
    },
})
