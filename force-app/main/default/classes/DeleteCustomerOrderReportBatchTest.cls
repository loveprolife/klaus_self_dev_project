@isTest
private class DeleteCustomerOrderReportBatchTest {
    static testMethod void testMethod1() {

        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA',
        	Type = 'Management',
            Guarantor_Country_Code__c = 'US'
        );
        Database.insert(acc1);

        Order__c order1 = new Order__c();
        order1.Customer__c = acc1.Id;
        order1.Order_Date__c = Date.today();
        order1.Order_Amount__c = 555;
        Database.insert(order1);

        Delivery_Order_Item__c del1 = new Delivery_Order_Item__c();
        del1.Customer__c = acc1.Id;
        del1.order__c = order1.id;
        del1.Delivery_Quantity__c = 555;
        del1.Total_Amount__c = 555;
        Database.insert(del1);
        Delivery_Order_Item__c del2 = new Delivery_Order_Item__c();
        del2.Customer__c = acc1.Id;
        del2.order__c = order1.id;
        del2.Delivery_Quantity__c = 555;
        del2.Total_Amount__c = 555;
        Database.insert(del2);

        Order_Product__c op1 = new Order_Product__c();
        op1.order__c = order1.id;
        op1.Quantity__c = 555;
        Database.insert(op1);
        
        Customer_Order_Report__c cor = new Customer_Order_Report__c();
        cor.order__c = order1.id;
        cor.Customer__c = acc1.id;
        Database.insert(cor);

        DeleteCustomerOrderReportBatch ss  = new DeleteCustomerOrderReportBatch();
		Database.executeBatch(ss,200);
    }
}