/**
 * @description       : 执行岗位变动之前将历史共享数据Is_New_Share__c均更新为false, 重新共享的数据会再次激活, 在共享结束后, 
 *                      将会删除删除Is_New_Share__c仍为false的数据;
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global withOut sharing class ShareInsertShareHistoryBatch implements Database.Batchable<sObject>{
    public String query;
    public String positionGroupId; //岗位Id
    public Boolean isDelete; // true是否做删除共享历史 / false将共享历史字段 *最新共享 设为false
    public String currentUserId;
    public List<String> shareObjectList;
    public String positionId;

    public ShareInsertShareHistoryBatch(
        String positionId,
        String positionGroupId, 
        List<String> shareObjectList, 
        Boolean isDelete
    ) {
        this.positionId = positionId;
        this.isDelete = isDelete;
        this.positionGroupId = positionGroupId;
        this.shareObjectList = shareObjectList;
        String queryStr;

        if (isDelete) {
            queryStr = 'SELECT Id,Is_New_Share__c,Position__c,Share_Object_Name__c,Share_ID__c FROM Share_History__c WHERE GroupId__c = :positionGroupId ORDER BY Share_Object_Name__c';
        }else {
            queryStr = 'SELECT Id, UserOrGroupId FROM ' + shareObjectList[0];
            queryStr += ' WHERE UserOrGroupId = :positionGroupId ';
        }
        this.query = queryStr;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        if (isDelete) {
            List<Share_History__c> shList = (List<Share_History__c>)scope;

            List<Share_History__c> deleteShareshList = new List<Share_History__c>();
            for (Share_History__c shall : shList) {
                if (shall.Is_New_Share__c == false) {
                    deleteShareshList.add(shall);
                }
            }
            Map<String, List<SObject>> deleteSObjectListMap = new Map<String, List<SObject>>();
            for (Share_History__c sh : deleteShareshList) {
                SObject shareItemObject = (SObject)Type.forName(sh.Share_Object_Name__c).newInstance();
                shareItemObject.put('Id', sh.Share_ID__c);
                if (deleteSObjectListMap.containsKey(sh.Share_Object_Name__c)) {
                    deleteSObjectListMap.get(sh.Share_Object_Name__c).add(shareItemObject);
                }else {
                    deleteSObjectListMap.put(sh.Share_Object_Name__c, new List<SObject>{shareItemObject});
                }
            }

            if (!deleteSObjectListMap.isEmpty() && !Test.isRunningTest()) {
                for (String strKey : deleteSObjectListMap.keySet()) {
                    List<SObject> deleteList = deleteSObjectListMap.get(strKey);
                    Database.delete(deleteList, false);
                }
            }

            DELETE shList;
        }else {
            List<Share_History__c> shList = new List<Share_History__c>();
            for (Sobject sobj : scope) {
                Share_History__c sh = new Share_History__c();
                sh.GroupId__c = positionGroupId;
                sh.Share_ID__c = String.valueOf(sobj.get('Id'));
                sh.Is_New_Share__c = false;
                sh.Share_Object_Name__c = shareObjectList[0];
                shList.add(sh);
            }

            INSERT shList;
        }
    }

    global void finish(Database.BatchableContext BC) {

        if (!isDelete) {
            if (!shareObjectList.isEmpty()) {
                shareObjectList.remove(0);
                if (!shareObjectList.isEmpty()) {
                    ShareInsertShareHistoryBatch theBatch = new ShareInsertShareHistoryBatch(positionId, positionGroupId, shareObjectList, false);
                    Database.executeBatch(theBatch, 8000);
                }else {
                    
                    //开始岗位计算
                    System.debug(LoggingLevel.INFO, '*** 开始岗位计算: ');
                    Map<String, String> soMap = new Map<String, String>();
                    for (Share_Object__c so : Share_Common_IntegrationTDGW.queryShareObject()) {
                        soMap.put(so.Object_API__c, so.Id);
                    }
                    System.debug(LoggingLevel.INFO, '*** soMap: ' + soMap);
                    
                    //岗位计算
                    Share_Position_Common_IntegrationBatch theBatch = new Share_Position_Common_IntegrationBatch(
                        positionId,
                        soMap
                    );
                    if (!Test.isRunningTest()) {
                        Database.executeBatch(theBatch, 20);
                    }
                }
            }
        }else {
            Position__c pos = new Position__c(Id = positionId, Is_Job__c = false);
            UPDATE pos;
        }
    }
}