import { LightningElement,api,track } from 'lwc';

export default class ListOfItems extends LightningElement {
    @api countOfPageElements;
    @api countOfAllElements;
    @api countOfColumns;
    @api pageNumber;
    listOfAllElements = [];
    listOfElements = [];

    @api
    get countAlEl(){
        return this.countOfAllElements;
    }
    set countAlEl(count){
        this.countOfAllElements = count;
        let temp = [];
        for (let i = 0; i < this.countOfAllElements; i++) {
            temp.push('Element number ' + (i + 1));
        }
        this.listOfAllElements = temp;  
        if (count != undefined) {
            this.setpgNum(undefined);
        }
    }
    @api
    setpgNum(value){
        if (value != undefined) {
            this.pageNumber = value;
        }
        let startIndex = (this.pageNumber - 1) * this.countOfPageElements;
        let endIndex = this.countOfAllElements - startIndex > this.countOfPageElements ?
        startIndex + this.countOfPageElements : this.countOfAllElements; 
        let temp = [];
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
            temp.push(object); 
        }
        this.listOfElements = temp;
    }
}