/*
 * @Author: WFC
 * @Date: 2024-01-15 09:17:15
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-15 13:36:29
 * @Description: Database.executeBatch(new RealTimeInventorySellInBatch('Hisense South Africa', '2023-01-01'));
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\RealTimeInventorySellInBatch.cls
 */
global class RealTimeInventorySellInBatch implements Database.Batchable<sObject> {

    public String salesRegion;// 国家
    public Date orderDate;// 日期
    public String query;

    global RealTimeInventorySellInBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT Order__r.Customer__c, SAP_Product_Customer_Model__c, Order__r.Order_Date__c, Quantity__c ' + 
                     ' FROM Order_Product__c ' +
                     ' WHERE Order__r.Customer__r.SAP_Customer_Code__c != null ' +
                     ' AND SAP_Product_Customer_Model__c != null ' +
                     ' AND Order__r.Order_Classification__c = \'S\' ' + 
                     ' AND Order__r.Order_Date__c >= :orderDate ' +
                     ' AND Order__r.Customer__r.Sales_Region__c = :salesRegion ';
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Order_Product__c> orderList) {
        Set<String> keySet = new Set<String>();
        Map<String, Real_Time_Inventory__c> rtiMap = new Map<String, Real_Time_Inventory__c>();
        for(Order_Product__c op : orderList){
            // 订单日期
            String orderDateStr = op.Order__r.Order_Date__c + '';
            // 客户id
            String accId = op.Order__r.Customer__c;
            // 产品名称
            String productName = op.SAP_Product_Customer_Model__c;
            // 报表唯一值key
            String key = orderDateStr + '-' + accId + '-' + productName;
            keySet.add(key);
        }
        // 查询报表Real_Time_Inventory__c
        List<Real_Time_Inventory__c> rtiList = [SELECT Id, Key__c, Sell_In_Number__c FROM Real_Time_Inventory__c WHERE Key__c IN :keySet];
        for(Real_Time_Inventory__c rti : rtiList){
            rtiMap.put(rti.key__c, rti);
        }

        for(Order_Product__c op : orderList){
            Decimal quantity = op.Quantity__c;
            // 订单日期
            String orderDateStr = op.Order__r.Order_Date__c + '';
            // 客户id
            String accId = op.Order__r.Customer__c;
            // 产品名称
            String productName = op.SAP_Product_Customer_Model__c;
            // 报表唯一值key
            String key = orderDateStr + '-' + accId + '-' + productName;
            if(rtiMap.containsKey(key)){
                System.debug('www--' + rtiMap.get(key));
                rtiMap.get(key).Sell_In_Number__c = rtiMap.get(key).Sell_In_Number__c + quantity;
            }
        }

        Database.upsert(rtiMap.values(), Real_Time_Inventory__c.Fields.Key__c, false);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('RealTimeInventorySellInBatch', '1', this.salesRegion + '-' + this.orderDate, String.valueOf(Datetime.now()));

        RealTimeInventorySellOutBatch ss  = new RealTimeInventorySellOutBatch(this.salesRegion, String.valueOf(this.orderDate));
        Database.executeBatch(ss);
    }
}