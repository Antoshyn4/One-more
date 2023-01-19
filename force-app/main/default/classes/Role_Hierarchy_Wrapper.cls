public with sharing class Role_Hierarchy_Wrapper {
    @AuraEnabled
    public Role_Hierarchy__c Role {get; set;}
    @AuraEnabled
    public List<Role_Hierarchy_Wrapper> Childs {get; set;}
    @AuraEnabled
    public Boolean showChilds {get; set;}
    @AuraEnabled
    public List<User> listOfAssignedUsers;
    @AuraEnabled
    public List<Share_object__c> listOfSharedObjects;
    
    
    public Role_Hierarchy_Wrapper(Role_Hierarchy__c role, Map<Id, Role_Hierarchy__c> mapOfAllRoles, Map<Id, List<User>> mapOfAllUsersByRoleId, Map<Id, List<Id>> mapOfSharedOrOwneredObjectsIdByUserId, Map<Id, Share_object__c> mapOfSharedObjectsById, Map<Id, List<Id>> mapOfWhoSharesIdByWithWhoSharesId) {
        this.Role = role;
        this.Childs = Role_Hierarchy_Wrapper.getListOfChilds(this, mapOfAllRoles, mapOfAllUsersByRoleId, mapOfSharedOrOwneredObjectsIdByUserId, mapOfSharedObjectsById, mapOfWhoSharesIdByWithWhoSharesId);
        if (role.Name == 'Lone wolf') {
            System.debug(this.Childs);
        }
        this.listOfAssignedUsers = mapOfAllUsersByRoleId.get(role.Id);
        this.listOfSharedObjects = new List<Share_object__c>();
        if (mapOfAllUsersByRoleId.get(role.Id) != null) {
            for (User user : mapOfAllUsersByRoleId.get(role.Id)) {
                if (mapOfSharedOrOwneredObjectsIdByUserId.get(user.Id) != null) {
                    for (Id sharedObjectId : mapOfSharedOrOwneredObjectsIdByUserId.get(user.Id)) {
                        if (mapOfSharedObjectsById.get(sharedObjectId) != null && !this.listOfSharedObjects.contains(mapOfSharedObjectsById.get(sharedObjectId))) {
                            this.listOfSharedObjects.add(mapOfSharedObjectsById.get(sharedObjectId));
                        }
                    }
                }
            }
        }
        else {
            List<Id> listOfUsersIdUnderRole = new List<Id>();
            List<Role_Hierarchy_Wrapper> listOfChilds = new List<Role_Hierarchy_Wrapper>();
            listOfChilds.addAll(this.Childs);
            if (mapOfWhoSharesIdByWithWhoSharesId.get(role.Id) != null) {
                for (Id roleId : mapOfWhoSharesIdByWithWhoSharesId.get(role.Id)) {
                    Role_Hierarchy_Wrapper wrapper = new Role_Hierarchy_Wrapper(mapOfAllRoles.get(roleId), mapOfAllRoles, mapOfAllUsersByRoleId, mapOfSharedOrOwneredObjectsIdByUserId, mapOfSharedObjectsById, mapOfWhoSharesIdByWithWhoSharesId);
                    listOfChilds.addAll(wrapper.Childs);
                }
            }
            List<Role_Hierarchy__c> listOfRoles = new List<Role_Hierarchy__c>();
            customHierarchyService.getAllRolesBelow(role, mapOfAllRoles, listOfRoles, mapOfWhoSharesIdByWithWhoSharesId, new List<Id>());
            listOfUsersIdUnderRole = customHierarchyService.getAllUsersIdByRoles(listOfRoles);
            if (listOfUsersIdUnderRole != null) {
                for (Id userId : listOfUsersIdUnderRole) {
                    if (mapOfSharedOrOwneredObjectsIdByUserId.get(userId) != null) {
                        for (Id sharedObjectId : mapOfSharedOrOwneredObjectsIdByUserId.get(userId)) {
                            if (!this.listOfSharedObjects.contains(mapOfSharedObjectsById.get(sharedObjectId))) {
                                this.listOfSharedObjects.add(mapOfSharedObjectsById.get(sharedObjectId));
                            }
                        }
                    }
                }
            }
        }
        if (role.Name == 'Lone wolf') {
            System.debug(this.Childs);
        }
    }
    private static List<Role_Hierarchy_Wrapper> getListOfChilds(Role_Hierarchy_Wrapper enteredRole, Map<Id,Role_Hierarchy__c> mapOfAllRoles, Map<Id, List<User>> mapOfAllUsersByRoleId, Map<Id, List<Id>> mapOfSharedOrOwneredObjectsIdByUserId, Map<Id, Share_object__c> mapOfSharedObjectsById, Map<Id, List<Id>> mapOfWhoSharesIdByWithWhoSharesId){
        List<Role_Hierarchy_Wrapper> listOfChildsRole = new List<Role_Hierarchy_Wrapper>();
        for (Role_Hierarchy__c role : mapOfAllRoles.values()) {
            if(role.Parent__c == enteredRole.Role.Id){
                Role_Hierarchy_Wrapper newWrappedRole = new Role_Hierarchy_Wrapper(role, mapOfAllRoles, mapOfAllUsersByRoleId, mapOfSharedOrOwneredObjectsIdByUserId, mapOfSharedObjectsById, mapOfWhoSharesIdByWithWhoSharesId);
                listOfChildsRole.add(newWrappedRole);
            }
        }
        return listOfChildsRole;
    }
    @AuraEnabled
    public static List<Role_Hierarchy_Wrapper> getAllRoles(){
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role5 : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role5.Id, role5);
        }

        Map<Id, User> mapOfUsersById = new Map<Id, User>();
        for (User user : [SELECT Id, Name FROM User]) {
            mapOfUsersById.put(user.Id, user);
        }

        Map<Id, List<User>> mapOfAllUsersByRoleId = new Map<Id, List<User>>();
        for (User_Junction__c user : [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c]) {
            List<User> listUsersId = new List<User>();
            if (mapOfAllUsersByRoleId.get(user.Role_Hierarchy__c) != null) {
                listUsersId = mapOfAllUsersByRoleId.get(user.Role_Hierarchy__c);
            }
            listUsersId.add(mapOfUsersById.get(user.User__c));
            mapOfAllUsersByRoleId.put(user.Role_Hierarchy__c, listUsersId);
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

        Map<Id, Share_object__c> mapOfSharedObjectsById = new Map<Id, Share_object__c>();
        for (Share_object__c shareObject : [SELECT Id, Name, Text__c FROM Share_object__c]) {
            mapOfSharedObjectsById.put(shareObject.Id, shareObject);
        }

        Map<Id, List<Id>> mapOfWhoSharesIdByWithWhoSharesId = new Map<Id, List<Id>>();
        for (Sharing_rules__c sharingRule : [SELECT Who_share__c, Share_with__c FROM Sharing_rules__c]) {
            List<Id> listOfRolesId = new List<Id>();
            if (mapOfWhoSharesIdByWithWhoSharesId.get(sharingRule.Share_with__c) != null) {
                listOfRolesId = mapOfWhoSharesIdByWithWhoSharesId.get(sharingRule.Share_with__c);
            }
            listOfRolesId.add(sharingRule.Who_share__c);
            mapOfWhoSharesIdByWithWhoSharesId.put(sharingRule.Share_with__c, listOfRolesId);
        }

        List<Role_Hierarchy_Wrapper> listOfHierarchies = new List<Role_Hierarchy_Wrapper>();
        for (Role_Hierarchy__c TempRole : mapOfAllRoles.values()) {
            if (TempRole.Parent__c == null) {
                Role_Hierarchy_Wrapper wrapper = new Role_Hierarchy_Wrapper(TempRole, mapOfAllRoles, mapOfAllUsersByRoleId, mapOfSharedOrOwneredObjectsIdByUserId, mapOfSharedObjectsById, mapOfWhoSharesIdByWithWhoSharesId);
                listOfHierarchies.add(wrapper);
                if (TempRole.Name == 'Head_of_first') {
                    System.debug(wrapper);
                    System.debug(wrapper.listOfAssignedUsers);
                }
            }
        }
        return listOfHierarchies;
    }
}