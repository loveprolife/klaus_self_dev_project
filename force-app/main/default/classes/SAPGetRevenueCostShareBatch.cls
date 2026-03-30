/**********************************************************************
* Name: SAPGetRevenueCostShareBatch
* Object: SAP_Cost_Revenue_Data__c 
* Purpose: 
* SAPGetRevenueCost share权限
* Create Date: 2019-06-19
*************************************************************************/
global class SAPGetRevenueCostShareBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;

    global SAPGetRevenueCostShareBatch(String year,String month) {
        this.year = year;
        this.month = month;
        if (Integer.valueOf(this.month)<10) {
            this.month = '0'+this.month;
        }
        
        this.query = 'SELECT ID,Product_Line_Text__c,Product_Line__c,Customer__c,OwnerId FROM SAP_Cost_Revenue_Data__c WHERE Product_Line__c != null AND Customer__c !=null AND Year__c =:year and Month__c =:month';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<SAP_Cost_Revenue_Data__c> revenueDataList) {
        Set<String> cusIdSet = new Set<String>();
        Set<String> sapCostrevenueIdSet = new Set<String>();

        for (SAP_Cost_Revenue_Data__c revenueData : revenueDataList) {
            sapCostrevenueIdSet.add(revenueData.Id);
            cusIdSet.add(revenueData.Customer__c);
        }

        //对应的sales
        Map<String, List<Sales__c>> salesMap = new Map<String, List<Sales__c>>();
        List<Sales__c> salesList = [SELECT id, IsKeyUser__c, Customer__c, Sales__c, Sales__r.IsActive, Product_Line__c FROM Sales__c WHERE Customer__c IN : cusIdSet AND Sales__r.IsActive = TRUE];
        for (Sales__c salesData : salesList) {
            if(salesMap.containsKey(salesData.Customer__c)){
                salesMap.get(salesData.Customer__c).add(salesData);
            }else{
                salesMap.put(salesData.Customer__c,new List<Sales__c>{salesData});
            }
        }

        //已存在的手动share
        // List<SAP_Cost_Revenue_Data__Share> existSAPRevenueShareList =[SELECT ParentId,UserOrGroupId FROM SAP_Cost_Revenue_Data__Share WHERE ParentId IN :sapCostrevenueIdSet];
        // Map<String,Set<String>> accessUserMap = new Map<String,Set<String>>();

        // for(SAP_Cost_Revenue_Data__Share revenueShareData : existSAPRevenueShareList){
        //     if(accessUserMap.containsKey(revenueShareData.ParentId)){
        //         accessUserMap.get(revenueShareData.ParentId).add(revenueShareData.UserOrGroupId);
        //     }else{
        //         accessUserMap.put(revenueShareData.ParentId, new Set<String>{revenueShareData.UserOrGroupId});
        //     }
        // }

        //设置share
        Map<String,SAP_Cost_Revenue_Data__Share> insertSAPRevenueShareMap = new Map<String,SAP_Cost_Revenue_Data__Share>();
        List<SAP_Cost_Revenue_Data__Share> insertSAPRevenueShareList = new List<SAP_Cost_Revenue_Data__Share>();
        
        for (SAP_Cost_Revenue_Data__c revenueData : revenueDataList) {
            List<Sales__c> salescList = salesMap.get(revenueData.Customer__c);
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            Boolean flag = false;
            if (salescList ==null) {
                continue;
            }
            for (Sales__c salesme : salescList) { 
                
                // if (revenueData.OwnerId != salesme.Sales__c) {
                //     if(accessUserMap.containsKey(revenueData.Id) && accessUserMap.get(revenueData.Id).contains(salesme.Sales__c)){
                //         continue;
                //     }
                // }
                
                if (Utility.isExistProductLine(salesme.Product_Line__c,revenueData.Product_Line__c)) {
                    SAP_Cost_Revenue_Data__Share revenueShareData = new SAP_Cost_Revenue_Data__Share();
                    revenueShareData.RowCause = 'Manual';
                    revenueShareData.ParentId = revenueData.Id;
                    revenueShareData.UserOrGroupId  = salesme.Sales__c;
                    revenueShareData.AccessLevel = 'Read';
                    String idKeyString = String.valueOf(revenueData.Id)+String.valueOf(salesme.Sales__c);
                    insertSAPRevenueShareMap.put(idKeyString, revenueShareData);
                    productLineSalesList.add(salesme);
                    //如果为keyuser，设置为owner
                    if (salesme.IsKeyUser__c) {
                        revenueData.OwnerId = salesme.Sales__c;
                        // String existOwnerReDataId =String.valueOf(revenueData.Id)+String.valueOf(salesme.Sales__c);
                        // insertSAPRevenueShareMap.remove(existOwnerReDataId);
                        flag = true;
                    }
                }
            }
            if (flag == false && productLineSalesList.size() >0) {
                revenueData.OwnerId = productLineSalesList[0].Sales__c;  
            }
            String mapString = String.valueOf(revenueData.Id)+String.valueOf(revenueData.OwnerId);
            if (insertSAPRevenueShareMap.containsKey(mapString)) {
                insertSAPRevenueShareMap.remove(mapString);
            }
            

        }
           
        try{
            update revenueDataList;
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }


        if(insertSAPRevenueShareMap.size()>0){
            insertSAPRevenueShareList = insertSAPRevenueShareMap.values();
            try{
                Database.upsert(insertSAPRevenueShareList);
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}