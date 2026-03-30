@isTest
private class QuoteLineItemTriggerHandlerTest {
    static testMethod void testMethod1() {
        Test.startTest();
    	List<Quote__c> quoteList = TestDataUtility.createQuoteList(true);
    	List<Pricebook_Entry__c> pbEntryList = [SELECT Id,Name,Price_Book__c from Pricebook_Entry__c WHERE Price_Book__c=:quoteList[1].Pricebook__c AND Customer_Model_Product__r.Product_Line__c = 'TV' LIMIT 1];
    	QuoteAddProductController.saveSelectedProList(pbEntryList[0].Id,quoteList[1].Id);
    	List<Quote_Product__c> qtItemList = [SELECT Id,Name,Quote_Name__c,Pricebook_Entry__c,Customer_Model_Product__c from Quote_Product__c where Quote_Name__c =:quoteList[1].Id];
    	pbEntryList[0].Product__c = [SELECT Id,Name from Product__c WHERE Name ='TestProductTV001' LIMIT 1].Id;
        update pbEntryList[0];
        Quote_Product__c newQtItem1 = new Quote_Product__c();
    	newQtItem1 = qtItemList[0];
    	newQtItem1.Id = null;
    	newQtItem1.External_ID__c = 'Test Quote Product00001';
        insert newQtItem1;

        Quote__c quoteNew = new Quote__c();
        quoteNew = quoteList[1];
        quoteNew.Id = null;
        insert quoteNew;
        quoteNew.CurrencyIsoCode = 'CNY';
        update quoteNew;
        Quote_Product__c newQtItem2 = new Quote_Product__c();
        newQtItem2 = qtItemList[0];
    	newQtItem2.Id = null;
    	newQtItem2.CurrencyIsoCode = 'CNY';
    	newQtItem2.Quote_Name__c = quoteNew.Id;
    	newQtItem2.External_ID__c = 'Test Quote Product00002';
    	insert newQtItem2;
    	Test.stopTest();
    }
}