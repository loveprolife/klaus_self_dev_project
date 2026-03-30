/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 17-08-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
@isTest
public class NewSamplingDetailControllerTest {
    @isTest
    static void testMethod1(){
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '促销员', email='TestCX@noemail.com',
        emailencodingkey='UTF-8', lastname='TestCX', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testCX@noemail.com');
        INSERT user1; 
        
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
        
        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
       	productTest.Name = 'NTC-22E-TV';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        Insert productTest;
        
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = Datetime.now().year() + '';
        ispTest.Inspection_Month__c = Datetime.now().month() + '';
        INSERT ispTest;
        
        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;
        
        Sampling_Mapping__c testSM = new Sampling_Mapping__c();
        testSM.Account__c = acc.id;
        testSM.Shop_Level__c = 'A';
        testSM.Level__c = 'A';
        testSM.OwnerId = user1.id;
        testSM.RecordTypeId = Schema.SObjectType.Sampling_Mapping__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        Insert testSM;
        
        Sampling_Standard__c testSS = new Sampling_Standard__c();
        testSS.Channel_Name__c = acc.Id;
        testSS.Is_Added__c = '是';
        testSS.Status__c = 'True';
        testSS.Level__c = 'A';
        testSS.Product__c = productTest.id;
        testSS.OwnerId = user1.id;
        testSS.Channel_Name__c = acc.id;
        testSS.Is_Add_ByReport__c = true;
        //testSS.Sampling_Mapping__c = testSM.id;
        Insert testSS;
        
        Sampling_Detail__c testSD = new Sampling_Detail__c();
        testSD.Shop__c = shop1.id;
        testSD.Is_Add__c = '是';
        testSD.Display_Status__c = '展出';
        testSD.Product__c = productTest.id;
        testSD.Sampling_Standard__c = testSS.id;
        
        String detailStr = Json.serialize(testSD);
        
        Test.startTest();
        NewSamplingDetailController.getInitData(shop1.id);
        NewSamplingDetailController.saveRecord(shop1.id,detailStr);
        Test.stopTest();
        
    }
    
    @isTest
    static void testMethod2(){
        String profileName = '促销员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '促销员', email='TestCX@noemail.com',
        emailencodingkey='UTF-8', lastname='TestCX', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testCX@noemail.com');
        INSERT user1; 
        
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
        
        Shop__c shop2 = new Shop__c();
        //shop2.Account__c = acc.id;
        shop2.Shop_Level__c = 'A';
        shop2.Name = '可乐店11111';
        shop2.City__c = '北京市';    
        Insert shop2;
        
        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('AC_Product_RecordType').getRecordTypeId();
        // productTest.Product_Line__c = 'TV';
       	productTest.Name = 'NTC-22E-TV';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        Insert productTest;
        
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = Datetime.now().year() + '';
        ispTest.Inspection_Month__c = Datetime.now().month() + '';
        INSERT ispTest;
        
        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;
        
        Sampling_Mapping__c testSM = new Sampling_Mapping__c();
        testSM.Account__c = acc.id;
        testSM.Shop_Level__c = 'A';
        testSM.Level__c = 'A';
        testSM.OwnerId = user1.id;
        testSM.RecordTypeId = Schema.SObjectType.Sampling_Mapping__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        Insert testSM;
        
        Sampling_Standard__c testSS = new Sampling_Standard__c();
        testSS.Channel_Name__c = acc.Id;
        testSS.Is_Added__c = '是';
        testSS.Status__c = 'True';
        testSS.Level__c = 'A';
        testSS.Product__c = productTest.id;
        testSS.OwnerId = user1.id;
        testSS.Channel_Name__c = acc.id;
        testSS.Is_Add_ByReport__c = true;
        //testSS.Sampling_Mapping__c = testSM.id;
        //Insert testSS;
        
        Sampling_Detail__c testSD = new Sampling_Detail__c();
        testSD.Shop__c = shop1.id;
        testSD.Is_Add__c = '是';
        testSD.Display_Status__c = '展出';
        testSD.Product__c = productTest.id;
        //testSD.Sampling_Standard__c = testSS.id;
        
        String detailStr = Json.serialize(testSD);

        Store_Product_Line__c spl = new Store_Product_Line__c();
        spl.Store__c = shop1.Id;
        spl.Product_Line__c = 'TV';
        spl.Display_Type__c = 'In-Line';
        insert spl;
        
        Test.startTest();
        NewSamplingDetailController.getInitData(shop1.Id);
        NewSamplingDetailController.saveRecord(shop1.Id,detailStr);
        NewSamplingDetailController.saveRecord(shop2.Id,detailStr);
        NewSamplingDetailController.saveRecord(null,detailStr);
        NewSamplingDetailController.selectDisplayType(shop1.Id,productTest.id);
        Test.stopTest();
    }
}