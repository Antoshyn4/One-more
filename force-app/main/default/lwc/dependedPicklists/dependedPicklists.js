import { LightningElement, wire } from 'lwc';
import getAllObjectsWithChild from '@salesforce/apex/ComponentCustomSettings.getAllObjectsWithChild';

export default class DependedPicklists extends LightningElement {
    
    handleSubmit(event){
        // event.preventDefault(); 
        // const fields = event.detail.fields;
        // this.template.querySelector('lightning-record-edit-form').submit(fields);
     }
}