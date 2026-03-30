@isTest
private class Call_GenerateExternalPageUrlTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();

        Test.startTest();
    	
        String json = '{"DATA": [{"billing_type": "ZMK1"}]}';

        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        Call_GenerateExternalPageUrl.generateExternalPageUrl('123');
        Test.stopTest();
    }
}