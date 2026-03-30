/*
 * @Author: WFC
 * @Date: 2024-04-11 15:20:56
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-11 17:20:19
 * @Description: 东盟报表
 SalesTargetReportBatch ss  = new SalesTargetReportBatch();
 Database.executeBatch(ss);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\SalesTargetReportBatch.cls
 */
global withOut sharing class SalesTargetReportBatch implements Database.Batchable<sObject>{
    public String query;

    global SalesTargetReportBatch(){
        this.query = 'SELECT id, CurrencyIsoCode, Total_Price__c, Store_Inspection_Manage__c, Daily_Sales__c, Daily_Sales__r.Status__c, Daily_Sales__r.Shop__c ' + 
                 ' FROM Store_Inspection_Manage_Daily_Sales__c ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Store_Inspection_Manage_Daily_Sales__c> simdsList){
        List<Sales_Target_Report__c> addList = new List<Sales_Target_Report__c>();
        Set<Id> shopIdSet = new Set<Id>();
        Map<Id, List<Id>> rpMap = new Map<Id, List<Id>>();
        for (Store_Inspection_Manage_Daily_Sales__c simds : simdsList){
            shopIdSet.add(simds.Daily_Sales__r.Shop__c);
        }
        List<Responsible_Person__c> rpList = [SELECT Id, Shop_Name__c, Principal__c
                                              FROM Responsible_Person__c
                                              WHERE Shop_Name__c IN:shopIdSet AND RecordType__c IN ('巡店员', 'Backup Floorwalker')];
        for (Responsible_Person__c rp : rpList){
            if (rpMap.containsKey(rp.Shop_Name__c)){
                rpMap.get(rp.Shop_Name__c).add(rp.Principal__c);
            } else{
                rpMap.put(rp.Shop_Name__c, new List<Id>{ rp.Principal__c });
            }
        }

        for (Store_Inspection_Manage_Daily_Sales__c simds : simdsList){
            List<Id> userList = rpMap.get(simds.Daily_Sales__r.Shop__c);
            if (userList != null && userList.size() > 0){
                for (Id uId : userList){
                    Sales_Target_Report__c str = new Sales_Target_Report__c();
                    str.CurrencyIsoCode = simds.CurrencyIsoCode;
                    str.Daily_Sales__c = simds.Daily_Sales__c;
                    str.Inspection_Status__c = simds.Daily_Sales__r.Status__c;
                    str.Key__c = simds.Store_Inspection_Manage__c + '-' + simds.Daily_Sales__c + '-' + uId;
                    str.Store_Inspection_Manage__c = simds.Store_Inspection_Manage__c;
                    str.Total_Price__c = simds.Total_Price__c;
                    str.User__c = uId;
                    addList.add(str);
                }
            }
        }
        Database.upsert (addList, Sales_Target_Report__c.Fields.Key__c, false);
    }

    global void finish(Database.BatchableContext BC){
        Utility.refreshReportCustom('SalesTargetReportClearBatch');
    }

}