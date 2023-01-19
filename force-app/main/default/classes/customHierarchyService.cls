public with sharing class customHierarchyService {
    public static void getAllRolesAbove(Role_Hierarchy__c enteredRole, Map<Id,Role_Hierarchy__c> mapOfAllRoles, List<Role_Hierarchy__c> listOfRoles, Map<Id, List<Id>> mapOfWithWhoSharesIdByWhoSharesId, List<Id> idOfRoleWhoShared){
        if (idOfRoleWhoShared != null && idOfRoleWhoShared.contains(enteredRole.Parent__c)) {
            idOfRoleWhoShared.remove(idOfRoleWhoShared.indexOf(enteredRole.Parent__c));
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
                if (idOfRoleWhoShared == null) {
                    idOfRoleWhoShared = new List<Id>();
                }
                idOfRoleWhoShared.add(enteredRole.Id);
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(RolesIdShareWith), mapOfAllRoles, listOfRolesINSharingRule, mapOfWithWhoSharesIdByWhoSharesId, idOfRoleWhoShared);
                listOfRoles.addAll(listOfRolesINSharingRule);
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
                    System.debug(usersId[index]);
                    System.debug(err.getMessage());
                    return false;
               }
            }
        }
        return false;
    }
    public static void shareRecordWithUsersById(List<Id> listOfRecordId, List<id> usersId){
        List<Share_object__Share> listOfSharedObjects = new List<Share_object__Share>();
        for (Id userId : usersId) {
            for (Id sharedObjectId : listOfRecordId) {
                Share_object__Share sharedObject = new Share_object__Share();
                sharedObject.ParentId = sharedObjectId;
                sharedObject.UserOrGroupId = userId;
                sharedObject.AccessLevel = 'Edit';
                sharedObject.RowCause = Schema.Share_object__Share.RowCause.Manual;
                listOfSharedObjects.add(sharedObject);
            }
        }
        List<Database.SaveResult> listOfResults = Database.insert(listOfSharedObjects,false);
        for (Database.SaveResult sr : listOfResults) {
            if(sr.isSuccess()){
                return;
            }
            else {
               Database.Error err = sr.getErrors()[0];
               if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                    err.getMessage().contains('AccessLevel')){
                        return;
               }
               else{
                    System.debug(err);
                    System.debug(err.getMessage());
               }
            }
        }
    }
    public static List<Role_Hierarchy__c> getAllRolesBetween(Role_Hierarchy__c oldParent, Role_Hierarchy__c newParent, Map<Id,Role_Hierarchy__c> mapOfAllRoles, Map<Id, List<Id>> mapOfWithWhoSharesIdByWhoSharesId){
        List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
        //System.debug(oldParent);
        //System.debug(newParent);

        Role_Hierarchy__c tempRole = oldParent;
        if (newParent == null) {
            do {
                if (mapOfWithWhoSharesIdByWhoSharesId.get(tempRole.Id) != null) {
                    for (Id RolesIdShareWith : mapOfWithWhoSharesIdByWhoSharesId.get(tempRole.Id)) {
                        List<Role_Hierarchy__c> listOfRolesINSharingRule = new List<Role_Hierarchy__c>();
                        List<Id> idOfRoleWhoShared = new List<Id>();
                        idOfRoleWhoShared.add(tempRole.Id);
                        customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(RolesIdShareWith), mapOfAllRoles, listOfRolesINSharingRule, mapOfWithWhoSharesIdByWhoSharesId, idOfRoleWhoShared);
                        listOfRolesAbove.addAll(listOfRolesINSharingRule);
                    }
                }
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
            if (mapOfWithWhoSharesIdByWhoSharesId.get(tempRole.Id) != null) {
                for (Id RolesIdShareWith : mapOfWithWhoSharesIdByWhoSharesId.get(tempRole.Id)) {
                    List<Role_Hierarchy__c> listOfRolesINSharingRule = new List<Role_Hierarchy__c>();
                    List<Id> idOfRoleWhoShared = new List<Id>();
                    idOfRoleWhoShared.add(tempRole.Id);
                    idOfRoleWhoShared.add(newParent.Id);
                    customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(RolesIdShareWith), mapOfAllRoles, listOfRolesINSharingRule, mapOfWithWhoSharesIdByWhoSharesId, idOfRoleWhoShared);
                    listOfRolesAbove.addAll(listOfRolesINSharingRule);
                }
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
    public static void getAllRolesBelow(Role_Hierarchy__c enteredRole, Map<Id,Role_Hierarchy__c> mapOfAllRoles, List<Role_Hierarchy__c> listOfRoles, Map<Id, List<Id>> mapOfWhoSharesIdByWithWhoSharesId, List<Id> idOfRoleShareWith){
        if (idOfRoleShareWith.contains(enteredRole.Id)) {
            idOfRoleShareWith.remove(idOfRoleShareWith.indexOf(enteredRole.Id));
            return;
        }
        if (mapOfWhoSharesIdByWithWhoSharesId.get(enteredRole.Id) != null) {
            idOfRoleShareWith.add(enteredRole.Id);
            for (Id roleId : mapOfWhoSharesIdByWithWhoSharesId.get(enteredRole.Id)) {
                listOfRoles.add(mapOfAllRoles.get(roleId));
            }
        }
        for (Role_Hierarchy__c role : mapOfAllRoles.values()) {
            if (role.Parent__c == enteredRole.Id) {
                listOfRoles.add(role);
            }
        }
        List<Role_Hierarchy__c> listOfTempRoles = new list<Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : listOfRoles) {
            customHierarchyService.getAllRolesBelow(role, mapOfAllRoles, listOfTempRoles, mapOfWhoSharesIdByWithWhoSharesId, idOfRoleShareWith);
        }
        listOfRoles.addAll(listOfTempRoles);
        return;
    }
}