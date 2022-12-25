({
    doInit : function(component, event, helper) {
        component.set("v.ParentName","Account");
        component.set("v.ChildName","Contacts");
        component.set("v.isFirstPage", "true");
        let getObjectsAction = component.get("c.getAccountList");
        let getSortAction = component.get("c.getSortSettings");
        let getPageSettings = component.get("c.getCustomSettings");
        component.set("v.PageNumber",1);
        
        getObjectsAction.setParams({
            "parentName": component.get("v.ParentName"),
            "childName": component.get("v.ChildName")
        });
        getObjectsAction.setCallback(this, function(response) {
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
                $A.enqueueAction(getPageSettings);
            }
        })
        getPageSettings.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();

                component.set("v.countOfAllElements",result.All_elements_count__c);
                component.set("v.countOfColumns",result.Columns_count__c);
                component.set("v.countOfPageElements", result.On_page_elements_count__c);
                component.set("v.PageCount", Math.ceil(component.get("v.countOfAllElements")/component.get("v.countOfPageElements")));
                if (component.get("v.listOfObjects").length < component.get("v.countOfAllElements")) {
                    component.set("v.PageCount", Math.ceil(component.get("v.listOfObjects").length/component.get("v.countOfPageElements")));
                }
                component.set("v.isLastPage", component.get("v.PageNumber") == component.get("v.PageCount"));
                component.set("v.isNotSingle", component.get("v.PageCount") > 1);
                helper.changeOnPageElements(component);
            }
        })
        $A.enqueueAction(getObjectsAction);

    },
    handleChangePageNumber : function(component, event, helper) {
        let number = event.getParam("PageNumber");
        component.set("v.PageNumber", number);
        component.set("v.isFirstPage", component.get("v.PageNumber") == 1);
        component.set("v.isLastPage", component.get("v.PageNumber") == component.get("v.PageCount"));
        helper.changeOnPageElements(component);
    },
    changeSort : function(component, event, helper) {
        let field = event.getParam("sortField");
        let isDisc = event.getParam("isDiscending");
        component.set("v.sortField", field);
        component.set("v.sortedByDescending", isDisc);
        component.set("v.listOfObjects", helper.quickSort(component, component.get("v.listOfObjects")));
        let setOrderAction = component.get("c.setOrder");
        setOrderAction.setParams({
            "sortBy" : component.get("v.sortField"),
            "isDesc" : component.get("v.sortedByDescending")
        });
        $A.enqueueAction(setOrderAction);
        helper.changeOnPageElements(component);
    },
    doSearchHandler : function(component, event, helper) {
        let search = event.getParam("Search");
        let searchAction = component.get("c.doSearch");
        searchAction.setParams({
            "search" : search,
            "parentName" : component.get("v.ParentName"),
            "childName" : component.get("v.ChildName")
        });
        searchAction.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let temp = [];
                for (const key in JSON.parse(response.getReturnValue())) {
                    let ob = {};
                    ob['Account'] = JSON.parse(response.getReturnValue())[key].Account;
                    ob['isAccount'] = JSON.parse(response.getReturnValue())[key].isAccount;
                    temp.push(ob);
                }
                let temp2 = [];
                for (const key in temp) {
                    let ob = {};
                    ob = temp[key]['Account'];
                    ob['isAccount'] = temp[key]['isAccount'];
                    if (temp[key]['Account'][component.get("v.ChildName")] != undefined) {
                        ob[component.get("v.ChildName")] = temp[key]['Account'][component.get("v.ChildName")].records;
                    }
                    else {
                        ob[component.get("v.ChildName")] = [];
                    }
                    temp2.push(ob);
                }
                if (temp2.length == 0) {

                } else {
                    component.set("v.PageCount", Math.ceil(component.get("v.countOfAllElements")/component.get("v.countOfPageElements")));
                    component.set("v.listOfObjects", helper.quickSort(component, temp2));
                    if (component.get("v.listOfObjects").length < component.get("v.countOfAllElements")) {
                        component.set("v.PageCount", Math.ceil(component.get("v.listOfObjects").length/component.get("v.countOfPageElements")));
                    }
                    component.set("v.PageNumber", 1);
                    component.set("v.isFirstPage", "true");
                    component.set("v.isLastPage", component.get("v.PageNumber") == component.get("v.PageCount"));
                    component.set("v.isNotSingle", component.get("v.PageCount") > 1);
                    helper.changeOnPageElements(component);
                }
            }
        });
        $A.enqueueAction(searchAction);
    }
})
