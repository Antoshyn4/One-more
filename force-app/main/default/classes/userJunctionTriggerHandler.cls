public with sharing class userJunctionTriggerHandler {
    public void onUpdate(Map<Id, User_Junction__c> oldMap, Map<Id, User_Junction__c> newMap) {
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role.Id, role);
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
        
        for (User_Junction__c newUser : newMap.values()) {
            User_Junction__c oldUser = oldMap.get(newUser.Id);
            if (oldUser.Role_Hierarchy__c != newUser.Role_Hierarchy__c) {
                List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(newUser.Role_Hierarchy__c),mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                List<Id> listOfUsersId = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove);
                List<Id> listOfObjectsId = new List<id>();
                for (Share_object__c ob : [SELECT Id, OwnerId FROM Share_object__c WHERE OwnerId =: newUser.User__c]) {
                    listOfObjectsId.add(ob.Id);
                }  
                customHierarchyService.shareRecordWithUsers(listOfObjectsId, listOfUsersId, 0);
                if (mapOfAllRoles.get(oldUser.Role_Hierarchy__c) != null) {
                    List<Role_Hierarchy__c> listOfRolesBetween = customHierarchyService.getAllRolesBetween(mapOfAllRoles.get(oldUser.Role_Hierarchy__c), mapOfAllRoles.get(newUser.Role_Hierarchy__c), mapOfAllRoles);
                    System.debug(listOfRolesBetween);
                    if (listOfRolesBetween.size() != 0) {
                        list<Id> listOfUsersToUnshare = customHierarchyService.getAllUsersIdByRoles(listOfRolesBetween);
                        customHierarchyService.unShareRecordWithUsers(listOfObjectsId, listOfUsersToUnshare);
                    }
                }
            }
        }
    }
    public void onInsert(Map<Id, User_Junction__c> newMap){
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role.Id, role);
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
        

        for (User_Junction__c newUser : newMap.values()) {
            if (String.isNotBlank(newUser.Role_Hierarchy__c)) {
                List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(newUser.Role_Hierarchy__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                List<Id> listOfUsersId = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove);
                List<Id> listOfObjectsId = new List<id>();
                for (Share_object__c ob : [SELECT Id, OwnerId FROM Share_object__c WHERE OwnerId =: newUser.User__c]) {
                    listOfObjectsId.add(ob.Id);
                }
                customHierarchyService.shareRecordWithUsers(listOfObjectsId, listOfUsersId, 0);
            }
        }
    }
}
