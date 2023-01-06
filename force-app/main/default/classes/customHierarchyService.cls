public with sharing class customHierarchyService {
    public static List<Role_Hierarchy__c> getAllRolesAbove(Role_Hierarchy__c enteredRole, Map<Id,Role_Hierarchy__c> mapOfAllRoles, List<Role_Hierarchy__c> listOfRoles){
        if (String.isNotBlank(enteredRole.Parent__c)) {
            Role_Hierarchy__c role = mapOfAllRoles.get(enteredRole.Parent__c);
            listOfRoles.add(role);
            listOfRoles = customHierarchyService.getAllRolesAbove(role, mapOfAllRoles, listOfRoles);
        }
        return listOfRoles;
    }
    public static Boolean shareRecordWithUsers(Id recordId, List<id> usersId, Integer index) {
        System.debug(usersId.size());
        System.debug(index);
        if (index == usersId.size()) {
            return true;
        }
        Share_object__Share shrOb = new Share_object__Share();
        shrOb.ParentId = recordId;
        shrOb.UserOrGroupId = usersId[index];
        shrOb.AccessLevel = 'Edit';
        shrOb.RowCause = Schema.Share_object__Share.RowCause.Manual;
        System.debug(shrOb);
        System.debug(shrOb.UserOrGroupId);
        Database.SaveResult sr = Database.insert(shrOb,false);
        System.debug(sr.isSuccess());
        if(sr.isSuccess()){
            if (customHierarchyService.shareRecordWithUsers(recordId, usersId, ++index)) {
                return true;
            }
            else {
                return false;
            }
        }
        else {
           Database.Error err = sr.getErrors()[0];
           if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                err.getMessage().contains('AccessLevel')){
                if (customHierarchyService.shareRecordWithUsers(recordId, usersId, ++index)) {
                    return true;
                }
                else {
                    return false;
                }
           }
           else{
                System.debug(err.getMessage());
                return false;
           }
         }
    }
}
