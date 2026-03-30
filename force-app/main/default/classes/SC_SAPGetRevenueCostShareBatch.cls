global class SC_SAPGetRevenueCostShareBatch extends SC_Base implements Database.Batchable<sObject> , Database.Stateful {
    public Set<String> salesIdSet;
    global SC_SAPGetRevenueCostShareBatch() {
        super();
    }

    global SC_SAPGetRevenueCostShareBatch(String startDate, String endDate) {
        super(startDate, endDate);
    }
    global SC_SAPGetRevenueCostShareBatch(String startDate, String endDate, Set<String> salesIdSet){
        super(startDate, endDate);
        this.salesIdSet = salesIdSet;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date sd = Date.valueOf(this.startDate);
        Date ed = Date.valueOf(this.endDate);
        Set<String> sIdSet = this.salesIdSet;
        if(sIdSet != null){
            this.salesQuery += ' AND Sales__c IN:sIdSet';
        }
        this.salesList = Database.query(this.salesQuery 
            + ' AND LastModifiedDate >= :sd '
            + ' AND LastModifiedDate < :ed ALL ROWS');

        this.customerIdSet = new Set<String>();
        for(Sales__c sales: this.salesList){
            this.customerIdSet.add(sales.Customer__c);
        }

        return Database.getQueryLocator([SELECT 
                Id,Product_Line_Text__c,Product_Line__c,Customer__c,OwnerId 
                FROM SAP_Cost_Revenue_Data__c 
                WHERE Product_Line__c != null AND Customer__c in:customerIdSet]);
    }

    global void execute(Database.BatchableContext BC, list<SAP_Cost_Revenue_Data__c> scope) {
        SalesShareService service = new SalesShareService();
        service.shareData(
            scope, 
            this.updatedList(),
            customerIdSet,
            null,
            'SAP_Cost_Revenue_Data__Share',
            'Customer__c',
            'Product_Line__c');

        service.removeShare(
            scope,
            this.deletedList(),
            null,
            'SAP_Cost_Revenue_Data__Share',
            'Customer__c',
            'Product_Line__c');
    }

    global void finish(Database.BatchableContext BC) {
        if(salesIdSet == null){
            SC_ComparisonSalesReportShareBatch ss = new SC_ComparisonSalesReportShareBatch(this.startDate,this.endDate);
            Database.executeBatch(ss);
        }
        
    }
}