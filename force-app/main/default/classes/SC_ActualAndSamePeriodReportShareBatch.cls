global class SC_ActualAndSamePeriodReportShareBatch extends SC_Base implements Database.Batchable<sObject> , Database.Stateful{
    global SC_ActualAndSamePeriodReportShareBatch() {
        super();
    }

    global SC_ActualAndSamePeriodReportShareBatch(String startDate, String endDate) {
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
                SELECT Id,Customer__c,Product_Line__c,OwnerId 
                FROM Actual_And_Same_Period_Report__c 
                WHERE Customer__c in:customerIdSet
                ]);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        SalesShareService service = new SalesShareService();
        service.shareData(
            scope, 
            this.updatedList(),
            customerIdSet,
            null,
            'Actual_And_Same_Period_Report__Share',
            'Customer__c',
            'Product_Line__c');

        service.removeShare(
            scope,
            this.deletedList(),
            null,
            'Actual_And_Same_Period_Report__Share',
            'Customer__c',
            'Product_Line__c');
    }

    global void finish(Database.BatchableContext BC) {
        SC_GrowthRateReportBatchShareBatch ss = new SC_GrowthRateReportBatchShareBatch(this.startDate,this.endDate);
        Database.executeBatch(ss);
    }
}