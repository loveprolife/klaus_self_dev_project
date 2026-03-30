/**
 * @description       : Share_Common_Integration transfer data gather way
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class Share_Common_IntegrationTDGW {
    public static void deleteChangeDataShare(Share_Object__c shareObj, 
                                             Map<String, List<String>> checkShareDataIdMap, 
                                             List<Object> shareDataList,
                                             List<String> deleteSriList,
                                             Set<String> changeIdSet) {
        system.debug('wwwwwddd----'  + JSON.serialize(shareObj));
        system.debug('wwwwwddd----'  + JSON.serialize(checkShareDataIdMap));
        system.debug('wwwwwddd----'  + JSON.serialize(shareDataList));
        system.debug('wwwwwddd----'  + JSON.serialize(deleteSriList));
        system.debug('wwwwwddd----'  + JSON.serialize(changeIdSet));
        if(checkShareDataIdMap.isEmpty()){
            return;
        }

        //系统中的change数据的共享关系记录
        Map<String, List<String>> shareDataIdMap = new Map<String, List<String>>();

        //可以删除的共享关系对象的 目标对象ID
        Set<String> deleteParentIdSet = new Set<String>();

        //查找共享关系行中的 Share_Relationship_ID__c 为 checkShareDataIdMap.keySet()
        for (Share_Relationship_Item__c sri : queryShareRelationshipItemList(checkShareDataIdMap.keySet())) {
            if(shareDataIdMap.containsKey(sri.Share_Relationship_ID__c)) {
                shareDataIdMap.get(sri.Share_Relationship_ID__c).add(sri.ShareItemId__c);
            }else {
                shareDataIdMap.put(sri.Share_Relationship_ID__c, new List<String>{sri.ShareItemId__c});
            }
        }
        system.debug('shareDataIdMap'+shareDataIdMap);
        for(String strKey : shareDataIdMap.keySet()) {
            if(checkShareDataIdMap.values().size() == shareDataIdMap.values().size()) {
                deleteParentIdSet.add(strKey);
            }

        }
        system.debug('deleteParentIdSet'+deleteParentIdSet);

        //要删除的更新的共享对象共享数据
        Map<String, List<SObject>> deleteChangeShareListMap = new Map<String, List<SObject>>();

        //通过 changeIdSet 查找关系对象中的共享数据
        for (Share_Relation_Object__c sro : shareObj.Share_Object_Relation__r) {
            String deleteRelatShareQuery = 'SELECT Id,UserOrGroupId FROM ' + sro.Object_Share__c;
            deleteRelatShareQuery += ' WHERE ' + sro.Share_Type__c + ' IN :deleteParentIdSet';
            system.debug('deleteRelatShareQuery'+deleteRelatShareQuery);
            List<SObject> deleteChangeShareList = new List<SObject>();
            for (SObject sob : Database.query(deleteRelatShareQuery)) {
                deleteChangeShareList.add(sob);
            }
            if(!deleteChangeShareList.isEmpty()) {
                deleteChangeShareListMap.put(sro.Id, deleteChangeShareList);
            }
        }

        String deleteShareQuery = 'SELECT Id FROM ' + shareObj.Object_Share__c;
        deleteShareQuery += ' WHERE ' + shareObj.Share_Type__c + ' IN :changeIdSet';
        List<SObject> deleteChangeShareList = new List<SObject>();
        system.debug('deleteShareQuery'+deleteShareQuery);
        for (SObject sob : Database.query(deleteShareQuery)) {
            deleteChangeShareList.add(sob);
        }
        if(!deleteChangeShareList.isEmpty()) {
            deleteChangeShareListMap.put(shareObj.Id, deleteChangeShareList);
        }

        if(!deleteChangeShareList.isEmpty()){
            for (String strKey : deleteChangeShareListMap.keySet()) {
                Database.delete(deleteChangeShareListMap.get(strKey), false);
            }
        }

        //删除共享关系行
        List<Share_Relationship_Item__c> shareRelationshipItemByKeyList = queryShareRelationshipItemByKeyList(deleteSriList);
        if(!shareRelationshipItemByKeyList.isEmpty()) {
            DELETE shareRelationshipItemByKeyList;
        }
    }

    public static List<SObject> sortChunks(List<SObject> scope) {
        Map<String, List<SObject>> sortMap = new Map<String, List<SObject>>();
        for (SObject rec : scope) {
            String keyPrefix = rec.getSObjectType().getDescribe().getName();
            if (!sortMap.containsKey(keyPrefix)) {
            sortMap.put(keyPrefix, new List<SObject>());
            }
            sortMap.get(keyPrefix).add(rec);
        }

        List<SObject> flattenedList = new List<SObject>();
        for ( String key: sortMap.keySet() ) {
            flattenedList.addAll( sortMap.get(key) );
        }
        return flattenedList;
    }

    /**
    * @description 
    * @author chenpeng@deloitte.com.cn | 01-24-2022 
    * @param objectName  - 对象名
    * @param parameter - (List<Object>)
    * @param cause - Row_Cause__c
    **/
    public static void writeShareLogs(String objectName,
                                      Map<String, List<String>> parameterList, 
                                      Map<String, String> causeMap) {

        try {
            Share_Log__c log = new Share_Log__c();
            log.Share_Object__c = objectName;
            log.Row_Cause__c = JSON.serialize(causeMap);
            log.Parameter__c = JSON.serialize(parameterList);
            log.Share_Time__c = System.now();
            INSERT log;

        } catch(Exception ex) {
            System.debug(LoggingLevel.INFO, '*** Insert Log Error: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    public static List<Share_Relationship_Item__c> queryShareRelationshipItemList(Set<String> shareRelatIdSet){
        return [SELECT External_Key_ID__c,
                       ShareItemId__c,
                       Share_Relationship_ID__c
                FROM Share_Relationship_Item__c
                WHERE Share_Relationship_ID__c IN :shareRelatIdSet];
    }

    public static List<Share_Relationship_Item__c> queryShareRelationshipItemByKeyList(List<String> deleteSriList){
        return [SELECT External_Key_ID__c,
                       ShareItemId__c,
                       Share_Relationship_ID__c
                FROM Share_Relationship_Item__c
                WHERE External_Key_ID__c IN :deleteSriList];
    }

    public static List<Share_Object__c> queryShareObject(){
        return [SELECT Name, 
                        Object_API__c,
                        Gridding_Filed_API__c,
                        Account_API__c,
                        Account_Product_Line__c,
                        Object_Share__c,
                        Share_Type__c,
                        Share_RowCause__c,
                        Share_Chunk__c,
                        Batch_AddMinutes__c,
                        Query_Statement__c,
                        IsRelyThisShare__c,
                        Product_Line_API__c,
                        Refresh_Query_Statement__c,
                        Shop_Filed_API__c
                FROM Share_Object__c
                WHERE IsActive__c = true AND Object_Share__c  != 'Customer_Visit__Share'];
    }
}