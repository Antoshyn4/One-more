import { LightningElement,api, track } from 'lwc';

export default class ListOfAccounts extends LightningElement {
    activeSections = ['A', 'C'];
    @api countOfColumns;
    @api countOfAllElements;
    @api countOfPageElements;
    @api countOfPages;
    @api pageNumber;
    @api record = [];
    @api task = [];
    listOfElements = [];
    listOfAllElements = [];

    connectedCallback(){
        let temp = [];
        for (let i = 0; i < this.countOfAllElements; i++) {  
            if (this.record[i] != undefined) {
                let object = {};
                object['Contacts'] = [];
                object['Count'] = "Count of Contacts: ";
                let counter = 0;
                object['Name'] = this.record[i].Name;
                for (const key in this.record[i].Contacts) {
                    object.Contacts.push(String(this.record[i].Contacts[key].Name));
                    counter++;
                }
                object.Count += counter;
                temp.push(object);
            }
        }
        this.listOfAllElements = temp;
        let startIndex = (this.pageNumber - 1) * this.countOfPageElements;
        let temp2 = [];
        for (let i = 0; i < this.countOfColumns; i++){
            let object = {};
            object['type'] = 'text';
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
                    }
                    object.value.push(inObject);
                }
            }  
            temp2.push(object); 
        }
        this.listOfElements = temp2;
    }
    @api draw(number){
        if (number != undefined) {
            this.pageNumber = number;
        }
        let startIndex = (this.pageNumber - 1) * this.countOfPageElements;
        let temp2 = [];
        for (let i = 0; i < this.countOfColumns; i++){
            let object = {};
            object['type'] = 'text';
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
                    }
                    object.value.push(inObject);
                }
            }  
            temp2.push(object); 
        }
        this.listOfElements = temp2;
    }
}   