/*
 * @Author: WFC
 * @Date: 2023-11-15 10:06:55
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-29 11:26:30
 * @Description: CustomerProductSalesReportBatch ss  = new CustomerProductSalesReportBatch('Hisense Indonesia,Hisense Vietnam,Hisense Philippines,Hisense Malaysia,Hisense Thailand','2023-07-01');
        Database.executeBatch(ss);
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\CustomerProductSalesReportBatch.cls
 */
global class CustomerProductSalesReportBatch implements Database.Batchable<sObject> {
    public String query;
    public List<String> salesRegion;
    public String salesRegionStr;
    public Date orderDate;
    public String customerType;
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();

    global CustomerProductSalesReportBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion.split(',');
        this.salesRegionStr = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT id,Order__r.Order_Date__c,SAP_Product_Customer_Model__c,Quantity__c, Unit_Price__c,CurrencyIsoCode,Order__r.Customer__c,Customer_Sales_Region__c,Product_Line__c,Hisense_Entity__c ' +
                            ' FROM Order_Product__c ' +
                            ' WHERE Order__r.Hisense_Entity__c in :salesRegion ' +
                            ' AND SAP_Product_Customer_Model__c != null ' +
                            ' AND Order__r.Order_Date__c >= :orderDate ' +
                            ' AND Order__r.Customer__r.channel__c != \'零售\' ';
        
        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order_Product__c> orderProductList) {
        
        Set<String> productSet = new Set<String>();
        Set<String> keySet = new Set<String>();
        for(Order_Product__c op : orderProductList){
            String customer = op.Order__r.Customer__c;
            String product =  op.SAP_Product_Customer_Model__c;
            String orderDate =  String.valueOf(op.Order__r.Order_Date__c);
            keySet.add(orderDate + '-' + customer + '-' + product);
            productSet.add(product);
        }
        // 客户订单库存表集合
        List<Customer_Product_Sales_Report__c> cpsrList = [SELECT id, key__c, Quantity__c, Sales__c FROM Customer_Product_Sales_Report__c WHERE key__c IN:keySet];
        // 客户订单库存表map
        Map<String, Customer_Product_Sales_Report__c> keyMap = new Map<String, Customer_Product_Sales_Report__c>();
        for (Customer_Product_Sales_Report__c cpsr : cpsrList) {
            keyMap.put(cpsr.key__c, cpsr);
        }

        // 产品表集合
        List<Product__c> productList = [SELECT id, Name, sales_region__c,Guiding_Price__c,CurrencyIsoCode FROM Product__c WHERE Name IN:productSet ORDER BY Guiding_Price__c NULLS FIRST];
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product : productList){
            productMap.put(product.name + product.sales_region__c, product);
        }

        for(Order_Product__c op : orderProductList){
            // 汇率转换
            Decimal rate = currencyRateMap.get(op.CurrencyIsoCode);

            Decimal quantity = op.Quantity__c;
            Decimal sales = op.Unit_Price__c  / rate;
            String customer = op.Order__r.Customer__c;
            String product =  op.SAP_Product_Customer_Model__c;
            String orderDate =  String.valueOf(op.Order__r.Order_Date__c);
            String key = orderDate + '-' + customer + '-' + product;

            if(keyMap.containsKey(key)){
                keyMap.get(key).Quantity__c = keyMap.get(key).Quantity__c + quantity;
                keyMap.get(key).Sales__c = keyMap.get(key).Sales__c + sales;
            }else {
                Customer_Product_Sales_Report__c cpsr = new Customer_Product_Sales_Report__c();
                cpsr.key__c = key;
                cpsr.Customer__c = customer;
                cpsr.Product_Code__c = product;
                cpsr.Product_Line__c = op.Product_Line__c;
                cpsr.Quantity__c = quantity;
                cpsr.Sales__c = sales;
                cpsr.CurrencyIsoCode = 'USD';
                cpsr.Statistical_Date__c = op.Order__r.Order_Date__c;
                cpsr.Data_Source__c = 'SAP';
                cpsr.Sales_Region__c = op.Customer_Sales_Region__c;
                cpsr.Entity__c = op.Hisense_Entity__c;
                // 查询是否有指导价格
                Product__c p = productMap.get(product + op.Customer_Sales_Region__c);
                if(p != null){
                    Decimal rateProduct = currencyRateMap.get(p.CurrencyIsoCode);
                    cpsr.Product__c = p.Id;
                    cpsr.Guiding_Price__c = p.Guiding_Price__c != null ? p.Guiding_Price__c / rateProduct : null;
                }
                keyMap.put(key, cpsr);
            }
        }
        Database.upsert(keyMap.values(), Customer_Product_Sales_Report__c.Fields.key__c, false);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('CustomerProductSalesReportBatch', '1', JSON.serialize(this.salesRegion), String.valueOf(Datetime.now()));
        // CustomerProductSalesReportInvoiceBatch ss  = new CustomerProductSalesReportInvoiceBatch(this.salesRegionStr,String.valueOf(this.orderDate));
        // Database.executeBatch(ss);
    }
}