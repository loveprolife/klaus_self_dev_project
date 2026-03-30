@isTest
private class QuoteTriggerHandlerTest {
    static testMethod void testMethod1() {
        Test.startTest();
    	List<Quote__c> quoteList = TestDataUtility.createQuoteList(false);
    	insert quoteList;
    	Account acc1 = new Account(
        	Name = 'Test Customer for Quote',
        	Price_Book_Region__c = 'East Malaysia'

        );
        insert acc1;
        Account acc2 = new Account(
        	Name = 'Test Customer for Quote',
        	Price_Book_Region__c = 'West Malaysia'

        );
        insert acc2;
        //马来西亚报价创建
        quoteList[3].Id = null;
        quoteList[3].Customer_Name__c = acc1.Id;
        insert quoteList[3];
        //名称重复校验
        quoteList[0].Name = 'Test USA CE Quote';
        update quoteList[0];
        
        List<Pricebook_Entry__c> pbEntryList = [SELECT Id,Name,Price_Book__c from Pricebook_Entry__c WHERE Price_Book__c=:quoteList[1].Pricebook__c AND Customer_Model_Product__r.Product_Line__c = 'TV' LIMIT 1];
        
        //美国报价改变客户,无报价产品
        quoteList[1].Customer_Name__c = acc1.Id;
        update quoteList[1];
        quoteList[1].Pricebook__c = pbEntryList[0].Price_Book__c;
        update quoteList[1];
        QuoteAddProductController.saveSelectedProList(pbEntryList[0].Id,quoteList[1].Id);
        //美国报价改变币种,有报价产品
        quoteList[1].CurrencyIsoCode = 'CNY';
        update quoteList[1];
        //美国报价改变客户,有报价产品
        quoteList[1].Customer_Name__c = acc2.Id;
        update quoteList[1];
        //马来西亚报价改变客户
        quoteList[3].Customer_Name__c = acc2.Id;
        update quoteList[3];
        Test.stopTest();
        
    }
}