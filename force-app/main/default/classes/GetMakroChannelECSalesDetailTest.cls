@isTest
private class GetMakroChannelECSalesDetailTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();

        Test.startTest();
    	
        String json = '{"DATA": [{"billing_type": "ZMK1"}]}';

        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        GetMakroChannelECSalesDetail.getAll();
        Test.stopTest();
    }
}