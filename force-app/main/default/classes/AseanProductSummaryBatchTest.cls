@isTest
private class AseanProductSummaryBatchTest {

    static testmethod void test2() {
        Mapping__c mp1 = new Mapping__c();
        mp1.Name = '14';
        mp1.Mapping_Code__c = 'TV';
        mp1.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        Database.insert(mp1);

        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense Malaysia',
        	Type = 'Management',
        	Hisense_Entity__c = '8110',
            channel__c = '零售'
        );
        Database.insert(acc1);

    	Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
    	customerProductLine.Product_Line_Name__c = 'TV';
    	customerProductLine.Customer__c = acc1.id;
    	customerProductLine.Management_Customer__c = acc1.id;
    	customerProductLine.Classification__c = 'Customer of Oversea Company';
    	customerProductLine.Development_Stage__c = 'Undeveloped';
    	customerProductLine.Prospective_Rank__c = 'Normal Customer';
    	Database.insert(customerProductLine);
    	Order__c order = new Order__c();
    	order.Customer__c = acc1.id;
        order.Order_Classification__c = 'S';
        order.Order_Date__c = Date.today();
        order.Hisense_Entity__c = '8110';
    	Database.insert(order);
    	Order_Product__c orderProduct = new Order_Product__c();
    	orderProduct.Order__c = order.Id;
    	orderProduct.SAP_Product_Customer_Model__c = 'NTC-22E';
    	orderProduct.SAP_Product_Line__c = mp1.id;
    	orderProduct.Quantity__c = 1;
    	orderProduct.Unit_Price__c = 111;
    	Database.insert(orderProduct);

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc1.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '测试门店';
        shop1.Sales_Region__c = 'Hisense Malaysia';
        // INSERT shop1;
        Database.insert(shop1);

        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  acc1.id;
        testReport1.Shop__c = shop1.id;
        testReport1.Report_Date__c = Date.today();
        // Insert testReport1;
        Database.insert(testReport1);

        Product__c productTest = new Product__c();
       	productTest.Name = 'AS-22CR2SBBDB00易装G(CL11)(CKD)';
        productTest.Product_Line__c = 'AC';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'AS-22CR2SBBDB00易装G(CL11)(CKD)';
        productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        productTest.sales_region__c = 'Hisense Malaysia';
       	// Insert productTest;
        Database.insert(productTest);

        Product__c productTest1 = new Product__c();
       	productTest1.Name = 'AS-24UF2SBBTD00四向/调序(ZX)';
        productTest1.Product_Line__c = 'AC';
       	productTest1.CurrencyIsoCode = 'USD';
       	productTest1.Product_External_Id__c = 'AS-24UF2SBBTD00四向/调序(ZX)';
        productTest1.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        productTest1.sales_region__c = 'Hisense Malaysia';
       	// Insert productTest1;
        Database.insert(productTest1);
        
        Retail_Number__c testRetailNumber = new Retail_Number__c();
        testRetailNumber.Shop__c = shop1.id;
        testRetailNumber.Product__c = productTest1.id;
        testRetailNumber.Number__c = 100;
        testRetailNumber.Price__c = 199;
        testRetailNumber.CurrencyIsoCode = 'USD';
        testRetailNumber.Customer__c = acc1.id;
        testRetailNumber.PromoterDailyReport__c = testReport1.id;
        testRetailNumber.Status__c ='Submitted';
        Database.insert(testRetailNumber);

        Retail_Number__c testRetailNumber1 = new Retail_Number__c();
        testRetailNumber1.Shop__c = shop1.id;
        testRetailNumber1.Product__c = productTest.id;
        testRetailNumber1.Number__c = 100;
        testRetailNumber1.Price__c = 199;
        testRetailNumber1.CurrencyIsoCode = 'USD';
        testRetailNumber1.Customer__c = acc1.id;
        testRetailNumber1.PromoterDailyReport__c = testReport1.id;
        testRetailNumber1.Status__c ='Submitted';
        Database.insert(testRetailNumber1);

        testReport1.Status__c ='Submitted';
        Database.update(testReport1);
        List<Retail_Number__c> one = [SELECT Sales_Region__c,
                   ReportDate__c,
                   Product_Line__c,
                   Number__c
            FROM   Retail_Number__c
            WHERE  ReportDate__c != null
            AND    Product__r.High_End_Model_Asean__c = 'High-End' 
            AND Status__c ='Submitted'];
        System.debug('参数' + one.size());
        AseanProductSummaryBatch ss  = new AseanProductSummaryBatch();
        Database.executeBatch(ss);
    }
}