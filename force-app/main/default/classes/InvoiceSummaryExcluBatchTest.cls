@isTest
private class InvoiceSummaryExcluBatchTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();
        ID accId = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        TestDataUtility.createCustomerModelProduct('H359BI-WD', null,null);
        TestDataUtility.createCustomerModelProduct('H359BI-WD1', 'Hisense USA','TV');
        //Cooking用出口型号
        TestDataUtility.createProduct('65M7000UWG');
        //电视  手机用工厂型号
        TestDataUtility.createProduct('HA65M7000UWTG');
        //冰冷洗用工厂型号建relation
        TestDataUtility.createProductRelation('HA65M7000UWTG');

        //添加产品线
        TestDataUtility.insertMapping('62','Refrigerator');
        TestDataUtility.insertMapping('65', 'Cooking');
        TestDataUtility.insertMapping('14', 'TV');

        Mapping__c mpp1 = new Mapping__c();
        mpp1.Name = '0104';
        mpp1.Mapping_Code__c = 'TV';
        mpp1.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Scope and Product Line Mapping').getRecordTypeId();
        Database.insert(mpp1);

        Order__c order = new Order__c(
            Customer__c = accId,
            SAP_Order_No__c = '4500004397',
            External_Key__c = '45000043970000504263'
        );
        Database.insert(order);
        Order_Product__c orderProduct = new Order_Product__c();
        orderProduct.Order__c = order.Id;
        orderProduct.External_Key__c = '4500004397000010';
        Database.insert(orderProduct);
        Delivery_Order__c deliveryOrder = new Delivery_Order__c();
        deliveryOrder.Customer__c = accId;
        deliveryOrder.SAP_Delivery_Order_No__c = '0080002649';
        Database.insert(deliveryOrder);
        Delivery_Order_Item__c doi = new Delivery_Order_Item__c();
        doi.Delivery_Order__c = deliveryOrder.Id;
        doi.External_Key__c = '0080002649000010';
        doi.Order_Product__c = orderProduct.Id;
        Database.insert(doi);
       
        Invoice__c inv = new Invoice__c();
        inv.Customer__c = accId;
        inv.Invoice_Posting_Date__c = Date.newInstance(2019, 1, 15);
        insert inv;
        Invoice_Item__c invItem = new Invoice_Item__c();
        invItem.Invoice__c = inv.Id;
        invItem.SAP_Product_Line__c = mpp1.Id;
        invItem.Sales_Order_Item__c = orderProduct.Id;
        insert invItem;

        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = accId;
        customerProductLine.Management_Customer__c = accId;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);

        Actual_And_Same_Period_Report__c apr = new Actual_And_Same_Period_Report__c();
        apr.Customer__c = accId;
        apr.Customer_Product_Line__c = customerProductLine.Id;
        apr.Year__c = '2019';
        apr.Month__c = '01';
        apr.External_ID__c = '201901' + accId  + 'TV';
        Database.insert(apr);
        Test.startTest();

        InvoiceSummaryExcluBatch rcs = new InvoiceSummaryExcluBatch('2019','1','Hisense USA');
        Database.executeBatch(rcs,200);


        Test.stopTest();
    }
}