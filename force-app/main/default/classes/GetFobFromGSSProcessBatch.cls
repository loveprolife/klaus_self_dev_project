/**********************************************************************
* Name: GetFobFromGSSProcess
* Object: FOB FOBGSS 
* Purpose: 
* FobGSS中的Batch_Number__c 与 Fob中的Batch_Number__c 关联
* Author: Gerry
* Create Date: 2021-11-11
* 执行方法 Database.executeBatch(new GetFobFromGSSProcessBatch(),200);
*************************************************************************/
global class GetFobFromGSSProcessBatch implements Database.Batchable<sObject> {
    public String query;

    global GetFobFromGSSProcessBatch() {
        this.query = 'select id,FOB_GSS__c,Batch_Number__c from FOB__c where FOB_GSS__c = null and Batch_Number__c != null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<FOB__c> fobList) {
        List<FOB__c> updateFobList = new List<FOB__c>();
        // Fob中的 Batch_Number__c 集合
        List<String> bnList = new List<String>();
        for(FOB__c fob : fobList){
            bnList.add(fob.Batch_Number__c);    
        }

        // 查询FOB GSS中相关数据
        List<FOB_GSS__c> fgList= [select id,Batch_Number__c from FOB_GSS__c where Batch_Number__c =: bnList];
        Map<String, ID> fgMap = new Map<String, ID>();
        for(FOB_GSS__c fg : fgList){
            fgMap.put(fg.Batch_Number__c, fg.id);
        }

        // 处理Fob数据
        for(FOB__c fob : fobList){
            fob.FOB_GSS__c = fgMap.get(fob.Batch_Number__c);
            updateFobList.add(fob);
        }

        update updateFobList;        
        
    }

    global void finish(Database.BatchableContext BC) {

    }
}