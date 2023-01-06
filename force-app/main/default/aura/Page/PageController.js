({
    doInit : function(component, event, helper) {
        helper.initialize(component, helper);
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
        if (search.length == 0) {
            helper.initialize(component, helper);
        }
        else {
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
                        debugger;
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
                        component.set("v.listOfObjects",[]);
                        helper.changeOnPageElements(component);
                        component.set("v.PageCount", 0);
                        component.set("v.isFirstPage", "true");
                        component.set("v.isLastPage", "true");
                        component.set("v.isNotSingle", component.get("v.PageCount") > 1);
                    } 
                    else {
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
    }
})
