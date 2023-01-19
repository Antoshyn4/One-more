import { LightningElement, track } from 'lwc';
import getAllRoles from '@salesforce/apex/Role_Hierarchy_Wrapper.getAllRoles';

export default class PageOfRoles extends LightningElement {
    listOfHierarchies = [];
    @track listOfUsers = [];
    @track listOfRecords = [];
    
    connectedCallback(){
        getAllRoles()
        .then(result => {
            this.listOfHierarchies = result;
            console.log(JSON.stringify(this.listOfHierarchies));
        })
        .catch(error => {
            alert(error);
        });
    }
    showRecords(event){
        const id = event.detail[0];
        console.log(id);
        this.getWrapper(id, this.listOfHierarchies);
        console.log(JSON.stringify(this.listOfUsers));
        console.log(JSON.stringify(this.listOfRecords));
    }
    getWrapper(Id, temp){
        for (let i = 0; i < temp.length; i++) {
            if (temp[i].Role.Id == Id) {
                this.listOfUsers = temp[i].listOfAssignedUsers;
                this.listOfRecords = temp[i].listOfSharedObjects;
                return;
            }
            else if (temp[i].Childs != null){
                this.getWrapper(Id, temp[i].Childs);
            }
        }
    }
}