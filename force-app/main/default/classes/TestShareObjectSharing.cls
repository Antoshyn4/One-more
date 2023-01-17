@isTest 
public with sharing class TestShareObjectSharing {
    @TestSetup
    static void makeUsers(){
        Integer countOfUsers = 10;
        Integer countOfHierarchies = 50;
        Integer countOfObjects = 0;
        List<User> listOfUsers = new List<User>();
        for (Integer i = 0; i < countOfUsers; i++) {
            listOfUsers.add(new User());
        }
        Integer index = 0;
        for (User user : listOfUsers) {
            user.LastName = 'Tester&';
            user.Alias = 'Tester';
            user.Email = 'dimamar1003@gmail.com';
            user.Username = ++index + 'Usernamedimamar1003@gmail.com';
            user.CommunityNickname = ++index + 'test12';
            user.LocaleSidKey = 'en_US';
            user.TimeZoneSidKey = 'GMT';
            user.ProfileID = '00eDn000000QallIAC';
            user.LanguageLocaleKey = 'en_US';
            user.EmailEncodingKey = 'UTF-8';
        }
        insert listOfUsers;

        List<Role_Hierarchy__c> listOfHierarchies = new List<Role_Hierarchy__c>();
        for (Integer i = 0; i < countOfHierarchies; i++) {
            Role_Hierarchy__c role = new Role_Hierarchy__c();
            role.Name = 'Level ' + (i + 1);
            if (i > 0) {
                role.Parent__c = listOfHierarchies[i - 1].Id;
            }
            listOfHierarchies.add(role);
            insert role;
        }

        List<User_Junction__c> listOfAllUsers = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c];
        index = 0;
        for (User_Junction__c user : listOfAllUsers) {
            user.Role_Hierarchy__c = listOfHierarchies[index++].Id;
        }
        update listOfAllUsers;
        List<Share_object__c> listOfSharedObjects = new List<Share_object__c>();
        for (Integer i = 0; i < countOfObjects; i++) {
            Share_object__c shareOb = new Share_object__c(); 
            shareOb.Name = 'Test&';
            shareOb.Text__c = 'Some test Text';
            shareOb.OwnerId = listOfAllUsers[listOfAllUsers.size() - 1].User__c;
            listOfSharedObjects.add(shareOb);
        }
        insert listOfSharedObjects;
        

        // List<User> listOfUsers = new List<User>();
        // for (Integer i = 0; i < 11; i++) {
        //     listOfUsers.add(new User());
        // }
        // Integer index = 0;
        // for (User user : listOfUsers) {
        //     user.LastName = 'Tester&';
        //     user.Alias = 'Tester';
        //     user.Email = 'dimamar1003@gmail.com';
        //     user.Username = ++index + 'Usernamedimamar1003@gmail.com';
        //     user.CommunityNickname = ++index + 'test12';
        //     user.LocaleSidKey = 'en_US';
        //     user.TimeZoneSidKey = 'GMT';
        //     user.ProfileID = '00eDn000000QallIAC';
        //     user.LanguageLocaleKey = 'en_US';
        //     user.EmailEncodingKey = 'UTF-8';
        // }
        // insert listOfUsers;

        // List<Role_Hierarchy__c> listOfHierarchies = new List<Role_Hierarchy__c>();
        // for (Integer i = 0; i < 11; i++) {
        //     Role_Hierarchy__c role = new Role_Hierarchy__c();
        //     role.Name = 'Level ' + (i + 1);
        //     if (i > 0) {
        //         role.Parent__c = listOfHierarchies[i - 1].Id;[]
        //     }
        //     listOfHierarchies.add(role);
        //     insert role;
        // }System.debug('asdopjaposd');fh 
        // for (Role_Hierarchy__c role : [SELECT ID FROM Role_Herarchy__C]) {
            
        // }
    }
    @isTest
    static void testShare(){
        // List<User> usersId = new List<User>();
        // usersId = [SELECT Id FROM User WHERE Name = 'Tester&'];
        // Share_object__c shareOb = [SELECT Id FROM Share_object__c WHERE Name = 'Test&'];
        // System.assertEquals(true, customHierarchyService.shareRecordWithUsers(shareOb.Id, usersId, 0));
        // List<Share_object__Share> listOfSharedObject = [SELECT Id, UserOrGroupId, AccessLevel, 
        // RowCause FROM Share_object__Share WHERE ParentId =: shareOb.Id AND UserOrGroupId IN: usersId];
        // System.assertEquals(2, listOfSharedObject.size(), 'Incorrect count of shared objects');
        // System.assertEquals('Edit', listOfSharedObject[0].AccessLevel); 
        // System.assertEquals('Manual', listOfSharedObject[0].RowCause);
        // System.assertEquals(usersId[1], listOfSharedObject[0].UserOrGroupId);
    }
    @isTest
    static void testUsers(){
        List<User_Junction__c> junUsersId = [SELECT User__c FROM User_Junction__c];
        List<User> usersId = [SELECT Id FROM User WHERE Name = 'Tester&'];
        System.debug(junUsersId);
        System.debug(usersId);
        Role_Hierarchy__c role = [SELECT Id FROM Role_Hierarchy__c LIMIT 1];
        update role;
    }
    @isTest 
    static void testUpdateUsersRole(){
        User_Junction__c junctionUserWhoShared = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 4'];
        User UserWhoShared = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared.User__c];
        List<User_Junction__c> listOfjunctionUserWithRole = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE Role_Hierarchy__c != null];
        Set<Id> setOfUserIdWithRole = new Set<Id>();
        for (User_Junction__c junctionUser : listOfjunctionUserWithRole) {
            setOfUserIdWithRole.add(junctionUser.User__c);
        }
        List<User> listOfUsersSharedWith = [SELECT Id FROM User WHERE Id IN: setOfUserIdWithRole];
        List<Role_Hierarchy__c> listOfAllRoles = [SELECT Name FROM Role_Hierarchy__c ORDER BY Name];
        Test.startTest();
        System.runAs(UserWhoShared){
            System.assertEquals(50, [SELECT Id FROM Share_object__c].size());
        }
        junctionUserWhoShared.Role_Hierarchy__c = listOfAllRoles[listOfAllRoles.size() - 1].Id;
        update junctionUserWhoShared;
        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                System.assertEquals(50, [SELECT Id FROM Share_object__c].size());
            }
        }
        // Role_Hierarchy__c roleToUpdate = [SELECT Id, Name FROM Role_Hierarchy__c WHERE Id = : junctionUserWhoShared.Role_Hierarchy__c];
        // roleToUpdate.Name = 'Level 1.1';
        // roleToUpdate.Parent__c = listOfAllRoles[0].Id;
        // update roleToUpdate;
        junctionUserWhoShared.Role_Hierarchy__c = [SELECT Id FROM Role_Hierarchy__c WHERE Name = 'Level 2' LIMIT 1].Id;
        update junctionUserWhoShared;
        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        Share_object__c shareObject = new Share_object__c();
        System.runAs(UserWhoShared){
            shareObject.Name = 'Object to share';
            insert shareObject;
        }
        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                //System.debug([SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE User__c =: user.Id].Role_Hierarchy__r.Name);
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        // System.runAs(UserWhoShared){
        //     System.debug([SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE User__c =: listOfUsersSharedWith[0].Id].Role_Hierarchy__r.Name);
        //     shareObject.OwnerId = listOfUsersSharedWith[0].Id;
        //     update shareObject;
        // }
        for (User user : [SELECT Id FROM User WHERE IsActive = true]) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());  
            }
        }
        Sharing_rules__c sharing = new Sharing_rules__c();
        sharing.Who_share__c = junctionUserWhoShared.Role_Hierarchy__c;
        sharing.Share_with__c = [SELECT Id FROM Role_Hierarchy__c WHERE Name = 'Level 3' LIMIT 1].Id;
        insert sharing;
        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        Test.stopTest();
    }
    @isTest 
    static void testRolesInsertAndUpdate(){
        User_Junction__c junctionUserWhoShared = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 4'];
        User UserWhoShared = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared.User__c];
        List<User_Junction__c> listOfjunctionUserWithRole = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE Role_Hierarchy__c != null];
        Set<Id> setOfUserIdWithRole = new Set<Id>();
        for (User_Junction__c junctionUser : listOfjunctionUserWithRole) {
            setOfUserIdWithRole.add(junctionUser.User__c);
        }
        Test.startTest();
        List<User> listOfUsersSharedWith = [SELECT Id FROM User WHERE Id IN: setOfUserIdWithRole];

        List<Share_object__c> listOfSharedObjects = new List<Share_object__c>();
        System.runAs(UserWhoShared){
            for (Integer i = 0; i < 10; i++) {
                Share_object__c shareOb = new Share_object__c(); 
                shareOb.Name = 'Test&';
                shareOb.Text__c = 'Some test Text';
                listOfSharedObjects.add(shareOb);
            }
            insert listOfSharedObjects;
        }

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }

        Role_Hierarchy__c role = [SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 4' LIMIT 1][0];
        role.Parent__c = [SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 1' LIMIT 1][0].Id;
        update role;

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug(user.Id);
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testUsersInsertAndUpdate(){
        User_Junction__c junctionUserWhoShared = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 4'];
        User UserWhoShared = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared.User__c];
        List<User_Junction__c> listOfjunctionUserWithRole = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE Role_Hierarchy__c != null];
        Set<Id> setOfUserIdWithRole = new Set<Id>();
        for (User_Junction__c junctionUser : listOfjunctionUserWithRole) {
            setOfUserIdWithRole.add(junctionUser.User__c);
        }
        Test.startTest();
        List<User> listOfUsersSharedWith = [SELECT Id FROM User WHERE Id IN: setOfUserIdWithRole];

        List<Share_object__c> listOfSharedObjects = new List<Share_object__c>();
        System.runAs(UserWhoShared){
            for (Integer i = 0; i < 10; i++) {
                Share_object__c shareOb = new Share_object__c(); 
                shareOb.Name = 'Test&';
                shareOb.Text__c = 'Some test Text';
                listOfSharedObjects.add(shareOb);
            }
            insert listOfSharedObjects;
        }

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }

        junctionUserWhoShared.Role_Hierarchy__c = [SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 2' LIMIT 1][0].Id;
        update junctionUserWhoShared;

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug(user.Id);
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        Test.stopTest();
    }
    @isTest 
    static void testSharingRulesAndRolesInsertAndUpdate(){
        User_Junction__c junctionUserWhoShared = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 4'];
        User UserWhoShared = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared.User__c];
        List<User_Junction__c> listOfjunctionUserWithRole = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE Role_Hierarchy__c != null];
        Set<Id> setOfUserIdWithRole = new Set<Id>();
        for (User_Junction__c junctionUser : listOfjunctionUserWithRole) {
            setOfUserIdWithRole.add(junctionUser.User__c);
        }
        Test.startTest();
        List<User> listOfUsersSharedWith = [SELECT Id FROM User WHERE Id IN: setOfUserIdWithRole];

        List<Share_object__c> listOfSharedObjects = new List<Share_object__c>();
        System.runAs(UserWhoShared){
            for (Integer i = 0; i < 10; i++) {
                Share_object__c shareOb = new Share_object__c(); 
                shareOb.Name = 'Test&';
                shareOb.Text__c = 'Some test Text';
                listOfSharedObjects.add(shareOb);
            }
            insert listOfSharedObjects;
        }

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }

        Role_Hierarchy__c role = [SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 4' LIMIT 1][0];
        role.Parent__c = null;
        //[SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 1' LIMIT 1][0].Id;
        role.Name = 'Level 2.1';
        update role;

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug(user.Id);
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }

        Sharing_rules__c sharing = new Sharing_rules__c();
        sharing.Who_share__c = junctionUserWhoShared.Role_Hierarchy__c;
        sharing.Share_with__c = [SELECT Id FROM Role_Hierarchy__c WHERE Name = 'Level 2' LIMIT 1].Id;
        insert sharing;

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug(user.Id);
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        

        sharing = [SELECT Who_share__c, Share_with__c FROM Sharing_rules__c LIMIT 1][0];
        //sharing.Who_share__c = junctionUserWhoShared.Role_Hierarchy__c;
        sharing.Share_with__c = [SELECT Id FROM Role_Hierarchy__c WHERE Name = 'Level 3' LIMIT 1].Id;
        update sharing;

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug(user.Id);
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        
        Test.stopTest();
    }
    @isTest 
    static void testSharingRulesInsertAndUpdate(){
        Role_Hierarchy__c role = [SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 5' LIMIT 1][0];
        role.Parent__c = null;
        //[SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 1' LIMIT 1][0].Id;
        role.Name = 'Level 2.1';
        update role;

        System.debug([SELECT Name, Parent__r.Name FROM Role_Hierarchy__c WHERE Name = 'Level 6' LIMIT 1][0].Parent__r.Name);

        role = [SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 6' LIMIT 1][0];
        role.Parent__c = [SELECT Id FROM Role_Hierarchy__c WHERE Name = 'Level 2.1' LIMIT 1].Id;
        //[SELECT Name FROM Role_Hierarchy__c WHERE Name = 'Level 1' LIMIT 1][0].Id;
        role.Name = 'Level 2.2';
        update role;

        User_Junction__c junctionUserWhoShared = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 3'];
        User_Junction__c junctionUserWhoShared2 = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 2'];
        User UserWhoShared = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared.User__c];
        User UserWhoShared2 = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared2.User__c];
        List<User_Junction__c> listOfjunctionUserWithRole = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE Role_Hierarchy__c != null];
        Set<Id> setOfUserIdWithRole = new Set<Id>();
        for (User_Junction__c junctionUser : listOfjunctionUserWithRole) {
            setOfUserIdWithRole.add(junctionUser.User__c);
        }
        Test.startTest();
        List<User> listOfUsersSharedWith = [SELECT Id FROM User WHERE Id IN: setOfUserIdWithRole];

        List<Share_object__c> listOfSharedObjects = new List<Share_object__c>();
        System.runAs(UserWhoShared){
            for (Integer i = 0; i < 5; i++) {
                Share_object__c shareOb = new Share_object__c(); 
                shareOb.Name = 'Test&';
                shareOb.Text__c = 'Some test Text';
                listOfSharedObjects.add(shareOb);
            }
            insert listOfSharedObjects;
        }

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        
        listOfSharedObjects = new List<Share_object__c>();
        System.runAs(UserWhoShared2){
            for (Integer i = 0; i < 10; i++) {
                Share_object__c shareOb = new Share_object__c(); 
                shareOb.Name = 'Test&';
                shareOb.Text__c = 'Some test Text';
                listOfSharedObjects.add(shareOb);
            }
            insert listOfSharedObjects;
        }

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        junctionUserWhoShared.Role_Hierarchy__c = [SELECT Id, Parent__c FROM Role_Hierarchy__c WHERE Name = 'Level 1' LIMIT 1][0].Id;
        update junctionUserWhoShared;
        
        Sharing_rules__c sharing = new Sharing_rules__c();
        sharing.Who_share__c = [SELECT Id FROM Role_Hierarchy__c WHERE Name = 'Level 1' LIMIT 1].Id;
        sharing.Share_with__c = [SELECT Id FROM Role_Hierarchy__c WHERE Name = 'Level 2.2' LIMIT 1].Id;
        sharing.Name = 'Test';
        insert sharing;

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        Boolean track = false;
        List<Role_Hierarchy__c> listOfAllRoles = [SELECT Name, Parent__c FROM Role_Hierarchy__c LIMIT 10];
        for (Role_Hierarchy__c temp : listOfAllRoles) {
            if (!track) {
                track = true;
                temp.Parent__c = null;
            }
            else {
                track = false;
            }
        }
        update listOfAllRoles;
        
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role5 : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role5.Id, role5);
        }
        Test.stopTest();
        List<Role_Hierarchy_Wrapper> listOfHierarchies = new List<Role_Hierarchy_Wrapper>();
        for (Role_Hierarchy__c TempRole : mapOfAllRoles.values()) {
            if (TempRole.Parent__c == null) {
                Role_Hierarchy_Wrapper wrapper = new Role_Hierarchy_Wrapper(TempRole, mapOfAllRoles);
                listOfHierarchies.add(wrapper);
            }
        }
        System.debug(JSON.serialize(listOfHierarchies));
        // for (Role_Hierarchy_Wrapper wrapper : listOfHierarchies) {
        //     System.debug(wrapper);
        // }
        
        for (Role_Hierarchy__c role2 : [SELECT Name, Parent__r.Name FROM Role_Hierarchy__c]) {
            System.debug(role2.Name + ' ' + role2.Id);
            System.debug(role2.Parent__r.Name);
        }
    }
    @isTest 
    static void testSharing(){
        User_Junction__c junctionUserWhoShared = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 4'];
        User_Junction__c junctionUserWhoShared2 = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 2'];
        User_Junction__c junctionUserWhoShared5 = [SELECT User__c, Role_Hierarchy__r.Name FROM User_Junction__c WHERE Role_Hierarchy__r.Name = 'Level 5'];
        User UserWhoShared = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared.User__c];
        User UserWhoShared2 = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared2.User__c];
        User UserWhoShared5 = [SELECT Id FROM User WHERE Id =: junctionUserWhoShared5.User__c];
        List<User_Junction__c> listOfjunctionUserWithRole = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c WHERE Role_Hierarchy__c != null];
        Set<Id> setOfUserIdWithRole = new Set<Id>();
        for (User_Junction__c junctionUser : listOfjunctionUserWithRole) {
            setOfUserIdWithRole.add(junctionUser.User__c);
        }
        List<User> listOfUsersSharedWith = [SELECT Id FROM User WHERE Id IN: setOfUserIdWithRole];

        List<Share_object__c> listOfSharedObjects = new List<Share_object__c>();
        Test.startTest();

        System.runAs(UserWhoShared2){
            for (Integer i = 0; i < 5; i++) {
                Share_object__c shareOb = new Share_object__c(); 
                shareOb.Name = 'Test&';
                shareOb.Text__c = 'Some test Text';
                listOfSharedObjects.add(shareOb);
            }
            insert listOfSharedObjects;
        }
        listOfSharedObjects = new List<Share_object__c>();
        System.runAs(UserWhoShared){
            for (Integer i = 0; i < 10; i++) {
                Share_object__c shareOb = new Share_object__c(); 
                shareOb.Name = 'Test&';
                shareOb.Text__c = 'Some test Text';
                listOfSharedObjects.add(shareOb);
            }
            insert listOfSharedObjects;
        }

        listOfSharedObjects = new List<Share_object__c>();
        System.runAs(UserWhoShared5){
            for (Integer i = 0; i < 8; i++) {
                Share_object__c shareOb = new Share_object__c(); 
                shareOb.Name = 'Test&';
                shareOb.Text__c = 'Some test Text';
                listOfSharedObjects.add(shareOb);
            }
            insert listOfSharedObjects;
        }

        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        Role_Hierarchy__c role = [SELECT Name, Parent__c FROM Role_Hierarchy__c WHERE Name = 'Level 4' LIMIT 1][0];
        role.Parent__c = null;
        role.Name = 'Level 3.1';
        update role;
        
        for (User user : listOfUsersSharedWith) {
            System.runAs(user){
                for (User_Junction__c temp : [SELECT Role_Hierarchy__r.Name, User__c FROM User_Junction__c Where User__c =: user.id LIMIT 1]) {
                    System.debug(temp.Role_Hierarchy__r.Name);
                }
                System.debug([SELECT Id FROM Share_object__c].size());
            }
        }
        System.debug([SELECT Name, Parent__r.Name FROM Role_Hierarchy__c WHERE Name = 'Level 5' LIMIT 1][0].Parent__r.Name);
        Test.stopTest();
    }
}
