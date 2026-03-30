/**********************************************************************
* Name: SalesTargetBranchCompanyUseShareBatch
* Object: Sales_Target_Branch_Company_Use__c 
* Purpose: 
* Sales_Target_Branch_Company_Use__c权限共享batch
* Author: Gerry
* Create Date: 2019-11-13
*************************************************************************/
global class SalesTargetBranchCompanyUseShareBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;

    global SalesTargetBranchCompanyUseShareBatch(String inputYear) {
        this.year = inputYear;
        this.query = 'SELECT ID,Customer_Name__c,Product_Line__c,OwnerId,Year__c FROM Sales_Target_Branch_Company_Use__c WHERE Year__c=:year';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sales_Target_Branch_Company_Use__c> salesTargetBranchCompanyUseList) {
        Set<String> accIdSet = new Set<String>();

        for (Sales_Target_Branch_Company_Use__c stb : salesTargetBranchCompanyUseList) {
            accIdSet.add(stb.Customer_Name__c);
        }

        List<Sales__c> salesList = [SELECT id, Customer__c, Sales__c, Sales__r.IsActive,IsKeyUser__c ,Product_Line__c FROM Sales__c WHERE Customer__c IN : accIdSet AND Sales__r.IsActive = TRUE];
        Map<String, List<Sales__c>> salesMap = new Map<String, List<Sales__c>>();
        for (Sales__c salesData : salesList) {
            if(salesMap.containsKey(salesData.Customer__c)){
                salesMap.get(salesData.Customer__c).add(salesData);
            }else{
                salesMap.put(salesData.Customer__c,new List<Sales__c>{salesData});
            }
        }

        //查询所有客户产品线
        //通过客户加上粗的产品线指向细的产品线 例如：CustomerA + HA => Refrigerator，Freezer，WM，，，
        Map<String,Set<String>> summaryProductLineMap = new Map<String,Set<String>>();
        for(Customer_Product_Line__c cProLine : [SELECT Id,Name,Management_Customer_Branch_Company__c,Product_Line_Name__c,Parent_Product_Line__c 
                                                 FROM Customer_Product_Line__c WHERE Management_Customer_Branch_Company__c IN:accIdSet]){
            String key = cProLine.Management_Customer_Branch_Company__c + cProLine.Parent_Product_Line__c;
            if(summaryProductLineMap.containsKey(key)){
                summaryProductLineMap.get(key).add(cProLine.Product_Line_Name__c);
            }else{
                summaryProductLineMap.put(key,new Set<String>{cProLine.Product_Line_Name__c});
            }
        }

        List<Sales_Target_Branch_Company_Use__Share> insertstbcList = new List<Sales_Target_Branch_Company_Use__Share>();

        //设置Share
        Map<String, Sales_Target_Branch_Company_Use__Share> insertstbcMap = new Map<String, Sales_Target_Branch_Company_Use__Share>();
        for (Sales_Target_Branch_Company_Use__c stbc : salesTargetBranchCompanyUseList) {
            List<Sales__c> salescList = salesMap.get(stbc.Customer_Name__c);
            //通过客户加上粗的产品线对应找到细的产品线有哪几条 例如：CustomerA + HA => Refrigerator，Freezer，WM，，，
            Set<String> stbcProductLineSet = summaryProductLineMap.get(stbc.Customer_Name__c + stbc.Product_Line__c);
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            Boolean flag = false;
            if (salescList == null || stbcProductLineSet == null) {
                continue;
            }
            for (Sales__c salesme : salescList) {
                for(String stbcProductLine : stbcProductLineSet){
                    if (Utility.isExistProductLine(salesme.Product_Line__c,stbcProductLine)) {
                        Sales_Target_Branch_Company_Use__Share stbcShare = new Sales_Target_Branch_Company_Use__Share();
                        stbcShare.RowCause = 'Manual';
                        stbcShare.ParentId = stbc.Id;
                        stbcShare.UserOrGroupId  = salesme.Sales__c;
                        stbcShare.AccessLevel = 'Read';
                        String idKeyString = String.valueOf(stbc.Id)+String.valueOf(salesme.Sales__c);
                        insertstbcMap.put(idKeyString, stbcShare);
                        productLineSalesList.add(salesme);
                        //如果为keyuser，设置为owner
                        if (salesme.IsKeyUser__c) {
                            stbc.OwnerId = salesme.Sales__c;
                            flag = true;
                        }
                        break;//只要销售负责其中一条产品线即可Share，因此跳出该层循环
                    }
                }
                
            }
            if (flag == false && productLineSalesList.size() > 0) {
                stbc.OwnerId = productLineSalesList[0].Sales__c;
                
            }
            String mapString = String.valueOf(stbc.Id)+String.valueOf(stbc.OwnerId);
            if (insertstbcMap.containsKey(mapString)) {
                insertstbcMap.remove(mapString);
            }
            
        }
        
        
        try{
            update salesTargetBranchCompanyUseList;
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }

        if(insertstbcMap.size() > 0){
            insertstbcList = insertstbcMap.values();
            try{
                Database.upsert(insertstbcList);
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}