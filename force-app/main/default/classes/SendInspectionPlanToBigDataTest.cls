@isTest
private class SendInspectionPlanToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Id profileId2 = [SELECT Id,Name FROM profile where PermissionsModifyAllData=true AND PermissionsViewAllProfiles=true ].GET(0).Id;

        User user1 = new User(alias = '巡店员', email='test777@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing777', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId2, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test777@noemail.com');
        INSERT user1;

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.Inspection_Year__c = String.valueOf(System.today().year());
        ispTest.Inspection_Month__c = String.valueOf(System.today().month());
        ispTest.OwnerId = user1.Id;
        INSERT ispTest;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2025-02-10 00:00:00"}');
		SendInspectionPlanToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendInspectionPlanToBigData.adoPost();
        Test.stopTest();
    }
}