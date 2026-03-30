@isTest
public class StoreLevelTempTest{
    @IsTest
    static void method1(){
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Shop__c store = new Shop__c();
        store.Name = 'wwww1';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        Shop__c store1 = new Shop__c();
        store1.Name = 'wwww2';
        store1.Account__c = customer.Id;
        store1.Sales_Region__c = 'Hisense Indonesia';
        insert store1;

        Store_Level_Temp__c slt = new Store_Level_Temp__c();
        slt.Store__c = store.Id;
        slt.Key__c = store.Id;
        insert slt;

        Promoter_Daily_Report__c report = new Promoter_Daily_Report__c();
        report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = system.today().addDays(-1);
        insert report;

        String productRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.Product_Line__c = 'TV';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        Product__c product1 = new Product__c();
        product1.Name = '65A65G';
        product1.Product_Line__c = 'Refrigerator';
        product1.RecordTypeId = productRecordTypeId;
        insert product1;

        Product__c product2 = new Product__c();
        product2.Name = '65A65G';
        product2.Product_Line__c = 'WM';
        product2.RecordTypeId = productRecordTypeId;
        insert product2;

        Product__c product3 = new Product__c();
        product3.Name = '65A65G';
        product3.Product_Line__c = 'AC';
        product3.RecordTypeId = productRecordTypeId;
        insert product3;

        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = report.Id;
        sales1.Product__c = product.Id;
        sales1.Shop__c = store.Id;
        sales1.Price__c = 600000;
        sales1.Status__c = 'Submitted';
        sales1.Number__c = 3;
        sales1.CurrencyIsoCode = 'CNY';
        insert sales1;

        Retail_Number__c sales2 = new Retail_Number__c();
        sales2.PromoterDailyReport__c = report.Id;
        sales2.Product__c = product1.Id;
        sales2.Shop__c = store.Id;
        sales2.Price__c = 600000;
        sales2.Status__c = 'Submitted';
        sales2.Number__c = 3;
        sales2.CurrencyIsoCode = 'CNY';
        insert sales2;

        Retail_Number__c sales3 = new Retail_Number__c();
        sales3.PromoterDailyReport__c = report.Id;
        sales3.Product__c = product2.Id;
        sales3.Shop__c = store.Id;
        sales3.Price__c = 600000;
        sales3.Status__c = 'Submitted';
        sales3.Number__c = 3;
        sales3.CurrencyIsoCode = 'CNY';
        insert sales3;

        Retail_Number__c sales4 = new Retail_Number__c();
        sales4.PromoterDailyReport__c = report.Id;
        sales4.Product__c = product3.Id;
        sales4.Shop__c = store.Id;
        sales4.Price__c = 600000;
        sales4.Status__c = 'Submitted';
        sales4.Number__c = 3;
        sales4.CurrencyIsoCode = 'CNY';
        insert sales4;

        Retail_Number__c sales5 = new Retail_Number__c();
        sales5.PromoterDailyReport__c = report.Id;
        sales5.Product__c = product3.Id;
        sales5.Shop__c = store1.Id;
        sales5.Price__c = 600000;
        sales5.Status__c = 'Submitted';
        sales5.Number__c = 3;
        sales5.CurrencyIsoCode = 'CNY';
        insert sales5;

        Store_Level__c sl = new Store_Level__c();
        sl.name = 'Hisense Indonesia-TV';
        sl.Level_S__c = 4;
        sl.Level_S_Score__c = 1;
        sl.Level_A__c = 3;
        sl.Level_A_Score__c = 2;
        sl.Level_B__c = 2;
        sl.Level_B_Score__c = 3;
        sl.Level_C__c = 1;
        sl.Level_C_Score__c = 4;
        sl.Level_D_Score__c = 5;
        insert sl;

        Store_Level__c sl1 = new Store_Level__c();
        sl1.name = 'Hisense Indonesia-Refrigerator';
        sl1.Level_S__c = 4;
        sl1.Level_S_Score__c = 1;
        sl1.Level_A__c = 3;
        sl1.Level_A_Score__c = 2;
        sl1.Level_B__c = 2;
        sl1.Level_B_Score__c = 3;
        sl1.Level_C__c = 1;
        sl1.Level_C_Score__c = 4;
        sl1.Level_D_Score__c = 5;
        insert sl1;

        Store_Level__c sl2 = new Store_Level__c();
        sl2.name = 'Hisense Indonesia-WM';
        sl2.Level_S__c = 4;
        sl2.Level_S_Score__c = 1;
        sl2.Level_A__c = 3;
        sl2.Level_A_Score__c = 2;
        sl2.Level_B__c = 2;
        sl2.Level_B_Score__c = 3;
        sl2.Level_C__c = 1;
        sl2.Level_C_Score__c = 4;
        sl2.Level_D_Score__c = 5;
        insert sl2;

        Store_Level__c sl3 = new Store_Level__c();
        sl3.name = 'Hisense Indonesia-AC';
        sl3.Level_S__c = 4;
        sl3.Level_S_Score__c = 1;
        sl3.Level_A__c = 3;
        sl3.Level_A_Score__c = 2;
        sl3.Level_B__c = 2;
        sl3.Level_B_Score__c = 3;
        sl3.Level_C__c = 1;
        sl3.Level_C_Score__c = 4;
        sl3.Level_D_Score__c = 5;
        insert sl3;

        Store_Score_Level__c ssl = new Store_Score_Level__c();
        ssl.name = '1';
        ssl.Level__c = 'S';
        insert ssl;

        Store_Score_Level__c ssl1 = new Store_Score_Level__c();
        ssl1.name = '2';
        ssl1.Level__c = 'A';
        insert ssl1;

        Store_Score_Level__c ssl2 = new Store_Score_Level__c();
        ssl2.name = '3';
        ssl2.Level__c = 'B';
        insert ssl2;

        Store_Score_Level__c ssl3 = new Store_Score_Level__c();
        ssl3.name = '4';
        ssl3.Level__c = 'C';
        insert ssl3;

        Store_Score_Level__c ssl4 = new Store_Score_Level__c();
        ssl4.name = '5';
        ssl4.Level__c = 'D';
        insert ssl4;

        Test.StartTest();
        StoreLevelTempClearBatch batch = new StoreLevelTempClearBatch();
        ID bid = Database.executeBatch(batch);
        Test.StopTest();
    }

