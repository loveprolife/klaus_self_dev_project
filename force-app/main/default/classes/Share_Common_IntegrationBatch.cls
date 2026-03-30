/**
 * @description       : 共享通用类,构造函数中仅可传入 共享对象对应的API名
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global withOut sharing class Share_Common_IntegrationBatch implements Database.Batchable<sObject>{
    public String query;
    public Share_Object__c shareObject;
    public String objectName;
    public Boolean isCallSchedulable = false; //是否在finish中挂起下次Schedulable
    public String schedulableName; //需挂起的schedulable类名
    public Boolean isRefresh = false; //是否在finish中挂起下次Schedulable
    public String positionId = '';
    public String groupId = '';
    public Set<String> graddingSet = new Set<String>();
    public Set<String> accountSet = new Set<String>();
    public Set<String> accountProductLineSet = new Set<String>();
    public Integer nextSchedulableTime;
    public Boolean isNeedChange = false; //数据不需要IsChange wfc

    /**
    * @description 
    * @author chenpeng@deloitte.com.cn | 01-20-2022 
    * @param objectName 
    * @param isCallSchedulable 
    * @param schedulableName 
    **/
    public Share_Common_IntegrationBatch(
        String objectName, 
        Boolean isCallSchedulable, 
        String schedulableName, 
        Integer nextSchedulableTime,
        String query
    ) {
        this.objectName = objectName;
        this.isCallSchedulable = isCallSchedulable;
        this.schedulableName = schedulableName;
        this.nextSchedulableTime = nextSchedulableTime;

        List<Share_Object__c> soList = Share_Common_IntegrationService.queryShareObject(objectName);

        if (soList.isEmpty()) {
            this.query = 'SELECT Id FROM ' + objectName;
        }else {
            Share_Object__c shareObj = soList[0];
            this.shareObject = shareObj;
            if (String.isBlank(query)) {
                this.query = shareObject.Query_Statement__c;
            }else {
                this.query = query;
            }
        }
    }
    // wfc
    public Share_Common_IntegrationBatch(
        String objectName, 
        Boolean isCallSchedulable, 
        String schedulableName, 
        Integer nextSchedulableTime,
        String query,
        Boolean isNeedChange
    ) {
        this.objectName = objectName;
        this.isCallSchedulable = isCallSchedulable;
        this.schedulableName = schedulableName;
        this.nextSchedulableTime = nextSchedulableTime;
        this.isNeedChange = isNeedChange != null ? isNeedChange : false;

        List<Share_Object__c> soList = Share_Common_IntegrationService.queryShareObject(objectName);

        if (soList.isEmpty()) {
            this.query = 'SELECT Id FROM ' + objectName;
        }else {
            Share_Object__c shareObj = soList[0];
            this.shareObject = shareObj;
            if (String.isBlank(query)) {
                this.query = shareObject.Query_Statement__c;
            }else {
                this.query = query;
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        System.debug('www*** scope: ' + scope);
        Share_Common_IntegrationService.shareData(objectName, JSON.serialize(scope), '', this.isNeedChange);

        //检查记录是否存在锁定, 锁定解锁后更新, 再进行锁定
        List<Id> checkLockRecordList = new List<Id>();

        //需要进行锁定的记录
        List<String> lockRecordList = new List<String>();

        // 取消IsNew标记
        for(Sobject sObj : scope){
            sObj.put('IsNew__c', false);
            sObj.put('IsChange__c', false);
            checkLockRecordList.add(Id.valueOf(String.valueOf(sObj.get('Id'))));
        }

        //解锁记录
        lockRecordList = Utility.getLockRecord(checkLockRecordList);

        if(!scope.isEmpty() && objectName != 'Customer_Visit__c') {
            UPDATE scope;
        }

        //锁定记录
        for(String strId : lockRecordList){
            Approval.lock(Id.valueOf(strId), false);
        }
    }

    global void finish(Database.BatchableContext BC) {

        System.debug(LoggingLevel.INFO, '*** isCallSchedulable: ' + isCallSchedulable); 
        if (isCallSchedulable) {

            //运行定时任务
            String fmt = Utility.nextSchedulableTime(nextSchedulableTime);
            String scheduledJob = schedulableName + '_' + fmt + '_' + shareObject.Id;
            Type t = Type.forName(schedulableName);
            Schedulable classInstance = (Schedulable)t.newInstance();
            System.schedule(scheduledJob, fmt, classInstance);
        }
    }
}