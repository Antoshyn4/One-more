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
    public static My_page_settings__c geTestPageCount(){
        My_page_settings__c page = My_page_settings__c.getValues('First Page');
        return page;
    }
}
