public with sharing class userTriggerHandler {
    public void onUpdate(List<User> newList, List<User> oldList) {
        //List<User_Junction__c> listOfJunctions = new List<User_Junction__c>();

    }
    public void onDelete(List<User> newList, List<User> oldList) {
        List<User_Junction__c> listOfJunctions = new List<User_Junction__c>();
        for (User user : oldList) {
            User_Junction__c user_junction = new User_Junction__c();
            user_junction.User__c = user.id;
            listOfJunctions.add(user_junction);
        }
        if (listOfJunctions.size() != 0) {
            delete listOfJunctions;
        }
    }
    public void onInsert(List<User> newList, List<User> oldList) {
        List<User_Junction__c> listOfJunctions = new List<User_Junction__c>();
        for (User user : newList) {
            User_Junction__c user_junction = new User_Junction__c();
            user_junction.User__c = user.Id;
            listOfJunctions.add(user_junction);
        }
        if (listOfJunctions.size() != 0) {
            insert listOfJunctions;
        }
    }
}
