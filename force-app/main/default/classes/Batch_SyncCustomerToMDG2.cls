/*
 * @Author: WFC
 * @Date: 2025-11-28 15:42:56
 * @LastEditors: WFC
 * @LastEditTime: 2025-11-28 18:17:47
 * @Description: Database.executeBatch(new Batch_SyncCustomerToMDG2(),1);
 * @FilePath: \testuat\force-app\main\default\classes\Batch_SyncCustomerToMDG2.cls
 */
public without sharing class Batch_SyncCustomerToMDG2 implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public String query;

    public Batch_SyncCustomerToMDG2(){
        this.query = 'SELECT Id, Name FROM Temp_Table__c';
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Temp_Table__c> ttList){
        for (Temp_Table__c tt : ttList){
            if (String.isNotBlank(tt.Name)){
                GetCustomerInfoByCustomerCodeFromSAP2.getCustomerInfo(tt.Name, Date.today().toString().substring(0, 10).replace('-', ''), Date.today().toString().substring(0, 10).replace('-', ''));
            }
        }
        // GetCustomerInfoByCustomerCodeFromSAP2.getCustomerInfo(ttList[0].Name, Date.today().toString().substring(0, 10).replace('-', ''), Date.today().toString().substring(0, 10).replace('-', ''));
    }

    public void finish(Database.BatchableContext bc){
        Utility.insertLog('Batch_SyncCustomerToMDG2', '1', '', '');
    }

}