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

        
        for (Sharing_rules__c newSharingRule : newMap.values()) {
            Sharing_rules__c oldSharingRule = oldMap.get(newSharingRule.Id);
            if (oldSharingRule.Who_share__c != newSharingRule.Who_share__c || oldSharingRule.Share_with__c != newSharingRule.Share_with__c) {
                List<Id> listOfUsersIdWhoShare = mapOfAllUsersIdByRoleId.get(newSharingRule.Who_share__c);
                List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(newSharingRule.Share_with__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                List<Id> listOfUsersIdShareWith = new List<Id>();
                for (Role_Hierarchy__c role : listOfRolesAbove) {
                    if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                        listOfUsersIdShareWith.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                    }
                }

                if (listOfUsersIdWhoShare.size() > 0 && listOfUsersIdShareWith.size() > 0) {
                    List<Id> listOfObjectsId = new List<id>();
                    for (Id userId : listOfUsersIdWhoShare) {
                        if (mapOfListOfObjectsIdBywnerId.get(userId) != null) {
                            listOfObjectsId.addAll(mapOfListOfObjectsIdBywnerId.get(userId));
                        }
                    }
                    customHierarchyService.shareRecordWithUsersById(listOfObjectsId, listOfUsersIdShareWith);

                    if (oldSharingRule.Who_share__c != newSharingRule.Who_share__c) {
                        listOfObjectsId = new List<id>();
                        listOfUsersIdWhoShare = mapOfAllUsersIdByRoleId.get(oldSharingRule.Who_share__c);
                        listOfRolesAbove = new List<Role_Hierarchy__c>();
                        customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(oldSharingRule.Share_with__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                        listOfUsersIdShareWith = new List<Id>();
                        for (Role_Hierarchy__c role : listOfRolesAbove) {
                            if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                                listOfUsersIdShareWith.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                            }
                        }
                        for (Id userId : listOfUsersIdWhoShare) {
                            if (mapOfListOfObjectsIdBywnerId.get(userId) != null) {
                                listOfObjectsId.addAll(mapOfListOfObjectsIdBywnerId.get(userId));
                            }
                        }
                        customHierarchyService.unShareRecordWithUsers(listOfObjectsId, listOfUsersIdShareWith);
                    }

                    else if (oldSharingRule.Share_with__c != newSharingRule.Share_with__c) {
                        List<Role_Hierarchy__c> listOfRolesToUnshare = customHierarchyService.getAllRolesBetween(mapOfAllRoles.get(oldSharingRule.Share_with__c), mapOfAllRoles.get(newSharingRule.Share_with__c), mapOfAllRoles, mapOfWithWhoSharesIdByWhoSharesId);
                        List<Id> listOfUsersIdToUnshare = new List<Id>();
                        for (Role_Hierarchy__c role : listOfRolesToUnshare) {
                            if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                                listOfUsersIdToUnshare.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                            }
                        }
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

        Map<Id, List<Id>> mapOfSharedOrOwneredObjectsIdByUserId = new Map<Id, List<Id>>();
        for (Share_object__Share shareObject : [SELECT ParentId, UserOrGroupId FROM Share_object__Share]) {
            List<Id> lsitOfObjectsId = new List<Id>();
            if (mapOfSharedOrOwneredObjectsIdByUserId.get(shareObject.UserOrGroupId) != null) {
                lsitOfObjectsId = mapOfSharedOrOwneredObjectsIdByUserId.get(shareObject.UserOrGroupId);
            }
            lsitOfObjectsId.add(shareObject.ParentId);
            mapOfSharedOrOwneredObjectsIdByUserId.put(shareObject.UserOrGroupId, lsitOfObjectsId);
        }
        mapOfSharedOrOwneredObjectsIdByUserId.putAll(mapOfListOfObjectsIdBywnerId);
        
        for (Sharing_rules__c sharingRule : newMap.values()) {
            List<Id> listOfUsersIdWhoShare = mapOfAllUsersIdByRoleId.get(sharingRule.Who_share__c);
            List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
            customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(sharingRule.Share_with__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
            List<Id> listOfUsersIdShareWith = new List<Id>();
            for (Role_Hierarchy__c role : listOfRolesAbove) {
                if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                    listOfUsersIdShareWith.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                }
            }
            if (listOfUsersIdWhoShare.size() > 0 && listOfUsersIdShareWith.size() > 0) {
                List<Id> listOfObjectsId = new List<id>();
                for (Id userId : listOfUsersIdWhoShare) {
                    if (mapOfSharedOrOwneredObjectsIdByUserId.get(userId) != null) {
                        listOfObjectsId.addAll(mapOfSharedOrOwneredObjectsIdByUserId.get(userId));
                    }
                }
                customHierarchyService.shareRecordWithUsersById(listOfObjectsId, listOfUsersIdShareWith);
            }
        }
    }
}