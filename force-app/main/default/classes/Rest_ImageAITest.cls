@isTest
public with sharing class Rest_ImageAITest{
    @isTest
    static void testRest_ImageAI(){
        Image_Ai_Interface__c iai = new Image_Ai_Interface__c();
        iai.Name = '电视黑屏检核';
        iai.Type__c = 'POST';
        iai.Url__c = 'https://open-apisix.hisense.com/hiai/gjyxkongyang?app_id=2iscpteb&app_key=fiufxcv0wwhxuwdtcjwvfxittzpuzp29';
        insert iai;

        // 设置 mock
        String json = '{"code":0,"result":{"result":"未检测到异常"}}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json) );

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins', 
            PathOnClient = 'Penguins.txt', 
            VersionData = Blob.valueOf('Test Content'), 
            IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId
                                           FROM ContentDocument];
        if (!documents.isEmpty()){
            Image image = new Image(
                Name = '电视黑屏检核', 
                Record_Id__c = iai.Id, 
                ContentDocumentId = documents[0].Id
            );
            insert image;
            Rest_ImageAI.imageAi(image.Id, iai.Type__c, iai.Url__c, '1111');
        }


        Rest_ImageAI.checkSI('电视黑屏检核', '1111');
        Rest_ImageAI.imageAi(iai.Type__c, iai.Url__c, '1111');
    }

}