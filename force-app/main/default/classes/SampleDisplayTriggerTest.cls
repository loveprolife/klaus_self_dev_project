/*
 * @Author: WFC
 * @Date: 2024-10-21 14:42:41
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-10 16:14:00
 * @Description: 样机管理test类
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplayTriggerTest.cls
 */
@isTest
private class SampleDisplayTriggerTest{
    static testMethod void testSampleDisplayTriggerHandler(){
        Profile p = [SELECT Id, Name
                     FROM Profile
                     WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', 
            Email = 'SampleDisplayTrigger@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'SampleDisplayTrigger@hisensetest.com', 
            Sales_Region__c = 'Hisense Indonesia'
        );
        Database.insert (user1);

        System.runAs(user1){

            Account acc = new Account(
                Name = 'Example'
            );
            insert acc;

            Shop__c store = new Shop__c();
            store.Name = 'Hi Fi Corporation NEWCASTLE';
            store.Account__c = acc.Id;
            store.Sales_Region__c = 'Hisense Indonesia';
            insert store;

            Shop__c store1 = new Shop__c();
            store1.Name = '1111111';
            store1.Account__c = acc.Id;
            store1.Sales_Region__c = 'Hisense Indonesia';
            insert store1;

            Shop__c store2 = new Shop__c();
            store2.Name = '222222';
            store2.Account__c = acc.Id;
            store2.Sales_Region__c = 'Hisense Indonesia';
            insert store2;

            Product__c productTest = new Product__c();
            productTest.Name = 'NTC-22E';
            productTest.CurrencyIsoCode = 'USD';
            productTest.Product_Line__c = 'TV';
            productTest.Product_External_Id__c = 'NTC-22E-Returns';
            productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            productTest.Sales_Region__c = 'Hisense Indonesia';
            Insert productTest;

            Test.startTest();

            Sample_Display__c sd = new Sample_Display__c();
            sd.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Channel').getRecordTypeId();
            sd.Product_Model__c = productTest.Id;
            sd.Channel_Text__c = '111';
            sd.Number__c = 10;
            sd.Deadline__c = Date.today();
            sd.Approval_Status__c = 'Approved';
            sd.Customer__c = acc.Id;
            insert sd;

            Sample_Display__c sd1 = new Sample_Display__c();
            sd1.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
            sd1.Product_Model__c = productTest.Id;
            sd1.Store__c = store.Id;
            sd1.Number__c = 10;
            sd1.Deadline__c = Date.today();
            sd1.Approval_Status__c = 'Approved';
            insert sd1;

            Sample_Display_Customer_Confirm__c sdcc = new Sample_Display_Customer_Confirm__c();
            sdcc.Sample_Display__c = sd.Id;
            sdcc.Product_Model__c = productTest.Id;
            sdcc.Customer__c = acc.Id;
            sdcc.Number__c = 20;
            insert sdcc;

            Sample_Display_Customer_Confirm__c sdcc1 = new Sample_Display_Customer_Confirm__c();
            sdcc1.Sample_Display__c = sd1.Id;
            sdcc1.Product_Model__c = productTest.Id;
            sdcc1.Customer__c = acc.Id;
            sdcc1.Number__c = 20;
            insert sdcc1;

            SAP_Customer_Detail__c sap = new SAP_Customer_Detail__c();
            sap.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sap.Number__c = 20;
            sap.Status__c = 'C';
            insert sap;

            SAP_Customer_Detail__c sap1 = new SAP_Customer_Detail__c();
            sap1.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sap1.Number__c = 10;
            sap1.Status__c = 'C';
            insert sap1;

            SAP_Customer_Detail__c sap2 = new SAP_Customer_Detail__c();
            sap2.Sample_Display_Customer_Confirm__c = sdcc1.Id;
            sap2.Number__c = 10;
            sap2.Status__c = 'C';
            insert sap2;

            Sample_Display_Confirm__c sdc = new Sample_Display_Confirm__c();
            sdc.Sample_Display__c = sd.Id;
            sdc.Store__c = store.Id;
            sdc.Number__c = 12;
            sdc.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc.Customer__c = acc.Id;
            sdc.Product_Model__c = productTest.Id;
            insert sdc;

            Sample_Display_Confirm__c sdc1 = new Sample_Display_Confirm__c();
            sdc1.Sample_Display__c = sd.Id;
            sdc1.Store__c = store1.Id;
            sdc1.Number__c = 3;
            sdc1.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc1.Customer__c = acc.Id;
            sdc1.Product_Model__c = productTest.Id;
            insert sdc1;

            Sample_Display_Confirm__c sdc2 = new Sample_Display_Confirm__c();
            sdc2.Sample_Display__c = sd.Id;
            sdc2.Store__c = store2.Id;
            sdc2.Number__c = 3;
            sdc2.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc2.Customer__c = acc.Id;
            sdc2.Product_Model__c = productTest.Id;
            insert sdc2;

            // // Create an approval request for the account
            // Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            // req1.setComments('Submitting request for approval.');
            // req1.setObjectId(sd.id);
            // // Submit on behalf of a specific submitter
            // req1.setSubmitterId(user1.Id);
            // req1.setNextApproverIds(new List<String>{ user1.Id });
            // // Submit the record to specific process and skip the criteria evaluation
            // req1.setProcessDefinitionNameOrId('Test_Approval');
            // req1.setSkipEntryCriteria(true);

            // // Submit the approval request for the account
            // Approval.ProcessResult result1 = Approval.process(req1);

            sdcc.Number__c = 13;
            update sdcc;

            sdc.Number__c = 11;
            sdc.Upload_File_Flag__c = true;
            sdc.Status__c = 'Completed';
            update sdc;

            sd.Approval_Status__c = 'Approved';
            update sd;

            sd.Approval_Status__c = 'Draft';
            update sd;

            delete sdc;
            delete sdcc;
            delete sd;

            Sample_Removal__c sr = new Sample_Removal__c();
            sr.Product_Model__c = productTest.Id;
            sr.Store__c = store.Id;
            sr.Number__c = 2;
            sr.Deadline__c = Date.today();
            insert sr;

            Sample_Removal_Confirm__c src = new Sample_Removal_Confirm__c();
            src.Sample_Removal_Code__c = sr.Id;
            src.Store__c = store.Id;
            src.Product_Model__c = productTest.Id;
            src.Number__c = 2;
            src.Status__c = 'Uncompleted';
            src.Deadline__c = Date.today();
            src.Key__c = productTest.Id + '-' + store.Id;
            insert src;

            sr.Approval_Status__c = 'Approved';
            update sr;

            SubUser__c subUser = new SubUser__c();
            subUser.ParentUser__c = user1.Id;
            subUser.IsActive__c = true;
            Insert subUser;

            SubStore__c subStore1 = new SubStore__c();
            subStore1.StoreID__c = store.Id;
            subStore1.SubUserID__c = subUser.Id;
            Insert subStore1;

            SubStore__c subStore2 = new SubStore__c();
            subStore2.StoreID__c = store1.Id;
            subStore2.SubUserID__c = subUser.Id;
            Insert subStore2;

            SubUser_Device__c subDevice = new SubUser_Device__c();
            subDevice.SubUserID__c = subUser.Id;
            subDevice.IsActive__c = true;
            subDevice.LastUsedTime__c = System.now();
            subDevice.DeviceID__c = '001';
            Insert subDevice;

            SubUserLog__c subUserLog = new SubUserLog__c();
            subUserLog.SubUser__c = subUser.Id;
            subUserLog.StoreId__c = store.Id;
            subUserLog.Action_Time__c = System.now();
            subUserLog.DeviceID__c = subDevice.Id;
            Insert subUserLog;

            SampleDisplayConfirmController.getSampleDisplayConfirmData('001');
            SampleDisplayConfirmController.getSampleRemovalConfirmData('001');

            Test.stopTest();
        }
    }

