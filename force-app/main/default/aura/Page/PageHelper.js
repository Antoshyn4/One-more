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
                        inObject['Contacts'] = listOfAllElements[startIndex + i + z * countOfColumns].Contacts;
                        if (listOfAllElements[startIndex + i + z * countOfColumns].Contacts != undefined) {
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
        component.set("v.listOfPageObjects",temp2);
        // let temp = [];
        // if (this.someRecAll != undefined) {
        //     debugger;
        //     for (const key in this.someRecAll['record']) {
        //         if (!this.someRecAll['record'][key]['isAccount']) { 
        //             temp.push(this.someRecAll['record'][key]['Account'].Id);
        //         }
        //     }
        //     if (temp.length > 0) {
        //         debugger;
        //         this.activeSections = temp;
        //         console.log(JSON.stringify(temp));
        //     }  
        //     this.someRecAll = undefined;
        // }
    }
})
