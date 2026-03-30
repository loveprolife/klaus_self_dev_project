/**************************************************************************************************
 * Name:ActualAndSamePeriodReportExcluBatch
 * Purpose: 生成实际同期报表数据
 * Author: wfc
 * Create Date: 2020-06-18
 * 执行方法 Database.executeBatch(new ActualAndSamePeriodReportExcluBatch(year,month),200);
***************************************************************************************************/
global class ActualAndSamePeriodReportExcluBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;
    public String region;
    public List<String> proLineList = Label.Product_Line_List.split(',');
    //获取客户销售组织对应币种Map
    public static Map<String,String> hEntityCurrencyMap = Utility.getHisenseEntityCurrencyMap();

    global ActualAndSamePeriodReportExcluBatch(String year, String month, String region) {
        this.year = year;
        this.month = month;
        this.region = region;
        // this.region = 'Hisense USA';
        if (Integer.valueOf(this.month) < 10) {
            this.month = '0'+this.month;
        }
        this.query = 'SELECT Id,Customer__c,Customer__r.Hisense_Entity__c,Product_Line_Name__c FROM Customer_Product_Line__c' + 
                     ' WHERE Product_Line_Name__c IN:proLineList AND (Customer__r.Hisense_Entity__c = :region OR Customer__r.Sales_Region__c =:region)';
    
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Customer_Product_Line__c> customerProLineList) {
        // Actual_And_Same_Period_Report__c已存在的External_ID__c
        Set<String> externalIdList = new Set<String>();
        List<Actual_And_Same_Period_Report__c> conList = [select id,External_ID__c from Actual_And_Same_Period_Report__c where Year__c = :year and Month__c = :month];
        for(Actual_And_Same_Period_Report__c con : conList){
            externalIdList.add(con.External_ID__c);
        }

        Map<String,Actual_And_Same_Period_Report__c> upsertAPRMap = new Map<String,Actual_And_Same_Period_Report__c>();
        //初始化已有的实际同期报表数据，生成新的实际同期报表数据
        for(Customer_Product_Line__c customerPro : customerProLineList){
            Actual_And_Same_Period_Report__c upsertAPR = new Actual_And_Same_Period_Report__c();
            upsertAPR.Year__c = year;
            upsertAPR.Month__c = month;
            upsertAPR.Customer__c = customerPro.Customer__c;
            upsertAPR.Customer_Product_Line__c = customerPro.Id;
            upsertAPR.N_Month_Sales_Volume_N_Year__c = null;
            upsertAPR.N_Month_Gross_N_Year__c = null;
            upsertAPR.N_Month_Net_N_Year__c = null;
            upsertAPR.N_Month_Gross_USD_N_Year__c = null;
            upsertAPR.N_Month_Net_USD_N_Year__c = null;
            upsertAPR.N_Month_Sales_Volume_N_1_Year__c = null;
            upsertAPR.N_Month_Gross_N_1_Year__c = null;
            upsertAPR.N_Month_Net_N_1_Year__c = null;
            upsertAPR.N_Month_Gross_USD_N_1_Year__c = null;
            upsertAPR.N_Month_Net_USD_N_1_Year__c = null;
            upsertAPR.Current_Sales_Volume__c = null;
            upsertAPR.Current_Gross__c = null;
            upsertAPR.Current_Net__c = null;
            upsertAPR.Current_Gross_USD__c = null;
            upsertAPR.Current_Net_USD__c = null;
            upsertAPR.External_ID__c = year + month + customerPro.Customer__c + customerPro.Product_Line_Name__c;
            upsertAPR.CurrencyIsoCode = String.isBlank(customerPro.Customer__r.Hisense_Entity__c)? null : hEntityCurrencyMap.get(customerPro.Customer__r.Hisense_Entity__c);
            
            if(!externalIdList.contains(upsertAPR.External_ID__c)){
                upsertAPRMap.put(upsertAPR.External_ID__c,upsertAPR);
            }
            
        }
        
        try{
            upsert upsertAPRMap.values() External_ID__c;
        }catch(Exception e){
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC) {
        //Actual And Same Period Report权限Share
        // ActualAndSamePeriodReportShareBatch aprShare = new ActualAndSamePeriodReportShareBatch(year,Integer.valueOf(month)+'');
        // Database.executeBatch(aprShare,200);

        Share_Common_IntegrationBatch aprShareBatch = new Share_Common_IntegrationBatch(
            'Actual_And_Same_Period_Report__c', 
            false, 
            '',
            0,
            ''
        );
        Database.executeBatch(aprShareBatch, 30);
    }
}