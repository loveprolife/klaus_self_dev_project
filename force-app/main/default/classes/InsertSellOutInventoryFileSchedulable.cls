global class InsertSellOutInventoryFileSchedulable implements Schedulable {
    public String schedulable_name;
    public String deleteStrDate;
    public Boolean flg;
 
    global InsertSellOutInventoryFileSchedulable (String schedulable_name, String deleteStrDate){
        this.schedulable_name = schedulable_name;
        this.deleteStrDate = deleteStrDate;
    }

    global InsertSellOutInventoryFileSchedulable (String schedulable_name, String deleteStrDate, Boolean flg){
        this.schedulable_name = schedulable_name;
        this.deleteStrDate = deleteStrDate;
        this.flg = flg;
    }


    global void execute(SchedulableContext sc) {
        try {

            // 删除定时任务
            deleteSchedulable(schedulable_name);

            if(flg != null && flg){
                list<Sell_out_Inventory__c> dl = [select id from Sell_out_Inventory__c where create_dt__c = :deleteStrDate limit 9500];
                if(dl !=  null && dl.size() > 0){
                    Database.delete(dl);

                    if(dl.size() < 9500){
                        // 当前时间N分钟，下一次定时时间
                        DateTime reTime = System.Now().addSeconds(5);
                        Integer second = reTime.second();
                        Integer minute = reTime.minute();
                        Integer hour = reTime.hour();  
                        String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                        // 生成唯一值
                        Blob b = Crypto.GenerateAESKey(128);
                        String h = EncodingUtil.ConvertTohex(b) + 'read';
                        System.schedule(h, con, new InsertSellOutInventoryFileSchedulable(h, deleteStrDate));
                        
                    }else{
                        // 当前时间N分钟，下一次定时时间
                        DateTime reTime = System.Now().addSeconds(5);
                        Integer second = reTime.second();
                        Integer minute = reTime.minute();
                        Integer hour = reTime.hour();  
                        String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                        // 生成唯一值
                        Blob b = Crypto.GenerateAESKey(128);
                        String h = EncodingUtil.ConvertTohex(b) + 'delete';
                        System.schedule(h, con, new InsertSellOutInventoryFileSchedulable(h, deleteStrDate, true));
                    }
                }else{
                    // 当前时间N分钟，下一次定时时间
                    DateTime reTime = System.Now().addSeconds(5);
                    Integer second = reTime.second();
                    Integer minute = reTime.minute();
                    Integer hour = reTime.hour();  
                    String con = second + ' ' + minute + ' ' + hour + ' * * ?';
        
                    // 生成唯一值
                    Blob b = Crypto.GenerateAESKey(128);
                    String h = EncodingUtil.ConvertTohex(b) + 'read';
                    System.schedule(h, con, new InsertSellOutInventoryFileSchedulable(h, deleteStrDate));
                }
            }else{
                GetSellOutInventory.readTextAndInsert(deleteStrDate);
            }

        } catch (Exception e) {
            system.debug('error message'+e.getMessage());
            Utility.insertLog('InsertSellOutInventoryFileSchedulable', '0', null,  '-----' + schedulable_name);
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