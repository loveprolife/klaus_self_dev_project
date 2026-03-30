/*
 * @Author: WFC
 * @Date: 2024-01-15 09:17:16
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-17 10:33:35
 * @Description: Database.executeBatch(new RealTimeInventorySellOutBatch('Hisense South Africa', '2023-01-01'));
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\RealTimeInventorySellOutBatch.cls
 */
global class RealTimeInventorySellOutBatch implements Database.Batchable<sObject> {

    public String salesRegion;// 国家
    public Date orderDate;// 日期
    public String query;

    global RealTimeInventorySellOutBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT id, Customer__c, ReportDate__c, Product__r.Name, Number__c,Shop__r.Account__c '+
                        ' FROM Retail_Number__c '+
                        ' WHERE Store_Sales_Region__c  = :salesRegion '+
                        ' AND ReportDate__c >= :orderDate ';
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Retail_Number__c> dailySalesList) {
        Set<String> keySet = new Set<String>();
        Map<String, Real_Time_Inventory__c> rtiMap = new Map<String, Real_Time_Inventory__c>();
        for(Retail_Number__c dailySales : dailySalesList){
            // dailySales日期
            String dailySalesDate = dailySales.ReportDate__c + '';
            // 客户id
            String accId = String.isNotBlank(dailySales.Customer__c) ? dailySales.Customer__c : dailySales.Shop__r.Account__c;
            // 产品名称
            String productName =  dailySales.Product__r.Name;
            // 报表唯一值key
            String key = dailySalesDate + '-' + accId + '-' + productName;
            keySet.add(key);
        }
        // 查询报表Real_Time_Inventory__c
        List<Real_Time_Inventory__c> rtiList = [SELECT Id, Key__c, Sell_Out_Number__c FROM Real_Time_Inventory__c WHERE Key__c IN :keySet];
        for(Real_Time_Inventory__c rti : rtiList){
            rtiMap.put(rti.key__c, rti);
        }

        for(Retail_Number__c dailySales : dailySalesList){
            Decimal quantity = dailySales.Number__c;
            // dailySales日期
            String dailySalesDate = dailySales.ReportDate__c + '';
            // 客户id
            String accId = String.isNotBlank(dailySales.Customer__c) ? dailySales.Customer__c : dailySales.Shop__r.Account__c;
            // 产品名称
            String productName =  dailySales.Product__r.Name;
            // 报表唯一值key
            String key = dailySalesDate + '-' + accId + '-' + productName;
            if(rtiMap.containsKey(key)){
                rtiMap.get(key).Sell_Out_Number__c = rtiMap.get(key).Sell_Out_Number__c + quantity;
            }
        }

        Database.upsert(rtiMap.values(), Real_Time_Inventory__c.Fields.Key__c, false);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('RealTimeInventorySellOutBatch', '1', this.salesRegion + '-' + this.orderDate, String.valueOf(Datetime.now()));

        RealTimeInventoryReportBatch ss  = new RealTimeInventoryReportBatch(this.salesRegion, String.valueOf(this.orderDate));
        Database.executeBatch(ss, 10);
    }
}