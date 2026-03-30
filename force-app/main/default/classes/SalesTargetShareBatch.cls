/**********************************************************************
* Name: SalesTargetShareBatch
* Object: Sales_Target__c 
* Purpose: 
* SalesTarget share权限
* Create Date: 2019-06-19
*************************************************************************/
global class SalesTargetShareBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;

    global SalesTargetShareBatch(String year) {
        this.year = year;
        this.query = 'SELECT id, Customer_Name__c,Product_Line__c,OwnerId FROM Sales_Target__c WHERE Year__c = :year AND Product_Line__c != null AND Customer_Name__c !=null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sales_Target__c> salesTargetList) {
        Set<String> cusIdSet = new Set<String>();
        Set<String> salesTargetIdSet = new Set<String>();

        for (Sales_Target__c salesTargetData : salesTargetList) {
            salesTargetIdSet.add(salesTargetData.Id);
            cusIdSet.add(salesTargetData.Customer_Name__c);
        }

        List<Sales__c> salesList = [SELECT id, Customer__c, Sales__c, Sales__r.IsActive,IsKeyUser__c ,Product_Line__c FROM Sales__c WHERE Customer__c IN : cusIdSet AND Sales__r.IsActive = TRUE];
        Map<String, List<Sales__c>> salesMap = new Map<String, List<Sales__c>>();
        for (Sales__c salesData : salesList) {
            if(salesMap.containsKey(salesData.Customer__c)){
                salesMap.get(salesData.Customer__c).add(salesData);
            }else{
                salesMap.put(salesData.Customer__c,new List<Sales__c>{salesData});
            }
        }

        List<Sales_Target__Share> insertSalesTargetList = new List<Sales_Target__Share>();
        // List<Sales_Target__Share> existSalesTargetList =[SELECT ParentId,UserOrGroupId FROM Sales_Target__Share WHERE ParentId IN :salesTargetIdSet];
        // Map<String,Set<String>> accessUserMap = new Map<String,Set<String>>();

        // for(Sales_Target__Share salesTargetShareData : existSalesTargetList){
        //     if(accessUserMap.containsKey(salesTargetShareData.ParentId)){
        //         accessUserMap.get(salesTargetShareData.ParentId).add(salesTargetShareData.UserOrGroupId);
        //     }else{
        //         accessUserMap.put(salesTargetShareData.ParentId, new Set<String>{salesTargetShareData.UserOrGroupId});
        //     }
        // }


        //设置Share
        Map<String, Sales_Target__Share> insertSalesTargetMap = new Map<String, Sales_Target__Share>();
        for (Sales_Target__c salesTargetData : salesTargetList) {
            List<Sales__c> salescList = salesMap.get(salesTargetData.Customer_Name__c);
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            Boolean flag = false;
            if (salescList == null) {
                continue;
            }
            for (Sales__c salesme : salescList) {
                // if (salesTargetData.OwnerId != salesme.Sales__c) {
                //     if(accessUserMap.containsKey(salesTargetData.Id) && accessUserMap.get(salesTargetData.Id).contains(salesme.Sales__c)){
                //         continue;
                //     }
                // }
                
                if (Utility.isExistProductLine(salesme.Product_Line__c,salesTargetData.Product_Line__c)) {
                    Sales_Target__Share salesTargetShareData = new Sales_Target__Share();
                    salesTargetShareData.RowCause = 'Manual';
                    salesTargetShareData.ParentId = salesTargetData.Id;
                    salesTargetShareData.UserOrGroupId  = salesme.Sales__c;
                    salesTargetShareData.AccessLevel = 'Read';
                    String idKeyString = String.valueOf(salesTargetData.Id)+String.valueOf(salesme.Sales__c);
                    insertSalesTargetMap.put(idKeyString, salesTargetShareData);
                    productLineSalesList.add(salesme);
                    //如果为keyuser，设置为owner
                    if (salesme.IsKeyUser__c) {
                        salesTargetData.OwnerId = salesme.Sales__c;
                        // String existOwnerReDataId =String.valueOf(salesTargetData.Id)+String.valueOf(salesme.Sales__c);
                        // insertSalesTargetMap.remove(existOwnerReDataId);
                        flag = true;
                    }
                }
            }
            if (flag == false && productLineSalesList.size() > 0) {
                salesTargetData.OwnerId = productLineSalesList[0].Sales__c;
                
            }
            String mapString = String.valueOf(salesTargetData.Id)+String.valueOf(salesTargetData.OwnerId);
            if (insertSalesTargetMap.containsKey(mapString)) {
                insertSalesTargetMap.remove(mapString);
            }
            
        }
        
        
        try{
            update salesTargetList;
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }

        if(insertSalesTargetMap.size() > 0){
            insertSalesTargetList = insertSalesTargetMap.values();
            try{
                Database.upsert(insertSalesTargetList);
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}