public with sharing class accountTriggerHandler {
    public static Boolean isFromLWC = true;
    public void onBeforeUpdate(List<Account> oldList, List<Account> newList) {
        if (accountTriggerHandler.isFromLWC) {
            for (Account oldAcc : oldList) {
                for (Account newAcc : newList) {
                    if (oldAcc.Name != newAcc.Name) {
                        newAcc.Name = oldAcc.Name;
                        System.debug(My_page_settings__c.getValues('First Page').Error_text__c);
                    }
                }
            }
        }
    }   
}
