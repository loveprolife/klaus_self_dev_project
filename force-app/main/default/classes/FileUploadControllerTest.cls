@isTest
private class FileUploadControllerTest{
    @isTest
    static void testGetRecordFiles(){
        // 创建测试数据
        FOB__c fob = new FOB__c();
        fob.External_Key__c = 'test';
        insert fob;

        // 创建测试文档
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins', 
            PathOnClient = 'Penguins.jpg', 
            VersionData = Blob.valueOf('Test Content'), 
            IsMajorVersion = true
        );
        insert contentVersion;

        // 创建文档链接
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId
                                           FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = fob.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        Test.startTest();
        // 测试方法
        FileUploadController.getRecordFiles(fob.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetRecordFilesWithNullRecordId(){
        // 测试空记录ID的情况
        FileUploadController.getRecordFiles(null);
    }

    @isTest
    static void testDeleteFileLinkSuccess(){
        // 创建测试数据
        FOB__c fob = new FOB__c();
        fob.External_Key__c = 'test';
        insert fob;

        // 创建测试文档
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins', 
            PathOnClient = 'Penguins.jpg', 
            VersionData = Blob.valueOf('Test Content'), 
            IsMajorVersion = true
        );
        insert contentVersion;

        // 创建文档链接
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId
                                           FROM ContentDocument];

        ContentDocumentLink testLink = New ContentDocumentLink();
        testLink.LinkedEntityId = fob.id;
        testLink.ContentDocumentId = documents[0].Id;
        testLink.shareType = 'V';
        insert testLink;

        // 测试删除方法
        FileUploadController.DeleteRequest req = new FileUploadController.DeleteRequest();
        req.contentDocumentId = String.valueOf(documents[0].Id);
        req.contentDocumentLinkId = String.valueOf(testLink.Id);
        req.recordId = String.valueOf(fob.Id);

        FileUploadController.deleteFileLink(req.contentDocumentId, req.contentDocumentLinkId, req.recordId);
    }

    @isTest
    static void testDeleteFileLinkInvalidLink(){
        // 创建测试数据
        FOB__c fob = new FOB__c();
        fob.External_Key__c = 'test';
        insert fob;

        // 测试无效链接的情况
        FileUploadController.DeleteRequest req = new FileUploadController.DeleteRequest();
        req.contentDocumentId = 'invalidId';
        req.contentDocumentLinkId = 'invalidId';
        req.recordId = String.valueOf(fob.Id);

        FileUploadController.deleteFileLink(req.contentDocumentId, req.contentDocumentLinkId, req.recordId);
    }

    @isTest
    static void testDeleteFileLinkWrongRecord(){
        // 创建测试数据
        FOB__c fob1 = new FOB__c();
        fob1.External_Key__c = 'test1';
        insert fob1;

        FOB__c fob2 = new FOB__c();
        fob2.External_Key__c = 'test2';
        insert fob2;

        // 创建测试文档
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins', 
            PathOnClient = 'Penguins.jpg', 
            VersionData = Blob.valueOf('Test Content'), 
            IsMajorVersion = true
        );
        insert contentVersion;

        // 创建文档链接
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId
                                           FROM ContentDocument];

        ContentDocumentLink testLink = New ContentDocumentLink();
        testLink.LinkedEntityId = fob1.id;
        testLink.ContentDocumentId = documents[0].Id;
        testLink.shareType = 'V';
        insert testLink;

        // 测试链接不属于指定记录的情况
        FileUploadController.DeleteRequest req = new FileUploadController.DeleteRequest();
        req.contentDocumentId = String.valueOf(documents[0].Id);
        req.contentDocumentLinkId = String.valueOf(testLink.Id);
        req.recordId = String.valueOf(fob2.Id); // 不匹配的记录ID

        FileUploadController.deleteFileLink(req.contentDocumentId, req.contentDocumentLinkId, req.recordId);
        FileUploadController.deleteFileLink(req.contentDocumentId, '', req.recordId);
    }

}