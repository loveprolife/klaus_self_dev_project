@isTest
private class QuoteEditProductControllerTest {
    static testMethod void testMethod1() {
        Test.startTest();
    	List<Pricebook__c> pbList = TestDataUtility.createPriceBookList();
    	Account acc = new Account(
        	Name = 'Test Customer for Quote'

        );
        insert acc;
    	Quote__c testQuote = new Quote__c(
        	Name = 'Test SD Quote',
        	Customer_Name__c = acc.Id,
            RecordTypeId = Utility.getRecordTypeMapBySobj('Quote__c').get('Quote_Sales_Department_TV'),
            Product_Line__c = 'TV',
            Pricebook__c = pbList[0].Id,
            CurrencyIsoCode = 'USD'

        );
        insert testQuote;
        List<Pricebook_Entry__c> pbEntryList = [SELECT Id,Name from Pricebook_Entry__c WHERE Price_Book__c=:pbList[0].Id AND Product__r.Product_Line__c = 'TV' LIMIT 2];
        String proIdString = pbEntryList[0].Id + ';' + pbEntryList[1].Id;
        QuoteAddProductController.saveSelectedProList(proIdString,testQuote.Id);
        QuoteEditProductController.initData(testQuote.Id);
        List<Quote_Product__c> qpList = [SELECT Id,CurrencyIsoCode FROM Quote_Product__c WHERE Quote_Name__c =:testQuote.Id];
        qpList[0].CurrencyIsoCode = 'CNY';
        QuoteEditProductController.saveQuoteProduct(new List<Quote_Product__c>{qpList[0]},testQuote.Id);
        Test.stopTest();
    }
}