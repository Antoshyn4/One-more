import StayInTouchSignature from '@salesforce/schema/User.StayInTouchSignature';
import { LightningElement, api, track } from 'lwc';
const columnsUser = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'Name', fieldName: 'Name', type: 'text' }
];
const columnsRecord = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Text', fieldName: 'Text__c', type: 'text' }
];

export default class ShowUsersAndRecords extends LightningElement {
    @track dataRecords = [];
    @track dataUsers = [];
    @api listOfUsers;
    @api listOfRecords;
    @track _listOfRecords;
    @track _listOfUsers;
    columnsUser = columnsUser;
    columnsRecord = columnsRecord;
    set listOfRecords(data){
        this._listOfRecords = data;
        this.dataRecords = data;
        console.log(JSON.stringify(data));
    }
    get listOfRecords(){
        return this._listOfRecords;
    }

    set listOfUsers(data){
        this._listOfUsers = data;
        this.dataUsers = data;
        console.log(JSON.stringify(data));
    }
    get listOfUsers(){
        return this._listOfUsers;
    }

}