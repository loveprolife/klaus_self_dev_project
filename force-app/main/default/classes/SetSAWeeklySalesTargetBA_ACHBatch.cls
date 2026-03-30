/******************************************************************************
 ************************
 * Name: SetSAWeeklySalesTargetBA_CHBatch
 * Description:  设置南非周目标BA_ACH，统计Daily Sales
 * TestClassName:  SetSAWeeklySalesTargetBA_CHBatchTest
 * Version History: 0.01
 * Date: 2024-01-16
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
public with sharing class SetSAWeeklySalesTargetBA_ACHBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    
    public List<Weekly_Sales_Target__c> wstList;
    public Integer year, week;
    public String actionType;

    public SetSAWeeklySalesTargetBA_ACHBatch(List<Weekly_Sales_Target__c> wstList){
        this.wstList = wstList;
    }
    public SetSAWeeklySalesTargetBA_ACHBatch(List<Weekly_Sales_Target__c> wstList, String actionType){
        this.wstList = wstList;
        this.actionType = actionType;
    }
    public SetSAWeeklySalesTargetBA_ACHBatch(List<Weekly_Sales_Target__c> wstList, Integer year, Integer week){
        this.wstList = wstList;
        this.year = year;
        this.week = week;
    }
    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-27
     * @Description: 进入Batch前执行方法
     */
    public Iterable<sObject> start(Database.BatchableContext BC) {
        return wstList;
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-27
     * @Description: 
     */
    public void execute(Database.BatchableContext BC, list<Weekly_Sales_Target__c> wstList) {
        if('insert'.equals(actionType)){
            Database.upsert(wstList,Weekly_Sales_Target__c.Fields.External_key__c,true);
        }
        NewWeeklySalesTargetButtonController.setBA_ACH(wstList);
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-27
     * @Description: 执行完Batch后进入，记录日志
     */
    public void finish(Database.BatchableContext BC) {
        Utility.insertLog('SetSAWeeklySalesTargetBA_CHBatch', '1', '', '');
    }

}