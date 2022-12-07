import { LightningElement, track, wire } from 'lwc';
import getCustomSettings from '@salesforce/apex/ComponentCustomSettings.getCustomSettings';
import getAccountList from '@salesforce/apex/ComponentCustomSettings.getAccountList';

export default class MyPage extends LightningElement {
    @track countOfColumns;
    @track countOfAllElements;
    @track countOfPageElements;
    @track countOfPages;
    @track record = [];
    @track error; 
    pageNum = 1;

    @wire(getCustomSettings)
    wiredCustomSettings({error, data}){
        if (data) {
            this.countOfAllElements = data.All_elements_count__c;
            this.countOfColumns = data.Columns_count__c;
            this.countOfPageElements = data.On_page_elements_count__c;
            this.countOfPages = Math.ceil(this.countOfAllElements/this.countOfPageElements);
        }
        else if (error) {
            alert("Error");
        }
    }
    @wire(getAccountList)
    wiredList({error,data}){
        if (data) {
            this.record.length = 0;
            let temp = []; 
            for (const key in data) {
                temp.push(data[key])
            }
            this.record = temp;
            this.error = undefined; 
            if (this.countOfAllElements > this.record.length) {
                this.countOfAllElements = this.record.length;
                this.countOfPages = Math.ceil(this.countOfAllElements/this.countOfPageElements);
            }
            console.log("Ok");
        }
        else if (error){
            this.record = undefined;
            this.error = error;
            console.log("Not Ok");
            alert('Error');
        }
    }
    reDraw(event){
        this.countOfPages = Math.ceil(this.countOfAllElements/this.countOfPageElements);
        this.pageNum = event.detail;
        this.template.querySelector('c-list-of-accounts').draw(this.pageNum);
    }
}