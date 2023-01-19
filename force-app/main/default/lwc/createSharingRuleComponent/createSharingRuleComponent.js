import { LightningElement } from 'lwc';

export default class CreateValidationRuleComponent extends LightningElement {
    strName;
    strWhoShare;
    strShareWith;

    nameChangedHandler(event){
        this.strName = event.target.value;
    }

    whoShareRuleChangedHandler(event){
        this.strWhoShare = event.target.value;
    }

    withWhoShareRuleChangedHandler(event){
        this.strShareWith = event.target.value;
    }
}