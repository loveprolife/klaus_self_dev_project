@isTest
private class UpdateSAPSalesActualTest {
    static testMethod void testMethod1() {
    	ID accId = TestDataUtility.createAccount('BatchTest', '0000504263', '0000504263', 'Hisense USA');
    	Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
    	customerProductLine.Product_Line_Name__c = 'TV';
    	customerProductLine.Customer__c = accId;
    	customerProductLine.Management_Customer__c = accId;
    	customerProductLine.Classification__c = 'Customer of Oversea Company';
    	customerProductLine.Development_Stage__c = 'Undeveloped';
    	customerProductLine.Prospective_Rank__c = 'Normal Customer';
        Database.insert(customerProductLine);
    	Order__c order = new Order__c();
    	order.Customer__c = accId;
    	order.Order_Classification__c = 'E';
    	Database.insert(order);
    	Order_Product__c orderProduct = new Order_Product__c();
    	orderProduct.Order__c = order.Id;
    	orderProduct.Total_Sales_Amount__c = 1111;
    	Database.insert(orderProduct);
    	Sales_Target__c salesTarget = new Sales_Target__c();
    	salesTarget.Customer_Name__c = accId;
    	salesTarget.Customer_Product_Line__c = customerProductLine.Id;
    	salesTarget.Hisense_Entity__c = '8510';
    	salesTarget.Year__c = '2019';
    	Database.insert(salesTarget);
        SAP_Sales_Actual__c salesActual = new SAP_Sales_Actual__c();
        salesActual.Year__c = '2019';
        salesActual.Month__c = '1';
        salesActual.Date__c = '1';
        salesActual.Order_Item_No__c = orderProduct.Id;
        salesActual.Customer__c = accId;
        salesActual.Customer_Product_Line__c = customerProductLine.Id;
        salesActual.Sales_Orgnization__c = '8510';
        salesActual.CurrencyIsoCode = 'CNY';
        Database.insert(salesActual);
        UpdateSAPSalesActual salesActualBatch = new UpdateSAPSalesActual();
        //SalesTarget 报表
        Database.executeBatch(salesActualBatch,200);
    }
}