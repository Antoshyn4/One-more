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
})
