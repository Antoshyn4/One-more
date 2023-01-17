global class CustomIterableRole implements Iterator<Role_Hierarchy__c> {
    List<Role_Hierarchy__c> listOfRoles {get;set;}
    Integer i {get; set;}
 
    public CustomIterableRole(List<Role_Hierarchy__c> listOfRolesToIterate) {
        this.listOfRoles = listOfRolesToIterate;
        this.i = 0;
    }

    global Boolean hasNext(){
        return i >= listOfRoles.size() ? false : true;
    }

    global Role_Hierarchy__c next(){
        if(i == 50){
            return null;
        } 
        i++; 
        return listofRoles[i-1];
    }
}