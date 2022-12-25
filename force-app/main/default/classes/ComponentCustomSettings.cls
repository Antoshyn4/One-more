public class ComponentCustomSettings {

    @AuraEnabled
    public static String getAllObjectsWithChild(){
        Map<String,List<String>> mapOfParents = new Map<String,List<String>>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        for(Schema.SObjectType d : gd.values())
        { 
            if(!d.getDescribe().isCreateable())
                continue;
            Schema.DescribeSObjectResult ds = d.getDescribe();
            List<String> listOfChilds = new List<String>();
            for (Schema.ChildRelationship cr: ds.getChildRelationships()) {
                if (cr.getRelationshipName() == null) 
                    continue;
                listOfChilds.add(cr.getRelationshipName());
            }
            mapOfParents.put(d.getDescribe().getName(), listOfChilds);
        }
        return JSON.serialize(mapOfParents);
    }
    @AuraEnabled
    public static Dependencies__c getObjectsName(){
        Dependencies__c d = Database.query('SELECT Parent__c, Child__c FROM Dependencies__c LIMIT 1');
        System.debug(d);
        return d;
    }
    @AuraEnabled
    public static Sort_Acc__c getSortSettings(){
        return Sort_Acc__c.getValues('Default');
    }
    @AuraEnabled
    public static void setOrder(Boolean isDesc, String sortBy){
        System.debug(isDesc + ' ' + sortBy);
        Sort_Acc__c customSetting = Sort_Acc__c.getInstance('Default');
        customSetting.SortBy__c = sortBy;
        customSetting.isDesc__c = isDesc ? 'DESC' : 'ASC';
        update customSetting;
    }
    @AuraEnabled
    public static List<SObject> getAccountList(String parentName, String childName){
        String query;
        query = 'SELECT Name, CreatedDate, (SELECT ';
        String field;
        switch on childName {
            when  'Contacts'{
                query += 'Name';
            }
            when 'Cases'{
                query += 'CaseNumber';
            }
        }
        query += ' FROM '+ childName + ')  FROM '+ parentName;
        System.debug(query);
        return Database.query(query);
    }
    @AuraEnabled(cacheable=true)
    public static My_page_settings__c getCustomSettings(){
        return My_page_settings__c.getValues('First Page');
    }
    @AuraEnabled(cacheable=true)
    public static SObject getAllAccountRecords(Id accid){
        System.debug(accId);
        String name = accid.getSObjectType().getDescribe().getName();
        Schema.FieldSet allAccountFields;
        switch on name {
            when  'Account'{
                allAccountFields = Schema.SObjectType.Account.fieldSets.All_Fields;
            }
            when 'Contact'{
                allAccountFields = Schema.SObjectType.Contact.fieldSets.All_Fields;
            }
            when 'Case'{
                allAccountFields = Schema.SObjectType.Case.fieldSets.All_Fields;
            }
        }
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : allAccountFields.getFields()){
            if (f.getFieldPath() != 'Tier'){
                query += f.getFieldPath() + ', ';
            }
        }
        query = query.substring(0,query.length() - 2);
        query += ' FROM ' + name + ' WHERE Id = \'';
        query += accid + '\'';
        return Database.query(query);   
    }
    @AuraEnabled
    public static string getNameById(Id objectId){
        return objectId.getSObjectType().getDescribe().getName();
    }
    @AuraEnabled(cacheable=true)
    public static String doSearch(String search, String parentName, String childName){
        System.debug('o');
        String field;
        List<List<SObject>> searchList = new List<List<SObject>>();
        switch on parentName {
            when  'Account'{
                searchList = [FIND :search IN All FIELDS 
                RETURNING Account(Id), Contact(AccountId, Id)];
            }
            when 'Contact'{
                searchList = [FIND :search IN All FIELDS 
                RETURNING Contact(Id), Case(ContactId, Id)];
            }
        } 
        List<wrapper> listOfAcc = new List<wrapper>();
        List<Id> parentIds = new List<Id>();
        List<Id> childIds = new List<Id>();
        List<Id> parentIdFromChild = new List<Id>();
        for (SObject ob : searchList[0]) {
            parentIds.add((Id)ob.get('Id'));
        }
        System.debug( searchList[1]);
        for (SObject ob : searchList[1]) {
            if (childName == 'Contacts') {
                if (!parentIdFromChild.contains((Id)ob.get('AccountId'))) {
                    parentIdFromChild.add((Id)ob.get('AccountId'));
                }
            } else {
                if (!parentIdFromChild.contains((Id)ob.get('ContactId'))) {
                    parentIdFromChild.add((Id)ob.get('ContactId'));
                }
            }
            childIds.add((Id)ob.get('Id'));
        }
        for (Id accId : parentIdFromChild) { 
            if (parentIds.contains(accId)) {
                parentIds.remove(parentIds.indexOf(accId));
                break;
            }
        }
        System.debug(parentIds);
        System.debug(parentIdFromChild);
        parentIds.addAll(parentIdFromChild);
        String query = 'SELECT Name, (SELECT ';
        switch on childName {
            when  'Contacts'{
                query += 'Name';
            }
            when 'Cases'{
                query += 'CaseNumber';
            }
        }
        query += ' FROM ' + childName + ' WHERE Id IN :childIds) FROM ' + parentName + ' WHERE Id IN :parentIds'; 
        System.debug(query);
        System.debug(Database.query(query));
        for (SObject acc : Database.query(query)) {
            wrapper wr = new wrapper();
            wr.Account = acc;
            if (parentIdFromChild.contains(acc.Id)) {
                wr.isAccount = false;
                System.debug(acc);
            }
            else {
                wr.isAccount = true;
            }
            listOfAcc.add(wr);
        }
        System.debug(listOfAcc);
        return JSON.serialize(listOfAcc);
    }
}
