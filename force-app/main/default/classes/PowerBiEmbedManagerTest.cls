@isTest
private class PowerBiEmbedManagerTest {
    
    static testMethod void testHandle1() {
        test.startTest();
        String json = '{"token_type": "Bearer", "expires_in": 3599, "ext_expires_in": 3599, "access_token": "111"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json, 200));
        PowerBiEmbedManager.getEmbeddingDataForReport('111','222');
        test.stopTest();
    }

    static testMethod void testHandle2() {
        test.startTest();
        String json = '{"token_type": "Bearer", "expires_in": 3599, "ext_expires_in": 3599, "access_token": "111"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json, 400));
        PowerBiEmbedManager.getEmbeddingDataForReport('111','222');
        test.stopTest();
    }
}