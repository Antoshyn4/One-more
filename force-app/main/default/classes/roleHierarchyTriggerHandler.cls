public with sharing class roleHierarchyTriggerHandler {
    public static Boolean tracker = false;
    public void onUpdate(Map<Id, Role_Hierarchy__c> newMap, Map<Id, Role_Hierarchy__c> oldMap) {
        List<Role_Hierarchy__c> listOfRolesToUpdate = new List<Role_Hierarchy__c>();
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role.Id, role);
        }
        List<User_Junction__c> listOfUsersJunctionWithRole = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE Role_Hierarchy__c IN: newMap.values()];

        Map<Id, List<Id>> mapOfUsersIdByRoleId = new Map<Id, List<Id>>();
        for (User_Junction__c user : listOfUsersJunctionWithRole) {
            List<Id> listOfUsersIdByRole = new List<Id>();
            if (mapOfUsersIdByRoleId.get(user.Role_Hierarchy__c) != null) {
                listOfUsersIdByRole = mapOfUsersIdByRoleId.get(user.Role_Hierarchy__c);
            }
            listOfUsersIdByRole.add(user.User__c);
            mapOfUsersIdByRoleId.put(user.Role_Hierarchy__c, listOfUsersIdByRole);
        }

        Map<Id, List<Id>> mapOfWithWhoSharesIdByWhoSharesId = new Map<Id, List<Id>>();
        for (Sharing_rules__c shareingRule : [SELECT Who_share__c, Share_with__c FROM Sharing_rules__c]) {
            List<Id> listOfRolesId = new List<Id>();
            if (mapOfWithWhoSharesIdByWhoSharesId.get(shareingRule.Who_share__c) != null) {
                listOfRolesId = mapOfWithWhoSharesIdByWhoSharesId.get(shareingRule.Who_share__c);
            }
            listOfRolesId.add(shareingRule.Share_with__c);
            mapOfWithWhoSharesIdByWhoSharesId.put(shareingRule.Who_share__c, listOfRolesId);
        }

        Map<Id, List<Id>> mapOfListOfObjectsIdBywnerId = new  Map<Id, List<Id>>();
        for (Share_object__c ob : [SELECT OwnerId FROM Share_object__c ]) {
            List<Id> listOfObjectsId = new List<Id>();
            if (mapOfListOfObjectsIdBywnerId.get(ob.OwnerId) != null) {
                listOfObjectsId = mapOfListOfObjectsIdBywnerId.get(ob.OwnerId);
            }
            listOfObjectsId.add(ob.Id);
            mapOfListOfObjectsIdBywnerId.put(ob.OwnerId, listOfObjectsId);
        }

        Map<Id, List<Id>> mapOfAllUsersIdByRoleId = new Map<Id, List<Id>>();
        for (User_Junction__c user : [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c]) {
            List<Id> listUsersId = new List<Id>();
            if (mapOfAllUsersIdByRoleId.get(user.Role_Hierarchy__c) != null) {
                listUsersId = mapOfAllUsersIdByRoleId.get(user.Role_Hierarchy__c);
            }
            listUsersId.add(user.User__c);
            mapOfAllUsersIdByRoleId.put(user.Role_Hierarchy__c, listUsersId);
        }
        
        for (Role_Hierarchy__c newRole : newMap.values()) {
            Role_Hierarchy__c oldRole = oldMap.get(newRole.Id);
            if (newRole.Parent__c != oldRole.Parent__c) {
                List<Role_Hierarchy__c> listOfRolesAbove =  new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(newRole, mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                listOfRolesAbove.remove(listOfRolesAbove.indexOf(newRole));
                List<Id> listOfUsersId = new List<Id>();
                for (Role_Hierarchy__c role : listOfRolesAbove) {
                    if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                        listOfUsersId.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                    }
                }
                List<Id> listOfObjectsId = new List<id>();
                if (mapOfUsersIdByRoleId.get(newRole.Id) != null) {
                    for (Id usersId : mapOfUsersIdByRoleId.get(newRole.Id)) {
                        if (mapOfListOfObjectsIdBywnerId.get(usersId) != null) {
                            listOfObjectsId.addAll(mapOfListOfObjectsIdBywnerId.get(usersId));
                        }
                    }
                }
                customHierarchyService.shareRecordWithUsersById(listOfObjectsId, listOfUsersId);
                List<Role_Hierarchy__c> listOfRolesBetween = customHierarchyService.getAllRolesBetween(mapOfAllRoles.get(oldRole.Parent__c), mapOfAllRoles.get(newRole.Parent__c), mapOfAllRoles, mapOfWithWhoSharesIdByWhoSharesId);
                if (listOfRolesBetween.size() != 0) {
                    list<Id> listOfUsersToUnshare = new List<Id>();
                    for (Role_Hierarchy__c role : listOfRolesBetween) {
                        if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                            listOfUsersToUnshare.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                        }
                    }
                    customHierarchyService.unShareRecordWithUsers(listOfObjectsId, listOfUsersToUnshare);
                }
                for (Role_Hierarchy__c role : mapOfAllRoles.values()) {
                    if (role.Parent__c == oldRole.Id) {
                        role.Parent__c = oldRole.Parent__c;
                        listOfRolesToUpdate.add(role);
                    }
                }
            }
        }
        System.debug(listOfRolesToUpdate);
        if (listOfRolesToUpdate.size() != 0 && roleHierarchyTriggerHandler.tracker == false) {
            roleHierarchyTriggerHandler.tracker = true;
            System.debug(listOfRolesToUpdate);
            Id jobID = Database.executeBatch(new updateRolesBatch(listOfRolesToUpdate));
        }
    }
    public void onInsert(List<Role_Hierarchy__c> newList, List<Role_Hierarchy__c> oldList) {
        // for (Role_Hierarchy__c role : newList) {
        //     if (String.isNotBlank(role.Pa)) {
                
        //     }
        // }   
    }
}