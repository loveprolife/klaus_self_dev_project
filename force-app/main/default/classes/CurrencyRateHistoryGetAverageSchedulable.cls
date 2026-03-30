/**************************************************************************************************
 * Name:CurrencyRateHistoryGetAverageSchedulable
 * Purpose:根据上月和当月汇率求平均值作为历史汇率,仅能执行一次，谨慎操作
 * Author: Deloitte Johnson
 * Create Date: 2019-09-24
***************************************************************************************************/
global class CurrencyRateHistoryGetAverageSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
    	List<Currency_Rate_History__c> updateRateHistoryList = new List<Currency_Rate_History__c>();
    	Map<String,Decimal> currentRateMap = new Map<String,Decimal>();
    	Datetime lastMonthTime = System.now().addHours(8).addMonths(-1);//由于系统时间为GMT，需要加8小时换算成北京时间
    	String year = lastMonthTime.format('yyyy');
    	String month = lastMonthTime.format('MM');
    	for(CurrencyType cType :[SELECT IsoCode,ConversionRate,IsActive,IsCorporate FROM CurrencyType WHERE IsActive = TRUE]){
            currentRateMap.put(cType.IsoCode, cType.ConversionRate);
    	}
    	for(Currency_Rate_History__c rateHistory : [SELECT Id,CurrencyIsoCode,Conversion_Rate__c FROM Currency_Rate_History__c
    		                                        WHERE Conversion_Rate__c != null
    		                                        AND Year__c =:year
    		                                        AND Month__c =:month]){
            if(currentRateMap.containsKey(rateHistory.CurrencyIsoCode)){
                rateHistory.Conversion_Rate__c = (currentRateMap.get(rateHistory.CurrencyIsoCode) + rateHistory.Conversion_Rate__c)/2;
            	updateRateHistoryList.add(rateHistory);
            }
    	}
    	update updateRateHistoryList;
    }
}