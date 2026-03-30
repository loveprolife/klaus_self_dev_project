@isTest
private class OpportunityAddProductControllerTest {
    static testMethod void testMethod1() {
    	Test.startTest();
    	List<Product__c> proList = TestDataUtility.createProductList();
        Opportunity__c thisOpp = new Opportunity__c();
        thisOpp.Name = 'Test Opp000111';
        thisOpp.Opportunity_Product_Type__c = 'TV';
        insert thisOpp;
        OpportunityAddProductController.initData(thisOpp.Id);
        OpportunityAddProductController.getSearchResultList(new List<String>{'TV'},'test',thisOpp.Id);
        OpportunityAddProductController.getSelectedProList(proList[0].Id,thisOpp.Id);
        Opportunity_Product__c oppItem = new Opportunity_Product__c();
        oppItem.Opportunity__c = thisOpp.Id;
        oppItem.Product__c = proList[1].Id;
        OpportunityAddProductController.saveOppProduct(new List<Opportunity_Product__c>());
        OpportunityAddProductController.saveOppProduct(new List<Opportunity_Product__c>{oppItem});
        Test.stopTest();
    }
}