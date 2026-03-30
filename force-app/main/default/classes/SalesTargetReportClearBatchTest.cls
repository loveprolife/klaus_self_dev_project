@isTest
private class SalesTargetReportClearBatchTest{
    static testMethod void testMethod1(){
        Account acc1 = new Account(
            Name = 'Test Account001', 
            SAP_Customer_Code__c = '1234567890', 
            External_Key__c = '1234567890', 
            Sales_Region__c = 'Hisense USA', 
            Type = 'Management'
        );
        Database.insert (acc1);

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc1.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '测试门店';
        shop1.Sales_Region__c = 'Hisense USA';
        Database.insert (shop1);

        Product__c productTest = new Product__c();
        productTest.Name = 'NTC-22E';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_Line__c = 'TV';
        productTest.Product_External_Id__c = 'NTC-22E-Returns';
        productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
        Database.insert (productTest);

        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c = acc1.id;
        testReport1.Shop__c = shop1.id;
        testReport1.Report_Date__c = Date.today();
        Database.insert (testReport1);

        Retail_Number__c rm = new Retail_Number__c();
        rm.Shop__c = shop1.id;
        rm.Product__c = productTest.id;
        rm.Number__c = 1;
        rm.Price__c = 199;
        rm.CurrencyIsoCode = 'USD';
        rm.Customer__c = acc1.id;
        rm.PromoterDailyReport__c = testReport1.id;
        rm.IsUpload__c = true;
        Database.insert (rm);

        Store_Inspection_Manage__c sim = new Store_Inspection_Manage__c();
        sim.Task_Type__c = '销售额';
        sim.Year__c = String.valueOf(Date.today().year());
        sim.Month__c = String.valueOf(Date.today().month());
        sim.Product_Line__c = 'TV';
        sim.Sales_Region__c = 'Hisense South Africa';
        Database.insert (sim);


        Sales_Target_Report__c str = new Sales_Target_Report__c();
        str.Daily_Sales__c = rm.Id;
        str.Inspection_Status__c = 'New';
        str.Key__c = sim.Id + '-' + rm.Id + '-' + UserInfo.getUserId();
        str.Store_Inspection_Manage__c = sim.Id;
        str.Total_Price__c = 1;
        str.User__c = UserInfo.getUserId();
        Database.insert (str);


        Store_Inspection_Manage_Daily_Sales__c simds = new Store_Inspection_Manage_Daily_Sales__c();
        simds.Store_Inspection_Manage__c = sim.Id;
        simds.Daily_Sales__c = rm.Id;
        simds.Total_Price__c = 1;
        Database.insert (simds);

        Responsible_Person__c promoterRes = new Responsible_Person__c();
        promoterRes.Shop_Name__c = shop1.Id;
        promoterRes.Principal__c = UserInfo.getUserId();
        promoterRes.RecordType__c = '巡店员';
        Database.insert (promoterRes);

        SalesTargetReportBatch ss = new SalesTargetReportBatch();
        Database.executeBatch(ss);

        SalesTargetReportClearBatch ss1 = new SalesTargetReportClearBatch();
        Database.executeBatch(ss1);

        SchedulableContext sc;
        SalesTargetReportCleartBatchSchedulable strcbs = new SalesTargetReportCleartBatchSchedulable();
        strcbs.execute(sc);
    }

}