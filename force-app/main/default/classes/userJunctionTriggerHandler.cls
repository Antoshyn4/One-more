public with sharing class userJunctionTriggerHandler {
    public void onUpdate(Map<Id, User_Junction__c> oldMap, Map<Id, User_Junction__c> newMap) {
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role.Id, role);
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

        Map<Id, List<Id>> mapOfWithWhoSharesIdByWhoSharesId = new Map<Id, List<Id>>();
        for (Sharing_rules__c shareingRule : [SELECT Who_share__c, Share_with__c FROM Sharing_rules__c]) {
            List<Id> listOfRolesId = new List<Id>();
            if (mapOfWithWhoSharesIdByWhoSharesId.get(shareingRule.Who_share__c) != null) {
                listOfRolesId = mapOfWithWhoSharesIdByWhoSharesId.get(shareingRule.Who_share__c);
            }
            listOfRolesId.add(shareingRule.Share_with__c);
            mapOfWithWhoSharesIdByWhoSharesId.put(shareingRule.Who_share__c, listOfRolesId);
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
        
        for (User_Junction__c newUser : newMap.values()) {
            User_Junction__c oldUser = oldMap.get(newUser.Id);
            if (oldUser.Role_Hierarchy__c != newUser.Role_Hierarchy__c) {
                List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(newUser.Role_Hierarchy__c),mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                List<Id> listOfUsersId = new List<Id>();
                for (Role_Hierarchy__c role : listOfRolesAbove) {
                    if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                        listOfUsersId.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                    }
                }
                if (listOfUsersId.contains(newUser.User__c)) {
                    listOfUsersId.remove(listOfUsersId.indexOf(newUser.User__c));
                } 
                customHierarchyService.shareRecordWithUsersById(mapOfListOfObjectsIdBywnerId.get(newUser.User__c), listOfUsersId);
                List<Id> listOfObjects = new List<Id>();
                if (mapOfAllUsersIdByRoleId.get(newUser.Role_Hierarchy__c) != null) {
                    for (Id userId : mapOfAllUsersIdByRoleId.get(newUser.Role_Hierarchy__c)) {
                        if (userId != newUser.User__c && mapOfSharedOrOwneredObjectsIdByUserId.get(userId) != null) {
                            listOfObjects.addAll(mapOfSharedOrOwneredObjectsIdByUserId.get(userId));
                        }
                    }
                }
                if (mapOfSharedOrOwneredObjectsIdByUserId.get(newUser.User__c) != null) {
                    for (Id objectId : mapOfSharedOrOwneredObjectsIdByUserId.get(newUser.User__c)) {
                        if (listOfObjects.contains(objectId)) {
                            listOfObjects.remove(listOfObjects.indexOf(objectId));
                        }
                    }
                }
                List<Id> listOfOneUser = new List<Id>();
                listOfOneUser.add(newUser.User__c);
                customHierarchyService.shareRecordWithUsersById(listOfObjects, listOfOneUser);
                if (mapOfAllRoles.get(oldUser.Role_Hierarchy__c) != null) {
                    List<Role_Hierarchy__c> listOfRolesBetween = customHierarchyService.getAllRolesBetween(mapOfAllRoles.get(oldUser.Role_Hierarchy__c), mapOfAllRoles.get(newUser.Role_Hierarchy__c), mapOfAllRoles, mapOfWithWhoSharesIdByWhoSharesId);
                    //System.debug(listOfRolesBetween);
                    if (listOfRolesBetween.size() != 0) {
                        list<Id> listOfUsersToUnshare = new List<Id>();
                        for (Role_Hierarchy__c role : listOfRolesBetween) {
                            if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                                listOfUsersToUnshare.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                            }
                        }
                        if (mapOfListOfObjectsIdBywnerId.get(newUser.User__c) != null) {
                            customHierarchyService.unShareRecordWithUsers(mapOfListOfObjectsIdBywnerId.get(newUser.User__c), listOfUsersToUnshare);
                        }
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

        Map<Id, List<Id>> mapOfListOfObjectsIdBywnerId = new  Map<Id, List<Id>>();
        for (Share_object__c ob : [SELECT OwnerId FROM Share_object__c ]) {
            List<Id> listOfObjectsId = new List<Id>();
            if (mapOfListOfObjectsIdBywnerId.get(ob.OwnerId) != null) {
                if (mapOfListOfObjectsIdBywnerId.get(ob.OwnerId) != null) {
                    listOfObjectsId = mapOfListOfObjectsIdBywnerId.get(ob.OwnerId);
                }
            }
            listOfObjectsId.add(ob.Id);
            mapOfListOfObjectsIdBywnerId.put(ob.OwnerId, listOfObjectsId);
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

        for (User_Junction__c newUser : newMap.values()) {
            if (String.isNotBlank(newUser.Role_Hierarchy__c)) {
                List<Role_Hierarchy__c> listOfRolesAbove = new List<Role_Hierarchy__c>();
                customHierarchyService.getAllRolesAbove(mapOfAllRoles.get(newUser.Role_Hierarchy__c), mapOfAllRoles, listOfRolesAbove, mapOfWithWhoSharesIdByWhoSharesId, null);
                List<Id> listOfUsersId = new List<Id>();
                for (Role_Hierarchy__c role : listOfRolesAbove) {
                    if (mapOfAllUsersIdByRoleId.get(role.Id) != null) {
                        listOfUsersId.addAll(mapOfAllUsersIdByRoleId.get(role.Id));
                    }
                }
                // List<Id> listOfObjectsId = new List<id>();
                // for (Share_object__c ob : [SELECT Id, OwnerId FROM Share_object__c WHERE OwnerId =: newUser.User__c]) {
                //     listOfObjectsId.add(ob.Id);
                // }
                customHierarchyService.shareRecordWithUsersById(mapOfListOfObjectsIdBywnerId.get(newUser.User__c), listOfUsersId);
                List<Id> listOfObjects = new List<Id>();
                if (mapOfAllUsersIdByRoleId.get(newUser.Role_Hierarchy__c) != null) {
                    for (Id userId : mapOfAllUsersIdByRoleId.get(newUser.Role_Hierarchy__c)) {
                        if (mapOfSharedOrOwneredObjectsIdByUserId.get(userId) != null) {
                            listOfObjects.addAll(mapOfSharedOrOwneredObjectsIdByUserId.get(userId));
                        }
                    }
                }
                List<Id> listOfOneUser = new List<Id>();
                listOfOneUser.add(newUser.User__c);
                customHierarchyService.shareRecordWithUsersById(listOfObjects, listOfOneUser);
            }
        }
    }
}