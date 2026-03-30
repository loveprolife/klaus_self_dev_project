/**********************************************************************
* Name: ActualAndSamePeriodReportShareWBatch
* Object: Actual_And_Same_Period_Report__c
* Purpose: ActualAndSamePeriodRepor share权限
* Create Date: 2019-08-02
*************************************************************************/
global class ActualAndSamePeriodReportShareWBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;
    public String region;

    global ActualAndSamePeriodReportShareWBatch(String year,String month) {
        this.year = year;
        this.month = month;
        this.region = 'Hisense USA';
        if (Integer.valueOf(this.month) < 10) {
            this.month = '0'+this.month;
        }
        this.query = 'SELECT Id,Customer__c,Product_Line__c,OwnerId FROM Actual_And_Same_Period_Report__c'+ 
                     ' WHERE Year__c =:year AND Month__c =:month and Customer__r.Sales_Region__c = :region';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Actual_And_Same_Period_Report__c> aprList) {
        Set<String> cusIdSet = new Set<String>();
        Set<String> aprIdSet = new Set<String>();

        for (Actual_And_Same_Period_Report__c apr : aprList) {
            aprIdSet.add(apr.Id);
            cusIdSet.add(apr.Customer__c);
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
        Map<String,Actual_And_Same_Period_Report__Share> upsertAPRShareMap = new Map<String,Actual_And_Same_Period_Report__Share>();
        for (Actual_And_Same_Period_Report__c apr : aprList) {
            List<Sales__c> salescList = salesMap.get(apr.Customer__c);
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            Boolean flag = false;
            if (salescList == null) {
                continue;
            }
            for (Sales__c salesme : salescList) {
                if (Utility.isExistProductLine(salesme.Product_Line__c,apr.Product_Line__c)) {
                    Actual_And_Same_Period_Report__Share aprShare = new Actual_And_Same_Period_Report__Share();
                    aprShare.RowCause = 'Manual';
                    aprShare.ParentId = apr.Id;
                    aprShare.UserOrGroupId  = salesme.Sales__c;
                    aprShare.AccessLevel = 'Read';
                    String idKeyString = String.valueOf(apr.Id)+String.valueOf(salesme.Sales__c);
                    upsertAPRShareMap.put(idKeyString, aprShare);
                    productLineSalesList.add(salesme);
                    //如果为keyuser，设置为owner
                    if (salesme.IsKeyUser__c) {
                        apr.OwnerId = salesme.Sales__c;
        
                        flag = true;
                    }
                }
            }
            if (flag == false && productLineSalesList.size() > 0) {
                apr.OwnerId = productLineSalesList[0].Sales__c;
            }
            String mapString = String.valueOf(apr.Id)+String.valueOf(apr.OwnerId);
            if (upsertAPRShareMap.containsKey(mapString)) {
                upsertAPRShareMap.remove(mapString);
            }
        }
        
                
        try{
            update aprList;
            if(upsertAPRShareMap.size() > 0){
                List<Actual_And_Same_Period_Report__Share> upsertAPRShareList = upsertAPRShareMap.values();
                Database.upsert(upsertAPRShareList);
            }
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}