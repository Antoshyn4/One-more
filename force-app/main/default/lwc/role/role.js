import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import StayInTouchSignature from '@salesforce/schema/User.StayInTouchSignature';
import { LightningElement, api, track } from 'lwc';

export default class Role extends LightningElement {
    @api listOfHierarchies;
    @track _listOfHierarchies;
    @track showChilds = false;
    @track activeSections = [];

    set listOfHierarchies(data){
        if (data) {
            this._listOfHierarchies = JSON.parse(JSON.stringify(data));
        }
    }
    get listOfHierarchies(){
        return this._listOfHierarchies;
    }
    
    // get listOfHierarchiesPlease(){
    //     return this.listOfHierarchies;
    // }
    connectedCallback(){
    }
    handleSectionToggle(event){
        let result = event.detail.openSections.filter(name => this.activeSections.indexOf(name) < 0);
        if (result.length == 0) {
            result = this.activeSections.filter(name2 => event.detail.openSections.indexOf(name2) < 0);
        }
        this.dispatchEvent(new CustomEvent('showrecords', {detail: result, bubbles: true, composed: true}));
        let temp = this._listOfHierarchies;
        for (let index = 0; index < temp.length; index++) {
            if(event.detail.openSections.includes(temp[index].Role.Id)){
                temp[index].showChilds = true;
            }
        }
        this._listOfHierarchies = temp;
        this.activeSections = event.detail.openSections;
    }
}