@isTest
private class InsertDailySalesQueueableTest {

    static testMethod void testMethod1(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='InsertDailySalesQueueableTest@noemail.com',
        emailencodingkey='UTF-8', lastname='InsertDailySalesQueueableTest', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='InsertDailySalesQueueableTest@noemail.com',Sales_Region__c='Hisense South Africa');
        INSERT user1;

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c shop = new Shop__c();
        shop.Name = 'Hi Fi Corporation NEWCASTLE';
        shop.Account__c = customer.Id;
        shop.Sales_Region__c = 'Hisense South Africa';
        insert shop;

        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        productTest.Name = 'NTC-33K';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'DELOITTE';
        productTest.Sales_Region__c = 'Hisense South Africa';
        Insert productTest;

        List<Promoter_Daily_Report__c> addReportList = new List<Promoter_Daily_Report__c>();
        Map<String,List<Retail_Number__c>> tempMap = new Map<String,List<Retail_Number__c>>();

        Promoter_Daily_Report__c newDir = new Promoter_Daily_Report__c();
        newDir.Shop__c = shop.Id;
        newDir.Report_Date__c = Date.today();
        newDir.ExternalId__c = '1-1-1-1-1-1';
        addReportList.add(newDir);

        Retail_Number__c dailySales = new Retail_Number__c();
        dailySales.Product__c = productTest.Id;
        dailySales.Price__c = 1;
        dailySales.Number__c = 1;
        dailySales.TotalPrice__c = 1;
        dailySales.Shop__c = shop.id;
        dailySales.Customer__c = customer.id;

        String key = shop.Id + '_' + user1.Id + '_' + Date.today();
        if (tempMap.containsKey(key)) {
            tempMap.get(key).add(dailySales);
        }else{
            tempMap.put(key, new List<Retail_Number__c>{dailySales});
        }
        System.runAs(user1){
            Test.startTest();
            InsertDailySalesQueueable idsq = new InsertDailySalesQueueable(addReportList, tempMap);
            ID jobID = System.enqueueJob(idsq);
            Test.stopTest();
        }
    }
}