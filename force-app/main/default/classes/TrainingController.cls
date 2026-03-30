/*
 * @Author: WFC
 * @Date: 2024-04-03 14:17:00
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-06 15:37:48
 * @Description:
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\TrainingController.cls
 */
public without sharing class TrainingController{
    @AuraEnabled
    public static List<Training__c> getTrainingData(String valueYear, String valueMonth){
        String sql = 'SELECT Id, Name, Year__c, Month__c, Email__c, Training_Theme__c, Training_Classification__c, Task_Number__c, Pre_effective_Number__c, Effective_Number__c, Rate_of_Completion__c ' + 
                 ' FROM Training__c ' + 
                 ' WHERE Email__c = \'' + UserInfo.getUserName() + '\'';
        if (String.isNotBlank(valueYear)){
            sql = sql + ' AND Year__c = \'' + valueYear + '\'';
        }
        if (String.isNotBlank(valueMonth)){
            sql = sql + ' AND Month__c = \'' + valueMonth + '\'';
        }
        sql = sql + 'ORDER BY Name';
        return Database.query(sql);
    }

    @AuraEnabled(Cacheable = true)
    public static List<Map<String, String>> getPickList(String objectName, String fieldName){

        try{
            Map<String, String> temp = Utility.getPicklistValueMap(objectName, fieldName);
            List<Map<String, String>> result = new List<Map<String, String>>();
            result.add(new Map<String, String>{ 'label' => '--None--', 'value' => '' });
            for (String key : temp.keySet()){
                result.add(new Map<String, String>{ 'label' => temp.get(key), 'value' => key });
            }
            return result;
        } catch (Exception e){
            // throw new AuraHandledException(e.getMessage());
            return null;
        }
    }

    // // 附件上传
    // @AuraEnabled
    // public static void saveTrainingPicture(String recordId, String photoStream){
    //     System.debug('photoStream--->' + photoStream);
    //     if (recordId == null || photoStream == null || photoStream == ''){
    //         return;
    //     }
    //     String fileName = System.now().format('yyyyMMddHHmmss') + '.jpeg';
    //     ContentVersion cv = new ContentVersion();
    //     cv.VersionData = EncodingUtil.base64Decode(photoStream.substring(23, photoStream.length()));
    //     cv.Title = fileName;
    //     cv.PathOnClient = fileName;
    //     insert cv;
    //     ContentVersion qrcv = [SELECT Id, ContentDocumentId
    //                            FROM ContentVersion
    //                            WHERE Id = :cv.id];
    //     ContentDocumentLink cdl = new ContentDocumentLink();
    //     cdl.ContentDocumentId = qrcv.ContentDocumentId;
    //     cdl.LinkedEntityId = recordId;
    //     cdl.ShareType = 'V';
    //     insert cdl;
    // }
    @AuraEnabled
    public static List<ContentVersion> getPictureList(String recordId){
        Set<Id> idSet = new Set<Id>();
        // 查询与记录相关联的文件
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType
                                                   FROM ContentDocumentLink
                                                   WHERE LinkedEntityId = :recordId];
        // 处理查询结果
        for (ContentDocumentLink link : documentLinks){
            idSet.add(link.ContentDocumentId);
        }
        // 检索文件详细信息
        List<ContentVersion> cvList = [SELECT Id, ContentBodyId, ContentDocumentId, FileType
                                       FROM ContentVersion
                                       WHERE ContentDocumentId IN:idSet
                                       ORDER BY ContentDocument.CreatedDate];
        return cvList;
    }

    @AuraEnabled
    public static Boolean deletePicture(String contentDocumentId){
        Database.delete (contentDocumentId);
        return true;
    }

    // 保存考评(trainingTaskEvaluateLwc)
    @AuraEnabled
    public static Boolean saveEvaluate(String recordId, String ratingDataJson){
        Map<String, Object> ratingMap = (Map<String, Object>)JSON.deserializeUntyped(ratingDataJson);
        Decimal score = 0;
        for (String index : ratingMap.keySet()){
            score += Decimal.valueOf(String.valueOf(ratingMap.get(index)));
        }
        Training_Tasks_Evaluate__c tte = new Training_Tasks_Evaluate__c();
        tte.Training_Tasks__c = recordId;
        tte.Score__c = score;
        tte.Answer__c = ratingDataJson;
        insert tte;
        return true;
    }

    // @AuraEnabled(Cacheable = true)
    // public static List<Training_Tasks_Evaluate_Question__c> getQuestions(){
    //     return [SELECT Id, Name, Topic__c, Score__c, Sort__c, IsActive__c
    //             FROM Training_Tasks_Evaluate_Question__c
    //             WHERE IsActive__c = true
    //             ORDER BY Sort__c];
    // }
    @AuraEnabled(Cacheable = true)
    public static Boolean getStatus(String recordId){

        Training_Tasks__c tt = [SELECT Status__c
                                FROM Training_Tasks__c
                                WHERE Id = :recordId
                                LIMIT 1];
        if (tt.Status__c == '预有效' || tt.Status__c == '有效'){
            return false;
        } else{
            return true;
        }
    }

    @AuraEnabled
    public static Boolean isCanUpload(){
        User currentUser = [SELECT Id, Profile.name
                            FROM User
                            WHERE Id = :UserInfo.getUserId()];
        if (currentUser.profile.name == 'Indonesia Store M and malaysia GM' || currentUser.profile.name == 'System Administrator'){
            return true;
        } else{
            return false;
        }
    }

}