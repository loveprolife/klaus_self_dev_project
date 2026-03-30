@istest
public with sharing class SalesGoalTriggerHandlerHelper2Test {
    
    public static Account customer;
    public static Shop__c store;
    public static User promoter;
    public static Product__c product;
    public static String productRecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
    @TestSetup
    static void makeData(){
        customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        insert store;
        
        product = new Product__c();
        product.Name = '65A65G';
        product.RecordTypeId = productRecordTypeId;
        insert product;
        
        promoter = new User();
        promoter.Username = 'testPromoterUser12138@test004.com';
        promoter.lastname = 'testPromoterUser12138';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%促销员%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Country = 'ZA';
        insert promoter;

        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Shop_Name__c = store.Id;
        promoterRes.Principal__c = promoter.Id;
        promoterRes.RecordType__c = '促销员';
        insert promoterRes;
    }

    @istest
    static void test1() {
        insert new SalesGoal__c(
            IsSplit__c = true,
            IsActive__c = true,
            Year__c = System.today().year() + '',
            Month__c = System.today().month() + '',
            Store__c = [select id from shop__c limit 1].Id,
            ResponsiblePerson__c = [select id from Responsible_Person__c limit 1].Id,
            ProductLine__c = 'TV',
            Amounts__c = 10000,
            Quantities__c = 100,
            RecordTypeId = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Month').getRecordTypeId()
        );
    }
}