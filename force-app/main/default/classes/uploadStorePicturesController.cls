//只针对门店
public without sharing class uploadStorePicturesController {
	private final static  String NOTIFY_BODY =  System.Label.Store_Pic_Notify_Body;
	private final static  String NOTIFY_TITLE =  System.Label.Store_Pic_Notify_Title;
    @AuraEnabled
    public static ConResponse saveObject(Id id,String versionIdField, String contentBodyIdField,String fileTypeField,String documentId,String contentVersionId,String contentBodyId,String name, Boolean isUpdate) {
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
            // sObjectAPI.put(getCoverImgPublicLink(versionIdField), cd.DistributionPublicUrl);

            List<String> urlStrList = cd.DistributionPublicUrl.split('/p/');
            List<String> urlStrList2 = urlStrList[1].split('/a/');
            sObjectAPI.put(fileTypeField,contDocList[0].FileType);
            Update sObjectAPI;

            //share imgs to all user
            ContentDocumentLink cdlink = new ContentDocumentLink(
                ContentDocumentId = documentId,
                LinkedEntityId = id,
                ShareType = 'I',
                Visibility = 'AllUsers'
            );
            INSERT cdlink;


            if (isUpdate) {
            	Set<String> userIdset = new Set<String>();
            	for (Responsible_Person__c item: [SELECT Id,Principal__c FROM Responsible_Person__c WHERE (RecordType__c = '促销员' OR RecordType__c = '巡店员') AND Principal__c<>NULL AND Shop_Name__c =: id]) {
            		userIdset.add(item.Principal__c);
            		
            	}
            	if (! userIdset.isEmpty()) {
            	    CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType  WHERE DeveloperName='Custom_Notification'];
            	    // String sobjectName = 'Shop__c';
            	    // String fieldApiName = '';
            	    // if (versionIdField.contains('1')) fieldApiName = 'CoverImg1__c';
            	    // if (versionIdField.contains('2')) fieldApiName = 'CoverImg2__c';
            	    // else fieldApiName = 'CoverImg__c';

            	    Shop__c store = [SELECT Name FROM Shop__c WHERE Id=:id];

            	    // String bodyMsg = 'the ' + getFieldLabelByFieldApiName(sobjectName,fieldApiName) + ' on the store named '+store.Name+' has been updated!';
            	    String bodyMsg = 'the Store Sampling Product Layout on the '+store.Name+' have been updated!';
            	    notifyUsers(notificationType, userIdset, id, bodyMsg);
            	}
            }
          	


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
    public static ConResponse delObject(Id id,String versionIdField, String contentBodyIdField, String fileTypeField, String contentVersionId) {
        ConResponse resp = new ConResponse();
        try {
            List<ContentVersion> contVerList =  [SELECT Id, ContentDocumentId, ContentBodyId FROM ContentVersion WHERE Id =: contentVersionId];
        
            if (contVerList.size()>0) {
                ContentDocument contDoc = new ContentDocument();
                contDoc.Id = contVerList[0].ContentDocumentId;
                delete contDoc;
            }

            //删除 ContentDocumentLink
            for (ContentDocumentLink item: [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =:id AND ContentDocumentId =:contVerList[0].ContentDocumentId]) {
                DELETE item;
            }


            String objectAPIName =  id.getSObjectType().getDescribe().getName();
            Schema.SObjectType t = Schema.getGlobalDescribe().get(objectAPIName);
            SObject sObjectAPI = t.newSObject(id);
            sObjectAPI.put(versionIdField,'');
            sObjectAPI.put(contentBodyIdField,'');
            // sObjectAPI.put(publicLinkField,'');
            // sObjectAPI.put(getCoverImgPublicLink(versionIdField), NULL);
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

    @AuraEnabled
    public static ConResponse getPicMsg(String contentVersionId){
        ConResponse resp = new ConResponse();
        try{
             List<ContentVersion> contVerList =  [SELECT Id, ContentDocumentId, ContentBodyId FROM ContentVersion WHERE Id =: contentVersionId];
             if ( ! contVerList.isEmpty()) {
                Map<String, String> dataMap = new Map<String, String>();
                dataMap.put('documentId', contVerList[0].ContentDocumentId);
                 resp.data = dataMap;
             }
        }catch(Exception e) {
            resp.code = -1;
            resp.message = 'error'+ e.getMessage() + '\n' + e.getStackTraceString();
        }
        return resp;

    }

    //自定义通知
    public static void notifyUsers(CustomNotificationType notificationType, Set<String> recipientsIds, String targetId, String bodyMsg) {

        
        System.debug('userid--->'+recipientsIds);
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle(NOTIFY_TITLE);
        notification.setBody(NOTIFY_BODY+bodyMsg);

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
       	// notification.setTargetId('0050o00000XQeznAAD');
        // Actually send the notification
        // try {
            notification.send(recipientsIds);
        // }
        // catch (Exception e) {
        //     System.debug('Problem sending notification: ' + e.getLineNumber()+e.getMessage());
        // }
    }

    //获取 CoverImgPublicLink__c
    // public static String getCoverImgPublicLink(String versionIdField){
    //     if (versionIdField.contains('1')) {
    //         return 'CoverImgPublicLink1__c';
    //     }
    //     if (versionIdField.contains('2')) {
    //         return 'CoverImgPublicLink2__c';
    //     }else {
    //         return 'CoverImgPublicLink__c';
    //     }

    // }

    //根据recordId获取versionId 列表 
    @AuraEnabled
    public static ConResponse getContentVersionIdListById(String recordId){
        ConResponse resp = new ConResponse();
        try{
            List<String> idList = new List<String>();
            for (Shop__c  item: [SELECT Id, CoverImgVersionId__c, CoverImgVersionId1__c, CoverImgVersionId2__c FROM Shop__c WHERE Id =:recordId]) {
                if (String.isNotBlank(item.CoverImgVersionId__c)) idList.add(item.CoverImgVersionId__c);
                if (String.isNotBlank(item.CoverImgVersionId1__c)) idList.add(item.CoverImgVersionId1__c);
                if (String.isNotBlank(item.CoverImgVersionId2__c)) idList.add(item.CoverImgVersionId2__c);
            }
            resp.data = idList;
        }catch(Exception e) {
            resp.code = -1;
            resp.message = 'error'+ e.getMessage() + '\n' + e.getStackTraceString();
        }
        return resp;
    }


    //获取当前登录用户的类型 是否满足展示要求 ----------------是否是促销员
    @AuraEnabled
    public static ConResponse isCurrentUserView(){
        ConResponse resp = new ConResponse();
        try{
            Boolean isView = false;
            String currentUserId = UserInfo.getUserId();
            List<String> sysUserIdList = new List<String>();
            for (Profile ite: [SELECT Id, Name FROM Profile WHERE Name like '%dmin%']) sysUserIdList.add(ite.Id);
                
            for (Responsible_Person__c item: [SELECT Id,Principal__c,RecordType__c FROM Responsible_Person__c WHERE Principal__c=: currentUserId]) {
                if (item.RecordType__c == '促销员' || sysUserIdList.contains(currentUserId)) isView = true;
            }
            resp.data = isView;
        }catch(Exception e){
            resp.code = -1;
            resp.message = 'error'+ e.getMessage() + '\n' + e.getStackTraceString();
        }
        return resp;


    }


    //根据字段API获取字段Label
  //   public static String getFieldLabelByFieldApiName(String sobjectName, String filedApiName){
  //   	List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{sobjectName}); 
		// String objectLabel = describeSobjectsResult[0].getLabel();
		// Map<String, Schema.SObjectField> allFields = describeSobjectsResult[0].fields.getMap();
		// return allFields.get(filedApiName).getDescribe().getLabel();

  //   }



}