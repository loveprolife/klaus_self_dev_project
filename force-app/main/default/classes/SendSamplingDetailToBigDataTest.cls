@isTest
private class SendSamplingDetailToBigDataTest {

    public static String productRecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
    
    static testMethod void testMethod1() {
        Test.startTest();

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = customer.Id;
        sm.Level__c = 'A';
        sm.Shop_Level__c = 'A';
        INSERT sm;
		Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = customer.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        ss.Is_Added__c = '是';
        ss.Level__c = 'A';
        INSERT ss; 
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense South Africa';
        insert store;

        Product__c product = new Product__c();
        product.RecordTypeId = productRecordTypeId;
        product.Product_Line__c = 'TV';
        product.Name = 'NTC-22E-TV';
        product.Sales_Region__c = 'Hisense South Africa';

        Sampling_Detail__c detail = new Sampling_Detail__c();
        detail.Shop__c = store.Id;
        detail.Is_Add__c = '是';
        detail.Display_Status__c = '展出';
        detail.Product__c = product.Id;
        detail.AutomaticallyGenerateSampleStandard__c = true;
        detail.Sampling_Standard__c = ss.id;
        insert detail;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2025-02-10 00:00:00"}');
		SendSamplingDetailToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendSamplingDetailToBigData.adoPost();
        Test.stopTest();
    }
}