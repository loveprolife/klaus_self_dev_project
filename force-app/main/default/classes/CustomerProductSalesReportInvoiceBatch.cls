global class CustomerProductSalesReportInvoiceBatch implements Database.Batchable<sObject> {
    public String query;
    public List<String> salesRegion;
    public String salesRegionStr;
    public Date orderDate;
    public String customerType;
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();

    global CustomerProductSalesReportInvoiceBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion.split(',');
        this.salesRegionStr = salesRegion;
        this.orderDate = Date.valueOf(orderDate);
        this.query = 'SELECT id,Invoice__r.Invoice_Posting_Date__c, SAP_Customer_Model_Product__c, Invoice_Quantity__c, Hisense_Entity__c, ' +
                            ' Total_Amount_After_Rebate__c, CurrencyIsoCode, Invoice__r.Customer__c, Customer_Sales_Region__c, Product_Line__c ' +
                            ' FROM Invoice_Item__c ' +
                            ' WHERE Hisense_Entity__c in :salesRegion ' +
                            ' AND SAP_Customer_Model_Product__c != null ' +
                            ' AND Invoice__r.Invoice_Posting_Date__c >= :orderDate ';
        
        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Invoice_Item__c> invoiceItemList) {
        
        Set<String> productSet = new Set<String>();
        Set<String> keySet = new Set<String>();
        for(Invoice_Item__c ii : invoiceItemList){
            String customer = ii.Invoice__r.Customer__c;
            String product =  ii.SAP_Customer_Model_Product__c;
            String orderDate =  String.valueOf(ii.Invoice__r.Invoice_Posting_Date__c);
            keySet.add(orderDate + '-' + customer + '-' + product);
            productSet.add(product);
        }
        // 客户订单库存表集合
        List<Customer_Product_Sales_Report__c> cpsrList = [SELECT id, key__c, Quantity_Invoice__c, Sales_Invoice__c FROM Customer_Product_Sales_Report__c WHERE key__c IN:keySet];
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

        for(Invoice_Item__c ii : invoiceItemList){
            // 汇率转换
            Decimal rate = currencyRateMap.get(ii.CurrencyIsoCode);

            Decimal quantity = ii.Invoice_Quantity__c;
            Decimal sales = ii.Total_Amount_After_Rebate__c / rate;
            String customer = ii.Invoice__r.Customer__c;
            String product = ii.SAP_Customer_Model_Product__c;
            String orderDate = String.valueOf(ii.Invoice__r.Invoice_Posting_Date__c);
            String key = orderDate + '-' + customer + '-' + product;

            if(keyMap.containsKey(key)){
                keyMap.get(key).Quantity_Invoice__c = keyMap.get(key).Quantity_Invoice__c + quantity;
                keyMap.get(key).Sales_Invoice__c = keyMap.get(key).Sales_Invoice__c + sales;
            }else {
                Customer_Product_Sales_Report__c cpsr = new Customer_Product_Sales_Report__c();
                cpsr.key__c = key;
                cpsr.Customer__c = customer;
                cpsr.Product_Code__c = product;
                cpsr.Product_Line__c = ii.Product_Line__c;
                cpsr.Quantity_Invoice__c = quantity;
                cpsr.Sales_Invoice__c = sales;
                cpsr.CurrencyIsoCode = 'USD';
                cpsr.Statistical_Date__c = ii.Invoice__r.Invoice_Posting_Date__c;
                cpsr.Data_Source__c = 'SAP';
                cpsr.Sales_Region__c = ii.Customer_Sales_Region__c;
                cpsr.Entity__c = ii.Hisense_Entity__c;
                // 查询是否有指导价格
                Product__c p = productMap.get(product + ii.Customer_Sales_Region__c);
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
        Utility.insertLog('CustomerProductSalesReportInvoiceBatch', '1', JSON.serialize(this.salesRegion), String.valueOf(Datetime.now()));
        CustomerProductSalesReport1Batch ss  = new CustomerProductSalesReport1Batch(this.salesRegionStr,String.valueOf(this.orderDate));
        Database.executeBatch(ss);
    }
}