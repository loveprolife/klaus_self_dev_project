@isTest
public class SetDateHandlerTest {
    static testMethod void testHander(){
        Share_Object__c shareObject = new Share_Object__c(Name = '巡店任务',
                                        Object_API__c = 'Inspection_Shop_Task__c',
                                        Object_Share__c = 'Inspection_Shop_Task__Share'
                                      
        );
        INSERT shareObject;
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Status__c = '未到访';
        // ist.CheckInDevice__c = '1';
        ist.Inspection_Date__c = DATE.today();
        INSERT ist;
        test.startTest();
        Inspection_Shop_Task__c istest = new Inspection_Shop_Task__c();
        istest.Id = ist.Id;
        // istest.CheckInDevice__c = ist.CheckInDevice__c;
        istest.Inspection_Date__c = DATE.today() + 1;
        UPDATE istest;
        DELETE istest;
        Set<String> taskIdSet = new Set<String>();
        taskIdSet.add(ist.Id);
        test.stopTest();
    }
    
    @isTest
    static void testMethod2(){
        String profileName = 'System Admin'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '促销员', email='TestCX@noemail.com',
        emailencodingkey='UTF-8', lastname='TestCX', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testCX@noemail.com');
        INSERT user1; 
                
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
        
        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
       	productTest.Name = 'NTC-77E-TV';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-77E-TV';
        productTest.Series__c = 'hisense tv';
        productTest.Category__c = 'product Category';
        Insert productTest;
        
        Product__c productTest2 = new Product__c();
        productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
       	productTest2.Name = 'NTC-2232E-TV';
       	productTest2.CurrencyIsoCode = 'USD';
       	productTest2.Product_External_Id__c = 'NTC-2323E-TV';
        productTest2.Series__c = 'hisense tv';
        productTest2.Category__c = 'product Category';
        Insert productTest2;
        
        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Shop_Level__c = 'A';
        shop2.Name = '测试店';
        shop2.Shop_Center_Location__Latitude__s = 29.4545;
        shop2.Shop_Center_Location__Longitude__s = 96.509;
        INSERT shop2;
        
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = user1.id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = '2024';
        ispTest.Inspection_Month__c = '8';
        INSERT ispTest;
        
        Date date1 = Date.today();
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop2.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        ist.Inspection_Plan__c = ispTest.id;
        ist.Inspection_Date__c = date1;
        INSERT ist;
        
        Sampling_Mapping__c testSM = new Sampling_Mapping__c();
        testSM.Account__c = acc.id;
        testSM.OwnerId = user1.id;
        testSM.Shop_Level__c = 'A';
        testSM.Level__c = 'A';
        testSM.RecordTypeId = Schema.SObjectType.Sampling_Mapping__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
        Insert testSM;
        
        Sampling_Standard__c testSS = new Sampling_Standard__c();
        testSS.Channel_Name__c = acc.Id;
        testSS.Is_Added__c = '是';
        testSS.Status__c = 'True';
        testSS.Level__c = 'A';
        testSS.Product__c = productTest.id;
        testSS.OwnerId = user1.id;
        testSS.Sampling_Mapping__c = testSM.id;
        Insert testSS;
        
        Sampling_Detail__c testSD = new Sampling_Detail__c();
        testSD.Shop__c = shop2.id;
        testSD.Is_Add__c = '是';
        testSD.Display_Status__c = '展出';
        testSD.Product__c = productTest.id;
        testSD.Sampling_Standard__c = testSS.id;
        Insert testSD;
        
		Sampling_Detail__c testSD2 = [select id from Sampling_Detail__c where Product__c = :productTest.id AND Sampling_Standard__c = :testSS.id Limit 1];
            
        Sampling_Inspection__c testSI1 = new Sampling_Inspection__c();
        testSI1.Inspection_Date__c = System.today();
        testSI1.Placement_Status__c = '展出';
        testSI1.Unplanned_Sample__c = 'No';
        testSI1.Product__c = productTest.id;
        testSI1.Inspection_Shop_Task__c = ist.id;
        testSI1.Shop__c = shop2.id;
        testSI1.Sample_Item__c = testSD2.id;
        testSI1.ReRe__c = '测试rere1';
        //testSI1.ExternalID__c = 
        //Insert testSI1;
        
        Test.startTest();
        ist.Status__c = '未到访';
        update ist;
        Test.stopTest();
        
    }
}