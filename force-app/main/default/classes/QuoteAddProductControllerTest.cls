@isTest
public class QuoteAddProductControllerTest {
    static testMethod void testMethod1() {
    	Test.startTest();
    	List<Pricebook__c> pbList = TestDataUtility.createPriceBookList();
        pbList[0].Name = 'SD PB Name Change';
        update pbList[0];
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
        List<Pricebook_Entry__c> pbEntryList = [SELECT Id,Name from Pricebook_Entry__c WHERE Price_Book__c=:pbList[0].Id LIMIT 1];

        QuoteAddProductController.initData(testQuote.Id);
        QuoteAddProductController.getSearchResultList(new List<String>{'TV'},'test',testQuote.Id);
        QuoteAddProductController.saveSelectedProList(pbEntryList[0].Id,testQuote.Id);
        

        Quote__c testQuote1 = new Quote__c(
        	Name = 'Test USA Quote',
        	Customer_Name__c = [SELECT Id from Account where SAP_Customer_Code__c='1234567890'].Id,
            RecordTypeId = Utility.getRecordTypeMapBySobj('Quote__c').get('Quote_USA_CE'),
            Product_Line__c = 'TV'

        );
        insert testQuote1;
        testQuote1.Pricebook__c = null;
        update testQuote1;
        List<Pricebook_Entry__c> pbEntryList1 = [SELECT Id,Name from Pricebook_Entry__c WHERE Price_Book__c=:pbList[1].Id LIMIT 1];
        QuoteAddProductController.initData(testQuote1.Id);
        QuoteAddProductController.getSearchResultList(new List<String>{'TV'},'test',testQuote1.Id);
        testQuote1.CurrencyIsoCode = 'CNY';
        update testQuote1;
        QuoteAddProductController.saveSelectedProList(pbEntryList1[0].Id,testQuote1.Id);
        Test.stopTest();
    }
}