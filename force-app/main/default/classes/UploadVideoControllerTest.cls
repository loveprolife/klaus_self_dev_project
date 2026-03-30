@isTest
private class UploadVideoControllerTest {

    static testMethod void testMethod1() {
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='UploadVideoControllerTest@noemail.com',
        emailencodingkey='UTF-8', lastname='UploadVideoControllerTest', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId,country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='UploadVideoControllerTest@noemail.com',Sales_Region__c='Hisense South Africa');
        INSERT user1;

        
        Training_Task__c tt = new Training_Task__c();
        tt.Training_Content__c = '培训任务-001';
        tt.Pass_Score__c = 1;
        tt.Training_Time__c = Datetime.now();
        tt.Approval_Status__c = 'Approved';
        insert tt;
        // 添加培训人员
        Training_Task_User__c ttu = new Training_Task_User__c();
        ttu.Training_Task__c = tt.id;
        ttu.User__c = UserInfo.getUserId();
        insert ttu;
        // 培训人员
        Training_Personnel__c tp = new Training_Personnel__c();
        tp.Training_Task__c = tt.id;
        tp.Training_Task_User__c = ttu.id;
        tp.User__c = UserInfo.getUserId();
        insert tp;

        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = tt.id;
        cdl1.ContentDocumentId = documents[0].Id;
        cdl1.shareType = 'V';
        insert cdl1;  

        Learning_Platform_Management__c lpm = new Learning_Platform_Management__c();
        lpm.Name = '1';
        lpm.Type__c = 'competition';
        lpm.Author_Email__c = 'UploadVideoControllerTest@noemail.com';
        lpm.Validity__c = '永久';
        lpm.Sales_Region__c = 'Hisense USA';
        lpm.Person_Type__c = 'Promoter';
        insert lpm;
        
        Test.startTest();

        UploadVideoController.saveData(tp.id);
        UploadVideoController.saveData(null);

        UploadVideoController.getAttachedDocuments(tp.Id);
        UploadVideoController.getTrainingTaskAttachedDocuments(tp.Id);
        UploadVideoController.getAttachedDocuments(null);
        UploadVideoController.getTrainingTaskAttachedDocuments(null);

        UploadVideoController.verifyPublication(tp.id);

        UploadVideoController.saveCheckFileDetail(tp.id, 'a1', 'a2', 'a3');
        UploadVideoController.saveCheckFileDetail(null, 'a1', 'a2', 'a3');

        UploadVideoController.deleteFile(documents[0].Id);
        UploadVideoController.deleteFile(null);

        UploadVideoController.saveFileViewDetail('Learning_File_View_Details__c', 'Learning_File_View_Details_Total__c' , lpm.Id,  documents[0].Id, 'test11');

        Test.stopTest();
    }
}