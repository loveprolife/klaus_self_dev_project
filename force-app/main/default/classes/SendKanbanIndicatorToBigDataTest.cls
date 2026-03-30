@isTest
private class SendKanbanIndicatorToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved',
            isGoFinApprove__c = 'fin_approved',
            Basic_Approval_Status__c = 'draft'
        );
        Database.insert(acc1);

        Shop__c shop = new Shop__c();
        shop.Account__c = acc1.Id;
        shop.Shop_Level__c = 'A';
        //shop.Grid__c = gird1.id;
        shop.City__c = '北京市';
        INSERT shop;

        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = acc1.Id;
        store.sales_region__c = 'Hisense Indonesia';
        insert store;

        User promoter = new User();
        promoter.Username = 'testPromoterUser12138@test004.com';
        promoter.lastname = 'testPromoterUser12138';
        promoter.alias = 'Promoter';
        promoter.email ='Promoter@test.com';
        promoter.emailencodingkey = 'UTF-8';
        promoter.languagelocalekey = 'zh_CN';
        promoter.LocaleSidKey = 'zh_CN';
        promoter.IsActive = true;
        promoter.ProfileId = [SELECT Id FROM profile WHERE Name = 'Indonesia Promoter'][0].Id;
        promoter.timezonesidkey ='Asia/Shanghai';
        promoter.Country = 'ID';
        promoter.sales_region__c = 'Hisense Indonesia';
        insert promoter;

        // Responsible_Person__c promoterRes = new Responsible_Person__c();
        // promoterRes.Shop_Name__c = store.Id;
        // promoterRes.Principal__c = promoter.Id;
        // promoterRes.RecordType__c = '促销员';
        // //promoterRes.Promoter_Attendance_Rule__c = par.Id;
        // insert promoterRes;

        Daily_Inspection_Report__c inspectionReport = new Daily_Inspection_Report__c();
        inspectionReport.Report_Date__c = System.today();
        inspectionReport.OwnerId = promoter.Id;
        insert inspectionReport;

        Ticket__c ticket = new Ticket__c();
        ticket.Subject__c = 'TicketTriggerHandlerTest Ticket';
        ticket.Description__c = 'TicketTriggerHandlerTest Ticket';
        ticket.Department__c = 'Marketing';
        insert ticket;


        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2030-05-10 00:00:00"}');
		SendKanbanIndicatorToBigData.adoPost();
        SendCustomerToBigData.adoPost();
        SendPromotersToBigData.adoPost();
        SendDailyInspectionReportToBigData.adoPost();
        SendTicketToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendKanbanIndicatorToBigData.adoPost();
        SendCustomerToBigData.adoPost();
        SendPromotersToBigData.adoPost();
        SendDailyInspectionReportToBigData.adoPost();
        SendTicketToBigData.adoPost();
        Test.stopTest();
    }
}