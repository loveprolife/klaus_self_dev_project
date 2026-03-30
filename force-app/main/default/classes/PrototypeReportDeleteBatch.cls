/*
 * @Author: WFC
 * @Date: 2024-03-14 14:57:03
 * @LastEditors: WFC
 * @LastEditTime: 2024-03-20 10:34:31
 * @Description: 清空样机日报表
 PrototypeReportDeleteBatch pr = new PrototypeReportDeleteBatch();
 Database.executeBatch(pr,200);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\PrototypeReportDeleteBatch.cls
 */
global class PrototypeReportDeleteBatch implements Database.Batchable<sObject>{
    public String query;
    global Database.QueryLocator start(Database.BatchableContext bc){
        List<String> salesRegionList = Label.Asean_Region.split(',');
        this.query = ' SELECT id FROM Prototype_Report__c WHERE Sampling_Detail__r.Shop__r.Sales_Region__c IN :salesRegionList ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Prototype_Report__c> prototypeReportList){
        delete prototypeReportList;
    }

    global void finish(Database.BatchableContext BC){
        PrototypeReportBatch pr = new PrototypeReportBatch();
        Database.executeBatch(pr, 200);
    }

}