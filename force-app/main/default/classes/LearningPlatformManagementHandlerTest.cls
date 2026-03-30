@isTest
private class LearningPlatformManagementHandlerTest{
    static testMethod void testMethod1(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='UploadVideoControllerTest@noemail.com',
        emailencodingkey='UTF-8', lastname='UploadVideoControllerTest', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId,country='United States',IsActive =true,Role_Type__c='Promoter',
        timezonesidkey='America/Los_Angeles', username='UploadVideoControllerTest@noemail.com',Sales_Region__c='Hisense South Africa');
        INSERT user1;
        
        Learning_Platform_Management__c lpm = new Learning_Platform_Management__c();
        lpm.Name = '1';
        lpm.Type__c = 'competition';
        lpm.Author_Email__c = 'UploadVideoControllerTest@noemail.com';
        lpm.Validity__c = '永久';
        lpm.Sales_Region__c = 'Hisense South Africa';
        lpm.Person_Type__c = 'Promoter';
        lpm.Email_Notification__c = true;
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

        delete lpm;
 
    }

}