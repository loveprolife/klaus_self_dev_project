@isTest
private class QuoteButtonHandlerControllerTest {
    static testMethod void testMethod1() {
        Test.startTest();
    	List<Quote__c> quoteList = TestDataUtility.createQuoteList(true);
    	List<User> userList = TestDataUtility.createUserList(true);
    	List<Pricebook_Entry__c> pbEntryList = [SELECT Id,Name,Price_Book__c from Pricebook_Entry__c WHERE Price_Book__c=:quoteList[0].Pricebook__c AND Product__r.Product_Line__c = 'TV'];
    	String proIdString = '';
    	for(Pricebook_Entry__c pbEntry : pbEntryList){
            proIdString += pbEntry.Id + ';';
    	}
    	QuoteAddProductController.saveSelectedProList(proIdString,quoteList[0].Id);
    	//没有填写成本组人员
    	QuoteButtonHandlerController.submitToCost(quoteList[0].Id);
    	quoteList[0].Cost_Staff__c = userList[1].Id;
    	update quoteList[0];
    	//没有需要需要询价的产品
    	QuoteButtonHandlerController.submitToCost(quoteList[0].Id);
    	List<Quote_Product__c> qtItemList = [SELECT Id,Name FROM Quote_Product__c WHERE Quote_Name__c =:quoteList[0].Id];
    	qtItemList[0].Need_to_Provide_EXW__c = 'YES';
    	qtItemList[0].Cost_Type__c = 'EXW';
    	qtItemList[0].Cost__c = 100;
    	update qtItemList[0];
    	QuoteButtonHandlerController.submitToCost(quoteList[0].Id);
    	//已经提交成本组询价
    	QuoteButtonHandlerController.submitToCost(quoteList[0].Id);
    	quoteList[0].Approval_Status__c = 'Approved';
    	update quoteList[0];
    	//当前状态的报价不能再提交到成本组
    	QuoteButtonHandlerController.submitToCost(quoteList[0].Id);
        
    	QuoteButtonHandlerController.confirmCostPrice(quoteList[0].Id);
    	qtItemList[0].Need_to_Provide_EXW__c = 'NO';
    	update qtItemList[0];
    	//没有需要需要询价的产品
    	QuoteButtonHandlerController.confirmCostPrice(quoteList[0].Id);
    	//已经确认过成本价
    	QuoteButtonHandlerController.confirmCostPrice(quoteList[0].Id);
    	Test.stopTest();
    }
    static testMethod void testMethod2() {
        Test.startTest();
        List<Quote__c> quoteList = TestDataUtility.createQuoteList(true);
    	//失效日期必须在今天之后
    	QuoteButtonHandlerController.submitForApproval(quoteList[0].Id);
    	quoteList[0].Expiry_Date__c = System.today().addDays(10);
    	update quoteList[0];
    	//必须先维护产品线最小毛利润
    	QuoteButtonHandlerController.submitForApproval(quoteList[0].Id);
    	Customer_Product_Line__c cpl = new Customer_Product_Line__c();
    	cpl.Customer__c = quoteList[0].Customer_Name__c;
    	cpl.Product_Line_Name__c = 'TV';
        cpl.Minimum_Gross_Profit_Margin_Level__c = 10;
        insert cpl;
        //提交审批前先添加产品
        QuoteButtonHandlerController.submitForApproval(quoteList[0].Id);
    	List<Pricebook_Entry__c> pbEntryList = [SELECT Id,Name,Price_Book__c from Pricebook_Entry__c WHERE Price_Book__c=:quoteList[0].Pricebook__c AND Product__r.Product_Line__c = 'TV'];
    	String proIdString = '';
    	for(Pricebook_Entry__c pbEntry : pbEntryList){
            proIdString += pbEntry.Id + ';';
    	}
    	QuoteAddProductController.saveSelectedProList(proIdString,quoteList[0].Id);
    	//报价产品必填字段必须填写
    	QuoteButtonHandlerController.submitForApproval(quoteList[0].Id);
    	List<Quote_Product__c> qtItemList = [SELECT Id,Name FROM Quote_Product__c WHERE Quote_Name__c =:quoteList[0].Id];
    	for(Quote_Product__c qtItem : qtItemList){
            qtItem.Quantity__c = 10;
            qtItem.Unit_Sell_In_Price__c = 1000;
            qtItem.Delivery_Form__c = 'CKD';
    	}
    	update qtItemList;
    	QuoteButtonHandlerController.submitForApproval(quoteList[0].Id);
    	//当前报价状态不能提交审批
        QuoteButtonHandlerController.submitForApproval(quoteList[0].Id);
        Test.stopTest();
    }
    static testMethod void testMethod3() {
        Test.startTest();
        List<Quote__c> quoteList = TestDataUtility.createQuoteList(true);
        QuoteButtonHandlerController.submitForAbandon(quoteList[0].Id);
        //只有草稿或者拒绝状态的报价才能废弃
        QuoteButtonHandlerController.submitForAbandon(quoteList[0].Id);
        List<Pricebook_Entry__c> pbEntryList = [SELECT Id,Name,Price_Book__c from Pricebook_Entry__c WHERE Price_Book__c=:quoteList[0].Pricebook__c AND Product__r.Product_Line__c = 'TV'];
    	String proIdString = '';
    	for(Pricebook_Entry__c pbEntry : pbEntryList){
            proIdString += pbEntry.Id + ';';
    	}
    	QuoteAddProductController.saveSelectedProList(proIdString,quoteList[0].Id);
    	QuoteButtonHandlerController.copyQuoteInfo(quoteList[0].Id);
        Test.stopTest();
    }
}