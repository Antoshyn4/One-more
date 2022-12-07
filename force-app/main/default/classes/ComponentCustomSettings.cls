public class ComponentCustomSettings {

    @AuraEnabled(cacheable=true)
    public static Integer getAllCount(){
        My_page_settings__c page = My_page_settings__c.getValues('First Page');
        Decimal val = page.All_elements_count__c;
        return Integer.valueOf(val);
    }
    @AuraEnabled(cacheable=true)
    public static Integer getColumnsCount(){
        My_page_settings__c page = My_page_settings__c.getValues('First Page');
        Decimal val = page.Columns_count__c;
        return Integer.valueOf(val);
    }
    @AuraEnabled(cacheable=true)
    public static Integer getPageElementsCount(){
        My_page_settings__c page = My_page_settings__c.getValues('First Page');
        return  Integer.valueOf(page.On_page_elements_count__c);
    }
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getAccountList(){
        List<AggregateResult> listOfAccounts = [SELECT COUNT(AccountId), Account.Name accName, Account.Id accId FROM Contact WHERE AccountId != null GROUP BY Account.Name, Account.Id];
        for (AggregateResult aggr : listOfAccounts){
            System.debug(aggr.get('accName'));
            System.debug(aggr.get('accId'));
            System.debug(aggr.get('expr0'));
        }
        return listOfAccounts;
    }
}
