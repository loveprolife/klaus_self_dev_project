@isTest
private class CustomerProductSalesReportBatchTest {
    static testmethod void test1() {
        Mapping__c mp1 = new Mapping__c();
        mp1.Name = '14';
        mp1.Mapping_Code__c = 'TV';
        mp1.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        Database.insert(mp1);

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'USA';
        insert tcm1;

        National_tax_category__c ntc1 = new National_tax_category__c();
        ntc1.National_code__c = 'USA';
        ntc1.sort__c = 2;
        ntc1.Tax_category__c = 'UTXJ';
        insert ntc1;

        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8110',
        	Type = 'Management'
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

        Product__c productTest = new Product__c();
       	productTest.Name = 'NTC-22E';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-Returns';
        productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
        productTest.sales_region__c = 'Hisense USA';
       	Insert productTest;

        Invoice__c invoice = new Invoice__c();
        invoice.Customer__c = acc1.id;
        invoice.Invoice_Posting_Date__c = Date.today();
        invoice.Hisense_Entity__c = '8110';
        insert invoice;

        Invoice_Item__c invoiceItem = new Invoice_Item__c();
        invoiceItem.Invoice__c = invoice.Id;
        invoiceItem.SAP_Customer_Model_Product__c = 'NTC-22E1';
        invoiceItem.Product_Factory_Model__c = 'NTC-22E1';
        invoiceItem.SAP_Product_Line__c = mp1.Id;
        invoiceItem.Sales_Order_Item__c = orderProduct.id;
        invoiceItem.Invoice_Quantity__c = 10;
        invoiceItem.Total_Amount_After_Rebate__c = 100;
        insert invoiceItem;

        CustomerProductSalesReportBatch ss  = new CustomerProductSalesReportBatch('8110',String.valueOf(Date.today().addDays(-1)));
        Database.executeBatch(ss);

        CustomerProductSalesReportInvoiceBatch ss1  = new CustomerProductSalesReportInvoiceBatch('8110',String.valueOf(Date.today().addDays(-1)));
        Database.executeBatch(ss1);
    }

    static testmethod void test2() {
        Mapping__c mp1 = new Mapping__c();
        mp1.Name = '14';
        mp1.Mapping_Code__c = 'TV';
        mp1.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
        Database.insert(mp1);

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8110';
        tcm1.Country__c = 'USA';
        insert tcm1;

        National_tax_category__c ntc1 = new National_tax_category__c();
        ntc1.National_code__c = 'USA';
        ntc1.sort__c = 2;
        ntc1.Tax_category__c = 'UTXJ';
        insert ntc1;

        Account acc1 = new Account(
        	Name = 'Test Account001',
        	SAP_Customer_Code__c = '1234567890',
        	External_Key__c = '1234567890',
        	Sales_Region__c = 'Hisense USA',
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
        shop1.Sales_Region__c = 'Hisense USA';
        INSERT shop1;

        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  acc1.id;
        testReport1.Shop__c = shop1.id;
        testReport1.Report_Date__c = Date.today();
        Insert testReport1;

        Product__c productTest = new Product__c();
       	productTest.Name = 'NTC-22E';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-Returns';
        productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
       	Insert productTest;
        
        Retail_Number__c testRetailNumber = new Retail_Number__c();
        testRetailNumber.Shop__c = shop1.id;
        testRetailNumber.Product__c = productTest.id;
        testRetailNumber.Number__c = 100;
        testRetailNumber.Price__c = 199;
        testRetailNumber.CurrencyIsoCode = 'USD';
        testRetailNumber.Customer__c = acc1.id;
        testRetailNumber.PromoterDailyReport__c = testReport1.id;
        Insert testRetailNumber;

        CustomerProductSalesReport1Batch ss1  = new CustomerProductSalesReport1Batch('8110',String.valueOf(Date.today().addDays(-1)));
        Database.executeBatch(ss1);

        CustomerProductSalesReportDelBatch ss  = new CustomerProductSalesReportDelBatch('8110',String.valueOf(Date.today().addDays(-1)));
        Database.executeBatch(ss);

        SchedulableContext sc;
        CustomerProductSalesReportSchedulable asp = new CustomerProductSalesReportSchedulable('8110','2023-01-01');
        asp.execute(sc);
    }
}