@isTest
private class SendSamplingInspectionToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();
        Id profileId2 = [SELECT Id,Name FROM profile where PermissionsModifyAllData=true AND PermissionsViewAllProfiles=true ].GET(0).Id;
        User user1 = new User(alias = '巡店员', email='test777@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing777', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId2, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test777@noemail.com');
        INSERT user1;
        
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.Inspection_Year__c = String.valueOf(System.today().year());
        ispTest.Inspection_Month__c = String.valueOf(System.today().month());
        ispTest.OwnerId = user1.Id;
        INSERT ispTest;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        INSERT shop1;

        Date date1 = Date.today();
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        ist.Inspection_Plan__c = ispTest.id;
        ist.Inspection_Date__c = date1;
        INSERT ist;

        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        //si.Sample_Images__r = testSImg.id;
        INSERT si;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2025-02-10 00:00:00"}');
		SendSamplingInspectionToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendSamplingInspectionToBigData.adoPost();
        Test.stopTest();
    }
}