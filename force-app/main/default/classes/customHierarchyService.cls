public with sharing class customHierarchyService {
    public static void getAllRolesAbove(Role_Hierarchy__c enteredRole, Map<Id,Role_Hierarchy__c> mapOfAllRoles, List<Role_Hierarchy__c> listOfRoles, Map<Id, List<Id>> mapOfWithWhoSharesIdByWhoSharesId, Id idOfRoleWhoShared){
        if (idOfRoleWhoShared != null && enteredRole.Parent__c == idOfRoleWhoShared) {
            idOfRoleWhoShared = null;
            System.debug(listOfRoles);
            return;
        }
        if (enteredRole == null) {
            listOfRoles = new List<Role_Hierarchy__c>();
            return;
        }
        if (listOfRoles.size() == 0) {
            listOfRoles.add(enteredRole);
        }
        if (mapOfWithWhoSharesIdByWhoSharesId.get(enteredRole.Id) != null) {
            for (Id RolesIdShareWith : mapOfWithWhoSharesIdByWhoSharesId.get(enteredRole.Id)) {
                List<Role_Hierarchy__c> listOfRolesINSharingRule = new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(RolesIdShareWith), mapOfAllRoles, listOfRolesINSharingRule, mapOfWithWhoSharesIdByWhoSharesId, enteredRole.Id);
                listOfRoles.addAll(listOfRolesINSharingRule);
                System.debug(mapOfAllRoles.get(RolesIdShareWith));
            }
        }
        if (String.isNotBlank(enteredRole.Parent__c)) {
            Role_Hierarchy__c role = mapOfAllRoles.get(enteredRole.Parent__c);
            listOfRoles.add(role);
            customHierarchyService.getAllRolesAbove(role, mapOfAllRoles, listOfRoles, mapOfWithWhoSharesIdByWhoSharesId, idOfRoleWhoShared);
        }
    }
    public static List<Id> getAllUsersIdByRoles(List<Role_Hierarchy__c> listOfRoles){
        List<Id> listOfUsersId = new List<Id>();
        for (User_Junction__c user : [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__c IN : listOfRoles]) {
            listOfUsersId.add(user.User__c);
        }
        return listOfUsersId;
    }
    public static Boolean shareRecordWithUsers(List<Id> listOfRecordId, List<id> usersId, Integer index) {
        if (index == usersId.size()) {
            return true;
        }
        List<Share_object__Share> listOfSharedObjects = new List<Share_object__Share>();
        for (Id sharedObjectId : listOfRecordId) {
            Share_object__Share sharedObject = new Share_object__Share();
            sharedObject.ParentId = sharedObjectId;
            sharedObject.UserOrGroupId = usersId[index];
            sharedObject.AccessLevel = 'Edit';
            sharedObject.RowCause = Schema.Share_object__Share.RowCause.Manual;
            listOfSharedObjects.add(sharedObject);
        }
        List<Database.SaveResult> listOfResults = Database.insert(listOfSharedObjects,false);
        for (Database.SaveResult sr : listOfResults) {
            if(sr.isSuccess()){
                System.debug([SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c WHERE User__c =: usersId[index]][0].Role_Hierarchy__r.Name);
                if (customHierarchyService.shareRecordWithUsers(listOfRecordId, usersId, ++index)) {
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
                    if (customHierarchyService.shareRecordWithUsers(listOfRecordId, usersId, ++index)) {
                        return true;
                    }
                    else {
                        return false;
                    }
               }
               else{
                    //System.debug([SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c WHERE User__c =: usersId[index]][0].Role_Hierarchy__r.Name);
                    System.debug(err.getMessage());
                    return false;
               }
            }
        }
        return false;
    }
    public static List<Role_Hierarchy__c> getAllRolesBetween(Role_Hierarchy__c oldParent, Role_Hierarchy__c newParent, Map<Id,Role_Hierarchy__c> mapOfAllRoles){
        List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
        //System.debug(oldParent);
        //System.debug(newParent);

        Role_Hierarchy__c tempRole = oldParent;
        if (newParent == null) {
            do {
                listOfRolesAbove.add(tempRole);
                tempRole = mapOfAllRoles.get(tempRole.Parent__c);
            } while (tempRole != null);
            return listOfRolesAbove;
        }
        else if (oldParent == null){
            return listOfRolesAbove;
        }

        do {
            if (tempRole.Id == newParent.Id) {
                return listOfRolesAbove;
            }
            listOfRolesAbove.add(tempRole);
            tempRole = mapOfAllRoles.get(tempRole.Parent__c);
        } while (tempRole != null);

        tempRole = newParent;
        do {
            if (tempRole.Id == oldParent.Id) {
                return new List<Role_Hierarchy__c>();
            }
            tempRole = mapOfAllRoles.get(tempRole.Parent__c);
        } while (tempRole != null);

        return listOfRolesAbove;
    }
    public static void unShareRecordWithUsers(List<Id> listOfRecordId, List<id> usersId){
        List<Share_object__Share> listOfShareObjects = [SELECT Id, ParentId, RowCause, UserOrGroupId FROM Share_object__Share WHERE UserOrGroupId IN :usersId AND ParentId IN: listOfRecordId AND RowCause != 'Owner' AND RowCause != 'Rule' AND RowCause != 'GuestRule'];
        delete listOfShareObjects;
    }
}
