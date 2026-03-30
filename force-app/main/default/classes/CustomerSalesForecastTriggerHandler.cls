/*
 * @Author: WFC
 * @Date: 2023-03-23 16:38:33
 * @LastEditors: WFC
 * @LastEditTime: 2023-03-31 16:07:32
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\classes\CustomerExtendTriggerHandler.cls
 */
public class CustomerSalesForecastTriggerHandler implements Triggers.Handler{
    
    public void handle() {

        Map<String,Integer> monthMap = new Map<String,Integer>();
        monthMap.put('Jan',1);
        monthMap.put('Feb',2);
        monthMap.put('Mar',3);
        monthMap.put('Apr',4);
        monthMap.put('May',5);
        monthMap.put('Jun',6);
        monthMap.put('Jul',7);
        monthMap.put('Aug',8);
        monthMap.put('Sept',9);
        monthMap.put('Oct',10);
        monthMap.put('Nov',11);
        monthMap.put('Dec',12);

        if (Trigger.isBefore && Trigger.isInsert) {        
            System.debug('Customer_Sales_Forecast__c-----beforeInsert');
            
            for (Customer_Sales_Forecast__c csf : ((list<Customer_Sales_Forecast__c>)Trigger.new)) {

                Integer year = Integer.valueOf(csf.year__c);
                Integer month = monthMap.get(csf.month__c);

                List<AggregateResult> actualList = [select sum(Order_Amount__c)actual from Order__c where CALENDAR_YEAR(Order_Date__c) =:year 
                                                                                    and CALENDAR_month(Order_Date__c) =:month
                                                                                    and Customer__c =:csf.Customer__c];

                for(AggregateResult ar : actualList){
                    csf.Actual__c = Double.valueOf(ar.get('actual'));
                }

                csf.External_Key__c = csf.Customer__c + String.valueOf(year) + String.valueOf(month);

                list<Forecast__c> listF = [select id from Forecast__c where External_key__c =:csf.Customer__c];
                Forecast__c f = null;

                if(listF == null || listF.size() == 0){
                    f = new Forecast__c();
                    f.Customer__c = csf.Customer__c;
                    f.External_Key__c = csf.Customer__c;
                    List<AggregateResult> ytdActualList = [select sum(Order_Amount__c)ytd from Order__c where CALENDAR_YEAR(Order_Date__c) =:year and Customer__c =:csf.Customer__c];
                    f.YTD_Actual__c = Double.valueOf(ytdActualList.get(0).get('ytd'));
                }else{
                    f = listF.get(0);
                    List<AggregateResult> ytdActualList = [select sum(Order_Amount__c)ytd from Order__c where CALENDAR_YEAR(Order_Date__c) =:year and Customer__c =:csf.Customer__c];
                    f.YTD_Actual__c = Double.valueOf(ytdActualList.get(0).get('ytd'));
                }

                if(Date.today().month() == month && Date.today().year() == year){
                    f.Current_Month_Forecast__c = csf.Amount__c * csf.Probability__c / 100;
                }else if(Date.today().addMonths(1).month() == month && Date.today().year() == year){
                    f.Next_Month_Forecast__c = csf.Amount__c * csf.Probability__c / 100;
                }else if(Date.today().addMonths(2).month() == month && Date.today().year() == year){
                    f.Next_Next_Month_Forecast__c = csf.Amount__c * csf.Probability__c / 100;
                }
                

                Database.upsert(f);
            }
        }


        if (Trigger.isBefore && Trigger.isUpdate) {

            System.debug('Customer_Sales_Forecast__c-----beforeUpdate');

            for (Customer_Sales_Forecast__c csf : ((list<Customer_Sales_Forecast__c>)Trigger.new)) {

                Integer year = Date.today().year();
                Integer month = monthMap.get(csf.month__c);

                List<AggregateResult> actualList = [select sum(Order_Amount__c)actual from Order__c where CALENDAR_YEAR(Order_Date__c) =:year 
                                                                                    and CALENDAR_month(Order_Date__c) =:month
                                                                                    and Customer__c =:csf.Customer__c];

                for(AggregateResult ar : actualList){
                    csf.Actual__c = Double.valueOf(ar.get('actual'));
                }

                csf.External_Key__c = csf.Customer__c + String.valueOf(year) + String.valueOf(month);

                list<Forecast__c> listF = [select id from Forecast__c where External_key__c =:csf.Customer__c];
                Forecast__c f = null;

                if(listF == null || listF.size() == 0){
                    f = new Forecast__c();
                    f.Customer__c = csf.Customer__c;
                    f.External_Key__c = csf.Customer__c;
                    List<AggregateResult> ytdActualList = [select sum(Order_Amount__c)ytd from Order__c where CALENDAR_YEAR(Order_Date__c) =:year and Customer__c =:csf.Customer__c];
                    f.YTD_Actual__c = Double.valueOf(ytdActualList.get(0).get('ytd'));
                }else{
                    f = listF.get(0);
                    List<AggregateResult> ytdActualList = [select sum(Order_Amount__c)ytd from Order__c where CALENDAR_YEAR(Order_Date__c) =:year and Customer__c =:csf.Customer__c];
                    f.YTD_Actual__c = Double.valueOf(ytdActualList.get(0).get('ytd'));
                }

                if(Date.today().month() == month && Date.today().year() == year){
                    f.Current_Month_Forecast__c = csf.Amount__c * csf.Probability__c / 100;
                }else if(Date.today().addMonths(1).month() == month && Date.today().year() == year){
                    f.Next_Month_Forecast__c = csf.Amount__c * csf.Probability__c / 100;
                }else if(Date.today().addMonths(2).month() == month && Date.today().year() == year){
                    f.Next_Next_Month_Forecast__c = csf.Amount__c * csf.Probability__c / 100;
                }

                Database.upsert(f);
            }
        }

        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {

        }

    }
}