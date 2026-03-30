/**********************************************************************
*  System.schedule('BulkApiSchedulable-Initialize', '0 0 12 * * ?', new BulkApiSchedulable('2022-02-02', 0));
*  System.schedule('BulkApiSchedulable-data', '0 0 12 * * ?', new BulkApiSchedulable('2022-02-02', 1));
*************************************************************************/
global class BulkApiSchedulable implements Schedulable {

    // 时间参数
    public String erdat;
    // 定时任务初始化标识
    public Integer index;

    global BulkApiSchedulable (String erdat, Integer index){
        this.erdat = erdat;
        this.index = index;
    }

    global void execute(SchedulableContext sc) {
        if(index == 0){
            // 当前时间N分钟，下一次定时时间
            DateTime reTime = System.Now().addMinutes(1);
            Integer minute = reTime.minute();
            Integer hour = reTime.hour();  
            String con = '0 ' + minute + ' ' + hour + ' * * ?';
            // 删除初始化定时
            deleteSchedulable('BulkApiSchedulable-Initialize');
            if(Date.parse(erdat) < System.today()){
                Date erdatNew = Date.valueOf(erdat).addDays(1);
                String year1 = erdatNew.year() + '';
                String month1 = erdatNew.month() < 10 ? 0+''+erdatNew.month() : erdatNew.month() + '';
                String day1 = erdatNew.day() < 10 ? 0 +''+erdatNew.day() : erdatNew.day() + '';
                String erdatStr = year1 + '-' + month1 + '-' + day1;
                System.schedule('BulkApiSchedulable-Initialize', con, new BulkApiSchedulable(erdatStr, 0));
            }
            // 执行方法
            BulkApi.bulkApiTest(erdat);
        }else {
            BulkApi.bulkApiTest(String.isNotBlank(erdat) ? erdat : Datetime.now().addDays(-1).format('yyyy-MM-dd'));
        }

        Utility.insertBatchLog('BulkApiSchedulable',JSON.serialize(erdat));
        
    }


    global void deleteSchedulable(String name) {
        // 删除定时任务
        List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name =:name and CronJobDetail.JobType = '7'];
        if(cronTriggers.size() > 0){
           for(cronTrigger cronTrigger : cronTriggers){
              System.abortJob(cronTrigger.id);
           }
        }
     }
  
}