@isTest
private class uploadStorePicturesControllerTest {
    static testMethod void testMethod1() {
    	Exhibition_Product__c ep1 = new Exhibition_Product__c(
            Backup_Quantity__c =1, 
            Display_Quantity__c =1, 
            Packaging_Dimension_D__c =1, 
            Packaging_Dimension_H__c =1, 
            Packaging_Dimension_W__c =1, 
            Weight_With_Packaging__c =1);
        INSERT ep1;
         
        ContentVersion contVerFile = new ContentVersion(
            VersionData = Blob.valueOf('String o'),
            Title = 'title',
            ContentLocation = 's',
            PathOnClient = 'title.cvs'
            );
        INSERT contVerFile;

        ContentVersion testContentVersion1 = new ContentVersion();
        //testContentVersion1.ContentDocumentId = '0690l000003bfgnAAA';
        testContentVersion1.PathOnClient = '新建文本文档.txt';
        testContentVersion1.Title = '新建文本文档.txt';
        testContentVersion1.VersionData = Blob.valueOf('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');
        //testContentVersion1.VersionData = EncodingUtil.base64Decode(String.valueOf('data:image/png;base64,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'));


        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contVerFile.Id].ContentDocumentId;

        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType  WHERE DeveloperName='Custom_Notification'];

        Shop__c shop1 = new Shop__c(CoverImgVersionId__c = 'ioteurwo09460437rg', CoverImgVersionId1__c = 'ieoitjeowjtorejhreh', CoverImgVersionId2__c = 'foierhgoehoieowighoirehgw');
        INSERT shop1;

        Promoter_Attendance_Rule__c pa1 = new Promoter_Attendance_Rule__c(Distance__c = 1000,
            End_time__c = Time.newInstance(10, 10, 10, 10),
            Start_time__c = Time.newInstance(9, 10, 10, 10),
            Time_buffer__c = 60
        );
        INSERT pa1;

        Responsible_Person__c rp1 = new Responsible_Person__c(RecordType__c = '促销员', Principal__c = UserInfo.getUserId(), 
            Promoter_Attendance_Rule__c = pa1.Id,
            Shop_Name__c = shop1.Id);
        INSERT rp1;

        Test.startTest();
        uploadStorePicturesController.saveObject(ep1.Id, 'CoverImgVersionId__c', 'CoverImgContentBodyId__c', 'CoverImgFileType__c', conDoc, contVerFile.Id,'contentBodyId', 'name', true);
        uploadStorePicturesController.delObject(ep1.Id, 'CoverImgVersionId__c', 'CoverImgContentBodyId__c', 'CoverImgFileType__c', contVerFile.Id);

        uploadStorePicturesController.saveObject(ep1.Id, 'CoverImgVersion', 'CoverImgContentBodyI', 'CoverImgFileType__c', conDoc, contVerFile.Id,'contentBodyId', 'name', true);
        uploadStorePicturesController.delObject(ep1.Id, 'CoverImgVersion', 'CoverImgContentBody', 'CoverImgFileType__c', contVerFile.Id);

        uploadStorePicturesController.getPicMsg(contVerFile.Id);
        uploadStorePicturesController.notifyUsers(notificationType, new Set<String>{UserInfo.getUserId()}, ep1.Id, 'BodyMsg') ;
        uploadStorePicturesController.getContentVersionIdListById(shop1.Id);


        uploadStorePicturesController.isCurrentUserView();
        uploadStorePicturesController.getContentVersionIdListById(null);
        uploadStorePicturesController.getPicMsg(NULL);

        Test.stopTest();
    }

    static testMethod void testMethod2() {
            ConResponse resp = new ConResponse();
            resp.code = -1;
            Boolean res = resp.isSuccess;

            Response resp1 = new Response();
            resp1.data = 'test';
            resp1.message = 'test';


        }
}