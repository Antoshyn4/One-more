import { LightningElement,api,wire,track } from 'lwc';
import MyModal from 'c/popUpAccount';
import getAllAccountRecords from '@salesforce/apex/ComponentCustomSettings.getAllAccountRecords';
import getNameById from '@salesforce/apex/ComponentCustomSettings.getNameById';

export default class ListOfAccounts extends LightningElement {
    @track isAcc = true;
    @track activeSections = [];
    @api countOfColumns;
    @api countOfAllElements;
    @api countOfPageElements;
    @api countOfPages;
    @api pageNumber;    
    record = [];
    @track listOfElements = [];
    @track listOfAllElements = [];
    someRecAll = [];
    check = true;
    name;
    @api parentName;
    @api childName;

    @api 
    get recordPlease(){
        return this.record;
    }
    set recordPlease(arr){
        if (arr) {
            this.record = arr;
            this.changeAllElements();
            this.changeOnPageElements();
            let te = []
            
        }
        else{
            this.record = [];
            this.changeAllElements();
            this.changeOnPageElements();
        }
        // if (this.someRecAll.length > 0) {
        //     for (const key in this.someRecAll['record']) {
        //         debugger;
        //         console.log(this.someRecAll['record'][key].Id);
        //         console.log(this.someRecAll['record'][key]);
        //         te.push(this.someRecAll['record'][key]['Account'].Id);
        //     }
        //     if (te.length > 0) {
        //         this.activeSections = te;
        //         console.log(te);
        //     }
        // }
    }
    changeAllElements(){
        let temp = [];
        for (let i = 0; i < this.countOfAllElements; i++) {  
            if (this.record[i] != undefined) {
                let object = {};
                object['Contacts'] = [];
                object['Count'] = "Count of " + this.childName + ": ";
                let counter = 0;
                object['Name'] = this.record[i].Name;
                object['Id'] = (this.record[i].Id);
                for (const key in this.record[i][this.childName]) {
                    if (this.childName == 'Cases') {
                        object.Contacts.push({Name: String(this.record[i][this.childName][key].CaseNumber), Id : this.record[i][this.childName][key].Id});
                    }
                    else if (this.childName == 'Contacts'){
                        object.Contacts.push({Name: String(this.record[i][this.childName][key].Name), Id : this.record[i][this.childName][key].Id});
                    }
                    counter++;
                }
                object['Num'] = counter;
                object.Count += counter;
                temp.push(object);
            }
        }
        this.listOfAllElements = temp;  
    }
    @api draw(number){
        if (number != undefined) {
            this.pageNumber = number;
        }
        this.changeOnPageElements();
    }
    @api changeRecord(someRec){
        //this.activeSections = ['001Dn0000065gWqIAI','001Dn0000065gWsIAI','001Dn000006iDqRIAU'];
        if (someRec['record'] == undefined) {
            this.record = [];
        }
        else{
            let temp = [];
            for (const key in someRec['record']) {
                temp.push(someRec['record'][key]['Account']);
            }
            this.recordPlease = temp;
        }
        this.countOfAllElements = this.record.length;
        this.countOfPages = Math.ceil(this.countOfAllElements/this.countOfPageElements);
        this.changeAllElements();
        this.pageNumber = 1;
        this.someRecAll = someRec;
        this.changeOnPageElements(); 
          
    }
    changeOnPageElements(){
        let startIndex = (this.pageNumber - 1) * this.countOfPageElements;
        let temp2 = [];
        for (let i = 0; i < this.countOfColumns; i++){
            let object = {};
            object['type'] = '';
            object['value'] = [];
             for (let z = 0; z < Math.ceil(parseInt(this.countOfPageElements)/parseInt(this.countOfColumns)); z++) {
                if (z + 1 < Math.ceil(this.countOfPageElements/this.countOfColumns) || 
                (this.countOfPageElements % this.countOfColumns == 0 || 
                    i + 1 <= this.countOfPageElements % this.countOfColumns)) {
                    let inObject = {};
                    if (this.listOfAllElements[startIndex + i + z * this.countOfColumns]) {
                        inObject['Name'] = this.listOfAllElements[startIndex + i + z * this.countOfColumns].Name;
                        inObject['Count'] = this.listOfAllElements[startIndex + i + z * this.countOfColumns].Count;
                        inObject['Contacts'] = this.listOfAllElements[startIndex + i + z * this.countOfColumns].Contacts;
                        inObject['Num'] = this.listOfAllElements[startIndex + i + z * this.countOfColumns].Num;
                        inObject['Id'] = this.listOfAllElements[startIndex + i + z * this.countOfColumns].Id;
                    }
                    object.value.push(inObject);
                }
            }  
            temp2.push(object); 
        }
        let temp = [];
        if (this.someRecAll != undefined) {
            debugger;
            for (const key in this.someRecAll['record']) {
                if (!this.someRecAll['record'][key]['isAccount']) { 
                    temp.push(this.someRecAll['record'][key]['Account'].Id);
                }
            }
            if (temp.length > 0) {
                debugger;
                this.activeSections = temp;
                console.log(JSON.stringify(temp));
            }  
            this.someRecAll = undefined;
        }
        this.listOfElements = temp2;

    }
    async doPopUp(event){
        getNameById({objectId: event.target.dataset.id})
        .then(result => {
            this.name = result;
        })
        .catch(error => {
            alert('Error in getName');
        })
        getAllAccountRecords({ accid : event.target.dataset.id })
        .then(result => {
            let values = Object.values(result);
            let keys = Object.keys(result);
            let myOptions = [];
            let Id;
            for (let i = 0; i < values.length; i++) {
                let ob = {};
                debugger;
                ob['label'] = keys[i];
                ob['value'] = values[i];
                if (keys[i] == 'Id') {
                    Id = values[i];
                }
                myOptions.push(ob);
            }
            debugger;
            MyModal.open({
                size: 'large',
                description: 'Accessible description of modal\'s purpose',
                options: myOptions,
                recordId: Id,
                objectName: this.name
            });
        })
        .catch(error => {
            alert(JSON.stringify(error));
        });
    }
    renderedCallback(){
        if (this.check) {
            debugger;
            this.check = false;
        }
    }
}