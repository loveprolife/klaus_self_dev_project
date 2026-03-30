@isTest
private class SelloutReportControllerTest{
    static testMethod void testMethod1(){
        string monthRecordTypeId = [SELECT Id, DeveloperName, SobjectType
                                    FROM RecordType
                                    WHERE SobjectType = 'SalesGoal__c' AND DeveloperName = 'Month'].Id;
        Profile p = [SELECT Id, Name
                     FROM Profile
                     WHERE Name = 'System Administrator'];

        User user1 = new User(
            Alias = 'admin1', 
            Email = 'systemadmin1@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'systemadmin1@hisensetest.com'
        );
        insert user1;
        User user2 = new User(
            Alias = 'admin2', 
            Email = 'systemadmin2@hisensetest.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'sales representative', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey = 'Asia/Kuala_Lumpur', 
            UserName = 'systemadmin2@hisensetest.com', 
            ManagerId = user1.Id
        );
        insert user2;

        system.runAs(user2){
            Account customer = new Account();
            customer.Name = 'Wal-mart';
            insert customer;

            Shop__c store = new Shop__c();
            store.Name = 'Hi Fi Corporation NEWCASTLE';
            store.Account__c = customer.Id;
            store.Sales_Region__c = 'Hisense Chile';
            insert store;

            Promoter_Attendance_Rule__c attendanceRule = new Promoter_Attendance_Rule__c();
            attendanceRule.Start_time__c = Time.newInstance(9, 0, 0, 0);
            attendanceRule.End_time__c = Time.newInstance(18, 0, 0, 0);
            attendanceRule.Time_buffer__c = 15;
            insert attendanceRule;

            Responsible_Person__c promoterRes = new Responsible_Person__c();
            promoterRes.Shop_Name__c = store.Id;
            promoterRes.Principal__c = user2.Id;
            promoterRes.RecordType__c = '促销员';
            promoterRes.Promoter_Attendance_Rule__c = attendanceRule.Id;
            insert promoterRes;

            SalesGoal__c monthGoal = new SalesGoal__c();
            monthGoal.RecordTypeId = monthRecordTypeId;
            monthGoal.Store__c = store.Id;
            monthGoal.Year__c = String.valueOf(Date.today().year());
            monthGoal.Month__c = String.valueOf(Date.today().month());
            monthGoal.ResponsiblePerson__c = promoterRes.Id;
            monthGoal.Amounts__c = 880000;
            monthGoal.IsActive__c = true;
            insert monthGoal;

            // promoter daily report
            Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
            testReport1.Customer__c = customer.id;
            testReport1.Shop__c = store.id;
            testReport1.Report_Date__c = Date.today();
            insert testReport1;

            // product
            Product__c product1 = new Product__c();
            product1.Name = 'TVtest';
            product1.CurrencyIsoCode = 'USD';
            product1.Product_Line__c = 'TV';
            product1.Product_External_Id__c = 'TVtest';
            product1.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            insert product1;

            Product__c product2 = new Product__c();
            product2.Name = 'Refrigeratortest';
            product2.CurrencyIsoCode = 'USD';
            product2.Product_Line__c = 'Refrigerator';
            product2.Product_External_Id__c = 'Refrigeratortest';
            product2.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            insert product2;

            Product__c product3 = new Product__c();
            product3.Name = 'WMtest';
            product3.CurrencyIsoCode = 'USD';
            product3.Product_Line__c = 'WM';
            product3.Product_External_Id__c = 'WMtest';
            product3.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            insert product3;

            Product__c product4 = new Product__c();
            product4.Name = 'ACtest';
            product4.CurrencyIsoCode = 'USD';
            product4.Product_Line__c = 'AC';
            product4.Product_External_Id__c = 'ACtest';
            product4.RecordTypeId = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Gift').getRecordTypeId();
            insert product4;

            // daily sales
            Retail_Number__c daily = new Retail_Number__c();
            daily.Shop__c = store.id;
            daily.Product__c = product1.id;
            daily.Number__c = 1;
            daily.Price__c = 199;
            daily.CurrencyIsoCode = 'USD';
            daily.Customer__c = customer.id;
            daily.PromoterDailyReport__c = testReport1.id;
            daily.IsUpload__c = true;
            daily.Status__c = 'Submitted';
            insert daily;
            
            Retail_Number__c daily1 = new Retail_Number__c();
            daily1.Shop__c = store.id;
            daily1.Product__c = product2.id;
            daily1.Number__c = 1;
            daily1.Price__c = 199;
            daily1.CurrencyIsoCode = 'USD';
            daily1.Customer__c = customer.id;
            daily1.PromoterDailyReport__c = testReport1.id;
            daily1.IsUpload__c = true;
            daily1.Status__c = 'Submitted';
            insert daily1;

            Retail_Number__c daily2 = new Retail_Number__c();
            daily2.Shop__c = store.id;
            daily2.Product__c = product3.id;
            daily2.Number__c = 1;
            daily2.Price__c = 199;
            daily2.CurrencyIsoCode = 'USD';
            daily2.Customer__c = customer.id;
            daily2.PromoterDailyReport__c = testReport1.id;
            daily2.IsUpload__c = true;
            daily2.Status__c = 'Submitted';
            insert daily2;

            Retail_Number__c daily3 = new Retail_Number__c();
            daily3.Shop__c = store.id;
            daily3.Product__c = product4.id;
            daily3.Number__c = 1;
            daily3.Price__c = 199;
            daily3.CurrencyIsoCode = 'USD';
            daily3.Customer__c = customer.id;
            daily3.PromoterDailyReport__c = testReport1.id;
            daily3.IsUpload__c = true;
            daily3.Status__c = 'Submitted';
            insert daily3;
        }

        Sellout_Report_User__c sru = new Sellout_Report_User__c();
        sru.User__c = user1.Id;
        sru.TV_Key_Model__c = 'TVtest';
        sru.Refrigerator_Key_Model__c = 'Refrigeratortest';
        insert sru;

        Test.startTest();
        SelloutReportController.selloutReportStatistics(null);
        Test.stopTest();
    }

}