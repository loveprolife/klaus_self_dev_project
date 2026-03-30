global class SC_SalesTargetShareBatch extends SC_Base implements Database.Batchable<sObject> , Database.Stateful{
    global SC_SalesTargetShareBatch() {
        super();
    }

    global SC_SalesTargetShareBatch(String startDate, String endDate) {
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
                SELECT Id, Customer_Name__c,Product_Line__c,OwnerId 
                FROM Sales_Target__c 
                WHERE Product_Line__c != null 
                AND Customer_Name__c in:customerIdSet
                ]);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        SalesShareService service = new SalesShareService();
        service.shareData(
            scope, 
            this.updatedList(),
            customerIdSet,
            null,
            'Sales_Target__Share',
            'Customer_Name__c',
            'Product_Line__c');

        service.removeShare(
            scope,
            this.deletedList(),
            null,
            'Sales_Target__Share',
            'Customer_Name__c',
            'Product_Line__c');
    }

    global void finish(Database.BatchableContext BC) {
        SC_RevenueStatementReportShareBatch ss = new SC_RevenueStatementReportShareBatch(this.startDate,this.endDate);
        Database.executeBatch(ss);
    }
}