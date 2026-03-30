@isTest
public with sharing class TrainingControllerTest{
    @isTest
    static void Test1(){
        User u = new User();
        Profile p = [SELECT Id
                     FROM profile
                     WHERE name = 'System Administrator'];
        u.username = 'TrainingControllerTest@salesforce.com';
        u.email = 'TrainingControllerTest@salesforce.com';
        u.lastName = 'TTrainingControllerTest';
        String alias = 'aa';
        u.alias = alias;
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        u.HisenseSSOName__c = 'testId';
        insert u;

        Training__c tr = new Training__c();
        tr.Year__c = '2024';
        tr.Month__c = '10';
        tr.Task_Number__c = 10;
        tr.Email__c = 'TrainingControllerTest@salesforce.com';
        insert tr;

        TrainingController.getTrainingData('', '');
        TrainingController.getTrainingData('2024', '10');

        TrainingController.getPickList('Training__c', 'Month__c');
        TrainingController.getPickList('Training__c', 'Month1__c');

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins', 
            PathOnClient = 'Penguins.jpg', 
            VersionData = Blob.valueOf('Test Content'), 
            IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId
                                           FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tr.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        TrainingController.getPictureList(tr.Id);

        TrainingController.deletePicture(documents[0].Id);

        

        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        Shop__c store = new Shop__c();
        store.Name = 'Hi Fi Corporation NEWCASTLE';
        store.Account__c = customer.Id;
        store.Sales_Region__c = 'Hisense Indonesia';
        insert store;

        Training_Tasks__c tt = new Training_Tasks__c();
        tt.Store__c = store.id;
        tt.Training__c = tr.id;
        tt.Training_Address__c = '111';
        tt.Number_of_Trainees__c = 1;
        tt.Number_of_Evaluators__c = 1;
        tt.First_level_Option__c = 'Promoter Meeting';
        tt.Secondary_option__c = 'Promoter';
        tt.Training_Start_Time__c = System.now();
        tt.Training_End_Time__c = System.now().addMinutes(1);
        tt.Product_Line__c = 'TV';
        tt.Training_Type__c = 'Online training';
        tt.Hisense_Entity__c = '8430';
        insert tt;

        TrainingController.saveEvaluate(tt.Id, '{"0":3,"1":4,"2":4,"3":5}');

        TrainingController.getStatus(tt.Id);

        tt.Status__c = '有效';
        update tt;
        TrainingController.getStatus(tt.Id);

        TrainingController.isCanUpload();
    }

}