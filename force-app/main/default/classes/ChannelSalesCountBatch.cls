global class ChannelSalesCountBatch implements Database.Batchable<sObject>{

    // 是否刷新最近两月的数据
    private Boolean flag;
    // 汇总批处理数据
    static Map<String,Channel_Sales_Count__c> mapChannelSale = new Map<String,Channel_Sales_Count__c>(); 

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // String queryS = 'SELECT Id,Account__c,Account_Name__c,Sales_Region__c,Channel_Code_Formula__c,Channel_Name_Formula__c,Number_Of_Store_Staff__c FROM Shop__c';
        String queryS = 'SELECT Id,Reportyear__c,Sales_Region__c,Reportmonth__c,Shop__c,Product_Line__c,TotalPrice__c,Number__c FROM Retail_Number__c where Shop__c != null';

        return Database.getQueryLocator(queryS);
    }
    global void execute(Database.BatchableContext BC, list<Retail_Number__c> scope) {
        
    }

    global void finish(Database.BatchableContext BC) {
        
    }

}