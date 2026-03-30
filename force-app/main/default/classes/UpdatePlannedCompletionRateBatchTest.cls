@isTest
private class UpdatePlannedCompletionRateBatchTest {
    @testSetup 
    static void setup() {
        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8110';
        tcm.Country__c = 'US';
        insert tcm;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        Account acc1 = new Account(
            Name = 'TestAccount 1',
            SAP_Customer_Code__c = '0000504263',
            External_Key__c = '0000504263',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8110'
        );
        Database.insert(acc1);
        // ID acc1.Id = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = acc1.Id;
        customerProductLine.Management_Customer__c = acc1.Id;
        customerProductLine.Management_Customer_Branch_Company__c = acc1.Id;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);

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

        Mapping__c mpp = new Mapping__c();
        mpp.Name = '8010';
        mpp.Mapping_Code__c = '8010';
        mpp.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Orgnization and Name Mapping').getRecordTypeId();
        Database.insert(mpp);

        Mapping__c mpp1 = new Mapping__c();
        mpp1.Name = '0104';
        mpp1.Mapping_Code__c = 'TV';
        mpp1.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Scope and Product Line Mapping').getRecordTypeId();
        Database.insert(mpp1);

        Order__c order = new Order__c(
            Customer__c = acc1.Id,
            SAP_Order_No__c = '4500004397',
            External_Key__c = '45000043970000504263'
        );
        Database.insert(order);
        Order_Product__c orderProduct = new Order_Product__c();
        orderProduct.Order__c = order.Id;
        orderProduct.External_Key__c = '4500004397000010';
        Database.insert(orderProduct);
        Delivery_Order__c deliveryOrder = new Delivery_Order__c();
        deliveryOrder.Customer__c = acc1.Id;
        deliveryOrder.SAP_Delivery_Order_No__c = '0080002649';
        Database.insert(deliveryOrder);
        Delivery_Order_Item__c doi = new Delivery_Order_Item__c();
        doi.Delivery_Order__c = deliveryOrder.Id;
        doi.External_Key__c = '0080002649000010';
        doi.Order_Product__c = orderProduct.Id;
        Database.insert(doi);
       
        Invoice__c inv = new Invoice__c();
        inv.Customer__c = acc1.Id;
        inv.Invoice_Posting_Date__c = Date.newInstance(2019, 1, 15);
        insert inv;
        Invoice_Item__c invItem = new Invoice_Item__c();
        invItem.Invoice__c = inv.Id;
        invItem.SAP_Product_Line__c = mpp1.Id;
        invItem.Sales_Order_Item__c = orderProduct.Id;
        insert invItem;

        Invoice__c inv2 = new Invoice__c();
        inv2.Customer__c = acc1.Id;
        inv2.Invoice_Posting_Date__c = Date.newInstance(2019, 2, 14);
        insert inv2;
        Invoice_Item__c invItem2 = new Invoice_Item__c();
        invItem2.Invoice__c = inv.Id;
        invItem2.SAP_Product_Line__c = mpp1.Id;
        invItem2.Sales_Order_Item__c = orderProduct.Id;
        insert invItem2;

        Sales_Target_Branch_Company_Use__c salesTarget1 = new Sales_Target_Branch_Company_Use__c();
        salesTarget1.Customer_Name__c = acc1.Id;
        salesTarget1.Product_Line__c = 'TV';
        salesTarget1.Year__c = '2019';
        Database.insert(salesTarget1);

        Planned_Completion_Rate_Report__c pcrr = new Planned_Completion_Rate_Report__c(
            Management_Customer__c = acc1.Id,
            Product_Line__c = 'TV',
            Year__c = '2019',
            Month__c = '01',
            CurrencyIsoCode = 'USD'
        );
        Planned_Completion_Rate_Report__c pcrr2 = new Planned_Completion_Rate_Report__c(
            Management_Customer__c = acc1.Id,
            Product_Line__c = 'TV',
            Year__c = '2019',
            Month__c = '02',
            CurrencyIsoCode = 'USD'
        );
        Planned_Completion_Rate_Report__c pcrr3 = new Planned_Completion_Rate_Report__c(
            Management_Customer__c = acc1.Id,
            Product_Line__c = 'TV',
            Year__c = '2019',
            Month__c = '03',
            CurrencyIsoCode = 'USD'
        );

        List<Planned_Completion_Rate_Report__c> pcrrs = new List<Planned_Completion_Rate_Report__c>();
        pcrrs.add(pcrr);
        pcrrs.add(pcrr2);
        pcrrs.add(pcrr3);
        insert pcrrs;

        SAP_Cost_Revenue_Data__c costRevenueData = new SAP_Cost_Revenue_Data__c();
        costRevenueData.Year__c = '2019';
        costRevenueData.Month__c = '01';
        costRevenueData.CurrencyIsoCode = 'USD';
        costRevenueData.Company_Code__c = mpp.Id;
        costRevenueData.Business_Scope__c = mpp1.Id;
        costRevenueData.Customer_Product_Line__c = customerProductLine.Id;
        costRevenueData.Customer__c = acc1.Id;
        costRevenueData.Sales_Volume__c = 10;
        costRevenueData.Sales_Revenue__c = 10;
        costRevenueData.Sales_Revenue_USD__c = 10;
        costRevenueData.Sales_Gross_Revenue__c = 10;
        costRevenueData.Sales_Gross_Revenue_USD__c = 10;
        Database.insert(costRevenueData);

