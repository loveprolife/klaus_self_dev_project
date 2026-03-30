@isTest
public class CustomLookupProviderTest {
    
    @isTest
    static void Test1() {
        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;
        
        Shop__c testShop = new Shop__c();
        testShop.name = '测试NewPromoterDailyReportActionController门店0629(lookup)';
        testShop.City__c = '重庆';
        testShop.Sales_Region__c = 'Hisense Indonesia';
        testShop.Shop_Level__c = 'A';
        testShop.Grid__c = grid.id;
        testShop.Shop_Code_Text__c = '90999';
        testShop.Shop_Center_Location__Latitude__s = 29.4545;
        testShop.Shop_Center_Location__Longitude__s = 106.509;
        Insert testShop;

        // 创建测试国家州省记录
        Country_State__c countryState = new Country_State__c(
            Name__c = 'Test State',
            Belong_To__c = 'CN'
        );
        Insert countryState;
        
        new CustomLookupProvider.BrandContainsHisense().getData('', 'Account', new Map<String, Object>());
        new CustomLookupProvider.Test().getData('', 'Account', new Map<String, Object>());
        new CustomLookupProvider.OfficeTest().getOfficeData('','', 'Account', new Map<String, Object>());


        new CustomLookupProvider.ProductAllFilter().getData('', 'Product__c', new Map<String, Object>());
        new CustomLookupProvider.ChannelAllFilter().getData('', 'Channel_item__c', new Map<String, Object>());
        
        new CustomLookupProvider.ProductFilter().getData('', 'Product__c', new Map<String, Object>());
        
        new CustomLookupProvider.ProductGift().getData('', 'Product__c', new Map<String, Object>());
        
        new CustomLookupProvider.UserFilter().getData('', 'User', new Map<String, Object>());
        //20250227 TJP 增加展会审批人的下拉筛选
        new CustomLookupProvider.ApprovalFliter().getData('', 'Exhibition_OA_Second_Approver__c', new Map<String, Object>());
        
        new CustomLookupProvider.BrandContainsHisense().getData('', 'Product__c', new Map<String, Object>());
        
        new CustomLookupProvider.BrandDoNotContainsHisense().getData('', 'Product__c', new Map<String, Object>());
        
        new CustomLookupProvider.StoreFilter().getData('', 'Shop__c', new Map<String, Object>());
        
        new CustomLookupProvider.SchedulingPlanStoreFilter().getData('', 'Shop__c', new Map<String, Object>{'Shop__c' => testShop.Id});
        
        new CustomLookupProvider.SchedulingPlanUserFilter().getData('', 'Shop__c', new Map<String, Object>{'Shop__c' => testShop.Id});

        new CustomLookupProvider.ShopFilter().getData('', 'Shop__c', new Map<String, Object>{'Shop__c' => testShop.Id});
        
        new CustomLookupProvider.DepartmentUserFilter().getData('', 'User', new Map<String, Object>{'Shop__c' => testShop.Id});
        // 20241101 TJP 
        new CustomLookupProvider.InternationalProductFilter().getOfficeData('Hisense USA', '', 'Product__c', new Map<String, Object>());
        new CustomLookupProvider.InternationalProductFilter().getOfficeData('Hisense Japan', '', 'Product__c', new Map<String, Object>());
        new CustomLookupProvider.InternationalProductFilter().getOfficeData('Hisense International', '', 'Product__c', new Map<String, Object>());
        new CustomLookupProvider.OtherStoreFilter().getData('', 'Product__c', new Map<String, Object>{'Shop__c' => testShop.Id});

        new CustomLookupProvider.BankFilter().getData('', 'Customer_Banks__c', new Map<String, Object>());
        new CustomLookupProvider.PickListFilter().getData('', 'PickList__c ', new Map<String, Object>{'entity' => '8110'});
        new CustomLookupProvider.PickListFilter().getData('', 'PickList__c ', new Map<String, Object>{'belongToLocation' => '8110'});
        new CustomLookupProvider.PickListFilter().getData('', 'PickList__c ', new Map<String, Object>{'belongToOffice' => '8110'});
        new CustomLookupProvider.CountryStateFilter().getData('', 'Country_State__c ', new Map<String, Object>{'belongTo' => '8110'});
        new CustomLookupProvider.CountryStateFilter().getData('', 'Country_State__c ', new Map<String, Object>{'belongToProvince' => countryState.Id});
        new CustomLookupProvider.CountryStateFilter().getData('', 'Country_State__c ', new Map<String, Object>{'belongToCity' => countryState.Id});
        new CustomLookupProvider.CountryStateFilter().getData('', 'Country_State__c ', new Map<String, Object>{'belongToDistrict' => countryState.Id});
        //tjp 2025-08-05
        // new CustomLookupProvider.productLineTicketFilter().getData('', 'Product__c', new Map<String, Object>{'Product_Lines__c' => 'TV'});
        // new CustomLookupProvider.productLineTicketFilter().getData('', 'Product__c', new Map<String, Object>());
        new CustomLookupProvider.productTicketFilter().getData('', 'Product__c', new Map<String, Object>());

        new CustomLookupProvider.TaxCategoryFilter().getData('', 'Tax_category__c ', new Map<String, Object>{'belongToDistrict' => '8110'});

        new CustomLookupProvider.CustomerChannelFliter().getData('', 'Account ', new Map<String, Object>());
        new CustomLookupProvider.CustomerSapCodeFliter().getData('', 'Account ', new Map<String, Object>());
        new CustomLookupProvider.StoreFilterTicket().getData('', 'Shop__c ', new Map<String, Object>());

        Map<String, Object> m = new Map<String, Object>();
        m.put('argentinaPL', '11');
        m.put('argentinaPS', '11');
        new CustomLookupProvider.ArgentinaProductFilter().getData('', 'Product__c', m);

    }

