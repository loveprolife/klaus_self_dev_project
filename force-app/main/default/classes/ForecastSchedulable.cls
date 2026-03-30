global class ForecastSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {

        Map<Integer,String> monthMap = new Map<Integer,String>();
        monthMap.put(1,'Jan');
        monthMap.put(2,'Feb');
        monthMap.put(3,'Mar');
        monthMap.put(4,'Apr');
        monthMap.put(5,'May');
        monthMap.put(6,'Jun');
        monthMap.put(7,'Jul');
        monthMap.put(8,'Aug');
        monthMap.put(9,'Sept');
        monthMap.put(10,'Oct');
        monthMap.put(11,'Nov');
        monthMap.put(12,'Dec');

        list<Forecast__c> listF = [select id,Customer__c,Current_Month_Forecast__c,Next_Month_Forecast__c,Next_Next_Month_Forecast__c,YTD_Actual__c from Forecast__c];

        for(Forecast__c f : listF){

            Integer year = Date.today().year();
            Integer month = Date.today().month();

            List<AggregateResult> ytdActualList = [select sum(Order_Amount__c)ytd from Order__c where CALENDAR_YEAR(Order_Date__c) =:year and Customer__c =:f.Customer__c];
            f.YTD_Actual__c = Double.valueOf(ytdActualList.get(0).get('ytd'));

            String externalKey = f.Customer__c + String.valueOf(year) + String.valueOf(month);
            list<Customer_Sales_Forecast__c> csf = [select id,Amount__c,Probability__c from Customer_Sales_Forecast__c where External_Key__c = :externalKey and Month__c = :monthMap.get(month)];
            if(csf != null && csf.size() > 0){
                f.Current_Month_Forecast__c = csf.get(0).Amount__c * csf.get(0).Probability__c / 100;
            }else{
                f.Current_Month_Forecast__c = Double.valueOf(0);
            }

            year = Date.today().addMonths(1).year();
            month = Date.today().addMonths(1).month();
            externalKey = f.Customer__c + String.valueOf(year) + String.valueOf(month);
            csf = [select id,Amount__c,Probability__c from Customer_Sales_Forecast__c where External_Key__c = :externalKey and Month__c = :monthMap.get(month)];
            if(csf != null && csf.size() > 0){
                f.Next_Month_Forecast__c = csf.get(0).Amount__c * csf.get(0).Probability__c / 100;
            }else{
                f.Next_Month_Forecast__c = Double.valueOf(0);
            }

            year = Date.today().addMonths(2).year();
            month = Date.today().addMonths(2).month();
            externalKey = f.Customer__c + String.valueOf(year) + String.valueOf(month);
            csf = [select id,Amount__c,Probability__c from Customer_Sales_Forecast__c where External_Key__c = :externalKey and Month__c = :monthMap.get(month)];
            if(csf != null && csf.size() > 0){
                f.Next_Next_Month_Forecast__c = csf.get(0).Amount__c * csf.get(0).Probability__c / 100;
            }else{
                f.Next_Next_Month_Forecast__c = Double.valueOf(0);
            }
        }

        Database.update(listF);
    }
}