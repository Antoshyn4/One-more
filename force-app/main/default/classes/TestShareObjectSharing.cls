@isTest 
public with sharing class TestShareObjectSharing {
    @TestSetup
    static void makeUsers(){
        Integer countOfUsers = 3;
        Integer countOfHierarchies = 103;
        List<User> listOfUsers = new List<User>();
        for (Integer i = 0; i < countOfUsers; i++) {
            listOfUsers.add(new User());
        }
        INteger index = 0;
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

        Share_object__c shareOb = new Share_object__c();
        shareOb.Name = 'Test&';
        shareOb.Text__c = 'Some test Text';
        shareOb.OwnerId = '005Dn000000PdEJIA0';
        insert shareOb;

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
        //insert listOfHierarchies;
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
    }
    @isTest 
    static void testRoles(){
        List<User_Junction__c> junUsersId = [SELECT User__c, Role_Hierarchy__c FROM User_Junction__c];
        User_Junction__c junUser = junUsersId[0];
        Map<Id, Role_Hierarchy__c> mapOfAllRoles = new Map<Id,Role_Hierarchy__c>();
        for (Role_Hierarchy__c role : [SELECT Name, Parent__c FROM Role_Hierarchy__c]) {
            mapOfAllRoles.put(role.Id, role);
        }
        //Test.startTest();
        System.debug(customHierarchyService.getAllRolesAbove([SELECT Parent__c FROM Role_Hierarchy__c WHERE Name = 'Level 103'],mapOfAllRoles, new List<Role_Hierarchy__c>()).size());
        //Test.stopTest();
    }
}