    @IsTest
    static void method2(){
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Shop__c store = new Shop__c();
        store.Name = 'wwww1';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        Shop__c store1 = new Shop__c();
        store1.Name = 'wwww2';
        store1.Account__c = customer.Id;
        store1.Sales_Region__c = 'Hisense Indonesia';
        insert store1;

        Store_Level_Temp__c slt = new Store_Level_Temp__c();
        slt.Store__c = store.Id;
        slt.Key__c = store.Id;
        insert slt;

        Promoter_Daily_Report__c report = new Promoter_Daily_Report__c();
        report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = system.today().addDays(-1);
        insert report;

        String productRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.Product_Line__c = 'TV';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        Product__c product1 = new Product__c();
        product1.Name = '65A65G';
        product1.Product_Line__c = 'Refrigerator';
        product1.RecordTypeId = productRecordTypeId;
        insert product1;

        Product__c product2 = new Product__c();
        product2.Name = '65A65G';
        product2.Product_Line__c = 'WM';
        product2.RecordTypeId = productRecordTypeId;
        insert product2;

        Product__c product3 = new Product__c();
        product3.Name = '65A65G';
        product3.Product_Line__c = 'AC';
        product3.RecordTypeId = productRecordTypeId;
        insert product3;

        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = report.Id;
        sales1.Product__c = product.Id;
        sales1.Shop__c = store.Id;
        sales1.Price__c = 30000;
        sales1.Status__c = 'Submitted';
        sales1.Number__c = 1;
        sales1.CurrencyIsoCode = 'CNY';
        insert sales1;

        Retail_Number__c sales2 = new Retail_Number__c();
        sales2.PromoterDailyReport__c = report.Id;
        sales2.Product__c = product1.Id;
        sales2.Shop__c = store.Id;
        sales2.Price__c = 30000;
        sales2.Status__c = 'Submitted';
        sales2.Number__c = 1;
        sales2.CurrencyIsoCode = 'CNY';
        insert sales2;

        Retail_Number__c sales3 = new Retail_Number__c();
        sales3.PromoterDailyReport__c = report.Id;
        sales3.Product__c = product2.Id;
        sales3.Shop__c = store.Id;
        sales3.Price__c = 30000;
        sales3.Status__c = 'Submitted';
        sales3.Number__c = 1;
        sales3.CurrencyIsoCode = 'CNY';
        insert sales3;

        Retail_Number__c sales4 = new Retail_Number__c();
        sales4.PromoterDailyReport__c = report.Id;
        sales4.Product__c = product3.Id;
        sales4.Shop__c = store.Id;
        sales4.Price__c = 30000;
        sales4.Status__c = 'Submitted';
        sales4.Number__c = 1;
        sales4.CurrencyIsoCode = 'CNY';
        insert sales4;

        Retail_Number__c sales5 = new Retail_Number__c();
        sales5.PromoterDailyReport__c = report.Id;
        sales5.Product__c = product3.Id;
        sales5.Shop__c = store1.Id;
        sales5.Price__c = 30000;
        sales5.Status__c = 'Submitted';
        sales5.Number__c = 1;
        sales5.CurrencyIsoCode = 'CNY';
        insert sales5;

        Store_Level__c sl = new Store_Level__c();
        sl.name = 'Hisense Indonesia-TV';
        sl.Level_S__c = 4 * 4;
        sl.Level_S_Score__c = 1;
        sl.Level_A__c = 3 * 4;
        sl.Level_A_Score__c = 2;
        sl.Level_B__c = 2 * 4;
        sl.Level_B_Score__c = 3;
        sl.Level_C__c = 1 * 4;
        sl.Level_C_Score__c = 4;
        sl.Level_D_Score__c = 5;
        insert sl;

        Store_Level__c sl1 = new Store_Level__c();
        sl1.name = 'Hisense Indonesia-Refrigerator';
        sl1.Level_S__c = 4 * 4;
        sl1.Level_S_Score__c = 1;
        sl1.Level_A__c = 3 * 4;
        sl1.Level_A_Score__c = 2;
        sl1.Level_B__c = 2 * 4;
        sl1.Level_B_Score__c = 3;
        sl1.Level_C__c = 1 * 4;
        sl1.Level_C_Score__c = 4;
        sl1.Level_D_Score__c = 5;
        insert sl1;

        Store_Level__c sl2 = new Store_Level__c();
        sl2.name = 'Hisense Indonesia-WM';
        sl2.Level_S__c = 4 * 4;
        sl2.Level_S_Score__c = 1;
        sl2.Level_A__c = 3 * 4;
        sl2.Level_A_Score__c = 2;
        sl2.Level_B__c = 2 * 4;
        sl2.Level_B_Score__c = 3;
        sl2.Level_C__c = 1 * 4;
        sl2.Level_C_Score__c = 4;
        sl2.Level_D_Score__c = 5;
        insert sl2;

        Store_Level__c sl3 = new Store_Level__c();
        sl3.name = 'Hisense Indonesia-AC';
        sl3.Level_S__c = 4 * 4;
        sl3.Level_S_Score__c = 1;
        sl3.Level_A__c = 3 * 4;
        sl3.Level_A_Score__c = 2;
        sl3.Level_B__c = 2 * 4;
        sl3.Level_B_Score__c = 3;
        sl3.Level_C__c = 1 * 4;
        sl3.Level_C_Score__c = 4;
        sl3.Level_D_Score__c = 5;
        insert sl3;

        Store_Score_Level__c ssl = new Store_Score_Level__c();
        ssl.name = '1';
        ssl.Level__c = 'S';
        insert ssl;

        Store_Score_Level__c ssl1 = new Store_Score_Level__c();
        ssl1.name = '2';
        ssl1.Level__c = 'A';
        insert ssl1;

        Store_Score_Level__c ssl2 = new Store_Score_Level__c();
        ssl2.name = '3';
        ssl2.Level__c = 'B';
        insert ssl2;

        Store_Score_Level__c ssl3 = new Store_Score_Level__c();
        ssl3.name = '4';
        ssl3.Level__c = 'C';
        insert ssl3;

        Store_Score_Level__c ssl4 = new Store_Score_Level__c();
        ssl4.name = '5';
        ssl4.Level__c = 'D';
        insert ssl4;

        Test.StartTest();
        StoreLevelTempClearBatch batch = new StoreLevelTempClearBatch();
        ID bid = Database.executeBatch(batch);
        Test.StopTest();
    }

