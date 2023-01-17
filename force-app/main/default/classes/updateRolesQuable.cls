public with sharing class updateRolesQuable implements Queueable{
    private List<Role_Hierarchy__c> listOfROlesToUpdate;
    public updateRolesQuable(List<Role_Hierarchy__c> listOfROlesToUpdate){
        this.listOfROlesToUpdate = listOfROlesToUpdate; 
    }
    public void execute(QueueableContext context) {
        System.debug(listOfROlesToUpdate[0].Name);
        System.debug([SELECT Name FROM Role_Hierarchy__c WHERE Id =: listOfROlesToUpdate[0].Parent__c][0].Name);
        update listOfROlesToUpdate;
    }
}