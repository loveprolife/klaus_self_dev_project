public with sharing class uploadPicturesController {
    @AuraEnabled
    public static ConResponse saveObject(Id id,String versionIdField,String publicLinkField,String contentBodyIdField,String fileTypeField,String documentId,String contentVersionId,String contentBodyId,String name) {
        System.debug('name--=='+name);
        ConResponse resp = new ConResponse();
        List<String> strList =  name.split('\\.');
        System.debug('strList--=='+strList);
        try {
            String title = strList[0];
            List<ContentDocument> contDocList =  [SELECT FileType, Id FROM ContentDocument WHERE Id =: documentId];
            ContentDistribution cd = new ContentDistribution();
            cd.Name = title;
            cd.ContentVersionId = contentVersionId;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            CD.PreferencesAllowPDFDownload = false;
            insert cd;

            cd = [SELECT id, DistributionPublicUrl
                  FROM ContentDistribution 
                  WHERE id =: cd.id];

            String objectAPIName =  id.getSObjectType().getDescribe().getName();
            Schema.SObjectType t = Schema.getGlobalDescribe().get(objectAPIName);
            SObject sObjectAPI = t.newSObject(id);
            sObjectAPI.put(versionIdField,contentVersionId);
            sObjectAPI.put(contentBodyIdField,contentBodyId);

            List<String> urlStrList = cd.DistributionPublicUrl.split('/p/');

            System.debug('urlStrList--='+urlStrList);
            List<String> urlStrList2 = urlStrList[1].split('/a/');
            System.debug('urlStrList2--='+urlStrList2);
            // Modified By Ethan 修改拼接前缀
            String urlPrefix = System.URL.getSalesforceBaseUrl().toExternalForm().contains('sandbox') ? System.URL.getSalesforceBaseUrl().toExternalForm().substringBefore('.')+'.sandbox.file.force.com' : System.URL.getSalesforceBaseUrl().toExternalForm().substringBefore('.')+'.file.force.com';
            String imaUrl = urlPrefix+'/sfc/dist/version/renditionDownload?rendition=ORIGINAL_'+
                            contDocList[0].FileType+'&versionId='+contentVersionId+'&operationContext=DELIVERY&contentId='+
                            contentBodyId+'&page=0&d=/a/'+urlStrList2[1]+'&oid=00D'+urlStrList2[0]+'&dpt=null&viewId=';
            // String imaUrl = 'https://hisenseint--hitest.sandbox.file.force.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_'+
            //                 contDocList[0].FileType+'&versionId='+contentVersionId+'&operationContext=DELIVERY&contentId='+
            //                 contentBodyId+'&page=0&d=/a/'+urlStrList2[1]+'&oid=00D'+urlStrList2[0]+'&dpt=null&viewId=';
            System.debug('imaUrl---='+imaUrl);
            sObjectAPI.put(publicLinkField,imaUrl);
            sObjectAPI.put(fileTypeField,contDocList[0].FileType);
            Update sObjectAPI;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        

        return resp;
    }

    @AuraEnabled
    public static ConResponse delObject(Id id,String versionIdField,String publicLinkField,String contentBodyIdField,String fileTypeField,String contentVersionId) {
        ConResponse resp = new ConResponse();
        try {
            List<ContentVersion> contVerList =  [SELECT Id, ContentDocumentId, ContentBodyId FROM ContentVersion WHERE Id =: contentVersionId];
        
            if (contVerList.size()>0) {
                ContentDocument contDoc = new ContentDocument();
                contDoc.Id = contVerList[0].ContentDocumentId;
                delete contDoc;
            }

            String objectAPIName =  id.getSObjectType().getDescribe().getName();
            Schema.SObjectType t = Schema.getGlobalDescribe().get(objectAPIName);
            SObject sObjectAPI = t.newSObject(id);
            sObjectAPI.put(versionIdField,'');
            sObjectAPI.put(contentBodyIdField,'');
            sObjectAPI.put(publicLinkField,'');
            sObjectAPI.put(fileTypeField,'');
            Update sObjectAPI;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = 'error';
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

}