    @IsTest
    static void method3(){
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Shop__c store = new Shop__c();
        store.Name = 'wwww1';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        Shop__c store1 = new Shop__c();
        store1.Name = 'wwww2';
        store1.Account__c = customer.Id;
        store1.Sales_Region__c = 'Hisense Indonesia';
        insert store1;

        Store_Level_Temp__c slt = new Store_Level_Temp__c();
        slt.Store__c = store.Id;
        slt.Key__c = store.Id;
        insert slt;

        Promoter_Daily_Report__c report = new Promoter_Daily_Report__c();
        report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = system.today().addDays(-1);
        insert report;

        String productRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.Product_Line__c = 'TV';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        Product__c product1 = new Product__c();
        product1.Name = '65A65G';
        product1.Product_Line__c = 'Refrigerator';
        product1.RecordTypeId = productRecordTypeId;
        insert product1;

        Product__c product2 = new Product__c();
        product2.Name = '65A65G';
        product2.Product_Line__c = 'WM';
        product2.RecordTypeId = productRecordTypeId;
        insert product2;

        Product__c product3 = new Product__c();
        product3.Name = '65A65G';
        product3.Product_Line__c = 'AC';
        product3.RecordTypeId = productRecordTypeId;
        insert product3;

        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = report.Id;
        sales1.Product__c = product.Id;
        sales1.Shop__c = store.Id;
        sales1.Price__c = 20000;
        sales1.Status__c = 'Submitted';
        sales1.Number__c = 1;
        sales1.CurrencyIsoCode = 'CNY';
        insert sales1;

        Retail_Number__c sales2 = new Retail_Number__c();
        sales2.PromoterDailyReport__c = report.Id;
        sales2.Product__c = product1.Id;
        sales2.Shop__c = store.Id;
        sales2.Price__c = 20000;
        sales2.Status__c = 'Submitted';
        sales2.Number__c = 1;
        sales2.CurrencyIsoCode = 'CNY';
        insert sales2;

        Retail_Number__c sales3 = new Retail_Number__c();
        sales3.PromoterDailyReport__c = report.Id;
        sales3.Product__c = product2.Id;
        sales3.Shop__c = store.Id;
        sales3.Price__c = 20000;
        sales3.Status__c = 'Submitted';
        sales3.Number__c = 1;
        sales3.CurrencyIsoCode = 'CNY';
        insert sales3;

        Retail_Number__c sales4 = new Retail_Number__c();
        sales4.PromoterDailyReport__c = report.Id;
        sales4.Product__c = product3.Id;
        sales4.Shop__c = store.Id;
        sales4.Price__c = 20000;
        sales4.Status__c = 'Submitted';
        sales4.Number__c = 1;
        sales4.CurrencyIsoCode = 'CNY';
        insert sales4;

        Retail_Number__c sales5 = new Retail_Number__c();
        sales5.PromoterDailyReport__c = report.Id;
        sales5.Product__c = product3.Id;
        sales5.Shop__c = store1.Id;
        sales5.Price__c = 20000;
        sales5.Status__c = 'Submitted';
        sales5.Number__c = 1;
        sales5.CurrencyIsoCode = 'CNY';
        insert sales5;

        Store_Level__c sl = new Store_Level__c();
        sl.name = 'Hisense Indonesia-TV';
        sl.Level_S__c = 4 * 4;
        sl.Level_S_Score__c = 1;
        sl.Level_A__c = 3 * 4;
        sl.Level_A_Score__c = 2;
        sl.Level_B__c = 2 * 4;
        sl.Level_B_Score__c = 3;
        sl.Level_C__c = 1 * 4;
        sl.Level_C_Score__c = 4;
        sl.Level_D_Score__c = 5;
        insert sl;

        Store_Level__c sl1 = new Store_Level__c();
        sl1.name = 'Hisense Indonesia-Refrigerator';
        sl1.Level_S__c = 4 * 4;
        sl1.Level_S_Score__c = 1;
        sl1.Level_A__c = 3 * 4;
        sl1.Level_A_Score__c = 2;
        sl1.Level_B__c = 2 * 4;
        sl1.Level_B_Score__c = 3;
        sl1.Level_C__c = 1 * 4;
        sl1.Level_C_Score__c = 4;
        sl1.Level_D_Score__c = 5;
        insert sl1;

        Store_Level__c sl2 = new Store_Level__c();
        sl2.name = 'Hisense Indonesia-WM';
        sl2.Level_S__c = 4 * 4;
        sl2.Level_S_Score__c = 1;
        sl2.Level_A__c = 3 * 4;
        sl2.Level_A_Score__c = 2;
        sl2.Level_B__c = 2 * 4;
        sl2.Level_B_Score__c = 3;
        sl2.Level_C__c = 1 * 4;
        sl2.Level_C_Score__c = 4;
        sl2.Level_D_Score__c = 5;
        insert sl2;

        Store_Level__c sl3 = new Store_Level__c();
        sl3.name = 'Hisense Indonesia-AC';
        sl3.Level_S__c = 4 * 4;
        sl3.Level_S_Score__c = 1;
        sl3.Level_A__c = 3 * 4;
        sl3.Level_A_Score__c = 2;
        sl3.Level_B__c = 2 * 4;
        sl3.Level_B_Score__c = 3;
        sl3.Level_C__c = 1 * 4;
        sl3.Level_C_Score__c = 4;
        sl3.Level_D_Score__c = 5;
        insert sl3;

        Store_Score_Level__c ssl = new Store_Score_Level__c();
        ssl.name = '1';
        ssl.Level__c = 'S';
        insert ssl;

        Store_Score_Level__c ssl1 = new Store_Score_Level__c();
        ssl1.name = '2';
        ssl1.Level__c = 'A';
        insert ssl1;

        Store_Score_Level__c ssl2 = new Store_Score_Level__c();
        ssl2.name = '3';
        ssl2.Level__c = 'B';
        insert ssl2;

        Store_Score_Level__c ssl3 = new Store_Score_Level__c();
        ssl3.name = '4';
        ssl3.Level__c = 'C';
        insert ssl3;

        Store_Score_Level__c ssl4 = new Store_Score_Level__c();
        ssl4.name = '5';
        ssl4.Level__c = 'D';
        insert ssl4;

        Test.StartTest();
        StoreLevelTempClearBatch batch = new StoreLevelTempClearBatch();
        ID bid = Database.executeBatch(batch);
        Test.StopTest();
    }

