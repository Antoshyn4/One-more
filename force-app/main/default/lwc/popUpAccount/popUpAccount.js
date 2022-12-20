import { api, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import Name from '@salesforce/schema/Account.Name';

export default class MyModal extends LightningModal {
    @api options = [];
    @api objectName;
    @api recordId;
    link;

    handleOkay() {
        this.close('okay');
    }
    connectedCallback(){
        //this.link = 'https://playful-impala-3rlhua-dev-ed.trailblaze.lightning.force.com/lightning/r/Account/' + this.options[2].value + '/view';
    }
    updateRecord(event){
        // console.log(JSON.stringify(event.detail.fields));
        // console.log(JSON.stringify(event.detail.field));
        // console.log(JSON.stringify(event.target.name));
        // debugger;
        // this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail;  
        debugger;
        for (const key in fields) {
            debugger;
            if (key == 'Phone') {
                if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(key.value)){
                    
                }
            }
        }     // stop the form from submitting
        this.template.querySelector('lightning-record-edit-form').submit(fields);
     }
     validation(event){
        const inputCmp = this.template.querySelectorAll("lightning-input-field");
        
        debugger;
        switch (event.target.dataset.name) {
            case 'Phone':
                for (const key in inputCmp) {
                    if (inputCmp[key].fieldName == 'Phone') {
                        inputCmp[key].value = event.target.value.replace(/[a-zA-Z]/g,'');
                        inputCmp[key].value = event.target.value.replace('\ ','-');
                    }
                }
                break;
            case 'Fax': 
                for (const key in inputCmp) {
                    if (inputCmp[key].fieldName == 'Fax') {
                        inputCmp[key].value = event.target.value.replace(/[a-zA-Z]/g,'');
                        inputCmp[key].value = event.target.value.replace('\ ','-');
                    }
                }
                break;
            default:
                break;
        }
        console.log();
        debugger;
     }
}