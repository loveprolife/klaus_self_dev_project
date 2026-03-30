@isTest
public class MarketReportControllerTest {
	@isTest
    static void testMethod1(){
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;
        
        Brand__c brand = new Brand__c();
        brand.Name = 'Hisense';
        insert brand;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Shop__c testShop2 = new Shop__c();
        testShop2.name = 'test';
        testShop2.City__c = '重庆';
        testShop2.Account__c = customerTest.id;
        testShop2.Shop_Level__c = 'A';
        Insert testShop2;
        
        String profileName = 'System Admin'; 
        List<profile> listpro = [SELECT Id FROM profile WHERE Name = :profileName];
        Id profileId = listpro[0].Id;
        User user1 = new User(alias = '促销员', email='test1230000000000@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123000000000000000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test123000000@noemail.com');
        INSERT user1;
        
        User user2 = new User(alias = '促销员', email='test12334300@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing14300000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test343000@noemail.com');
        INSERT user2;
        
        //Country__c ='South Africa'

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        testPAR.Name = 'testPAR';
        Insert testPAR;
        
        Responsible_Person__c testResponsiblePerson = new Responsible_Person__c();
        testResponsiblePerson.Shop_Name__c = testShop.id;
        //testResponsiblePerson.Shop_Name__r.Name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testResponsiblePerson.Principal__c = UserInfo.getUserId();
        testResponsiblePerson.RecordType__c = '促销员';
        testResponsiblePerson.Promoter_Attendance_Rule__c = testPAR.Id;
        Insert testResponsiblePerson;

        //Product__c testProduct2 = [Select id,sales_region__c,Name from Product__c where Name = 'RD_27DR'];
                
        Product__c productTest = new Product__c();
       	productTest.Name = 'RC-70WS';
        productTest.sales_region__c = 'Hisense South Africa';
       	Insert productTest;
        
        Market__c testMarket = new Market__c();
        testMarket.Shop__c = testShop.id;
        testMarket.OwnerId = user1.id;
        testMarket.Report_Date__c = System.today();
        testMarket.Status__c = 'New';
        Insert testMarket;
        
        Market__c testMarket2 = new Market__c();
        testMarket2.Shop__c = testShop.id;
        testMarket2.OwnerId = user2.id;
        testMarket2.Report_Date__c = System.today();
        testMarket2.Status__c = 'New';
        Insert testMarket2;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        testReport1.OwnerId = user1.id;
        testReport1.Report_Date__c = System.today();
        testReport1.Status__c = 'New';
        Insert testReport1;

        Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
        testReport2.Customer__c =  customerTest.id;
        testReport2.Shop__c = testShop.id;
        testReport2.OwnerId = user2.id;
        testReport2.Report_Date__c = System.today();
        Insert testReport2;
        
        Promoter_Daily_Report__c testReport3 = New Promoter_Daily_Report__c();
        testReport3.Customer__c =  customerTest.id;
        testReport3.Shop__c = testShop2.id;
        testReport3.OwnerId = user1.id;
        testReport3.Report_Date__c = System.today();
            
        Promoter_Attendance__c testPromoterAttendance = new Promoter_Attendance__c();
        testPromoterAttendance.CheckIn_Date__c = System.today();
        testPromoterAttendance.OwnerId = UserInfo.getUserId();
        testPromoterAttendance.Shop__c = testShop.id;
        testPromoterAttendance.PromoterDailyReport__c = testReport1.id;
        testPromoterAttendance.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
        testPromoterAttendance.SignInTime__c = Time.newInstance(8, 30, 30, 0);
        testPromoterAttendance.SignOutTime__c = Time.newInstance(17, 30, 30, 0);
        Insert testPromoterAttendance;

        Retail_Number__c testRetailNumber = new Retail_Number__c();
        testRetailNumber.Shop__c = testShop.id;
        testRetailNumber.Product__c = productTest.id;
        testRetailNumber.Number__c = 10;
        testRetailNumber.Price__c = 100;
        testRetailNumber.CurrencyIsoCode = 'USD';
        testRetailNumber.Customer__c = customerTest.id;
        testRetailNumber.PromoterDailyReport__c = testReport1.id;
        Insert testRetailNumber;

        GoodsInOut__c testGoodsInOut = new GoodsInOut__c();
        testGoodsInOut.Customer__c = customerTest.id;
        //testGoodsInOut.DailySales__c = testRetailNumber.id;
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        testGoodsInOut.Status__c = 'New';
        Insert testGoodsInOut;

        Shop_Retail_Detail__c testShopRetailDetail = new Shop_Retail_Detail__c();
        testShopRetailDetail.Customer__c = customerTest.id;
        testShopRetailDetail.Product__c = productTest.id;
        testShopRetailDetail.Shop__c = testShop.id;
        testShopRetailDetail.PromoterDailyReport__c = testReport1.id;
        testShopRetailDetail.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
        Insert testShopRetailDetail;

        List<String> retailList = new List<String>();
		retailList.add('test001');
        retailList.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo retailNumberData = new NewPromoterDailyReportActionController.InputDataInfo();
        retailNumberData.dailySaleDataInfo = testRetailNumber;
        retailNumberData.filesInfo = retailList;
        List<NewPromoterDailyReportActionController.InputDataInfo> retailNumberList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        retailNumberList.add(retailNumberData);
        String retailNumberJson = Json.serialize(retailNumberList);

        List<String> goodsReceiveList = new List<String>();
		retailList.add('test001');
        retailList.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo goodsReceivingData = new NewPromoterDailyReportActionController.InputDataInfo();
        goodsReceivingData.goodsReceivingDataInfo = testGoodsInOut;
        goodsReceivingData.filesInfo = goodsReceiveList;
        List<NewPromoterDailyReportActionController.InputDataInfo> goodsReceivingList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        goodsReceivingList.add(goodsReceivingData);
        String goodsReceivingJson = Json.serialize(goodsReceivingList);

        List<String> intelligenceStrList = new List<String>();
		intelligenceStrList.add('test001_hisense_1');
        intelligenceStrList.add('test002_tcl_2');
        NewPromoterDailyReportActionController.InputDataInfo intelligenceData = new NewPromoterDailyReportActionController.InputDataInfo();
        intelligenceData.intelligenceDataInfo = testShopRetailDetail;
        intelligenceData.filesInfo = intelligenceStrList;
        List<NewPromoterDailyReportActionController.InputDataInfo> intelligenceList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        intelligenceList.add(intelligenceData);
        List<List<NewPromoterDailyReportActionController.InputDataInfo>> finalIntelligenceList = new List<List<NewPromoterDailyReportActionController.InputDataInfo>>();
        finalIntelligenceList.add(intelligenceList);
        String intelligenceJson = Json.serialize(finalIntelligenceList);

        Boolean isSubmit = true;

        Map<String,Object> retailNumberFilesMap = new Map<String,Object>();
        retailNumberFilesMap.put('1',testRetailNumber);
        String retailNumberFilesMapJson = Json.serialize(retailNumberFilesMap);

        Map<String,Object> goodsReceivingFilesMap = new Map<String,Object>();
        goodsReceivingFilesMap.put('1',testGoodsInOut);
        String goodsReceivingFilesMapJson = Json.serialize(goodsReceivingFilesMap);

        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('1',testShopRetailDetail);
        String intelligenceFilesMapJson = Json.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        String dateStr = String.valueOf(System.today());
        
        String createDataStr = Json.serialize(testReport3);

		String MarketJson = json.serialize(testMarket2);
        
        Test.startTest();
        system.runAs(user1){
            MarketReportController.getInitData(testMarket.Id);
            MarketReportController.getInitData('');
            MarketReportController.refreshData(dateStr,testShop.id);
            
            MarketReportController.createData(MarketJson);
            MarketReportController.saveData(MarketJson,retailNumberJson,goodsReceivingJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,intelligenceFilesMapJson);

        }
        
        Test.stopTest();
    }
    @isTest
    static void testMethod2(){
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;
        
        Brand__c brand = new Brand__c();
        brand.Name = 'Hisense';
        insert brand;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        
        Shop__c testShop2 = new Shop__c();
        testShop2.name = 'test';
        testShop2.City__c = '重庆';
        testShop2.Account__c = customerTest.id;
        testShop2.Shop_Level__c = 'A';
        Insert testShop2;
        
        String profileName = 'System Admin'; 
        List<profile> listpro = [SELECT Id FROM profile WHERE Name = :profileName];
        Id profileId = listpro[0].Id;
        User user1 = new User(alias = '促销员', email='test1230000000000@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123000000000000000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test123000000@noemail.com');
        INSERT user1;
        
        User user2 = new User(alias = '促销员', email='test12334300@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing14300000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test343000@noemail.com');
        INSERT user2;
        
        //Country__c ='South Africa'

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        testPAR.Name = 'testPAR';
        Insert testPAR;
        
        Responsible_Person__c testResponsiblePerson = new Responsible_Person__c();
        testResponsiblePerson.Shop_Name__c = testShop.id;
        //testResponsiblePerson.Shop_Name__r.Name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testResponsiblePerson.Principal__c = UserInfo.getUserId();
        testResponsiblePerson.RecordType__c = '促销员';
        testResponsiblePerson.Promoter_Attendance_Rule__c = testPAR.Id;
        Insert testResponsiblePerson;

        //Product__c testProduct2 = [Select id,sales_region__c,Name from Product__c where Name = 'RD_27DR'];
                
        Product__c productTest = new Product__c();
       	productTest.Name = 'RC-70WS';
        productTest.sales_region__c = 'Hisense South Africa';
       	Insert productTest;

        ProductSpiv__c ps = new ProductSpiv__c();
        ps.SPIV__c = 3;
        ps.Product__c = productTest.id;
        ps.Sales_Region__c = 'Hisense South Africa';
        ps.IsActive__c = true;
        ps.StartTime__c = Datetime.newInstance(2015,3,1,13,26,0);
        ps.EndTime__c = Datetime.newInstance(2080,3,1,13,26,0);
        insert ps;
        
        Market__c testMarket = new Market__c();
        testMarket.Shop__c = testShop.id;
        testMarket.OwnerId = user1.id;
        testMarket.Report_Date__c = System.today();
        testMarket.Status__c = 'New';
        Insert testMarket;
        
        Market__c testMarket2 = new Market__c();
        testMarket2.Shop__c = testShop.id;
        testMarket2.OwnerId = user2.id;
        testMarket2.Report_Date__c = System.today();
        testMarket2.Status__c = 'New';
        Insert testMarket2;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        testReport1.OwnerId = user1.id;
        testReport1.Report_Date__c = System.today();
        testReport1.Status__c = 'New';
        Insert testReport1;

        Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
        testReport2.Customer__c =  customerTest.id;
        testReport2.Shop__c = testShop.id;
        testReport2.OwnerId = user2.id;
        testReport2.Report_Date__c = System.today();
        Insert testReport2;
        
        Promoter_Daily_Report__c testReport3 = New Promoter_Daily_Report__c();
        testReport3.Customer__c =  customerTest.id;
        testReport3.Shop__c = testShop2.id;
        testReport3.OwnerId = user1.id;
        testReport3.Report_Date__c = System.today();
            
        Promoter_Attendance__c testPromoterAttendance = new Promoter_Attendance__c();
        testPromoterAttendance.CheckIn_Date__c = System.today();
        testPromoterAttendance.OwnerId = UserInfo.getUserId();
        testPromoterAttendance.Shop__c = testShop.id;
        testPromoterAttendance.PromoterDailyReport__c = testReport1.id;
        testPromoterAttendance.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
        testPromoterAttendance.SignInTime__c = Time.newInstance(8, 30, 30, 0);
        testPromoterAttendance.SignOutTime__c = Time.newInstance(17, 30, 30, 0);
        Insert testPromoterAttendance;

        Retail_Number__c testRetailNumber = new Retail_Number__c();
        testRetailNumber.Shop__c = testShop.id;
        testRetailNumber.Product__c = productTest.id;
        testRetailNumber.Number__c = 10;
        testRetailNumber.Price__c = 100;
        testRetailNumber.CurrencyIsoCode = 'USD';
        testRetailNumber.Customer__c = customerTest.id;
        testRetailNumber.PromoterDailyReport__c = testReport1.id;
        Insert testRetailNumber;

        GoodsInOut__c testGoodsInOut = new GoodsInOut__c();
        testGoodsInOut.Customer__c = customerTest.id;
        //testGoodsInOut.DailySales__c = testRetailNumber.id;
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        testGoodsInOut.Status__c = 'New';
        Insert testGoodsInOut;

        Shop_Retail_Detail__c testShopRetailDetail = new Shop_Retail_Detail__c();
        testShopRetailDetail.Customer__c = customerTest.id;
        testShopRetailDetail.Product__c = productTest.id;
        testShopRetailDetail.Shop__c = testShop.id;
        testShopRetailDetail.PromoterDailyReport__c = testReport1.id;
        testShopRetailDetail.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
        Insert testShopRetailDetail;

        List<String> retailList = new List<String>();
		retailList.add('test001');
        retailList.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo retailNumberData = new NewPromoterDailyReportActionController.InputDataInfo();
        retailNumberData.dailySaleDataInfo = testRetailNumber;
        retailNumberData.filesInfo = retailList;
        List<NewPromoterDailyReportActionController.InputDataInfo> retailNumberList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        retailNumberList.add(retailNumberData);
        String retailNumberJson = Json.serialize(retailNumberList);

        List<String> goodsReceiveList = new List<String>();
		retailList.add('test001');
        retailList.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo goodsReceivingData = new NewPromoterDailyReportActionController.InputDataInfo();
        goodsReceivingData.goodsReceivingDataInfo = testGoodsInOut;
        goodsReceivingData.filesInfo = goodsReceiveList;
        List<NewPromoterDailyReportActionController.InputDataInfo> goodsReceivingList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        goodsReceivingList.add(goodsReceivingData);
        String goodsReceivingJson = Json.serialize(goodsReceivingList);

        List<String> intelligenceStrList = new List<String>();
		intelligenceStrList.add('test001_hisense_1');
        intelligenceStrList.add('test002_tcl_2');
        NewPromoterDailyReportActionController.InputDataInfo intelligenceData = new NewPromoterDailyReportActionController.InputDataInfo();
        intelligenceData.intelligenceDataInfo = testShopRetailDetail;
        intelligenceData.filesInfo = intelligenceStrList;
        List<NewPromoterDailyReportActionController.InputDataInfo> intelligenceList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        intelligenceList.add(intelligenceData);
        List<List<NewPromoterDailyReportActionController.InputDataInfo>> finalIntelligenceList = new List<List<NewPromoterDailyReportActionController.InputDataInfo>>();
        finalIntelligenceList.add(intelligenceList);
        String intelligenceJson = Json.serialize(finalIntelligenceList);

        Boolean isSubmit = true;

        Map<String,Object> retailNumberFilesMap = new Map<String,Object>();
        retailNumberFilesMap.put('1',testRetailNumber);
        String retailNumberFilesMapJson = Json.serialize(retailNumberFilesMap);

        Map<String,Object> goodsReceivingFilesMap = new Map<String,Object>();
        goodsReceivingFilesMap.put('1',testGoodsInOut);
        String goodsReceivingFilesMapJson = Json.serialize(goodsReceivingFilesMap);

        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('1',testShopRetailDetail);
        String intelligenceFilesMapJson = Json.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        String dateStr = String.valueOf(System.today());
        
        String createDataStr = Json.serialize(testReport3);

		String MarketJson = json.serialize(testMarket2);
        String parId = 'ParId';
        
        String ExID = '';
        
        Test.startTest();

        MarketReportController.getInitData('');
        MarketReportController.refreshData(dateStr,testShop.id);
        
        MarketReportController.saveData(MarketJson,retailNumberJson,goodsReceivingJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,intelligenceFilesMapJson);
        MarketReportController.saveDailySalesData(MarketJson,retailNumberJson, retailNumberFilesMapJson);
        MarketReportController.saveGoodsReceivingData(MarketJson,goodsReceivingJson,isSubmit, goodsReceivingFilesMapJson);
        MarketReportController.saveIntelligenceData(MarketJson,intelligenceJson,intelligenceFilesMapJson,testReport2.id);
        MarketReportController.autoShowProductDes(productTest.Id);
        MarketReportController.judgeCountry();
        MarketReportController.getProductSpiv(productTest.Id);
        MarketReportController.getResponsiblePersonBaseShop(testShop.id);
        MarketReportController.getExistPromoterDailyReportBasedExternalId(ExID);
        MarketReportController.getExistPromoterDailyReportBasedLikeExternalId(ExID);
        MarketReportController.getExistPromoterDailyReportBasedId(testReport1.id);
        MarketReportController.getExistMarketBasedExternalId(ExID);
        MarketReportController.getExistMarketBasedLikeExternalId(ExID);
        MarketReportController.getExistMarketBasedId(testMarket2.id);
        MarketReportController.getExistRetailNumberBasedPdr(testReport1.id);
        MarketReportController.getExistGoodsReceivingBasedPdr(testReport1.id);
        MarketReportController.getExistGoodsReceivingBasedPdrStatus(testReport1.id,'New');
        MarketReportController.getExistIntelligenceBasedPdr(testMarket2.id);

        Test.stopTest();
    }
    
