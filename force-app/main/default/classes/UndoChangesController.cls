/**************************************************************************************************
 * Name:UndoChangesController
 * Purpose:客户、拓展、银行撤销更改
 * Author: lizunxing
 * Create Date: 2025-01-22
***************************************************************************************************/
global  without sharing class UndoChangesController{

    public class ResultData {
        public String code;
        public String msg;
    }

    @AuraEnabled 
    public static String initData(String recordIdStr){

        ResultData resDate = new ResultData();
        resDate.code = '0';

        Id recordId = (Id)recordIdStr;
        SObjectType objectType = recordId.getSObjectType();
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        String objectName = describeResult.getName();

        List<Customer_Extend_Bank_History__c>  cebhList = 
            [SELECT id, Record_id__c, Record_type__c, Record_body__c, Process_cause__c FROM Customer_Extend_Bank_History__c  
            WHERE Record_id__c =:recordId and Process_cause__c = '变更' order by CreatedDate desc limit 1];
        if(cebhList == null || cebhList.size() == 0){
            resDate.code = '1';
            resDate.msg = Label.Undo_Changes_Not_found;
            return JSON.serialize(resDate);
        }

        Customer_Extend_Bank_History__c cebh = cebhList.get(0);
        if('Account'.equals(objectName)){
            Account account = (Account)JSON.deserialize(cebh.Record_body__c, Account.class);

            String sql = 'select ' + Utility.getAllFields(objectType) + ' from Account where id =:recordId limit 1';

            Account oldRecord = (Account)Database.query(sql).get(0);

            String oldBodyJson = JSON.serialize(oldRecord);
            String newBodyJson = JSON.serialize(account);
            Utility.insertCusHistoyr(recordIdStr, 'Account', '撤销变更', oldBodyJson, newBodyJson);
            
            try {
                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'AccountTriggerHandler');
                update account;
                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
            } catch (Exception e) {
                resDate.code = '1';
                resDate.msg = e.getMessage();
                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
            }
        }else if('Customer_Extend__c'.equals(objectName)){
            Customer_Extend__c ce = (Customer_Extend__c)JSON.deserialize(cebh.Record_body__c, Customer_Extend__c.class);

            String sql = 'select ' + Utility.getAllFields(objectType) + ' from Customer_Extend__c where id =:recordId limit 1';

            Customer_Extend__c oldRecord = (Customer_Extend__c)Database.query(sql).get(0);

            String oldBodyJson = JSON.serialize(oldRecord);
            String newBodyJson = JSON.serialize(ce);
            Utility.insertCusHistoyr(recordIdStr, 'Customer_Extend__c', '撤销变更', oldBodyJson, newBodyJson);
            
            try {
                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'CustomerExtendTriggerHandler');
                update ce;
                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
            } catch (Exception e) {
                resDate.code = '1';
                resDate.msg = e.getMessage();
                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
            }
        }else if('Customer_Banks__c'.equals(objectName)){
            Customer_Banks__c cb = (Customer_Banks__c)JSON.deserialize(cebh.Record_body__c, Customer_Banks__c.class);

            String sql = 'select ' + Utility.getAllFields(objectType) + ' from Customer_Banks__c where id =:recordId limit 1';

            Customer_Banks__c oldRecord = (Customer_Banks__c)Database.query(sql).get(0);

            String oldBodyJson = JSON.serialize(oldRecord);
            String newBodyJson = JSON.serialize(cb);
            Utility.insertCusHistoyr(recordIdStr, 'Customer_Banks__c', '撤销变更', oldBodyJson, newBodyJson);
            
            try {
                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'CustomerBanksTriggerHandler');
                update cb;
                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
            } catch (Exception e) {
                resDate.code = '1';
                resDate.msg = e.getMessage();
                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
            }
            
        }


        System.debug('resDate==>>>' + resDate);

        
        return JSON.serialize(resDate);
    }

    
}