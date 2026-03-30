global without sharing class ExhibitionSSOVerifyBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable {
    private final static String  PARAMS_PREFIX = 'uid=';
    public String query;
    public Id exId;
    //定时任务
    global void execute(SchedulableContext sc) {
        ExhibitionSSOVerifyBatch st = new ExhibitionSSOVerifyBatch(exId);
        Database.executeBatch(st,10);
    }
    global ExhibitionSSOVerifyBatch(Id expoId) {
        this.exId = expoId;
        // this.query = 'SELECT Id,Is_Verify__c,XHNumber__c,Department_Name__c,Department_Code__c,Is_Present__c,Last_Verified_Date__c '
        // +'FROM Internal_Registration__c WHERE  Exhibition_Id__c=: expoId AND XHNumber__c <> NULL AND Is_Present__c = TRUE AND '
        // +'Exhibition_Id__r.LastRegistrationDate__c >= TODAY AND Exhibition_Id__r.Is_Verify_Batch__c = FALSE';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        query = 'SELECT Id,Is_Verify__c,XHNumber__c,Department_Name__c,Department_Code__c,Is_Present__c,Last_Verified_Date__c,Name_CN__c, Position__c, Email__c, Phone__c '
        +'FROM Internal_Registration__c WHERE  Exhibition_Id__c=: exId AND XHNumber__c <> NULL AND Is_Present__c = TRUE AND '
        +'Exhibition_Id__r.LastRegistrationDate__c >= TODAY AND Exhibition_Id__r.Is_Verify_Batch__c = TRUE AND Is_Verify_Batch__c = TRUE';
        System.debug('exId--->'+exId);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Internal_Registration__c> scope) {
        System.debug('ExhibitionSSOVerifyBatch====================');
        try {
            verifyRecords(scope);
        }
        catch (Exception e) {
            System.debug('ExhibitionSSOVerifyBatch---->'+e.getLineNumber()+e.getMessage());
        }
        
    }

    global void finish(Database.BatchableContext BC) {
        //总Batch跑完
        for (ExpoInfo__c item: [SELECT Id, Is_Verify_Batch__c FROM ExpoInfo__c WHERE Id=:exId AND Is_Verify_Batch__c = TRUE]) {
                    item.Is_Verify_Batch__c = FALSE;
                    UPDATE item;
                }
        List<Internal_Registration__c> failList = new List<Internal_Registration__c>();
        for (Internal_Registration__c item1: [SELECT Id, Is_Verify_Batch__c,Verify_Result__c,Is_Verify__c,Last_Verified_Date__c FROM Internal_Registration__c 
            WHERE Exhibition_Id__c=: exId AND Is_Verify_Batch__c = TRUE]) {
            if (item1.Is_Verify_Batch__c) {
                item1.Is_Verify_Batch__c = FALSE;
                item1.Verify_Result__c = 'LDAP校验接口调用,验证未通过(Batch调用),未成功获取Ldap账号信息(信鸿号未匹配)';
                item1.Is_Verify__c = TRUE;
                item1.Last_Verified_Date__c = System.now();
                failList.add(item1);
            }
        }
        if (failList.size() > 0) UPDATE failList;
            
        
        System.debug('=========ExhibitionSSOVerifyBatch Finish============');
    }

    global void verifyRecords(List<Internal_Registration__c> intRegList) {
        String xhStrs = '';
        Map<String, Internal_Registration__c> xhMap = new Map<String, Internal_Registration__c>();
        for (Internal_Registration__c item: intRegList) {
            xhStrs=xhStrs+PARAMS_PREFIX+item.XHNumber__c+',';
            xhMap.put(item.XHNumber__c.toUpperCase(), item);
        }
        xhStrs.removeEnd(',');
        System.debug('xhStrs-->'+xhStrs);
        System.debug('xhMap'+xhMap);

        ExhibitionSSOVerify.VerifyData verifyData = ExhibitionSSOVerify.verifyInternalRegistration(xhStrs);
        List<Internal_Registration__c> intRegUpdateList = new List<Internal_Registration__c>();
        if (verifyData.code == 0 && verifyData.data.size() > 0) {//成功
            for (ExhibitionSSOVerify.Data item1: verifyData.data) {
                System.debug('item1'+item1);
                Internal_Registration__c ir = xhMap.get(item1.uid.toUpperCase());
                System.debug('ir-->'+ir);
                System.debug('item.ou-->'+item1.ou);
                if (ir != NULL) {
                    if(item1.ou != NULL) ir.Department_Name__c = item1.ou;
                    ir.Department_Code__c = item1.departmentNumber;
                    if(item1.cn != NULL) ir.Name_CN__c = verifyData.data[0].cn;//姓名
                    if(item1.title != NULL) ir.Position__c = verifyData.data[0].title;//岗位
                    if(item1.mail != NULL) ir.Email__c = verifyData.data[0].mail;//邮箱
                    if(item1.mobile != NULL) ir.Phone__c = verifyData.data[0].mobile;//电话
                    ir.Is_Verify__c = TRUE;
                    ir.Last_Verified_Date__c = System.now();
                    ir.Verify_Result__c = 'LDAP校验接口调用,验证通过(Batch调用),成功获取Ldap账号信息';
                    ir.Is_Verify_Batch__c = FALSE;
                    intRegUpdateList.add(ir);
                }
            }
            if (intRegUpdateList.size() > 0) UPDATE intRegUpdateList;
        }
    }
}