    static testMethod void testSAPCustomerDetailTriggerHandler(){
        Profile p = [SELECT Id, Name
                     FROM Profile
                     WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', 
            Email = 'SampleDisplayTrigger@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'SampleDisplayTrigger@hisensetest.com', 
            Sales_Region__c = 'Hisense Indonesia'
        );
        Database.insert (user1);

        System.runAs(user1){

            Account acc = new Account(
                Name = 'Example'
            );
            insert acc;

            Shop__c store = new Shop__c();
            store.Name = 'Hi Fi Corporation NEWCASTLE';
            store.Account__c = acc.Id;
            store.Sales_Region__c = 'Hisense Indonesia';
            insert store;

            Shop__c store1 = new Shop__c();
            store1.Name = '1111111';
            store1.Account__c = acc.Id;
            store1.Sales_Region__c = 'Hisense Indonesia';
            insert store1;

            Shop__c store2 = new Shop__c();
            store2.Name = '222222';
            store2.Account__c = acc.Id;
            store2.Sales_Region__c = 'Hisense Indonesia';
            insert store2;

            Product__c productTest = new Product__c();
            productTest.Name = 'NTC-22E';
            productTest.CurrencyIsoCode = 'USD';
            productTest.Product_Line__c = 'TV';
            productTest.Product_External_Id__c = 'NTC-22E-Returns';
            productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            productTest.Sales_Region__c = 'Hisense Indonesia';
            Insert productTest;

            Test.startTest();

            Sample_Display__c sd1 = new Sample_Display__c();
            sd1.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
            sd1.Product_Model__c = productTest.Id;
            sd1.Store__c = store.Id;
            sd1.Number__c = 10;
            sd1.Deadline__c = Date.today();
            sd1.Approval_Status__c = 'Approved';
            insert sd1;

            Sample_Display_Customer_Confirm__c sdcc = new Sample_Display_Customer_Confirm__c();
            sdcc.Sample_Display__c = sd1.Id;
            sdcc.Product_Model__c = productTest.Id;
            sdcc.Customer__c = acc.Id;
            sdcc.Number__c = 10;
            insert sdcc;

            SAP_Customer_Detail__c sap = new SAP_Customer_Detail__c();
            sap.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sap.Number__c = 10;
            sap.Status__c = 'C';
            insert sap;

            Test.stopTest();
        }
    }

