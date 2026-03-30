@isTest
public with sharing class NewPromoterDailyReportActionControlTest {
    @isTest
    static void testNewPromoterDailyReportActionController(){
        NewPromoterDailyReportActionController.gabige();
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;

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
        
        String profileName = 'Chile Promoter'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '促销员', email='test1230000000000@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123000000000000000', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test123000000@noemail.com');
        INSERT user1;
        
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


        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        testReport1.OwnerId = user1.id;
        testReport1.Report_Date__c = System.today().addDays(-1);
        testReport1.Status__c = 'Submitted';
        //testReport.Name = '测试PromoterShare用';
        Insert testReport1;
        System.debug('())()()()()()()()()'+ testReport1.id);

        Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
        testReport2.Customer__c =  customerTest.id;
        testReport2.Shop__c = testShop.id;
        testReport2.OwnerId = UserInfo.getUserId();
        testReport2.Report_Date__c = System.today();
        //testReport2.Name = '测试PromoterShare用';
        Insert testReport2;
        
        Promoter_Daily_Report__c testReport3 = New Promoter_Daily_Report__c();
        testReport3.Customer__c =  customerTest.id;
        testReport3.Shop__c = testShop2.id;
        testReport3.OwnerId = UserInfo.getUserId();
        testReport3.Report_Date__c = System.today();
            
        Promoter_Attendance__c testPromoterAttendance = new Promoter_Attendance__c();
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

        Promotional_Stock__c stock1 = new Promotional_Stock__c();
        stock1.Promoter_Daily_Report__c = testReport1.id;
        stock1.Product_Model__c = productTest.Id;
        stock1.Store_Code__c = testShop.Id;
        stock1.Quantities__c = 600;
        // stock1.Report_Date__c = testReport1.Report_Date__c;
        stock1.Status__c = 'Submitted';
        insert stock1;

        GoodsInOut__c testGoodsInOut = new GoodsInOut__c();
        testGoodsInOut.Customer__c = customerTest.id;
        //testGoodsInOut.DailySales__c = testRetailNumber.id;
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        testGoodsInOut.Status__c = 'New';
        //Insert testGoodsInOut;

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

        List<String> stockList = new List<String>();
		retailList.add('test001');
        retailList.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo stockData = new NewPromoterDailyReportActionController.InputDataInfo();
        stockData.stockDataInfo = stock1;
        stockData.filesInfo = stockList;
        List<NewPromoterDailyReportActionController.InputDataInfo> stockLists = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        stockLists.add(stockData);
        String stockJson = Json.serialize(stockLists);

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

        Map<String,Object> stockFilesMap = new Map<String,Object>();
        stockFilesMap.put('1',stock1);
        String stockFilesMapJson = Json.serialize(stockFilesMap);

        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('1',testShopRetailDetail);
        String intelligenceFilesMapJson = Json.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        String dateStr = String.valueOf(System.today());
        
        String createDataStr = Json.serialize(testReport3);

        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion contentVersion1 = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion1; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testRetailNumber.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = testRetailNumber.id;
        cdl1.ContentDocumentId = documents[1].Id;
        cdl1.shareType = 'V';
        insert cdl1;

        Test.startTest();
        System.runAs(user1){
            NewPromoterDailyReportActionController.getInitData(testReport1.id);
        	NewPromoterDailyReportActionController.getInitData('');
        	NewPromoterDailyReportActionController.refreshData(dateStr,testShop.id);
        	NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson); 
        	NewPromoterDailyReportActionController.saveDataThailand(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson); 
        	NewPromoterDailyReportActionController.createData(createDataStr);
        }
        Test.stopTest();

    }
    @isTest
    static void testNewPromoterDailyReportActionController2(){
        Account customerTest = new Account();
        customerTest.Name = '测试NewPromoterDailyReportActionController客户0629';
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(08, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(17, 30, 0, 0);
        Insert testPAR;
        
        Responsible_Person__c testResponsiblePerson = new Responsible_Person__c();
        testResponsiblePerson.Shop_Name__c = testShop.id;
        //testResponsiblePerson.Shop_Name__r.Name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testResponsiblePerson.Principal__c = UserInfo.getUserId();
        testResponsiblePerson.RecordType__c = '促销员';
        testResponsiblePerson.Promoter_Attendance_Rule__c = testPAR.id;
        Insert testResponsiblePerson;

        Product__c productTest = new Product__c();
       	productTest.Name = 'Hisense';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-Returns';
       	Insert productTest;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        testReport1.Status__c = 'New';
        testReport1.Report_Date__c = system.today();
        testReport1.OwnerId = UserInfo.getUserId();
        //testReport.Name = '测试PromoterShare用';
        Insert testReport1;

        //Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
        //testReport2.Customer__c =  customerTest.id;
        //testReport2.Shop__c = testShop.id;
        //testReport.Name = '测试PromoterShare用';
        //Insert testReport2;

        Promoter_Attendance__c testPromoterAttendance = new Promoter_Attendance__c();
        testPromoterAttendance.Shop__c = testShop.id;
        testPromoterAttendance.PromoterDailyReport__c = testReport1.id;
        testPromoterAttendance.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
        //testPromoterAttendance.SignInTime__c = ;
        //testPromoterAttendance.SigOutTime__c = ;
        Insert testPromoterAttendance;

        // Retail_Number__c testRetailNumber = new Retail_Number__c();
        // testRetailNumber.Shop__c = testShop.id;
        // testRetailNumber.Product__c = productTest.id;
        // testRetailNumber.Number__c = 100;
        // testRetailNumber.CurrencyIsoCode = 'USD';
        // testRetailNumber.Customer__c = customerTest.id;
        // testRetailNumber.PromoterDailyReport__c = testReport1.id;
        // testRetailNumber.Status__c = 'New';
        // Insert testRetailNumber;


        GoodsInOut__c testGoodsInOut = new GoodsInOut__c();
        testGoodsInOut.Customer__c = customerTest.id;
        //testGoodsInOut.DailySales__c = testRetailNumber.id;
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.Status__c = 'New';
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        //Insert testGoodsInOut;

        Shop_Retail_Detail__c testShopRetailDetail = new Shop_Retail_Detail__c();
        testShopRetailDetail.Customer__c = customerTest.id;
        testShopRetailDetail.Product__c = productTest.id;
        testShopRetailDetail.Shop__c = testShop.id;
        testShopRetailDetail.PromoterDailyReport__c = testReport1.id;
        testShopRetailDetail.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
        Insert testShopRetailDetail;
        
        ProductSpiv__c ps = new ProductSpiv__c();
        ps.SPIV__c = 3;
        ps.Product__c = productTest.id;
        ps.Sales_Region__c = 'Hisense South Africa';
        ps.IsActive__c = true;
        ps.StartTime__c = Datetime.newInstance(2015,3,1,13,26,0);
        ps.EndTime__c = Datetime.newInstance(2080,3,1,13,26,0);
        insert ps;

        NewPromoterDailyReportActionController.InputDataInfo retailNumberData = new NewPromoterDailyReportActionController.InputDataInfo();
        //retailNumberData.dailySaleDataInfo = testRetailNumber;
        List<NewPromoterDailyReportActionController.InputDataInfo> retailNumberList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        retailNumberList.add(retailNumberData);
        String retailNumberJson = Json.serialize(retailNumberList);
        List<String> filesKeyMap = new List<String>();
        filesKeyMap.add('test001');
        filesKeyMap.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo goodsReceivingData = new NewPromoterDailyReportActionController.InputDataInfo();
        goodsReceivingData.goodsReceivingDataInfo = testGoodsInOut;
        goodsReceivingData.filesInfo = filesKeyMap;
        List<NewPromoterDailyReportActionController.InputDataInfo> goodsReceivingList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        goodsReceivingList.add(goodsReceivingData);
        String goodsReceivingJson = Json.serialize(goodsReceivingList);

        NewPromoterDailyReportActionController.InputDataInfo intelligenceData = new NewPromoterDailyReportActionController.InputDataInfo();
        intelligenceData.intelligenceDataInfo = testShopRetailDetail;
        List<NewPromoterDailyReportActionController.InputDataInfo> intelligenceList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        intelligenceList.add(intelligenceData);
        String intelligenceJson = Json.serialize(intelligenceList);

        Boolean isSubmit = true;
        
        Map<String,Object> retailNumberFilesMap = new Map<String,Object>();
        //retailNumberFilesMap.put('1',testRetailNumber);
        String retailNumberFilesMapJson = Json.serialize(retailNumberFilesMap);


        Map<String,Object> goodsReceivingFilesMap = new Map<String,Object>();
        goodsReceivingFilesMap.put('1',testGoodsInOut);
        String goodsReceivingFilesMapJson = Json.serialize(goodsReceivingFilesMap);

        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('1',testShopRetailDetail);
        String intelligenceFilesMapJson = Json.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        Test.startTest();
        NewPromoterDailyReportActionController.getInitData('');
        
        //NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,intelligenceFilesMapJson);
        NewPromoterDailyReportActionController.autoShowProductDes(productTest.id);
        NewPromoterDailyReportActionController.autoShowProductListPrice(productTest.id);
        NewPromoterDailyReportActionController.getExistGoodsReceivingBasedPdrStatus(testReport1.Id,testGoodsInOut.Status__c);
        NewPromoterDailyReportActionController.getProductSpiv(productTest.Id);
        NewPromoterDailyReportActionController.saveGoodsReceivingData(recordJson,goodsReceivingJson,isSubmit,goodsReceivingFilesMapJson);
        NewPromoterDailyReportActionController.saveIntelligenceData(recordJson,intelligenceJson,intelligenceFilesMapJson);
        NewPromoterDailyReportActionController.refreshData('test001','test001');
        NewPromoterDailyReportActionController.judgeCountry();
        Test.stopTest();

    }
    @isTest
    static void testNewPromoterDailyReportActionController3(){
        String profileName = 'South Africa Promoter'; 
        Id profileId = [SELECT Id FROM profile WHERE Name =: profileName][0].Id;
        User user1 = new User(alias = '促销员', email='test1111111111111@noemail.com',
        emailencodingkey='UTF-8', lastname='T11111111111111', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='t11111111@noemail.com',Country__c = 'South Africa',Sales_Region__c = 'Hisense South Africa');
        INSERT user1;
        Account customerTest = new Account();
        customerTest.Name = '测试NewPromoterDailyReportActionController客户0629';
        Insert customerTest;

        Account brand = new Account();
        brand.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        brand.Name = 'TCL';
        insert brand;
        Account brand1 = new Account();
        brand1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        brand1.Name = 'Hisense';
        insert brand1;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;

        // Responsible_Person__c testResponsiblePerson = new Responsible_Person__c();
        // testResponsiblePerson.Shop_Name__c = testShop.id;
        // //testResponsiblePerson.Shop_Name__r.Name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        // testResponsiblePerson.Principal__c = UserInfo.getUserId();
        // testResponsiblePerson.RecordType__c = '促销员';
        // Insert testResponsiblePerson;

        Product__c productTest = new Product__c();
       	productTest.Name = 'NTC-22E';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-Returns';
       	Insert productTest;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        testReport1.Status__c = 'New';
        testReport1.Report_Date__c = system.today();
        testReport1.OwnerId = UserInfo.getUserId();
        //testReport.Name = '测试PromoterShare用';
        Insert testReport1;

        Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
        testReport2.Customer__c =  customerTest.id;
        testReport2.Shop__c = testShop.id;
        //testReport.Name = '测试PromoterShare用';
        Insert testReport2;


        Promoter_Attendance__c testPromoterAttendance = new Promoter_Attendance__c();
        testPromoterAttendance.Shop__c = testShop.id;
        testPromoterAttendance.PromoterDailyReport__c = testReport1.id;
        testPromoterAttendance.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
        testPromoterAttendance.CheckIn_Date__c = System.today();
        testPromoterAttendance.OwnerId = UserInfo.getUserId();
        Insert testPromoterAttendance;

        // Retail_Number__c testRetailNumber = new Retail_Number__c();
        // testRetailNumber.Shop__c = testShop.id;
        // testRetailNumber.Product__c = productTest.id;
        // testRetailNumber.Number__c = 100;
        // testRetailNumber.CurrencyIsoCode = 'USD';
        // testRetailNumber.Customer__c = customerTest.id;
        // testRetailNumber.PromoterDailyReport__c = testReport1.id;
        // Insert testRetailNumber;

        GoodsInOut__c testGoodsInOut = new GoodsInOut__c();
        testGoodsInOut.Customer__c = customerTest.id;
        //testGoodsInOut.DailySales__c = testRetailNumber.id;
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.Status__c = 'New';
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        Insert testGoodsInOut;
        
        Shop_Retail_Detail__c testShopRetailDetail = new Shop_Retail_Detail__c();
        testShopRetailDetail.Brand__c = brand1.Id;
        testShopRetailDetail.CampaignDescription__c = '00001';
        testShopRetailDetail.CampaignType__c = 'Extender Warranty';
        testShopRetailDetail.Commission__c = 99;
        testShopRetailDetail.Discount__c = 12;
        testShopRetailDetail.DiscountPrice__c = 1.2;
        testShopRetailDetail.ProductInformation__c = '999090';
        testShopRetailDetail.NewProduct__c = 'Yes';
        testShopRetailDetail.Price__c = 12;
        testShopRetailDetail.Customer__c = customerTest.id;
        testShopRetailDetail.Product__c = productTest.id;
        testShopRetailDetail.Shop__c = testShop.id;
        testShopRetailDetail.PromoterDailyReport__c = testReport1.id;
        testShopRetailDetail.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
        Insert testShopRetailDetail;
        Shop_Retail_Detail__c testShopRetailDetail2 = new Shop_Retail_Detail__c();
        testShopRetailDetail2.Brand__c = brand.Id;
        testShopRetailDetail2.CampaignDescription__c = '00002';
        testShopRetailDetail2.CampaignType__c = 'Free installments';
        testShopRetailDetail2.Commission__c = 10;
        testShopRetailDetail2.Discount__c = 1;
        testShopRetailDetail2.DiscountPrice__c = 1;
        testShopRetailDetail2.ProductInformation__c = '99000';
        testShopRetailDetail2.NewProduct__c = 'NO';
        testShopRetailDetail2.Price__c = 122;
        testShopRetailDetail2.Customer__c = customerTest.id;
        testShopRetailDetail2.Product__c = productTest.id;
        testShopRetailDetail2.Shop__c = testShop.id;
        testShopRetailDetail2.PromoterDailyReport__c = testReport1.id;
        testShopRetailDetail2.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
        testShopRetailDetail2.HisenseShopRetailDetail__c = testShopRetailDetail.Id;
        Insert testShopRetailDetail2;

        

        NewPromoterDailyReportActionController.InputDataInfo retailNumberData = new NewPromoterDailyReportActionController.InputDataInfo();
        //retailNumberData.dailySaleDataInfo = testRetailNumber;
        List<NewPromoterDailyReportActionController.InputDataInfo> retailNumberList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        retailNumberList.add(retailNumberData);
        String retailNumberJson = Json.serialize(retailNumberList);

        NewPromoterDailyReportActionController.InputDataInfo goodsReceivingData = new NewPromoterDailyReportActionController.InputDataInfo();
        goodsReceivingData.goodsReceivingDataInfo = testGoodsInOut;
        List<NewPromoterDailyReportActionController.InputDataInfo> goodsReceivingList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        goodsReceivingList.add(goodsReceivingData);
        String goodsReceivingJson = Json.serialize(goodsReceivingList);

        NewPromoterDailyReportActionController.InputDataInfo intelligenceData = new NewPromoterDailyReportActionController.InputDataInfo();
        intelligenceData.intelligenceDataInfo = testShopRetailDetail2;
        List<NewPromoterDailyReportActionController.InputDataInfo> intelligenceList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        intelligenceList.add(intelligenceData);
        List<List<NewPromoterDailyReportActionController.InputDataInfo>> intell = new List<List<NewPromoterDailyReportActionController.InputDataInfo>>();
        intell.add(intelligenceList);
        String intelligenceJson = Json.serialize(intell);

        Boolean isSubmit = true;        
        String goodsReceivingFilesMapJson = JSON.serialize(goodsReceivingList);
       
        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('intelligence_1','test');
        String intelligenceFilesMapJson = JSON.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        Test.startTest();
    
            NewPromoterDailyReportActionController.getInitData('');
            NewPromoterDailyReportActionController.saveGoodsReceivingData(recordJson,goodsReceivingJson,isSubmit,goodsReceivingFilesMapJson);
            NewPromoterDailyReportActionController.saveIntelligenceData(recordJson,intelligenceJson,intelligenceFilesMapJson);
            //NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,intelligenceJson,isSubmit,null,goodsReceivingFilesMapJson,intelligenceFilesMapJson);

        Test.stopTest();

    }
    @isTest
    static void testNewPromoterDailyReportActionController4(){
        String profileName = 'South Africa Promoter'; 
        Id profileId = [SELECT Id FROM profile WHERE Name =: profileName][0].Id;
        User user1 = new User(alias = '促销员', email='test1111111111111@noemail.com',
        emailencodingkey='UTF-8', lastname='T11111111111111', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='t11111111@noemail.com',Country__c = 'South Africa',Sales_Region__c = 'Hisense South Africa');
        INSERT user1;
        Account customerTest = new Account();
        customerTest.Name = '测试NewPromoterDailyReportActionController客户0629';
        Insert customerTest;

        Account brand = new Account();
        brand.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        brand.Name = 'TCL';
        insert brand;
        Account brand1 = new Account();
        brand1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        brand1.Name = 'Hisense';
        insert brand1;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(08, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(17, 30, 0, 0);
        Insert testPAR;
        
        Responsible_Person__c testResponsiblePerson = new Responsible_Person__c();
        testResponsiblePerson.Shop_Name__c = testShop.id;
        //testResponsiblePerson.Shop_Name__r.Name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testResponsiblePerson.Principal__c = UserInfo.getUserId();
        testResponsiblePerson.RecordType__c = '促销员';
        testResponsiblePerson.Promoter_Attendance_Rule__c = testPAR.id;
        Insert testResponsiblePerson;

        Product__c productTest = new Product__c();
       	productTest.Name = 'NTC-22E';
       	productTest.CurrencyIsoCode = 'USD';
       	productTest.Product_External_Id__c = 'NTC-22E-Returns';
       	Insert productTest;
        
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        testReport1.Status__c = 'New';
        testReport1.Report_Date__c = system.today();
        testReport1.OwnerId = UserInfo.getUserId();
        //testReport.Name = '测试PromoterShare用';
        Insert testReport1;

        Promoter_Daily_Report__c testReport2 = New Promoter_Daily_Report__c();
        testReport2.Customer__c =  customerTest.id;
        testReport2.Shop__c = testShop.id;
        //testReport.Name = '测试PromoterShare用';
        Insert testReport2;


        // Promoter_Attendance__c testPromoterAttendance = new Promoter_Attendance__c();
        // testPromoterAttendance.Shop__c = testShop.id;
        // testPromoterAttendance.PromoterDailyReport__c = testReport1.id;
        // testPromoterAttendance.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
        // testPromoterAttendance.CheckIn_Date__c = System.today();
        // testPromoterAttendance.OwnerId = UserInfo.getUserId();
        // Insert testPromoterAttendance;

        // Retail_Number__c testRetailNumber = new Retail_Number__c();
        // testRetailNumber.Shop__c = testShop.id;
        // testRetailNumber.Product__c = productTest.id;
        // testRetailNumber.Number__c = 100;
        // testRetailNumber.CurrencyIsoCode = 'USD';
        // testRetailNumber.Customer__c = customerTest.id;
        // testRetailNumber.PromoterDailyReport__c = testReport1.id;
        // Insert testRetailNumber;

        GoodsInOut__c testGoodsInOut = new GoodsInOut__c();
        testGoodsInOut.Customer__c = customerTest.id;
        //testGoodsInOut.DailySales__c = testRetailNumber.id;
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.Status__c = 'New';
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        Insert testGoodsInOut;
        
        Shop_Retail_Detail__c testShopRetailDetail = new Shop_Retail_Detail__c();
        testShopRetailDetail.Brand__c = brand1.Id;
        testShopRetailDetail.CampaignDescription__c = '00001';
        testShopRetailDetail.CampaignType__c = 'Extender Warranty';
        testShopRetailDetail.Commission__c = 99;
        testShopRetailDetail.Discount__c = 12;
        testShopRetailDetail.DiscountPrice__c = 1.2;
        testShopRetailDetail.ProductInformation__c = '999090';
        testShopRetailDetail.NewProduct__c = 'Yes';
        testShopRetailDetail.Price__c = 12;
        testShopRetailDetail.Customer__c = customerTest.id;
        testShopRetailDetail.Product__c = productTest.id;
        testShopRetailDetail.Shop__c = testShop.id;
        testShopRetailDetail.PromoterDailyReport__c = testReport1.id;
        testShopRetailDetail.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
        Insert testShopRetailDetail;
        Shop_Retail_Detail__c testShopRetailDetail2 = new Shop_Retail_Detail__c();
        testShopRetailDetail2.Brand__c = brand.Id;
        testShopRetailDetail2.CampaignDescription__c = '00002';
        testShopRetailDetail2.CampaignType__c = 'Free installments';
        testShopRetailDetail2.Commission__c = 10;
        testShopRetailDetail2.Discount__c = 1;
        testShopRetailDetail2.DiscountPrice__c = 1;
        testShopRetailDetail2.ProductInformation__c = '99000';
        testShopRetailDetail2.NewProduct__c = 'NO';
        testShopRetailDetail2.Price__c = 122;
        testShopRetailDetail2.Customer__c = customerTest.id;
        testShopRetailDetail2.Product__c = productTest.id;
        testShopRetailDetail2.Shop__c = testShop.id;
        testShopRetailDetail2.PromoterDailyReport__c = testReport1.id;
        testShopRetailDetail2.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
        testShopRetailDetail2.HisenseShopRetailDetail__c = testShopRetailDetail.Id;
        Insert testShopRetailDetail2;

        

        NewPromoterDailyReportActionController.InputDataInfo retailNumberData = new NewPromoterDailyReportActionController.InputDataInfo();
        //retailNumberData.dailySaleDataInfo = testRetailNumber;
        List<NewPromoterDailyReportActionController.InputDataInfo> retailNumberList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        retailNumberList.add(retailNumberData);
        String retailNumberJson = Json.serialize(retailNumberList);

        NewPromoterDailyReportActionController.InputDataInfo goodsReceivingData = new NewPromoterDailyReportActionController.InputDataInfo();
        goodsReceivingData.goodsReceivingDataInfo = testGoodsInOut;
        List<NewPromoterDailyReportActionController.InputDataInfo> goodsReceivingList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        goodsReceivingList.add(goodsReceivingData);
        String goodsReceivingJson = Json.serialize(goodsReceivingList);

        NewPromoterDailyReportActionController.InputDataInfo intelligenceData = new NewPromoterDailyReportActionController.InputDataInfo();
        intelligenceData.intelligenceDataInfo = testShopRetailDetail2;
        List<NewPromoterDailyReportActionController.InputDataInfo> intelligenceList = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        intelligenceList.add(intelligenceData);
        List<List<NewPromoterDailyReportActionController.InputDataInfo>> intell = new List<List<NewPromoterDailyReportActionController.InputDataInfo>>();
        intell.add(intelligenceList);
        String intelligenceJson = Json.serialize(intell);

        Boolean isSubmit = true;        
        String goodsReceivingFilesMapJson = JSON.serialize(goodsReceivingList);
       
        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('intelligence_1','test');
        String intelligenceFilesMapJson = JSON.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        Test.startTest();
    
            NewPromoterDailyReportActionController.getInitData('');
            NewPromoterDailyReportActionController.saveGoodsReceivingData(recordJson,goodsReceivingJson,isSubmit,goodsReceivingFilesMapJson);
            NewPromoterDailyReportActionController.saveIntelligenceData(recordJson,intelligenceJson,intelligenceFilesMapJson);
            //NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,intelligenceJson,isSubmit,null,goodsReceivingFilesMapJson,intelligenceFilesMapJson);

        Test.stopTest();

    }
    
    @isTest
    static void testNewPromoterDailyReportActionController5(){    
        //Account customerTest = new Account();
        //customerTest.Name = '测试NewPromoterDailyReportActionController客户0629';
        //Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = '0010o00002OBEDhAAP';
        testShop.Shop_Level__c = 'A';
        //Insert testShop;
        String testProductId = 'a0z9D000002Lbz0QAC';
                
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  '0010o00002OBEDhAAP';
        testReport1.Shop__c = testShop.id;
        //testReport1.OwnerId = user1.id;
        testReport1.Report_Date__c = System.today().addDays(-1);
        testReport1.Status__c = 'New';
        //Insert testReport1;

        Retail_Number__c testRetailNumber = new Retail_Number__c();
        testRetailNumber.Shop__c = testShop.id;
        testRetailNumber.Product__c = testProductId;
        testRetailNumber.Number__c = 10;
        testRetailNumber.Price__c = 100;
        testRetailNumber.CurrencyIsoCode = 'USD';
        testRetailNumber.Customer__c = '0010o00002OBEDhAAP';
        testRetailNumber.PromoterDailyReport__c = testReport1.id;
        //Insert testRetailNumber;

        GoodsInOut__c testGoodsInOut = new GoodsInOut__c();
        testGoodsInOut.Customer__c = '0010o00002OBEDhAAP';
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        testGoodsInOut.Status__c = 'New';

        Promotional_Stock__c stock1 = new Promotional_Stock__c();
        stock1.Promoter_Daily_Report__c = testReport1.id;
        stock1.Product_Model__c = testProductId;
        stock1.Store_Code__c = testShop.Id;
        stock1.Quantities__c = 600;
        // stock1.Report_Date__c = testReport1.Report_Date__c;
        stock1.Status__c = 'New';

        Shop_Retail_Detail__c testShopRetailDetail = new Shop_Retail_Detail__c();
        testShopRetailDetail.Customer__c = '0010o00002OBEDhAAP';
        testShopRetailDetail.Product__c = testProductId;
        testShopRetailDetail.Shop__c = testShop.id;
        testShopRetailDetail.PromoterDailyReport__c = testReport1.id;
        testShopRetailDetail.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
        //Insert testShopRetailDetail;

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

        List<String> stockList = new List<String>();
		retailList.add('test001');
        retailList.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo stockData = new NewPromoterDailyReportActionController.InputDataInfo();
        stockData.stockDataInfo = stock1;
        stockData.filesInfo = stockList;
        List<NewPromoterDailyReportActionController.InputDataInfo> stockLists = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        stockLists.add(stockData);
        String stockJson = Json.serialize(stockLists);

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

        Map<String,Object> stockFilesMap = new Map<String,Object>();
        stockFilesMap.put('1',stock1);
        String stockFilesMapJson = Json.serialize(stockFilesMap);

        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('1',testShopRetailDetail);
        String intelligenceFilesMapJson = Json.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        String dateStr = String.valueOf(System.today());
        
        List<UserRole> roleId = [SELECT id from UserRole where name='SouthAfrica Regional Manager GP1']; 
        Id roId = roleId[0].Id;
        String profileName = 'South Africa Promoter'; 
        Id profileIdSA = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = '促销员', email='test12343y493@noemail.com',Country__c = 'South Africa',
        emailencodingkey='UTF-8', lastname='Testing12334873', languagelocalekey='en_US',UserRoleId = roId,
        localesidkey='en_US', profileid = profileIdSA, country='United States',IsActive =true,Sales_Region__c = 'Hisense South Africa',
        timezonesidkey='America/Los_Angeles', username='test123034343@noemail.com');
        INSERT user1;

        List<UserRole> roleId1 = [SELECT id from UserRole where name='SouthAfrica Ops Regional Manager For GP/NW/LP&MP'];
        Id roid1 = roleId1[0].Id;
        String profileName1 = 'Chile Promoter'; 
        Id profileIdCL = [SELECT Id FROM profile WHERE Name = :profileName1][0].Id;
		User user2 = new User(alias = '促dsaf22', email='test1dcxv93@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing12dsf873', languagelocalekey='en_US',UserRoleId = roid1,
        localesidkey='en_US', profileid = profileIdCL, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='test12cxd3@noemail.com');
        INSERT user2; 
        
        List<UserRole> roleId2 = [SELECT id from UserRole where name='Chile KAM'];
        Id roid2 = roleId2[0].Id;
        String profileName2 = 'Indonesia Promoter'; 
        Id profileIdID = [SELECT Id FROM profile WHERE Name = :profileName2][0].Id;
        User user3 = new User(alias = '促dsaf33', email='testclclclv93@noemail.com',Country__c = 'Chile',
        emailencodingkey='UTF-8', lastname='Testclclccldsf873', languagelocalekey='en_US',UserRoleId = roid2,
        localesidkey='en_US', profileid = profileIdID, country='United States',IsActive =true,Sales_Region__c = 'Hisense Indonesia',
        timezonesidkey='America/Los_Angeles', username='testclclcsd34@noemail.com');
        INSERT user3; 
        
        List<UserRole> roleId3 = [SELECT id from UserRole where name='Indonesia Training Manager'];
        Id roid3 = roleId3[0].Id;
        String profileName3 = 'Chile Promoter'; 
        Id profileIdCL2 = [SELECT Id FROM profile WHERE Name = :profileName3][0].Id;
        User user4 = new User(alias = '促dsaf', email='testididid93@noemail.com',Country__c = 'Indonesia',
        emailencodingkey='UTF-8', lastname='Testidididdsf873', languagelocalekey='en_US',UserRoleId = roid3,
        localesidkey='en_US', profileid = profileIdCL2, country='United States',IsActive =true,Sales_Region__c = 'Hisense Chile',
        timezonesidkey='America/Los_Angeles', username='testidididid34@noemail.com');
        INSERT user4; 
        
        Test.startTest();
        System.runAs(user1){
        	NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson); 
            NewPromoterDailyReportActionController.saveDataThailand(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson); 
        }
        System.runAs(user3){
        	NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson); 
            NewPromoterDailyReportActionController.saveDataThailand(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson); 
        }
        System.runAs(user4){
        	NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson); 
            NewPromoterDailyReportActionController.saveDataThailand(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson); 
        }
        Test.stopTest();

    }
    @isTest
    static void testNewPromoterDailyReportActionController6(){ 
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;
        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Grid__c = grid.id;
        testShop.Account__c = customerTest.id;
        testShop.Shop_Level__c = 'A';
        testShop.Shop_Code_Text__c = '90986';
        testShop.Shop_Center_Location__Latitude__s = 29.4545;
        testShop.Shop_Center_Location__Longitude__s = 106.509;
        Insert testShop;
        Product__c productTest = new Product__c();
       	productTest.Name = 'RC-70WS';
        productTest.sales_region__c = 'Hisense South Africa';
       	Insert productTest;
                
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        //testReport1.OwnerId = user1.id;
        testReport1.Report_Date__c = System.today();
        testReport1.Status__c = 'New';
        Insert testReport1;

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
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        testGoodsInOut.Status__c = 'New';

        Promotional_Stock__c stock1 = new Promotional_Stock__c();
        stock1.Promoter_Daily_Report__c = testReport1.id;
        stock1.Product_Model__c = productTest.Id;
        stock1.Store_Code__c = testShop.Id;
        stock1.Quantities__c = 600;
        // stock1.Report_Date__c = testReport1.Report_Date__c;
        stock1.Status__c = 'New';

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
        List<String> stockList = new List<String>();
		retailList.add('test001');
        retailList.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo stockData = new NewPromoterDailyReportActionController.InputDataInfo();
        stockData.stockDataInfo = stock1;
        stockData.filesInfo = stockList;
        List<NewPromoterDailyReportActionController.InputDataInfo> stockLists = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        stockLists.add(stockData);
        String stockJson = Json.serialize(stockLists);
        Boolean isSubmit = false;
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


        Map<String,Object> retailNumberFilesMap = new Map<String,Object>();
        retailNumberFilesMap.put('1',testRetailNumber);
        String retailNumberFilesMapJson = Json.serialize(retailNumberFilesMap);

        Map<String,Object> goodsReceivingFilesMap = new Map<String,Object>();
        goodsReceivingFilesMap.put('1',testGoodsInOut);
        String goodsReceivingFilesMapJson = Json.serialize(goodsReceivingFilesMap);

        Map<String,Object> stockFilesMap = new Map<String,Object>();
        stockFilesMap.put('1',stock1);
        String stockFilesMapJson = Json.serialize(stockFilesMap);

        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('1',testShopRetailDetail);
        String intelligenceFilesMapJson = Json.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        String dateStr = String.valueOf(System.today());
        
        Test.startTest();
        NewPromoterDailyReportActionController.getInitData('test001');
        NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson);
        NewPromoterDailyReportActionController.saveDataThailand(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson);
        Test.stopTest();
    }
    @isTest
    static void testNewPromoterDailyReportActionController7(){ 
        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        // Shop__c shop1 = new Shop__c();
        // shop1.Account__c = acc.id;
        // shop1.Shop_Level__c = 'A';
        // shop1.Name = '可乐店';
        // shop1.City__c = '北京市';
        // shop1.Shop_Code_Text__c = '90986';
        // shop1.Grid__c = grid.id;
        // shop1.Shop_Center_Location__Latitude__s = 29.4545;
        // shop1.Shop_Center_Location__Longitude__s = 106.509;
        // Insert shop1;
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.id;
        testShop.Grid__c = grid.id;
        testShop.Shop_Level__c = 'A';
        testShop.Shop_Code_Text__c = '90986';
        testShop.Shop_Center_Location__Latitude__s = 29.4545;
        testShop.Shop_Center_Location__Longitude__s = 106.509;
        Insert testShop;
        Product__c productTest = new Product__c();
       	productTest.Name = 'RC-70WS';
        productTest.sales_region__c = 'Hisense South Africa';
       	Insert productTest;
                
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.id;
        testReport1.Shop__c = testShop.id;
        //testReport1.OwnerId = user1.id;
        testReport1.Report_Date__c = System.today();
        testReport1.Status__c = 'Submitted';
        Insert testReport1;

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
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        testGoodsInOut.Status__c = 'New';

        Promotional_Stock__c stock1 = new Promotional_Stock__c();
        stock1.Promoter_Daily_Report__c = testReport1.id;
        stock1.Product_Model__c = productTest.Id;
        stock1.Store_Code__c = testShop.Id;
        stock1.Quantities__c = 600;
        // stock1.Report_Date__c = testReport1.Report_Date__c;
        stock1.Status__c = 'New';


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
        List<String> stockList = new List<String>();
		retailList.add('test001');
        retailList.add('test002');
        NewPromoterDailyReportActionController.InputDataInfo stockData = new NewPromoterDailyReportActionController.InputDataInfo();
        stockData.stockDataInfo = stock1;
        stockData.filesInfo = stockList;
        List<NewPromoterDailyReportActionController.InputDataInfo> stockLists = new List<NewPromoterDailyReportActionController.InputDataInfo>();
        stockLists.add(stockData);
        String stockJson = Json.serialize(stockLists);
        Boolean isSubmit = true;
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


        Map<String,Object> retailNumberFilesMap = new Map<String,Object>();
        retailNumberFilesMap.put('1',testRetailNumber);
        String retailNumberFilesMapJson = Json.serialize(retailNumberFilesMap);

        Map<String,Object> goodsReceivingFilesMap = new Map<String,Object>();
        goodsReceivingFilesMap.put('1',testGoodsInOut);
        String goodsReceivingFilesMapJson = Json.serialize(goodsReceivingFilesMap);

        Map<String,Object> stockFilesMap = new Map<String,Object>();
        stockFilesMap.put('1',stock1);
        String stockFilesMapJson = Json.serialize(stockFilesMap);

        Map<String,Object> intelligenceFilesMap = new Map<String,Object>();
        intelligenceFilesMap.put('1',testShopRetailDetail);
        String intelligenceFilesMapJson = Json.serialize(intelligenceFilesMap);

        String recordJson = Json.serialize(testReport1);
        String dateStr = String.valueOf(System.today());
        
        Test.startTest();
        NewPromoterDailyReportActionController.getInitData('test001');
        NewPromoterDailyReportActionController.saveData(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson);
        NewPromoterDailyReportActionController.saveDataThailand(recordJson,retailNumberJson,goodsReceivingJson,stockJson,intelligenceJson,isSubmit,retailNumberFilesMapJson,goodsReceivingFilesMapJson,stockFilesMapJson,intelligenceFilesMapJson);
        Test.stopTest();
    }

    @isTest
    static void testNewPromoterDailyReportActionController8(){ 
        Account customerTest = new Account();
        customerTest.Name = 'Hisense';
        customerTest.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brand').getRecordTypeId();
        Insert customerTest;

        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Account__c = customerTest.Id;
        testShop.Shop_Level__c = 'A';
        Insert testShop;
        Product__c productTest = new Product__c();
       	productTest.Name = 'RC-70WS';
        productTest.sales_region__c = 'Hisense South Africa';
       	Insert productTest;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        testPAR.Name = 'testPAR';
        Insert testPAR;
        
        Responsible_Person__c testResponsiblePerson = new Responsible_Person__c();
        testResponsiblePerson.Shop_Name__c = testShop.id;
        testResponsiblePerson.Principal__c = UserInfo.getUserId();
        testResponsiblePerson.RecordType__c = '促销员';
        testResponsiblePerson.Promoter_Attendance_Rule__c = testPAR.Id;
        Insert testResponsiblePerson;
                
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c =  customerTest.Id;
        testReport1.Shop__c = testShop.id;
        //testReport1.OwnerId = user1.id;
        testReport1.Report_Date__c = System.today();
        testReport1.Status__c = 'Submitted';
        testReport1.ExternalId__c = testShop.id + '_' + UserInfo.getUserId() + '_' + String.valueOf(System.today()) + ' 00:00:00';
        Insert testReport1;

        Retail_Number__c testRetailNumber = new Retail_Number__c();
        testRetailNumber.Shop__c = testShop.id;
        testRetailNumber.Product__c = productTest.id;
        testRetailNumber.Number__c = 10;
        testRetailNumber.Price__c = 100;
        testRetailNumber.CurrencyIsoCode = 'USD';
        testRetailNumber.Customer__c = customerTest.Id;
        testRetailNumber.PromoterDailyReport__c = testReport1.id;
        Insert testRetailNumber;

        GoodsInOut__c testGoodsInOut = new GoodsInOut__c();
        testGoodsInOut.Customer__c = customerTest.Id;
        testGoodsInOut.PromoterDailyReport__c = testReport1.id;
        testGoodsInOut.StroeCode__c = testShop.id;
        testGoodsInOut.Quantities__c = 50;
        testGoodsInOut.RecordTypeId = Schema.SObjectType.GoodsInOut__c.getRecordTypeInfosByDeveloperName().get('In').getRecordTypeId();
        testGoodsInOut.Status__c = 'New';

        Shop_Retail_Detail__c testShopRetailDetail = new Shop_Retail_Detail__c();
        testShopRetailDetail.Customer__c = customerTest.Id;
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
        Boolean isSubmit = true;
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

        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion contentVersion1 = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion1; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testRetailNumber.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = testRetailNumber.id;
        cdl1.ContentDocumentId = documents[1].Id;
        cdl1.shareType = 'V';
        insert cdl1;
        
        Test.startTest();
        NewPromoterDailyReportActionController.getInitData('');
        Test.stopTest();
    }
}