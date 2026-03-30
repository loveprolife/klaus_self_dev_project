@isTest
private class SyncSampleDisplayFromSAPTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();

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

            SAP__c sdcc = new SAP__c();
            sdcc.Sample_Display__c = sd1.Id;
            sdcc.Number__c = 10;
            sdcc.SO__c = '111';
            insert sdcc;

            POD__c sap = new POD__c();
            sap.Sample_Display__c = sd1.Id;
            sap.Number__c = 10;
            sap.Status__c = 'pod';
            insert sap;

            String json = '{"ZTYPE":"S",' +
                '"ITAB": [' +
                    '{' +
                        '"VBELN": "111",' +
                        '"ZCUSMODEL": "HYXE-VA01A",' +
                        '"LGORT": "M003",' +
                        '"WERKS": 8140,' +
                        '"MATNR": "GKH128NC2012",' +
                        '"CHARG": "HR210461",' +
                        '"ERSDA": "2022-06-22",' +
                        '"LABST": "4950.000",' +
                        '"ZKYKC": "4950.000",' +
                        '"SOQTY": 0,' +
                        '"DNQTY": 0,' +
                        '"BRQTY": 0,' +
                        '"UBQTY": 0,' +
                        '"MTART": "FERT"' +
                    '}' +
                ']' +
            '}';

            Test.setMock(HttpCalloutMock.class, new CalloutMock(json));

            syncSampleDisplayFromSAP.syncSampleDisplayFromSAP('20241030');
            Test.stopTest();
        }
    }

    static testMethod void testMethod2() {
        TestDataUtility.createCustomSettings();

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

            SAP__c sdcc = new SAP__c();
            sdcc.Sample_Display__c = sd1.Id;
            sdcc.Number__c = 10;
            sdcc.SO__c = '111';
            insert sdcc;

            POD__c sap = new POD__c();
            sap.Sample_Display__c = sd1.Id;
            sap.Number__c = 10;
            sap.Status__c = 'pod';
            insert sap;

            String json = '{"ZTYPE":"S",' +
                '"ITAB": [' +
                    '{' +
                        '"VBELN": "111",' +
                        '"ZCUSMODEL": "HYXE-VA01A",' +
                        '"LGORT": "M003",' +
                        '"WERKS": 8140,' +
                        '"MATNR": "GKH128NC2012",' +
                        '"CHARG": "HR210461"' +
                        '"ERS-06-22",' +
                        '"LABST": "4950.000",' +
                        '"ZKYKC": "4950.000",' +
                        '"SOQTY": 0,' +
                        '"DNQTY": 0,' +
                        '"BRQTY": 0,' +
                        '"UBQTY": 0,' +
                        '"MTART": "FERT"' +
                    '}' +
                ']' +
            '}';

            Test.setMock(HttpCalloutMock.class, new CalloutMock(json));

            syncSampleDisplayFromSAP.syncSampleDisplayFromSAP('20241030');
            Test.stopTest();
        }
    }
}