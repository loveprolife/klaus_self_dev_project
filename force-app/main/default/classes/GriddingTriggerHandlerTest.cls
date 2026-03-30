@isTest
private class GriddingTriggerHandlerTest {

    static testMethod void testHandler() {
        Gridding__c gird1 = new Gridding__c();
        gird1.Name = 'test002';
        gird1.Gridding_Level__c = 'B';
        gird1.Gridding_Code__c  = 'J01-J001';
        INSERT gird1;

        gird1.Name = 'test001';
        gird1.Gridding_Code__c = 'J01-J002';
        UPDATE gird1;
        
    }

}