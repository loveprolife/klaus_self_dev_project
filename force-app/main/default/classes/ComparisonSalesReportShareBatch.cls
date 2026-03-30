/**********************************************************************
* Name: ComparisonSalesReportShareBatch
* Object: Comparison_Sales_Report_YoY__c 
* Purpose: Comparison Sales Report(YoY) share权限
* Create Date: 2019-06-27
*************************************************************************/
global class ComparisonSalesReportShareBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;

    global ComparisonSalesReportShareBatch(String year,String month) {
        this.year = year;
        this.month = month;
        
        this.query = 'SELECT ID,Product_Line_Code__c,Customer__c,OwnerId FROM Comparison_Sales_Report_YoY__c WHERE Product_Line_Code__c != null AND Customer__c !=null AND Year__c =:year and Month__c =:month';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Comparison_Sales_Report_YoY__c> csrDataList) {
        Set<String> cusIdSet = new Set<String>();
        Set<String> sapCostrevenueIdSet = new Set<String>();

        for (Comparison_Sales_Report_YoY__c csrData : csrDataList) {
            sapCostrevenueIdSet.add(csrData.Id);
            cusIdSet.add(csrData.Customer__c);
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


        //设置share
        Map<String,Comparison_Sales_Report_YoY__Share> insertCSRShareMap = new Map<String,Comparison_Sales_Report_YoY__Share>();
        List<Comparison_Sales_Report_YoY__Share> insertCSRShareList = new List<Comparison_Sales_Report_YoY__Share>();
        
        for (Comparison_Sales_Report_YoY__c csrData : csrDataList) {
            List<Sales__c> salescList = salesMap.get(csrData.Customer__c);
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            Boolean flag = false;
            if (salescList ==null) {
                continue;
            }
            for (Sales__c salesme : salescList) { 
                
                if (Utility.isExistProductLine(salesme.Product_Line__c,csrData.Product_Line_Code__c)) {
                    Comparison_Sales_Report_YoY__Share csrShareData = new Comparison_Sales_Report_YoY__Share();
                    csrShareData.RowCause = 'Manual';
                    csrShareData.ParentId = csrData.Id;
                    csrShareData.UserOrGroupId  = salesme.Sales__c;
                    csrShareData.AccessLevel = 'Read';
                    String idKeyString = String.valueOf(csrData.Id)+String.valueOf(salesme.Sales__c);
                    insertCSRShareMap.put(idKeyString, csrShareData);
                    productLineSalesList.add(salesme);
                    //如果为keyuser，设置为owner
                    if (salesme.IsKeyUser__c) {
                        csrData.OwnerId = salesme.Sales__c;
                        flag = true;
                    }
                }
            }
            if (flag == false && productLineSalesList.size() >0) {
                csrData.OwnerId = productLineSalesList[0].Sales__c;  
            }
            String mapString = String.valueOf(csrData.Id)+String.valueOf(csrData.OwnerId);
            if (insertCSRShareMap.containsKey(mapString)) {
                insertCSRShareMap.remove(mapString);
            }
            

        }
           
        try{
            update csrDataList;
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }


        if(insertCSRShareMap.size()>0){
            insertCSRShareList = insertCSRShareMap.values();
            try{
                Database.upsert(insertCSRShareList);
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}