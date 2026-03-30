/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 04-07-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
@isTest
public class CreateNewInspectionControllerTest {
    @TestSetup
    static void makeData(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        
        User user3 = new User(alias = 'Appl2', email='test344@noemail.com',
        emailencodingkey='UTF-8', lastname='Test344', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test344@noemail.com');
        INSERT user3;
        //user3.UserRoleId = testRole3.Id;
        //update user3;
        
        User user2 = new User(alias = 'Appl1', email='test155@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing155', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles',ManagerId = user3.Id, username='test155@noemail.com');
        INSERT user2;
        //user2.UserRoleId = testRole2.Id;
        //update user2;
        
        Id profileId2 = [SELECT Id,Name FROM profile where PermissionsModifyAllData=true AND PermissionsViewAllProfiles=true ].GET(0).Id;
        User user1 = new User(alias = '巡店员', email='test777@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing777', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId2, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles',ManagerId = user2.Id, username='test777@noemail.com');
        INSERT user1;
        //user1.UserRoleId = testRole1.Id;
        //update user1;
    }

	/*@isTest
    static void testMethod1(){
        //UserRole testRole1 = [select id from UserRole where DeveloperName Like 'Indonesia%' AND DeveloperName Like '%Training_Manager%' Limit 1];
        //UserRole testRole2 = [select id from UserRole where DeveloperName Like 'Indonesia%' AND DeveloperName Like '%Retail_Manager%' Limit 1];
        //UserRole testRole3 = [select id from UserRole where DeveloperName Like 'Indonesia%' AND DeveloperName Like '%Retail_Director%' Limit 1];
        
        

        //ProcessDefinition testPDF = new ProcessInstanceWorkitem();
        //testPDF.Name = '测试';
        //Insert testPDF;
        
        
        //ProcessInstanceWorkitem testProcessInstanceWorkitem = new ProcessInstanceWorkitem();
        //testProcessInstanceWorkitem.ProcessInstanceId.TargetObjectId = user2.Id;
        //Insert testProcessInstanceWorkitem;
        
        //Id floorwalkerPID = [SELECT Id From Profile Where Name = :INSPECTION_PROFILE].Id;
        
        //Inspection_Shop_Task__c istTest = new Inspection_Shop_Task__c();
        //istTest.Shop__c = shop1.id;
		//istTest.Inspection_Date__c = '2023-07-03';
		//istTest.Result__c = '在交涉';
        //istTest.Inspection_Target__c = '1';
               
        test.startTest();
        system.runAs(user1){
        CreateNewInspectionController.getData(ispTest.Id);
        CreateNewInspectionController.getData('');
        CreateNewInspectionController.getRelatedUserId(1);
        CreateNewInspectionController.getRelatedUserId(2);
        CreateNewInspectionController.getCurrentUserRole(user2.Id);
        CreateNewInspectionController.getCurrentUserRole(user3.Id);
        CreateNewInspectionController.haveRepeatingData('2023','7',System.UserInfo.getUserId());
        CreateNewInspectionController.haveRepeatingData('2019','7',System.UserInfo.getUserId());
        CreateNewInspectionController.haveRepeatingData('2025','9',System.UserInfo.getUserId());
        CreateNewInspectionController.haveRepeatingData('2023','7',null);
        //CreateNewInspectionController.haveRepeatingData('2023','7','JASdsadijE738HU');
        CreateNewInspectionController.getResponsPerson(user1.Id);
        CreateNewInspectionController.getReport(ist.Id);
        CreateNewInspectionController.saveData(ispTest,taskMapDataJSON,'',true,ispTest.Inspection_Year__c,ispTest.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);
        CreateNewInspectionController.saveData(ispTest,taskMapDataJSON,ispTest.Id,true,ispTest.Inspection_Year__c,ispTest.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);
        CreateNewInspectionController.saveData(ispTest2,taskMapDataJSON,ispTest2.Id,true,ispTest2.Inspection_Year__c,ispTest2.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);    
        ispTest.Approver1__c = user2.id;
        ispTest.Approver2__c = user3.id;
        update ispTest;
        CreateNewInspectionController.approvalSubmit(ispTest.id);
        
        ProcessInstanceWorkitem testPIW = [Select id,ProcessInstance.TargetObjectId From ProcessInstanceWorkitem Where ProcessInstance.TargetObjectId != null Limit 1];
        System.debug('--------------------'+testPIW);
        CreateNewInspectionController.approvalProcess(testPIW.ProcessInstance.TargetObjectId,'Approve',User2.id,null);
        //CreateNewInspectionController.approvalProcess('1', '提交', User2.id);
        //CreateNewInspectionController.filterFloorwalker(User2.username);
        }
        test.stopTest();
    }
    */

  //   @IsTest
  //   static void test(){
  //       User user1 =[select id,lastname from  User where lastname ='Testing777'].get(0);
  //       User user2 =[select id,lastname from  User where lastname ='Testing155'].get(0);
  //       User user3 =[select id,lastname from  User where lastname ='Test344'].get(0);
  //       String taskMapDataJSON = '{"a1c0T000000Oe1ZQAS2023-7-03NEW": {"Id": "a1s0T000000Y3P7QAK","Shop__c":"a1c0T000000Oe1ZQAS","Inspection_Date__c": "2022-02-14","Result__c": "在交涉","Inspection_Target__c": "1","Remark__c": "1","Inspection_Plan__c": "a1d0T000000ex1MQAQ","Status__c": "已到访","Daily_Inspection_Report__c": "a1y0T000000IzOxQAK"}}';

  //       Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
  //       ispTest.Inspection_Year__c = String.valueOf(System.today().year());
  //       ispTest.Inspection_Month__c = String.valueOf(System.today().month());
  //       ispTest.OwnerId = user1.Id;
  //       INSERT ispTest;
        
  //       Inspection_Shop_Plan__c ispTest2 = new Inspection_Shop_Plan__c();
  //       ispTest2.Inspection_Year__c = String.valueOf(2025);
  //       ispTest2.Inspection_Month__c = String.valueOf(8);
  //       ispTest2.OwnerId = user1.Id;
  //       //INSERT ispTest2;

  //       Account acc = new Account();
  //       acc.Name = 'test';
  //       INSERT acc;
                
  //       Shop__c shop1 = new Shop__c();
  //       shop1.Account__c = acc.Id;
  //       shop1.Shop_Level__c = 'A';
  //       shop1.Name = 'Homeplus本石町店';
  //       INSERT shop1;
        
  //       Shop__c shop2 = new Shop__c();
  //       shop2.Account__c = acc.Id;
  //       shop2.Shop_Level__c = 'A';
  //       shop2.Name = '本石町店';
  //       INSERT shop2;

  //       Responsible_Person__c rp = new Responsible_Person__c();
  //       rp.Principal__c = user1.Id;
  //       rp.RecordType__c = '巡店员';
  //       rp.Shop_Name__c = shop1.Id;
  //       INSERT rp; 
        
  //       Date date1 = Date.today();
  //       Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
  //       ist.Shop__c = shop1.Id;
  //       ist.ExternalId__c = acc.Id;
  //       ist.OwnerId = user1.Id;
  //       ist.Status__c = '已到访';
  //       ist.Inspection_Plan__c = ispTest.id;
  //       ist.Inspection_Date__c = date1;
  //       INSERT ist;
        
  //       Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
  //       ist2.Shop__c = shop2.Id;
  //       ist2.ExternalId__c = acc.Id;
  //       ist2.OwnerId = user1.Id;
  //       ist2.Status__c = '已到访';
  //       ist2.Inspection_Plan__c = ispTest.id;
  //       ist2.Inspection_Date__c = date1;
  //       INSERT ist2;
        
  //       Sampling_Inspection__c si = new Sampling_Inspection__c();
  //       si.IsNew__c = true;
  //       si.ExternalID__c = acc.Id;
  //       si.Inspection_Shop_Task__c = ist.Id;
  //       //si.Sample_Images__r = testSImg.id;
  //       INSERT si;

  //       Sample_Images__c testSImg = new Sample_Images__c();
  //       testSImg.ReRe__c = '测试';
  //       testSImg.Sample_Images__c = 'https://hisenseint--c.documentforce.com/sfc/dist/version/download/?oid=00D0o000001BdQ5&ids=0680o00000bEBLv&d=%2Fa%2F0o0000006YPL%2FUiS0qwkDdDtVnsfC2JHOEuOi.YTBLWxy3oIlTK83CJk&asPdf=false';
		// testSImg.Sampling_Inspection__c = si.id;
  //       Insert testSImg;
  //       Test.startTest();
  //       System.runAs(user1){
  //           CreateNewInspectionController.getData(ispTest.Id);
  //       CreateNewInspectionController.getData('');
  //       CreateNewInspectionController.getRelatedUserId(1);
  //       CreateNewInspectionController.getRelatedUserId(2);
  //       CreateNewInspectionController.getCurrentUserRole(user2.Id);
  //       CreateNewInspectionController.getCurrentUserRole(user3.Id);
  //       // CreateNewInspectionController.haveRepeatingData('2023','7',System.UserInfo.getUserId());
  //       // CreateNewInspectionController.haveRepeatingData('2019','7',System.UserInfo.getUserId());
  //       // CreateNewInspectionController.haveRepeatingData('2025','9',System.UserInfo.getUserId());
  //       // CreateNewInspectionController.haveRepeatingData('2023','7',null);
  //       CreateNewInspectionController.haveRepeatingData('2023','7',System.UserInfo.getUserId(), '', '');
  //       CreateNewInspectionController.haveRepeatingData('2019','7',System.UserInfo.getUserId(), '', '');
  //       CreateNewInspectionController.haveRepeatingData('2025','9',System.UserInfo.getUserId(), '', '');
  //       CreateNewInspectionController.haveRepeatingData('2023','7',null, '', '');
  //       //CreateNewInspectionController.haveRepeatingData('2023','7','JASdsadijE738HU');
  //       CreateNewInspectionController.getResponsPerson(user1.Id);
  //       CreateNewInspectionController.getReport(ist.Id);
  //       CreateNewInspectionController.saveData(ispTest,taskMapDataJSON,'',true,ispTest.Inspection_Year__c,ispTest.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);
  //       CreateNewInspectionController.saveData(ispTest,taskMapDataJSON,ispTest.Id,true,ispTest.Inspection_Year__c,ispTest.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);
  //       CreateNewInspectionController.saveData(ispTest2,taskMapDataJSON,ispTest2.Id,true,ispTest2.Inspection_Year__c,ispTest2.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);    
  //       ispTest.Approver1__c = user2.id;
  //       ispTest.Approver2__c = user3.id;
  //       update ispTest;
  //       CreateNewInspectionController.approvalSubmit(ispTest.id);
        
  //       ProcessInstanceWorkitem testPIW = [Select id,ProcessInstance.TargetObjectId From ProcessInstanceWorkitem Where ProcessInstance.TargetObjectId != null Limit 1];
  //       System.debug('--------------------'+testPIW);
  //       CreateNewInspectionController.approvalProcess(testPIW.ProcessInstance.TargetObjectId,'Approve',User2.id,null);
  //       //CreateNewInspectionController.approvalProcess('1', '提交', User2.id);
  //       //CreateNewInspectionController.filterFloorwalker(User2.username);
  //       }
  //       Test.stopTest();
        
  //   }


    @IsTest
    static void testForCPULimit1() {
        User user1 =[select id,lastname from  User where lastname ='Testing777'].get(0);
        User user2 =[select id,lastname from  User where lastname ='Testing155'].get(0);
        User user3 =[select id,lastname from  User where lastname ='Test344'].get(0);
        String taskMapDataJSON = '{"a1c0T000000Oe1ZQAS2023-7-03NEW": {"Id": "a1s0T000000Y3P7QAK","Shop__c":"a1c0T000000Oe1ZQAS","Inspection_Date__c": "2022-02-14","Result__c": "在交涉","Inspection_Target__c": "1","Remark__c": "1","Inspection_Plan__c": "a1d0T000000ex1MQAQ","Status__c": "已到访","Daily_Inspection_Report__c": "a1y0T000000IzOxQAK"}}';

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.Inspection_Year__c = String.valueOf(System.today().year());
        ispTest.Inspection_Month__c = String.valueOf(System.today().month());
        ispTest.OwnerId = user1.Id;
        INSERT ispTest;
        
        Inspection_Shop_Plan__c ispTest2 = new Inspection_Shop_Plan__c();
        ispTest2.Inspection_Year__c = String.valueOf(2024);
        ispTest2.Inspection_Month__c = String.valueOf(8);
        ispTest2.OwnerId = user1.Id;
        //INSERT ispTest2;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Sales_Region__c = 'Hisense Indonesia';
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        INSERT shop1;
        
        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Sales_Region__c = 'Hisense Indonesia';
        shop2.Shop_Level__c = 'A';
        shop2.Name = '本石町店';
        INSERT shop2;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop1.Id;
        INSERT rp; 
        
        Date date1 = Date.today();
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        ist.Inspection_Plan__c = ispTest.id;
        ist.Inspection_Date__c = date1;
        INSERT ist;
        
        Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
        ist2.Shop__c = shop2.Id;
        ist2.ExternalId__c = acc.Id;
        ist2.OwnerId = user1.Id;
        ist2.Status__c = '已到访';
        ist2.Inspection_Plan__c = ispTest.id;
        ist2.Inspection_Date__c = date1;
        INSERT ist2;
        
        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        //si.Sample_Images__r = testSImg.id;
        INSERT si;

        Sample_Images__c testSImg = new Sample_Images__c();
        testSImg.ReRe__c = '测试';
        testSImg.Sample_Images__c = 'https://hisenseint--c.documentforce.com/sfc/dist/version/download/?oid=00D0o000001BdQ5&ids=0680o00000bEBLv&d=%2Fa%2F0o0000006YPL%2FUiS0qwkDdDtVnsfC2JHOEuOi.YTBLWxy3oIlTK83CJk&asPdf=false';
        testSImg.Sampling_Inspection__c = si.id;
        Insert testSImg;
        Test.startTest();
        System.runAs(user1){
            CreateNewInspectionController.getData(ispTest.Id, '', '', '', '', '');
        CreateNewInspectionController.getData('', '', '', '', '', '');
       
       
        }
        Test.stopTest();
        
    }
    @IsTest
    static void testForCPULimit11() {
        User user1 =[select id,lastname from  User where lastname ='Testing777'].get(0);
        User user2 =[select id,lastname from  User where lastname ='Testing155'].get(0);
        User user3 =[select id,lastname from  User where lastname ='Test344'].get(0);
        String taskMapDataJSON = '{"a1c0T000000Oe1ZQAS2023-7-03NEW": {"Id": "a1s0T000000Y3P7QAK","Shop__c":"a1c0T000000Oe1ZQAS","Inspection_Date__c": "2022-02-14","Result__c": "在交涉","Inspection_Target__c": "1","Remark__c": "1","Inspection_Plan__c": "a1d0T000000ex1MQAQ","Status__c": "已到访","Daily_Inspection_Report__c": "a1y0T000000IzOxQAK"}}';

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.Inspection_Year__c = String.valueOf(System.today().year());
        ispTest.Inspection_Month__c = String.valueOf(System.today().month());
        ispTest.OwnerId = user1.Id;
        INSERT ispTest;
        
        Inspection_Shop_Plan__c ispTest2 = new Inspection_Shop_Plan__c();
        ispTest2.Inspection_Year__c = String.valueOf(2025);
        ispTest2.Inspection_Month__c = String.valueOf(8);
        ispTest2.OwnerId = user1.Id;
        //INSERT ispTest2;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Sales_Region__c = 'Hisense Indonesia';
        shop1.Name = 'Homeplus本石町店';
        INSERT shop1;
        
        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Shop_Level__c = 'A';
        shop2.Sales_Region__c = 'Hisense Indonesia';
        shop2.Name = '本石町店';
        INSERT shop2;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop1.Id;
        INSERT rp; 
        
        Date date1 = Date.today();
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        ist.Inspection_Plan__c = ispTest.id;
        ist.Inspection_Date__c = date1;
        INSERT ist;
        
        Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
        ist2.Shop__c = shop2.Id;
        ist2.ExternalId__c = acc.Id;
        ist2.OwnerId = user1.Id;
        ist2.Status__c = '已到访';
        ist2.Inspection_Plan__c = ispTest.id;
        ist2.Inspection_Date__c = date1;
        INSERT ist2;
        
        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        //si.Sample_Images__r = testSImg.id;
        INSERT si;

        Sample_Images__c testSImg = new Sample_Images__c();
        testSImg.ReRe__c = '测试';
        testSImg.Sample_Images__c = 'https://hisenseint--c.documentforce.com/sfc/dist/version/download/?oid=00D0o000001BdQ5&ids=0680o00000bEBLv&d=%2Fa%2F0o0000006YPL%2FUiS0qwkDdDtVnsfC2JHOEuOi.YTBLWxy3oIlTK83CJk&asPdf=false';
        testSImg.Sampling_Inspection__c = si.id;
        Insert testSImg;
        Test.startTest();
        System.runAs(user1){
        CreateNewInspectionController.getRelatedUserId(1);
        CreateNewInspectionController.getRelatedUserId(2);
       
        }
        Test.stopTest();
        
    }

    @IsTest
    static void testForCPULimit2() {
        User user1 =[select id,lastname from  User where lastname ='Testing777'].get(0);
        User user2 =[select id,lastname from  User where lastname ='Testing155'].get(0);
        User user3 =[select id,lastname from  User where lastname ='Test344'].get(0);
        String taskMapDataJSON = '{"a1c0T000000Oe1ZQAS2023-7-03NEW": {"Id": "a1s0T000000Y3P7QAK","Shop__c":"a1c0T000000Oe1ZQAS","Inspection_Date__c": "2022-02-14","Result__c": "在交涉","Inspection_Target__c": "1","Remark__c": "1","Inspection_Plan__c": "a1d0T000000ex1MQAQ","Status__c": "已到访","Daily_Inspection_Report__c": "a1y0T000000IzOxQAK"}}';

        Sales_Region__c sr = new Sales_Region__c();
        sr.Name = 'Hisense Indonesia';
        INSERT sr;
        
        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.Inspection_Year__c = String.valueOf(System.today().year());
        ispTest.Inspection_Month__c = String.valueOf(System.today().month());
        ispTest.OwnerId = user1.Id;
        INSERT ispTest;
        
        Inspection_Shop_Plan__c ispTest2 = new Inspection_Shop_Plan__c();
        ispTest2.Inspection_Year__c = String.valueOf(2025);
        ispTest2.Inspection_Month__c = String.valueOf(8);
        ispTest2.OwnerId = user1.Id;
        //INSERT ispTest2;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'Homeplus本石町店';
        shop1.Sales_Region__c = 'Hisense Indonesia';
        shop1.Sales_Region_Lookup__c = sr.Id;
        INSERT shop1;
        
        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Shop_Level__c = 'A';
        shop2.Name = '本石町店';
        shop2.Sales_Region__c = 'Hisense Indonesia';
        shop2.Sales_Region_Lookup__c = sr.Id;
        INSERT shop2;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop1.Id;
        INSERT rp; 
        
        Date date1 = Date.today();
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        ist.Inspection_Plan__c = ispTest.id;
        ist.Inspection_Date__c = date1;
        INSERT ist;
        
        Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
        ist2.Shop__c = shop2.Id;
        ist2.ExternalId__c = acc.Id;
        ist2.OwnerId = user1.Id;
        ist2.Status__c = '已到访';
        ist2.Inspection_Plan__c = ispTest.id;
        ist2.Inspection_Date__c = date1;
        INSERT ist2;
        
        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        //si.Sample_Images__r = testSImg.id;
        INSERT si;

        Sample_Images__c testSImg = new Sample_Images__c();
        testSImg.ReRe__c = '测试';
        testSImg.Sample_Images__c = 'https://hisenseint--c.documentforce.com/sfc/dist/version/download/?oid=00D0o000001BdQ5&ids=0680o00000bEBLv&d=%2Fa%2F0o0000006YPL%2FUiS0qwkDdDtVnsfC2JHOEuOi.YTBLWxy3oIlTK83CJk&asPdf=false';
        testSImg.Sampling_Inspection__c = si.id;
        Insert testSImg;


        // 字典表
        Dictionary__c dt = new Dictionary__c();
        dt.Sales_Region__c = sr.Id;
        dt.Store_Level__c = 'A';
        dt.Overdue__c = 1;
        dt.Type__c = 'Inspection Plan';
        Insert dt;

        Test.startTest();
        System.runAs(user1){
            
        CreateNewInspectionController.saveNote(ist);
        CreateNewInspectionController.getNoteByTaskId(ist.Id);

        CreateNewInspectionController.getCurrentUserRole(user2.Id);
        CreateNewInspectionController.getCurrentUserRole(user3.Id);
     
        CreateNewInspectionController.haveRepeatingData('2023','7',System.UserInfo.getUserId(), '', '', '', '', '', '');
        CreateNewInspectionController.haveRepeatingData('2019','7',System.UserInfo.getUserId(), '', '', '', '', '', '');
        CreateNewInspectionController.haveRepeatingData('2025','12',System.UserInfo.getUserId(), '', '', '', '', '', '');

        CreateNewInspectionController.addPlanTask(shop1.Id, '2025-07-22', ispTest.id, user1.id);
        CreateNewInspectionController.deleteRecord(ist.Id);
        
        //CreateNewInspectionController.approvalProcess('1', '提交', User2.id);
        //CreateNewInspectionController.filterFloorwalker(User2.username);
        }
        Test.stopTest();
        
    }
    @IsTest
    static void testForCPULimit3() {
        User user1 =[select id,lastname from  User where lastname ='Testing777'].get(0);
        User user2 =[select id,lastname from  User where lastname ='Testing155'].get(0);
        User user3 =[select id,lastname from  User where lastname ='Test344'].get(0);
        String taskMapDataJSON = '{"a1c0T000000Oe1ZQAS2023-7-03NEW": {"Id": "a1s0T000000Y3P7QAK","Shop__c":"a1c0T000000Oe1ZQAS","Inspection_Date__c": "2022-02-14","Result__c": "在交涉","Inspection_Target__c": "1","Remark__c": "1","Inspection_Plan__c": "a1d0T000000ex1MQAQ","Status__c": "已到访","Daily_Inspection_Report__c": "a1y0T000000IzOxQAK"}}';

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.Inspection_Year__c = String.valueOf(System.today().year());
        ispTest.Inspection_Month__c = String.valueOf(System.today().month());
        ispTest.OwnerId = user1.Id;
        INSERT ispTest;
        
        Inspection_Shop_Plan__c ispTest2 = new Inspection_Shop_Plan__c();
        ispTest2.Inspection_Year__c = String.valueOf(2025);
        ispTest2.Inspection_Month__c = String.valueOf(8);
        ispTest2.OwnerId = user1.Id;
        //INSERT ispTest2;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Sales_Region__c = 'Hisense Indonesia';
        shop1.Name = 'Homeplus本石町店';
        INSERT shop1;
        
        Shop__c shop2 = new Shop__c();
        shop2.Account__c = acc.Id;
        shop2.Shop_Level__c = 'A';
        shop2.Sales_Region__c = 'Hisense Indonesia';
        shop2.Name = '本石町店';
        INSERT shop2;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '巡店员';
        rp.Shop_Name__c = shop1.Id;
        INSERT rp; 
        
        Date date1 = Date.today();
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.Shop__c = shop1.Id;
        ist.ExternalId__c = acc.Id;
        ist.OwnerId = user1.Id;
        ist.Status__c = '已到访';
        ist.Inspection_Plan__c = ispTest.id;
        ist.Inspection_Date__c = date1;
        INSERT ist;
        
        Inspection_Shop_Task__c ist2 = new Inspection_Shop_Task__c();
        ist2.Shop__c = shop2.Id;
        ist2.ExternalId__c = acc.Id;
        ist2.OwnerId = user1.Id;
        ist2.Status__c = '已到访';
        ist2.Inspection_Plan__c = ispTest.id;
        ist2.Inspection_Date__c = date1;
        INSERT ist2;
        
        Sampling_Inspection__c si = new Sampling_Inspection__c();
        si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        si.Inspection_Shop_Task__c = ist.Id;
        //si.Sample_Images__r = testSImg.id;
        INSERT si;

        Sample_Images__c testSImg = new Sample_Images__c();
        testSImg.ReRe__c = '测试';
        testSImg.Sample_Images__c = 'https://hisenseint--c.documentforce.com/sfc/dist/version/download/?oid=00D0o000001BdQ5&ids=0680o00000bEBLv&d=%2Fa%2F0o0000006YPL%2FUiS0qwkDdDtVnsfC2JHOEuOi.YTBLWxy3oIlTK83CJk&asPdf=false';
        testSImg.Sampling_Inspection__c = si.id;
        Insert testSImg;
        Test.startTest();
        System.runAs(user1){
           CreateNewInspectionController.haveRepeatingData('2023','7',null, '', '', '', '', '', '');
        CreateNewInspectionController.getResponsPerson(user1.Id);
        CreateNewInspectionController.getReport(ist.Id);
        CreateNewInspectionController.saveData(ispTest,taskMapDataJSON,'',true,ispTest.Inspection_Year__c,ispTest.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);
        CreateNewInspectionController.saveData(ispTest,taskMapDataJSON,ispTest.Id,true,ispTest.Inspection_Year__c,ispTest.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);
        CreateNewInspectionController.saveData(ispTest2,taskMapDataJSON,ispTest2.Id,true,ispTest2.Inspection_Year__c,ispTest2.Inspection_Month__c,System.UserInfo.getUserId(),User2.id,User3.Id);    
        ispTest.Approver1__c = user2.id;
        ispTest.Approver2__c = user3.id;
        update ispTest;
        CreateNewInspectionController.approvalSubmit(ispTest.id);
        
        ProcessInstanceWorkitem testPIW = [Select id,ProcessInstance.TargetObjectId From ProcessInstanceWorkitem Where ProcessInstance.TargetObjectId != null Limit 1];
        System.debug('--------------------'+testPIW);
        CreateNewInspectionController.approvalProcess(testPIW.ProcessInstance.TargetObjectId,'Approve',User2.id,null);
        }
        Test.stopTest();
        
    }
}