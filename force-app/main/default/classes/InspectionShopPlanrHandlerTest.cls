@isTest
private class InspectionShopPlanrHandlerTest {
    static testMethod void testHandler() {
        Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
        isp.Inspection_Year__c = '2023';
        isp.Inspection_Month__c = '1';
        
		test.startTest();
        INSERT isp;
		test.stopTest();        
    }
}