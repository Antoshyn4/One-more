import { LightningElement,api, track } from 'lwc';

export default class ListOfAccounts extends LightningElement {
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
                temp.push(this.record[i].accName);
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
                    object.value.push(this.listOfAllElements[startIndex + i + z * this.countOfColumns]);
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
                    object.value.push(this.listOfAllElements[startIndex + i + z * this.countOfColumns]);
                }
            }  
            temp2.push(object); 
        }
        this.listOfElements = temp2;
    }
}   