/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public without sharing class InspectorDailyReportControllerTest {
    private static Date dateSelect;
    private static Account acc;
    private static Shop__c shop;
    private static Account acc2;
    private static Shop__c shop2;
    static testMethod void testInspectorDailyReportController(){
        String profileName = 'System Admin'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;

        User userManager = new User(alias = 'Admn44', email='test1234123123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test12341231312@noemail.com');
        INSERT userManager;

        User user1 = new User(alias = 'Admin34', email='test123423@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing122323', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123432@noemail.com', ManagerId = userManager.Id);
        INSERT user1;
        acc = new Account(
                            Name = 'testname');
        insert acc;   
        shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Sales_Region__c = 'Hisense Japan';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;

        acc2 = new Account(
                            Name = 'testname2',
                            External_Key__c = '999999');
        insert acc2; 
        shop2 = new Shop__c();
        shop2.Account__c = acc2.Id;
        INSERT shop2;
        system.runAs(user1){
        dateSelect = system.today();
        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Detail__c = 'test';
        dir.Report_Date__c = dateSelect - 1;
        dir.OwnerId = user1.Id;
        INSERT dir;

           
        Credit_Limit_Application__c newCredit = new Credit_Limit_Application__c(
                                                Payment_Method__c = '1',
                                                Buyer_English_Address__c = 'testtheaddress',
                                                //Enterprise_internal_code__c = 'testcode',
                                                Credit_Guarantee_Issuing_Bank_SWIFT__c='A0000111',
                                                Customer__c = acc.Id);
        insert newCredit;
        
        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Penguins',
                                        PathOnClient = 'Penguins.jpg',
                                        VersionData = Blob.valueOf('Test Content'),
                                        IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = newCredit.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        InspectorDailyReportController.getNewCreateData(dateSelect);

        Id recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'InspectorAttendace'][0].Id;
        Id recordId2 = [SELECT Id FROM RecordType WHERE DeveloperName = 'CheckInSupplementary'][0].Id;
        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.ApprovalStatus__c ='未创建';
        pa.AddCheckInReason__c = 'test AddCheckInReason';
        pa.Shop__c = shop.Id;
        pa.Add_Check_Shop__c = shop.Id;
        pa.CheckInStatus__c = '已签退';
        pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = dateSelect;
        pa.ExternalId__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
        pa.OwnerId = user1.Id;
        pa.RecordTypeId = recordId;
        pa.Daily_Inspection_Report__c = dir.Id;
        pa.AddCheckSignInTime__c = null;
        pa.SignInTime__c = Time.newInstance(18, 30, 00, 00);        
        INSERT pa;



        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.ExternalId__c = pa.ExternalId__c;
        ist.OwnerId = user1.Id;
        ist.Status__c = '计划外到访';
        ist.Inspection_Date__c = dateSelect;
        ist.Daily_Inspection_Report__c = dir.Id;
        ist.Is_Create_Report__c = true;
        INSERT ist;

        Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
        ist2.Shop__c = shop.Id;
        ist2.ExternalId__c = pa.ExternalId__c;
        ist2.OwnerId = user1.Id;
        ist2.Status__c = '未到访';
        ist2.Inspection_Date__c = dateSelect + 1;
        ist2.Daily_Inspection_Report__c = dir.Id;
        ist2.Is_Create_Report__c = true;
        INSERT ist2;

        Supplementary_Information__c supp = new Supplementary_Information__c();
        supp.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        supp.Shop__c = shop.Id;
        supp.Status__c='已提交补签申请';
        supp.Attendance__c = pa.Id;
        supp.RecordTypeId = recordId2;
        supp.Reson__c = 'test';
        INSERT supp;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop2.Id;
        INSERT rp; 

        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Level__c = 'A';
        sm.Shop_Level__c = 'A';
        INSERT sm;
		Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        ss.Is_Added__c = '是';
        ss.Level__c = 'A';
        INSERT ss; 

        Id recordId3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ALL_Product_Japan'][0].Id;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.OwnerId = user1.Id;
        pro.RecordTypeId = recordId3;
        INSERT pro;

        Sampling_Inspection__c si2 = new Sampling_Inspection__c();
        // si.IsNew__c = true;
        si2.ExternalID__c =  user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
        si2.Inspection_Shop_Task__c = ist.Id;
        si2.Shop__c = shop.Id;
        si2.Product__c = pro.Id;
        si2.Placement_Status__c = '展出';
        INSERT si2;

        Sample_Images__c sample = new Sample_Images__c();
        sample.Sampling_Inspection__c = si2.Id;
        sample.ReRe__c = 'test';
        INSERT sample;

        InspectorDailyReportController.SampleImagesData  sampleImagesData = new InspectorDailyReportController.SampleImagesData();
        sampleImagesData.sampleImages = sample;
        sampleImagesData.index = '1';

        List<InspectorDailyReportController.SampleImagesData> sampleImageList = new List<InspectorDailyReportController.SampleImagesData>();
        sampleImageList.add(sampleImagesData);

        InspectorDailyReportController.SamplingInspectionData si = new InspectorDailyReportController.SamplingInspectionData();
        si.key = '1';
        si.index = '1';
        si.showDelete = true;
        si.samplingInspection = si2;
        si.sampleImageList = sampleImageList;


        List<InspectorDailyReportController.SamplingInspectionData> samplingInspectionDataList = new List<InspectorDailyReportController.SamplingInspectionData>();
        samplingInspectionDataList.add(si);

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        sd.Shop__c = shop.Id;
        sd.Is_Add__c = '是';
        sd.ExternalID__c = si2.Shop__c+'-'+si2.Product__c;
        INSERT sd;

        Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
        isp.Inspection_Year__c = String.valueOf(system.today().year());
        isp.Inspection_Month__c =  String.valueOf(system.today().month());
        isp.OwnerId__c = user1.Id;
        INSERT isp;

        InspectorDailyReportController.Store store = new InspectorDailyReportController.Store();
        store.taskStatus = true;
        store.samplingInspectionDataList = samplingInspectionDataList;
        store.isCanChangeStatus = true;
        store.shop = shop.Id;
        List<InspectorDailyReportController.Store> stores = new List<InspectorDailyReportController.Store>();
        stores.add(store);
        store.taskStatus = false;

        InspectorDailyReportController.OutPut outPut = new InspectorDailyReportController.OutPut();
        Mileage__c mileage = new Mileage__c();
        mileage.Start__c = 1;
        mileage.End__c = 222;
        mileage.Amount_To__c = 50;
        mileage.Report__c = dir.Id;
        mileage.Gas_Mileage__c = 888;
        INSERT mileage;
        mileage.Id = null;
        //UPDATE mileage;
        system.debug(mileage);

        Mileage__c mileage2 = new Mileage__c();
        mileage2.Start__c = 10;
        mileage2.End__c = 22;
        mileage2.Amount_To__c = 500;
        mileage2.Report__c = dir.Id;
        INSERT mileage2;
        mileage2.Amount_To__c = 100;

        outPut.mileage = mileage;
        outPut.mileageFirst = true;
        outPut.lastMileageId = mileage2.id;
        InspectorDailyReportController.ShopSelect shopSelect = new InspectorDailyReportController.ShopSelect();
        shopSelect.label = shop.Name;
        shopSelect.value = 'testvalue';


        List<InspectorDailyReportController.ShopSelect> shopSelectList = new List<InspectorDailyReportController.ShopSelect>();
        shopSelectList.add(shopSelect);

        Map<String,List<InspectorDailyReportController.ShopSelect>> shopMap = new Map<String,List<InspectorDailyReportController.ShopSelect>>();
        shopMap.put(acc.Name,shopSelectList);

        List<String> deleteTaskId = new List<String>();
        deleteTaskId.add(ist.Id);
        deleteTaskId.add(ist2.Id);
        List<String> deletePhoto = new List<String>();
        
        // InspectorDailyReportController.CompetitiveProducts   cProduct = new InspectorDailyReportController.CompetitiveProducts();

        // Competitive_products__c cp = new Competitive_products__c();
        // cp.Name = 'test';
        // cp.Is_Active__c = True;
        // cp.ExternalId__c = cProduct.productsName+'_'+cProduct.brand+'_'+cProduct.size+'_'+cProduct.posttype;
        // INSERT cp;

        Shop_Report__c sReport = new Shop_Report__c();
        sReport.Daily_Inspection_Report__c = dir.Id;
        sReport.User__c = user1.Id;
        sReport.Comment__c = 'test';
        INSERT sReport;

        Responde__c responde = new Responde__c();
        responde.Shop_Report__c = sReport.Id;
        INSERT responde;

        Set<String> userEmailSet = new Set<String>();
        userEmailSet.add(user1.Email);

        // Group gro = new Group();
        // gro.Name = 'Update_Sampling_Detail';
        // INSERT gro;

        // GroupMember gm = new GroupMember();
        // gm.UserOrGroupId = user1.Id;
        // gm.GroupId = gro.id;
        // INSERT gm;

        // Test.startTest();
        //system.runAs(user1){
        InspectorDailyReportController.initData(dir.Id);
        InspectorDailyReportController.initData('');
        Test.startTest();
        InspectorDailyReportController.saveAttachment(cdl.ContentDocumentId,contentVersion.Id);
        InspectorDailyReportController.validationData(dir,stores,outPut.mileage,pa);
        InspectorDailyReportController.getNewCreateData(System.today() + 20);
        InspectorDailyReportController.getNewCreateData(System.today() - 20);
        InspectorDailyReportController.getNewCreateData(dateSelect);
        InspectorDailyReportController.addShopData(String.valueOf(shop.Id), 0, shopMap);
        InspectorDailyReportController.saveData(dir, stores, mileage, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        InspectorDailyReportController.saveData(dir, stores, mileage2, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        InspectorDailyReportController.sendApproval(supp);
        // InspectorDailyReportController.isExistProductsData(cProduct);
        InspectorDailyReportController.saveEvaluation(sReport.Comment__c,dir.Id);
        InspectorDailyReportController.saveResponse(sReport.Id, dir.Id, 'test');
        InspectorDailyReportController.deleteEvaluation(sReport.Id, dir.Id);
        InspectorDailyReportController.deleteResponde('', dir.Id, sReport.Id);
        //InspectorDailyReportController.sentEmail('test',userEmailSet,'testemail');
        //}
        InspectorDailyReportController.validationData(dir,stores,outPut.mileage,new Promoter_Attendance__c());

        Promoter_Attendance__c pa1 = new Promoter_Attendance__c();
        pa1.ApprovalStatus__c ='未创建';
        pa1.AddCheckInReason__c = 'test AddCheckInReason';
        pa1.Shop__c = shop.Id;
        pa1.Add_Check_Shop__c = shop.Id;
        pa1.CheckInStatus__c = '已签到';
        pa1.CheckOutShop__c = shop.Id;
        pa1.CheckIn_Date__c = dateSelect + 1;
        pa1.ExternalId__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c + 1);
        pa1.OwnerId = user1.Id;
        pa1.RecordTypeId = recordId;
        pa1.Daily_Inspection_Report__c = dir.Id;
        pa1.AddCheckSignInTime__c = null;
        pa1.SignInTime__c = Time.newInstance(18, 30, 00, 00);        
        INSERT pa1;

        Daily_Inspection_Report__c dir1 = new Daily_Inspection_Report__c();
        dir1.Report_Date__c = dateSelect + 1;
        dir1.OwnerId = user1.Id;
        INSERT dir1;

        Mileage__c mileage1= new Mileage__c();
        mileage1.Start__c = 1;
        mileage1.Amount_To__c = 50;
        mileage1.Report__c = dir.Id;
        mileage1.Gas_Mileage__c = 888;
        INSERT mileage1;
        outPut.mileage = mileage1;
        InspectorDailyReportController.validationData(dir1,stores,outPut.mileage,pa1);

        Test.stopTest();
        }
    }

    @IsTest
    static void testGetProductSeries(){
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        INSERT pro;
        Test.startTest();
        InspectorDailyReportController.getProductSeries(pro.Id);
        Test.stopTest();
        
    } 

    @IsTest
    static void saveDataTest2(){
        Test.startTest();
        String profileName = 'System Admin'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = 'Admin', email='test123123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123123@noemail.com');
        INSERT user1;
        acc = new Account(
                            Name = 'testname');
        insert acc;   
        shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Sales_Region__c = 'Hisense Japan';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;

        acc2 = new Account(
                            Name = 'testname2',
                            External_Key__c = '999999');
        insert acc2; 
        shop2 = new Shop__c();
        shop2.Account__c = acc2.Id;
        INSERT shop2;
        System.runAs(user1){
        dateSelect = system.today();
        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Detail__c = 'test';
        dir.Report_Date__c = dateSelect - 1;
        dir.OwnerId = user1.Id;
        INSERT dir;

        Promoter_Attendance__c pa2 = new Promoter_Attendance__c();
        INSERT pa2;
        pa2.Id = null;

        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.ExternalId__c = pa2.ExternalId__c;
        ist.OwnerId = user1.Id;
        ist.Status__c = '计划外到访';
        ist.Inspection_Date__c = dateSelect;
        ist.Daily_Inspection_Report__c = dir.Id;
        ist.Is_Create_Report__c = true;
        INSERT ist;


        Sampling_Inspection__c si2 = new Sampling_Inspection__c();
        si2.ExternalID__c =  user1.Id + '_' + String.valueOf(pa2.CheckIn_Date__c);

        Id recordId3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ALL_Product_Japan'][0].Id;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.OwnerId = user1.Id;
        pro.RecordTypeId = recordId3;
        INSERT pro;

        si2.Inspection_Shop_Task__c = ist.Id;
        si2.Shop__c = shop.Id;
        si2.Product__c = pro.Id;
        INSERT si2;

        Sample_Images__c sample = new Sample_Images__c();
        sample.Sampling_Inspection__c = si2.Id;
        sample.ReRe__c = 'test';
        INSERT sample;

        InspectorDailyReportController.SampleImagesData  sampleImagesData = new InspectorDailyReportController.SampleImagesData();
        sampleImagesData.sampleImages = sample;
        sampleImagesData.index = '1';

        List<InspectorDailyReportController.SampleImagesData> sampleImageList = new List<InspectorDailyReportController.SampleImagesData>();
        sampleImageList.add(sampleImagesData);

        InspectorDailyReportController.SamplingInspectionData si = new InspectorDailyReportController.SamplingInspectionData();
        si.key = '1';
        si.index = '1';
        si.showDelete = true;
        si.samplingInspection = si2;
        si.sampleImageList = sampleImageList;


        List<InspectorDailyReportController.SamplingInspectionData> samplingInspectionDataList = new List<InspectorDailyReportController.SamplingInspectionData>();
        samplingInspectionDataList.add(si);

        Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
        isp.Inspection_Year__c = String.valueOf(system.today().year());
        isp.Inspection_Month__c =  String.valueOf(system.today().month());
        isp.OwnerId__c = user1.Id;
        INSERT isp;

        InspectorDailyReportController.Store store = new InspectorDailyReportController.Store();
        store.taskStatus = true;
        store.samplingInspectionDataList = samplingInspectionDataList;
        store.isCanChangeStatus = true;
        store.shop = shop.Id;
        List<InspectorDailyReportController.Store> stores = new List<InspectorDailyReportController.Store>();
        stores.add(store);
        store.taskStatus = false;

        Mileage__c mileage = new Mileage__c();
        mileage.Start__c = 1;
        mileage.End__c = 222;
        mileage.Amount_To__c = 50;
        mileage.Report__c = dir.Id;
        mileage.Gas_Mileage__c = 888;
        INSERT mileage;
        mileage.Id = null;
        mileage.Amount_To__c = 100;

        List<String> deleteTaskId = new List<String>();
        List<String> deletePhoto = new List<String>();
        
        InspectorDailyReportController.saveData(dir, stores, mileage, true, Date.today(), deleteTaskId, pa2, deletePhoto, mileage.id, true);

        
        Test.stopTest();
        }
    }

    static testMethod void testInspectorDailyReportController1(){
        String profileName = 'System Admin'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;

        User userManager = new User(alias = 'Adin1113', email='test12341657212@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing1231212', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test1236575674@noemail.com');
        INSERT userManager;

        User user1 = new User(alias = 'Adin463', email='test12334535@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing1245643', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test12323425@noemail.com', ManagerId = userManager.Id);
        INSERT user1;
        acc = new Account(
                            Name = 'testname');
        insert acc;   
        shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        shop.City__c = '北京市';
        shop.Sales_Region__c = 'Hisense Japan';
        shop.Shop_Center_Location__Latitude__s = 29.4545;
        shop.Shop_Center_Location__Longitude__s = 106.509;
        INSERT shop;

        acc2 = new Account(
                            Name = 'testname2',
                            External_Key__c = '999999');
        insert acc2; 
        shop2 = new Shop__c();
        shop2.Account__c = acc2.Id;
        INSERT shop2;
        system.runAs(user1){
        dateSelect = system.today();
        Daily_Inspection_Report__c dir = new Daily_Inspection_Report__c();
        dir.Report_Detail__c = 'test';
        dir.Report_Date__c = dateSelect;
        dir.OwnerId = user1.Id;
        INSERT dir;

           
        Credit_Limit_Application__c newCredit = new Credit_Limit_Application__c(
                                                Payment_Method__c = '1',
                                                Buyer_English_Address__c = 'testtheaddress',
                                                //Enterprise_internal_code__c = 'testcode',
                                                Credit_Guarantee_Issuing_Bank_SWIFT__c='A0000111',
                                                Customer__c = acc.Id);
        insert newCredit;
        
        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Penguins',
                                        PathOnClient = 'Penguins.jpg',
                                        VersionData = Blob.valueOf('Test Content'),
                                        IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = newCredit.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;


        Id recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'InspectorAttendace'][0].Id;
        Id recordId2 = [SELECT Id FROM RecordType WHERE DeveloperName = 'CheckInSupplementary'][0].Id;
        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.ApprovalStatus__c ='未创建';
        pa.AddCheckInReason__c = 'test AddCheckInReason';
        pa.Shop__c = shop.Id;
        pa.Add_Check_Shop__c = shop.Id;
        pa.CheckInStatus__c = '已签退';
        pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = dateSelect;
        pa.ExternalId__c = user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
        pa.OwnerId = user1.Id;
        pa.RecordTypeId = recordId;
        pa.Daily_Inspection_Report__c = dir.Id;
        pa.AddCheckSignInTime__c = null;
        pa.SignInTime__c = Time.newInstance(18, 30, 00, 00);        
        INSERT pa;



        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop.Id;
        ist.ExternalId__c = pa.ExternalId__c;
        ist.OwnerId = user1.Id;
        ist.Status__c = '计划外到访';
        ist.Inspection_Date__c = dateSelect;
        ist.Daily_Inspection_Report__c = dir.Id;
        ist.Is_Create_Report__c = true;
        INSERT ist;

        Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
        ist2.Shop__c = shop.Id;
        ist2.ExternalId__c = pa.ExternalId__c;
        ist2.OwnerId = user1.Id;
        ist2.Status__c = '未到访';
        ist2.Inspection_Date__c = dateSelect + 1;
        ist2.Daily_Inspection_Report__c = dir.Id;
        ist2.Is_Create_Report__c = true;
        INSERT ist2;

        Supplementary_Information__c supp = new Supplementary_Information__c();
        supp.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        supp.Shop__c = shop.Id;
        supp.Status__c='已提交补签申请';
        supp.Attendance__c = pa.Id;
        supp.RecordTypeId = recordId2;
        supp.Reson__c = 'test';
        INSERT supp;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop2.Id;
        INSERT rp; 

        Sampling_Mapping__c sm = new Sampling_Mapping__c();
        sm.Account__c = acc.Id;
        sm.Level__c = 'A';
        sm.Shop_Level__c = 'A';
        INSERT sm;
		Sampling_Standard__c ss = new Sampling_Standard__c();
        ss.Sampling_Mapping__c = sm.Id;
        ss.Channel_Name__c = acc.Id;
        ss.Status__c = 'True';
        ss.Is_Add_ByReport__c = true;
        INSERT ss; 

        Id recordId3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ALL_Product_Japan'][0].Id;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.OwnerId = user1.Id;
        pro.RecordTypeId = recordId3;
        INSERT pro;

        Sampling_Inspection__c si2 = new Sampling_Inspection__c();
        // si.IsNew__c = true;
        si2.ExternalID__c =  user1.Id + '_' + String.valueOf(pa.CheckIn_Date__c);
        si2.Inspection_Shop_Task__c = ist.Id;
        si2.Shop__c = shop.Id;
        si2.Product__c = pro.Id;
        INSERT si2;

        Sample_Images__c sample = new Sample_Images__c();
        sample.Sampling_Inspection__c = si2.Id;
        sample.ReRe__c = 'test';
        INSERT sample;

        InspectorDailyReportController.SampleImagesData  sampleImagesData = new InspectorDailyReportController.SampleImagesData();
        sampleImagesData.sampleImages = sample;
        sampleImagesData.index = '1';

        List<InspectorDailyReportController.SampleImagesData> sampleImageList = new List<InspectorDailyReportController.SampleImagesData>();
        sampleImageList.add(sampleImagesData);

        InspectorDailyReportController.SamplingInspectionData si = new InspectorDailyReportController.SamplingInspectionData();
        si.key = '1';
        si.index = '1';
        si.showDelete = true;
        si.samplingInspection = si2;
        si.sampleImageList = sampleImageList;


        List<InspectorDailyReportController.SamplingInspectionData> samplingInspectionDataList = new List<InspectorDailyReportController.SamplingInspectionData>();
        samplingInspectionDataList.add(si);

        Sampling_Detail__c sd = new Sampling_Detail__c();
        sd.Sampling_Standard__c = ss.Id;
        sd.Shop__c = shop.Id;
        sd.Is_Add__c = '是';
        sd.ExternalID__c = si2.Shop__c+'-'+si2.Product__c;
        INSERT sd;

        Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
        isp.Inspection_Year__c = String.valueOf(system.today().year());
        isp.Inspection_Month__c =  String.valueOf(system.today().month());
        isp.OwnerId__c = user1.Id;
        INSERT isp;

        InspectorDailyReportController.Store store = new InspectorDailyReportController.Store();
        store.taskStatus = true;
        store.samplingInspectionDataList = samplingInspectionDataList;
        store.isCanChangeStatus = true;
        store.shop = shop.Id;
        List<InspectorDailyReportController.Store> stores = new List<InspectorDailyReportController.Store>();
        stores.add(store);
        store.taskStatus = false;

        InspectorDailyReportController.OutPut outPut = new InspectorDailyReportController.OutPut();
        Mileage__c mileage = new Mileage__c();
        mileage.Start__c = 1;
        mileage.End__c = 222;
        mileage.Amount_To__c = 50;
        mileage.Report__c = dir.Id;
        mileage.Gas_Mileage__c = 888;
        INSERT mileage;
        mileage.Id = null;
        //UPDATE mileage;
        system.debug(mileage);

        Mileage__c mileage2 = new Mileage__c();
        mileage2.Start__c = 10;
        mileage2.End__c = 22;
        mileage2.Amount_To__c = 500;
        mileage2.Report__c = dir.Id;
        INSERT mileage2;
        mileage2.Amount_To__c = 100;

        outPut.mileage = mileage;
        outPut.mileageFirst = true;
        outPut.lastMileageId = mileage2.id;
        InspectorDailyReportController.ShopSelect shopSelect = new InspectorDailyReportController.ShopSelect();
        shopSelect.label = shop.Name;
        shopSelect.value = 'testvalue';


        List<InspectorDailyReportController.ShopSelect> shopSelectList = new List<InspectorDailyReportController.ShopSelect>();
        shopSelectList.add(shopSelect);

        Map<String,List<InspectorDailyReportController.ShopSelect>> shopMap = new Map<String,List<InspectorDailyReportController.ShopSelect>>();
        shopMap.put(acc.Name,shopSelectList);

        List<String> deleteTaskId = new List<String>();
        deleteTaskId.add(ist.Id);
        deleteTaskId.add(ist2.Id);
        List<String> deletePhoto = new List<String>();
        
        // InspectorDailyReportController.CompetitiveProducts   cProduct = new InspectorDailyReportController.CompetitiveProducts();

        // Competitive_products__c cp = new Competitive_products__c();
        // cp.Name = 'test';
        // cp.Is_Active__c = True;
        // cp.ExternalId__c = cProduct.productsName+'_'+cProduct.brand+'_'+cProduct.size+'_'+cProduct.posttype;
        // INSERT cp;

        Shop_Report__c sReport = new Shop_Report__c();
        sReport.Daily_Inspection_Report__c = dir.Id;
        sReport.User__c = user1.Id;
        sReport.Comment__c = 'test';
        INSERT sReport;

        Responde__c responde = new Responde__c();
        responde.Shop_Report__c = sReport.Id;
        INSERT responde;

        Set<String> userEmailSet = new Set<String>();
        userEmailSet.add(user1.Email);

        Daily_Inspection_Report__c dir1 = new Daily_Inspection_Report__c();
        dir1.Report_Detail__c = 'test1';
        dir1.Report_Date__c = dateSelect - 5;
        dir1.OwnerId = user1.Id;
        INSERT dir1;
        Daily_Inspection_Report__c dir2 = new Daily_Inspection_Report__c();
        dir2.Report_Detail__c = 'test2';
        dir2.Report_Date__c = dateSelect - 3;
        dir2.OwnerId = user1.Id;
        INSERT dir2;
        Daily_Inspection_Report__c dir3 = new Daily_Inspection_Report__c();
        dir3.Report_Detail__c = 'test3';
        dir3.Report_Date__c = dateSelect + 2;
        dir3.OwnerId = user1.Id;
        INSERT dir3;

        Mileage__c mileage3 = new Mileage__c();
        mileage3.Start__c = 10;
        mileage3.End__c = 22;
        mileage3.Report__c = dir1.Id;
        INSERT mileage3;
        Mileage__c mileage4 = new Mileage__c();
        mileage4.Start__c = 10;
        mileage4.End__c = 22;
        mileage4.Gas_Mileage__c = 12;
        mileage4.Report__c = dir2.Id;
        INSERT mileage4;
        Mileage__c mileage5 = new Mileage__c();
        mileage5.Start__c = 10;
        mileage5.End__c = 22;
        mileage5.Gas_Mileage__c = 12;
        mileage5.Amount_To__c = 500;
        mileage5.Report__c = dir3.Id;
        INSERT mileage5;

        Test.startTest();
        mileage.Amount_To__c = null;
        
        InspectorDailyReportController.deleteResponde(responde.id, dir.Id, sReport.Id);
        InspectorDailyReportController.getStoreInfo(shop.Name);
        InspectorDailyReportController.saveData(dir, stores, mileage, true, Date.today(), new List<String>(), new Promoter_Attendance__c(), deletePhoto, outPut.lastMileageId, true);
        InspectorDailyReportController.saveData(dir, stores, mileage, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        InspectorDailyReportController.saveData(dir, stores, mileage3, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        InspectorDailyReportController.saveData(dir, stores, mileage4, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        mileage3.Amount_To__c = 22;
        mileage3.Gas_Mileage__c = 22;
        mileage3.id = null;
        InspectorDailyReportController.saveData(dir, stores, mileage3, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        mileage4.Amount_To__c = 22;
        InspectorDailyReportController.saveData(dir, stores, mileage4, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        InspectorDailyReportController.saveData(dir, stores, mileage5, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        mileage5.Amount_To__c = 22;
        InspectorDailyReportController.saveData(dir, stores, mileage5, true, Date.today(), deleteTaskId, pa, deletePhoto, outPut.lastMileageId, true);
        Test.stopTest();
        }
    }
    
}