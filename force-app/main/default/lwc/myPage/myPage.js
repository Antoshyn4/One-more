import { LightningElement, track, wire, api} from 'lwc';
import getCustomSettings from '@salesforce/apex/ComponentCustomSettings.getCustomSettings';
import getAccountList from '@salesforce/apex/ComponentCustomSettings.getAccountList';

export default class MyPage extends LightningElement {
    @track noSearchResult = false;
    @api countOfColumns;
    @track countOfAllElements;
    @track countOfPageElements;
    @track countOfPages;
    @track record = [];
    @track error; 
    pageNum = 1;

    get countOfAllElementsAct(){
        if (this.countOfAllElements > this.record.length) {
            return  this.record.length;
        }
        return this.countOfAllElements;
    }
    get countOfPagesAct(){
        if (this.countOfAllElements > this.record.length) {
            return  Math.ceil(this.record.length/this.countOfPageElements);
        }
        return this.countOfPages;
    }

    connectedCallback(){
        getCustomSettings()
        .then(result => {
            if (result.All_elements_count__c <= 0 || result.Columns_count__c <= 0 || result.On_page_elements_count__c < 0) {
                alert('Incorrect input values');
                // this.countOfAllElements = 0;
                // this.countOfColumns = 0;
                // this.countOfPageElements = 0;
                // this.countOfPages = 0;
                // this.record = undefined;
            }
            else {
                this.countOfAllElements = result.All_elements_count__c;
                this.countOfColumns = result.Columns_count__c;
                this.countOfPageElements = result.On_page_elements_count__c;
                this.countOfPages = Math.ceil(this.countOfAllElements/this.countOfPageElements);
            }
        }) 
        .catch(error => {
            alert('Error in getCS' + JSON.stringify(error));
        });
        getAccountList({isDesc: '', sortBy:})
        .then(result => {
            this.record.length = 0;
            let temp = []; 
            for (const key in result) {
                temp.push(result[key])
            }
            this.record = temp;
            this.error = undefined; 
        })
        .catch(error => {
            this.record = undefined;
            this.error = error;
            alert('Error in getAcc' + JSON.stringify(error));
        });
    }

    reDraw(event){
        this.countOfPages = Math.ceil(this.countOfAllElements/this.countOfPageElements);
        this.pageNum = event.detail;
        this.template.querySelector('c-list-of-accounts').draw(this.pageNum);
    }
    changeRecord(event){
        if (event.detail['record'].length == 0 || event.detail['isAcc'] == null) {
            this.noSearchResult = true;
            this.record.length = 0;
            this.template.querySelector('c-menu').changeCount(this.countOfPagesAct);
            this.template.querySelector('c-list-of-accounts').changeRecord(event.detail);
        }
        else {
            this.noSearchResult = false;
            let data = event.detail['record'];
            this.record = data;
            this.error = undefined; 
            this.template.querySelector('c-menu').changeCount(this.countOfPagesAct);
            this.template.querySelector('c-list-of-accounts').changeRecord(event.detail);
        }
    }
    fillAllValues(){
        this.noSearchResult = false;
        getCustomSettings()
        .then(result => {
            if (result.All_elements_count__c <= 0 || result.Columns_count__c <= 0 || result.On_page_elements_count__c < 0) {
                alert('Incorrect input values');
                // this.countOfAllElements = 0;
                // this.countOfColumns = 0;
                // this.countOfPageElements = 0;
                // this.countOfPages = 0;
                // this.record = undefined;
            }
            else {
                this.countOfAllElements = result.All_elements_count__c;
                this.countOfColumns = result.Columns_count__c;
                this.countOfPageElements = result.On_page_elements_count__c;
                this.countOfPages = Math.ceil(this.countOfAllElements/this.countOfPageElements);
            }
        }) 
        .catch(error => {
            alert('Error in getCS' + JSON.stringify(error));
        });
        getAccountList()
        .then(result => {
            debugger;
            this.record.length = 0;
            let temp = []; 
            for (const key in result) {
                temp.push(result[key])
            }
            this.record = temp;
            this.error = undefined; 
            this.template.querySelector('c-menu').changeCount(this.countOfPagesAct);
        })
        .catch(error => {
            this.record = undefined;
            this.error = error;
            alert('Error in getAcc' + JSON.stringify(error));
        });
    }
}