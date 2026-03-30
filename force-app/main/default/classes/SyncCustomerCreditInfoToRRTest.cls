@isTest
private class SyncCustomerCreditInfoToRRTest {
    static testMethod void testMethod1() {
        system.test.startTest();
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'RR',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;
        system.Test.setMock(HttpCalloutMock.class, new SyncCustomerCreditInfoToRR_Mock());

        // 数据
        Account acc = new Account(
                            Name = 'testname');
        insert acc;      
        Credit_Limit_Application__c newCredit = new Credit_Limit_Application__c(
                                                Payment_Method__c = '1',
                                                Buyer_English_Address__c = 'testtheaddress',
                                                //Enterprise_internal_code__c = 'testcode',
                                                Credit_Guarantee_Issuing_Bank_SWIFT__c='A0000111',
                                                Customer__c = acc.Id,
                                                Insurance_Company__c = '中信保');
        insert newCredit;
        //ProcessSteps newsteps = new ProcessSteps();
        // AttachedContentDocuments NewFileAttachmentInput = new AttachedContentDocuments(
        //                                      );

        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = newCredit.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        //
        SyncCustomerCreditInfoToRR.postInfomation(newCredit.Id);
        system.Test.stopTest();
    }
    static testMethod void testMethod2() {
        Test.startTest();
        Interface_Url__c newurl = new Interface_Url__c(
                                    Name = 'RR',
                                    Basic_Url__c ='testbasic',
                                    User_Name__c = 'username',
                                    Password__c = 'password');
        insert newurl;
        Account acc = new Account(
                            Name = 'testname');
        insert acc;      
        Credit_Limit_Application__c newCredit = new Credit_Limit_Application__c(
                                                Payment_Method__c = '1',
                                                Buyer_English_Address__c = 'testtheaddress',
                                                //Enterprise_internal_code__c = 'testcode',
                                                Credit_Guarantee_Issuing_Bank_SWIFT__c='A0000111',
                                                Customer__c = acc.Id,
                                                Insurance_Company__c = '中信保');
        insert newCredit;
        SyncCustomerCreditInfoToRR.postInfomation(newCredit.Id);
        Test.stopTest();
    }

    static testMethod void testMethod3() {
        Test.startTest();
        Interface_Url__c newurl = new Interface_Url__c(
            Name = 'RR',
            Basic_Url__c ='testbasic',
            User_Name__c = 'username',
            Password__c = 'password');
        insert newurl;
        Account acc = new Account(
            Name = 'testname');
        insert acc;      
        Credit_Limit_Application__c newCredit = new Credit_Limit_Application__c(
                                Payment_Method__c = '1',
                                Buyer_English_Address__c = 'testtheaddress',
                                //Enterprise_internal_code__c = 'testcode',
                                Credit_Guarantee_Issuing_Bank_SWIFT__c='A0000111',
                                Customer__c = acc.Id,
                                Insurance_Company__c = '中信保');
        insert newCredit;
        String json = '{"IsSuccess": "","FailReason": ""}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SyncCustomerCreditInfoToRR.postInfomation(newCredit.Id);
        Test.stopTest();
    }
}