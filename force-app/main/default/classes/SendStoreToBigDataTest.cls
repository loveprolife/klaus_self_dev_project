@isTest
private class SendStoreToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;

        Shop__c c = new Shop__c(
            Account__c = customer.Id,
            Name = 'Hi Fi Corporation NEWCASTLE',
            Shop_Level__c = 'A',
            Entering_Status__c = '',
            Sales_Region__c = 'Hisense Australia',
            City__c = 'CHILLAN',
            Store_No_from_Account__c = '',
            Grid__c = gird1.id,
            CurrencyIsoCode = 'USD'
        );

        insert c;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2055-02-10 00:00:00"}');
		SendStoreToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendStoreToBigData.adoPost();
        Test.stopTest();
    }
}