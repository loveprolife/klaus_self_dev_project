@isTest
public class ImageUploaderHandlerTest {
    static testMethod void methodName(){
        Account acc = new Account(
                            Name = 'testname');
        insert acc;      
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
        Test.startTest();
        ImageUploaderHandler.saveFile(newCredit.id,'Penguins','Test Content');
        ImageUploaderHandler.setImageUrl(newCredit.id);
        ImageUploaderHandler.deleteFiles(newCredit.id);
        Test.stopTest();
        
    }
}