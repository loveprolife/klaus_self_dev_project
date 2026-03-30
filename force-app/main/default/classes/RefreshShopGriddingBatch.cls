/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-05-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global with sharing class RefreshShopGriddingBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    global RefreshShopGriddingBatch() {
        this.query = 'SELECT Id,City__c,External_Key_ID__c FROM Shop__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Shop__c> queryList) {
        if (!queryList.isEmpty()) {
            UPDATE queryList;
        }
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}