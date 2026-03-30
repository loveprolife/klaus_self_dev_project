global class PlannedCompletionRateReportShareBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;

    global PlannedCompletionRateReportShareBatch(String inputYear,String inputMonth) {
        this.year = inputYear;
        this.month = inputMonth;
        if (Integer.valueOf(this.month) < 10) {
            this.month = '0'+this.month;
        }
        this.query = 'SELECT ID,Management_Customer__c,Product_Line__c,OwnerId,Year__c,Month__c FROM Planned_Completion_Rate_Report__c WHERE Year__c=:year AND Month__c=:month';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Planned_Completion_Rate_Report__c> pcrrList) {
        Set<String> accIdSet = new Set<String>();
        Set<String> pcrrIdSet = new Set<String>();

        for (Planned_Completion_Rate_Report__c pcrr : pcrrList) {
            pcrrIdSet.add(pcrr.Id);
            accIdSet.add(pcrr.Management_Customer__c);
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
        //System.debug('summaryProductLineMap: ' + summaryProductLineMap);

        List<Planned_Completion_Rate_Report__Share> insertpcrrList = new List<Planned_Completion_Rate_Report__Share>();
        
        //设置Share
        Map<String, Planned_Completion_Rate_Report__Share> insertPcrrMap = new Map<String, Planned_Completion_Rate_Report__Share>();
        for (Planned_Completion_Rate_Report__c pcrr : pcrrList) {
            List<Sales__c> salescList = salesMap.get(pcrr.Management_Customer__c);
            //通过客户加上粗的产品线对应找到细的产品线有哪几条 例如：CustomerA + HA => Refrigerator，Freezer，WM，，，
            Set<String> pcrrProductLineSet = summaryProductLineMap.get(pcrr.Management_Customer__c + pcrr.Product_Line__c);
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            Boolean flag = false;
            if (salescList == null || pcrrProductLineSet == null) {
                continue;
            }
            for (Sales__c salesme : salescList) {
                for(String pcrrProductLine : pcrrProductLineSet){
                    if (Utility.isExistProductLine(salesme.Product_Line__c,pcrrProductLine)) {
                        Planned_Completion_Rate_Report__Share pcrrShare = new Planned_Completion_Rate_Report__Share();
                        pcrrShare.RowCause = 'Manual';
                        pcrrShare.ParentId = pcrr.Id;
                        pcrrShare.UserOrGroupId  = salesme.Sales__c;
                        pcrrShare.AccessLevel = 'Read';
                        String idKeyString = String.valueOf(pcrr.Id)+String.valueOf(salesme.Sales__c);
                        insertPcrrMap.put(idKeyString, pcrrShare);
                        productLineSalesList.add(salesme);
                        //如果为keyuser，设置为owner
                        if (salesme.IsKeyUser__c) {
                            pcrr.OwnerId = salesme.Sales__c;
                            flag = true;
                        }
                        break;//只要销售负责其中一条产品线即可Share，因此跳出该层循环
                    }
                }
                
            }
            if (flag == false && productLineSalesList.size() > 0) {
                pcrr.OwnerId = productLineSalesList[0].Sales__c;
                
            }
            String mapString = String.valueOf(pcrr.Id)+String.valueOf(pcrr.OwnerId);
            if (insertPcrrMap.containsKey(mapString)) {
                insertPcrrMap.remove(mapString);
            }
            
        }
        
        
        try{
            update pcrrList;
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }

        if(insertPcrrMap.size() > 0){
            insertpcrrList = insertPcrrMap.values();
            try{
                Database.upsert(insertpcrrList);
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}