    static testMethod void testSampleDisplayController(){
        Profile p = [SELECT Id, Name
                     FROM Profile
                     WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', 
            Email = 'SampleDisplayTrigger@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'SampleDisplayTrigger@hisensetest.com', 
            Sales_Region__c = 'Hisense Indonesia'
        );
        Database.insert (user1);

        System.runAs(user1){

            Account acc = new Account(
                Name = 'Example'
            );
            insert acc;

            Shop__c store = new Shop__c();
            store.Name = 'Hi Fi Corporation NEWCASTLE';
            store.Account__c = acc.Id;
            store.Sales_Region__c = 'Hisense Indonesia';
            store.Shop_Code_Text__c = '111';
            insert store;

            Shop__c store1 = new Shop__c();
            store1.Name = '1111111';
            store1.Account__c = acc.Id;
            store1.Sales_Region__c = 'Hisense Indonesia';
            store1.Shop_Code_Text__c = '222';
            insert store1;

            Shop__c store2 = new Shop__c();
            store2.Name = '222222';
            store2.Account__c = acc.Id;
            store2.Sales_Region__c = 'Hisense Indonesia';
            store2.Shop_Code_Text__c = '333';
            insert store2;

            Product__c productTest = new Product__c();
            productTest.Name = 'NTC-22E';
            productTest.CurrencyIsoCode = 'USD';
            productTest.Product_Line__c = 'TV';
            productTest.Product_External_Id__c = 'NTC-22E-Returns';
            productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            productTest.Sales_Region__c = 'Hisense Indonesia';
            Insert productTest;

            Test.startTest();

            Sample_Display__c sd = new Sample_Display__c();
            sd.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Channel').getRecordTypeId();
            sd.Product_Model__c = productTest.Id;
            sd.Channel_Text__c = '111';
            sd.Customer__c = acc.Id;
            sd.Number__c = 10;
            sd.Deadline__c = Date.today();
            sd.Approval_Status__c = 'Approved';
            insert sd;

            Sample_Display__c sd1 = new Sample_Display__c();
            sd1.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
            sd1.Product_Model__c = productTest.Id;
            sd1.Store__c = store.Id;
            sd1.Number__c = 10;
            sd1.Deadline__c = Date.today();
            sd1.Approval_Status__c = 'Approved';
            insert sd1;

            Sample_Display_Customer_Confirm__c sdcc = new Sample_Display_Customer_Confirm__c();
            sdcc.Sample_Display__c = sd.Id;
            sdcc.Product_Model__c = productTest.Id;
            sdcc.Customer__c = acc.Id;
            sdcc.Number__c = 20;
            insert sdcc;

            SAP_Customer_Detail__c sap = new SAP_Customer_Detail__c();
            sap.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sap.Number__c = 20;
            sap.Status__c = 'C';
            insert sap;

            SAP_Customer_Detail__c sap1 = new SAP_Customer_Detail__c();
            sap1.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sap1.Number__c = 10;
            sap1.Status__c = 'C';
            insert sap1;

            Sample_Display_Confirm__c sdc = new Sample_Display_Confirm__c();
            sdc.Sample_Display__c = sd.Id;
            sdc.Store__c = store.Id;
            sdc.Number__c = 12;
            sdc.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc.Customer__c = acc.Id;
            sdc.Product_Model__c = productTest.Id;
            insert sdc;

            Sample_Display_Confirm__c sdc1 = new Sample_Display_Confirm__c();
            sdc1.Sample_Display__c = sd.Id;
            sdc1.Store__c = store1.Id;
            sdc1.Number__c = 3;
            sdc1.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc1.Customer__c = acc.Id;
            sdc1.Product_Model__c = productTest.Id;
            insert sdc1;

            Sample_Display_Confirm__c sdc2 = new Sample_Display_Confirm__c();
            sdc2.Sample_Display__c = sd.Id;
            sdc2.Store__c = store2.Id;
            sdc2.Number__c = 3;
            sdc2.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc2.Customer__c = acc.Id;
            sdc2.Product_Model__c = productTest.Id;
            insert sdc2;

            Sample_Removal__c sr = new Sample_Removal__c();
            sr.Product_Model__c = productTest.Id;
            sr.Store__c = store.Id;
            sr.Number__c = 2;
            sr.Deadline__c = Date.today();
            insert sr;

            Sample_Removal_Confirm__c src = new Sample_Removal_Confirm__c();
            src.Sample_Removal_Code__c = sr.Id;
            src.Store__c = store.Id;
            src.Product_Model__c = productTest.Id;
            src.Number__c = 2;
            src.Status__c = 'Uncompleted';
            src.Deadline__c = Date.today();
            src.Key__c = productTest.Id + '-' + store.Id;
            insert src;

            sr.Approval_Status__c = 'Approved';
            update sr;

            SampleDisplayController.storeDetailUploadFile(sdc.Id);
            SampleDisplayController.storeDetailUploadFile(src.Id);
            SampleDisplayController.saveAdditionalInformation(sdc.Id, 'New', null);
            SampleDisplayController.saveAdditionalInformation(sdc.Id, 'Replace', productTest.Id);

            Blob b = Blob.valueOf('Sales Region,Task Level,Product Model,Channel or Store Code,Number,Deadline\r\n' + 
                               'Hisense Indonesia,Channel,NTC-22E,123123,2,20240-06-24\r\n' + 
                               'Hisense Indonesia,Store,NTC-22E,111,2,2024-06-24\r\n');
            String s = EncodingUtil.base64Encode(b);
            SampleDisplayController.saveSampleDisplayFile('Test.csv', s);

            Blob b1 = Blob.valueOf('Product Model,Store Name,Store Code,Number,Deadline\r\n' + 
                                 'NTC-22E,111,111,2,2024-06-24\r\n' + 
                                 'NTC-22E,222,222,2,2024-06-24\r\n');
            String s1 = EncodingUtil.base64Encode(b1);
            SampleDisplayController.saveSampleRemovalFile('Test1.csv', s1);

            Blob b2 = Blob.valueOf('Sample Display Code 2,Store Name,Store Code,Number\r\n' + sdcc.Name + ',111,111,2\r\n' + sdcc.Name + ',222,222,2\r\n');
            String s2 = EncodingUtil.base64Encode(b2);
            SampleDisplayController.saveStoreDetailConfirmFile(sdcc.Id, productTest.Id, 'Test2.csv', s2);

            Blob b3 = Blob.valueOf('123');
            String s3 = EncodingUtil.base64Encode(b3);
            RowIteratorUtility r = New RowIteratorUtility(s3);

            Test.stopTest();
        }
    }

