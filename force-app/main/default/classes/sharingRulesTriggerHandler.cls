public with sharing class sharingRulesTriggerHandler {
    public void onUpdate(Map<Id, Sharing_rules__c> newMap, Map<Id, Sharing_rules__c> oldMap) {
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id, Role_Hierarchy__c>();
        Map<Id, List<Role_Hierarchy__c>> mapOfAllRolesByList = new Map<Id, List<Role_Hierarchy__c>>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            List<Role_Hierarchy__c> listRoles = new List<Role_Hierarchy__c>();
            listRoles.add(role);
            mapOfAllRolesByList.put(role.Id, listRoles);
            mapOfAllRoles.put(role.Id, role);
        }


        Map<Id, List<Id>> mapOfWithWhoSharesIdByWhoSharesId = new Map<Id, List<Id>>();
        System.debug([SELECT Who_share__c, Share_with__c FROM Sharing_rules__c]);
        for (Sharing_rules__c shareingRule : [SELECT Who_share__c, Share_with__c FROM Sharing_rules__c]) {
            List<Id> listOfRolesId = new List<Id>();
            if (mapOfWithWhoSharesIdByWhoSharesId.get(shareingRule.Who_share__c) != null) {
                listOfRolesId = mapOfWithWhoSharesIdByWhoSharesId.get(shareingRule.Who_share__c);
            }
            listOfRolesId.add(shareingRule.Share_with__c);
            mapOfWithWhoSharesIdByWhoSharesId.put(shareingRule.Who_share__c, listOfRolesId);
        }
        

        
        for (Sharing_rules__c newSharingRule : newMap.values()) {
            Sharing_rules__c oldSharingRule = oldMap.get(newSharingRule.Id);
            if (oldSharingRule.Who_share__c != newSharingRule.Who_share__c || oldSharingRule.Share_with__c != newSharingRule.Share_with__c) {
                List<Id> listOfUsersIdWhoShare = customHierarchyService.getAllUsersIdByRoles(mapOfAllRolesByList.get(newSharingRule.Who_share__c)); 
                List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(newSharingRule.Share_with__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                List<Id> listOfUsersIdShareWith = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove); 

                if (listOfUsersIdWhoShare.size() > 0 && listOfUsersIdShareWith.size() > 0) {
                    List<Id> listOfObjectsId = new List<id>();
                    for (Share_object__c ob : [SELECT Id, OwnerId FROM Share_object__c WHERE OwnerId IN: listOfUsersIdWhoShare]) {
                        listOfObjectsId.add(ob.Id);
                    }
                    customHierarchyService.shareRecordWithUsers(listOfObjectsId, listOfUsersIdShareWith, 0);

                    if (oldSharingRule.Who_share__c != newSharingRule.Who_share__c) {
                        listOfObjectsId = new List<id>();
                        listOfUsersIdWhoShare = customHierarchyService.getAllUsersIdByRoles(mapOfAllRolesByList.get(oldSharingRule.Who_share__c)); 
                        listOfRolesAbove = new List<Role_Hierarchy__c>();
                        customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(oldSharingRule.Share_with__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                        listOfUsersIdShareWith = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove); 
                        for (Share_object__c ob : [SELECT Id, OwnerId FROM Share_object__c WHERE OwnerId IN: listOfUsersIdWhoShare]) {
                            listOfObjectsId.add(ob.Id);
                        }
                        customHierarchyService.unShareRecordWithUsers(listOfObjectsId, listOfUsersIdShareWith);
                    }

                    else if (oldSharingRule.Share_with__c != newSharingRule.Share_with__c) {
                        List<Role_Hierarchy__c> listOfRolesToUnshare = customHierarchyService.getAllRolesBetween(mapOfAllRoles.get(oldSharingRule.Share_with__c), mapOfAllRoles.get(newSharingRule.Share_with__c), mapOfAllRoles);
                        List<Id> listOfUsersIdToUnshare = customHierarchyService.getAllUsersIdByRoles(listOfRolesToUnshare);
                        customHierarchyService.unShareRecordWithUsers(listOfObjectsId, listOfUsersIdToUnshare);
                    }
                }
            }
        }
    }
    public void onInsert(Map<Id, Sharing_rules__c> newMap) {
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id, Role_Hierarchy__c>();
        Map<Id, List<Role_Hierarchy__c>> mapOfAllRolesByList = new Map<Id, List<Role_Hierarchy__c>>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            List<Role_Hierarchy__c> listRoles = new List<Role_Hierarchy__c>();
            listRoles.add(role);
            mapOfAllRolesByList.put(role.Id, listRoles);
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
        
        for (Sharing_rules__c sharingRule : newMap.values()) {
            List<Id> listOfUsersIdWhoShare = customHierarchyService.getAllUsersIdByRoles(mapOfAllRolesByList.get(sharingRule.Who_share__c)); 
            List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
            customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(sharingRule.Share_with__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
            List<Id> listOfUsersIdShareWith = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove); 
            if (listOfUsersIdWhoShare.size() > 0 && listOfUsersIdShareWith.size() > 0) {
                List<Id> listOfObjectsId = new List<id>();
                // for (User user : listOfUsersIdWhoShare) {
                //     System.runAs(user){
                //         for (Share_object__c ob : [SELECT Id, OwnerId FROM Share_object__c]) {
                //             listOfObjectsId.add(ob.Id);
                //         }
                //     }
                // }
                for (Share_object__c ob : [SELECT Id, OwnerId FROM Share_object__c WHERE OwnerId IN: listOfUsersIdWhoShare]) {
                    listOfObjectsId.add(ob.Id);
                }
                customHierarchyService.shareRecordWithUsers(listOfObjectsId, listOfUsersIdShareWith, 0);
            }
        }
    }
}
