@isTest
public with sharing class OandMScriptTest {
    @IsTest
    static void DeleteInspectorDailyReportTest(){
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
        
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;
        
        Id profileId2 = [SELECT Id,Name FROM profile where PermissionsModifyAllData=true AND PermissionsViewAllProfiles=true ].get(0).Id;
        
        User user2 = new User(alias = 'admin', email='TestAdmin@noemail.com',
        emailencodingkey='UTF-8', lastname='TestAdmin', languagelocalekey='en_US',
        Sales_Region__c = 'Hisense South Africa',                    
        localesidkey='en_US',profileid = profileId2, country='South Africa',Country__c = 'South Africa',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='TestAdmin@noemail.com');
        INSERT user2;

        Test.startTest();
        System.runAs(user2){
            Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
            testDIR.Report_Date__c = System.today();
            testDIR.Store__c = shop1.id;
            testDIR.OwnerId = UserInfo.getUserId();
            testDIR.Status__c = 'New';
            Insert testDIR;
            
            Product__c productTest2 = new Product__c();
            //productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('ALL_Product_Japan').getRecordTypeId();
            productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
            //productTest.Product_Line__c = 'TV';
            productTest2.Name = 'NTC-24E-TV';
            productTest2.CurrencyIsoCode = 'USD';
            productTest2.Product_External_Id__c = 'NTC-24E-TV';
            productTest2.Series__c = 'hisense tv';
            productTest2.Category__c = 'Category';
            productTest2.sales_region__c = 'Hisense South Africa';
            Insert productTest2;

            Sampling_Inspection__c newSi = new Sampling_Inspection__c();
            newSi.Placement_Status__c = '未展出';
            newSi.Unplanned_Sample__c = 'No';
            newSi.Product__c = productTest2.id;
            newSi.Inspection_Date__c = System.today();
            newSi.Shop__c = shop1.Id;
            newSi.OwnerId = UserInfo.getUserId();
            newSi.ExternalID__c = String.valueOf(System.today()) + '_' + shop1.Id + '_' + productTest2.id; 
            Insert newSi;

            OandMScript.DeleteInspectorDailyReport(testDIR.Id, false);
            OandMScript.DeleteInspectorDailyReport(testDIR.Id, true);
        }
        Test.stopTest();
    }
}