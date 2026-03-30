global class RevenueStatementReportShareBatch implements Database.Batchable<sObject> {
    public String query;

    global RevenueStatementReportShareBatch() {
        this.query = 'SELECT Id,Customer__c,Product_Line__c FROM Revenue_Statement_Report__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Revenue_Statement_Report__c> sObjList) {
        System.debug('sObjList.size(): '+sObjList.size());
        Set<String> accIdSet = new Set<String>();
        Map<String,List<Revenue_Statement_Report__c>> rspMap = new Map<String,List<Revenue_Statement_Report__c>>();
        for(Revenue_Statement_Report__c sObj : sObjList){
            accIdSet.add(sObj.Customer__c);
            if(rspMap.containsKey(sObj.Customer__c)){
                rspMap.get(sObj.Customer__c).add(sObj);
            }else{
                rspMap.put(sObj.Customer__c,new List<Revenue_Statement_Report__c>{sObj});
            }
        }
        List<Sales__c> salesList = [SELECT Customer__c,Product_Line__c,Sales__c FROM Sales__c 
                                    WHERE Customer__c IN:accIdSet AND Sales__r.IsActive = TRUE];
        Integer count = 0;
        for(Sales__c sales : salesList){
            for(Revenue_Statement_Report__c sObj : rspMap.get(sales.Customer__c)){
                if(sales.Product_Line__c.contains(sObj.Product_Line__c)){
                    sObj.OwnerId = sales.Sales__c;
                    count ++;
                }
            }
        }
        System.debug('count : '+ count);
        try{
            update sObjList;
        }catch(Exception e){
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());    
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}