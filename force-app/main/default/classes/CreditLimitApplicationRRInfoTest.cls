@isTest
private class CreditLimitApplicationRRInfoTest {
   
    static testMethod void testMethod1() {
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'RR',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;
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

        Credit_Limit_Application__c creditLimit = new Credit_Limit_Application__c();
        creditLimit.Customer__c = acc1.Id;
        creditLimit.Payment_Method__c = '1';
        creditLimit.Approval_Status__c = 'Insurance Company Approved'; 
        creditLimit.Buyer_English_Address__c = 'Test';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c = '11111111';
        creditLimit.Approval_Date__c = Datetime.now();
        Database.insert(creditLimit);

      Credit_Limit_Application_RR_INFO__c info = new Credit_Limit_Application_RR_INFO__c();
        info.Audit_Node__c = '1';
        info.Audit_Opinion__c = '2';
        info.Audit_Person__c = '3';
        info.Audit_Status__c = '4';
        info.Audit_Time__c = '5';
        info.Credit_Limit_Id__c = creditLimit.id;
        insert info;
        CreditLimitApplicationRRInfoController.initData(creditLimit.Id);
        CreditLimitApplicationRRInfoController.syncData(creditLimit.Id);
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'RR',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;

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
      String json = '{"Success": "1", "ErrorMessage": "", "Data": [{"ApprovalStage": "限额申请", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-03 17:48:02", "ApprovalResult": "同意", "ApprovedLimit": "", "ApprovedTerm": ""}, {"ApprovalStage": "信保申请", "ApprovalStatus": "已提交已批复", "Approver": "", "ApprovalTime": "2023-02-06 15:10:15", "ApprovalResult": "", "ApprovedLimit": "3000000.00", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-15 14:08:30", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李伟", "ApprovalTime": "2023-02-15 14:13:29", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "易小兵", "ApprovalTime": "2023-02-16 06:09:58", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王云利", "ApprovalTime": "2023-02-16 07:55:22", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "胡剑涌", "ApprovalTime": "2023-02-16 08:52:38", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "常惠甜", "ApprovalTime": "2023-02-16 09:41:14", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李强", "ApprovalTime": "2023-02-17 13:45:51", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王艳凤", "ApprovalTime": "2023-02-21 00:00:35", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        Credit_Limit_Application__c creditLimit = new Credit_Limit_Application__c();
        creditLimit.Customer__c = acc1.Id;
        creditLimit.Payment_Method__c = '1';
        creditLimit.Approval_Status__c = 'Insurance Company Approved'; 
        creditLimit.Buyer_English_Address__c = 'Test';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c = '11111111';
        creditLimit.Approval_Date__c = Datetime.now();
        Database.insert(creditLimit);

        List<Credit_Limit_Application__c> creditList = [Select name,id from Credit_Limit_Application__c Where name =:creditLimit.name];
        CreditLimitApplicationRRInfoController.syncAuditInfoFromRR(creditLimit.name);
        CreditLimitApplicationRRInfoController.syncAuditInfoFromRRNoFuture(creditLimit.name);
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'RR',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;

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
      String json = '{"Success": "0", "ErrorMessage": "", "Data": [{"ApprovalStage": "限额申请", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-03 17:48:02", "ApprovalResult": "同意", "ApprovedLimit": "", "ApprovedTerm": ""}, {"ApprovalStage": "信保申请", "ApprovalStatus": "已提交已批复", "Approver": "", "ApprovalTime": "2023-02-06 15:10:15", "ApprovalResult": "", "ApprovedLimit": "3000000.00", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-15 14:08:30", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李伟", "ApprovalTime": "2023-02-15 14:13:29", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "易小兵", "ApprovalTime": "2023-02-16 06:09:58", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王云利", "ApprovalTime": "2023-02-16 07:55:22", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "胡剑涌", "ApprovalTime": "2023-02-16 08:52:38", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "常惠甜", "ApprovalTime": "2023-02-16 09:41:14", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李强", "ApprovalTime": "2023-02-17 13:45:51", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王艳凤", "ApprovalTime": "2023-02-21 00:00:35", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        Credit_Limit_Application__c creditLimit = new Credit_Limit_Application__c();
        creditLimit.Customer__c = acc1.Id;
        creditLimit.Payment_Method__c = '1';
        creditLimit.Approval_Status__c = 'Insurance Company Approved'; 
        creditLimit.Buyer_English_Address__c = 'Test';
        //creditLimit.Enterprise_internal_code__c = 'Test';
        creditLimit.Credit_Guarantee_Issuing_Bank_SWIFT__c = '11111111';
        creditLimit.Approval_Date__c = Datetime.now();
        Database.insert(creditLimit);
        CreditLimitApplicationRRInfoController.syncAuditInfoFromRR(creditLimit.name);
        CreditLimitApplicationRRInfoController.syncAuditInfoFromRRNoFuture(creditLimit.name);
        Test.stopTest();
    }
}