    static testMethod void testSampleDisplayDetailsController(){
        Profile p = [SELECT Id, Name
                     FROM Profile
                     WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', 
            Email = 'SampleDisplayTrigger@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'SampleDisplayTrigger@hisensetest.com', 
            Sales_Region__c = 'Hisense Indonesia'
        );
        Database.insert (user1);

        System.runAs(user1){

            Account acc = new Account(
                Name = 'Example'
            );
            insert acc;

            Shop__c store = new Shop__c();
            store.Name = 'Hi Fi Corporation NEWCASTLE';
            store.Account__c = acc.Id;
            store.Sales_Region__c = 'Hisense Indonesia';
            store.Shop_Code_Text__c = '111';
            insert store;

            Shop__c store1 = new Shop__c();
            store1.Name = '1111111';
            store1.Account__c = acc.Id;
            store1.Sales_Region__c = 'Hisense Indonesia';
            store1.Shop_Code_Text__c = '222';
            insert store1;

            Shop__c store2 = new Shop__c();
            store2.Name = '222222';
            store2.Account__c = acc.Id;
            store2.Sales_Region__c = 'Hisense Indonesia';
            store2.Shop_Code_Text__c = '333';
            insert store2;

            Product__c productTest = new Product__c();
            productTest.Name = 'NTC-22E';
            productTest.CurrencyIsoCode = 'USD';
            productTest.Product_Line__c = 'TV';
            productTest.Product_External_Id__c = 'NTC-22E-Returns';
            productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            productTest.Sales_Region__c = 'Hisense Indonesia';
            Insert productTest;

            Test.startTest();

            Sample_Display__c sd = new Sample_Display__c();
            sd.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Channel').getRecordTypeId();
            sd.Product_Model__c = productTest.Id;
            sd.Channel_Text__c = '111';
            sd.Number__c = 10;
            sd.Deadline__c = Date.today();
            sd.Approval_Status__c = 'Approved';
            sd.Customer__c = acc.Id;
            insert sd;

            Sample_Display__c sd1 = new Sample_Display__c();
            sd1.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
            sd1.Product_Model__c = productTest.Id;
            sd1.Store__c = store.Id;
            sd1.Number__c = 10;
            sd1.Deadline__c = Date.today();
            sd1.Approval_Status__c = 'Approved';
            insert sd1;

            Sample_Display_Customer_Confirm__c sdcc = new Sample_Display_Customer_Confirm__c();
            sdcc.Sample_Display__c = sd.Id;
            sdcc.Product_Model__c = productTest.Id;
            sdcc.Customer__c = acc.Id;
            sdcc.Number__c = 20;
            insert sdcc;

            SAP_Customer_Detail__c sap = new SAP_Customer_Detail__c();
            sap.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sap.Number__c = 20;
            sap.Status__c = 'C';
            insert sap;

            SAP_Customer_Detail__c sap1 = new SAP_Customer_Detail__c();
            sap1.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sap1.Number__c = 10;
            sap1.Status__c = 'C';
            insert sap1;

            Sample_Display_Confirm__c sdc = new Sample_Display_Confirm__c();
            sdc.Sample_Display__c = sd.Id;
            sdc.Store__c = store.Id;
            sdc.Number__c = 12;
            sdc.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc.Customer__c = acc.Id;
            sdc.Product_Model__c = productTest.Id;
            insert sdc;

            Sample_Display_Confirm__c sdc1 = new Sample_Display_Confirm__c();
            sdc1.Sample_Display__c = sd.Id;
            sdc1.Store__c = store1.Id;
            sdc1.Number__c = 3;
            sdc1.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc1.Customer__c = acc.Id;
            sdc1.Product_Model__c = productTest.Id;
            insert sdc1;

            Sample_Display_Confirm__c sdc2 = new Sample_Display_Confirm__c();
            sdc2.Sample_Display__c = sd.Id;
            sdc2.Store__c = store2.Id;
            sdc2.Number__c = 3;
            sdc2.Sample_Display_Customer_Confirm__c = sdcc.Id;
            sdc2.Customer__c = acc.Id;
            sdc2.Product_Model__c = productTest.Id;
            insert sdc2;

            Sample_Removal__c sr = new Sample_Removal__c();
            sr.Product_Model__c = productTest.Id;
            sr.Store__c = store.Id;
            sr.Number__c = 2;
            sr.Deadline__c = Date.today();
            insert sr;

            sr.Approval_Status__c = 'Approved';
            update sr;

            SampleDisplayDetailsController.searchSampleDisplay(sd.Id);

            Blob b = Blob.valueOf('123');
            String s = EncodingUtil.base64Encode(b);
            SampleDisplayDetailsController.saveCustomerDetail(sd.Id, productTest.Id, acc.Id, '10', 'Store', '111.txt', s);

            SampleDisplayDetailsController.saveStoreDetail(sd.Id, productTest.Id, store.Id, '10', true);
            SampleDisplayDetailsController.verifyStoreDetailsNumber(sd.Id);
            SampleDisplayDetailsController.searchSampleDisplaySAP(sd.Id);

            Test.stopTest();
        }
    }

