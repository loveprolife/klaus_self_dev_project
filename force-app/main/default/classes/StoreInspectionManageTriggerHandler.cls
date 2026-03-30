public class StoreInspectionManageTriggerHandler implements Triggers.Handler{

    public void handle() {
        if (Trigger.isAfter && Trigger.isInsert) {
            List<Store_Inspection_Manage_Daily_Sales__c> addList = new  List<Store_Inspection_Manage_Daily_Sales__c>();
            for(Store_Inspection_Manage__c sim : ((list<Store_Inspection_Manage__c>)Trigger.new)) {
                if(sim.Task_Type__c == '销售额'){
                    Date firstDay = Date.newInstance(Integer.valueOf(sim.Year__c), Integer.valueOf(sim.Month__c), 1);
                    Date nextMonthFirstDay = firstDay.addMonths(1);
                    List<Retail_Number__c> rnList = new List<Retail_Number__c>();
                    if(sim.Store__c != null){
                        rnList = [SELECT Id, TotalPrice__c, CurrencyIsoCode FROM Retail_Number__c 
                                    WHERE Store_Sales_Region__c = :sim.Sales_Region__c
                                    AND ReportDate__c >= :firstDay
                                    AND ReportDate__c < :nextMonthFirstDay
                                    AND Product_Line__c = :sim.Product_Line__c
                                    AND Shop__c  = :sim.Store__c
                                ];
                    }else {
                        rnList = [SELECT Id, TotalPrice__c, CurrencyIsoCode FROM Retail_Number__c 
                                    WHERE Store_Sales_Region__c = :sim.Sales_Region__c
                                    AND ReportDate__c >= :firstDay
                                    AND ReportDate__c < :nextMonthFirstDay
                                    AND Product_Line__c = :sim.Product_Line__c
                                ];
                    }
                    

                    for(Retail_Number__c rn : rnList){
                        Store_Inspection_Manage_Daily_Sales__c simds = new Store_Inspection_Manage_Daily_Sales__c();
                        simds.Daily_Sales__c = rn.id;
                        simds.Total_Price__c = rn.TotalPrice__c;
                        simds.Store_Inspection_Manage__c = sim.id;
                        simds.CurrencyIsoCode = rn.CurrencyIsoCode;
                        addList.add(simds);
                    }
                }
            }
            Database.insert(addList);
        }
    }
}