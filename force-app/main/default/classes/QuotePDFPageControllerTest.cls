@isTest
private class QuotePDFPageControllerTest {
    static testMethod void testMethod1() {
        Test.startTest();
    	List<Quote__c> quoteList = TestDataUtility.createQuoteList(true);
    	List<Pricebook_Entry__c> pbEntryList = [SELECT Id,Name,Price_Book__c from Pricebook_Entry__c WHERE Price_Book__c=:quoteList[1].Pricebook__c AND Customer_Model_Product__r.Product_Line__c = 'TV' LIMIT 1];
    	QuoteAddProductController.saveSelectedProList(pbEntryList[0].Id,quoteList[1].Id);
    	List<Quote_Product__c> qtItemList = [SELECT Id,Name from Quote_Product__c where Quote_Name__c =:quoteList[1].Id];
    	for(Quote_Product__c qtItem : qtItemList){
            qtItem.Quantity__c = 10;
            qtItem.Number_of_Containers__c = 5;
    	}
    	update qtItemList;
        QuotePDFGenerationController.getQuote(quoteList[1].Id);
    	ApexPages.CurrentPage().getParameters().put('ID',quoteList[1].Id);
    	QuotePDFPageController qtPDF = new QuotePDFPageController();
    	Test.stopTest();
    }
}