    @IsTest
    static void method4(){
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Shop__c store = new Shop__c();
        store.Name = 'wwww1';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        Shop__c store1 = new Shop__c();
        store1.Name = 'wwww2';
        store1.Account__c = customer.Id;
        store1.Sales_Region__c = 'Hisense Indonesia';
        insert store1;

        Store_Level_Temp__c slt = new Store_Level_Temp__c();
        slt.Store__c = store.Id;
        slt.Key__c = store.Id;
        insert slt;

        Promoter_Daily_Report__c report = new Promoter_Daily_Report__c();
        report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = system.today().addDays(-1);
        insert report;

        String productRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.Product_Line__c = 'TV';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        Product__c product1 = new Product__c();
        product1.Name = '65A65G';
        product1.Product_Line__c = 'Refrigerator';
        product1.RecordTypeId = productRecordTypeId;
        insert product1;

        Product__c product2 = new Product__c();
        product2.Name = '65A65G';
        product2.Product_Line__c = 'WM';
        product2.RecordTypeId = productRecordTypeId;
        insert product2;

        Product__c product3 = new Product__c();
        product3.Name = '65A65G';
        product3.Product_Line__c = 'AC';
        product3.RecordTypeId = productRecordTypeId;
        insert product3;

        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = report.Id;
        sales1.Product__c = product.Id;
        sales1.Shop__c = store.Id;
        sales1.Price__c = 11000;
        sales1.Status__c = 'Submitted';
        sales1.Number__c = 1;
        sales1.CurrencyIsoCode = 'CNY';
        insert sales1;

        Retail_Number__c sales2 = new Retail_Number__c();
        sales2.PromoterDailyReport__c = report.Id;
        sales2.Product__c = product1.Id;
        sales2.Shop__c = store.Id;
        sales2.Price__c = 11000;
        sales2.Status__c = 'Submitted';
        sales2.Number__c = 1;
        sales2.CurrencyIsoCode = 'CNY';
        insert sales2;

        Retail_Number__c sales3 = new Retail_Number__c();
        sales3.PromoterDailyReport__c = report.Id;
        sales3.Product__c = product2.Id;
        sales3.Shop__c = store.Id;
        sales3.Price__c = 11000;
        sales3.Status__c = 'Submitted';
        sales3.Number__c = 1;
        sales3.CurrencyIsoCode = 'CNY';
        insert sales3;

        Retail_Number__c sales4 = new Retail_Number__c();
        sales4.PromoterDailyReport__c = report.Id;
        sales4.Product__c = product3.Id;
        sales4.Shop__c = store.Id;
        sales4.Price__c = 11000;
        sales4.Status__c = 'Submitted';
        sales4.Number__c = 1;
        sales4.CurrencyIsoCode = 'CNY';
        insert sales4;

        Retail_Number__c sales5 = new Retail_Number__c();
        sales5.PromoterDailyReport__c = report.Id;
        sales5.Product__c = product3.Id;
        sales5.Shop__c = store1.Id;
        sales5.Price__c = 11000;
        sales5.Status__c = 'Submitted';
        sales5.Number__c = 1;
        sales5.CurrencyIsoCode = 'CNY';
        insert sales5;

        Store_Level__c sl = new Store_Level__c();
        sl.name = 'Hisense Indonesia-TV';
        sl.Level_S__c = 4 * 4;
        sl.Level_S_Score__c = 1;
        sl.Level_A__c = 3 * 4;
        sl.Level_A_Score__c = 2;
        sl.Level_B__c = 2 * 4;
        sl.Level_B_Score__c = 3;
        sl.Level_C__c = 1 * 4;
        sl.Level_C_Score__c = 4;
        sl.Level_D_Score__c = 5;
        insert sl;

        Store_Level__c sl1 = new Store_Level__c();
        sl1.name = 'Hisense Indonesia-Refrigerator';
        sl1.Level_S__c = 4 * 4;
        sl1.Level_S_Score__c = 1;
        sl1.Level_A__c = 3 * 4;
        sl1.Level_A_Score__c = 2;
        sl1.Level_B__c = 2 * 4;
        sl1.Level_B_Score__c = 3;
        sl1.Level_C__c = 1 * 4;
        sl1.Level_C_Score__c = 4;
        sl1.Level_D_Score__c = 5;
        insert sl1;

        Store_Level__c sl2 = new Store_Level__c();
        sl2.name = 'Hisense Indonesia-WM';
        sl2.Level_S__c = 4 * 4;
        sl2.Level_S_Score__c = 1;
        sl2.Level_A__c = 3 * 4;
        sl2.Level_A_Score__c = 2;
        sl2.Level_B__c = 2 * 4;
        sl2.Level_B_Score__c = 3;
        sl2.Level_C__c = 1 * 4;
        sl2.Level_C_Score__c = 4;
        sl2.Level_D_Score__c = 5;
        insert sl2;

        Store_Level__c sl3 = new Store_Level__c();
        sl3.name = 'Hisense Indonesia-AC';
        sl3.Level_S__c = 4 * 4;
        sl3.Level_S_Score__c = 1;
        sl3.Level_A__c = 3 * 4;
        sl3.Level_A_Score__c = 2;
        sl3.Level_B__c = 2 * 4;
        sl3.Level_B_Score__c = 3;
        sl3.Level_C__c = 1 * 4;
        sl3.Level_C_Score__c = 4;
        sl3.Level_D_Score__c = 5;
        insert sl3;

        Store_Score_Level__c ssl = new Store_Score_Level__c();
        ssl.name = '1';
        ssl.Level__c = 'S';
        insert ssl;

        Store_Score_Level__c ssl1 = new Store_Score_Level__c();
        ssl1.name = '2';
        ssl1.Level__c = 'A';
        insert ssl1;

        Store_Score_Level__c ssl2 = new Store_Score_Level__c();
        ssl2.name = '3';
        ssl2.Level__c = 'B';
        insert ssl2;

        Store_Score_Level__c ssl3 = new Store_Score_Level__c();
        ssl3.name = '4';
        ssl3.Level__c = 'C';
        insert ssl3;

        Store_Score_Level__c ssl4 = new Store_Score_Level__c();
        ssl4.name = '5';
        ssl4.Level__c = 'D';
        insert ssl4;

        Test.StartTest();
        StoreLevelTempClearBatch batch = new StoreLevelTempClearBatch();
        ID bid = Database.executeBatch(batch);
        Test.StopTest();
    }

