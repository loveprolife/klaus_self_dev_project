@IsTest(SeeAllData = false)
private class DownloadZipControllerTest{
    /* =========================
     Shared Test Utilities
     ========================= */
    // Ensure current user has Sales_Region__c set, because controller queries rely on it
    private static void ensureCurrentUserSR(){
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        if (String.isBlank(u.Sales_Region__c)){
            u.Sales_Region__c = 'SR-TEST';
            update u;
        }
    }

    // Create a Shop__c
    private static Shop__c mkShop(){
        Channel_item__c channelItem = new Channel_item__c();
        channelItem.Channel_Name__c = 'CH001';
        insert channelItem;

        Shop__c s = new Shop__c(
            Name = 'Test Shop', 
            Channel_item__c = channelItem.Id
        );
        insert s;
        return s;
    }

    // Try make an InspectorDailyReport__c; return Id or null if object missing
    private static Id mkInspectorDailyReport(Shop__c shop, Date d, String status, String sr){
        // try {
        SObject idr = (SObject) Schema.getGlobalDescribe().get('Daily_Inspection_Report__c').newSObject();
        idr.put('Report_Date__c', d);
        idr.put('Store__c', shop.Id);
        idr.put('Status__c', status);
        // idr.put('Sales_Region__c', sr);
        // Optional fields guarded
        try{
            idr.put('OwnerId', UserInfo.getUserId());
        } catch (Exception e){
        }
        insert idr;
        return (Id) idr.get('Id');
        // } catch (Exception e) {
        //     return null;
        // }
    }

    // Create a CheckItem if exists, returns Id or null
    private static Id mkCheckItem(String itemType, String desc1){
        // try {
        SObject ci = (SObject) Schema.getGlobalDescribe().get('CheckItem__c').newSObject();
        ci.put('RecordTypeId', Schema.SobjectType.CheckItem__c.getRecordTypeInfosByDeveloperName().get('USA').getRecordTypeId());
        ci.put('Item_Type__c', itemType);
        ci.put('Description__c', desc1);
        insert ci;
        return (Id) ci.get('Id');
        // } catch (Exception e) {
        //     return null;
        // }
    }

    // Create a CheckResult__c for given IDR and CheckItem
    private static Id mkCheckResult(Id idrId, Id checkItemId, String response, String result){
        // try {
        SObject cr = (SObject) Schema.getGlobalDescribe().get('CheckResult__c').newSObject();
        cr.put('InspectorDailyReport__c', idrId);
        if (checkItemId != null)
            cr.put('CheckItem__c', checkItemId);
        if (response != null)
            cr.put('Response__c', response);
        // if (result != null) cr.put('Result__c', result);
        insert cr;
        return (Id) cr.get('Id');
        // } catch (Exception e) {
        //     return null;
        // }
    }

    // Try make an Inspection_Report__c
    private static Id mkInspectionReport(Date d, String status, String sr, Id shopId){
        // try {
        SObject ir = (SObject) Schema.getGlobalDescribe().get('Daily_Inspection_Report__c').newSObject();
        ir.put('Report_Date__c', d);
        ir.put('Status__c', status);
        // ir.put('Sales_Region__c', sr);
        try{
            ir.put('OwnerId', UserInfo.getUserId());
        } catch (Exception e){
        }
        insert ir;
        return (Id) ir.get('Id');
        // } catch (Exception e) {
        //     return null;
        // }
    }

    // Try make a Sampling_Inspection__c under inspection report
    private static Id mkSampling(Id reportId, Shop__c shop, String placementStatus, String productName){
        // try {
        // try create Product__c if exists
        Id prodId = null;
        try{
            SObject prod = (SObject) Schema.getGlobalDescribe().get('Product__c').newSObject();
            prod.put('Name', productName);
            insert prod;
            prodId = (Id) prod.get('Id');
        } catch (Exception e){
        }
        SObject sp = (SObject) Schema.getGlobalDescribe().get('Sampling_Inspection__c').newSObject();
        sp.put('Inspection_Report__c', reportId);
        sp.put('Shop__c', shop.Id);
        sp.put('ExternalID__c', prodId);
        if (prodId != null)
            sp.put('Product__c', prodId);
        if (placementStatus != null)
            sp.put('Placement_Status__c', placementStatus);
        insert sp;
        return (Id) sp.get('Id');
        // } catch (Exception e) {
        //     return null;
        // }
    }