        SAP_Cost_Revenue_Data__c costRevenueData1 = new SAP_Cost_Revenue_Data__c();
        costRevenueData1.Year__c = '2019';
        costRevenueData1.Month__c = '02';
        costRevenueData1.CurrencyIsoCode = 'USD';
        costRevenueData1.Company_Code__c = mpp.Id;
        costRevenueData1.Business_Scope__c = mpp1.Id;
        costRevenueData1.Customer_Product_Line__c = customerProductLine.Id;
        costRevenueData1.Customer__c = acc1.Id;
        costRevenueData1.Sales_Volume__c = 10;
        costRevenueData1.Sales_Revenue__c = 10;
        costRevenueData1.Sales_Revenue_USD__c = 10;
        costRevenueData1.Sales_Gross_Revenue__c = 10;
        costRevenueData1.Sales_Gross_Revenue_USD__c = 10;
        Database.insert(costRevenueData1);
    } 

    static testMethod void testMethod1() {
        Test.startTest();
        UpdatePlannedCompletionRateBatch pcrr = new UpdatePlannedCompletionRateBatch('2019','1');
        
        Database.executeBatch(pcrr,200);
        Test.stopTest();
        List<Planned_Completion_Rate_Report__c> ls = [
            SELECT Id,Year__c,Month__c,Accumulated_Revenue_Net__c,Accumulated_Revenue_Net_USD__c,
                Accumulated_Revenue_Gross__c,Accumulated_Revenue_Gross_USD__c,
                Accumulated_sales_volumn__c,Actual_Revenue_Net__c,Actual_Revenue_Net_USD__c,
                Actual_Revenue_Gross__c,Actual_Revenue_Gross_USD__c,Actual_Sales_Volumn__c
            From Planned_Completion_Rate_Report__c
            WHERE Year__c='2019' AND Month__c='01'
        ];
        Planned_Completion_Rate_Report__c l = ls[0];
        System.assertEquals(10,l.Accumulated_Revenue_Net__c);
        System.assertEquals(10,l.Accumulated_Revenue_Net_USD__c);
        System.assertEquals(10,l.Accumulated_Revenue_Gross__c);
        System.assertEquals(10,l.Accumulated_Revenue_Gross_USD__c);
        System.assertEquals(10,l.Accumulated_sales_volumn__c);

        System.assertEquals(10,l.Actual_Revenue_Net__c);
        System.assertEquals(10,l.Actual_Revenue_Net_USD__c);
        System.assertEquals(10,l.Actual_Revenue_Gross__c);
        System.assertEquals(10,l.Actual_Revenue_Gross_USD__c);
        System.assertEquals(10,l.Actual_Sales_Volumn__c);
    }
    static testMethod void testMethod2() {
        Test.startTest();
        UpdatePlannedCompletionRateBatch pcrr = new UpdatePlannedCompletionRateBatch('2019','2');
        
        Database.executeBatch(pcrr,200);
        Test.stopTest();
        List<Planned_Completion_Rate_Report__c> ls = [
            SELECT Id,Year__c,Month__c,Accumulated_Revenue_Net__c,Accumulated_Revenue_Net_USD__c,
                Accumulated_Revenue_Gross__c,Accumulated_Revenue_Gross_USD__c,
                Accumulated_sales_volumn__c,Actual_Revenue_Net__c,Actual_Revenue_Net_USD__c,
                Actual_Revenue_Gross__c,Actual_Revenue_Gross_USD__c,Actual_Sales_Volumn__c
            From Planned_Completion_Rate_Report__c
            WHERE Year__c='2019' AND Month__c='02'
        ];
        System.debug('==ls:'+ls);
        System.assertEquals(true, ls.size()>0);
        Planned_Completion_Rate_Report__c l = ls[0];
        System.assertEquals(20,l.Accumulated_Revenue_Net__c);
        System.assertEquals(20,l.Accumulated_Revenue_Net_USD__c);
        System.assertEquals(20,l.Accumulated_Revenue_Gross__c);
        System.assertEquals(20,l.Accumulated_Revenue_Gross_USD__c);
        System.assertEquals(20,l.Accumulated_sales_volumn__c);

        System.assertEquals(10,l.Actual_Revenue_Net__c);
        System.assertEquals(10,l.Actual_Revenue_Net_USD__c);
        System.assertEquals(10,l.Actual_Revenue_Gross__c);
        System.assertEquals(10,l.Actual_Revenue_Gross_USD__c);
        System.assertEquals(10,l.Actual_Sales_Volumn__c);
    }

    static testMethod void testSchedule(){
        String cron = '0 0 * * * ?';
        Test.StartTest();
        
        String jobId = System.schedule('test', cron, new UpdatePlannedCompletionRateSchedule());

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(cron, ct.CronExpression);
        Test.StopTest();
    }
}