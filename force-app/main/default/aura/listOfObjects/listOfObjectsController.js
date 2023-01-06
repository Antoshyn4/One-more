({
    handleSectionToggle : function(component, event, helper) {
        
    },
    doPopUp : function(component, event, helper) { 
        let getAllRecords = component.get("c.getAllAccountRecords");
        let parrentId = event.currentTarget.dataset.id;
        debugger;
        let getName = component.get("c.getNameById");
        getName.setParams({
            "objectId" : event.currentTarget.dataset.id
        });
        getName.setCallback(this, function(response) {
            let state = response.getState();
            debugger;
            if (state === "SUCCESS") {
                component.set("v.name", response.getReturnValue());
                $A.enqueueAction(getAllRecords);
            }
        });
        getAllRecords.setParams({
            'accid' : parrentId
        });
        getAllRecords.setCallback(this, function(response) {
            let state = response.getState();
            debugger;
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                let values = Object.values(result);
                let keys = Object.keys(result);
                let myOptions = [];
                let Id;
                for (let i = 0; i < values.length; i++) {
                    let ob = {};
                    ob['label'] = keys[i];
                    ob['value'] = values[i];
                    if (keys[i] == 'Id') {
                        Id = values[i];
                    }
                    myOptions.push(ob);
                }
                component.set("v.options", myOptions);
                component.set("v.recordId", Id);
                component.set("v.isModalOpen", true);
            }
        });
        $A.enqueueAction(getName);
    }
})