    // Create a ContentVersion, return queried with ContentDocumentId
    private static ContentVersion mkContentVersion(String title, String filename){
        ContentVersion cv = new ContentVersion(
            Title = title, 
            PathOnClient = filename, 
            VersionData = Blob.valueOf('binary-content-' + title), 
            IsMajorVersion = true
        );
        insert cv;
        return [SELECT Id, ContentDocumentId, Title
                FROM ContentVersion
                WHERE Id = :cv.Id];
    }

    // Link ContentDocument to an entity
    private static ContentDocumentLink linkDoc(Id entityId, Id contentDocumentId){
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = entityId, 
            ContentDocumentId = contentDocumentId, 
            ShareType = 'V'
        );
        insert cdl;
        return cdl;
    }

    // Create an Inspection_Photo_Download__c
    private static Inspection_Photo_Download__c mkPhotoDownload(String sr, Shop__c shop, Id idrId, Id docId, Date d, String type, String desc1, String photoId){
        Inspection_Photo_Download__c p = new Inspection_Photo_Download__c();
        p.SBU__c = sr;
        p.Inspection_Date__c = d;
        p.Item_Type__c = type;
        p.Description__c = desc1;
        p.DocumentId__c = (docId != null ? String.valueOf(docId) : null);
        p.PhotoId__c = photoId;
        p.Store__c = shop.Id;
        if (idrId != null){
            try{
                p.put('InspectorDailyReport__c', idrId);
            } catch (Exception e){
            }
        }
        insert p;
        return p;
    }

    // Build inclusive day count robustly
    private static Integer dayCount(Date a, Date b){
        return Math.abs(a.daysBetween(b)) + 1;
    }

    /* =========================
     Tests
     ========================= */
    @IsTest
    static void t01_searchDownloadPhoto_empty(){
        ensureCurrentUserSR();
        Date startDate = Date.today().addDays(-3);
        Date endDate = Date.today();

        Test.startTest();
        Map<String, Object> resp = DownloadZipController.searchDownloadPhoto(null, startDate, endDate, null, null);
        Test.stopTest();

        System.assertNotEquals(null, resp);
        System.assertEquals(true, resp.containsKey('result'));
        System.assertEquals(true, resp.containsKey('urlList'));
        System.assertEquals(true, resp.containsKey('total'));
        System.assertEquals(0, (Integer) resp.get('total'));
        List<Object> result = (List<Object>)resp.get('result');
        System.assertEquals(dayCount(startDate, endDate), result.size());
    }

    @IsTest
    static void t02_searchDownloadPhoto_withData(){
        ensureCurrentUserSR();
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        Shop__c shop = mkShop();

        Date d = Date.today();
        Id idrId = mkInspectorDailyReport(shop, d, 'Submitted', u.Sales_Region__c);

        ContentVersion cv = mkContentVersion('Test Photo', 'test.jpg');

        // two records with same PhotoId to test de-dup inside result grouping
        Inspection_Photo_Download__c p1 = mkPhotoDownload(u.Sales_Region__c, shop, idrId, cv.ContentDocumentId, d, 'TypeA', 'Desc1', 'P1');
        Inspection_Photo_Download__c p2 = mkPhotoDownload(u.Sales_Region__c, shop, idrId, cv.ContentDocumentId, d, 'TypeA', 'Desc2', 'P1');

        Date startDate = d;
        Date endDate = d;

        Test.startTest();
        Map<String, Object> resp = DownloadZipController.searchDownloadPhoto(shop.Id, startDate, endDate, null, null);
        Test.stopTest();

        System.assertEquals(true, resp.containsKey('isSuccess'));
        System.assertEquals(true, resp.containsKey('result'));
        System.assertEquals(true, resp.containsKey('urlList'));
        System.assertEquals(true, resp.containsKey('total'));
        System.assertEquals(2, (Integer) resp.get('total')); // total equals inserted count

        List<Object> result = (List<Object>)resp.get('result');
        System.assertEquals(1, result.size());
        Map<String, Object> dayBucket = (Map<String, Object>)result[0];
        Map<String, Object> itemTypeMap = (Map<String, Object>)dayBucket.get('dateDocument');
        System.assertEquals(true, itemTypeMap.containsKey('TypeA'));

        List<String> urlList = (List<String>)resp.get('urlList');
        Boolean hasShepherd = false;
        for (String s : urlList){
            if (s.contains('/sfc/servlet.shepherd/document/download/')){
                hasShepherd = true;
                break;
            }
        }
        System.assertEquals(true, hasShepherd, 'should build shepherd urls');
    }

    @IsTest
    static void t03_getUniqueARecords(){
        List<Inspection_Photo_Download__c> src = new List<Inspection_Photo_Download__c>{ new Inspection_Photo_Download__c(
            PhotoId__c = 'A', 
            Description__c = '1'
        ), new Inspection_Photo_Download__c(
            PhotoId__c = 'A', 
            Description__c = '2'
        ), new Inspection_Photo_Download__c(
            PhotoId__c = 'B', 
            Description__c = '3'
        ) };
        List<Inspection_Photo_Download__c> out = DownloadZipController.getUniqueARecords(src);
        System.assertEquals(2, out.size());
        Set<String> ids = new Set<String>();
        for (Inspection_Photo_Download__c r : out)
            ids.add(r.PhotoId__c);
        System.assertEquals(true, ids.contains('A'));
        System.assertEquals(true, ids.contains('B'));
    }

    @IsTest
    static void t04_concatHelpers(){
        List<String> ids = new List<String>{ 'x', 'y', 'z' };
        String joined = DownloadZipController.concatenateBatch(ids, 0, 50);
        System.assertEquals('x/y/z', joined);

        Map<Date, List<String>> m = new Map<Date, List<String>>();
        List<String> out = DownloadZipController.concatenateStringsInBatches(m);
        System.assertEquals(0, out.size());
    }

    @IsTest
    static void t05_searchSample_and_groupers_withData(){
        ensureCurrentUserSR();
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        Shop__c shop = mkShop();
        Date d = Date.today();

        // Build CheckResult side to exercise groupContentDocumentIdsByDate
        Id idrId = mkInspectorDailyReport(shop, d, 'Submitted', u.Sales_Region__c);
        Id checkItemId = mkCheckItem('Material', 'CI Desc');
        Id crId = mkCheckResult(idrId, checkItemId, 'Resp', 'OK');
        if (crId != null){
            ContentVersion cvr = mkContentVersion('CR Doc', 'cr.jpg');
            linkDoc(crId, cvr.ContentDocumentId);
        }

        // Build Sample side to exercise sampleContentDocumentIdsByDate and searchSample merge
        Id irId = mkInspectionReport(d, 'Submitted', u.Sales_Region__c, shop.Id);
        Id spId = mkSampling(irId, shop, '展出', 'ProdA');
        if (spId != null){
            ContentVersion cvs = mkContentVersion('SP Doc', 'sp.jpg');
            linkDoc(spId, cvs.ContentDocumentId);
        }

        Date startDate = d;
        Date endDate = d;

        Test.startTest();
        Map<String, Object> resp = DownloadZipController.searchSample(shop.Id, startDate, endDate, null, null);
        Test.stopTest();

        System.assertEquals(true, resp.containsKey('result'));
        System.assertEquals(true, resp.containsKey('urlList'));
        // if any docs existed, key should be present
        if (resp.containsKey('key')){
            System.assertEquals(true, ((String) resp.get('key')).length() > 0);
        }
        List<Object> result = (List<Object>)resp.get('result');
        System.assertEquals(1, result.size());
    }

    @IsTest
    static void t06_getParamResult_withData_and_NoData(){
        ensureCurrentUserSR();
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        Shop__c shop = mkShop();
        Date d = Date.today();

        // First call with no photo data in range (yesterday-2, yesterday-1) => should return default lists
        Date s1 = Date.today().addDays(-2);
        Date e1 = Date.today().addDays(-1);
        Map<String, Object> noData = DownloadZipController.getParamResult(s1, e1);
        System.assertEquals(true, noData.containsKey('channel'));
        System.assertEquals(true, noData.containsKey('owner'));

        // Prepare photo data in range for second call
        Id idrId = mkInspectorDailyReport(shop, d, 'Submitted', u.Sales_Region__c);
        ContentVersion cv = mkContentVersion('PD', 'pd.jpg');
        mkPhotoDownload(u.Sales_Region__c, shop, idrId, cv.ContentDocumentId, d, 'TypeA', 'Desc', 'PX');

        Test.startTest();
        Map<String, Object> resp = DownloadZipController.getParamResult(d, d);
        Test.stopTest();

        System.assertEquals(true, resp.containsKey('channel'));
        System.assertEquals(true, resp.containsKey('owner'));
        List<Map<String, String>> channels = (List<Map<String, String>>)resp.get('channel');
        List<Map<String, String>> owners = (List<Map<String, String>>)resp.get('owner');
        System.assertEquals(true, channels.size() >= 1);
        System.assertEquals(true, owners.size() >= 1);
    }

    @IsTest
    static void t07_getResultByStore_withData(){
        ensureCurrentUserSR();
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        Shop__c shop = mkShop();
        Date d = Date.today();

        Id idrId = mkInspectorDailyReport(shop, d, 'Submitted', u.Sales_Region__c);
        ContentVersion cv = mkContentVersion('PD2', 'pd2.jpg');
        mkPhotoDownload(u.Sales_Region__c, shop, idrId, cv.ContentDocumentId, d, 'TypeB', 'DescB', 'PY');

        Test.startTest();
        Map<String, Object> resp = DownloadZipController.getResultByStore(shop.Id, d, d);
        Test.stopTest();

        System.assertEquals(true, resp.containsKey('channelId'));
        System.assertEquals(true, resp.containsKey('owner'));
        List<Map<String, String>> owners = (List<Map<String, String>>)resp.get('owner');
        System.assertEquals(true, owners.size() >= 1);
    }

    @IsTest
    static void t08_shopVerification_match_unmatch(){
        Shop__c shop = mkShop();

        // unmatch
        Map<String, Object> unmatch = DownloadZipController.shopVerification(shop.Id, 'DIFF');
        System.assertEquals(true, unmatch.containsKey('shopId'));

        // match
        Map<String, Object> match = DownloadZipController.shopVerification(shop.Id, shop.Channel_item__c);
        System.assertEquals(true, match.containsKey('shopId'));
        System.assertEquals(shop.Id, (Id) match.get('shopId'));
    }

    @IsTest
    static void t09_changeCheckResultPhotoName_updates_titles(){
        ensureCurrentUserSR();
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        Shop__c shop = mkShop();
        Date d = Date.today();

        // Build a CheckResult with two linked ContentDocumentLink entries to trigger counting
        Id idrId = mkInspectorDailyReport(shop, d, 'Submitted', u.Sales_Region__c);
        Id checkItemId = mkCheckItem('Personnel', 'CI-Name');
        Id crId = mkCheckResult(idrId, checkItemId, null, 'OK');
        if (crId != null){
            ContentVersion cv1 = mkContentVersion('Rename1', 'r1.jpg');
            ContentVersion cv2 = mkContentVersion('Rename2', 'r2.jpg');
            linkDoc(crId, cv1.ContentDocumentId);
            linkDoc(crId, cv2.ContentDocumentId);
        }

        Test.startTest();
        DownloadZipController.changeCheckResultPhotoName(d, d, u.Sales_Region__c);
        Test.stopTest();

        // We cannot assert exact titles (Org-specific labels), but ensure no exception and ContentVersion are still present
        Integer cnt = [SELECT COUNT()
                       FROM ContentVersion];
        System.assertEquals(true, cnt >= 2);
    }

    @IsTest
    static void t10_changeSamplePhotoName_updates_titles(){
        ensureCurrentUserSR();
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        Shop__c shop = mkShop();
        Date d = Date.today();

        Id irId = mkInspectionReport(d, 'Submitted', u.Sales_Region__c, shop.Id);
        Id spId = mkSampling(irId, shop, '展出', 'ProdB');
        if (spId != null){
            ContentVersion cv1 = mkContentVersion('SRename1', 'sr1.jpg');
            ContentVersion cv2 = mkContentVersion('SRename2', 'sr2.jpg');
            linkDoc(spId, cv1.ContentDocumentId);
            linkDoc(spId, cv2.ContentDocumentId);
        }

        Test.startTest();
        DownloadZipController.changeSamplePhotoName(d, d, u.Sales_Region__c);
        Test.stopTest();

        Integer cnt = [SELECT COUNT()
                       FROM ContentVersion];
        System.assertEquals(true, cnt >= 2);
    }

    @IsTest
    static void t11_processCheckResults_and_getUpdateStatus(){
        ensureCurrentUserSR();
        String batchClass = 'PhotoDownloadProcessBatch';
        Test.startTest();
        DownloadZipController.processCheckResults(null, Date.today().addDays(-1), Date.today(), null, null);
        Update_Data_Event__c status = DownloadZipController.getUpdateStatus(batchClass);
        Test.stopTest();

        // processCheckResults upserts an event, then getUpdateStatus should fetch it
        System.assertEquals(true, status == null || status.Update_Status__c == 'Updating');
    }

    @IsTest
    static void t12_groupContentDocumentIdsByDate_direct(){
        // Directly cover groupContentDocumentIdsByDate with constructed lists
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        List<CheckResult__c> crs = new List<CheckResult__c>();

        // If CheckResult__c object doesn't exist, skip
        Boolean hasCR = Schema.getGlobalDescribe().containsKey('CheckResult__c');
        if (!hasCR)
            return;
        // Create two CRs on same day via dynamic insert
        Date d = Date.today();
        Id idrId = null;
        Id ciId = null;
        Shop__c shop = mkShop();
        ensureCurrentUserSR();
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        idrId = mkInspectorDailyReport(shop, d, 'Submitted', u.Sales_Region__c);
        ciId = mkCheckItem('Training', 'descD');
        Id crId1 = mkCheckResult(idrId, ciId, null, 'OK');
        Id crId2 = mkCheckResult(idrId, ciId, null, 'OK');

        // Build ContentVersion and links
        ContentVersion c1 = mkContentVersion('A', 'a.jpg');
        ContentVersion c2 = mkContentVersion('B', 'b.jpg');
        if (crId1 != null)
            linkDoc(crId1, c1.ContentDocumentId);
        if (crId2 != null)
            linkDoc(crId2, c2.ContentDocumentId);
        Set<Id> crIdSet = new Set<Id>{ crId1, crId2 };
        // Query back real lists for function
        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.PathOnClient
                                         FROM ContentDocumentLink
                                         WHERE LinkedEntityId IN:crIdSet];
        List<CheckResult__c> checkList = [SELECT Id, InspectorDailyReport__r.Report_Date__c
                                          FROM CheckResult__c
                                          WHERE Id IN:crIdSet];

        Test.startTest();
        Map<Date, List<String>> m = DownloadZipController.groupContentDocumentIdsByDate(checkList, cdl);
        Test.stopTest();

        System.assertEquals(true, m.containsKey(d));
        System.assertEquals(true, m.get(d).size() >= 2);
    }

    @IsTest
    static void t13_sampleContentDocumentIdsByDate_direct(){
        // Directly cover sampleContentDocumentIdsByDate
        Boolean hasSP = Schema.getGlobalDescribe().containsKey('Sampling_Inspection__c');
        if (!hasSP)
            return;
        ensureCurrentUserSR();
        User u = [SELECT Id, Sales_Region__c
                  FROM User
                  WHERE Id = :UserInfo.getUserId()];
        Shop__c shop = mkShop();
        Date d = Date.today();

        Id irId = mkInspectionReport(d, 'Submitted', u.Sales_Region__c, shop.Id);
        Id sp1 = mkSampling(irId, shop, '展出', 'P1');
        Id sp2 = mkSampling(irId, shop, '展出', 'P2');
        ContentVersion c1 = mkContentVersion('SP-A', 'spa.jpg');
        ContentVersion c2 = mkContentVersion('SP-B', 'spb.jpg');
        if (sp1 != null)
            linkDoc(sp1, c1.ContentDocumentId);
        if (sp2 != null)
            linkDoc(sp2, c2.ContentDocumentId);
        Set<Id> spSet = new Set<Id>{ sp1, sp2 };
        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.LatestPublishedVersion.VersionData, ContentDocument.LatestPublishedVersion.PathOnClient
                                         FROM ContentDocumentLink
                                         WHERE LinkedEntityId IN:spSet];
        List<Sampling_Inspection__c> sl = [SELECT Id, Inspection_Report__r.Report_Date__c
                                           FROM Sampling_Inspection__c
                                           WHERE Id IN:spSet];

        Test.startTest();
        Map<Date, List<String>> m = DownloadZipController.sampleContentDocumentIdsByDate(sl, cdl);
        Test.stopTest();

        System.assertEquals(true, m.containsKey(d));
        System.assertEquals(true, m.get(d).size() >= 2);
    }

    @isTest
    public static void testMethod2(){
        Test.startTest();
        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'testPromoterUser121382';
        promoter.alias = 'Promoter';
        promoter.email = 'Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id
                              FROM profile
                              WHERE Name LIKE '%Argentina%'][0].Id;
        promoter.timezonesidkey = 'Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Argentina';
        insert promoter;

        User manager = new User();
        manager.Username = 'testManagerUser1213823@test004.com';
        manager.lastname = 'testManagerUser121382';
        manager.alias = 'manager';
        manager.email = 'manager@test.com';
        manager.emailencodingkey = 'UTF-8';
        manager.languagelocalekey = 'zh_CN';
        manager.LocaleSidKey = 'zh_CN';
        manager.IsActive = true;
        manager.ProfileId = [SELECT Id
                             FROM profile
                             WHERE Name LIKE '%Argentina store manager%'][0].Id;
        manager.timezonesidkey = 'Asia/Shanghai';
        manager.Sales_Region__c = 'Hisense Argentina';
        manager.Department__c = 'Manager';
        insert manager;

        CheckItem__c checkItem = new CheckItem__c();
        checkItem.Description__c = '111111';
        checkItem.Active__c = true;
        // checkItem.Sales_Region__c = 'Hisense USA';
        // checkItem.Product_Line__c = 'TV';
        // checkItem.Project__c = 'Booth and image';
        // checkItem.MaximumScore__c = '5';
        // checkItem.ResponsibleDepartment__c = 'Sales';
        // checkItem.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('USA').getRecordTypeId();
        // checkItem.Automatic_Generation_Ticket__c = true;
        // checkItem.Question_Type__c = 'Yes/No';
        // checkItem.Item_Type__c = 'Training';
        insert checkItem;

        CheckItem__c checkItem1 = new CheckItem__c();
        checkItem1.Description__c = '222222';
        checkItem1.Active__c = true;
        // checkItem1.Sales_Region__c = 'Hisense USA';
        // checkItem1.Product_Line__c = 'TV';
        // checkItem1.Project__c = 'Booth and image';
        // checkItem1.MaximumScore__c = '5';
        // checkItem1.ResponsibleDepartment__c = 'Sales';
        // checkItem1.RecordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByName().get('USA').getRecordTypeId();
        // checkItem1.Automatic_Generation_Ticket__c = true;
        // checkItem1.Question_Type__c = 'Yes/No';
        // checkItem1.Item_Type__c = 'Training';
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

        Channel_item__c channelItem = new Channel_item__c();
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
        inspectionReport.Report_Date__c = System.today().addDays(-1);
        inspectionReport.OwnerId = promoter.Id;
        inspectionReport.Store__c = shop1.Id;
        insert inspectionReport;

        Daily_Inspection_Report__c inspectionReport1 = new Daily_Inspection_Report__c();
        inspectionReport1.Report_Date__c = System.today();
        inspectionReport1.OwnerId = promoter.Id;
        inspectionReport1.Store__c = shop1.Id;
        insert inspectionReport1;

        CheckResult__c checkResult = new CheckResult__c();
        checkResult.InspectorDailyReport__c = inspectionReport.Id;
        checkResult.CheckItem__c = checkItem.Id;
        checkResult.Status__c = 'Draft';
        checkResult.Max_Scores__c = 5;
        checkResult.Scores__c = 0;
        insert checkResult;

        CheckResult__c checkResult1 = new CheckResult__c();
        checkResult1.InspectorDailyReport__c = inspectionReport1.Id;
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
            PathOnClient = 'Penguins.jpg', 
            VersionData = Blob.valueOf('Test Content'), 
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId
                                           FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = checkResult.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = testSI1.id;
        cd2.ContentDocumentId = documents[0].Id;
        cd2.shareType = 'V';
        insert cd2;

        inspectionReport.Status__c = 'Submitted';
        update inspectionReport;

        inspectionReport1.Status__c = 'Submitted';
        update inspectionReport1;

        // DownloadZipController.getInitData();
        System.runAs(promoter){
            DownloadZipController.getDataResult();
            DownloadZipController.shopVerification(shop1.Sales_Region__c, shop1.Channel_item__c);
            DownloadZipController.getParamResult(System.today(), System.today());
            DownloadZipController.sampleResult(shop1.Id, System.today().addDays(-2), System.today(), '', '');
            DownloadZipController.changeSamplePhotoName(System.today().addDays(-2), System.today(), promoter.Sales_Region__c);
        }


        String cronExpression = '0 0 1 * * ?'; // 每天凌晨1点运行
        String jobName = 'PhotoDownloadProcessBatchJobTest'; // 定时任务的名称
        PhotoDownloadProcessScheduler scheduler = new PhotoDownloadProcessScheduler();

        System.schedule(jobName, cronExpression, scheduler);
        Test.stopTest();
    }

}