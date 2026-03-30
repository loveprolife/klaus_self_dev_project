/*
 * @Author: WFC
 * @Date: 2023-11-28 10:49:05
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-24 10:10:53
 * @Description: CustomerOrderInventoryDailyBatch ss  = new CustomerOrderInventoryDailyBatch('8110', '2023-01-01');
		Database.executeBatch(ss);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\CustomerOrderInventoryDailyBatch.cls
 */
global class CustomerOrderInventoryDailyBatch implements Database.Batchable<sObject> {
    public String query;
    public Date orderDate;
    public String entity;

    global CustomerOrderInventoryDailyBatch (String entity, String orderDate) {
        this.entity = entity;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT Id, Number__c, Customer__c, Customer__r.SAP_Customer_Code__c,Product__r.name,Product__r.Product_Line__c, '+
                     'Shop__c, PromoterDailyReport__r.Sales_Region__c, ReportDate__c, CurrencyIsoCode, TotalPrice__c ' + 
                     ' FROM Retail_Number__c where IsUpload__c = true ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Retail_Number__c> dailySalesList) {
        Boolean inventoryFlag = Statistics_Flag__c.getValues('Customer Order Inventory').Flag__c;
        Boolean manageFlag = Statistics_Flag__c.getValues('Store Inspection Manage').Flag__c;
        Set<String> keySet = new Set<String>();
        Set<String> StoreInspectionManageKeySet = new Set<String>();
        Map<String, String> coiMap = new Map<String, String>();
        List<Customer_Order_Inventory_Daily__c> addList = new List<Customer_Order_Inventory_Daily__c>();
        List<Store_Inspection_Manage_Daily_Sales__c> addListInspection = new List<Store_Inspection_Manage_Daily_Sales__c>();
        for (Retail_Number__c dailySales : dailySalesList) {
            dailySales.IsUpload__c = false;
            keySet.add(dailySales.Customer__r.SAP_Customer_Code__c + '-' + dailySales.Product__r.Product_Line__c + '-' + dailySales.Product__r.name);
            StoreInspectionManageKeySet.add(dailySales.PromoterDailyReport__r.Sales_Region__c + '-' + dailySales.ReportDate__c.year() + '-' + dailySales.ReportDate__c.month() + '-' + dailySales.Product__r.Product_Line__c + '-销售额');
            StoreInspectionManageKeySet.add(dailySales.PromoterDailyReport__r.Sales_Region__c + '-' + dailySales.ReportDate__c.year() + '-' + dailySales.ReportDate__c.month() + '-'+ dailySales.Product__r.Product_Line__c + '-销售额-' + dailySales.Shop__c);
        }
        // 查询Customer_Order_Inventory__c表数据
        List<Customer_Order_Inventory__c> coiList = [SELECT Id, key__c FROM Customer_Order_Inventory__c WHERE key__c IN :keySet];
        for(Customer_Order_Inventory__c coi : coiList){
            coiMap.put(coi.key__c, coi.Id);
        }
        // 查询Store_Inspection_Manage__c表数据
        List<Store_Inspection_Manage__c> simList = [SELECT Id, key__c FROM Store_Inspection_Manage__c WHERE key__c IN :StoreInspectionManageKeySet];
        for(Store_Inspection_Manage__c sim : simList){
            coiMap.put(sim.key__c, sim.Id);
        }
        for (Retail_Number__c dailySales : dailySalesList) {
            String key = dailySales.Customer__r.SAP_Customer_Code__c + '-' + dailySales.Product__r.Product_Line__c + '-' + dailySales.Product__r.name;
            String keyInventory = dailySales.PromoterDailyReport__r.Sales_Region__c + '-' + dailySales.ReportDate__c.year() + '-' + dailySales.ReportDate__c.month() + '-' + dailySales.Product__r.Product_Line__c + '-销售额';
            String keyInventoryStore = dailySales.PromoterDailyReport__r.Sales_Region__c + '-' + dailySales.ReportDate__c.year() + '-' + dailySales.ReportDate__c.month() + '-' + dailySales.Product__r.Product_Line__c + '-销售额-' + dailySales.Shop__c;
            if(String.isNotBlank(coiMap.get(key)) && inventoryFlag){
                Customer_Order_Inventory_Daily__c coid = new Customer_Order_Inventory_Daily__c();
                coid.Customer_Order_Inventory__c = coiMap.get(key);
                coid.Daily_Sales__c = dailySales.Id;
                coid.Quantity__c = dailySales.Number__c;
                coid.Key__c = coiMap.get(key) + '-' + dailySales.Id;
                addList.add(coid);
            }
            
            if(String.isNotBlank(coiMap.get(keyInventory)) && manageFlag){
                Store_Inspection_Manage_Daily_Sales__c simds = new Store_Inspection_Manage_Daily_Sales__c();
                simds.Daily_Sales__c = dailySales.id;
                simds.Total_Price__c = dailySales.TotalPrice__c;
                simds.CurrencyIsoCode = dailySales.CurrencyIsoCode;
                simds.Store_Inspection_Manage__c = coiMap.get(keyInventory);
                simds.Key__c = coiMap.get(keyInventory) + '-' + dailySales.id;
                addListInspection.add(simds);
            }
            if(String.isNotBlank(coiMap.get(keyInventoryStore)) && manageFlag){
                Store_Inspection_Manage_Daily_Sales__c simds = new Store_Inspection_Manage_Daily_Sales__c();
                simds.Daily_Sales__c = dailySales.id;
                simds.Total_Price__c = dailySales.TotalPrice__c;
                simds.CurrencyIsoCode = dailySales.CurrencyIsoCode;
                simds.Store_Inspection_Manage__c = coiMap.get(keyInventoryStore);
                simds.Key__c = coiMap.get(keyInventoryStore) + '-' + dailySales.id;
                addListInspection.add(simds);
            }
        }
        Database.upsert(addList, Customer_Order_Inventory_Daily__c.Fields.Key__c, false);
        Database.upsert(addListInspection, Store_Inspection_Manage_Daily_Sales__c.Fields.key__c, false);
        Database.update(dailySalesList);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('CustomerOrderInventoryDailyBatch', '1', this.entity + '-' + this.orderDate, String.valueOf(Datetime.now()));
        CustomerOrderInventoryVerifyBatch ss  = new CustomerOrderInventoryVerifyBatch(this.entity);
		Database.executeBatch(ss, 5);
    }
       
}