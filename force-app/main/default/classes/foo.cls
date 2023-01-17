global class foo implements iterable<Role_Hierarchy__c> {
    private List<Role_Hierarchy__c> listOfRolesToUpdate;

    public foo(List<Role_Hierarchy__c> listOfRoles) {
        this.listOfRolesToUpdate = listOfRoles;
    }
    
    global Iterator<Role_Hierarchy__c> Iterator(){
        return new CustomIterableRole(listOfRolesToUpdate);
    }
}