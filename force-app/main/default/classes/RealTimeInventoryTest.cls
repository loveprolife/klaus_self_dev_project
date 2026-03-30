@isTest
private class RealTimeInventoryTest {
    static testmethod void test() {
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(
            Alias = 'admin', Email='RealTimeInventoryTest@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='RealTimeInventoryTest@hisensetest.com',Sales_Region__c = 'Hisense USA'
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
            order.Order_Date__c = Date.today();
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

            Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
            testReport1.Customer__c =  acc1.id;
            testReport1.Report_Date__c = Date.today();
            Database.insert(testReport1);

            Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
            testReport2.Customer__c =  acc1.id;
            testReport2.Report_Date__c = Date.today().addDays(1);
            Database.insert(testReport2);

            Retail_Number__c rm = new Retail_Number__c();
            rm.Product__c = productTest.id;
            rm.Number__c = 1;
            rm.Price__c = 199;
            rm.CurrencyIsoCode = 'USD';
            rm.Customer__c = acc1.id;
            rm.PromoterDailyReport__c = testReport1.id;
            rm.IsUpload__c = true;
            Database.insert(rm);

            Retail_Number__c rm1 = new Retail_Number__c();
            rm1.Product__c = productTest.id;
            rm1.Number__c = 100;
            rm1.Price__c = 199;
            rm1.CurrencyIsoCode = 'USD';
            rm1.Customer__c = acc1.id;
            rm1.PromoterDailyReport__c = testReport2.id;
            rm1.IsUpload__c = true;
            Database.insert(rm1);

            Real_Time_Inventory_Sub__c rtis = new Real_Time_Inventory_Sub__c();
            rtis.Customer__c = acc1.id;
            rtis.Product_Name__c = 'NTC-22E1';
            Database.insert(rtis);

            RealTimeInventoryDeleteBatch ss1  = new RealTimeInventoryDeleteBatch('Hisense USA', '2024-01-01');
            Database.executeBatch(ss1);

        }
    }

    static testmethod void test1() {
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(
            Alias = 'admin', Email='RealTimeInventoryTest@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='RealTimeInventoryTest@hisensetest.com',Sales_Region__c = 'Hisense USA'
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

            Account acc2 = new Account(
                Name = 'Test Account002',
                SAP_Customer_Code__c = '1234987650',
                External_Key__c = '1234987650',
                Sales_Region__c = 'Hisense Indonesia',
                Type = 'Management'
            );
            Database.insert(acc2);

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
            order.Order_Date__c = Date.today();
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

            Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
            testReport1.Customer__c =  acc1.id;
            testReport1.Report_Date__c = Date.today();
            Database.insert(testReport1);

            Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
            testReport2.Customer__c =  acc1.id;
            testReport2.Report_Date__c = Date.today().addDays(1);
            Database.insert(testReport2);

            Retail_Number__c rm = new Retail_Number__c();
            rm.Product__c = productTest.id;
            rm.Number__c = 1;
            rm.Price__c = 199;
            rm.CurrencyIsoCode = 'USD';
            rm.Customer__c = acc1.id;
            rm.PromoterDailyReport__c = testReport1.id;
            rm.IsUpload__c = true;
            Database.insert(rm);

            Retail_Number__c rm1 = new Retail_Number__c();
            rm1.Product__c = productTest.id;
            rm1.Number__c = 100;
            rm1.Price__c = 199;
            rm1.CurrencyIsoCode = 'USD';
            rm1.Customer__c = acc1.id;
            rm1.PromoterDailyReport__c = testReport2.id;
            rm1.IsUpload__c = true;
            Database.insert(rm1);

            Real_Time_Inventory__c rti = new Real_Time_Inventory__c();
            rti.Customer__c = acc1.id;
            rti.Inventory_Date__c = Date.valueOf('2024-01-04');
            rti.Product_Name__c = productTest.Name;
            rti.Key__c = rti.Inventory_Date__c + '-' +  rti.Customer__c + '-' + rti.Product_Name__c;
            rti.Sell_In_Number__c = 10;
            rti.Sell_Out_Number__c = 2;
            rti.Inventory__c = 8;
            Database.insert(rti);

            Real_Time_Inventory__c rti1 = new Real_Time_Inventory__c();
            rti1.Customer__c = acc1.id;
            rti1.Inventory_Date__c = Date.valueOf('2024-01-06');
            rti1.Product_Name__c = productTest.Name;
            rti1.Key__c = rti1.Inventory_Date__c + '-' +  rti1.Customer__c + '-' + rti1.Product_Name__c;
            rti1.Sell_In_Number__c = 10;
            rti1.Sell_Out_Number__c = 2;
            rti1.Inventory__c = 16;
            Database.insert(rti1);

            Real_Time_Inventory__c rti2 = new Real_Time_Inventory__c();
            rti2.Customer__c = acc2.id;
            rti2.Inventory_Date__c = Date.valueOf('2024-01-07');
            rti2.Product_Name__c = productTest.Name;
            rti2.Key__c = rti2.Inventory_Date__c + '-' +  rti2.Customer__c + '-' + rti2.Product_Name__c;
            rti2.Sell_In_Number__c = 10;
            rti2.Sell_Out_Number__c = 2;
            rti2.Inventory__c = 16;

            RealTimeInventoryReportBatch ss4  = new RealTimeInventoryReportBatch('Hisense USA', '2024-01-01');
            Database.executeBatch(ss4);

            RealTimeInventorySchedulable cis = new RealTimeInventorySchedulable('Hisense USA', '2024-01-01');
            SchedulableContext sc;
            cis.execute(sc);

            System.enqueueJob(new RealTimeInventoryInitializeBatch.RealTimeInventoryAsyncSync(new List<Real_Time_Inventory__c>{rti2}));
        }
    }

}