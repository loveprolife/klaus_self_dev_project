/*
 * @Author: WFC
 * @Date: 2024-08-09 15:16:37
 * @LastEditors: WFC
 * @LastEditTime: 2024-08-15 15:38:07
 * @Description: 清空门店规模等级临时表
 StoreLevelTempClearBatch sir = new StoreLevelTempClearBatch();
 Database.executeBatch(sir,200);
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\StoreLevelTempClearBatch.cls
 */
global class StoreLevelTempClearBatch implements Database.Batchable<sObject>{
    public String query;

    global StoreLevelTempClearBatch(){
        this.query = ' SELECT Id, TV_Sales__c, TV_Level__c, Refrigerator_Sales__c, Refrigerator_Level__c,  WM_Sales__c, WM_Level__c,  AC_Sales__c, AC_Level__c, Total_Level__c, Is_New__c ' + 
                 ' FROM Store_Level_Temp__c ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Store_Level_Temp__c> sltList){
        // 清空数据
        for (Store_Level_Temp__c slt : sltList){
            slt.Is_New__c = false;
            slt.TV_Sales__c = null;
            slt.Refrigerator_Sales__c = null;
            slt.WM_Sales__c = null;
            slt.AC_Sales__c = null;
        }
        update sltList;
    }

    global void finish(Database.BatchableContext BC){
        StoreLevelTempBatch sir = new StoreLevelTempBatch();
        Database.executeBatch(sir, 200);
    }

}