    static testMethod void test01(){
        Profile p = [SELECT Id, Name
                     FROM Profile
                     WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin', 
            Email = 'SampleDisplayTrigger@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'SampleDisplayTrigger@hisensetest.com', 
            Sales_Region__c = 'Hisense Indonesia'
        );
        Database.insert (user1);

        System.runAs(user1){

            Account acc = new Account(
                Name = 'Example'
            );
            insert acc;

            Shop__c store = new Shop__c();
            store.Name = 'Hi Fi Corporation NEWCASTLE';
            store.Account__c = acc.Id;
            store.Sales_Region__c = 'Hisense Indonesia';
            insert store;

            Shop__c store1 = new Shop__c();
            store1.Name = '1111111';
            store1.Account__c = acc.Id;
            store1.Sales_Region__c = 'Hisense Indonesia';
            insert store1;

            Shop__c store2 = new Shop__c();
            store2.Name = '222222';
            store2.Account__c = acc.Id;
            store2.Sales_Region__c = 'Hisense Indonesia';
            insert store2;

            Shop__c store3 = new Shop__c();
            store3.Name = '33333';
            store3.Account__c = acc.Id;
            store3.Sales_Region__c = 'Hisense Indonesia';
            insert store3;

            Product__c productTest = new Product__c();
            productTest.Name = 'NTC-22E';
            productTest.CurrencyIsoCode = 'USD';
            productTest.Product_Line__c = 'TV';
            productTest.Product_External_Id__c = 'NTC-22E-Returns';
            productTest.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            productTest.Sales_Region__c = 'Hisense Indonesia';
            Insert productTest;

            Test.startTest();

            Sample_Display__c sd = new Sample_Display__c();
            sd.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Channel').getRecordTypeId();
            sd.Product_Model__c = productTest.Id;
            sd.Channel_Text__c = '111';
            sd.Number__c = 10;
            sd.Deadline__c = Date.today();
            sd.Approval_Status__c = 'Submitted';
            sd.Customer__c = acc.Id;
            insert sd;

            Sample_Display__c sdd = new Sample_Display__c();
            sdd.RecordTypeId = Schema.SobjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
            sdd.Product_Model__c = productTest.Id;
            sdd.Channel_Text__c = '111';
            sdd.Number__c = 10;
            sdd.Deadline__c = Date.today();
            sdd.Approval_Status__c = 'Submitted';
            sdd.Store__c = store.Id;
            insert sdd;

            Store_Detail__c storeDetail = new Store_Detail__c();
            storeDetail.Sample_Display__c = sdd.Id;
            storeDetail.Product_Model__c = productTest.Id;
            storeDetail.Number__c = 3;
            storeDetail.Store__c = store3.Id;
            storeDetail.Priority__c = false;
            insert storeDetail;

            delete storeDetail;

            Store_Detail__c storeDetail1 = new Store_Detail__c();
            storeDetail1.Sample_Display__c = sd.Id;
            storeDetail1.Product_Model__c = productTest.Id;
            storeDetail1.Number__c = 3;
            storeDetail1.Store__c = store.Id;
            storeDetail1.Priority__c = false;
            insert storeDetail1;

            Store_Detail__c storeDetail2 = new Store_Detail__c();
            storeDetail2.Sample_Display__c = sd.Id;
            storeDetail2.Product_Model__c = productTest.Id;
            storeDetail2.Number__c = 3;
            storeDetail2.Store__c = store1.Id;
            storeDetail2.Priority__c = true;
            insert storeDetail2;

            Store_Detail__c storeDetail3 = new Store_Detail__c();
            storeDetail3.Sample_Display__c = sd.Id;
            storeDetail3.Product_Model__c = productTest.Id;
            storeDetail3.Number__c = 4;
            storeDetail3.Store__c = store2.Id;
            storeDetail3.Priority__c = false;
            insert storeDetail3;

            sd.Path__c = 'Retail Manager Approve';
            update sd;

            Po__c po = new Po__c();
            po.Sample_Display__c = sd.Id;
            po.Customer__c = acc.Id;
            po.Number__c = 2;
            po.Product_Model__c = productTest.Id;
            po.Category_of_Delivery_Address__c = 'Store';
            insert po;

            Po__c po1 = new Po__c();
            po1.Sample_Display__c = sd.Id;
            po1.Customer__c = acc.Id;
            po1.Number__c = 2;
            po1.Product_Model__c = productTest.Id;
            po1.Category_of_Delivery_Address__c = 'Customer';
            insert po1;

            Po__c po2 = new Po__c();
            po2.Sample_Display__c = sd.Id;
            po2.Customer__c = acc.Id;
            po2.Number__c = 2;
            po2.Product_Model__c = productTest.Id;
            po2.Category_of_Delivery_Address__c = 'Store';
            insert po2;

            Po__c po3 = new Po__c();
            po3.Sample_Display__c = sd.Id;
            po3.Customer__c = acc.Id;
            po3.Number__c = 2;
            po3.Product_Model__c = productTest.Id;
            po3.Category_of_Delivery_Address__c = 'Store';
            insert po3;

            Po__c po4 = new Po__c();
            po4.Sample_Display__c = sd.Id;
            po4.Customer__c = acc.Id;
            po4.Number__c = 1;
            po4.Product_Model__c = productTest.Id;
            po4.Category_of_Delivery_Address__c = 'Store';
            insert po4;

            Po__c po5 = new Po__c();
            po5.Sample_Display__c = sd.Id;
            po5.Customer__c = acc.Id;
            po5.Number__c = 1;
            po5.Product_Model__c = productTest.Id;
            po5.Category_of_Delivery_Address__c = 'Store';
            insert po5;

            SAP__c sap = new SAP__c();
            sap.Sample_Display__c = sd.Id;
            sap.Number__c = 10;
            insert sap;

            POD__c pod = new POD__c();
            pod.Sample_Display__c = sd.Id;
            pod.Number__c = 4;
            insert pod;

            POD__c pod1 = new POD__c();
            pod1.Sample_Display__c = sd.Id;
            pod1.Number__c = 3;
            insert pod1;

            POD__c pod2 = new POD__c();
            pod2.Sample_Display__c = sd.Id;
            pod2.Number__c = 3;
            insert pod2;

            pod.Status__c = 'C';
            pod1.Status__c = 'C';
            pod2.Status__c = 'C';

            update pod;
            update pod1;
            update pod2;

            delete po2;

            sd.Path__c = 'Sample Task';
            update sd;

            sap.Edit_Flag__c = true;
            update sap;

            sd.Approval_Status__c = 'draft';
            update sd;

            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(sd.id);
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(user1.Id);
            req1.setNextApproverIds(new List<String>{user1.Id});
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Thailand_Customer_TV_Hisense');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result1 = Approval.process(req1);

            SampleDisplayMailOverdueInvocableMethod.processMailOverdue(null);

            SampleDisplaySendCCEmailInvocableMethod.processMailCC(new List<String>{ sd.Id });

            TestDataUtility.createCustomSettings();
            List<String> sampleDisplayIdList = new List<String>{ sd.Id };
            SampleDisplayPOApprovedController.splitPO(sampleDisplayIdList);

            SampleDisplayDetailsController.storeDetailsSubmit(sd.Id);

            Test.stopTest();
        }
    }

}