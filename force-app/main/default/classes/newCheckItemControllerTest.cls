@isTest
public class newCheckItemControllerTest {

    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 

    @isTest
    static void testMethod1(){
        String recordTypeId = Schema.SObjectType.CheckItem__c.getRecordTypeInfosByDeveloperName().get('USA').getRecordTypeId();
        System.debug('wwwrecordTypeId:' + recordTypeId);

        CheckItem__c checkItem = new CheckItem__c(
                RecordTypeId = recordTypeId,
                Sales_Region__c = 'Hisense USA',
                Inspection_Type__c = 'Locale Inspection',
                Item_Type__c = 'Sampling Product Check',
                Question_Type__c = 'Yes/No',
                Description__c = 'Test',
                Description_CN__c = '',
                Description_EN__c = '',
                HelpText__c = '',
                HelpTextCN__c = '',
                HelpTextEN__c = '',
                Enter_Choice__c = '',
                MaximumScore__c = '5',
                Conditional_Score_Has_File__c = '',
                Conditional_Yes_No_Has_File__c = 'Yes',
                Conditional_Score_Has_Comment__c = '',
                Conditional_Yes_No_Has_Comment__c = 'Yes',
                Conditional_Score_Has_Ticket__c = '',
                Conditional_Yes_No_Has_Ticket__c = '',
                Active__c = true,
                HasRelateQuestions__c = false,
                HasFile__c = true,
                File_Conditional_Type__c = 'Conditional',
                HasComment__c = true,
                Comment_Conditional_Type__c = 'Conditional',
                Automatic_Generation_Ticket__c = false,
                Ticket_Conditional_Type__c = '',
                OrderNumber__c = 0,
                Product_Line__c = 'All',
                Parent_Select__c = '2&3',
                Score_Symbol_Response__c = '>&!='
        );
        Insert checkItem;

        CheckItem__c checkItem1 = new CheckItem__c(
                RecordTypeId = recordTypeId,
                Sales_Region__c = 'Hisense USA',
                Inspection_Type__c = 'Locale Inspection',
                Item_Type__c = 'Sampling Product Check',
                Question_Type__c = 'Yes/No',
                Description__c = 'Test1',
                Description_CN__c = '',
                Description_EN__c = '',
                HelpText__c = '',
                HelpTextCN__c = '',
                HelpTextEN__c = '',
                Enter_Choice__c = '',
                MaximumScore__c = '5',
                Conditional_Score_Has_File__c = '',
                Conditional_Yes_No_Has_File__c = '',
                Conditional_Score_Has_Comment__c = '',
                Conditional_Yes_No_Has_Comment__c = '',
                Conditional_Score_Has_Ticket__c = '',
                Conditional_Yes_No_Has_Ticket__c = '',
                Active__c = true,
                HasRelateQuestions__c = false,
                HasFile__c = true,
                File_Conditional_Type__c = 'Mandatory',
                HasComment__c = true,
                Comment_Conditional_Type__c = 'Mandatory',
                Automatic_Generation_Ticket__c = false,
                Ticket_Conditional_Type__c = '',
                OrderNumber__c = 1,
                Product_Line__c = 'All',
                Parent_Select__c = '2&3',
                Score_Symbol_Response__c = '>&!='
        );
        Insert checkItem1;

        CheckItem__c checkItem2 = new CheckItem__c(
                RecordTypeId = recordTypeId,
                Sales_Region__c = 'Hisense USA',
                Inspection_Type__c = 'Locale Inspection',
                Item_Type__c = 'Sampling Product Check',
                Question_Type__c = 'Yes/No',
                Description__c = 'Test2',
                Description_CN__c = '',
                Description_EN__c = '',
                HelpText__c = '',
                HelpTextCN__c = '',
                HelpTextEN__c = '',
                Enter_Choice__c = '',
                MaximumScore__c = '5',
                Conditional_Score_Has_File__c = '',
                Conditional_Yes_No_Has_File__c = 'Yes',
                Conditional_Score_Has_Comment__c = '',
                Conditional_Yes_No_Has_Comment__c = '',
                Conditional_Score_Has_Ticket__c = '',
                Conditional_Yes_No_Has_Ticket__c = '',
                Active__c = true,
                HasRelateQuestions__c = false,
                HasFile__c = true,
                File_Conditional_Type__c = 'Conditional',
                HasComment__c = false,
                Comment_Conditional_Type__c = '',
                Automatic_Generation_Ticket__c = false,
                Ticket_Conditional_Type__c = '',
                OrderNumber__c = 1,
                Product_Line__c = 'All',
                Parent_Select__c = '2&3',
                Score_Symbol_Response__c = '>&!='
        );
        Insert checkItem2;

        CheckItem__c realteItem = new CheckItem__c(
                RecordTypeId = recordTypeId,
                Sales_Region__c = 'Hisense USA',
                Parent_Response__c = 'Yes',
                Parent__c = checkItem.Id,
                Inspection_Type__c = 'Locale Inspection',
                Item_Type__c = 'Sampling Product Check',
                Question_Type__c = 'Yes/No',
                Description__c = 'TestRealteItem',
                Description_CN__c = '',
                Description_EN__c = '',
                HelpText__c = '',
                HelpTextCN__c = '',
                HelpTextEN__c = '',
                Enter_Choice__c = '',
                MaximumScore__c = '5',
                Conditional_Score_Has_File__c = '',
                Conditional_Yes_No_Has_File__c = '',
                Conditional_Score_Has_Comment__c = '',
                Conditional_Yes_No_Has_Comment__c = '',
                Conditional_Score_Has_Ticket__c = '',
                Conditional_Yes_No_Has_Ticket__c = '',
                Active__c = true,
                HasRelateQuestions__c = false,
                HasFile__c = true,
                File_Conditional_Type__c = 'Mandatory',
                HasComment__c = true,
                Comment_Conditional_Type__c = 'Mandatory',
                Automatic_Generation_Ticket__c = false,
                Ticket_Conditional_Type__c = '',
                OrderNumber__c = 2,
                Product_Line__c = 'All',
                Parent_Select__c = '2&3',
                Score_Symbol_Response__c = '>&!='
        );
        Insert realteItem;

        CheckItem__c realteItemDel = new CheckItem__c(
                RecordTypeId = recordTypeId,
                Sales_Region__c = 'Hisense USA',
                Parent_Response__c = 'Yes',
                Parent__c = checkItem.Id,
                Inspection_Type__c = 'Locale Inspection',
                Item_Type__c = 'Sampling Product Check',
                Question_Type__c = 'Yes/No',
                Description__c = 'TestRealteItemDel',
                Description_CN__c = '',
                Description_EN__c = '',
                HelpText__c = '',
                HelpTextCN__c = '',
                HelpTextEN__c = '',
                Enter_Choice__c = '',
                MaximumScore__c = '5',
                Conditional_Score_Has_File__c = '',
                Conditional_Yes_No_Has_File__c = '',
                Conditional_Score_Has_Comment__c = '',
                Conditional_Yes_No_Has_Comment__c = '',
                Conditional_Score_Has_Ticket__c = '',
                Conditional_Yes_No_Has_Ticket__c = '',
                Active__c = true,
                HasRelateQuestions__c = false,
                HasFile__c = false,
                File_Conditional_Type__c = '',
                HasComment__c = false,
                Comment_Conditional_Type__c = '',
                Automatic_Generation_Ticket__c = false,
                Ticket_Conditional_Type__c = '',
                OrderNumber__c = 1,
                Product_Line__c = 'All',
                Parent_Select__c = '2&3',
                Score_Symbol_Response__c = '>&!='
        );
        Insert realteItemDel;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Gridding__c grid = new Gridding__c();
        grid.Gridding_Code__c = 'TEST GUID';
        insert grid;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Code_Text__c = '90999';
        shop1.Grid__c = grid.id;
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        Insert shop1;

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = currentUser.Id;
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

        Inspection_Product_Item__c testDIRItem = new Inspection_Product_Item__c();
        testDIRItem.Inspection_Report__c = testDIR.Id;
        testDIRItem.Product_Line__c = 'TV';
        testDIRItem.Status__c = 'Start';
        Insert testDIRItem;

        CheckResult__c checkResult = new CheckResult__c();
        checkResult.CheckItem__c = checkItem.id;
        checkResult.InspectorDailyReport__c = testDIR.id;
        checkResult.Inspection_Product_Item__c = testDIRItem.id;
        checkResult.Response__c = 'Yes';
        checkResult.Comments__c = 'Comments';
        Insert checkResult;

        CheckResult__c checkResult1 = new CheckResult__c();
        checkResult1.CheckItem__c = checkItem1.id;
        checkResult1.InspectorDailyReport__c = testDIR.id;
        checkResult1.Inspection_Product_Item__c = testDIRItem.id;
        checkResult1.Response__c = 'Yes';
        checkResult1.Comments__c = 'Comments';
        Insert checkResult1;

        CheckResult__c checkResult2 = new CheckResult__c();
        checkResult2.CheckItem__c = checkItem2.id;
        checkResult2.InspectorDailyReport__c = testDIR.id;
        checkResult2.Inspection_Product_Item__c = testDIRItem.id;
        checkResult2.Response__c = 'Yes';
        Insert checkResult2;

        CheckResult__c checkResultRelate = new CheckResult__c();
        checkResultRelate.CheckItem__c = realteItem.id;
        checkResultRelate.InspectorDailyReport__c = testDIR.id;
        checkResultRelate.Inspection_Product_Item__c = testDIRItem.id;
        checkResultRelate.Response__c = 'Yes';
        checkResultRelate.Comments__c = 'Comments';
        Insert checkResultRelate;

        Store_Product_Line__c spl = new Store_Product_Line__c();
        spl.Store__c = shop1.Id;
        spl.Product_Line__c = 'TV';
        Insert spl;

        // checkitem 详情
        // String checkItemJson = '{"Sales_Region__c":"' + currentUser.Sales_Region__c + '","Inspection_Type__c":"Locale Inspection","Item_Type__c":"Speak With the Store Leader","Question_Type__c":"Yes/No","Description__c":"Test","MaximumScore__c":"5"}';
        String checkItemJson = JSON.serialize(checkItem);

        // checkResult 详情
        newCheckItemController.CheckResultData checkResultData = new newCheckItemController.CheckResultData();
        newCheckItemController.CheckResultData checkResultDataItem = new newCheckItemController.CheckResultData();
        checkResultDataItem.parent = checkResultRelate;
        checkResultData.parent = checkResult;
        List<newCheckItemController.CheckResultData> resultDataItem = new List<newCheckItemController.CheckResultData>();
        resultDataItem.add(checkResultDataItem);
        List<List<newCheckItemController.CheckResultData>> resultDataItems = new List<List<newCheckItemController.CheckResultData>>();
        resultDataItems.add(resultDataItem);
        checkResultData.children = resultDataItems;
        List<newCheckItemController.CheckResultData> checkResultDataList = new List<newCheckItemController.CheckResultData>();
        checkResultDataList.add(checkResultData);
        String checkResultJson = JSON.serialize(checkResultDataList);
        
        // 关联问题
        String relateList = '[{"id":"' + realteItem.id + '"}]';
        // 删除的关联问题
        String relateDelList = '[{"id":"' + realteItemDel.id + '"}]';

        ContentVersion contentVersion = new ContentVersion(
                                        Title = 'Penguins',
                                        PathOnClient = 'Penguins.jpg',
                                        VersionData = Blob.valueOf('Test Content'),
                                        IsMajorVersion = true
        );
        insert contentVersion;
        ContentVersion contentVersion1 = new ContentVersion(
                                        Title = 'Penguins1',
                                        PathOnClient = 'Penguins1.jpg',
                                        VersionData = Blob.valueOf('Test Content1'),
                                        IsMajorVersion = true
        );
        insert contentVersion1;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = checkItem.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        List<String> filesToDelete = new List<String>();
        filesToDelete.add(documents[0].Id);

        List<Object> newFiles = new List<Object>();
        Map<Object, Object> dMap = new Map<Object, Object>();
        dMap.put('name', 'name');
        dMap.put('fileBody', 'fileBody');
        newFiles.add(dMap);

        test.startTest();
        newCheckItemController.getSalesRegionInfo('');
        newCheckItemController.getCountry(recordTypeId);

        newCheckItemController.getInitData('','');
        newCheckItemController.getInitData(checkItem.id,'');

        newCheckItemController.getOrderExist('',checkItem.id,currentUser.Sales_Region__c);

        newCheckItemController.saveDate(checkItemJson, relateList, relateDelList);

        newCheckItemController.addCheckResult('Sampling Product Check', testDIR.Id, testDIRItem.Id, 'TV');

        newCheckItemController.checkInitStatus('Sampling Product Check', testDIRItem.Id);

        newCheckItemController.getcheckResultInitInfo('Sampling Product Check', testDIRItem.Id);

        newCheckItemController.saveCheckResult(checkResultJson);

        newCheckItemController.getCheckItemCheckNumber('Sampling Product Check',testDIRItem.Id + '', 'TV');

        newCheckItemController.getChannels(currentUser.Sales_Region__c, 'TV');

        newCheckItemController.getProductLines(currentUser.Sales_Region__c, 'TV');

        newCheckItemController.saveDateWithFiles(checkItemJson, relateList, relateDelList, filesToDelete, newFiles);

        newCheckItemController.getExistingFiles(checkItem.Id);

        newCheckItemController.gabige();

        test.stopTest();
    }
}