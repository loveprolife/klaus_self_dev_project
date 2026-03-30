/*
 * @Author: WFC
 * @Date: 2024-01-15 13:43:09
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-17 10:33:27
 * @Description: Database.executeBatch(new RealTimeInventoryReportBatch('Hisense South Africa', '2023-01-01'), 10);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\RealTimeInventoryReportBatch.cls
 */
global class RealTimeInventoryReportBatch implements Database.Batchable<sObject> {

    public String salesRegion;// 国家
    public Date orderDate;// 日期
    public String query;

    global RealTimeInventoryReportBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT id, Sell_In_Number__c, Sell_Out_Number__c, Sell_In_Sub_Out__c, Inventory__c, Inventory_Date__c,Product_Name__c,Customer__c, Key__c   '+
                        ' FROM Real_Time_Inventory__c '+
                        ' WHERE Sales_Region__c  = :salesRegion '+
                        ' AND Inventory_Date__c = :orderDate ';
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Real_Time_Inventory__c> rtiList) {
        List<Real_Time_Inventory__c> updateList = new List<Real_Time_Inventory__c>();
        for(Real_Time_Inventory__c rti : rtiList){
            String accId = rti.Customer__c;
            String productName = rti.Product_Name__c;
            // 第一天库存赋值
            rti.Inventory__c = rti.Sell_In_Sub_Out__c;
            updateList.add(rti);
            List<Real_Time_Inventory__c> otherList = [SELECT id, Sell_In_Number__c, Sell_Out_Number__c, Sell_In_Sub_Out__c, Inventory__c
                                                        FROM Real_Time_Inventory__c
                                                        WHERE Customer__c = :accId AND Product_Name__c = :productName
                                                        AND id != :rti.Id
                                                        ORDER BY Inventory_Date__c];
            for(Integer i = 0; otherList.size() > i; i++){
                if(i == 0){
                    otherList[i].Inventory__c = rti.Inventory__c + otherList[i].Sell_In_Sub_Out__c;
                }else{
                    otherList[i].Inventory__c = otherList[i - 1].Inventory__c + otherList[i].Sell_In_Sub_Out__c;
                }
                updateList.add(otherList[i]);
            }
        }
        
        Database.upsert(updateList);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('RealTimeInventoryReportBatch', '1', this.salesRegion + '-' + this.orderDate, String.valueOf(Datetime.now()));
    }
}