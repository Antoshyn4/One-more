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
        

        Map<Id, List<Id>> mapOfListOfObjectsIdBywnerId = new  Map<Id, List<Id>>();
        for (Share_object__c ob : [SELECT OwnerId FROM Share_object__c ]) {
            List<Id> listOfObjectsId = new List<Id>();
            if (mapOfListOfObjectsIdBywnerId.get(ob.OwnerId) != null) {
                listOfObjectsId = mapOfListOfObjectsIdBywnerId.get(ob.OwnerId);
            }
            listOfObjectsId.add(ob.Id);
            mapOfListOfObjectsIdBywnerId.put(ob.Id, listOfObjectsId);
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
                    for (Id userId : listOfUsersIdWhoShare) {
                        if (mapOfListOfObjectsIdBywnerId.get(userId) != null) {
                            listOfObjectsId.addAll(mapOfListOfObjectsIdBywnerId.get(userId));
                        }
                    }
                    customHierarchyService.shareRecordWithUsers(listOfObjectsId, listOfUsersIdShareWith, 0);

                    if (oldSharingRule.Who_share__c != newSharingRule.Who_share__c) {
                        listOfObjectsId = new List<id>();
                        listOfUsersIdWhoShare = customHierarchyService.getAllUsersIdByRoles(mapOfAllRolesByList.get(oldSharingRule.Who_share__c)); 
                        listOfRolesAbove = new List<Role_Hierarchy__c>();
                        customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(oldSharingRule.Share_with__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                        listOfUsersIdShareWith = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove); 
                        for (Id userId : listOfUsersIdWhoShare) {
                            if (mapOfListOfObjectsIdBywnerId.get(userId) != null) {
                                listOfObjectsId.addAll(mapOfListOfObjectsIdBywnerId.get(userId));
                            }
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

        
        Map<Id, List<Id>> mapOfListOfObjectsIdBywnerId = new  Map<Id, List<Id>>();
        for (Share_object__c ob : [SELECT OwnerId FROM Share_object__c ]) {
            List<Id> listOfObjectsId = new List<Id>();
            if (mapOfListOfObjectsIdBywnerId.get(ob.OwnerId) != null) {
                listOfObjectsId = mapOfListOfObjectsIdBywnerId.get(ob.OwnerId);
            }
            listOfObjectsId.add(ob.Id);
            mapOfListOfObjectsIdBywnerId.put(ob.Id, listOfObjectsId);
        }
        
        for (Sharing_rules__c sharingRule : newMap.values()) {
            List<Id> listOfUsersIdWhoShare = customHierarchyService.getAllUsersIdByRoles(mapOfAllRolesByList.get(sharingRule.Who_share__c)); 
            List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
            customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(sharingRule.Share_with__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
            List<Id> listOfUsersIdShareWith = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove); 
            if (listOfUsersIdWhoShare.size() > 0 && listOfUsersIdShareWith.size() > 0) {
                List<Id> listOfObjectsId = new List<id>();
                Set<Id> setOfObjectsId = new Set<Id>();
                for (Share_object__Share shareObject : [SELECT ParentId FROM Share_object__Share WHERE UserOrGroupId IN: listOfUsersIdWhoShare]) {
                    setOfObjectsId.add(shareObject.ParentId);
                }
                for (Id userId : setOfObjectsId) {
                    if (mapOfListOfObjectsIdBywnerId.get(userId) != null) {
                        listOfObjectsId.addAll(mapOfListOfObjectsIdBywnerId.get(userId));
                    }
                }
                customHierarchyService.shareRecordWithUsers(listOfObjectsId, listOfUsersIdShareWith, 0);
            }
        }
    }
}
