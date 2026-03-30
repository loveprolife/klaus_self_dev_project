/**
 * @description       : 共享通用类,构造函数中仅可传入 共享对象对应的API名
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global withOut sharing class Share_Position_Common_IntegrationBatch implements Database.Batchable<sObject>{
    public String query;
    public Share_Object__c shareObject;
    public String objectName;
    public String positionId = '';
    public String groupId = '';
    public Set<String> graddingSet = new Set<String>();
    public Set<String> accountSet = new Set<String>();
    public Set<String> accountProductLineSet = new Set<String>();
    public Set<String> shopSet = new Set<String>();
    public Set<String> ownerSet = new Set<String>();
    public Map<String, String> osMap;

    /**
    * @description 
    * @author chenpeng@deloitte.com.cn | 01-20-2022 
    * @param objectName 
    * @param isRefresh  是否岗位刷新共享
    * @param positionId isRefresh为true时,positionId必需
    **/
    public Share_Position_Common_IntegrationBatch( 
        String positionId,
        Map<String, String> osMap
    ) {
        this.osMap = osMap;
        Position__c postion = Share_Common_IntegrationFunction.getPositionObject(positionId);
        this.objectName = Utility.setConverList(osMap.keySet())[0];
        List<Share_Object__c> soList = Share_Common_IntegrationService.queryShareObject(objectName);
        if (soList.isEmpty()) {
            return;
        }
        Share_Object__c shareObj = soList[0];
        this.shareObject = shareObj;
        this.positionId = positionId;
        this.groupId = postion.GroupId__c;
        for (Position_Permissions__c posPer : postion.Position_Permissions__r) {
            if (String.isNotBlank(posPer.Gridding_External_Key__c)) {
                this.graddingSet.add(posPer.Gridding_External_Key__c);
            }

            if (String.isNotBlank(posPer.Account_External_Key__c)) {
                this.accountSet.add(posPer.Account_External_Key__c);
            }

            if (String.isNotBlank(posPer.Account_Product_Line_Key__c)) {
                this.accountProductLineSet.add(posPer.Account_Product_Line_Key__c);
            }

            if (String.isNotBlank(posPer.Shop_External_Key__c)) {
                this.shopSet.add(posPer.Shop_External_Key__c);
            }
            // wfc
            if (String.isNotBlank(posPer.Owner_External_Key__c)) {
                this.ownerSet.add(posPer.Owner_External_Key__c);
            }
        }

        this.query = shareObject.Refresh_Query_Statement__c;
        System.debug(LoggingLevel.INFO, '*** shopSet: ' + JSON.serialize(this.shopSet));
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        System.debug(LoggingLevel.INFO, '*** scope.size(): ' + scope.size());
        try {
            Share_Common_IntegrationService.shareData(objectName, JSON.serialize(scope), groupId, false);
        } catch (Exception ex) {
            // Utility.Chatter chatterCls = new Utility.Chatter(
            //     Id.valueOf('0050o00000X2d4O'), 
            //     positionId, 
            //     '*** Insert Log Error: ' + ex.getMessage() + '\n' + ex.getStackTraceString()
            // );
            // List<Utility.Chatter> chatterList = new List<Utility.Chatter>();
            // chatterList.add(chatterCls);
            // Utility.createChatterNotice(chatterList);
        }
    }

    global void finish(Database.BatchableContext BC) {
        
        osMap.remove(objectName);
        System.debug(LoggingLevel.INFO, '*** osMap: ' + osMap);
        if (osMap.isEmpty()) {
            System.debug(LoggingLevel.INFO, '*** 进入删除最新共享操作: ');
            //删除不是最新的共享
            // ShareClearingShareHistoryBatch theBatch = new ShareClearingShareHistoryBatch(
            //     positionId,
            //     true
            // );
            // Database.executeBatch(theBatch, 200);
            ShareInsertShareHistoryBatch theBatch = new ShareInsertShareHistoryBatch(
                positionId,
                groupId, 
                new List<String>(),
                true
            );
            Database.executeBatch(theBatch, 8000);
        }else {
            Share_Position_Common_IntegrationBatch theBatch = new Share_Position_Common_IntegrationBatch(positionId, osMap);
            Database.executeBatch(theBatch, 20);
        }
    }
}