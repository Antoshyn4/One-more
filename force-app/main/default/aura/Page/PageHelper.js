({
    quickSort : function(component, origArray){
        if (origArray.length <= 1) { 
            return origArray;
        } 
        else {
            var left = [];
            var right = [];
            var newArray = [];  
            var pivot = origArray.pop();
            var length = origArray.length;
            var sortField = component.get("v.sortField");
            for (var i = 0; i < length; i++) {
                if (component.get("v.sortedByDescending") ? origArray[i][sortField] <= pivot[sortField] : origArray[i][sortField] >= pivot[sortField]) {
                    left.push(origArray[i]);
                } else {
                    right.push(origArray[i]);
                }
            }
            return newArray.concat(this.quickSort(component, left), pivot, this.quickSort(component, right));
        }
    },
    initialize : function(component, helper) {
        component.set("v.isFirstPage", "true");
        let getObjectsAction = component.get("c.getAccountList");
        let getSortAction = component.get("c.getSortSettings");
        let getPageSettings = component.get("c.getCustomSettings");
        component.set("v.PageNumber",1);
        
        getObjectsAction.setCallback(this, function(response) {
            debugger;
            let state = response.getState();
            if (state === 'SUCCESS') {
                let result = response.getReturnValue();
                let temp = []; 
                let ob = {};
                for (const key in result) {
                    ob = result[key];
                    ob['isAccount'] = true;
                    temp.push(ob);
                }
                component.set("v.listOfObjects", temp);
                if (component.get("v.listOfObjects").length < component.get("v.countOfAllElements")) {
                    component.set("v.PageCount", Math.ceil(component.get("v.listOfObjects").length/component.get("v.countOfPageElements")));
                }   
                $A.enqueueAction(getSortAction);
            }
        });
        getSortAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.sortField", result.SortBy__c);
                component.set("v.sortedByDescending", result.isDesc__c == 'DESC' ? true : false);
                let inputArr = component.get("v.listOfObjects");
                component.set("v.listOfObjects", helper.quickSort(component, inputArr));
                helper.changeOnPageElements(component);
            }
        })
        getPageSettings.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                if (result.All_elements_count__c <= 0 || result.On_page_elements_count__c <= 0 || result.Columns_count__c <= 0) {
                    alert("Incorrect page settings");
                }
                else { 
                    component.set("v.ErrorMessage", result.Error_message__c);
                    component.set("v.ParentName",result.Parent__c);
                    component.set("v.ChildName", result.Child__c);
                    component.set("v.isCase", result.Child__c == 'Cases' ? true : false);
                    component.set("v.countOfAllElements",result.All_elements_count__c);
                    component.set("v.countOfColumns",result.Columns_count__c);
                    component.set("v.countOfPageElements", result.On_page_elements_count__c);
                    component.set("v.PageCount", Math.ceil(component.get("v.countOfAllElements")/component.get("v.countOfPageElements")));
                    component.set("v.isLastPage", component.get("v.PageNumber") == component.get("v.PageCount"));
                    component.set("v.isNotSingle", component.get("v.PageCount") > 1);
                    getObjectsAction.setParams({
                        "parentName": component.get("v.ParentName"),
                        "childName": component.get("v.ChildName")
                    });
                    $A.enqueueAction(getObjectsAction);
                }
            }
        })
        $A.enqueueAction(getPageSettings);
    },
    changeOnPageElements : function(component) {
        let startIndex = (component.get("v.PageNumber") - 1) * component.get("v.countOfPageElements");
        let temp2 = [];
        let countOfColumns = component.get("v.countOfColumns");
        let listOfAllElements = component.get("v.listOfObjects");
        let countOfPageElements = component.get("v.countOfPageElements");
        let Parent = component.get("v.ParentName");
        let Child = component.get("v.ChildName");
        for (let i = 0; i < countOfColumns; i++){
            let object = {};
            object['type'] = '';
            object['value'] = [];
             for (let z = 0; z < Math.ceil(countOfPageElements/countOfColumns); z++) {
                if (z + 1 < Math.ceil(countOfPageElements/countOfColumns) || 
                (countOfPageElements % countOfColumns == 0 || 
                    i + 1 <= countOfPageElements % countOfColumns)) {
                    let inObject = {};
                    if (listOfAllElements[startIndex + i + z * countOfColumns]) {
                        inObject['Name'] = listOfAllElements[startIndex + i + z * countOfColumns].Name;
                        inObject['Id'] = listOfAllElements[startIndex + i + z * countOfColumns].Id;
                        debugger;
                        inObject['Contacts'] = listOfAllElements[startIndex + i + z * countOfColumns][component.get("v.ChildName")];
                        inObject['isAccount'] = listOfAllElements[startIndex + i + z * countOfColumns].isAccount;
                        if (listOfAllElements[startIndex + i + z * countOfColumns][component.get("v.ChildName")] != undefined) {
                            inObject['Num'] = listOfAllElements[startIndex + i + z * countOfColumns][Child].length;
                            inObject['Count'] = "Count of " + Child + ": " + inObject['Num'];
                        }
                        else {
                            inObject['Contacts'] = [];
                            inObject['Num'] = 0;
                            inObject['Count'] = "Count of " + Child + ": " +  0;
                        }
                    }
                    object.value.push(inObject);
                }
            }  
            temp2.push(object); 
        }
        component.set("v.listOfPageObjects", temp2);
    }
})
