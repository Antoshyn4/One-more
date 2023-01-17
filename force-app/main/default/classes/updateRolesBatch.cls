global class updateRolesBatch implements Database.Batchable<Role_Hierarchy__c>{
    public List<Role_Hierarchy__c> listOfRolesToUpdate;
    public updateRolesBatch(List<Role_Hierarchy__c> listOfRoles) {
        this.listOfRolesToUpdate = listOfRoles;
    }
    global Iterable<Role_Hierarchy__c> start(Database.BatchableContext context){
        return new foo(listOfRolesToUpdate);
    }
    global void execute(Database.BatchableContext context, List<Role_Hierarchy__c> scope){
        List<Role_Hierarchy__c> listOfRolesToUpdate = new List<Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : scope) {
            listOfRolesToUpdate.add(role);
        }
        update listOfRolesToUpdate;
    }
    global void finish(Database.BatchableContext context){
        roleHierarchyTriggerHandler.tracker = false;
    }
}