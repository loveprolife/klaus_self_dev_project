/*
 * @Author: WFC
 * @Date: 2024-01-12 14:24:21
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-17 09:36:41
 * @Description: 
 * 执行方法 Database.executeBatch(new RealTimeInventoryInitializeBatch('Hisense South Africa', '2023-01-01'), 40);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\RealTimeInventoryInitializeBatch.cls
 */
global class RealTimeInventoryInitializeBatch implements Database.Batchable<sObject> {

    public String salesRegion;// 国家
    public Date orderDate;// 日期
    public String query;

    global RealTimeInventoryInitializeBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT Customer__c ,Product_Name__c ' + 
                     ' FROM Real_Time_Inventory_Sub__c ' +
                     ' WHERE Sales_Region__c = :salesRegion ';
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Real_Time_Inventory_Sub__c> rtisList) {
        List<Real_Time_Inventory__c> addList1 = new List<Real_Time_Inventory__c>();
        List<Real_Time_Inventory__c> addList2 = new List<Real_Time_Inventory__c>();
        Date todayDate = Date.today();
        Integer j = 1;
        for(Real_Time_Inventory_Sub__c op : rtisList){
            // 客户id
            String accId = op.Customer__c;
            // 产品名称
            String productName = op.Product_Name__c;
            for(Integer i = 0; this.orderDate.daysBetween(todayDate) > i; i++){
                j++;
                Date inventoryDate = this.orderDate.addDays(i);
                Real_Time_Inventory__c rti = new Real_Time_Inventory__c();
                rti.Customer__c = accId;
                rti.Inventory_Date__c = inventoryDate;
                rti.Product_Name__c = productName;
                rti.Key__c = inventoryDate + '-' + accId + '-' + productName;
                rti.Sell_In_Number__c = 0;
                rti.Sell_Out_Number__c = 0;
                // 超过限制数据开启异步处理
                if(j < 9999){
                    addList1.add(rti);
                }else {
                    addList2.add(rti);
                }
                
            }  
        }
        insert addList1;
        if(addList2.size() > 0 && !Test.isRunningTest()){
            String jobID = System.enqueueJob(new RealTimeInventoryAsyncSync(addList2));
            system.Debug('www======== jobID==='+jobID);
        }
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('RealTimeInventoryInitializeBatch', '1', this.salesRegion + '-' + this.orderDate, String.valueOf(Datetime.now()));

        RealTimeInventorySellInBatch ss  = new RealTimeInventorySellInBatch(this.salesRegion, String.valueOf(this.orderDate));
        Database.executeBatch(ss);
    }

    //异步调用接口同步客户到SAP
    public class RealTimeInventoryAsyncSync implements Queueable, Database.AllowsCallouts {
        public List<Real_Time_Inventory__c> addList { get; set; }
        public RealTimeInventoryAsyncSync(List<Real_Time_Inventory__c> rtiList){
            addList = rtiList;
        }
        public void execute(QueueableContext context) {
            insert addList;
        }
    }
}