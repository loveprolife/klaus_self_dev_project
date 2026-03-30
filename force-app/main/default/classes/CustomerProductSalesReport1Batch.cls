/*
 * @Author: WFC
 * @Date: 2023-11-15 10:45:57
 * @LastEditors: WFC
 * @LastEditTime: 2024-06-11 16:18:43
 * @Description: CustomerProductSalesReport1Batch ss  = new CustomerProductSalesReport1Batch('Hisense Indonesia,Hisense Vietnam,Hisense Philippines,Hisense Malaysia,Hisense Thailand','2023-07-01');
        Database.executeBatch(ss);
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\CustomerProductSalesReport1Batch.cls
 */
global class CustomerProductSalesReport1Batch implements Database.Batchable<sObject> {
    public String query;
    public List<String> salesRegion;
    public Date orderDate;
    public String customerType;
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();

    global CustomerProductSalesReport1Batch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion.split(',');
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT id,Shop__c, Customer__c,Customer__r.Hisense_Entity__c,Product__c,Product__r.Name,Product__r.Guiding_Price__c,Product__r.CurrencyIsoCode,Number__c, TotalPrice__c, '+
                        ' CurrencyIsoCode,ReportDate__c,Store_Sales_Region__c,OwnerId__c,Product_Line__c,Shop_Code_Upload__c,Data_Type__c  '+
                        ' FROM Retail_Number__c '+
                        ' WHERE Customer__r.Hisense_Entity__c in :salesRegion '+
                        ' AND ReportDate__c >= :orderDate ';
                        // ' AND Customer__r.channel__c = \'零售\' ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Retail_Number__c> dailySalesList) {
        System.debug('www--' + dailySalesList.size());
        Set<String> keySet = new Set<String>();
        for(Retail_Number__c rn : dailySalesList){
            String customer = rn.Customer__c;
            String shop = rn.Shop__c;
            String shopCode = rn.Shop_Code_Upload__c;
            String dataType = rn.Data_Type__c;
            String product =  rn.Product__r.Name;
            String reportDate =  String.valueOf(rn.ReportDate__c);
            String userId =  rn.OwnerId__c;
            keySet.add(reportDate + '-' + customer + '-' + shop + '-' + product + '-' + userId + '-' + shopCode);
        }
        // 客户订单库存表集合
        List<Customer_Product_Sales_Report__c> cpsrList = [SELECT id, key__c, Quantity_Invoice__c, Sales_Invoice__c FROM Customer_Product_Sales_Report__c WHERE key__c IN:keySet];
        // 客户订单库存表map
        Map<String, Customer_Product_Sales_Report__c> keyMap = new Map<String, Customer_Product_Sales_Report__c>();
        for (Customer_Product_Sales_Report__c cpsr : cpsrList) {
            keyMap.put(cpsr.key__c, cpsr);
        }
        for(Retail_Number__c rn : dailySalesList){
            // 汇率转换
            Decimal rate = currencyRateMap.get(rn.CurrencyIsoCode);
            Decimal rateProduct = currencyRateMap.get(rn.Product__r.CurrencyIsoCode);
            Decimal quantity = rn.Number__c;
            Decimal sales = rn.TotalPrice__c / rate;
            String customer = rn.Customer__c;
            String shop = rn.Shop__c;
            String shopCode = rn.Shop_Code_Upload__c;
            String dataType = rn.Data_Type__c;
            String product =  rn.Product__r.Name;
            String reportDate =  String.valueOf(rn.ReportDate__c);
            String userId =  rn.OwnerId__c;
            String key = reportDate + '-' + customer + '-' + shop + '-' + product + '-' + userId + '-' + shopCode;

            if(keyMap.containsKey(key)){
                keyMap.get(key).Quantity_Invoice__c = keyMap.get(key).Quantity_Invoice__c + quantity;
                keyMap.get(key).Sales_Invoice__c = keyMap.get(key).Sales_Invoice__c + sales;
            }else {
                Customer_Product_Sales_Report__c cpsr = new Customer_Product_Sales_Report__c();
                cpsr.key__c = key;
                cpsr.Customer__c = customer;
                cpsr.Product_Code__c = product;
                cpsr.Product_Line__c = rn.Product_Line__c;
                cpsr.Store__c = rn.Shop__c;
                cpsr.Store_Code__c = rn.Shop_Code_Upload__c;
                cpsr.Data_Type__c = rn.Data_Type__c;
                cpsr.Quantity_Invoice__c = quantity;
                cpsr.Sales_Invoice__c = sales;
                cpsr.User__c = userId;
                cpsr.CurrencyIsoCode = 'USD';
                cpsr.Statistical_Date__c = rn.ReportDate__c;
                cpsr.Data_Source__c = 'Daily Sales';
                cpsr.Sales_Region__c = rn.Store_Sales_Region__c;
                cpsr.Guiding_Price__c = rn.Product__r.Guiding_Price__c != null ? rn.Product__r.Guiding_Price__c / rateProduct : null;
                cpsr.Product__c = rn.Product__c;
                cpsr.Entity__c = rn.Customer__r.Hisense_Entity__c;
                keyMap.put(key, cpsr);
            }
        }
        Database.upsert(keyMap.values(), Customer_Product_Sales_Report__c.Fields.key__c, false);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('CustomerProductSalesReport1Batch', '1', JSON.serialize(this.salesRegion), String.valueOf(Datetime.now()));
        Utility.refreshReportCustom('CustomerProductSalesReportDelBatch');
    }
}