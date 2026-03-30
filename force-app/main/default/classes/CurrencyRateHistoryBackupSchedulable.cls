/**************************************************************************************************
 * Name:CurrencyRateHistoryBackupSchedulable
 * Purpose:每月底备份历史汇率,暂定为每月28号
 * Author: Deloitte Johnson
 * Create Date: 2019-07-11
***************************************************************************************************/
global class CurrencyRateHistoryBackupSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
    	List<Currency_Rate_History__c> rateHistoryList = new List<Currency_Rate_History__c>();
    	for(CurrencyType cType :[SELECT IsoCode,ConversionRate,IsActive,IsCorporate FROM CurrencyType WHERE IsActive = TRUE]){
            Currency_Rate_History__c rateHistory = new Currency_Rate_History__c();
            rateHistory.Name = 'Currency Rate' + System.now().format('yyyyMM');
            rateHistory.Year__c = System.now().format('yyyy');
            rateHistory.Month__c = System.now().format('MM');
            rateHistory.CurrencyIsoCode = cType.IsoCode;
            rateHistory.Conversion_Rate__c = cType.ConversionRate;
            rateHistory.IsActive__c = cType.IsActive;
            rateHistory.IsCorporate__c = cType.IsCorporate;
            rateHistoryList.add(rateHistory);
    	}
    	insert rateHistoryList;
    }
}