public with sharing class Role_Hierarchy_Wrapper {
    Role_Hierarchy__c Role {private set; get;}
    List<Role_Hierarchy_Wrapper> Childs {private set; get;}
    public Role_Hierarchy_Wrapper(Role_Hierarchy__c role, Map<Id, Role_Hierarchy__c> mapOfAllRoles) {
        this.Role = role;
        this.Childs = Role_Hierarchy_Wrapper.getListOfChilds(this, mapOfAllRoles);
    }
    private static List<Role_Hierarchy_Wrapper> getListOfChilds(Role_Hierarchy_Wrapper enteredRole, Map<Id,Role_Hierarchy__c> mapOfAllRoles){
        List<Role_Hierarchy_Wrapper> listOfChildsRole = new List<Role_Hierarchy_Wrapper>();
        for (Role_Hierarchy__c role : mapOfAllRoles.values()) {
            if(role.Parent__c == enteredRole.Role.Id){
                Role_Hierarchy_Wrapper newWrappedRole = new Role_Hierarchy_Wrapper(role, mapOfAllRoles);
                listOfChildsRole.add(newWrappedRole);
            }
        }
        return listOfChildsRole;
    }
}