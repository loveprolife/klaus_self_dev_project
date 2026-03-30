/*
 * @Author: WFC
 * @Date: 2024-04-11 15:20:56
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-11 16:05:55
 * @Description: 东盟报表清空
 SalesTargetReportClearBatch ss  = new SalesTargetReportClearBatch();
 Database.executeBatch(ss);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\SalesTargetReportClearBatch.cls
 */
global withOut sharing class SalesTargetReportClearBatch implements Database.Batchable<sObject>{
    public String query;

    global SalesTargetReportClearBatch(){
        this.query = 'SELECT Id ' + 
                 ' FROM Sales_Target_Report__c ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sales_Target_Report__c> strList){
        delete strList;
    }

    global void finish(Database.BatchableContext BC){
        SalesTargetReportBatch ss  = new SalesTargetReportBatch();
        Database.executeBatch(ss);
    }

}