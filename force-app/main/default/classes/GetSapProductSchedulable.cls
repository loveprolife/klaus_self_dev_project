public class GetSapProductSchedulable implements Schedulable {

    String schedulable_name;
    String dateFrom;
    String dateTo;
    Integer index = 0;
    Boolean allDateFlg = false;
    Boolean allHeFlg = false;
    Boolean flag = false;

    public GetSapProductSchedulable(String schedulable_name, String dateFrom, String dateTo, Integer index, Boolean allDateFlg, Boolean allHeFlg) {
        this.schedulable_name = schedulable_name;
        this.dateFrom = dateFrom;
        this.dateTo = dateTo;
        this.index = index;
        this.allDateFlg = allDateFlg;
        this.allHeFlg = allHeFlg;
    }

    public GetSapProductSchedulable(Boolean flag) {
        this.flag = flag;
    }

    public GetSapProductSchedulable() {}

    public void execute(SchedulableContext sc) {
        
        if(flag){
            Batch_SapProductCreate ss  = new Batch_SapProductCreate();
		    Database.executeBatch(ss);
        }else{

            if(!'GetSapProductSchedulable'.equals(schedulable_name)){
                // 删除定时任务
                deleteSchedulable(schedulable_name);
            }
            
            if(String.isBlank(dateFrom)){
                Date currentDate = Date.today().addDays(-1);
                DateTime currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
                dateFrom = currentDateTime.format('yyyyMMdd');
            }
    
            if(String.isBlank(dateTo)){
                Date currentDate = Date.today();
                DateTime currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
                dateTo = currentDateTime.format('yyyyMMdd');
            }
    
            Call_GetProductFromSAP.getProductFromSAPAll(dateFrom, dateTo, index, allDateFlg, allHeFlg);
            
        }
    }

    public static void deleteSchedulable(String name) {
        // 删除定时任务
        List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name = :name and CronJobDetail.JobType = '7'];
        if(cronTriggers.size() > 0){
           for(cronTrigger cronTrigger : cronTriggers){
              System.abortJob(cronTrigger.id);
           }
        }
    }
}