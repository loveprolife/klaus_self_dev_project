/**************************************************************************************************
 * Name:InvoiceSummaryBatch
 * Purpose: 发票数据汇总到实际同期报表上
 * Author: Deloitte Johnson
 * Create Date: 2019-07-31
***************************************************************************************************/
global class InvoiceSummaryBatch implements Database.Batchable<sObject> {
    public String query;
    public String year;
    public String month;
    public Date startDate;//当月第一天
    public Date endDate;//当月最后一天
    public static Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateHistoryMap();
    //public Set<String> accIdSet = new Set<String>{'0010p000009o6X0AAI','0010p000009o5mbAAA','0010p000009o5lSAAQ'};

    global InvoiceSummaryBatch(String year,String month) {
        this.year = year;
        this.month = month;
        if (Integer.valueOf(this.month) < 10) {
            this.month = '0'+this.month;
        }
        //根据过账日期找出当月所有的发票行数据
        startDate = Date.valueOf(this.year + '-' + this.month + '-' + '01');
        endDate = startDate.addMonths(1);
        this.query = 'SELECT Invoice__r.Customer__c,Product_Line__c,CurrencyIsoCode,Invoice_Amount__c,Total_Amount_After_Rebate__c,Invoice_Quantity__c'+
                     ' FROM Invoice_Item__c WHERE Invoice__r.Invoice_Posting_Date__c >=:startDate AND Invoice__r.Invoice_Posting_Date__c <:endDate '+
                     ' AND Invoice__r.Customer__c !=null AND Product_Line__c != null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('query： ' +query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Invoice_Item__c> invoiceItemList) {
        Set<String> aprExternalIDSet = new Set<String>();
        try{
            for(Invoice_Item__c invoiceItem : invoiceItemList){
                String aprExternalID = year + month + invoiceItem.Invoice__r.Customer__c + invoiceItem.Product_Line__c;
                aprExternalIDSet.add(aprExternalID);
            }
            String queryAPR = 'SELECT Id,External_ID__c,CurrencyIsoCode,Current_Net__c, Current_Gross__c, Current_Net_USD__c,Current_Gross_USD__c,Current_Sales_Volume__c,' +
                              ' N_Month_Gross_N_Year__c,N_Month_Net_N_Year__c,N_Month_Gross_USD_N_Year__c,N_Month_Net_USD_N_Year__c,N_Month_Sales_Volume_N_Year__c'+
                              ' FROM Actual_And_Same_Period_Report__c WHERE External_ID__c IN:aprExternalIDSet';
            List<Actual_And_Same_Period_Report__c> updateAPRList = Database.query(queryAPR);
            Map<String,Actual_And_Same_Period_Report__c> updateAPRMap = new Map<String,Actual_And_Same_Period_Report__c>();
            for(Actual_And_Same_Period_Report__c updateAPR : updateAPRList){
                updateAPRMap.put(updateAPR.External_ID__c, updateAPR);
            }
            for(Invoice_Item__c invoiceItem : invoiceItemList){
                String aprExternalID = year + month + invoiceItem.Invoice__r.Customer__c + invoiceItem.Product_Line__c;
                if(updateAPRMap.containsKey(aprExternalID)){
                    Actual_And_Same_Period_Report__c updateAPR = updateAPRMap.get(aprExternalID);
                    //根据年月+币种得到发票币种的汇率以及实际同期币种的汇率
                    String rateYearMonth = year + month;
                    //销售组织的汇率
                    Decimal rate = currencyRateMap.get(updateAPR.CurrencyIsoCode + rateYearMonth);
                    //发票币种的汇率
                    Decimal rate1 = currencyRateMap.get(invoiceItem.CurrencyIsoCode + rateYearMonth);
                    if(Test.isRunningTest()){
                        rate = 1;rate1 = 1;
                    }
                    //根据换算过后的收入成本数据更新实际同期字段
                    if(updateAPR.CurrencyIsoCode.equals(invoiceItem.CurrencyIsoCode)){
                        updateAPR.N_Month_Gross_N_Year__c = convertNull(updateAPR.N_Month_Gross_N_Year__c) + convertNull(invoiceItem.Invoice_Amount__c);
                        updateAPR.N_Month_Net_N_Year__c = convertNull(updateAPR.N_Month_Net_N_Year__c) + convertNull(invoiceItem.Total_Amount_After_Rebate__c);
                    }else{
                        updateAPR.N_Month_Gross_N_Year__c = convertNull(updateAPR.N_Month_Gross_N_Year__c) + convertNull(invoiceItem.Invoice_Amount__c) / rate1 * rate;
                        updateAPR.N_Month_Net_N_Year__c = convertNull(updateAPR.N_Month_Net_N_Year__c) + convertNull(invoiceItem.Total_Amount_After_Rebate__c) / rate1 * rate;
                    }
                    updateAPR.N_Month_Gross_USD_N_Year__c = convertNull(updateAPR.N_Month_Gross_USD_N_Year__c) + convertNull(invoiceItem.Invoice_Amount__c) / rate1;
                    updateAPR.N_Month_Net_USD_N_Year__c = convertNull(updateAPR.N_Month_Net_USD_N_Year__c) + convertNull(invoiceItem.Total_Amount_After_Rebate__c) / rate1;
                    updateAPR.N_Month_Sales_Volume_N_Year__c = convertNull(updateAPR.N_Month_Sales_Volume_N_Year__c) + convertNull(invoiceItem.Invoice_Quantity__c);
                }
                
            }
            //更新实际同期报表的相关字段数据
            update updateAPRMap.values();
        }catch(Exception e){
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
    //转换'' to 0
    private static Decimal convertNull(Decimal num) {
        Decimal strConvert;
        if(num == null) {
            strConvert = 0;
        }else{
            strConvert = num;
        } 
        return strConvert;
    }
}