    @IsTest
    static void method5(){
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;

        Shop__c store = new Shop__c();
        store.Name = 'wwww1';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        Shop__c store1 = new Shop__c();
        store1.Name = 'wwww2';
        store1.Account__c = customer.Id;
        store1.Sales_Region__c = 'Hisense Indonesia';
        insert store1;

        Store_Level_Temp__c slt = new Store_Level_Temp__c();
        slt.Store__c = store.Id;
        slt.Key__c = store.Id;
        insert slt;

        Promoter_Daily_Report__c report = new Promoter_Daily_Report__c();
        report = new Promoter_Daily_Report__c();
        report.Shop__c = store.Id;
        report.Report_Date__c = system.today().addDays(-1);
        insert report;

        String productRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Product__c product = new Product__c();
        product.Name = '65A65G';
        product.Product_Line__c = 'TV';
        product.RecordTypeId = productRecordTypeId;
        insert product;

        Product__c product1 = new Product__c();
        product1.Name = '65A65G';
        product1.Product_Line__c = 'Refrigerator';
        product1.RecordTypeId = productRecordTypeId;
        insert product1;

        Product__c product2 = new Product__c();
        product2.Name = '65A65G';
        product2.Product_Line__c = 'WM';
        product2.RecordTypeId = productRecordTypeId;
        insert product2;

        Product__c product3 = new Product__c();
        product3.Name = '65A65G';
        product3.Product_Line__c = 'AC';
        product3.RecordTypeId = productRecordTypeId;
        insert product3;

        Retail_Number__c sales1 = new Retail_Number__c();
        sales1.PromoterDailyReport__c = report.Id;
        sales1.Product__c = product.Id;
        sales1.Shop__c = store.Id;
        sales1.Price__c = 3000;
        sales1.Status__c = 'Submitted';
        sales1.Number__c = 1;
        sales1.CurrencyIsoCode = 'CNY';
        insert sales1;

        Retail_Number__c sales2 = new Retail_Number__c();
        sales2.PromoterDailyReport__c = report.Id;
        sales2.Product__c = product1.Id;
        sales2.Shop__c = store.Id;
        sales2.Price__c = 3000;
        sales2.Status__c = 'Submitted';
        sales2.Number__c = 1;
        sales2.CurrencyIsoCode = 'CNY';
        insert sales2;

        Retail_Number__c sales3 = new Retail_Number__c();
        sales3.PromoterDailyReport__c = report.Id;
        sales3.Product__c = product2.Id;
        sales3.Shop__c = store.Id;
        sales3.Price__c = 3000;
        sales3.Status__c = 'Submitted';
        sales3.Number__c = 1;
        sales3.CurrencyIsoCode = 'CNY';
        insert sales3;

        Retail_Number__c sales4 = new Retail_Number__c();
        sales4.PromoterDailyReport__c = report.Id;
        sales4.Product__c = product3.Id;
        sales4.Shop__c = store.Id;
        sales4.Price__c = 3000;
        sales4.Status__c = 'Submitted';
        sales4.Number__c = 1;
        sales4.CurrencyIsoCode = 'CNY';
        insert sales4;

        Retail_Number__c sales5 = new Retail_Number__c();
        sales5.PromoterDailyReport__c = report.Id;
        sales5.Product__c = product3.Id;
        sales5.Shop__c = store1.Id;
        sales5.Price__c = 3000;
        sales5.Status__c = 'Submitted';
        sales5.Number__c = 1;
        sales5.CurrencyIsoCode = 'CNY';
        insert sales5;

        Store_Level__c sl = new Store_Level__c();
        sl.name = 'Hisense Indonesia-TV';
        sl.Level_S__c = 4 * 4;
        sl.Level_S_Score__c = 1;
        sl.Level_A__c = 3 * 4;
        sl.Level_A_Score__c = 2;
        sl.Level_B__c = 2 * 4;
        sl.Level_B_Score__c = 3;
        sl.Level_C__c = 1 * 4;
        sl.Level_C_Score__c = 4;
        sl.Level_D_Score__c = 5;
        insert sl;

        Store_Level__c sl1 = new Store_Level__c();
        sl1.name = 'Hisense Indonesia-Refrigerator';
        sl1.Level_S__c = 4 * 4;
        sl1.Level_S_Score__c = 1;
        sl1.Level_A__c = 3 * 4;
        sl1.Level_A_Score__c = 2;
        sl1.Level_B__c = 2 * 4;
        sl1.Level_B_Score__c = 3;
        sl1.Level_C__c = 1 * 4;
        sl1.Level_C_Score__c = 4;
        sl1.Level_D_Score__c = 5;
        insert sl1;

        Store_Level__c sl2 = new Store_Level__c();
        sl2.name = 'Hisense Indonesia-WM';
        sl2.Level_S__c = 4 * 4;
        sl2.Level_S_Score__c = 1;
        sl2.Level_A__c = 3 * 4;
        sl2.Level_A_Score__c = 2;
        sl2.Level_B__c = 2 * 4;
        sl2.Level_B_Score__c = 3;
        sl2.Level_C__c = 1 * 4;
        sl2.Level_C_Score__c = 4;
        sl2.Level_D_Score__c = 5;
        insert sl2;

        Store_Level__c sl3 = new Store_Level__c();
        sl3.name = 'Hisense Indonesia-AC';
        sl3.Level_S__c = 4 * 4;
        sl3.Level_S_Score__c = 1;
        sl3.Level_A__c = 3 * 4;
        sl3.Level_A_Score__c = 2;
        sl3.Level_B__c = 2 * 4;
        sl3.Level_B_Score__c = 3;
        sl3.Level_C__c = 1 * 4;
        sl3.Level_C_Score__c = 4;
        sl3.Level_D_Score__c = 5;
        insert sl3;

        Store_Score_Level__c ssl = new Store_Score_Level__c();
        ssl.name = '1';
        ssl.Level__c = 'S';
        insert ssl;

        Store_Score_Level__c ssl1 = new Store_Score_Level__c();
        ssl1.name = '2';
        ssl1.Level__c = 'A';
        insert ssl1;

        Store_Score_Level__c ssl2 = new Store_Score_Level__c();
        ssl2.name = '3';
        ssl2.Level__c = 'B';
        insert ssl2;

        Store_Score_Level__c ssl3 = new Store_Score_Level__c();
        ssl3.name = '4';
        ssl3.Level__c = 'C';
        insert ssl3;

        Store_Score_Level__c ssl4 = new Store_Score_Level__c();
        ssl4.name = '5';
        ssl4.Level__c = 'D';
        insert ssl4;

        Test.StartTest();
        StoreLevelTempClearBatch batch = new StoreLevelTempClearBatch();
        ID bid = Database.executeBatch(batch);

        SchedulableContext sc;
        StoreLevelTempClearBatchSchedulable sltcbs = new StoreLevelTempClearBatchSchedulable();
        sltcbs.execute(sc);

        Test.StopTest();
    }

}