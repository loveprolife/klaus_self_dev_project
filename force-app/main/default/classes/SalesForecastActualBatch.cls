/**********************************************************************
* Name: SalesForecastActualBatch
* Object: Monthly Sales Forecast VS Actual Report
* Purpose: 
* 月度销售预测与销售实际对比表
* Author: Gerry
* Create Date: 2019-04-03
*************************************************************************/
global class SalesForecastActualBatch implements Database.Batchable<sObject> {
    public String query;
    public String dateYearMonth;

    global SalesForecastActualBatch() {

        dateYearMonth = String.valueOf(System.now().year()+System.now().month());

        this.query = 'SELECT Product_Line__c,Oversea_Company_Sales_Department__c,Product_Model__c,Date_Year_And_Month__c,'+
                     'Customer__c,N_Month_Invoiced_Volume__c,N_Month_DO_Released_Not_Invoced_Volume__c, N_Month_POD__c,'+
                     'N_Month_Not_Released_Order__c,N_Month_Virtual_Order__c,Invoiced_Turnover__c,DO_Released_Not_Invoced_Turnover__c,'+
                     'Virtual_Turnover__c FROM Monthly_Sales_Forecast_VS_Actual_Report__c WHERE Date_Year_And_Month__c=:dateYearMonth';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Monthly_Sales_Forecast_VS_Actual_Report__c> salesForecastActualList) {
        // //产品线的set
        // Set<String> productSet = new Set<String>();
        // //产品型号的set
        // Set<String> modelSet = new Set<String>();

        // for (Monthly_Sales_Forecast_VS_Actual_Report__c msf : salesForecastActualList) {
            
        // }
    }

    global void finish(Database.BatchableContext BC) {

    }
}