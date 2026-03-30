global class WeeklySalesTargetSchedulable implements Schedulable {
    public String schedulable_name;
    public String action;
    public Integer week;
    
    global WeeklySalesTargetSchedulable (String schedulable_name, Integer week, String action){
        this.schedulable_name = schedulable_name;
        this.week = week;
        this.action = action;
    }

    global void execute(SchedulableContext sc) {

        if(week == null || week <= 0 || week > 53){
            week = NewWeeklySalesTargetButtonController.getWeekOfYear(System.today());
        }

        if('channel'.equals(action)){
            NewWeeklySalesTargetButtonController.updateChannelData(System.now().year(), week);
        }else{
            NewWeeklySalesTargetButtonController.runBatch('', String.valueOf(week));
        }
        
    }

}