@isTest
public with sharing class TrainingDocumentControllerTest{
    static testMethod void testMethod1(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='TrainingDocumentControllerTest@noemail.com',
        emailencodingkey='UTF-8', lastname='TrainingDocumentControllerTest', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId,country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='TrainingDocumentControllerTest@noemail.com',Sales_Region__c='Hisense South Africa');
        INSERT user1;
        
        Learning_Platform_Management__c lpm = new Learning_Platform_Management__c();
        lpm.Name = 'testWW';
        lpm.Type__c = 'competition';
        lpm.Author_Email__c = 'UploadVideoControllerTest@noemail.com';
        lpm.Author__c = 'TrainingDocument';
        lpm.Validity__c = '永久';
        lpm.Sales_Region__c = 'Hisense USA';
        lpm.Person_Type__c = 'Promoter';
        lpm.Email_Notification__c = true;
        lpm.Extra_Person__c = 'TrainingDocumentControllerTest@noemail.com';
        lpm.Allow_Download__c = true;
        insert lpm;
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = lpm.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        Test.startTest();
        Blob b = Blob.valueOf('TrainingDocumentControllerTest@noemail.com');
        String s = EncodingUtil.base64Encode(b);

        TrainingDocumentController.checkAuthorEmail('TrainingDocumentControllerTest@noemail.com');
        TrainingDocumentController.editExtrPerson(lpm.Id);
        TrainingDocumentController.getLearningData('test', 'competition', 'TrainingDocument', String.valueOf(Date.today()), String.valueOf(Date.today()), 'true');
        TrainingDocumentController.checkUploadExtraPerson('testtest', s);

        Test.stopTest();
 
    }

}