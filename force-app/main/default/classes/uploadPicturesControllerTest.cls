@isTest
private class uploadPicturesControllerTest {
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

    	Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contVerFile.Id].ContentDocumentId;

    	Test.startTest();
    	// (Id id,String versionIdField,String publicLinkField,String contentBodyIdField,String fileTypeField,String documentId,String contentVersionId,String contentBodyId,String name)
        uploadPicturesController.saveObject(ep1.Id, 'versionIdField', 'publicLinkField', 'contentBodyIdField', 'fileTypeField', conDoc, contVerFile.Id,'contentBodyId', 'name');
        // delObject(Id id,String versionIdField,String publicLinkField,String contentBodyIdField,String fileTypeField,String contentVersionId)
        uploadPicturesController.delObject(ep1.Id, 'versionIdField','publicLinkField', 'contentBodyIdField', 'fileTypeField', contVerFile.Id);

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