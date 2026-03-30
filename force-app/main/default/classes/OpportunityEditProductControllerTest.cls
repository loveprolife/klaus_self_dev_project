@isTest
private class OpportunityEditProductControllerTest {
    static testMethod void testMethod1() {
        Test.startTest();
    	List<Product__c> proList = TestDataUtility.createProductList();
        Opportunity__c thisOpp = new Opportunity__c();
        thisOpp.Name = 'Test Opp000111';
        thisOpp.Opportunity_Product_Type__c = 'TV';
        insert thisOpp;

        Opportunity_Product__c oppItem = new Opportunity_Product__c();
        oppItem.Opportunity__c = thisOpp.Id;
        oppItem.Product__c = proList[1].Id;
        insert oppItem;
        Opportunity_Product__c oppItem1 = new Opportunity_Product__c();
        oppItem1.Opportunity__c = thisOpp.Id;
        oppItem1.Product__c = proList[0].Id;
        OpportunityEditProductController.initData(thisOpp.Id);
        OpportunityEditProductController.saveOppProduct(new List<Opportunity_Product__c>{oppItem1},thisOpp.Id);
        OpportunityEditProductController.saveOppProduct(new List<Opportunity_Product__c>(),thisOpp.Id);
        Test.stopTest();
    }
}