    @istest
    static void test2() {
        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'testPromoterUser121382';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Argentina%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Argentina';
        insert promoter;

        User manager = new User();
        manager.Username = 'testManagerUser1213823@test004.com';
        manager.lastname = 'testManagerUser121382';
        manager.alias = 'manager';
        manager.email ='manager@test.com';
        manager.emailencodingkey = 'UTF-8';
        manager.languagelocalekey = 'zh_CN';
        manager.LocaleSidKey = 'zh_CN';
        manager.IsActive = true;
        manager.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Argentina store manager%'][0].Id;
        manager.timezonesidkey ='Asia/Shanghai';
        manager.Sales_Region__c = 'Hisense Argentina';
        manager.Department__c = 'Manager';
        insert manager;

        CheckItem__c checkItem = new CheckItem__c();
		checkItem.Description__c = '111111';
		checkItem.Active__c = true;
        insert checkItem;

        CheckItem__c checkItem1 = new CheckItem__c();
		checkItem1.Description__c = '222222';
		checkItem1.Active__c = true;
        insert checkItem1;

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense Argentina';
        Insert acc;

        // Gridding
        Gridding__c gridding = new Gridding__c();
        gridding.Grid_Manager__c = manager.Id;
        Insert gridding;

        Channel_item__c channelItem  = new Channel_item__c();
        channelItem.Channel_Name__c = 'YAMADA';
        insert channelItem;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'shop1';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense Argentina';
        shop1.Grid__c = gridding.Id;
        shop1.Channel_item__c = channelItem.Id;
        Insert shop1;

        Daily_Inspection_Report__c inspectionReport = new Daily_Inspection_Report__c();
        inspectionReport.Report_Date__c = System.today();
        inspectionReport.OwnerId = promoter.Id;
        inspectionReport.Store__c = shop1.Id;
        insert inspectionReport;

        CheckResult__c checkResult = new CheckResult__c();
        checkResult.InspectorDailyReport__c = inspectionReport.Id;
        checkResult.CheckItem__c = checkItem.Id;
        checkResult.Status__c = 'Draft';
        checkResult.Max_Scores__c = 5;
        checkResult.Scores__c = 0;
        insert checkResult;

        CheckResult__c checkResult1 = new CheckResult__c();
        checkResult1.InspectorDailyReport__c = inspectionReport.Id;
        checkResult1.CheckItem__c = checkItem1.Id;
        checkResult1.Status__c = 'Draft';
        checkResult1.Max_Scores__c = 5;
        checkResult1.Scores__c = 0;
        insert checkResult1;

         Product__c productTest2 = new Product__c();
        productTest2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        //productTest.Product_Line__c = 'TV';
        productTest2.Name = 'NTC-24E-TV';
        productTest2.CurrencyIsoCode = 'USD';
        productTest2.Product_External_Id__c = 'NTC-24E-TV';
        productTest2.Series__c = 'hisense tv';
        productTest2.Category__c = 'Category';
        Insert productTest2;

        // Sampling_Detail__c testSD = new Sampling_Detail__c();
        // testSD.Shop__c = shop1.id;
        // testSD.Is_Add__c = '是';
        // testSD.Display_Status__c = '展出';
        // testSD.Product__c = productTest2.id;
        // testSD.Sampling_Standard__c = testSS.id;
        // Insert testSD;
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = manager.Id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = Date.today().year() + '';
        ispTest.Inspection_Month__c = Date.today().month() + '';
        INSERT ispTest;

        Daily_Inspection_Report__c testDIR2 = new Daily_Inspection_Report__c();
        testDIR2.Report_Date__c = System.today();
        testDIR2.Inspection_Shop_Plan__c = ispTest.id;
        testDIR2.Store__c = shop1.id;
        testDIR2.OwnerId = manager.Id;
        testDIR2.Status__c = 'New';
        testDIR2.NeedCheckIn__c = true;
        Insert testDIR2;

        Sampling_Inspection__c testSI1 = new Sampling_Inspection__c();
        testSI1.Inspection_Date__c = System.today();
        testSI1.Placement_Status__c = '展出';
        testSI1.Unplanned_Sample__c = 'No';
        testSI1.Product__c = productTest2.id;
        testSI1.Shop__c = shop1.id;
        // testSI1.Sample_Item__c = testSD.id;
        testSI1.Inspection_Report__c = inspectionReport.id;
        testSI1.ReRe__c = '测试rere1';
        testSI1.ExternalID__c = String.valueOf(testDIR2.Report_Date__c) + '_' + testDIR2.Store__c + '_' + productTest2.Id;
        Insert testSI1;

        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Penguins',
                                        PathOnClient = 'Penguins.txt',
                                        VersionData = Blob.valueOf('Test Content'),
                                        Origin = 'H',
                                        IsMajorVersion = true
        );
        insert contentVersion;  
        ContentDocument testContentDocument  = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
                                                WHERE LatestPublishedVersionId = :contentVersion.Id];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = checkResult.id;
        cdl.ContentDocumentId = testContentDocument .Id;
        cdl.shareType = 'V';
        insert cdl;
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = checkResult1.id;
        cdl2.ContentDocumentId = testContentDocument .Id;
        cdl2.shareType = 'V';
        insert cdl2;
        inspectionReport.Status__c = 'Submitted';
        update inspectionReport;
        //20250530 TJP 增加CheckResult结果图片挂载的所属门店下拉筛选
        Map<String, Object> result = new Map<String, Object>();
        result.put('startDate', String.valueOf(System.today()));
        result.put('endDate', String.valueOf(System.today()));
        result.put('channelId',null);
        result.put('ownerId', null);
        // System.runAs(promoter){
            new CustomLookupProvider.HavePhotoStoreFilter().getData('', '', result);
        // }

    } 
}