    @isTest
    Static void testMethod3(){
        String profileName = 'System Admin'; 
        List<profile> listpro = [SELECT Id FROM profile WHERE Name = :profileName];
        Id profileId = listpro[0].Id;
        User user1 = new User(alias = '促销员', email='TestSA100@noemail.com',
        emailencodingkey='UTF-8', lastname='TestSA100', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense South Africa',
        timezonesidkey='America/Los_Angeles', username='TestSA100@noemail.com');
        INSERT user1;
        
        User user2 = new User(alias = '促销员', email='TestHCdssds0@noemail.com',
        emailencodingkey='UTF-8', lastname='TestHCkdckds0', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='TestHC100@noemail.com');
        INSERT user2;
        
        User user3 = new User(alias = '促销员', email='Testsdds00@noemail.com',
        emailencodingkey='UTF-8', lastname='TestID100', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense Indonesia',
        timezonesidkey='America/Los_Angeles', username='Testrte3100@noemail.com');
        INSERT user3;    

		Test.startTest();
        System.runAs(user1){
        	MarketReportController.judgeCountry();
        }
        System.runAs(user2){
        	MarketReportController.judgeCountry();
        }
        System.runAs(user3){
        	MarketReportController.judgeCountry();
        }
        Test.stopTest();
    }
}