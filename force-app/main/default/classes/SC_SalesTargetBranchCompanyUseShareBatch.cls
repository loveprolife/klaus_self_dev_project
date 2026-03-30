/**********************************************************************
* Name: SC_SalesTargetBranchCompanyUseShareBatch
* Object: Sales_Target_Branch_Company_Use__c 
* Purpose: 
* Sales_Target_Branch_Company_Use__c权限共享batch
* Author: Gerry
* Create Date: 2019-11-13
*************************************************************************/
global class SC_SalesTargetBranchCompanyUseShareBatch extends SC_Base implements Database.Batchable<sObject>, Database.Stateful {
    
    Map<String,Set<String>> summaryProductLineMap;

    global SC_SalesTargetBranchCompanyUseShareBatch() {
        super();
    }

    global SC_SalesTargetBranchCompanyUseShareBatch(String startDate, String endDate) {
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

        this.summaryProductLineMap = new Map<String,Set<String>>();

        for(Customer_Product_Line__c cProLine : 
                [SELECT Id,Name,Management_Customer_Branch_Company__c,
                    Product_Line_Name__c,Parent_Product_Line__c 
                  FROM Customer_Product_Line__c 
                  WHERE Management_Customer_Branch_Company__c IN:customerIdSet]) {

            String key = cProLine.Management_Customer_Branch_Company__c + cProLine.Product_Line_Name__c;
            if(summaryProductLineMap.containsKey(key)){
                summaryProductLineMap.get(key).add(cProLine.Product_Line_Name__c);
            }else{
                summaryProductLineMap.put(key,new Set<String>{cProLine.Product_Line_Name__c});
            }
        }

        return Database.getQueryLocator(
                [
                SELECT Id,Customer_Name__c,Product_Line__c,OwnerId,Year__c 
                FROM Sales_Target_Branch_Company_Use__c 
                WHERE Customer_Name__c in:customerIdSet
                ]);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        SalesShareService service = new SalesShareService();
        service.shareData(
            scope, 
            this.updatedList(),
            customerIdSet,
            summaryProductLineMap,
            'Sales_Target_Branch_Company_Use__Share',
            'Customer_Name__c',
            'Product_Line__c');

        service.removeShare(
            scope,
            this.deletedList(),
            summaryProductLineMap,
            'Sales_Target_Branch_Company_Use__Share',
            'Customer_Name__c',
            'Product_Line__c');
    }

    global void finish(Database.BatchableContext BC) {

    }
}