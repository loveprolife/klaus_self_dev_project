/**********************************************************************
* Name: RevenueStatementReportManualShareBatch
* Object: Revenue_Statement_Report__c
* Purpose: 
* RevenueStatementReport share权限
* Create Date: 2019-06-19
*************************************************************************/
global class RevenueStatementReportManualShareBatch implements Database.Batchable<sObject> {
    public String query;
    // public String year;
    // public String month;
    public String year;
    public String month;

    global RevenueStatementReportManualShareBatch(String year,String month) {
        this.year = year;
        this.month = month;
        this.query = 'SELECT Id,Customer__c,Product_Line__c,OwnerId FROM Revenue_Statement_Report__c WHERE Product_Line__c != null AND Customer__c !=null AND Year__c =:year and Month__c =:month';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Revenue_Statement_Report__c> revenueStatementReportList) {
        Set<String> cusIdSet = new Set<String>();
        Set<String> revenueStatementReportIdSet = new Set<String>();

        for (Revenue_Statement_Report__c revenueStatementReportData : revenueStatementReportList) {
            revenueStatementReportIdSet.add(revenueStatementReportData.Id);
            cusIdSet.add(revenueStatementReportData.Customer__c);
        }

        List<Sales__c> salesList = [SELECT id, Customer__c, Sales__c, Sales__r.IsActive,IsKeyUser__c, Product_Line__c FROM Sales__c WHERE Customer__c IN : cusIdSet AND Sales__r.IsActive = TRUE];
        Map<String, List<Sales__c>> salesMap = new Map<String, List<Sales__c>>();
        for (Sales__c salesData : salesList) {
            if(salesMap.containsKey(salesData.Customer__c)){
                salesMap.get(salesData.Customer__c).add(salesData);
            }else{
                salesMap.put(salesData.Customer__c,new List<Sales__c>{salesData});
            }
        }


        List<Revenue_Statement_Report__Share> insertRevenueStatementList = new List<Revenue_Statement_Report__Share>();
        // List<Revenue_Statement_Report__Share> existRevenueStatementList =[SELECT ParentId,UserOrGroupId FROM Revenue_Statement_Report__Share WHERE ParentId IN :revenueStatementReportIdSet];
        // Map<String,Set<String>> accessUserMap = new Map<String,Set<String>>();

        // for(Revenue_Statement_Report__Share revenueStatementShareData : existRevenueStatementList){
        //     if(accessUserMap.containsKey(revenueStatementShareData.ParentId)){
        //         accessUserMap.get(revenueStatementShareData.ParentId).add(revenueStatementShareData.UserOrGroupId);
        //     }else{
        //         accessUserMap.put(revenueStatementShareData.ParentId, new Set<String>{revenueStatementShareData.UserOrGroupId});
        //     }
        // }

        //设置Share
        Map<String,Revenue_Statement_Report__Share> insertRevenueStatementMap = new Map<String,Revenue_Statement_Report__Share>();
        for (Revenue_Statement_Report__c revenueStatementReportData : revenueStatementReportList) {
            List<Sales__c> salescList = salesMap.get(revenueStatementReportData.Customer__c);
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            Boolean flag = false;
            if (salescList == null) {
                continue;
            }
            for (Sales__c salesme : salescList) {
                // if (revenueStatementReportData.OwnerId != salesme.Sales__c) {
                //     if(accessUserMap.containsKey(revenueStatementReportData.Id) && accessUserMap.get(revenueStatementReportData.Id).contains(salesme.Sales__c)){
                //         continue;
                //     }
                // }
                
                if (Utility.isExistProductLine(salesme.Product_Line__c,revenueStatementReportData.Product_Line__c)) {
                    Revenue_Statement_Report__Share revenueStatementShareData = new Revenue_Statement_Report__Share();
                    revenueStatementShareData.RowCause = 'Manual';
                    revenueStatementShareData.ParentId = revenueStatementReportData.Id;
                    revenueStatementShareData.UserOrGroupId  = salesme.Sales__c;
                    revenueStatementShareData.AccessLevel = 'Read';
                    String idKeyString = String.valueOf(revenueStatementReportData.Id)+String.valueOf(salesme.Sales__c);
                    insertRevenueStatementMap.put(idKeyString, revenueStatementShareData);
                    productLineSalesList.add(salesme);
                    //如果为keyuser，设置为owner
                    if (salesme.IsKeyUser__c) {
                        revenueStatementReportData.OwnerId = salesme.Sales__c;
                        // String existOwnerReDataId =String.valueOf(revenueStatementReportData.Id)+String.valueOf(salesme.Sales__c);
                        // insertRevenueStatementMap.remove(existOwnerReDataId);
                        flag = true;
                    }
                }
            }
            if (flag == false && productLineSalesList.size() > 0) {
                revenueStatementReportData.OwnerId = productLineSalesList[0].Sales__c;
            }
            String mapString = String.valueOf(revenueStatementReportData.Id)+String.valueOf(revenueStatementReportData.OwnerId);
            if (insertRevenueStatementMap.containsKey(mapString)) {
                insertRevenueStatementMap.remove(mapString);
            }
        }
        
                
           

        try{
            update revenueStatementReportList;
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }

        if(insertRevenueStatementMap.size() > 0){
            insertRevenueStatementList = insertRevenueStatementMap.values();
            try{
                Database.upsert(insertRevenueStatementList);
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}