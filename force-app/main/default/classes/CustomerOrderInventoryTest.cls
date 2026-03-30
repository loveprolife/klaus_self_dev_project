@isTest
private class CustomerOrderInventoryTest {
    static testmethod void test() {
        Statistics_Flag__c sf1 = new Statistics_Flag__c();
        sf1.name = 'Customer Order Inventory';
        sf1.Flag__c = true;
        insert sf1;

        Statistics_Flag__c sf2 = new Statistics_Flag__c();
        sf2.name = 'Store Inspection Manage';
        sf2.Flag__c = true;
        insert sf2;

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(
            Alias = 'admin', Email='CustomerOrderInventoryTest@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='CustomerOrderInventoryTest@hisensetest.com',Sales_Region__c = 'Hisense USA'
        );
        Database.insert(user);
        System.runAs(user){
            Mapping__c mp1 = new Mapping__c();
            mp1.Name = '14';
            mp1.Mapping_Code__c = 'TV';
            mp1.RecordTypeId = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
            Database.insert(mp1);
            Account acc1 = new Account(
                Name = 'Test Account001',
                SAP_Customer_Code__c = '1234567890',
                External_Key__c = '1234567890',
                Sales_Region__c = 'Hisense USA',
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
            orderProduct.Quantity__c = 10;
            orderProduct.Unit_Price__c = 111;
            Database.insert(orderProduct);

            Product__c productTest = new Product__c();
            productTest.Name = 'NTC-22E';
            productTest.CurrencyIsoCode = 'USD';
            productTest.Product_Line__c = 'TV';
            productTest.Product_External_Id__c = 'NTC-22E-Returns';
            productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            Database.insert(productTest);

            Shop__c shop1 = new Shop__c();
            shop1.Account__c = acc1.Id;
            shop1.Shop_Level__c = 'A';
            shop1.Name = '测试门店';
            shop1.Sales_Region__c = 'Hisense USA';
            Database.insert(shop1);

            Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
            testReport1.Customer__c =  acc1.id;
            testReport1.Shop__c = shop1.id;
            testReport1.Report_Date__c = Date.today();
            Database.insert(testReport1);

            Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
            testReport2.Customer__c =  acc1.id;
            testReport2.Shop__c = shop1.id;
            testReport2.Report_Date__c = Date.today().addDays(1);
            Database.insert(testReport2);

            Retail_Number__c rm = new Retail_Number__c();
            rm.Shop__c = shop1.id;
            rm.Product__c = productTest.id;
            rm.Number__c = 1;
            rm.Price__c = 199;
            rm.CurrencyIsoCode = 'USD';
            rm.Customer__c = acc1.id;
            rm.PromoterDailyReport__c = testReport1.id;
            rm.IsUpload__c = true;
            Database.insert(rm);

            Retail_Number__c rm1 = new Retail_Number__c();
            rm1.Shop__c = shop1.id;
            rm1.Product__c = productTest.id;
            rm1.Number__c = 100;
            rm1.Price__c = 199;
            rm1.CurrencyIsoCode = 'USD';
            rm1.Customer__c = acc1.id;
            rm1.PromoterDailyReport__c = testReport2.id;
            rm1.IsUpload__c = true;
            Database.insert(rm1);

            Customer_Order_Inventory__c coi = new Customer_Order_Inventory__c();
            coi.Customer__c = acc1.id;
            coi.Product__c = 'NTC-22E';
            coi.Product_Line__c = 'TV';
            coi.Entity__c = '8110';
            coi.Quantity__c = 10;
            coi.key__c = rm.Customer__r.SAP_Customer_Code__c + '-' + rm.Product__r.Product_Line__c + '-' + rm.Product__r.name;
            Database.insert(coi);

            Customer_Order_Inventory_Daily__c coid = new Customer_Order_Inventory_Daily__c();
            coid.Customer_Order_Inventory__c = coi.Id;
            coid.Daily_Sales__c = rm.Id;
            coid.Quantity__c = 1;
            coid.Exceed__c = true;
            Database.insert(coid);

            Customer_Order_Inventory_Daily__c coid1 = new Customer_Order_Inventory_Daily__c();
            coid1.Customer_Order_Inventory__c = coi.Id;
            coid1.Daily_Sales__c = rm1.Id;
            coid1.Quantity__c = 100;
            coid1.Exceed__c = false;
            Database.insert(coid1);

            Store_Inspection_Manage__c sim = new Store_Inspection_Manage__c();
            sim.Sales_Region__c = 'Hisense USA';
            sim.Year__c = String.valueOf(Date.today().year());
            sim.Month__c = String.valueOf(Date.today().month());
            sim.Task_Type__c = '销售额';
            sim.Product_Line__c  = 'TV';
            sim.Key__c = 'Hisense USA-' + Date.today().year() + '-' + Date.today().month() + '-TV-销售额';
            Database.insert(sim);

            Store_Inspection_Manage__c sim1 = new Store_Inspection_Manage__c();
            sim1.Sales_Region__c = 'Hisense USA';
            sim1.Year__c = String.valueOf(Date.today().year());
            sim1.Month__c = String.valueOf(Date.today().month());
            sim1.Task_Type__c = '销售额';
            sim.Product_Line__c  = 'TV';
            sim1.Store__c = shop1.id;
            sim1.Key__c = 'Hisense USA-' + Date.today().year() + '-' + Date.today().month() + '-TV-销售额-' + shop1.id;
            Database.insert(sim1);

            CustomerOrderInventoryVerifyBatch ss4  = new CustomerOrderInventoryVerifyBatch('8110');
            Database.executeBatch(ss4);

            CustomerOrderInventoryClearBatch ss1  = new CustomerOrderInventoryClearBatch('8110', '2023-01-01');
            Database.executeBatch(ss1);

            CustomerOrderInventoryBatch ss2  = new CustomerOrderInventoryBatch('8110', '2023-01-01');
            Database.executeBatch(ss2);

            CustomerOrderInventoryDailyBatch ss3  = new CustomerOrderInventoryDailyBatch('8110', '2023-01-01');
            Database.executeBatch(ss3);

            List<Customer_Order_Inventory_Daily__c> coidList = new List<Customer_Order_Inventory_Daily__c>();
            coidList.add(coid);
            CustomerOrderInventoryDailyJob aa = new CustomerOrderInventoryDailyJob(coidList);
            ID jobID = System.enqueueJob(aa);

            CustomerOrderInventoryVerifyDisBatch ss5  = new CustomerOrderInventoryVerifyDisBatch('8110');
            Database.executeBatch(ss5);

            CustomerOrderInventoryClearSchedulable cis = new CustomerOrderInventoryClearSchedulable('8110', '2023-01-01');
            SchedulableContext sc;
            cis.execute(sc);
        }
    }

}