/*
 * @Author: WFC
 * @Date: 2023-11-15 14:44:32
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-09 14:18:56
 * @Description: 
    CustomerProductSalesReportDelBatch ss  = new CustomerProductSalesReportDelBatch('Hisense Indonesia,Hisense Vietnam,Hisense Philippines,Hisense Malaysia,Hisense Thailand','2023-07-01');
    CustomerProductSalesReportDelBatch ss  = new CustomerProductSalesReportDelBatch('8400,8420,8430','2023-07-01');
    Database.executeBatch(ss);
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\CustomerProductSalesReportDelBatch.cls
 */
global class CustomerProductSalesReportDelBatch implements Database.Batchable<sObject> {
    public String query;
    public List<String> salesRegion;
    public String salesRegionStr;
    public String orderDate;
    public String customerType;
    public Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();

    global CustomerProductSalesReportDelBatch () {
        
    }

    global CustomerProductSalesReportDelBatch (String salesRegion, String orderDate) {
        this.salesRegion = salesRegion.split(',');
        this.salesRegionStr = salesRegion;
        this.orderDate = orderDate;
        this.query = 'SELECT id '+
                        'FROM Customer_Product_Sales_Report__c '+
                        'WHERE Entity__c  in :salesRegion ';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Customer_Product_Sales_Report__c> dailySalesList) {
        Database.delete(dailySalesList);
    }

    global void finish(Database.BatchableContext BC) {
        Utility.insertLog('CustomerProductSalesReportDelBatch', '1', JSON.serialize(this.salesRegion), String.valueOf(Datetime.now()));
        CustomerProductSalesReportInvoiceBatch ss  = new CustomerProductSalesReportInvoiceBatch(this.salesRegionStr,this.orderDate);
        Database.executeBatch(ss);
    }
}