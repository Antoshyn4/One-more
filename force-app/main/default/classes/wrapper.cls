public with sharing class wrapper {
    public SObject Account;
    public Boolean isAccount;

    public Object doSJON(){
        return JSON.serialize(this);
    }
}