global class SC_ComparisonSalesReportShareBatch extends SC_Base implements Database.Batchable<sObject> ,Database.Stateful{
    global SC_ComparisonSalesReportShareBatch() {
        super();
    }

    global SC_ComparisonSalesReportShareBatch(String startDate, String endDate) {
        super(startDate, endDate);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date sd = Date.valueOf(this.startDate);
        Date ed = Date.valueOf(this.endDate);

        this.salesList = Database.query(this.salesQuery 
            + ' AND LastModifiedDate >= :sd '
            + ' AND LastModifiedDate < :ed ALL ROWS');

        this.customerIdSet = new Set<String>();
        for(Sales__c sales: this.salesList){
            this.customerIdSet.add(sales.Customer__c);
        }

        return Database.getQueryLocator(
                [
                SELECT Id,Product_Line_Code__c,Customer__c,OwnerId 
                FROM Comparison_Sales_Report_YoY__c 
                WHERE Product_Line_Code__c != null 
                AND Customer__c  in:customerIdSet
                ]);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        SalesShareService service = new SalesShareService();
        service.shareData(
            scope, 
            this.updatedList(),
            customerIdSet,
            null,
            'Comparison_Sales_Report_YoY__Share',
            'Customer__c',
            'Product_Line_Code__c');

        service.removeShare(scope,
            this.deletedList(),
            null,
            'Comparison_Sales_Report_YoY__Share',
            'Customer__c',
            'Product_Line_Code__c');
    }

    global void finish(Database.BatchableContext BC) {
        SC_SalesTargetShareBatch ss = new SC_SalesTargetShareBatch(this.startDate,this.endDate);
        Database.executeBatch(ss);
    }
}