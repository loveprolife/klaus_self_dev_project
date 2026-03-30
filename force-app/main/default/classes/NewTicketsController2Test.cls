@isTest
public class NewTicketsController2Test {
    @isTest
    public static void testNewTicketsController2() { 

        User promoter = new User();
        promoter.Username = 'testPromoterUser1213823@test004.com';
        promoter.lastname = 'promoter';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Chile Promoter%'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Sales_Region__c = 'Hisense Chile';
        insert promoter;

        User marketingUser = new User();
        marketingUser.Username = 'marketingUser12138@test004.com';
        marketingUser.lastname = 'marketingUser12138';
        marketingUser.alias = 'market';
        marketingUser.email ='marketingUser@test.com';
        marketingUser.emailencodingkey = 'UTF-8';
        marketingUser.languagelocalekey = 'zh_CN';
        marketingUser.LocaleSidKey = 'zh_CN';
        marketingUser.IsActive = true;
        marketingUser.ProfileId = [SELECT Id FROM profile WHERE Name LIKE '%Chile store manager%'][0].Id;
        marketingUser.timezonesidkey ='Asia/Shanghai';
        marketingUser.Sales_Region__c = 'Hisense Indonesia';
        marketingUser.Department__c = 'Marketing';
        insert marketingUser;

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
        
        Shop__c shop1 = new Shop__c();
        shop1.Sales_Region__c = 'Hisense Indonesia';
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'CX签到测试店';
        INSERT shop1;
               
        Promoter_Daily_Report__c testPDR = new Promoter_Daily_Report__c();
        testPDR.Shop__c = shop1.Id;
        testPDR.OwnerId = promoter.Id;
        insert testPDR;
        //AssignedTo__c testAT = new AssignedTo__c();
        
        Ticket__c tik = new Ticket__c();
        tik.PromoterDailyReport__c = testPDR.id;
        tik.Status__c = 'Open';
        insert tik;
        
        Ticket__c tik2 = new Ticket__c();
        tik2.PromoterDailyReport__c = testPDR.id;
        tik2.Status__c = 'Open';
        
        Map<String,Ticket__c> mapStr = new Map<String,Ticket__c>();
        mapStr.put('tik',tik);
        
        tik.Status__c = 'Closed';
        
        List<Ticket__c> ListTik = new List<Ticket__c>();
        ListTik.add(tik2);
        
        String recordListJson = JSON.serialize(ListTik);

        String recordJson = JSON.serialize(tik2);
        
        String fileMapJson = JSON.serialize(mapStr);
        
        String[] arry = new String[]{};
        arry.add(tik.Id);

        Ticket_Auto_Assigned__c taa = new Ticket_Auto_Assigned__c();
        taa.Assigned_To__c = promoter.Id;
        taa.SBU__c = 'Hisense Indonesia';
        taa.Category__c = 'Stock';
        taa.Product_Line__c = 'TV';
        insert taa;

        Ticket_Auto_Assigned__c taa1 = new Ticket_Auto_Assigned__c();
        taa1.Assigned_To__c = promoter.Id;
        taa1.SBU__c = 'Hisense Indonesia';
        taa1.Category__c = 'Stock';
        insert taa1;

        List<Map<String,Object>> filesInfo = new List<Map<String,Object>>();
        Map<String,Object> fileMap = new Map<String,Object>();
        fileMap.put('iconName', 'doctype:txt');
        fileMap.put('isImage', 'false');
        fileMap.put('base64', 'data:text/plain;base64,5a2X5q6177yaDQoJ6KGo77yaVGlja2V0CQlTQlVfX2PvvIxTYWxlc19SZWdpb25fTG9va3VwX19jDQoJCQl');
        filesInfo.add(fileMap);
        
        Test.startTest();

        System.runAs(promoter) {
            //string s =  Json.serialize(list);
            NewTicketsController2.getInitData(tik.id);
            NewTicketsController2.getInitData('');
            NewTicketsController2.saveData(recordListJson,tik.id,fileMapJson,arry);


            NewTicketsController2.newTicketGetInitData();
            NewTicketsController2.newTicketSaveData(recordListJson,fileMapJson);

            tik2.DueDate__c = date.newinstance(2023, 5, 13);
            recordListJson = JSON.serialize(ListTik);
            NewTicketsController2.newTicketSaveData(recordListJson,fileMapJson);

            tik2.Department__c = 'Sales';
            recordListJson = JSON.serialize(ListTik);
            NewTicketsController2.newTicketSaveData(recordListJson,fileMapJson);
            NewTicketsController2.handlerRemove();

            NewTicketsController2.getDepartmentUsers('test');
            NewTicketsController2.newTicketSaveData2(recordJson,filesInfo);
            NewTicketsController2.checkDepartment(ListTik);
            
            NewTicketsController2.autoAssigned('Hisense Indonesia', 'Stock', '');
            NewTicketsController2.autoAssigned('Hisense Indonesia', 'Stock', 'TV');
        }

        Test.stopTest();
    }
}