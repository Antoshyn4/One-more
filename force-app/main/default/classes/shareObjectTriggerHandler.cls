public with sharing class shareObjectTriggerHandler {
    public void onUpdate(Map<Id, Share_object__c> newMap, Map<Id, Share_object__c> oldMap) {

        Map<Id, List<Id>> mapOfSharedObjectsIdByUserId = new Map<Id, List<Id>>();
        for (Share_object__c shareObject : newMap.values()) {
            List<Id> listOFShareObjectsId = new List<Id>();
            if (mapOfSharedObjectsIdByUserId.get(shareObject.OwnerId) != null) {
                listOFShareObjectsId = mapOfSharedObjectsIdByUserId.get(shareObject.OwnerId);
            }
            listOFShareObjectsId.add(shareObject.Id);
            mapOfSharedObjectsIdByUserId.put(shareObject.OwnerId, listOFShareObjectsId);
        }
        for (Share_object__c shareObject : oldMap.values()) {
            List<Id> listOFShareObjectsId = new List<Id>();
            if (mapOfSharedObjectsIdByUserId.get(shareObject.OwnerId) != null) {
                listOFShareObjectsId = mapOfSharedObjectsIdByUserId.get(shareObject.OwnerId);
            }
            listOFShareObjectsId.add(shareObject.Id);
            mapOfSharedObjectsIdByUserId.put(shareObject.OwnerId, listOFShareObjectsId);
        }
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role.Id, role);
        }

        Map<Id, User_Junction__c> mapOfJunctionUserByUserId = new Map<Id, User_Junction__c>();
        for (User_Junction__c junctionUser : [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE User__c IN: mapOfSharedObjectsIdByUserId.keySet()]) {
            mapOfJunctionUserByUserId.put(junctionUser.User__c, junctionUser);
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
        

        for (Share_object__c newShareObject : newMap.values()) {
            Share_object__c oldShareObject = oldMap.get(newShareObject.Id);
            if (newShareObject.OwnerId != oldShareObject.OwnerId) {
                if (String.isNotBlank(mapOfJunctionUserByUserId.get(newShareObject.OwnerId).Role_Hierarchy__c)) {
                    List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
                    customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(mapOfJunctionUserByUserId.get(newShareObject.OwnerId).Role_Hierarchy__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                    List<Id> listOfUsersId = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove);
                    customHierarchyService.shareRecordWithUsers(mapOfSharedObjectsIdByUserId.get(newShareObject.OwnerId), listOfUsersId, 0);
                }
                if (String.isNotBlank(mapOfJunctionUserByUserId.get(oldShareObject.OwnerId).Role_Hierarchy__c)) {
                    List<Role_Hierarchy__c> listOfRolesBetween = customHierarchyService.getAllRolesBetween(
                        mapOfAllRoles.get(mapOfAllRoles.get(mapOfJunctionUserByUserId.get(oldShareObject.OwnerId).Role_Hierarchy__c).Parent__c),
                        mapOfAllRoles.get(mapOfAllRoles.get(mapOfJunctionUserByUserId.get(newShareObject.OwnerId).Role_Hierarchy__c).Parent__c), mapOfAllRoles);
                    if (listOfRolesBetween.size() != 0) {
                        list<Id> listOfUsersToUnshare = customHierarchyService.getAllUsersIdByRoles(listOfRolesBetween);
                        customHierarchyService.unShareRecordWithUsers(mapOfSharedObjectsIdByUserId.get(oldShareObject.OwnerId), listOfUsersToUnshare);
                    }
                }
            }
        } 
    }
    public void onInsert(Map<Id, Share_object__c> newMap) {

        Map<Id, List<Id>> mapOfSharedObjectsIdByUserId = new Map<Id, List<Id>>();
        for (Share_object__c shareObject : newMap.values()) {
            List<Id> listOFShareObjectsId = new List<Id>();
            if (mapOfSharedObjectsIdByUserId.get(shareObject.OwnerId) != null) {
                listOFShareObjectsId = mapOfSharedObjectsIdByUserId.get(shareObject.OwnerId);
            }
            listOFShareObjectsId.add(shareObject.Id);
            mapOfSharedObjectsIdByUserId.put(shareObject.OwnerId, listOFShareObjectsId);
        }

        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role.Id, role);
        }
        
        Map<Id, User_Junction__c> mapOfJunctionUserByUserId = new Map<Id, User_Junction__c>();
        for (User_Junction__c junctionUser : [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE User__c IN: mapOfSharedObjectsIdByUserId.keySet()]) {
            mapOfJunctionUserByUserId.put(junctionUser.User__c, junctionUser);
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
        
        
        for (Id userId : mapOfSharedObjectsIdByUserId.keySet()) {
            if (mapOfJunctionUserByUserId.get(userId).Role_Hierarchy__c != null) {
                List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(mapOfJunctionUserByUserId.get(userId).Role_Hierarchy__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                System.debug(mapOfSharedObjectsIdByUserId.get(userId));
                List<Id> listOfUsersId = customHierarchyService.getAllUsersIdByRoles(listOfRolesAbove);
                customHierarchyService.shareRecordWithUsers(mapOfSharedObjectsIdByUserId.get(userId), listOfUsersId, 0);
            }
        }
    }
}
