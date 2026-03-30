global class SC_OrderShareBatch extends SC_Base implements Database.Batchable<sObject> , Database.Stateful {
    public Set<String> salesIdSet;
    global SC_OrderShareBatch() {
        super();
    }

    global SC_OrderShareBatch(String startDate, String endDate) {
        super(startDate, endDate);
        
    }
    global SC_OrderShareBatch(String startDate, String endDate, Set<String> salesIdSet){
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

        return Database.getQueryLocator([select id,Customer__c,OwnerId,
                (select id,Product_Line__c FROM Order_Products__r 
                    where Product_Line__c != null LIMIT 1) 
                FROM Order__c where Customer__c in:this.customerIdSet]);
    }

    global void execute(Database.BatchableContext BC, list<Order__c> scope) {
        SalesShareService service = new SalesShareService();
        service.shareOrder(scope,this.updatedList());

        Set<String> salesIds = new Set<String>();
        Map<String, Sales__c> salesMap = new Map<String, Sales__c>();

        for (Sales__c sales : this.deletedList()) {         
            salesIds.add(sales.Sales__c);
            List<String> productLines = sales.Product_Line__c.split(';');
            for(String productLine: productLines){
                salesMap.put(sales.Customer__c + productLine, sales);
            }
        }

        Set<String> data_sales_keySet = new Set<String>();
        Set<String> dataIds = new Set<String>();
        
        for(Order__c data: scope){
            if(data.Order_Products__r !=null && data.Order_Products__r.size()>0) {
                String key = data.Customer__c + data.Order_Products__r[0].Product_Line__c;
                if(salesMap.containsKey(key)) {
                    dataIds.add(data.Id);
                    Sales__c sales = salesMap.get(key);
                    data_sales_keySet.add(data.Id +''+ sales.Sales__c);
                }
            }
        }
        service.removeSharingDataByDataAndUserIds(data_sales_keySet,salesIds,dataIds,'Order__Share');
    }

    global void finish(Database.BatchableContext BC) {
        SC_SAPGetRevenueCostShareBatch ss = new SC_SAPGetRevenueCostShareBatch(this.startDate,this.endDate,this.salesIdSet);
        Database.executeBatch(ss);
    }
}